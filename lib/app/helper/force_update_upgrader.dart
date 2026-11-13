import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:visiting_card/app/navigator/app_navigator_key.dart';

/// Soft update by default (Update Now + Skip Now).
///
/// Force update: when Play/App Store description sets a minimum version,
/// [Upgrader.blocked] hides Skip and only Update remains.
///
/// Play Store description tag:
///   [Minimum supported app version: 1.0.6]
/// App Store description tag:
///   [:mav: 1.0.6]
final Upgrader _appUpgrader = createAppUpgrader();

Upgrader createAppUpgrader() {
  return Upgrader(
    debugLogging: kDebugMode,
    // Debug-only: always show dialog so local version tests don't need a
    // higher store build. Turn off for release (kDebugMode is false).
    debugDisplayAlways: kDebugMode,
    // After Skip Now, don't prompt again until this duration.
    durationUntilAlertAgain: const Duration(days: 1),
    messages: _SkipNowUpgraderMessages(),
  );
}

/// Wraps [child] so an upgrade dialog can show when a newer version exists.
Widget wrapWithForceUpdateAlert({required Widget child}) {
  return _SafeForceUpdateAlert(
    upgrader: _appUpgrader,
    navigatorKey: appNavigatorKey,
    barrierDismissible: false,
    shouldPopScope: () => true,
    showIgnore: false,
    showLater: true,
    dialogStyle: Platform.isIOS
        ? UpgradeDialogStyle.cupertino
        : UpgradeDialogStyle.material,
    child: child,
  );
}

/// [UpgradeAlert] in [MaterialApp.builder] sits above the [Navigator].
/// Showing the dialog with that context can fail; use the root navigator key.
class _SafeForceUpdateAlert extends UpgradeAlert {
  _SafeForceUpdateAlert({
    required super.upgrader,
    super.navigatorKey,
    super.barrierDismissible,
    super.shouldPopScope,
    super.showIgnore,
    super.showLater,
    super.dialogStyle,
    super.child,
  });

  @override
  UpgradeAlertState createState() => _SafeForceUpdateAlertState();
}

class _SafeForceUpdateAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    final dialogContext = _dialogContext(context);
    if (dialogContext == null) {
      displayed = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }

    super.showTheDialog(
      key: key,
      context: dialogContext,
      title: title,
      message: message,
      releaseNotes: releaseNotes,
      barrierDismissible: barrierDismissible,
      messages: messages,
    );
  }

  BuildContext? _dialogContext(BuildContext fallback) {
    final fromKey = widget.navigatorKey?.currentContext;
    if (_canShowDialog(fromKey)) return fromKey;
    if (_canShowDialog(fallback)) return fallback;
    return null;
  }

  bool _canShowDialog(BuildContext? ctx) {
    if (ctx == null || !ctx.mounted) return false;
    return Navigator.maybeOf(ctx, rootNavigator: true) != null;
  }
}

class _SkipNowUpgraderMessages extends UpgraderMessages {
  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.buttonTitleUpdate:
        return 'Update Now';
      case UpgraderMessage.buttonTitleLater:
        return 'Skip Now';
      case UpgraderMessage.title:
        return 'Update Available';
      case UpgraderMessage.body:
        return 'A new version of this app is available. '
            'Update now or skip for now to continue using the app.';
      case UpgraderMessage.prompt:
        return 'Would you like to update now?';
      default:
        return super.message(messageKey);
    }
  }
}
