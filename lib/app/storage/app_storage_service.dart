import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visiting_card/app/storage/saved_file_entity.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';

/// Local persistence for saved files — PDF Scanner Isar Plus pattern.
///
/// Public API stays the same as the old SharedPreferences layer so call sites
/// do not need to change. [getAllFiles] is served from an in-memory cache that
/// is refreshed after every write.
class AppStorageService {
  AppStorageService._();

  static final AppStorageService instance = AppStorageService._();

  factory AppStorageService() => instance;

  static Isar? _isar;
  static SharedPreferences? _prefs;

  static const String _legacyAllFilesKey = 'allFiles';
  static const String _migratedKey = 'isar_saved_files_migrated_v1';

  List<SavedFileModel> _cache = const [];

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.openAsync(
      schemas: [SavedFileEntitySchema],
      directory: directory.path,
      name: 'visiting_card',
    );

    await instance._migrateFromSharedPreferencesIfNeeded();
    instance._reloadCache();
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
