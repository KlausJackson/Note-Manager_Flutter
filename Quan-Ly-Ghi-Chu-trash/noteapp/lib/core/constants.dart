import 'dart:io';

class Constants {
  static String get apiBaseUrl {
    if (Platform.isAndroid) {
      // use the special IP that points from the emulator back to the host PC.
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }
}
