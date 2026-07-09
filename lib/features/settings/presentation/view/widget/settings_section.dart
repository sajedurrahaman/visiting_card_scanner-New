import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/settings/presentation/view/widget/settings_item_data.dart';
import 'package:visiting_card/features/settings/presentation/view/widget/settings_tile.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ui.AppTextStyles.mainText(),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: ui.Colors.cardBgColor,
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
          child: Column(
            children: items.map((item) => SettingsTile(item: item)).toList(),
          ),
        ),
      ],
    );
  }
}
