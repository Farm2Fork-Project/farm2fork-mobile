// Firebase configuration for Farm2Fork (project farm2fork-2a5b9).
//
// Values are the public client configuration taken from the platform config
// files (android/app/google-services.json and ios/Runner/GoogleService-Info.plist).
// These identifiers are NOT secrets. The Admin SDK service-account key (a real
// secret) lives only on the backend, never in this app.
//
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for the platform the app is running on.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Farm2Fork Firebase is not configured for the web platform.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Farm2Fork Firebase is configured for Android and iOS only, '
          'not $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCv-EKMygv7FalbcyNHbrI8BiMle1hnCs0',
    appId: '1:886626107303:android:b54e4ef35e46f436998082',
    messagingSenderId: '886626107303',
    projectId: 'farm2fork-2a5b9',
    storageBucket: 'farm2fork-2a5b9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFxQZCJkoXd5VPB-1EBDMHoLanPni2Mtw',
    appId: '1:886626107303:ios:e8f498d43dd0d4cb998082',
    messagingSenderId: '886626107303',
    projectId: 'farm2fork-2a5b9',
    storageBucket: 'farm2fork-2a5b9.firebasestorage.app',
    iosClientId:
        '886626107303-i812hqv7bminose8da3943t881bonpds.apps.googleusercontent.com',
    iosBundleId: 'com.farm2fork.app',
  );
}
