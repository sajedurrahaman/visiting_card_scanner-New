import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';

class ParentBottomNavBar extends StatelessWidget {
  const ParentBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParentViewModel>();
    final currentIndex = viewModel.currentIndex;

    return BottomAppBar(
      color: ui.Colors.parentNavColor,
      elevation: 0,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      shape: const CircularNotchedRectangle(),
      notchMargin: 4.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ParentNavItem(
            label: 'Home',
            icon: ui.AppAssets.parentNavLogoOne,
            selectedIcon: ui.AppAssets.parentNavLogoOneSelect,
            isSelected: currentIndex == 0,
            onTap: () => viewModel.changeIndex(0),
          ),
          _ParentNavItem(
            label: 'Template',
            icon: ui.AppAssets.parentNavLogoTwo,
            selectedIcon: ui.AppAssets.parentNavLogoTwoSelect,
            isSelected: currentIndex == 1,
            onTap: () => viewModel.changeIndex(1),
          ),
          SizedBox(width: 64.w),
          _ParentNavItem(
            label: 'Folder',
            icon: ui.AppAssets.parentNavLogoThree,
            selectedIcon: ui.AppAssets.parentNavLogoThreeSelect,
            isSelected: currentIndex == 2,
            onTap: () => viewModel.changeIndex(2),
          ),
          _ParentNavItem(
            label: 'Settings',
            icon: ui.AppAssets.parentNavLogoFour,
            selectedIcon: ui.AppAssets.parentNavLogoFourSelect,
            isSelected: currentIndex == 3,
            onTap: () => viewModel.changeIndex(3),
          ),
        ],
      ),
    );
  }
}

class _ParentNavItem extends StatelessWidget {
  const _ParentNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final String selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? ui.Colors.parentIconSelectTextColor
        : ui.Colors.parentIconTextColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? selectedIcon : icon,
              width: 24.w,
              height: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: ui.AppTextStyles.iconUnderText(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
