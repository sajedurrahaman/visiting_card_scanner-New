import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/app/storage/folder_record.dart';
import 'package:visiting_card/features/folder/domain/model/sub_folder_item.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_item_data.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';

class FolderViewModel extends ChangeNotifier {
  FolderViewModel() {
    loadFromStorage();
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

  Future<void> loadFromStorage() async {
    _restoreFoldersFromStorage();

    final files = AppStorageService().getAllFiles();
    final folderIds = <String>{
      visitingCardFolderId,
      qrCodeFolderId,
      barcodeFolderId,
      ..._parentIds.keys,
      ..._subFolders.keys,
    };

    for (final id in folderIds) {
      _cards[id] = _cardsForFolder(files, id);
    }
    notifyListeners();
  }

  void _restoreFoldersFromStorage() {
    _subFolders.clear();
    _parentIds.clear();

    final records = AppStorageService().getAllFolders();
    for (final record in records) {
      if (record.id.isEmpty || record.parentFolderId.isEmpty) continue;
      _parentIds[record.id] = record.parentFolderId;
      final list = _subFolders.putIfAbsent(record.parentFolderId, () => []);
      list.add(
        SubFolderItem(
          id: record.id,
          name: record.name,
          dateTime: record.dateTime,
        ),
      );
      _subFolders.putIfAbsent(record.id, () => []);
    }

    for (final entry in _subFolders.entries) {
      entry.value.sort((a, b) => b.id.compareTo(a.id));
    }
  }

  Future<void> _persistFolders() async {
    final records = <FolderRecord>[];
    for (final entry in _subFolders.entries) {
      for (final sub in entry.value) {
        final parentId = _parentIds[sub.id];
        if (parentId == null) continue;
        records.add(
          FolderRecord(
            id: sub.id,
            name: sub.name,
            dateTime: sub.dateTime,
            parentFolderId: parentId,
          ),
        );
      }
    }
    await AppStorageService().replaceAllFolders(records);
  }

  List<RecentCardItem> _cardsForFolder(
    List<SavedFileModel> files,
    String folderId,
  ) {
    final cards = files
        .where((file) => file.folderId == folderId)
        .map(
          (file) => RecentCardItem(
            id: file.id,
            name: file.name,
            dateTime: file.dateTime,
            thumbnailPath: file.pathImage.isNotEmpty ? file.pathImage : null,
            path: file.path.isNotEmpty ? file.path : null,
            fileType: file.fileType,
            folderId: file.folderId,
            isTextFile: file.isTextFile,
          ),
        )
        .toList();
    cards.sort((a, b) => _recencyKey(b).compareTo(_recencyKey(a)));
    return cards;
  }

  static int _recencyKey(RecentCardItem item) {
    final fromId = RegExp(r'^(\d+)').firstMatch(item.id)?.group(1);
    final parsedId = fromId == null ? null : int.tryParse(fromId);
    if (parsedId != null && parsedId > 0) return parsedId;
    return 0;
  }

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

  Future<void> deleteSelectedItems(String folderId) async {
    final selectedIds = _selectedItemIds[folderId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return;
    }

    final allFiles = AppStorageService().getAllFiles();
    for (final file in allFiles.where((f) => selectedIds.contains(f.id))) {
      for (final path in {file.path, file.pathImage}) {
        if (path.isEmpty) continue;
        final disk = File(path);
        if (await disk.exists()) {
          try {
            await disk.delete();
          } catch (_) {}
        }
      }
    }

    final deletedFolderIds = <String>{};
    for (final id in List<String>.from(selectedIds)) {
      if (subFoldersFor(folderId).any((s) => s.id == id) ||
          _parentIds.containsKey(id)) {
        _collectFolderTreeIds(id, deletedFolderIds);
      }
    }

    _subFolders[folderId]?.removeWhere(
      (item) => selectedIds.contains(item.id),
    );
    _cards[folderId]?.removeWhere(
      (item) => selectedIds.contains(item.id),
    );

    for (final id in {...selectedIds, ...deletedFolderIds}) {
      _subFolders.remove(id);
      _cards.remove(id);
      _parentIds.remove(id);
      _selectionModes.remove(id);
      _selectedItemIds.remove(id);
    }

    final remaining =
        allFiles.where((file) => !selectedIds.contains(file.id)).toList();
    await AppStorageService().replaceAllFiles(remaining);
    await _persistFolders();

    selectedIds.clear();
    notifyListeners();
  }

  void _collectFolderTreeIds(String folderId, Set<String> out) {
    out.add(folderId);
    final nested = List<SubFolderItem>.from(_subFolders[folderId] ?? const []);
    for (final child in nested) {
      _collectFolderTreeIds(child.id, out);
    }
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

  Future<bool> moveSelectedItemsTo({
    required String sourceFolderId,
    required String destinationFolderId,
  }) async {
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

    final files = AppStorageService().getAllFiles();
    final updated = files
        .map(
          (file) => movingIds.contains(file.id)
              ? file.copyWith(folderId: destinationFolderId)
              : file,
        )
        .toList();
    await AppStorageService().replaceAllFiles(updated);
    await loadFromStorage();

    selectedIds.removeAll(movingIds);
    exitSelectionMode(sourceFolderId);
    return true;
  }

  Future<void> shareSelectedItems(String folderId) async {
    final selectedIds = _selectedItemIds[folderId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return;
    }

    final files = cardsFor(folderId)
        .where((card) => selectedIds.contains(card.id))
        .map((card) => card.path ?? card.thumbnailPath)
        .whereType<String>()
        .where((path) => path.isNotEmpty && File(path).existsSync())
        .map(XFile.new)
        .toList();

    if (files.isEmpty) {
      return;
    }

    await Share.shareXFiles(files);
    exitSelectionMode(folderId);
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

  Future<void> renameSubFolder({
    required String parentFolderId,
    required String subFolderId,
    required String newName,
  }) async {
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
    await _persistFolders();
    notifyListeners();
  }

  Future<void> deleteSubFolder({
    required String parentFolderId,
    required String subFolderId,
  }) async {
    _subFolders[parentFolderId]?.removeWhere(
      (item) => item.id == subFolderId,
    );
    _removeSubFolderTree(subFolderId);
    await _persistFolders();
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

  Future<void> createSubFolder(String folderId, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final subFolderId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    final dateTime = _formatDate(DateTime.now());
    final subFolders = _subFolders.putIfAbsent(folderId, () => []);
    subFolders.insert(
      0,
      SubFolderItem(
        id: subFolderId,
        name: trimmedName,
        dateTime: dateTime,
      ),
    );
    _subFolders[subFolderId] = [];
    _cards[subFolderId] = [];
    _parentIds[subFolderId] = folderId;
    await AppStorageService().saveFolder(
      FolderRecord(
        id: subFolderId,
        name: trimmedName,
        dateTime: dateTime,
        parentFolderId: folderId,
      ),
    );
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month-$day-${date.year}';
  }
}
