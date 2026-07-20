import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class TemplateOrientationTabs extends StatelessWidget {
  const TemplateOrientationTabs({
    super.key,
    required this.orientation,
    required this.onChanged,
  });

  final VisitingCardOrientation orientation;
  final ValueChanged<VisitingCardOrientation> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrientationTab(
          label: 'Horizontal',
          isSelected: orientation == VisitingCardOrientation.horizontal,
          onTap: () => onChanged(VisitingCardOrientation.horizontal),
        ),
        SizedBox(width: 24.w),
        _OrientationTab(
          label: 'Vertical',
          isSelected: orientation == VisitingCardOrientation.vertical,
          onTap: () => onChanged(VisitingCardOrientation.vertical),
        ),
      ],
    );
  }
}

class _OrientationTab extends StatelessWidget {
  const _OrientationTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? ui.Colors.parentIconSelectTextColor
        : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: ui.AppTextStyles.helperText(color: color).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.h,
            width: isSelected ? 28.w : 0,
            decoration: BoxDecoration(
              color: ui.Colors.parentIconSelectTextColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
