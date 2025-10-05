import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/notification_model.dart';
import '../../data/services/notification_service.dart';
import '../widgets/notification_list_item.dart';
import '../widgets/notification_filter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  NotificationType? _typeFilter;
  bool _unreadOnly = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              children: [
                // Header
                AppHeader(
                  title: 'Notifications',
                  subtitle: 'Stay updated with your application progress',
                  user: authProvider.user,
                  showBackButton: true,
                  actions: [
                    if (_unreadCount > 0)
                      ElevatedButton(
                        onPressed: _markAllAsRead,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: Text('Mark All Read ($_unreadCount)'),
                      ),
                  ],
                ),

                // Content
                Expanded(
                  child: Column(
                    children: [
                      // Filters
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: NotificationFilter(
                          selectedType: _typeFilter,
                          unreadOnly: _unreadOnly,
                          onTypeChanged: (type) {
                            setState(() {
                              _typeFilter = type;
                            });
                            _loadNotifications();
                          },
                          onUnreadOnlyChanged: (unreadOnly) {
                            setState(() {
                              _unreadOnly = unreadOnly;
                            });
                            _loadNotifications();
                          },
                        ),
                      ),

                      // Notifications List
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                                ),
                              )
                            : _notifications.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    itemCount: _notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification =
                                          _notifications[index];
                                      return NotificationListItem(
                                        notification: notification,
                                        onTap: () => _handleNotificationTap(
                                            notification),
                                        onMarkAsRead: () =>
                                            _markAsRead(notification),
                                        onDelete: () =>
                                            _deleteNotification(notification),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _unreadOnly
                ? 'You have no unread notifications'
                : 'You have no notifications yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final notifications = await NotificationService.getNotificationsForUser(
          userId: userId,
          type: _typeFilter,
          unreadOnly: _unreadOnly,
        );

        final unreadCount = await NotificationService.getUnreadCount(userId);

        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read if unread
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Navigate to action URL if available
    if (notification.actionUrl != null) {
      // TODO: Navigate to action URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigate to: ${notification.actionUrl}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    final success = await NotificationService.markAsRead(notification.id);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.markAsRead();
        }
        if (_unreadCount > 0) {
          _unreadCount--;
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
      final success = await NotificationService.markAllAsRead(userId);
      if (success) {
        setState(() {
          _notifications = _notifications.map((n) => n.markAsRead()).toList();
          _unreadCount = 0;
        });
      }
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await NotificationService.deleteNotification(notification.id);
      if (success) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
          if (!notification.isRead) {
            _unreadCount--;
          }
        });
      }
    }
  }
}
