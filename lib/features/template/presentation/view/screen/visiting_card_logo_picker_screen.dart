import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

/// Picks a logo via the Android/iOS system photo picker or camera.
/// Does **not** request READ_MEDIA_IMAGES / broad gallery access.
class VisitingCardLogoPickerScreen {
  VisitingCardLogoPickerScreen._();

  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> open(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Add logo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: ui.Colors.parentIconSelectTextColor,
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: ui.Colors.parentIconSelectTextColor,
                  ),
                  title: Text(
                    'Take photo',
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !context.mounted) return null;
    return _pick(source);
  }

  static Future<File?> _pick(ImageSource source) async {
    try {
      final x = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (x == null) return null;
      final bytes = await x.readAsBytes();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/vc_logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }
}
