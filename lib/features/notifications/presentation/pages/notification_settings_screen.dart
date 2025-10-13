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
  String? _deviceToken;
  bool _isLoading = true;
  bool _isUpdating = false;
  
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
    _loadDeviceToken();
  }

  Future<void> _checkNotificationStatus() async {
    try {
      final service = PushNotificationService();
      final enabled = await service.areNotificationsEnabled();
      final subscribedTopics = await service.getSubscribedTopics();
      
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
          _isLoading = false;
          
          // Update topic subscriptions from server
          for (final topic in subscribedTopics) {
            if (_topicSubscriptions.containsKey(topic)) {
              _topicSubscriptions[topic] = true;
            }
          }
          
          // Update individual boolean flags
          _jobApplications = _topicSubscriptions['job_applications'] ?? false;
          _interviewReminders = _topicSubscriptions['interviews'] ?? false;
          _documentUpdates = _topicSubscriptions['documents'] ?? false;
          _systemAnnouncements = _topicSubscriptions['hr_announcements'] ?? false;
          _marketingEmails = _topicSubscriptions['marketing'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDeviceToken() async {
    final service = PushNotificationService();
    final token = await service.getDeviceToken();
    if (mounted) {
      setState(() {
        _deviceToken = token;
      });
    }
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
    if (!mounted || _isUpdating) return;
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final service = PushNotificationService();
      if (subscribe) {
        await service.subscribeToTopic(topic);
      } else {
        await service.unsubscribeFromTopic(topic);
      }
      
      if (mounted) {
        setState(() {
          _topicSubscriptions[topic] = subscribe;
          _isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subscribe 
                ? 'Subscribed to ${_getTopicDisplayName(topic)} notifications' 
                : 'Unsubscribed from ${_getTopicDisplayName(topic)} notifications'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subscription: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  String _getTopicDisplayName(String topic) {
    switch (topic) {
      case 'job_applications':
        return 'Job Applications';
      case 'interviews':
        return 'Interviews';
      case 'documents':
        return 'Documents';
      case 'hr_announcements':
        return 'System Announcements';
      case 'marketing':
        return 'Marketing';
      default:
        return topic;
    }
  }

  Future<void> _refreshSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    await _checkNotificationStatus();
    await _loadDeviceToken();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    if (_isUpdating) return;
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final service = PushNotificationService();
      await service.showLocalNotification(
        'Test Notification',
        'This is a test notification from Care HR app! 🎉',
        payload: '{"type":"test","timestamp":"${DateTime.now().toIso8601String()}"}',
        id: DateTime.now().millisecondsSinceEpoch % 100000,
      );
      
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test notification sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send test notification: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSettings,
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading notification settings...'),
              ],
            ),
          )
        : SingleChildScrollView(
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
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: Colors.white,
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
              onChanged: _notificationsEnabled && !_isUpdating ? (value) {
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
              onChanged: _notificationsEnabled && !_isUpdating ? (value) {
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
              onChanged: _notificationsEnabled && !_isUpdating ? (value) {
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
              onChanged: _notificationsEnabled && !_isUpdating ? (value) {
                setState(() => _systemAnnouncements = value);
                _updateTopicSubscription('hr_announcements', value);
              } : null,
            ),
            
            // Marketing Communications
            _buildNotificationTile(
              icon: Icons.email,
              title: 'Marketing Communications',
              subtitle: 'Job recommendations and company news',
              value: _marketingEmails,
              onChanged: _notificationsEnabled && !_isUpdating ? (value) {
                setState(() => _marketingEmails = value);
                _updateTopicSubscription('marketing', value);
              } : null,
            ),
            
            const SizedBox(height: 24),
            
            // Test Notification Button
            if (_notificationsEnabled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Notifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Send a test notification to verify settings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : _sendTestNotification,
                          icon: const Icon(Icons.send),
                          label: const Text('Send Test Notification'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Device Token Info (Debug/Development)
            if (_deviceToken != null)
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
                            'Device ID (Debug)',
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
                        child: SelectableText(
                          _deviceToken!,
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
        activeTrackColor: AppColors.primary,
        activeThumbColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}