import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/presentation/view_model/recent_card_menu_view_model.dart';

class RecentCardTile extends StatelessWidget {
  const RecentCardTile({
    super.key,
    required this.item,
  });

  final RecentCardItem item;

  @override
  Widget build(BuildContext context) {
    final menuViewModel = context.read<RecentCardMenuViewModel>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
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
          _RecentThumbnail(item: item),
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
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: const Color(0xFF9E9E9E),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        item.dateTime,
                        style: ui.AppTextStyles.iconUnderText(
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<RecentCardMenuAction>(
            padding: EdgeInsets.zero,
            color: Colors.white,
            elevation: 8,
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            onSelected: (action) => menuViewModel.handleMenuAction(
              context,
              item: item,
              action: action,
            ),
            itemBuilder: (context) => [
              _buildMenuItem(
                value: RecentCardMenuAction.rename,
                icon: Icons.edit_outlined,
                label: 'Rename',
              ),
              _buildMenuItem(
                value: RecentCardMenuAction.download,
                icon: Icons.download_outlined,
                label: 'Download',
              ),
              _buildMenuItem(
                value: RecentCardMenuAction.share,
                icon: Icons.share_outlined,
                label: 'Share',
              ),
              _buildMenuItem(
                value: RecentCardMenuAction.delete,
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
    );
  }

  PopupMenuItem<RecentCardMenuAction> _buildMenuItem({
    required RecentCardMenuAction value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<RecentCardMenuAction>(
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

class _RecentThumbnail extends StatelessWidget {
  const _RecentThumbnail({required this.item});

  final RecentCardItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isTextFile) {
      return Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4FF),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.description_outlined,
          color: const Color(0xFF2F80ED),
          size: 28.sp,
        ),
      );
    }

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: item.thumbnailPath != null
          ? Image.asset(item.thumbnailPath!, fit: BoxFit.cover)
          : Icon(
              Icons.credit_card,
              color: const Color(0xFF9E9E9E),
              size: 26.sp,
            ),
    );
  }
}
