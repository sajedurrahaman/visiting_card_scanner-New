import 'package:flutter/material.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';

class HomeViewModel extends ChangeNotifier {
  List<RecentCardItem> _recentCards = const [];

  List<RecentCardItem> get recentCards => _recentCards;

  bool get hasRecentCards => _recentCards.isNotEmpty;

  void setRecentCards(List<RecentCardItem> cards) {
    _recentCards = cards;
    notifyListeners();
  }

  void renameRecentCard(String id, String newName) {
    _recentCards = _recentCards
        .map(
          (card) => card.id == id ? card.copyWith(name: newName) : card,
        )
        .toList();
    notifyListeners();
  }

  void deleteRecentCard(String id) {
    _recentCards = _recentCards.where((card) => card.id != id).toList();
    notifyListeners();
  }

  /// Demo data for the Recent list UI (Figma with-data state).
  void loadDemoRecentCards() {
    _recentCards = const [
      RecentCardItem(
        id: '1',
        name: 'Devid jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '2',
        name: 'Miraj Ahmed',
        dateTime: '01-Jan-2025 09:15',
        isTextFile: true,
      ),
      RecentCardItem(
        id: '3',
        name: 'Mark jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '4',
        name: 'Devid jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '5',
        name: 'Miraj Ahmed',
        dateTime: '01-Jan-2025 09:15',
        isTextFile: true,
      ),
      RecentCardItem(
        id: '6',
        name: 'Mark jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '7',
        name: 'Devid jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '8',
        name: 'Miraj Ahmed',
        dateTime: '01-Jan-2025 09:15',
        isTextFile: true,
      ),
      RecentCardItem(
        id: '9',
        name: 'Mark jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '10',
        name: 'Devid jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
      RecentCardItem(
        id: '11',
        name: 'Miraj Ahmed',
        dateTime: '01-Jan-2025 09:15',
        isTextFile: true,
      ),
      RecentCardItem(
        id: '12',
        name: 'Mark jhon',
        dateTime: '01-Jan-2025 09:15',
      ),
    ];
    notifyListeners();
  }

  void onVisitingCardTap() {}

  void onQrCodeTap() {}

  void onBarcodeTap() {}
}
