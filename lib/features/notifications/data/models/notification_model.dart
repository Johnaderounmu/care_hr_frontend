class NotificationModel {
  final String id;
  final String? recipientId; // null means global
  final String? senderId;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? actionText;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.recipientId,
    this.senderId,
  required this.title,
  required this.message,
    DateTime? createdAt,
    this.type = NotificationType.document,
    this.priority = NotificationPriority.normal,
    this.data,
    this.actionUrl,
    this.actionText,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationModel markAsRead() {
    return NotificationModel(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      title: title,
  message: message,
      createdAt: createdAt,
      type: type,
      priority: priority,
      data: data,
      actionUrl: actionUrl,
      actionText: actionText,
      isRead: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'senderId': senderId,
      'title': title,
  'message': message,
      'createdAt': createdAt.toIso8601String(),
      'type': type.index,
      'priority': priority.index,
      'data': data,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      recipientId: map['recipientId'] as String?,
      senderId: map['senderId'] as String?,
      title: map['title'] as String? ?? '',
  message: map['message'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      type: NotificationType.values[map['type'] as int],
      priority: NotificationPriority.values[map['priority'] as int],
      data: (map['data'] as Map?)?.cast<String, dynamic>(),
      actionUrl: map['actionUrl'] as String?,
      actionText: map['actionText'] as String?,
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}

enum NotificationType { document, application, interview, system, reminder }

enum NotificationPriority { low, normal, high, urgent }
