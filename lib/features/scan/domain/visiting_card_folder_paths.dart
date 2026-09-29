import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';

/// Resolves on-disk visiting-card files the same way PDF Scanner does when
/// stored [pathImage] / image paths go stale after restart.
class VisitingCardFolderPaths {
  VisitingCardFolderPaths._();

  static const visitingCardRelativeRoot = 'Convert Document/Visiting Card';

  static const _frontCandidates = [
    'card_front.jpg',
    'card_front.jpeg',
    'card_front.png',
    'card_0.jpg',
    '0.jpg',
  ];

  static const _sideCandidates = [
    'card_front.jpg',
    'card_back.jpg',
    'card_2.jpg',
    'card_3.jpg',
    'card_4.jpg',
    'card_5.jpg',
  ];

  /// Remaps a stored contact-folder absolute path onto the current Documents
  /// root. iOS container UUID can change after reinstall / some rebuilds while
  /// Isar still holds the old absolute path.
  static Future<String?> resolveContactFolder(String? storedPath) async {
    if (storedPath == null || storedPath.trim().isEmpty) return null;
    final trimmed = storedPath.trim();
    if (Directory(trimmed).existsSync()) return trimmed;

    final remapped = await resolveStoredAbsolutePath(trimmed);
    if (remapped != null && Directory(remapped).existsSync()) return remapped;

    final docs = await getApplicationDocumentsDirectory();
    final byName = Directory(
      p.join(docs.path, visitingCardRelativeRoot, p.basename(trimmed)),
    );
    if (byName.existsSync()) return byName.path;

    return trimmed;
  }

  /// Heals QR / barcode / visiting-card absolute paths after iOS Documents
  /// container UUID changes (`flutter clean` + reinstall keeps Isar rows).
  ///
  /// Example stored:
  /// `.../Application/<old-uuid>/Documents/qr_code/qr_123.png`
  /// → current `Documents/qr_code/qr_123.png`
  static Future<String?> resolveStoredAbsolutePath(String? storedPath) async {
    if (storedPath == null || storedPath.trim().isEmpty) return null;
    final trimmed = storedPath.trim();
    if (File(trimmed).existsSync() || Directory(trimmed).existsSync()) {
      return trimmed;
    }

    final docs = await getApplicationDocumentsDirectory();
    final match = RegExp(r'[/\\]Documents[/\\](.*)').firstMatch(trimmed);
    if (match != null) {
      final relative = match.group(1);
      if (relative != null && relative.isNotEmpty) {
        final remapped = p.join(docs.path, relative);
        if (File(remapped).existsSync() || Directory(remapped).existsSync()) {
          return remapped;
        }
      }
    }

    for (final marker in [
      visitingCardRelativeRoot,
      'Convert Document',
      'qr_code',
      'barcode',
      'visiting_card',
    ]) {
      final markerIndex = trimmed.indexOf(marker);
      if (markerIndex < 0) continue;
      final remapped = p.join(docs.path, trimmed.substring(markerIndex));
      if (File(remapped).existsSync() || Directory(remapped).existsSync()) {
        return remapped;
      }
    }

    return trimmed;
  }

  /// Prefer an existing image file; if [path] is a contact folder, look inside.
  static File? resolveThumbnail({
    String? thumbnailPath,
    String? folderOrFilePath,
  }) {
    for (final path in [thumbnailPath, folderOrFilePath]) {
      if (path == null || path.trim().isEmpty) continue;
      final lower = path.toLowerCase();
      if (lower.endsWith('.txt') || lower.endsWith('.json')) continue;

      final asFile = File(path);
      final asDir = Directory(path);

      if (asDir.existsSync()) {
        final fromFolder = _frontImageInFolder(asDir);
        if (fromFolder != null) return fromFolder;
        continue;
      }

      if (asFile.existsSync()) return asFile;
    }

    if (folderOrFilePath != null && folderOrFilePath.trim().isNotEmpty) {
      final parent = Directory(p.dirname(folderOrFilePath));
      if (parent.existsSync()) {
        return _frontImageInFolder(parent);
      }
    }
    return null;
  }

  /// Front/back scanned photos for a saved visiting-card contact.
  ///
  /// Does **not** include template captures (`template_front_*.png`) — those
  /// belong to LivePreview download/share, not the old-scan image strip.
  static List<File> resolveSideImages({
    String? folderPath,
    SavedContactInfo? contact,
    String? thumbnailPath,
  }) {
    final resolved = <File>[];
    final seen = <String>{};
    final folder = folderPath?.trim();

    void addIfExists(String? path) {
      if (path == null || path.trim().isEmpty) return;
      File? file = File(path);
      if (!file.existsSync() && folder != null && folder.isNotEmpty) {
        // iOS Documents UUID churn: absolute path stale, basename still in folder.
        final remapped = File(p.join(folder, p.basename(path)));
        if (remapped.existsSync()) file = remapped;
      }
      if (!file.existsSync()) return;
      if (_isTemplateCaptureName(p.basename(file.path))) return;
      final key = p.normalize(file.path);
      if (seen.add(key)) resolved.add(file);
    }

    if (contact != null) {
      for (final path in contact.imagePaths) {
        addIfExists(path);
      }
    }

    if (resolved.isNotEmpty) return resolved;

    if (folder != null && folder.isNotEmpty) {
      final dir = Directory(folder);
      if (dir.existsSync()) {
        for (final name in _sideCandidates) {
          addIfExists(p.join(folder, name));
        }
        if (resolved.isEmpty) {
          for (final name in _frontCandidates) {
            addIfExists(p.join(folder, name));
          }
        }
        if (resolved.isEmpty) {
          final files = dir
              .listSync(followLinks: false)
              .whereType<File>()
              .where((f) {
                final name = p.basename(f.path);
                if (_isTemplateCaptureName(name)) return false;
                final ext = p.extension(f.path).toLowerCase();
                return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
              })
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
          for (final f in files) {
            addIfExists(f.path);
          }
        }
      }
    }

    if (resolved.isEmpty) {
      addIfExists(thumbnailPath);
    }
    return resolved;
  }

  static bool _isTemplateCaptureName(String name) {
    final lower = name.toLowerCase();
    return lower.startsWith('template_front_') ||
        lower.startsWith('template_back_');
  }

  static File? _frontImageInFolder(Directory folder) {
    for (final name in _frontCandidates) {
      final f = File(p.join(folder.path, name));
      if (f.existsSync()) return f;
    }

    // Newest template capture from scan→template save.
    File? newestTemplateFront;
    var newestStamp = -1;
    for (final entity in folder.listSync(followLinks: false)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      final match = RegExp(r'^template_front_(\d+)\.png$').firstMatch(name);
      if (match != null) {
        final stamp = int.tryParse(match.group(1) ?? '') ?? 0;
        if (stamp >= newestStamp) {
          newestStamp = stamp;
          newestTemplateFront = entity;
        }
      }
    }
    if (newestTemplateFront != null) return newestTemplateFront;

    for (final entity in folder.listSync(followLinks: false)) {
      if (entity is! File) continue;
      final ext = p.extension(entity.path).toLowerCase();
      if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') {
        return entity;
      }
    }
    return null;
  }
}
