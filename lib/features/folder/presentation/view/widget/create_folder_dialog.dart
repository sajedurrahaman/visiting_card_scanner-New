import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const CreateFolderDialog(),
    );
  }

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Folder',
              style: ui.AppTextStyles.mainText(),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(context),
              decoration: InputDecoration(
                hintText: 'Folder Name',
                hintStyle: ui.AppTextStyles.helperText(
                  color: const Color(0xFFB0B0B0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF05B560),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF05B560),
                    width: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFF1A1A1A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: ui.AppTextStyles.helperText(
                        color: const Color(0xFF1A1A1A),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF05B560),
                          Color(0xFF074D2B),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                      ),
                      child: Text(
                        'Create',
                        style: ui.AppTextStyles.helperText(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.pop(context, name);
  }
}
