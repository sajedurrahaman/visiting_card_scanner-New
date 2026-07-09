import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class FolderSelectionBottomBar extends StatelessWidget {
  const FolderSelectionBottomBar({
    super.key,
    required this.canMove,
    required this.canShare,
    required this.canDelete,
    required this.onMove,
    required this.onShare,
    required this.onDelete,
  });

  final bool canMove;
  final bool canShare;
  final bool canDelete;
  final VoidCallback onMove;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SelectionAction(
              label: 'Move',
              activeAsset: ui.AppAssets.moveSelectIcon,
              inactiveAsset: ui.AppAssets.moveIcon,
              isEnabled: canMove,
              onTap: onMove,
            ),
            _SelectionAction(
              label: 'Share',
              activeAsset: ui.AppAssets.selectShareIcon,
              inactiveAsset: ui.AppAssets.selectShareIcon,
              isEnabled: canShare,
              onTap: onShare,
            ),
            _SelectionAction(
              label: 'Delete',
              activeAsset: ui.AppAssets.deleteSelectIcon,
              inactiveAsset: ui.AppAssets.delectIcon,
              isEnabled: canDelete,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionAction extends StatelessWidget {
  const _SelectionAction({
    required this.label,
    required this.activeAsset,
    required this.inactiveAsset,
    required this.isEnabled,
    required this.onTap,
  });

  final String label;
  final String activeAsset;
  final String inactiveAsset;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isEnabled
        ? const Color(0xFF05B560)
        : const Color(0xFF9E9E9E);

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isEnabled ? activeAsset : inactiveAsset,
              width: 24.w,
              height: 24.w,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: ui.AppTextStyles.iconUnderText(color: color).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
