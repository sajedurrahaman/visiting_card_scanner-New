import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/domain/model/sub_folder_item.dart';

class SubFolderTile extends StatelessWidget {
  const SubFolderTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
  });

  final SubFolderItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelectionMode && isSelected
        ? ui.Colors.cardBgColor
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
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
              SvgPicture.asset(
                ui.AppAssets.folderIcon,
                width: 40.w,
                height: 34.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: ui.AppTextStyles.helperText(
                        color: const Color(0xFF1A1A1A),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.dateTime,
                      style: ui.AppTextStyles.iconUnderText(
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_vert,
                size: 22.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
