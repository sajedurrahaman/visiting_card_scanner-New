import 'dart:convert';

import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';

/// Isar-backed contact payload keyed by Recent/Isar [fileId].
///
/// Visiting-card fields also live in `contact.json` on disk; this keeps a
/// copy in Isar so iOS Documents path churn does not wipe Contact Details.
class SavedContactInfoBackup {
  SavedContactInfoBackup._();

  static Future<void> save(String fileId, SavedContactInfo contact) async {
    if (fileId.trim().isEmpty) return;
    final existing = AppStorageService().getFileById(fileId);
    if (existing == null) return;
    final encoded = jsonEncode(contact.toJson());
    if (existing.contactJson == encoded) return;
    await AppStorageService().updateFile(
      existing.copyWith(contactJson: encoded),
    );
  }

  static Future<SavedContactInfo?> load(String fileId) async {
    if (fileId.trim().isEmpty) return null;
    final existing = AppStorageService().getFileById(fileId);
    final raw = existing?.contactJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return SavedContactInfo.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}
