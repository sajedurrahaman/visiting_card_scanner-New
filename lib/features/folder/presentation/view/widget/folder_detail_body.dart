import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/domain/model/sub_folder_item.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/move_folder_bottom_sheet.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_selection_checkbox.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/create_folder_dialog.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_detail_app_bar.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_selection_app_bar.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_selection_bottom_bar.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/sub_folder_tile.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view/widgets/recent_card_tile.dart';

class FolderDetailBody extends StatelessWidget {
  const FolderDetailBody({
    super.key,
    required this.folderId,
    required this.title,
  });

  final String folderId;
  final String title;

  Future<void> _onCreateFolder(BuildContext context) async {
    final name = await CreateFolderDialog.show(context);
    if (!context.mounted || name == null) {
      return;
    }
    context.read<FolderViewModel>().createSubFolder(folderId, name);
    ui.AppToast.success(context, 'Folder created');
  }

  void _enterSelectionMode(
    FolderViewModel viewModel, {
    required String itemId,
  }) {
    if (!viewModel.isSelectionMode(folderId)) {
      viewModel.toggleSelectionMode(folderId);
    }
    if (!viewModel.isItemSelected(folderId, itemId)) {
      viewModel.toggleItemSelection(folderId, itemId);
    }
  }

  Future<void> _handleSubFolderMenuAction(
    BuildContext context,
    FolderViewModel viewModel,
    SubFolderItem item,
    SubFolderMenuAction action,
  ) async {
    switch (action) {
      case SubFolderMenuAction.rename:
        final newName = await ui.AppDialogs.showRenameDialog(
          context,
          title: 'Rename Folder',
          initialValue: item.name,
          hintText: 'Folder Name',
        );
        if (!context.mounted || newName == null || newName == item.name) {
          return;
        }
        viewModel.renameSubFolder(
          parentFolderId: folderId,
          subFolderId: item.id,
          newName: newName,
        );
        ui.AppToast.success(context, 'Renamed to $newName');
      case SubFolderMenuAction.delete:
        final shouldDelete = await ui.AppDialogs.showDeleteDialog(
          context,
          message: 'Are you sure you want to delete "${item.name}"?',
        );
        if (!context.mounted || !shouldDelete) {
          return;
        }
        viewModel.deleteSubFolder(
          parentFolderId: folderId,
          subFolderId: item.id,
        );
        ui.AppToast.success(context, '${item.name} deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FolderViewModel>();
    final subFolders = viewModel.subFoldersFor(folderId);
    final cards = viewModel.cardsFor(folderId);
    final isSelectionMode = viewModel.isSelectionMode(folderId);
    final itemCount = subFolders.length + cards.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBFEF5),
              Colors.white,
            ],
            stops: [0.0, 0.20],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (isSelectionMode)
                FolderSelectionAppBar(
                  selectedCount: viewModel.selectedCount(folderId),
                  isAllSelected: viewModel.isAllSelected(folderId),
                  onCancel: () => viewModel.exitSelectionMode(folderId),
                  onToggleSelectAll: () =>
                      viewModel.toggleSelectAll(folderId),
                )
              else
                FolderDetailAppBar(
                  title: title,
                  onBack: () => Navigator.pop(context),
                  onCreateFolder: () => _onCreateFolder(context),
                  onToggleSelection: () =>
                      viewModel.toggleSelectionMode(folderId),
                ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    4.h,
                    16.w,
                    isSelectionMode ? 12.h : 24.h,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index < subFolders.length) {
                      final item = subFolders[index];
                      final isSelected =
                          viewModel.isItemSelected(folderId, item.id);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: SubFolderTile(
                          item: item,
                          isSelected: isSelected,
                          isSelectionMode: isSelectionMode,
                          onTap: () {
                            if (isSelectionMode) {
                              viewModel.toggleItemSelection(
                                folderId,
                                item.id,
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FolderDetailBody(
                                  folderId: item.id,
                                  title: item.name,
                                ),
                              ),
                            );
                          },
                          onLongPress: () => _enterSelectionMode(
                            viewModel,
                            itemId: item.id,
                          ),
                          onMenuAction: (action) => _handleSubFolderMenuAction(
                            context,
                            viewModel,
                            item,
                            action,
                          ),
                        ),
                      );
                    }

                    final card = cards[index - subFolders.length];
                    final isSelected =
                        viewModel.isItemSelected(folderId, card.id);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: GestureDetector(
                        onTap: isSelectionMode
                            ? () => viewModel.toggleItemSelection(
                                  folderId,
                                  card.id,
                                )
                            : null,
                        onLongPress: () => _enterSelectionMode(
                          viewModel,
                          itemId: card.id,
                        ),
                        child: RecentCardTile(
                          item: card,
                          isSelectionMode: isSelectionMode,
                          isSelected: isSelected,
                          selectionTrailing: FolderSelectionCheckbox(
                            isSelected: isSelected,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (isSelectionMode)
                FolderSelectionBottomBar(
                  canMove: viewModel.canMoveSelection(folderId),
                  canShare: viewModel.canShareSelection(folderId),
                  canDelete: viewModel.canDeleteSelection(folderId),
                  onMove: () async {
                    final moved = await MoveFolderBottomSheet.show(
                      context,
                      sourceFolderId: folderId,
                    );
                    if (!context.mounted || !moved) {
                      return;
                    }
                    ui.AppToast.success(context, 'Moved successfully');
                  },
                  onShare: () {
                    viewModel.shareSelectedItems(folderId);
                    ui.AppToast.success(context, 'Share selected items');
                  },
                  onDelete: () {
                    viewModel.deleteSelectedItems(folderId);
                    ui.AppToast.success(context, 'Deleted selected items');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
