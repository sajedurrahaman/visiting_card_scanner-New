// File generated for Firebase iOS + Android configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDguyvrG_KeOaOBpBmvjPqokcjuYUlQOzw',
    appId: '1:1047867960903:android:e7c28543dc79fbd3608b62',
    messagingSenderId: '1047867960903',
    projectId: 'visiting-card-scanner-maker',
    storageBucket: 'visiting-card-scanner-maker.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApcYkYqSUSgoCh1GYQMJ3NotM-OoxPeKw',
    appId: '1:1047867960903:ios:eed6545c9675fbc1608b62',
    messagingSenderId: '1047867960903',
    projectId: 'visiting-card-scanner-maker',
    storageBucket: 'visiting-card-scanner-maker.firebasestorage.app',
    iosBundleId: 'com.digital.visiting.card.scanner.reader.maker',
  );
}
