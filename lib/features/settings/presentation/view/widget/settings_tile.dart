import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/settings/presentation/view/widget/settings_item_data.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.item});

  final SettingsItemData item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  item.icon,
                  width: 22.w,
                  height: 22.w,
                ),
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
              Icon(
                Icons.chevron_right,
                size: 22.sp,
                color: const Color(0xFF074D2B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
