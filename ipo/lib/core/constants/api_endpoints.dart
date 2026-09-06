import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Configurable backend base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 10.0.2.2 accesses host machine from Android emulator
        return 'http://10.0.2.2:5000/api';
      default:
        return 'http://localhost:5000/api';
    }
  }

  static const String authSync = '/auth/sync';
  static const String ipos = '/ipos';
  static const String pans = '/pans';
  static const String allotmentCheck = '/allotment/check';
}
