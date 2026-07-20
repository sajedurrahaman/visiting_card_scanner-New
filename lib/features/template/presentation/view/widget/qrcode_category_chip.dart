import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class QrcodeCategoryChip extends StatelessWidget {
  const QrcodeCategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const chipSize = 52.0;

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: chipSize.w,
        height: chipSize.w,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? ui.Colors.parentIconSelectTextColor
                : const Color(0xFFE8E8E8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 22.w,
              height: 22.w,
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ui.AppTextStyles.iconUnderText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
