// Generated file for Firebase configuration
// Valores extraídos de google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA50W-8-652Bf2cqx6v2Kx7c2juiScmFRI',
    appId: '1:386527105063:android:656d7857abc804fe14fe02',
    messagingSenderId: '386527105063',
    projectId: 'paleto-knife-97c24',
    databaseURL: 'https://paleto-knife-97c24-default-rtdb.firebaseio.com',
    storageBucket: 'paleto-knife-97c24.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA50W-8-652Bf2cqx6v2Kx7c2juiScmFRI',
    appId: '1:386527105063:web:656d7857abc804fe14fe02',
    messagingSenderId: '386527105063',
    projectId: 'paleto-knife-97c24',
    authDomain: 'paleto-knife-97c24.firebaseapp.com',
    databaseURL: 'https://paleto-knife-97c24-default-rtdb.firebaseio.com',
    storageBucket: 'paleto-knife-97c24.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA50W-8-652Bf2cqx6v2Kx7c2juiScmFRI',
    appId: '1:386527105063:ios:656d7857abc804fe14fe02',
    messagingSenderId: '386527105063',
    projectId: 'paleto-knife-97c24',
    databaseURL: 'https://paleto-knife-97c24-default-rtdb.firebaseio.com',
    storageBucket: 'paleto-knife-97c24.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA50W-8-652Bf2cqx6v2Kx7c2juiScmFRI',
    appId: '1:386527105063:macos:656d7857abc804fe14fe02',
    messagingSenderId: '386527105063',
    projectId: 'paleto-knife-97c24',
    databaseURL: 'https://paleto-knife-97c24-default-rtdb.firebaseio.com',
    storageBucket: 'paleto-knife-97c24.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA50W-8-652Bf2cqx6v2Kx7c2juiScmFRI',
    appId: '1:386527105063:windows:656d7857abc804fe14fe02',
    messagingSenderId: '386527105063',
    projectId: 'paleto-knife-97c24',
    databaseURL: 'https://paleto-knife-97c24-default-rtdb.firebaseio.com',
    storageBucket: 'paleto-knife-97c24.firebasestorage.app',
  );
}
