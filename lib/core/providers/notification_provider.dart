import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/enhanced_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  int _currentPage = 1;
  bool _hasMoreNotifications = true;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasMoreNotifications => _hasMoreNotifications;

  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications => 
      _notifications.where((n) => n.isRead).toList();

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
      _hasMoreNotifications = true;
    }

    if (!_hasMoreNotifications) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await EnhancedApiService.getNotifications(
        page: _currentPage,
        limit: 20,
      );
      
      if (result != null) {
        final List<dynamic> notificationsData = result['notifications'] ?? [];
        final newNotifications = notificationsData
            .map((data) => NotificationModel.fromJson(data))
            .toList();

        if (refresh) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        _currentPage++;
        _hasMoreNotifications = newNotifications.length == 20; // If we got a full page, there might be more

        // Update unread count
        await _updateUnreadCount();
      }
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await EnhancedApiService.getNotifications(
        page: 1,
        limit: 50,
        unreadOnly: true,
      );
      
      if (result != null) {
        final List<dynamic> notificationsData = result['notifications'] ?? [];
        final unreadNotifications = notificationsData
            .map((data) => NotificationModel.fromJson(data))
            .toList();

        // Merge with existing notifications
        for (final notification in unreadNotifications) {
          final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
          if (existingIndex == -1) {
            _notifications.insert(0, notification);
          } else {
            _notifications[existingIndex] = notification;
          }
        }

        _sortNotifications();
        await _updateUnreadCount();
      }
    } catch (e) {
      _error = 'Failed to load unread notifications: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await EnhancedApiService.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update local notification
        final notificationIndex = _notifications.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          final updatedNotification = NotificationModel(
            id: _notifications[notificationIndex].id,
            title: _notifications[notificationIndex].title,
            message: _notifications[notificationIndex].message,
            type: _notifications[notificationIndex].type,
            priority: _notifications[notificationIndex].priority,
            isRead: true,
            metadata: _notifications[notificationIndex].metadata,
            userId: _notifications[notificationIndex].userId,
            triggeredById: _notifications[notificationIndex].triggeredById,
            createdAt: _notifications[notificationIndex].createdAt,
          );
          _notifications[notificationIndex] = updatedNotification;
          await _updateUnreadCount();
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: ${e.toString()}';
      notifyListeners();
    }
    return false;
  }

  Future<bool> markAllAsRead() async {
    try {
      // This would need to be implemented in the API service
      // For now, mark all local notifications as read
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          await markAsRead(_notifications[i].id);
        }
      }
      return true;
    } catch (e) {
      _error = 'Failed to mark all notifications as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await EnhancedApiService.getUnreadNotificationCount();
    } catch (e) {
      // Fallback to local count
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    }
  }

  void _sortNotifications() {
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }

  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<NotificationModel> getHighPriorityNotifications() {
    return _notifications.where((n) => n.priority == 'high' || n.priority == 'urgent').toList();
  }

  List<NotificationModel> getRecentNotifications({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _notifications.where((n) => n.createdAt.isAfter(cutoffDate)).toList();
  }

  void refresh() {
    loadNotifications(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}