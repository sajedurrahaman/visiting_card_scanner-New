import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view/widget/folder_item_data.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final FolderItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: ui.Colors.cardBgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF074D2B),
                    width: 1,
                  )
                : null,
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
                child: Text(
                  item.label,
                  style: ui.AppTextStyles.helperText(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
