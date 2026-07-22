import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';

class SavedImagePreviewScreen extends StatelessWidget {
  const SavedImagePreviewScreen({super.key, required this.item});

  final RecentCardItem item;

  @override
  Widget build(BuildContext context) {
    final path = item.path ?? item.thumbnailPath;
    final file = path != null ? File(path) : null;
    final exists = file != null && file.existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: const Color(0xFF404040)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.name,
          style: ui.AppTextStyles.mainText().copyWith(fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: exists
            ? InteractiveViewer(
                child: Image.file(file, fit: BoxFit.contain),
              )
            : Text(
                'File not found',
                style: ui.AppTextStyles.helperText(color: const Color(0xFF9E9E9E)),
              ),
      ),
    );
  }
}
