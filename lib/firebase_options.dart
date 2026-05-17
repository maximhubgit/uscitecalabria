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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non supportato per $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC_UwXfbLkrW_lY8otrwGL_bb7tBjhD16M",
    authDomain: "uscite-calabria.firebaseapp.com",
    projectId: "uscite-calabria",
    storageBucket: "uscite-calabria.firebasestorage.app",
    messagingSenderId: "691377905867",
    appId: "1:691377905867:web:4ae8fdbfd1ffa29e83bb4e"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBEJQCDWmpDvpujy9dkh-8K86Zj7BZN_Uk",
    appId: "1:691377905867:android:678302eacfc0628a83bb4e",
    messagingSenderId: "691377905867",
    projectId: "uscite-calabria",
    storageBucket: "uscite-calabria.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_UwXfbLkrW_lY8otrwGL_bb7tBjhD16M',
    appId: '1:691377905867:ios:placeholder',
    messagingSenderId: '691377905867',
    projectId: 'uscite-calabria',
    storageBucket: 'uscite-calabria.appspot.com',
  );
}
