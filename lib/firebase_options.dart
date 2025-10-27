import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';

/// Заглушка с настройками Firebase. Перед публикацией
/// необходимо заменить значения на реальные параметры
/// из консоли Firebase и добавить google-services.json/GoogleService-Info.plist.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return const FirebaseOptions(
        apiKey: 'REPLACE_ME',
        appId: '1:000000000000:android:placeholder',
        messagingSenderId: '000000000000',
        projectId: 'planner-app',
      );
    }
    if (Platform.isIOS) {
      return const FirebaseOptions(
        apiKey: 'REPLACE_ME',
        appId: '1:000000000000:ios:placeholder',
        messagingSenderId: '000000000000',
        projectId: 'planner-app',
        iosBundleId: 'com.example.planner',
      );
    }
    return const FirebaseOptions(
      apiKey: 'REPLACE_ME',
      appId: '1:000000000000:web:placeholder',
      messagingSenderId: '000000000000',
      projectId: 'planner-app',
    );
  }
}
