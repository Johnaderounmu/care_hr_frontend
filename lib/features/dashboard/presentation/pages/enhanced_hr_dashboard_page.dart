import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/job_provider.dart';
import '../../../../core/providers/document_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/quick_action_button.dart';
import '../../../../core/widgets/app_header.dart';

class EnhancedHRDashboardPage extends StatefulWidget {
  const EnhancedHRDashboardPage({super.key});

  @override
  State<EnhancedHRDashboardPage> createState() => _EnhancedHRDashboardPageState();
}

class _EnhancedHRDashboardPageState extends State<EnhancedHRDashboardPage> {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      await Future.wait([
        jobProvider.loadJobs(),
        documentProvider.loadDocuments(),
        notificationProvider.loadNotifications(),
      ]);
    } catch (e) {
      debugPrint('Dashboard data loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  title: AppStrings.dashboardTitle,
                  subtitle: 'Welcome back, ${authProvider.user?.fullName ?? "HR Admin"}',
                  user: authProvider.user,
                ),

                // Dashboard Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _loadDashboardData,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Cards
                                _buildStatsCards(),

                                const SizedBox(height: 32),

                                // Charts Section
                                _buildChartsSection(),

                                const SizedBox(height: 32),

                                // Quick Actions
                                _buildQuickActions(),

                                const SizedBox(height: 32),

                                // Recent Activity
                                _buildRecentActivity(),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer3<JobProvider, DocumentProvider, NotificationProvider>(
      builder: (context, jobProvider, documentProvider, notificationProvider, child) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4.0,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            DashboardCard(
              title: 'Active Jobs',
              value: jobProvider.activeJobsCount.toString(),
              icon: Icons.work,
              color: AppColors.primary,
              onTap: () => context.go('/job-listing'),
            ),
            DashboardCard(
              title: 'Pending Documents',
              value: documentProvider.pendingDocumentsCount.toString(),
              icon: Icons.description,
              color: AppColors.warning,
              onTap: () => context.go('/hr-document-review'),
            ),
            DashboardCard(
              title: 'Unread Notifications',
              value: notificationProvider.unreadCount.toString(),
              icon: Icons.notifications,
              color: AppColors.error,
              onTap: () => context.go('/notifications'),
            ),
            DashboardCard(
              title: 'Total Applications',
              value: _analyticsData?['totalApplications']?.toString() ?? '0',
              icon: Icons.people,
              color: AppColors.success,
              onTap: () => context.go('/applications'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.0,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ChartCard(
              title: 'Applications Trend',
              value: '${_analyticsData?['totalApplications'] ?? 0}',
              subtitle: 'Total applications',
              period: 'Last 30 Days',
              chart: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.3), AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            ChartCard(
              title: 'Document Status',
              value: '${_analyticsData?['pendingDocuments'] ?? 0}',
              subtitle: 'Pending review',
              period: 'Current Status',
              chart: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning.withOpacity(0.3), AppColors.warning],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            QuickActionButton(
              text: 'Create Job',
              icon: Icons.add_business,
              onPressed: () => context.go('/create-job'),
            ),
            QuickActionButton(
              text: 'Schedule Interview',
              icon: Icons.calendar_today,
              onPressed: () => context.go('/schedule-interview'),
            ),
            QuickActionButton(
              text: 'Review Documents',
              icon: Icons.folder_open,
              onPressed: () => context.go('/hr-document-review'),
            ),
            QuickActionButton(
              text: 'View Reports',
              icon: Icons.assessment,
              onPressed: () => context.go('/reports'),
            ),
            QuickActionButton(
              text: 'Analytics Dashboard',
              icon: Icons.analytics,
              onPressed: () => context.go('/analytics'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final recentNotifications = notificationProvider.getRecentNotifications(days: 3);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/notifications'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentNotifications.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              )
            else
              ...recentNotifications.take(5).map((notification) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getNotificationIcon(notification.type),
                        color: AppColors.primary,
                      ),
                      title: Text(notification.title),
                      subtitle: Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTime(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => notificationProvider.markAsRead(notification.id),
                    ),
                  )),
          ],
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'application_submitted':
        return Icons.person_add;
      case 'document_reviewed':
        return Icons.description;
      case 'interview_scheduled':
        return Icons.calendar_today;
      case 'job_posted':
        return Icons.work;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}