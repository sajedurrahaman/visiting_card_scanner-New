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
  static const moveRootsBrowseId = '__move_roots__';

  bool isRootFolder(String folderId) =>
      folderId == visitingCardFolderId ||
      folderId == qrCodeFolderId ||
      folderId == barcodeFolderId;

  final List<FolderItemData> folders = const [
    FolderItemData(id: visitingCardFolderId, label: 'Visiting Card'),
    FolderItemData(id: qrCodeFolderId, label: 'QR Code'),
    FolderItemData(id: barcodeFolderId, label: 'Barcode'),
  ];

  final Map<String, List<SubFolderItem>> _subFolders = {};
  final Map<String, List<RecentCardItem>> _cards = {};
  final Map<String, String> _parentIds = {};
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

  int selectedCount(String folderId) =>
      _selectedItemIds[folderId]?.length ?? 0;

  bool hasSelectedFolders(String folderId) {
    final folderIds = subFoldersFor(folderId).map((item) => item.id).toSet();
    return _selectedItemIds[folderId]?.any(folderIds.contains) ?? false;
  }

  bool hasSelectedFiles(String folderId) {
    final fileIds = cardsFor(folderId).map((item) => item.id).toSet();
    return _selectedItemIds[folderId]?.any(fileIds.contains) ?? false;
  }

  bool isAllSelected(String folderId) {
    final totalItems =
        subFoldersFor(folderId).length + cardsFor(folderId).length;
    if (totalItems == 0) {
      return false;
    }
    return selectedCount(folderId) == totalItems;
  }

  bool canMoveSelection(String folderId) {
    return hasSelectedFiles(folderId) && !hasSelectedFolders(folderId);
  }

  bool canShareSelection(String folderId) => canMoveSelection(folderId);

  bool canDeleteSelection(String folderId) => selectedCount(folderId) > 0;

  void exitSelectionMode(String folderId) {
    _selectionModes[folderId] = false;
    _selectedItemIds[folderId]?.clear();
    notifyListeners();
  }

  void selectAll(String folderId) {
    if (!isSelectionMode(folderId)) {
      return;
    }
    final allIds = {
      ...subFoldersFor(folderId).map((item) => item.id),
      ...cardsFor(folderId).map((item) => item.id),
    };
    _selectedItemIds[folderId] = allIds;
    notifyListeners();
  }

  void deselectAll(String folderId) {
    _selectedItemIds[folderId]?.clear();
    notifyListeners();
  }

  void toggleSelectAll(String folderId) {
    if (isAllSelected(folderId)) {
      deselectAll(folderId);
    } else {
      selectAll(folderId);
    }
  }

  void deleteSelectedItems(String folderId) {
    final selectedIds = _selectedItemIds[folderId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return;
    }

    _subFolders[folderId]?.removeWhere(
      (item) => selectedIds.contains(item.id),
    );
    _cards[folderId]?.removeWhere(
      (item) => selectedIds.contains(item.id),
    );

    for (final id in List<String>.from(selectedIds)) {
      _subFolders.remove(id);
      _cards.remove(id);
      _parentIds.remove(id);
      _selectionModes.remove(id);
      _selectedItemIds.remove(id);
    }

    selectedIds.clear();
    notifyListeners();
  }

  String? parentIdFor(String folderId) => _parentIds[folderId];

  String rootFolderIdFor(String folderId) {
    var current = folderId;
    while (_parentIds.containsKey(current)) {
      current = _parentIds[current]!;
    }
    return current;
  }

  String folderNameFor(String folderId) {
    for (final folder in folders) {
      if (folder.id == folderId) {
        return folder.label;
      }
    }

    for (final entry in _subFolders.entries) {
      for (final subFolder in entry.value) {
        if (subFolder.id == folderId) {
          return subFolder.name;
        }
      }
    }

    return 'Folder';
  }

  bool moveSelectedItemsTo({
    required String sourceFolderId,
    required String destinationFolderId,
  }) {
    if (sourceFolderId == destinationFolderId) {
      return false;
    }

    final selectedIds = _selectedItemIds[sourceFolderId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return false;
    }

    final fileIds = cardsFor(sourceFolderId).map((item) => item.id).toSet();
    final movingIds = selectedIds.where(fileIds.contains).toSet();
    if (movingIds.isEmpty) {
      return false;
    }

    final sourceCards =
        List<RecentCardItem>.from(_cards[sourceFolderId] ?? const []);
    final movingCards = sourceCards
        .where((card) => movingIds.contains(card.id))
        .toList(growable: false);
    sourceCards.removeWhere((card) => movingIds.contains(card.id));
    _cards[sourceFolderId] = sourceCards;

    final destinationCards =
        List<RecentCardItem>.from(_cards[destinationFolderId] ?? const []);
    destinationCards.insertAll(0, movingCards);
    _cards[destinationFolderId] = destinationCards;

    selectedIds.removeAll(movingIds);
    exitSelectionMode(sourceFolderId);
    return true;
  }

  void shareSelectedItems(String folderId) {
    // TODO: Integrate share sheet when file paths are available.
  }

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

  void renameSubFolder({
    required String parentFolderId,
    required String subFolderId,
    required String newName,
  }) {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final subFolders = _subFolders[parentFolderId];
    if (subFolders == null) {
      return;
    }

    final index = subFolders.indexWhere((item) => item.id == subFolderId);
    if (index == -1) {
      return;
    }

    subFolders[index] = subFolders[index].copyWith(name: trimmedName);
    notifyListeners();
  }

  void deleteSubFolder({
    required String parentFolderId,
    required String subFolderId,
  }) {
    _subFolders[parentFolderId]?.removeWhere(
      (item) => item.id == subFolderId,
    );
    _removeSubFolderTree(subFolderId);
    notifyListeners();
  }

  void _removeSubFolderTree(String folderId) {
    final nestedSubFolders = List<SubFolderItem>.from(
      _subFolders[folderId] ?? const [],
    );
    for (final nested in nestedSubFolders) {
      _removeSubFolderTree(nested.id);
    }

    _subFolders.remove(folderId);
    _cards.remove(folderId);
    _parentIds.remove(folderId);
    _selectionModes.remove(folderId);
    _selectedItemIds.remove(folderId);
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
    _parentIds[subFolderId] = folderId;
    notifyListeners();
  }

  void _registerSubFolder({
    required String parentId,
    required SubFolderItem item,
  }) {
    final subFolders = _subFolders.putIfAbsent(parentId, () => []);
    if (subFolders.any((folder) => folder.id == item.id)) {
      return;
    }
    subFolders.add(item);
    _subFolders[item.id] = _subFolders[item.id] ?? [];
    _cards[item.id] = _cards[item.id] ?? [];
    _parentIds[item.id] = parentId;
  }

  void _initDemoData() {
    _cards[visitingCardFolderId] = List.of(_demoVisitingCards);
    _cards[qrCodeFolderId] = List.of(_demoQrCodeCards);
    _cards[barcodeFolderId] = List.of(_demoBarcodeCards);

    _registerSubFolder(
      parentId: visitingCardFolderId,
      item: const SubFolderItem(
        id: 'sub_demo_1',
        name: 'New Folder',
        dateTime: '08-18-2025',
      ),
    );
    _registerSubFolder(
      parentId: visitingCardFolderId,
      item: const SubFolderItem(
        id: 'sub_demo_2',
        name: 'Nahid',
        dateTime: '08-18-2025',
      ),
    );
    _registerSubFolder(
      parentId: visitingCardFolderId,
      item: const SubFolderItem(
        id: 'sub_demo_3',
        name: 'Hasib',
        dateTime: '08-18-2025',
      ),
    );
    _cards['sub_demo_1'] = List.of(_demoSubFolderCards);
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
