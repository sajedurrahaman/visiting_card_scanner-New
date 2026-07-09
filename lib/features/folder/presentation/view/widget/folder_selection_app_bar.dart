import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class FolderSelectionAppBar extends StatelessWidget {
  const FolderSelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.isAllSelected,
    required this.onCancel,
    required this.onToggleSelectAll,
  });

  final int selectedCount;
  final bool isAllSelected;
  final VoidCallback onCancel;
  final VoidCallback onToggleSelectAll;

  @override
  Widget build(BuildContext context) {
    final countLabel = selectedCount.toString().padLeft(1, '0');

    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 12.w, 16.h),
      child: Row(
        children: [
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: ui.AppTextStyles.helperText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '$countLabel Selected',
              textAlign: TextAlign.center,
              style: ui.AppTextStyles.mainText(),
            ),
          ),
          TextButton(
            onPressed: onToggleSelectAll,
            child: Text(
              isAllSelected ? 'Deselect All' : 'Select All',
              style: ui.AppTextStyles.helperText(
                color: const Color(0xFF05B560),
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
