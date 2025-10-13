import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static FlutterLocalNotificationsPlugin? _localNotifications;
  static String? _deviceId;
  static const String _baseUrl = 'http://localhost:4000'; // Your backend URL
  
  /// Initialize notification service without Firebase
  Future<void> initialize() async {
    try {
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Generate unique device ID
      await _generateDeviceId();
      
      // Register device with backend
      await _registerDeviceWithBackend();
      
      print('🎯 Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications platform settings
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications?.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'care_hr_notifications',
      'Care HR Notifications',
      description: 'Notifications for Care HR app',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Generate unique device ID
  Future<void> _generateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }
    
    print('📱 Device ID: $_deviceId');
  }

  /// Register device with backend for notifications
  Future<void> _registerDeviceWithBackend() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/register-device'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'deviceId': _deviceId,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'appVersion': '1.0.0',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Device registered with backend');
      } else {
        print('⚠️ Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error registering device: $e');
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _localNotifications
          ?.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }
    
    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS doesn't provide this check easily
  }

  /// Show local notification
  Future<void> showLocalNotification(
    String title,
    String body, {
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'care_hr_notifications',
      'Care HR Notifications',
      channelDescription: 'Notifications for Care HR app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications?.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Subscribe to notification topic via backend
  Future<void> subscribeToTopic(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/subscribe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'deviceId': _deviceId,
          'topic': topic,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Subscribed to topic: $topic');
        
        // Save subscription locally
        final prefs = await SharedPreferences.getInstance();
        final subscriptions = prefs.getStringList('notification_subscriptions') ?? [];
        if (!subscriptions.contains(topic)) {
          subscriptions.add(topic);
          await prefs.setStringList('notification_subscriptions', subscriptions);
        }
      } else {
        print('❌ Failed to subscribe to topic: $topic');
      }
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from notification topic via backend
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/unsubscribe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'deviceId': _deviceId,
          'topic': topic,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Unsubscribed from topic: $topic');
        
        // Remove subscription locally
        final prefs = await SharedPreferences.getInstance();
        final subscriptions = prefs.getStringList('notification_subscriptions') ?? [];
        subscriptions.remove(topic);
        await prefs.setStringList('notification_subscriptions', subscriptions);
      } else {
        print('❌ Failed to unsubscribe from topic: $topic');
      }
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Get device ID (replaces Firebase token)
  Future<String?> getDeviceToken() async {
    return _deviceId;
  }

  /// Get all subscribed topics
  Future<List<String>> getSubscribedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notification_subscriptions') ?? [];
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _navigateBasedOnPayload(payload);
    }
  }

  /// Navigate based on notification payload
  void _navigateBasedOnPayload(String payload) {
    try {
      final data = json.decode(payload);
      final type = data['type'] as String?;
      
      // Handle navigation based on notification type
      switch (type) {
        case 'job_application':
          // Navigate to applications screen
          break;
        case 'interview':
          // Navigate to interview screen
          break;
        case 'document':
          // Navigate to documents screen
          break;
        default:
          // Navigate to dashboard
          break;
      }
    } catch (e) {
      print('❌ Error parsing notification payload: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications?.cancelAll();
  }

  /// Schedule a local notification for later
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'care_hr_notifications',
      'Care HR Notifications',
      channelDescription: 'Notifications for Care HR app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: For advanced scheduling, you might need to use a different package
    // or implement server-side scheduling
    await _localNotifications?.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Static convenience methods for backward compatibility
  static Future<void> initializeStatic() async {
    await PushNotificationService().initialize();
  }

  static Future<bool> requestPermission() async {
    return await PushNotificationService().requestPermissions();
  }

  static Future<bool> checkNotificationsEnabled() async {
    return await PushNotificationService().areNotificationsEnabled();
  }

  static Future<void> showNotification(String title, String body) async {
    await PushNotificationService().showLocalNotification(title, body);
  }
}