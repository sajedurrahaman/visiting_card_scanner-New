import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/scan/domain/visiting_card_folder_paths.dart';

class HomeViewModel extends ChangeNotifier {
  List<RecentCardItem> _recentCards = const [];

  List<RecentCardItem> get recentCards => _recentCards;

  bool get hasRecentCards => _recentCards.isNotEmpty;

  void setRecentCards(List<RecentCardItem> cards) {
    _recentCards = cards;
    notifyListeners();
  }

  Future<void> loadRecentFromStorage() async {
    final files = AppStorageService().getAllFiles();
    // Keep Recent newest-first (independent of folder list).
    final sorted = List.of(files)..sort((a, b) => b.id.compareTo(a.id));
    final cards = <RecentCardItem>[];
    for (final file in sorted) {
      var path = file.path.isNotEmpty ? file.path : null;
      var thumb = file.pathImage.isNotEmpty ? file.pathImage : null;

      if (file.fileType == 'visiting_card') {
        final resolvedFolder =
            await VisitingCardFolderPaths.resolveContactFolder(path);
        if (resolvedFolder != null && resolvedFolder.isNotEmpty) {
          if (path != resolvedFolder) {
            path = resolvedFolder;
            // Persist healed Documents path so later opens keep working.
            try {
              await AppStorageService().updateFile(
                file.copyWith(path: resolvedFolder),
              );
            } catch (_) {}
          }
        }
        final resolved = VisitingCardFolderPaths.resolveThumbnail(
          thumbnailPath: thumb,
          folderOrFilePath: path,
        );
        if (resolved != null) {
          thumb = resolved.path;
        }
      }

      cards.add(
        RecentCardItem(
          id: file.id,
          name: file.name,
          dateTime: file.dateTime,
          thumbnailPath: thumb,
          path: path,
          fileType: file.fileType,
          folderId: file.folderId,
          isTextFile: file.isTextFile,
        ),
      );
    }
    _recentCards = cards;
    notifyListeners();
  }

  Future<void> renameRecentCard(String id, String newName) async {
    _recentCards = _recentCards
        .map(
          (card) => card.id == id ? card.copyWith(name: newName) : card,
        )
        .toList();
    final files = AppStorageService().getAllFiles();
    final updated = files
        .map((file) => file.id == id ? file.copyWith(name: newName) : file)
        .toList();
    await AppStorageService().replaceAllFiles(updated);
    notifyListeners();
  }

  Future<void> deleteRecentCard(String id) async {
    final files = AppStorageService().getAllFiles();
    SavedFileModel? target;
    for (final file in files) {
      if (file.id == id) {
        target = file;
        break;
      }
    }
    if (target != null) {
      for (final path in {target.path, target.pathImage}) {
        if (path.isEmpty) continue;
        final dir = Directory(path);
        if (await dir.exists()) {
          try {
            await dir.delete(recursive: true);
          } catch (_) {}
          continue;
        }
        final file = File(path);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }
    }

    _recentCards = _recentCards.where((card) => card.id != id).toList();
    final remaining = files.where((file) => file.id != id).toList();
    await AppStorageService().replaceAllFiles(remaining);
    notifyListeners();
  }

  void onVisitingCardTap() {}

  void onQrCodeTap() {}

  void onBarcodeTap() {}
}
