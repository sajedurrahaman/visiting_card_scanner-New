import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visiting_card/app/storage/folder_entity.dart';
import 'package:visiting_card/app/storage/folder_record.dart';
import 'package:visiting_card/app/storage/saved_file_entity.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';

/// Local persistence — PDF Scanner Isar Plus pattern for files + folders.
///
/// [getAllFiles] / [getAllFolders] are served from in-memory caches refreshed
/// after every write.
class AppStorageService {
  AppStorageService._();

  static final AppStorageService instance = AppStorageService._();

  factory AppStorageService() => instance;

  static Isar? _isar;
  static SharedPreferences? _prefs;

  static const String _legacyAllFilesKey = 'allFiles';
  static const String _migratedKey = 'isar_saved_files_migrated_v1';
  static const String _legacyFoldersKey = 'sub_folders_v1';
  static const String _foldersMigratedKey = 'isar_folders_migrated_v1';

  List<SavedFileModel> _cache = const [];
  List<FolderRecord> _folderCache = const [];

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.openAsync(
      schemas: [SavedFileEntitySchema, FolderEntitySchema],
      directory: directory.path,
      name: 'visiting_card',
    );

    await instance._migrateFromSharedPreferencesIfNeeded();
    await instance._migrateFoldersFromSharedPreferencesIfNeeded();
    instance._reloadCache();
    instance._reloadFolderCache();
  }

  Isar get _db {
    final isar = _isar;
    if (isar == null) {
      throw StateError(
        'AppStorageService is not initialized. Call AppStorageService.init() first.',
      );
    }
    return isar;
  }

  SharedPreferences get _storage {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'AppStorageService is not initialized. Call AppStorageService.init() first.',
      );
    }
    return prefs;
  }

  List<SavedFileModel> getAllFiles() =>
      List<SavedFileModel>.unmodifiable(_cache);

  List<FolderRecord> getAllFolders() =>
      List<FolderRecord>.unmodifiable(_folderCache);

  Future<void> saveFolder(FolderRecord folder) async {
    final existing =
        _db.folders.where().folderIdEqualTo(folder.id).findFirst();
    final entity = FolderEntity()
      ..id = existing?.id ?? _db.folders.autoIncrement()
      ..folderId = folder.id
      ..name = folder.name
      ..dateTime = folder.dateTime
      ..parentFolderId = folder.parentFolderId;

    await _db.writeAsync((isar) {
      isar.folders.put(entity);
    });
    _reloadFolderCache();
  }

  Future<void> deleteFolders(Iterable<String> folderIds) async {
    final remove = folderIds.toSet();
    if (remove.isEmpty) return;

    await _db.writeAsync((isar) {
      for (final folderId in remove) {
        final existing =
            isar.folders.where().folderIdEqualTo(folderId).findFirst();
        if (existing != null) {
          isar.folders.delete(existing.id);
        }
      }
    });
    _reloadFolderCache();
  }

  Future<void> replaceAllFolders(List<FolderRecord> folders) async {
    await _db.writeAsync((isar) {
      isar.folders.clear();
      if (folders.isEmpty) return;
      final entities = <FolderEntity>[];
      for (final folder in folders) {
        entities.add(
          FolderEntity()
            ..id = isar.folders.autoIncrement()
            ..folderId = folder.id
            ..name = folder.name
            ..dateTime = folder.dateTime
            ..parentFolderId = folder.parentFolderId,
        );
      }
      isar.folders.putAll(entities);
    });
    _reloadFolderCache();
  }

  void _reloadFolderCache() {
    final entities = _db.folders.where().findAll();
    _folderCache = entities
        .map(
          (e) => FolderRecord(
            id: e.folderId,
            name: e.name,
            dateTime: e.dateTime,
            parentFolderId: e.parentFolderId,
          ),
        )
        .where((f) => f.id.isNotEmpty && f.parentFolderId.isNotEmpty)
        .toList();
  }

  Future<void> _migrateFoldersFromSharedPreferencesIfNeeded() async {
    if (_storage.getBool(_foldersMigratedKey) == true) return;

    final raw = _storage.getString(_legacyFoldersKey);
    if (raw != null && raw.isNotEmpty && raw != '[]') {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final records = decoded
              .whereType<Map>()
              .map(
                (item) =>
                    FolderRecord.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((f) => f.id.isNotEmpty && f.parentFolderId.isNotEmpty)
              .toList();

          if (records.isNotEmpty) {
            await _db.writeAsync((isar) {
              final entities = <FolderEntity>[];
              for (final folder in records) {
                entities.add(
                  FolderEntity()
                    ..id = isar.folders.autoIncrement()
                    ..folderId = folder.id
                    ..name = folder.name
                    ..dateTime = folder.dateTime
                    ..parentFolderId = folder.parentFolderId,
                );
              }
              isar.folders.putAll(entities);
            });
          }
        }
      } catch (_) {
        // Keep going — mark migrated so we do not loop on corrupt JSON.
      }
    }

    await _storage.setBool(_foldersMigratedKey, true);
    await _storage.remove(_legacyFoldersKey);
  }

  Future<void> storeAllFiles(SavedFileModel model) async {
    final existing =
        _db.savedFiles.where().fileIdEqualTo(model.id).findFirst();
    final entity = _toEntity(model, existingId: existing?.id);
    await _db.writeAsync((isar) {
      isar.savedFiles.put(entity);
    });
    _reloadCache();
  }

  Future<void> updateFile(SavedFileModel model) async {
    final existing =
        _db.savedFiles.where().fileIdEqualTo(model.id).findFirst();
    if (existing == null) {
      await storeAllFiles(model);
      return;
    }

    final entity = _toEntity(model, existingId: existing.id);
    await _db.writeAsync((isar) {
      isar.savedFiles.put(entity);
    });
    _reloadCache();
  }

  Future<void> replaceAllFiles(List<SavedFileModel> files) async {
    await _db.writeAsync((isar) {
      isar.savedFiles.clear();
      if (files.isEmpty) return;
      final entities = <SavedFileEntity>[];
      for (final file in files) {
        entities.add(
          SavedFileEntity()
            ..id = isar.savedFiles.autoIncrement()
            ..fileId = file.id
            ..name = file.name
            ..dateTime = file.dateTime
            ..path = file.path
            ..pathImage = file.pathImage
            ..fileType = file.fileType
            ..folderId = file.folderId
            ..isTextFile = file.isTextFile,
        );
      }
      isar.savedFiles.putAll(entities);
    });
    _reloadCache();
  }

  void _reloadCache() {
    // PDF Scanner recent parity: newest first (Isar id desc / latest saves on top).
    final entities = _db.savedFiles.where().sortByIdDesc().findAll();
    final models = entities.map(_toModel).toList();
    models.sort(_compareNewestFirst);
    _cache = models;
  }

  /// Prefer timestamp prefix in [SavedFileModel.id]; fall back to dateTime / id.
  static int _compareNewestFirst(SavedFileModel a, SavedFileModel b) {
    final aKey = _recencyKey(a);
    final bKey = _recencyKey(b);
    final byKey = bKey.compareTo(aKey);
    if (byKey != 0) return byKey;
    return b.id.compareTo(a.id);
  }

  static int _recencyKey(SavedFileModel file) {
    final fromId = RegExp(r'^(\d+)').firstMatch(file.id)?.group(1);
    final parsedId = fromId == null ? null : int.tryParse(fromId);
    if (parsedId != null && parsedId > 0) return parsedId;

    try {
      return DateFormat('dd-MMM-yyyy HH:mm').parse(file.dateTime).millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _migrateFromSharedPreferencesIfNeeded() async {
    if (_storage.getBool(_migratedKey) == true) return;

    final raw = _storage.getString(_legacyAllFilesKey);
    if (raw != null && raw.isNotEmpty && raw != '[]') {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final models = decoded
              .whereType<Map>()
              .map(
                (item) =>
                    SavedFileModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((m) => m.id.isNotEmpty)
              .toList();

          if (models.isNotEmpty) {
            await _db.writeAsync((isar) {
              final entities = <SavedFileEntity>[];
              for (final file in models) {
                entities.add(
                  SavedFileEntity()
                    ..id = isar.savedFiles.autoIncrement()
                    ..fileId = file.id
                    ..name = file.name
                    ..dateTime = file.dateTime
                    ..path = file.path
                    ..pathImage = file.pathImage
                    ..fileType = file.fileType
                    ..folderId = file.folderId
                    ..isTextFile = file.isTextFile,
                );
              }
              isar.savedFiles.putAll(entities);
            });
          }
        }
      } catch (_) {
        // Keep going — mark migrated so we do not loop on corrupt JSON.
      }
    }

    await _storage.setBool(_migratedKey, true);
    await _storage.remove(_legacyAllFilesKey);
  }

  SavedFileEntity _toEntity(SavedFileModel model, {int? existingId}) {
    return SavedFileEntity()
      ..id = existingId ?? _db.savedFiles.autoIncrement()
      ..fileId = model.id
      ..name = model.name
      ..dateTime = model.dateTime
      ..path = model.path
      ..pathImage = model.pathImage
      ..fileType = model.fileType
      ..folderId = model.folderId
      ..isTextFile = model.isTextFile;
  }

  SavedFileModel _toModel(SavedFileEntity entity) {
    return SavedFileModel(
      id: entity.fileId,
      name: entity.name,
      dateTime: entity.dateTime,
      path: entity.path,
      pathImage: entity.pathImage,
      fileType: entity.fileType,
      folderId: entity.folderId,
      isTextFile: entity.isTextFile,
    );
  }
}
