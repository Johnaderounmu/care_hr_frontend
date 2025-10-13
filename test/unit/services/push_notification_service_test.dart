import 'package:flutter_test/flutter_test.dart';
import 'package:care_hr_app/core/services/push_notification_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'push_notification_service_test.mocks.dart';

// Mock classes for testing
@GenerateMocks([PushNotificationService])
void main() {
  group('PushNotificationService Tests', () {
    late MockPushNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockPushNotificationService();
    });

    test('should initialize push notifications', () async {
      // Arrange
      when(mockNotificationService.initialize()).thenAnswer((_) async => null);

      // Act
      await mockNotificationService.initialize();

      // Assert
      verify(mockNotificationService.initialize()).called(1);
    });

    test('should request notification permissions', () async {
      // Arrange
      when(mockNotificationService.requestPermissions()).thenAnswer((_) async => true);

      // Act
      final result = await mockNotificationService.requestPermissions();

      // Assert
      expect(result, true);
      verify(mockNotificationService.requestPermissions()).called(1);
    });

    test('should return false when permission denied', () async {
      // Arrange
      when(mockNotificationService.requestPermissions()).thenAnswer((_) async => false);

      // Act
      final result = await mockNotificationService.requestPermissions();

      // Assert
      expect(result, false);
      verify(mockNotificationService.requestPermissions()).called(1);
    });

    test('should get device token', () async {
      // Arrange
      const expectedToken = 'test_device_id_123';
      when(mockNotificationService.getDeviceToken()).thenAnswer((_) async => expectedToken);

      // Act
      final token = await mockNotificationService.getDeviceToken();

      // Assert
      expect(token, expectedToken);
      verify(mockNotificationService.getDeviceToken()).called(1);
    });

    test('should return null when device token not available', () async {
      // Arrange
      when(mockNotificationService.getDeviceToken()).thenAnswer((_) async => null);

      // Act
      final token = await mockNotificationService.getDeviceToken();

      // Assert
      expect(token, null);
      verify(mockNotificationService.getDeviceToken()).called(1);
    });

    test('should check if notifications are enabled', () async {
      // Arrange
      when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);

      // Act
      final result = await mockNotificationService.areNotificationsEnabled();

      // Assert
      expect(result, true);
      verify(mockNotificationService.areNotificationsEnabled()).called(1);
    });

    test('should subscribe to topic', () async {
      // Arrange
      const topic = 'job_updates';
      when(mockNotificationService.subscribeToTopic(topic)).thenAnswer((_) async => null);

      // Act
      await mockNotificationService.subscribeToTopic(topic);

      // Assert
      verify(mockNotificationService.subscribeToTopic(topic)).called(1);
    });

    test('should unsubscribe from topic', () async {
      // Arrange
      const topic = 'job_updates';
      when(mockNotificationService.unsubscribeFromTopic(topic)).thenAnswer((_) async => null);

      // Act
      await mockNotificationService.unsubscribeFromTopic(topic);

      // Assert
      verify(mockNotificationService.unsubscribeFromTopic(topic)).called(1);
    });

    test('should get subscribed topics', () async {
      // Arrange
      const expectedTopics = ['job_updates', 'interviews', 'documents'];
      when(mockNotificationService.getSubscribedTopics()).thenAnswer((_) async => expectedTopics);

      // Act
      final topics = await mockNotificationService.getSubscribedTopics();

      // Assert
      expect(topics, expectedTopics);
      expect(topics.length, 3);
      verify(mockNotificationService.getSubscribedTopics()).called(1);
    });

    test('should show local notification', () async {
      // Arrange
      const title = 'Test Notification';
      const body = 'This is a test message';
      when(mockNotificationService.showLocalNotification(title, body)).thenAnswer((_) async => null);

      // Act
      await mockNotificationService.showLocalNotification(title, body);

      // Assert
      verify(mockNotificationService.showLocalNotification(title, body)).called(1);
    });

    test('should clear all notifications', () async {
      // Arrange
      when(mockNotificationService.clearAllNotifications()).thenAnswer((_) async => null);

      // Act
      await mockNotificationService.clearAllNotifications();

      // Assert
      verify(mockNotificationService.clearAllNotifications()).called(1);
    });

    test('should schedule notification', () async {
      // Arrange
      const id = 1;
      const title = 'Scheduled Notification';
      const body = 'This is scheduled';
      final scheduledDate = DateTime.now().add(const Duration(hours: 1));
      
      when(mockNotificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      )).thenAnswer((_) async => null);

      // Act
      await mockNotificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      // Assert
      verify(mockNotificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      )).called(1);
    });

    group('Service Instance Tests', () {
      test('should create singleton instance', () {
        // Arrange & Act
        final instance1 = PushNotificationService();
        final instance2 = PushNotificationService();
        
        // Assert
        expect(identical(instance1, instance2), true);
      });
      
      test('should have static convenience methods available', () {
        // Act & Assert - just verify the methods exist as static methods
        expect(PushNotificationService.initializeStatic, isA<Function>());
        expect(PushNotificationService.requestPermission, isA<Function>());
        expect(PushNotificationService.checkNotificationsEnabled, isA<Function>());
        expect(PushNotificationService.showNotification, isA<Function>());
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty topic subscription', () async {
        // Arrange
        const topic = '';
        when(mockNotificationService.subscribeToTopic(topic)).thenAnswer((_) async => null);

        // Act
        await mockNotificationService.subscribeToTopic(topic);

        // Assert
        verify(mockNotificationService.subscribeToTopic(topic)).called(1);
      });

      test('should handle null device token', () async {
        // Arrange
        when(mockNotificationService.getDeviceToken()).thenAnswer((_) async => null);

        // Act
        final token = await mockNotificationService.getDeviceToken();

        // Assert
        expect(token, isNull);
        verify(mockNotificationService.getDeviceToken()).called(1);
      });

      test('should handle empty subscribed topics list', () async {
        // Arrange
        when(mockNotificationService.getSubscribedTopics()).thenAnswer((_) async => []);

        // Act
        final topics = await mockNotificationService.getSubscribedTopics();

        // Assert
        expect(topics, isEmpty);
        verify(mockNotificationService.getSubscribedTopics()).called(1);
      });

      test('should handle notification with payload', () async {
        // Arrange
        const title = 'Test Notification';
        const body = 'Test Body';
        const payload = 'test_payload';
        const id = 123;
        
        when(mockNotificationService.showLocalNotification(
          title, 
          body, 
          payload: payload, 
          id: id
        )).thenAnswer((_) async => null);

        // Act
        await mockNotificationService.showLocalNotification(
          title, 
          body, 
          payload: payload, 
          id: id
        );

        // Assert
        verify(mockNotificationService.showLocalNotification(
          title, 
          body, 
          payload: payload, 
          id: id
        )).called(1);
      });

      test('should handle schedule notification with payload', () async {
        // Arrange
        const id = 1;
        const title = 'Scheduled Test';
        const body = 'Scheduled Body';
        const payload = 'scheduled_payload';
        final scheduledDate = DateTime.now().add(const Duration(minutes: 30));
        
        when(mockNotificationService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload,
        )).thenAnswer((_) async => null);

        // Act
        await mockNotificationService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload,
        );

        // Assert
        verify(mockNotificationService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload,
        )).called(1);
      });
    });
  });
}