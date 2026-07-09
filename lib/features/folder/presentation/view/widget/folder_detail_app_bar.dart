import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class FolderDetailAppBar extends StatelessWidget {
  const FolderDetailAppBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onCreateFolder,
    required this.onToggleSelection,
    this.isSelectionMode = false,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onCreateFolder;
  final VoidCallback onToggleSelection;
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 12.w, 16.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: ui.AppTextStyles.mainText(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                asset: ui.AppAssets.createFolderIcon,
                onTap: onCreateFolder,
              ),
              SizedBox(width: 8.w),
              _ActionIconButton(
                asset: ui.AppAssets.folderSelectIcon,
                onTap: onToggleSelection,
                isActive: isSelectionMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.asset,
    required this.onTap,
    this.isActive = false,
  });

  final String asset;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: SvgPicture.asset(
            asset,
            width: 24.w,
            height: 24.w,
            colorFilter: isActive
                ? const ColorFilter.mode(
                    Color(0xFF05B560),
                    BlendMode.srcIn,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
