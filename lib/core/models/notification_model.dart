import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 12)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String type; // application_submitted, application_status_changed, interview_scheduled, document_reviewed, job_posted, system_announcement

  @HiveField(4)
  final String priority; // low, medium, high, urgent

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final String? triggeredById;

  @HiveField(9)
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    this.metadata,
    required this.userId,
    this.triggeredById,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'medium',
      isRead: json['isRead'] ?? false,
      metadata: json['metadata'],
      userId: json['userId'] ?? '',
      triggeredById: json['triggeredById'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'isRead': isRead,
      'metadata': metadata,
      'userId': userId,
      'triggeredById': triggeredById,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get typeDisplayName {
    switch (type) {
      case 'application_submitted':
        return 'Application';
      case 'application_status_changed':
        return 'Status Update';
      case 'interview_scheduled':
        return 'Interview';
      case 'document_reviewed':
        return 'Document';
      case 'job_posted':
        return 'Job Posted';
      case 'system_announcement':
        return 'Announcement';
      default:
        return 'Notification';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Normal';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}