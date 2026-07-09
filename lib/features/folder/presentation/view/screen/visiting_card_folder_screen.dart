import 'package:flutter/material.dart';
import 'package:visiting_card/features/folder/presentation/view/widget/folder_detail_body.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';

class VisitingCardFolderScreen extends StatelessWidget {
  const VisitingCardFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FolderDetailBody(
      folderId: FolderViewModel.visitingCardFolderId,
      title: 'Visiting card',
    );
  }
}
