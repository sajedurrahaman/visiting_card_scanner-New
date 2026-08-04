import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/settings/presentation/view/widget/settings_item_data.dart';
import 'package:visiting_card/features/settings/presentation/view/widget/settings_section.dart';
import 'package:visiting_card/features/settings/presentation/view_model/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 20.h),
            child: Text(
              'Settings',
              style: ui.AppTextStyles.mainText(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
              children: [
                SettingsSection(
                  title: 'General',
                  items: [
                    SettingsItemData(
                      icon: ui.AppAssets.shareIcon,
                      label: 'Share with Friend',
                      onTap: () => viewModel.onShareWithFriendTap(context),
                    ),
                    SettingsItemData(
                      icon: ui.AppAssets.ratingIcon,
                      label: 'Rate Us',
                      onTap: () => viewModel.onRateUsTap(context),
                    ),
                    SettingsItemData(
                      icon: ui.AppAssets.moreIcon,
                      label: 'More Apps',
                      onTap: () => viewModel.onMoreAppsTap(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SettingsSection(
                  title: 'Info',
                  items: [
                    SettingsItemData(
                      icon: ui.AppAssets.contactIcon,
                      label: 'Contact Us',
                      onTap: () => viewModel.onContactUsTap(context),
                    ),
                    SettingsItemData(
                      icon: ui.AppAssets.privacyIcon,
                      label: 'Privacy Policy',
                      onTap: () => viewModel.onPrivacyPolicyTap(context),
                    ),
                    SettingsItemData(
                      icon: ui.AppAssets.termsIcon,
                      label: 'Terms & Conditions',
                      onTap: () => viewModel.onTermsAndConditionsTap(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
