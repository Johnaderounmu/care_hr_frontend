import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 4)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final NotificationType type;

  @HiveField(4)
  final NotificationPriority priority;

  @HiveField(5)
  final String? recipientId;

  @HiveField(6)
  final String? senderId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? readAt;

  @HiveField(9)
  final bool isRead;

  @HiveField(10)
  final Map<String, dynamic>? data;

  @HiveField(11)
  final String? actionUrl;

  @HiveField(12)
  final String? actionText;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    this.recipientId,
    this.senderId,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    this.data,
    this.actionUrl,
    this.actionText,
  });

  // Create NotificationModel from Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.fromString(map['type'] ?? 'general'),
      priority: NotificationPriority.fromString(map['priority'] ?? 'normal'),
      recipientId: map['recipientId'],
      senderId: map['senderId'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      isRead: map['isRead'] ?? false,
      data: map['data'],
      actionUrl: map['actionUrl'],
      actionText: map['actionText'],
    );
  }

  // Convert NotificationModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'recipientId': recipientId,
      'senderId': senderId,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'actionUrl': actionUrl,
      'actionText': actionText,
    };
  }

  // Copy with method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    String? recipientId,
    String? senderId,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionText,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 5)
enum NotificationType {
  @HiveField(0)
  general,

  @HiveField(1)
  application,

  @HiveField(2)
  document,

  @HiveField(3)
  interview,

  @HiveField(4)
  reminder,

  @HiveField(5)
  system,

  @HiveField(6)
  security;

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'general':
        return NotificationType.general;
      case 'application':
        return NotificationType.application;
      case 'document':
        return NotificationType.document;
      case 'interview':
        return NotificationType.interview;
      case 'reminder':
        return NotificationType.reminder;
      case 'system':
        return NotificationType.system;
      case 'security':
        return NotificationType.security;
      default:
        return NotificationType.general;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.application:
        return 'Application';
      case NotificationType.document:
        return 'Document';
      case NotificationType.interview:
        return 'Interview';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.system:
        return 'System';
      case NotificationType.security:
        return 'Security';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.general:
        return 'notifications';
      case NotificationType.application:
        return 'description';
      case NotificationType.document:
        return 'folder';
      case NotificationType.interview:
        return 'event';
      case NotificationType.reminder:
        return 'schedule';
      case NotificationType.system:
        return 'settings';
      case NotificationType.security:
        return 'security';
    }
  }
}

@HiveType(typeId: 6)
enum NotificationPriority {
  @HiveField(0)
  low,

  @HiveField(1)
  normal,

  @HiveField(2)
  high,

  @HiveField(3)
  urgent;

  static NotificationPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}

