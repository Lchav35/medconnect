import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🌐 WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBHRRUshcYULChPRMbArsubpxCFxy_LpPM",
    authDomain: "medconnect-saas.firebaseapp.com",
    projectId: "medconnect-saas",
    storageBucket: "medconnect-saas.firebasestorage.app",
    messagingSenderId: "624830714520",
    appId: "1:624830714520:web:1f3b4977085d626bd676ed",
  );

  // 🤖 ANDROID (configurar quando registrar app Android)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBHRRUshcYULChPRMbArsubpxCFxy_LpPM",
    appId: "COLE_AQUI_O_APP_ID_ANDROID",
    messagingSenderId: "624830714520",
    projectId: "medconnect-saas",
    storageBucket: "medconnect-saas.firebasestorage.app",
  );

  // 🍎 IOS (configurar quando registrar app iOS)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBHRRUshcYULChPRMbArsubpxCFxy_LpPM",
    appId: "COLE_AQUI_O_APP_ID_IOS",
    messagingSenderId: "624830714520",
    projectId: "medconnect-saas",
    storageBucket: "medconnect-saas.firebasestorage.app",
    iosBundleId: "com.seu.bundleid",
  );
}