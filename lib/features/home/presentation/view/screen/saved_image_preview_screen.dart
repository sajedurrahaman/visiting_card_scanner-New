import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';

class SavedImagePreviewScreen extends StatelessWidget {
  const SavedImagePreviewScreen({super.key, required this.item});

  final RecentCardItem item;

  List<File> _imageFiles() {
    final path = item.path ?? item.thumbnailPath;
    if (path == null || path.isEmpty) return const [];

    final entity = File(path);
    final dirCandidate = Directory(path);
    if (dirCandidate.existsSync()) {
      final front = File(p.join(path, 'card_front.jpg'));
      final back = File(p.join(path, 'card_back.jpg'));
      final files = <File>[];
      if (front.existsSync()) files.add(front);
      if (back.existsSync()) files.add(back);
      if (files.isEmpty) {
        files.addAll(
          dirCandidate
              .listSync()
              .whereType<File>()
              .where((f) {
                final ext = p.extension(f.path).toLowerCase();
                return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
              }),
        );
      }
      return files;
    }

    if (entity.existsSync()) return [entity];

    final thumb = item.thumbnailPath;
    if (thumb != null && File(thumb).existsSync()) {
      return [File(thumb)];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final files = _imageFiles();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: const Color(0xFF404040),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.name,
          style: ui.AppTextStyles.mainText().copyWith(fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: files.isEmpty
          ? Center(
              child: Text(
                'File not found',
                style: ui.AppTextStyles.helperText(
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: files.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: InteractiveViewer(
                    child: Image.file(files[index], fit: BoxFit.contain),
                  ),
                );
              },
            ),
    );
  }
}
