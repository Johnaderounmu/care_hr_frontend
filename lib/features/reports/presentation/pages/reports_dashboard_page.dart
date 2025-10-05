import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../data/services/report_service.dart';
import '../widgets/analytics_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/report_card.dart';

class ReportsDashboardPage extends StatefulWidget {
  const ReportsDashboardPage({super.key});

  @override
  State<ReportsDashboardPage> createState() => _ReportsDashboardPageState();
}

class _ReportsDashboardPageState extends State<ReportsDashboardPage> {
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analytics = await ReportService.getDashboardAnalytics();
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeader(
        title: 'Reports & Analytics',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/reports/generate-report'),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Cards
                    _buildOverviewSection(),

                    const SizedBox(height: 24),

                    // Charts Section
                    _buildChartsSection(),

                    const SizedBox(height: 24),

                    // Recent Reports
                    _buildRecentReportsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            AnalyticsCard(
              title: 'Total Applications',
              value: '${_analytics['totalApplications'] ?? 0}',
              icon: Icons.description,
              color: AppColors.primary,
              trend: '+12%',
              trendUp: true,
            ),
            AnalyticsCard(
              title: 'Active Jobs',
              value: '${_analytics['activeJobs'] ?? 0}',
              icon: Icons.work,
              color: AppColors.success,
              trend: '+8%',
              trendUp: true,
            ),
            AnalyticsCard(
              title: 'Active Users',
              value: '${_analytics['activeUsers'] ?? 0}',
              icon: Icons.people,
              color: AppColors.info,
              trend: '+5%',
              trendUp: true,
            ),
            AnalyticsCard(
              title: 'Pending Documents',
              value: '${_analytics['pendingDocuments'] ?? 0}',
              icon: Icons.folder_open,
              color: AppColors.warning,
              trend: '-3%',
              trendUp: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            ChartWidget(
              title: 'Applications by Status',
              chartType: 'pie',
              data: _analytics['applicationsByStatus'] ?? {},
              colors: const [
                AppColors.primary,
                AppColors.success,
                AppColors.warning,
                AppColors.error,
              ],
            ),
            ChartWidget(
              title: 'Users by Role',
              chartType: 'doughnut',
              data: _analytics['usersByRole'] ?? {},
              colors: const [
                AppColors.primary,
                AppColors.info,
                AppColors.success,
              ],
            ),
            ChartWidget(
              title: 'Jobs by Status',
              chartType: 'bar',
              data: _analytics['jobsByStatus'] ?? {},
              colors: const [
                AppColors.success,
                AppColors.warning,
                AppColors.mutedLight,
              ],
            ),
            ChartWidget(
              title: 'Monthly Applications',
              chartType: 'line',
              data: _analytics['applicationsByMonth'] ?? {},
              colors: const [AppColors.primary],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/reports/all-reports'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: ReportService.getAllReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading reports: ${snapshot.error}'),
              );
            }

            final reports = snapshot.data ?? [];
            final recentReports = reports.take(5).toList();

            if (recentReports.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reports generated yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate your first report to see analytics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5),
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/reports/generate-report'),
                      child: const Text('Generate Report'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentReports.length,
              itemBuilder: (context, index) {
                final report = recentReports[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReportCard(
                    report: report,
                    onTap: () =>
                        context.push('/reports/report-details/${report.id}'),
                    onDownload: () => _downloadReport(report),
                    onDelete: () => _deleteReport(report),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _downloadReport(report) {
    // TODO: Implement report download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
  }

  void _deleteReport(report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final scaffold = ScaffoldMessenger.of(context);
              try {
                await ReportService.deleteReport(report.id);
                if (mounted) {
                  _loadAnalytics();
                  scaffold.showSnackBar(
                    const SnackBar(
                        content: Text('Report deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Error deleting report: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
