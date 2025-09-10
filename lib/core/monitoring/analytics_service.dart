import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  static Future<void> trackEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      if (kDebugMode) {
        print('Analytics Event: $eventName');
        print('Parameters: $parameters');
        return;
      }

      // Convert parameters to proper types for Firebase
      final Map<String, Object> firebaseParams = {};
      parameters.forEach((key, value) {
        if (value is String || value is num || value is bool) {
          firebaseParams[key] = value;
        } else {
          firebaseParams[key] = value.toString();
        }
      });

      await _analytics.logEvent(
        name: eventName,
        parameters: firebaseParams,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Analytics error: $e');
      }
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      if (kDebugMode) {
        print('Analytics user property error: $e');
      }
    }
  }

  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      if (kDebugMode) {
        print('Analytics user ID error: $e');
      }
    }
  }

  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      if (kDebugMode) {
        print('Analytics screen view error: $e');
      }
    }
  }
}
