import 'package:flutter/material.dart';

import '../../domain/models/notification_model.dart';

class NotificationFilter extends StatelessWidget {
  final NotificationType? selectedType;
  final bool unreadOnly;
  final ValueChanged<NotificationType?>? onTypeChanged;
  final ValueChanged<bool>? onUnreadOnlyChanged;

  const NotificationFilter({
    super.key,
    this.selectedType,
    this.unreadOnly = false,
    this.onTypeChanged,
    this.onUnreadOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Type Dropdown
        Expanded(
          child: DropdownButton<NotificationType?>(
            value: selectedType,
            hint: const Text('All types'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<NotificationType?>(
                value: null,
                child: Text('All'),
              ),
              ...NotificationType.values.map(
                (t) => DropdownMenuItem<NotificationType?>(
                  value: t,
                  child: Text(t.displayName),
                ),
              ),
            ],
            onChanged: onTypeChanged,
          ),
        ),
        const SizedBox(width: 12),

        // Unread only switch
        Row(
          children: [
            const Text('Unread only'),
            const SizedBox(width: 8),
            Switch(
              value: unreadOnly,
              onChanged: onUnreadOnlyChanged,
            ),
          ],
        ),
      ],
    );
  }
}
