import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/notification_model.dart';

class NotificationFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final NotificationType? type;
  final NotificationPriority? priority;
  final int? count;

  const NotificationFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.type,
    this.priority,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null) ...[
              Icon(
                _getIconForType(type!),
                size: 14,
                color: isSelected ? Colors.white : _getTypeColor(type!),
              ),
              const SizedBox(width: 6),
            ],
            if (priority != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.white : _getPriorityColor(priority!),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.application:
        return Icons.description;
      case NotificationType.document:
        return Icons.folder;
      case NotificationType.interview:
        return Icons.event;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.security:
        return Icons.security;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return AppColors.primary;
      case NotificationType.application:
        return AppColors.info;
      case NotificationType.document:
        return AppColors.success;
      case NotificationType.interview:
        return AppColors.warning;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.mutedLight;
      case NotificationType.security:
        return AppColors.error;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return AppColors.error;
      case NotificationPriority.high:
        return AppColors.warning;
      case NotificationPriority.normal:
        return AppColors.primary;
      case NotificationPriority.low:
        return AppColors.mutedLight;
    }
  }
}

class NotificationPriorityChip extends StatelessWidget {
  final NotificationPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationPriorityChip({
    super.key,
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _getPriorityColor() : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _getPriorityColor()
                : _getPriorityColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : _getPriorityColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              priority.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : _getPriorityColor(),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority) {
      case NotificationPriority.urgent:
        return AppColors.error;
      case NotificationPriority.high:
        return AppColors.warning;
      case NotificationPriority.normal:
        return AppColors.primary;
      case NotificationPriority.low:
        return AppColors.mutedLight;
    }
  }
}

class NotificationTypeChip extends StatelessWidget {
  final NotificationType type;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const NotificationTypeChip({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _getTypeColor() : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? _getTypeColor() : _getTypeColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForType(),
              size: 14,
              color: isSelected ? Colors.white : _getTypeColor(),
            ),
            const SizedBox(width: 6),
            Text(
              type.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : _getTypeColor(),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : _getTypeColor(),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType() {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.application:
        return Icons.description;
      case NotificationType.document:
        return Icons.folder;
      case NotificationType.interview:
        return Icons.event;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.security:
        return Icons.security;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case NotificationType.general:
        return AppColors.primary;
      case NotificationType.application:
        return AppColors.info;
      case NotificationType.document:
        return AppColors.success;
      case NotificationType.interview:
        return AppColors.warning;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.mutedLight;
      case NotificationType.security:
        return AppColors.error;
    }
  }
}

