import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

enum VisitingCardQrOption { place, customize }

/// Place / Customize dialog after picking a visiting-card QR template.
class VisitingCardQrOptionDialog extends StatelessWidget {
  const VisitingCardQrOptionDialog({super.key});

  static Future<VisitingCardQrOption?> show(BuildContext context) {
    return showDialog<VisitingCardQrOption>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const VisitingCardQrOptionDialog(),
    );
  }

  static const _green = Color(0xFF05B560);
  static const _purple = Color(0xFF7B5CFF);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 28.w),
            padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose An Option',
                  style: ui.AppTextStyles.mainText().copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'How would you like to use this template?',
                  textAlign: TextAlign.center,
                  style: ui.AppTextStyles.helperText(
                    color: const Color(0xFF9E9E9E),
                  ).copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 18.h),
                _OptionTile(
                  iconAsset:
                      ui.AppAssets.templateVisitingCardQrCodeDialogPlaceIcon,
                  title: 'Place',
                  subtitle:
                      'Add your QR code directly and use the template as it is.',
                  accent: _green,
                  background: const Color(0xFFE8F8EF),
                  onTap: () =>
                      Navigator.pop(context, VisitingCardQrOption.place),
                ),
                SizedBox(height: 10.h),
                _OptionTile(
                  iconAsset: ui.AppAssets
                      .templateVisitingCardQrCodeDialogCustomizeIcon,
                  title: 'Customize',
                  subtitle:
                      'Customize colors, shapes, and elements before using.',
                  accent: _purple,
                  background: const Color(0xFFF1EDFF),
                  onTap: () =>
                      Navigator.pop(context, VisitingCardQrOption.customize),
                ),
                SizedBox(height: 14.h),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                  label: Text(
                    'Cancel',
                    style: ui.AppTextStyles.helperText(
                      color: const Color(0xFF9E9E9E),
                    ).copyWith(fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _green, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: EdgeInsets.all(12.w),
              child: Image.asset(
                ui.AppAssets.templateVisitingCardQrCode2,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.background,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final Color accent;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                child: SvgPicture.asset(iconAsset, colorFilter: ColorFilter.mode(accent, BlendMode.srcIn)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ui.AppTextStyles.mainText().copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: ui.AppTextStyles.helperText(
                        color: const Color(0xFF6B6B6B),
                      ).copyWith(fontSize: 11.sp, height: 1.25),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: accent, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
