// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCkI3laUosHyEvRtQKPZTXSaNagw43kn1E',
    appId: '1:26498716227:web:b1cec96d1fba59be6fbaf6',
    messagingSenderId: '26498716227',
    projectId: 'projectshow-5f97c',
    authDomain: 'projectshow-5f97c.firebaseapp.com',
    storageBucket: 'projectshow-5f97c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR9OrJ3OYdZ5BwGyY32oMg13HKJPX9lug',
    appId: '1:26498716227:android:e3ea08b7c4a05f5e6fbaf6',
    messagingSenderId: '26498716227',
    projectId: 'projectshow-5f97c',
    storageBucket: 'projectshow-5f97c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjLRT0ZldOGBziGwynCwA0lWvCUuOS-GQ',
    appId: '1:26498716227:ios:e395ba9982f500f86fbaf6',
    messagingSenderId: '26498716227',
    projectId: 'projectshow-5f97c',
    storageBucket: 'projectshow-5f97c.firebasestorage.app',
    iosBundleId: 'com.example.payit1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjLRT0ZldOGBziGwynCwA0lWvCUuOS-GQ',
    appId: '1:26498716227:ios:e395ba9982f500f86fbaf6',
    messagingSenderId: '26498716227',
    projectId: 'projectshow-5f97c',
    storageBucket: 'projectshow-5f97c.firebasestorage.app',
    iosBundleId: 'com.example.payit1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCkI3laUosHyEvRtQKPZTXSaNagw43kn1E',
    appId: '1:26498716227:web:2dfaa8c23b5aa0a96fbaf6',
    messagingSenderId: '26498716227',
    projectId: 'projectshow-5f97c',
    authDomain: 'projectshow-5f97c.firebaseapp.com',
    storageBucket: 'projectshow-5f97c.firebasestorage.app',
  );
}
