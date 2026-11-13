import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:upgrader/upgrader.dart';
import 'package:visiting_card/app/navigator/app_navigator_key.dart';
import 'package:visiting_card/app/routes/route_names.dart';

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
    // Material on all platforms: Cupertino dialog on iOS can fight Flutter's
    // SystemContextMenu ("Attempted to show while another instance was still
    // visible") during splash → home transitions.
    dialogStyle: UpgradeDialogStyle.material,
    showReleaseNotes: false,
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
    super.showReleaseNotes,
    super.child,
  });

  @override
  UpgradeAlertState createState() => _SafeForceUpdateAlertState();
}

class _SafeForceUpdateAlertState extends UpgradeAlertState {
  bool _showQueued = false;

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
    if (_showQueued) return;

    final dialogContext = _dialogContext(context);
    if (dialogContext == null || _isOnSplash(dialogContext)) {
      // Navigator / splash not ready yet — retry next frame.
      displayed = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }

    _showQueued = true;
    // Dismiss any focused field / iOS system text menu before the alert.
    FocusManager.instance.primaryFocus?.unfocus();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Let the previous route + context menu finish tearing down.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) {
        _showQueued = false;
        return;
      }

      final readyContext = _dialogContext(context);
      if (readyContext == null || _isOnSplash(readyContext)) {
        displayed = false;
        _showQueued = false;
        if (mounted) setState(() {});
        return;
      }

      FocusManager.instance.primaryFocus?.unfocus();

      try {
        super.showTheDialog(
          key: key,
          context: readyContext,
          title: title,
          message: message,
          releaseNotes: null, // avoid long selectable notes on iOS
          barrierDismissible: barrierDismissible,
          messages: messages,
        );
      } catch (e, st) {
        debugPrint('upgrader dialog failed: $e\n$st');
        displayed = false;
        _showQueued = false;
      }
    });
  }

  bool _isOnSplash(BuildContext ctx) {
    final name = ModalRoute.of(ctx)?.settings.name;
    return name == RouteNames.splash || name == '/';
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
