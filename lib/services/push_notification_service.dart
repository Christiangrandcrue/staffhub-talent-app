import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _apiService;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  PushNotificationService(this._apiService);

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('FCM Permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _getToken();
      _setupTokenRefresh();
      _setupForegroundHandler();
    }
  }

  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM Token: $_fcmToken');
      }
      
      if (_fcmToken != null) {
        await _registerTokenOnServer(_fcmToken!);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting FCM token: $e');
      }
    }
  }

  void _setupTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      if (kDebugMode) {
        debugPrint('FCM Token refreshed: $newToken');
      }
      await _registerTokenOnServer(newToken);
    });
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Foreground message: ${message.notification?.title}');
      }
      // Here you can show local notification or update UI
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    
    if (kDebugMode) {
      debugPrint('Push received:');
      debugPrint('  Title: ${notification?.title}');
      debugPrint('  Body: ${notification?.body}');
      debugPrint('  Data: $data');
    }
    
    // Handle different notification types based on data
    final type = data['type'];
    switch (type) {
      case 'new_job':
        // Navigate to jobs screen
        break;
      case 'application_approved':
      case 'application_rejected':
        // Navigate to applications screen
        break;
      case 'assignment':
        // Navigate to calendar screen
        break;
      case 'document_expiry':
        // Navigate to documents screen
        break;
    }
  }

  Future<void> _registerTokenOnServer(String token) async {
    try {
      await _apiService.registerDevice(fcmToken: token, platform: 'ANDROID');
      if (kDebugMode) {
        debugPrint('FCM token registered on server');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error registering FCM token: $e');
      }
    }
  }

  Future<void> unregisterToken() async {
    if (_fcmToken != null) {
      try {
        await _apiService.unregisterDevice(_fcmToken!);
        if (kDebugMode) {
          debugPrint('FCM token unregistered');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error unregistering FCM token: $e');
        }
      }
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Background message: ${message.notification?.title}');
  }
}
