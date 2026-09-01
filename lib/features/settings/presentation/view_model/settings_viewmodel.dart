import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';

class SettingsViewModel extends ChangeNotifier {
  // TODO: Replace these placeholders with your real production values.
  static const String _appName = 'Visiting Card Scanner';
  static const String _supportEmail = 'sajedurrahamanapp@gmail.com';
  static const String _moreAppsUrl =
      'https://apps.apple.com/us/developer/md-sajedur-rahaman/id1586019019';
  static const String _privacyPolicyUrl = 'https://sites.google.com/view/visiting-card-scanner-maker-a';
  static const String _termsAndConditionsUrl = 'https://sites.google.com/view/visitingcardscannermaker-a';

  void onUpgradePremiumTap() {}

  // Future<void> onShareWithFriendTap(BuildContext context) async {
  //   try {
  //     await Share.share('Check out $_appName');
  //   } catch (_) {
  //     if (!context.mounted) return;
  //     ui.AppToast.show(context, message: 'Failed to share app');
  //   }
  // }

  Future<void> onShareWithFriendTap(BuildContext context) async {
    final message =
        'Check out $_appName\n'
        'https://apps.apple.com/app/id6798218537';

    try {
      await VisitingCardShareHelper.shareText(context, message);
    } catch (_) {
      if (!context.mounted) return;
      ui.AppToast.show(context, message: 'Failed to share app');
    }
  }

  Future<void> onRateUsTap(BuildContext context) async {

    final marketUri = Uri.parse('market://details?id6798218537');
    final webUri = Uri.parse(
      'https://apps.apple.com/app/id6798218537',
    );

    final launched = await launchUrl(
      marketUri,
      mode: LaunchMode.externalApplication,
    );
    if (launched) return;

    final launchedWeb = await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launchedWeb && context.mounted) {
      ui.AppToast.show(context, message: 'Failed to open store page');
    }
  }

  Future<void> onMoreAppsTap(BuildContext context) async {
    await _openUrl(
      context,
      url: _moreAppsUrl,
      missingMessage: 'Add More Apps URL to open this page',
      failureMessage: 'Failed to open More Apps',
    );
  }

  Future<void> onContactUsTap(BuildContext context) async {
    if (_supportEmail.isEmpty) {
      ui.AppToast.show(context, message: 'Add support email to enable Contact Us');
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'Support Request - $_appName',
      },
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ui.AppToast.show(context, message: 'Failed to open email app');
    }
  }

  Future<void> onPrivacyPolicyTap(BuildContext context) async {
    await _openUrl(
      context,
      url: _privacyPolicyUrl,
      missingMessage: 'Add privacy policy URL to open this page',
      failureMessage: 'Failed to open Privacy Policy',
    );
  }

  Future<void> onTermsAndConditionsTap(BuildContext context) async {
    await _openUrl(
      context,
      url: _termsAndConditionsUrl,
      missingMessage: 'Add terms URL to open this page',
      failureMessage: 'Failed to open Terms & Conditions',
    );
  }

  Future<void> _openUrl(
    BuildContext context, {
    required String url,
    required String missingMessage,
    required String failureMessage,
  }) async {
    if (url.isEmpty) {
      ui.AppToast.show(context, message: missingMessage);
      return;
    }

    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ui.AppToast.show(context, message: failureMessage);
    }
  }
}
