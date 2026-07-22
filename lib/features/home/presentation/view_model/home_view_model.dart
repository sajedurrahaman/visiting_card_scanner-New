import 'package:flutter/material.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';

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
    final sorted = List.of(files)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _recentCards = sorted
        .map(
          (file) => RecentCardItem(
            id: file.id,
            name: file.name,
            dateTime: file.dateTime,
            thumbnailPath: file.pathImage.isNotEmpty ? file.pathImage : null,
            isTextFile: file.isTextFile,
          ),
        )
        .toList();
    notifyListeners();
  }

  void renameRecentCard(String id, String newName) {
    _recentCards = _recentCards
        .map(
          (card) => card.id == id ? card.copyWith(name: newName) : card,
        )
        .toList();
    final files = AppStorageService().getAllFiles();
    final updated = files
        .map((file) => file.id == id ? file.copyWith(name: newName) : file)
        .toList();
    AppStorageService().replaceAllFiles(updated);
    notifyListeners();
  }

  void deleteRecentCard(String id) {
    _recentCards = _recentCards.where((card) => card.id != id).toList();
    final files =
        AppStorageService().getAllFiles().where((file) => file.id != id).toList();
    AppStorageService().replaceAllFiles(files);
    notifyListeners();
  }

  void onVisitingCardTap() {}

  void onQrCodeTap() {}

  void onBarcodeTap() {}
}
