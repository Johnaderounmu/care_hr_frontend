import 'package:flutter/material.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _jobApplications = true;
  bool _interviewReminders = true;
  bool _documentUpdates = true;
  bool _systemAnnouncements = false;
  bool _marketingEmails = false;
  
  final Map<String, bool> _topicSubscriptions = {
    'job_applications': true,
    'interviews': true,
    'documents': true,
    'hr_announcements': false,
    'marketing': false,
  };

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await PushNotificationService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await PushNotificationService.requestPermission();
      setState(() {
        _notificationsEnabled = granted;
      });
      
      if (!granted) {
        _showPermissionDialog();
        return;
      }
    }
    
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updateTopicSubscription(String topic, bool subscribe) async {
    try {
      if (subscribe) {
        await PushNotificationService.subscribeToTopic(topic);
      } else {
        await PushNotificationService.unsubscribeFromTopic(topic);
      }
      
      setState(() {
        _topicSubscriptions[topic] = subscribe;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(subscribe 
              ? 'Subscribed to $topic notifications' 
              : 'Unsubscribed from $topic notifications'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update subscription: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications Permission'),
        content: const Text(
          'To receive notifications, please enable them in your device settings. '
          'Go to Settings > Apps > Care HR > Notifications and enable notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with notification status
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _notificationsEnabled 
                          ? Icons.notifications_active 
                          : Icons.notifications_off,
                      color: _notificationsEnabled 
                          ? AppColors.success 
                          : AppColors.error,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _notificationsEnabled 
                                ? 'Notifications Enabled' 
                                : 'Notifications Disabled',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _notificationsEnabled 
                                ? 'You\'ll receive important updates' 
                                : 'Enable to receive important updates',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notification Categories
            Text(
              'Notification Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Job Applications
            _buildNotificationTile(
              icon: Icons.work,
              title: 'Job Applications',
              subtitle: 'Updates about your job applications',
              value: _jobApplications,
              onChanged: _notificationsEnabled ? (value) {
                setState(() => _jobApplications = value);
                _updateTopicSubscription('job_applications', value);
              } : null,
            ),
            
            // Interview Reminders
            _buildNotificationTile(
              icon: Icons.calendar_today,
              title: 'Interview Reminders',
              subtitle: 'Upcoming interview notifications',
              value: _interviewReminders,
              onChanged: _notificationsEnabled ? (value) {
                setState(() => _interviewReminders = value);
                _updateTopicSubscription('interviews', value);
              } : null,
            ),
            
            // Document Updates
            _buildNotificationTile(
              icon: Icons.description,
              title: 'Document Updates',
              subtitle: 'Document approval and rejection notifications',
              value: _documentUpdates,
              onChanged: _notificationsEnabled ? (value) {
                setState(() => _documentUpdates = value);
                _updateTopicSubscription('documents', value);
              } : null,
            ),
            
            // System Announcements
            _buildNotificationTile(
              icon: Icons.campaign,
              title: 'System Announcements',
              subtitle: 'Important system updates and announcements',
              value: _systemAnnouncements,
              onChanged: _notificationsEnabled ? (value) {
                setState(() => _systemAnnouncements = value);
                _updateTopicSubscription('hr_announcements', value);
              } : null,
            ),
            
            // Marketing Emails
            _buildNotificationTile(
              icon: Icons.email,
              title: 'Marketing Communications',
              subtitle: 'Job recommendations and company news',
              value: _marketingEmails,
              onChanged: _notificationsEnabled ? (value) {
                setState(() => _marketingEmails = value);
                _updateTopicSubscription('marketing', value);
              } : null,
            ),
            
            const SizedBox(height: 32),
            
            // Device Token Info (Debug/Development)
            if (PushNotificationService.deviceToken != null)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Device Token (Debug)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          PushNotificationService.deviceToken!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : Colors.grey[400],
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}