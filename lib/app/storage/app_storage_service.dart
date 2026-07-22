import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';

class AppStorageService {
  AppStorageService._();

  static final AppStorageService instance = AppStorageService._();

  factory AppStorageService() => instance;

  static SharedPreferences? _prefs;

  static const String allFilesKey = 'allFiles';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
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

  String get getAllFilesRaw => _storage.getString(allFilesKey) ?? '[]';

  List<SavedFileModel> getAllFiles() {
    final decoded = jsonDecode(getAllFilesRaw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((item) => SavedFileModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> storeAllFiles(SavedFileModel model) async {
    final files = getAllFiles()..add(model);
    await _storage.setString(
      allFilesKey,
      jsonEncode(files.map((file) => file.toJson()).toList()),
    );
  }

  Future<void> replaceAllFiles(List<SavedFileModel> files) async {
    await _storage.setString(
      allFilesKey,
      jsonEncode(files.map((file) => file.toJson()).toList()),
    );
  }
}
