import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view/widget/create_folder_dialog.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_detail_app_bar.dart';
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
              FolderDetailAppBar(
                title: title,
                isSelectionMode: isSelectionMode,
                onBack: () => Navigator.pop(context),
                onCreateFolder: () => _onCreateFolder(context),
                onToggleSelection: () =>
                    viewModel.toggleSelectionMode(folderId),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelectionMode && isSelected
                                ? ui.Colors.cardBgColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: RecentCardTile(item: card),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
