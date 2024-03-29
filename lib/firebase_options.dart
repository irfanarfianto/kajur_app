// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0jpscArD0O7kzBB9j7l8a6Slmo4A6ngs',
    appId: '1:92661859660:android:97ddd3c83b05a4b7bdbbe9',
    messagingSenderId: '92661859660',
    projectId: 'kajur-app',
    databaseURL: 'https://kajur-app-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'kajur-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBMZb5orT-xG-5WciXXYG3VAU6oN2wFa30',
    appId: '1:92661859660:ios:19c195365a670038bdbbe9',
    messagingSenderId: '92661859660',
    projectId: 'kajur-app',
    databaseURL: 'https://kajur-app-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'kajur-app.appspot.com',
    iosClientId: '92661859660-dkov7o5qfo787kkljs0su50iqofqv26g.apps.googleusercontent.com',
    iosBundleId: 'com.example.kajurApp',
  );
}
