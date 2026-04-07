import 'package:flutter/foundation.dart';

/// Production-safe logger that only logs in debug mode.
/// Replaces all `print()` calls across the codebase.
class AppLogger {
  static void info(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] ✅ $message');
    }
  }

  static void warning(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] ⚠️ $message');
    }
  }

  static void error(String tag, String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[$tag] ❌ $message${error != null ? ': $error' : ''}');
    }
  }

  static void network(String tag, int statusCode, String endpoint) {
    if (kDebugMode) {
      debugPrint('[$tag] 🌐 HTTP $statusCode → $endpoint');
    }
  }
}
