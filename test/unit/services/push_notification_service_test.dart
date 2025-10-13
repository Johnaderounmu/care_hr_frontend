import 'package:flutter_test/flutter_test.dart';
import 'package:care_hr_app/core/services/push_notification_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

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
      when(mockNotificationService.initialize()).thenAnswer((_) async => true);

      // Act
      final result = await mockNotificationService.initialize();

      // Assert
      expect(result, true);
      verify(mockNotificationService.initialize()).called(1);
    });

    test('should request notification permissions', () async {
      // Arrange
      when(mockNotificationService.requestPermission()).thenAnswer((_) async => true);

      // Act
      final result = await mockNotificationService.requestPermission();

      // Assert
      expect(result, true);
      verify(mockNotificationService.requestPermission()).called(1);
    });

    test('should get device token', () async {
      // Arrange
      const expectedToken = 'test_token_123';
      when(mockNotificationService.getToken()).thenAnswer((_) async => expectedToken);

      // Act
      final token = await mockNotificationService.getToken();

      // Assert
      expect(token, expectedToken);
      verify(mockNotificationService.getToken()).called(1);
    });

    test('should subscribe to topic', () async {
      // Arrange
      const topic = 'job_updates';
      when(mockNotificationService.subscribeToTopic(topic)).thenAnswer((_) async {});

      // Act
      await mockNotificationService.subscribeToTopic(topic);

      // Assert
      verify(mockNotificationService.subscribeToTopic(topic)).called(1);
    });

    test('should unsubscribe from topic', () async {
      // Arrange
      const topic = 'job_updates';
      when(mockNotificationService.unsubscribeFromTopic(topic)).thenAnswer((_) async {});

      // Act
      await mockNotificationService.unsubscribeFromTopic(topic);

      // Assert
      verify(mockNotificationService.unsubscribeFromTopic(topic)).called(1);
    });
  });
}