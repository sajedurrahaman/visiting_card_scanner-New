import 'package:flutter/material.dart';
import 'package:visiting_card/features/folder/domain/model/sub_folder_item.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_item_data.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';

class FolderViewModel extends ChangeNotifier {
  FolderViewModel() {
    _initDemoData();
  }

  static const visitingCardFolderId = 'visiting_card';
  static const qrCodeFolderId = 'qr_code';
  static const barcodeFolderId = 'barcode';

  final List<FolderItemData> folders = const [
    FolderItemData(id: visitingCardFolderId, label: 'Visiting Card'),
    FolderItemData(id: qrCodeFolderId, label: 'QR Code'),
    FolderItemData(id: barcodeFolderId, label: 'Barcode'),
  ];

  final Map<String, List<SubFolderItem>> _subFolders = {};
  final Map<String, List<RecentCardItem>> _cards = {};
  final Map<String, bool> _selectionModes = {};
  final Map<String, Set<String>> _selectedItemIds = {};

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;

  List<SubFolderItem> subFoldersFor(String folderId) =>
      List.unmodifiable(_subFolders[folderId] ?? const []);

  List<RecentCardItem> cardsFor(String folderId) =>
      List.unmodifiable(_cards[folderId] ?? const []);

  bool isSelectionMode(String folderId) => _selectionModes[folderId] ?? false;

  bool isItemSelected(String folderId, String itemId) =>
      _selectedItemIds[folderId]?.contains(itemId) ?? false;

  void onFolderTap(int index) {
    if (_selectedIndex == index) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedIndex == null) {
      return;
    }
    _selectedIndex = null;
    notifyListeners();
  }

  void toggleSelectionMode(String folderId) {
    final isActive = isSelectionMode(folderId);
    _selectionModes[folderId] = !isActive;
    if (isActive) {
      _selectedItemIds[folderId]?.clear();
    }
    notifyListeners();
  }

  void toggleItemSelection(String folderId, String itemId) {
    if (!isSelectionMode(folderId)) {
      return;
    }
    final selected = _selectedItemIds.putIfAbsent(folderId, () => {});
    if (selected.contains(itemId)) {
      selected.remove(itemId);
    } else {
      selected.add(itemId);
    }
    notifyListeners();
  }

  void createSubFolder(String folderId, String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final subFolderId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    final subFolders = _subFolders.putIfAbsent(folderId, () => []);
    subFolders.insert(
      0,
      SubFolderItem(
        id: subFolderId,
        name: trimmedName,
        dateTime: _formatDate(DateTime.now()),
      ),
    );
    _subFolders[subFolderId] = [];
    _cards[subFolderId] = [];
    notifyListeners();
  }

  void _initDemoData() {
    _cards[visitingCardFolderId] = _demoVisitingCards;
    _cards[qrCodeFolderId] = _demoQrCodeCards;
    _cards[barcodeFolderId] = _demoBarcodeCards;

    _subFolders[visitingCardFolderId] = [
      const SubFolderItem(
        id: 'sub_demo_1',
        name: 'New Folder',
        dateTime: '08-18-2025',
      ),
    ];
    _subFolders['sub_demo_1'] = [];
    _cards['sub_demo_1'] = _demoSubFolderCards;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month-$day-${date.year}';
  }

  static const _demoSubFolderCards = [
    RecentCardItem(
      id: 'sub_vc_1',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
    ),
    RecentCardItem(
      id: 'sub_vc_2',
      name: 'Miraj Ahmed',
      dateTime: '01-Jan-2025 09:15',
    ),
  ];

  static const _demoVisitingCards = [
    RecentCardItem(
      id: 'vc_1',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
    ),
    RecentCardItem(
      id: 'vc_2',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
    ),
    RecentCardItem(
      id: 'vc_3',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
    ),
    RecentCardItem(
      id: 'vc_4',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
    ),
  ];

  static const _demoQrCodeCards = [
    RecentCardItem(
      id: 'qr_1',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
      isTextFile: true,
    ),
    RecentCardItem(
      id: 'qr_2',
      name: 'Miraj Ahmed',
      dateTime: '01-Jan-2025 09:15',
      isTextFile: true,
    ),
    RecentCardItem(
      id: 'qr_3',
      name: 'Mark jhon',
      dateTime: '01-Jan-2025 09:15',
      isTextFile: true,
    ),
  ];

  static const _demoBarcodeCards = [
    RecentCardItem(
      id: 'bc_1',
      name: 'Devid jhon',
      dateTime: '01-Jan-2025 09:15',
      isTextFile: true,
    ),
    RecentCardItem(
      id: 'bc_2',
      name: 'Miraj Ahmed',
      dateTime: '01-Jan-2025 09:15',
      isTextFile: true,
    ),
  ];
}
