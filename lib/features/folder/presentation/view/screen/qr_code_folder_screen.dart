import 'package:flutter/material.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_detail_body.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';

class QrCodeFolderScreen extends StatelessWidget {
  const QrCodeFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FolderDetailBody(
      folderId: FolderViewModel.qrCodeFolderId,
      title: 'QR Code',
    );
  }
}
