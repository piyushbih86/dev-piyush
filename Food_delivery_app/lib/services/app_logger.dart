import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message) {
    debugPrint('[KhaanaDo] $message');
  }

  static void error(String tag, Object error, [StackTrace? stackTrace]) {
    debugPrint('[KhaanaDo][ERROR] $tag: $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}

class AppTracker {
  AppTracker._();

  static void track(String event, [Map<String, Object?> params = const {}]) {
    if (params.isEmpty) {
      AppLogger.debug('track $event');
    } else {
      AppLogger.debug('track $event $params');
    }
  }
}
