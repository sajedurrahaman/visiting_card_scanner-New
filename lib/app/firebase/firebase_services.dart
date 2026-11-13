import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:visiting_card/firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupCrashlytics();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  unawaited(setupFirebaseMessaging());
}

bool _isOfflineGoogleFontFailure(Object error) {
  final text = error.toString();
  return text.contains('fonts.gstatic.com') ||
      text.contains('Failed to load font with url');
}

/// UI / plugin noise that should not count as fatal app crashes.
bool _isNonFatalFlutterNoise(Object error) {
  final text = error.toString();
  if (_isOfflineGoogleFontFailure(error)) return true;
  // Yellow-black stripes — layout bug, not a process crash.
  if (text.contains('A RenderFlex overflowed by')) return true;
  // Missing asset is handled by errorBuilder in most places; still not fatal.
  if (text.contains('Unable to load asset')) return true;
  // Double-open ImagePicker on Android.
  if (text.contains('already_active')) return true;
  return false;
}

Future<void> setupCrashlytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = (details) {
    if (_isNonFatalFlutterNoise(details.exception)) {
      debugPrint('Non-fatal Flutter error: ${details.exception}');
      // Keep visibility in Crashlytics without marking the session as crashed.
      FirebaseCrashlytics.instance.recordFlutterError(details);
      return;
    }
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isNonFatalFlutterNoise(error)) {
      debugPrint('Non-fatal platform error: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      return true;
    }
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> setupFirebaseMessaging() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (_) {},
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_highImportanceChannel);
    await androidPlugin?.requestNotificationsPermission();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      unawaited(
        _showNotification(
          notification.title ?? 'New Notification',
          notification.body ?? 'You have a new message',
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');
  } catch (e, stack) {
    debugPrint('Error setting up Firebase Messaging: $e');
    unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
  }
}

Future<void> _showNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'Used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const iosDetails = DarwinNotificationDetails();

  await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    ),
    payload: 'notification_payload',
  );
}

void _handleNotificationTap(RemoteMessage message) {
  debugPrint('Notification opened: ${message.data}');
}
