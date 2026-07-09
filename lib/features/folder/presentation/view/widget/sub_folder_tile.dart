import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view/widget/folder_selection_checkbox.dart';
import 'package:visiting_card/features/folder/domain/model/sub_folder_item.dart';

enum SubFolderMenuAction { rename, delete }

class SubFolderTile extends StatelessWidget {
  const SubFolderTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    this.onLongPress,
    this.onMenuAction,
  });

  final SubFolderItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<SubFolderMenuAction>? onMenuAction;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelectionMode && isSelected
        ? ui.Colors.cardBgColor
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
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
              if (isSelectionMode)
                FolderSelectionCheckbox(isSelected: isSelected)
              else
                PopupMenuButton<SubFolderMenuAction>(
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  elevation: 8,
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  onSelected: onMenuAction,
                  itemBuilder: (context) => [
                    _buildMenuItem(
                      value: SubFolderMenuAction.rename,
                      icon: Icons.edit_outlined,
                      label: 'Rename',
                    ),
                    _buildMenuItem(
                      value: SubFolderMenuAction.delete,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    size: 22.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<SubFolderMenuAction> _buildMenuItem({
    required SubFolderMenuAction value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<SubFolderMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: const Color(0xFF1A1A1A)),
          SizedBox(width: 10.w),
          Text(
            label,
            style: ui.AppTextStyles.helperText(
              color: const Color(0xFF1A1A1A),
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
