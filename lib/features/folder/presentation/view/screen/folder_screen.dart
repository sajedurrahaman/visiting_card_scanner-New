import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/routes/route_names.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view/widget/folder_tile.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';

class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

  String _routeForFolder(String folderId) {
    switch (folderId) {
      case FolderViewModel.visitingCardFolderId:
        return RouteNames.visitingCardFolder;
      case FolderViewModel.qrCodeFolderId:
        return RouteNames.qrCodeFolder;
      case FolderViewModel.barcodeFolderId:
        return RouteNames.barcodeFolder;
      default:
        return RouteNames.visitingCardFolder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FolderViewModel>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 20.h),
            child: Text(
              'Folder',
              style: ui.AppTextStyles.mainText(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
              itemCount: viewModel.folders.length,
              separatorBuilder: (_, _) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final item = viewModel.folders[index];

                return FolderTile(
                  item: item,
                  isSelected: viewModel.selectedIndex == index,
                  onTap: () {
                    viewModel.onFolderTap(index);
                    Navigator.pushNamed(
                      context,
                      _routeForFolder(item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
