import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/quick_action_button.dart';
import '../../../../core/widgets/app_header.dart';

class HRDashboardPage extends StatefulWidget {
  const HRDashboardPage({super.key});

  @override
  State<HRDashboardPage> createState() => _HRDashboardPageState();
}

class _HRDashboardPageState extends State<HRDashboardPage> {
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
                  subtitle: AppStrings.dashboardSubtitle,
                  user: authProvider.user,
                ),

                // Dashboard Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: const [
                            DashboardCard(
                              title: AppStrings.activeApplicants,
                              value: '125',
                              icon: Icons.people,
                              color: AppColors.primary,
                            ),
                            DashboardCard(
                              title: AppStrings.pendingReviews,
                              value: '32',
                              icon: Icons.description,
                              color: AppColors.warning,
                            ),
                            DashboardCard(
                              title: AppStrings.upcomingExpirations,
                              value: '15',
                              icon: Icons.schedule,
                              color: AppColors.error,
                            ),
                            DashboardCard(
                              title: AppStrings.recentlyUploaded,
                              value: '20',
                              icon: Icons.cloud_upload,
                              color: AppColors.success,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Charts Section
                        Row(
                          children: [
                            Text(
                              'Analytics Overview',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Charts Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            ChartCard(
                              title: AppStrings.applicantGrowth,
                              value: '+15%',
                              subtitle: '+2.5% vs last month',
                              period: 'Last 30 Days',
                              chart: _buildBarChart(),
                            ),
                            ChartCard(
                              title: AppStrings.documentProgress,
                              value: '85%',
                              subtitle: '+5% vs last week',
                              period: 'Current Quarter',
                              chart: _buildLineChart(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Quick Actions
                        Row(
                          children: [
                            Text(
                              AppStrings.quickActions,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Quick Action Buttons
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            QuickActionButton(
                              text: AppStrings.viewAllApplicants,
                              icon: Icons.people_outline,
                              onPressed: () {
                                // TODO: Navigate to applicants page
                              },
                            ),
                            QuickActionButton(
                              text: AppStrings.manageDocuments,
                              icon: Icons.description_outlined,
                              onPressed: () {
                                context.push('/hr-document-review');
                              },
                              isSecondary: true,
                            ),
                            QuickActionButton(
                              text: 'View Reports',
                              icon: Icons.analytics_outlined,
                              onPressed: () {
                                context.push('/reports');
                              },
                              isSecondary: true,
                            ),
                            QuickActionButton(
                              text: 'Schedule Interview',
                              icon: Icons.calendar_today_outlined,
                              onPressed: () {
                                // TODO: Navigate to interview scheduling
                              },
                              isSecondary: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Recent Activity
                        _buildRecentActivity(),
                      ],
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

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: AppColors.mutedLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('Jan', style: style);
                    break;
                  case 1:
                    text = const Text('Feb', style: style);
                    break;
                  case 2:
                    text = const Text('Mar', style: style);
                    break;
                  case 3:
                    text = const Text('Apr', style: style);
                    break;
                  case 4:
                    text = const Text('May', style: style);
                    break;
                  case 5:
                    text = const Text('Jun', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: text,
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: 60, color: AppColors.subtleLight)
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: 40, color: AppColors.subtleLight)
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(toY: 70, color: AppColors.subtleLight)
          ]),
          BarChartGroupData(
              x: 3,
              barRods: [BarChartRodData(toY: 85, color: AppColors.primary)]),
          BarChartGroupData(x: 4, barRods: [
            BarChartRodData(toY: 80, color: AppColors.subtleLight)
          ]),
          BarChartGroupData(x: 5, barRods: [
            BarChartRodData(toY: 95, color: AppColors.subtleLight)
          ]),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 87.2),
              FlSpot(1, 16.8),
              FlSpot(2, 32.8),
              FlSpot(3, 74.4),
              FlSpot(4, 26.4),
              FlSpot(5, 80.8),
              FlSpot(6, 48.8),
              FlSpot(7, 36),
              FlSpot(8, 96.8),
              FlSpot(9, 119.2),
              FlSpot(10, 0.8),
              FlSpot(11, 64.8),
              FlSpot(12, 103.2),
              FlSpot(13, 20),
            ],
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0)
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.person_add,
                  title: 'New applicant registered',
                  subtitle: 'John Doe applied for Nurse position',
                  time: '2 hours ago',
                  color: AppColors.primary,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.description,
                  title: 'Document reviewed',
                  subtitle: 'Sarah Wilson\'s resume approved',
                  time: '4 hours ago',
                  color: AppColors.success,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.schedule,
                  title: 'Interview scheduled',
                  subtitle: 'Meeting with Mike Johnson at 2:00 PM',
                  time: '6 hours ago',
                  color: AppColors.warning,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.notification_important,
                  title: 'Document expiring',
                  subtitle: '3 certificates expire this week',
                  time: '1 day ago',
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}
