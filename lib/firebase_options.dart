// File ini di-generate manual dari google-services.json
// project: puvluf | package: com.pufluv.app
// JANGAN commit ke Git jika berisi data sensitif — sudah di-cover .gitignore

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDalkzt6rO43jBE3qLeSupQaNcCYOITaao',
    appId: '1:468223071374:android:32739c4792957b765d25df',
    messagingSenderId: '468223071374',
    projectId: 'puvluf',
    databaseURL: 'https://puvluf-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'puvluf.firebasestorage.app',
  );
}
