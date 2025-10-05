import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/services/notification_service.dart'
    as local_notifications;
import '../../domain/models/notification_model.dart';

class NotificationService {
  static final Logger _logger = Logger();
  static const String _storageKey = 'notifications';

  // Create a notification
  static Future<NotificationModel> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? recipientId,
    String? senderId,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionText,
  }) async {
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        title: title,
        message: message,
        type: type,
        priority: priority,
        recipientId: recipientId,
        senderId: senderId,
        createdAt: DateTime.now(),
        data: data,
        actionUrl: actionUrl,
        actionText: actionText,
      );

      // Save to local storage
      await _saveNotification(notification);

      // Send push notification if high priority
      if (priority == NotificationPriority.high ||
          priority == NotificationPriority.urgent) {
        await local_notifications.NotificationService.showNotification(
          id: notification.id.hashCode,
          title: title,
          body: message,
          payload: notification.id,
        );
      }

      _logger.i('Notification created: ${notification.id}');
      return notification;
    } catch (e) {
      _logger.e('Error creating notification: $e');
      rethrow;
    }
  }

  // Get notifications for a user
  static Future<List<NotificationModel>> getNotificationsForUser({
    required String userId,
    NotificationType? type,
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      final notifications = await _getAllNotifications();

      var filteredNotifications = notifications
          .where((notification) =>
              notification.recipientId == userId ||
              notification.recipientId == null) // Global notifications
          .toList();

      // Apply filters
      if (type != null) {
        filteredNotifications = filteredNotifications
            .where((notification) => notification.type == type)
            .toList();
      }

      if (unreadOnly == true) {
        filteredNotifications = filteredNotifications
            .where((notification) => !notification.isRead)
            .toList();
      }

      // Sort by creation date (newest first)
      filteredNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply limit
      if (limit != null && limit > 0) {
        filteredNotifications = filteredNotifications.take(limit).toList();
      }

      return filteredNotifications;
    } catch (e) {
      _logger.e('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final notifications = await _getAllNotifications();
      final notificationIndex = notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );

      if (notificationIndex == -1) {
        _logger.w('Notification not found: $notificationId');
        return false;
      }

      notifications[notificationIndex] =
          notifications[notificationIndex].markAsRead();
      await StorageService.put(
          _storageKey, notifications.map((n) => n.toMap()).toList());

      _logger.i('Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read for a user
  static Future<bool> markAllAsRead(String userId) async {
    try {
      final notifications = await _getAllNotifications();

      for (int i = 0; i < notifications.length; i++) {
        if ((notifications[i].recipientId == userId ||
                notifications[i].recipientId == null) &&
            !notifications[i].isRead) {
          notifications[i] = notifications[i].markAsRead();
        }
      }

      await StorageService.put(
          _storageKey, notifications.map((n) => n.toMap()).toList());

      _logger.i('All notifications marked as read for user: $userId');
      return true;
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final notifications = await _getAllNotifications();
      notifications
          .removeWhere((notification) => notification.id == notificationId);

      await StorageService.put(
          _storageKey, notifications.map((n) => n.toMap()).toList());

      _logger.i('Notification deleted: $notificationId');
      return true;
    } catch (e) {
      _logger.e('Error deleting notification: $e');
      return false;
    }
  }

  // Get unread count for a user
  static Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotificationsForUser(
        userId: userId,
        unreadOnly: true,
      );
      return notifications.length;
    } catch (e) {
      _logger.e('Error getting unread count: $e');
      return 0;
    }
  }

  // Create notification for document events
  static Future<void> createDocumentNotification({
    required String recipientId,
    required String documentName,
    required String action,
    String? additionalInfo,
  }) async {
    String title;
    String message;
    NotificationType type = NotificationType.document;
    NotificationPriority priority = NotificationPriority.normal;

    switch (action.toLowerCase()) {
      case 'uploaded':
        title = 'Document Uploaded';
        message = '$documentName has been uploaded and is pending review.';
        break;
      case 'approved':
        title = 'Document Approved';
        message = '$documentName has been approved by HR.';
        priority = NotificationPriority.low;
        break;
      case 'rejected':
        title = 'Document Rejected';
        message =
            '$documentName has been rejected. ${additionalInfo ?? 'Please check the rejection reason.'}';
        priority = NotificationPriority.high;
        break;
      case 'expiring':
        title = 'Document Expiring Soon';
        message =
            '$documentName will expire in 30 days. Please upload a new version.';
        priority = NotificationPriority.high;
        break;
      case 'expired':
        title = 'Document Expired';
        message = '$documentName has expired. Please upload a new version.';
        priority = NotificationPriority.urgent;
        break;
      default:
        title = 'Document Update';
        message = '$documentName has been updated.';
    }

    await createNotification(
      title: title,
      message: message,
      type: type,
      priority: priority,
      recipientId: recipientId,
      actionUrl: '/applicant-documents',
      actionText: 'View Documents',
    );
  }

  // Create notification for application events
  static Future<void> createApplicationNotification({
    required String recipientId,
    required String applicationTitle,
    required String action,
    String? additionalInfo,
  }) async {
    String title;
    String message;
    NotificationType type = NotificationType.application;
    NotificationPriority priority = NotificationPriority.normal;

    switch (action.toLowerCase()) {
      case 'submitted':
        title = 'Application Submitted';
        message =
            'Your application for $applicationTitle has been submitted successfully.';
        break;
      case 'reviewed':
        title = 'Application Reviewed';
        message =
            'Your application for $applicationTitle has been reviewed. ${additionalInfo ?? ''}';
        break;
      case 'interview_scheduled':
        title = 'Interview Scheduled';
        message =
            'An interview has been scheduled for your application to $applicationTitle.';
        priority = NotificationPriority.high;
        break;
      case 'hired':
        title = 'Congratulations!';
        message = 'Congratulations! You have been hired for $applicationTitle.';
        priority = NotificationPriority.high;
        break;
      case 'rejected':
        title = 'Application Update';
        message =
            'Your application for $applicationTitle has been declined. ${additionalInfo ?? ''}';
        priority = NotificationPriority.normal;
        break;
      default:
        title = 'Application Update';
        message = 'Your application for $applicationTitle has been updated.';
    }

    await createNotification(
      title: title,
      message: message,
      type: type,
      priority: priority,
      recipientId: recipientId,
      actionUrl: '/applicant-dashboard',
      actionText: 'View Application',
    );
  }

  // Create system notification
  static Future<void> createSystemNotification({
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
    String? actionUrl,
    String? actionText,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.system,
      priority: priority,
      actionUrl: actionUrl,
      actionText: actionText,
    );
  }

  // Initialize with sample notifications
  static Future<void> initializeSampleNotifications() async {
    try {
      final existingNotifications = await _getAllNotifications();
      if (existingNotifications.isNotEmpty) return;

      final sampleNotifications = [
        NotificationModel(
          id: const Uuid().v4(),
          title: 'Welcome to CareConnect',
          message:
              'Welcome to CareConnect HR! Your account has been created successfully.',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          isRead: true,
          actionUrl: '/applicant-dashboard',
          actionText: 'Get Started',
        ),
        NotificationModel(
          id: const Uuid().v4(),
          title: 'Document Uploaded',
          message: 'Your resume has been uploaded and is pending review.',
          type: NotificationType.document,
          priority: NotificationPriority.normal,
          recipientId: 'applicant1',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          isRead: true,
          actionUrl: '/applicant-documents',
          actionText: 'View Documents',
        ),
        NotificationModel(
          id: const Uuid().v4(),
          title: 'Interview Scheduled',
          message:
              'An interview has been scheduled for your application to Nurse position.',
          type: NotificationType.interview,
          priority: NotificationPriority.high,
          recipientId: 'applicant1',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: false,
          actionUrl: '/applicant-dashboard',
          actionText: 'View Details',
        ),
        NotificationModel(
          id: const Uuid().v4(),
          title: 'Document Expiring Soon',
          message:
              'Your certification will expire in 30 days. Please upload a new version.',
          type: NotificationType.reminder,
          priority: NotificationPriority.high,
          recipientId: 'applicant1',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          isRead: false,
          actionUrl: '/applicant-documents',
          actionText: 'Upload New Document',
        ),
      ];

      await StorageService.put(
          _storageKey, sampleNotifications.map((n) => n.toMap()).toList());
      _logger.i('Sample notifications initialized');
    } catch (e) {
      _logger.e('Error initializing sample notifications: $e');
    }
  }

  // Private methods
  static Future<void> _saveNotification(NotificationModel notification) async {
    final notifications = await _getAllNotifications();
    notifications.add(notification);
    await StorageService.put(
        _storageKey, notifications.map((n) => n.toMap()).toList());
  }

  static Future<List<NotificationModel>> _getAllNotifications() async {
    try {
      final notificationsData = StorageService.get<List>(_storageKey);
      if (notificationsData == null) {
        return [];
      }

      return notificationsData
          .map((data) =>
              NotificationModel.fromMap(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      _logger.e('Error getting notifications: $e');
      return [];
    }
  }
}
