import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorReporter {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  static Future<void> initialize() async {
    FlutterError.onError = (errorDetails) {
      reportFlutterError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(error, stack);
      return true;
    };
  }

  static Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
      if (context != null) {
        print('Context: $context');
      }
      return;
    }

    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: false,
      );

      // Add context as custom keys
      if (context != null) {
        context.forEach((key, value) {
          _crashlytics.setCustomKey(key, value.toString());
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to report error to Crashlytics: $e');
      }
    }
  }

  static Future<void> reportFlutterError(
      FlutterErrorDetails errorDetails) async {
    if (kDebugMode) {
      FlutterError.presentError(errorDetails);
      return;
    }

    try {
      await _crashlytics.recordFlutterFatalError(errorDetails);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to report Flutter error to Crashlytics: $e');
      }
    }
  }

  static void setUserContext(String userId, Map<String, String> properties) {
    if (kDebugMode) {
      print('Setting user context: $userId, properties: $properties');
      return;
    }

    try {
      _crashlytics.setUserIdentifier(userId);
      properties.forEach((key, value) {
        _crashlytics.setCustomKey(key, value);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set user context: $e');
      }
    }
  }

  static Future<void> recordNonFatalError(
      Object error, StackTrace stackTrace) async {
    if (kDebugMode) {
      print('Non-fatal error: $error');
      return;
    }

    try {
      await _crashlytics.recordError(error, stackTrace, fatal: false);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to record non-fatal error: $e');
      }
    }
  }
}
