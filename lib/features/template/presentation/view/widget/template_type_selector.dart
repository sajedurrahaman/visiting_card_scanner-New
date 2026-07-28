import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class TemplateTypeSelector extends StatelessWidget {
  const TemplateTypeSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _items = [
    _TemplateTypeItem(
      icon: ui.AppAssets.homeVisitingCard,
      label: 'Visiting Card',
    ),
    _TemplateTypeItem(
      icon: ui.AppAssets.homeQrCode,
      label: 'QR Code',
    ),
    _TemplateTypeItem(
      icon: ui.AppAssets.homeBarCode,
      label: 'Barcode',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            Expanded(
              child: _TemplateTypeChip(
                item: _items[i],
                isSelected: selectedIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
            if (i < _items.length - 1) SizedBox(width: 6.w),
          ],
        ],
      ),
    );
  }
}

class _TemplateTypeItem {
  const _TemplateTypeItem({
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;
}

class _TemplateTypeChip extends StatelessWidget {
  const _TemplateTypeChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _TemplateTypeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
    final iconColor =
        isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: isSelected ? null : const Color(0xFFF3F3F3),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF3DCB6A),
                      Color(0xFF0B5D2A),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  item.icon,
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ui.AppTextStyles.iconUnderText(color: textColor)
                        .copyWith(fontWeight: FontWeight.w500,fontSize: 10.sp,letterSpacing: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
