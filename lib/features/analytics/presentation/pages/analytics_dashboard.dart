import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animations/custom_animations.dart';
import '../../../../core/services/navigation_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'Last 30 Days';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'Last Year', child: Text('Last Year')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedTimeRange, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Hiring'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHiringTab(),
          _buildPerformanceTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Key Metrics Cards
          ...AnimationHelpers.createStaggeredList(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Total Applications', '1,234', Icons.description, AppColors.primary, '+12%')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Active Jobs', '45', Icons.work, AppColors.secondary, '+5%')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Hired', '89', Icons.check_circle, AppColors.success, '+18%')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Avg. Time to Hire', '12 days', Icons.access_time, AppColors.accentInfo, '-2 days')),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Application Status Chart
          AnimatedCard(
            child: _buildChartCard(
              'Application Status Distribution',
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(value: 45, color: AppColors.primary, title: 'Under Review\n45%', titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                      PieChartSectionData(value: 25, color: AppColors.secondary, title: 'Interviewed\n25%', titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                      PieChartSectionData(value: 20, color: AppColors.success, title: 'Hired\n20%', titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                      PieChartSectionData(value: 10, color: AppColors.error, title: 'Rejected\n10%', titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                    ],
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Monthly Applications Trend
          AnimatedCard(
            child: _buildChartCard(
              'Monthly Applications Trend',
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                            if (value.toInt() < months.length) {
                              return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 120),
                          FlSpot(1, 180),
                          FlSpot(2, 150),
                          FlSpot(3, 220),
                          FlSpot(4, 280),
                          FlSpot(5, 320),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Hiring Funnel
          AnimatedCard(
            child: _buildChartCard(
              'Hiring Funnel',
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1000,
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const stages = ['Applied', 'Screened', 'Interviewed', 'Offered', 'Hired'];
                            if (value.toInt() < stages.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(stages[value.toInt()], style: const TextStyle(fontSize: 10)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1000, color: AppColors.primary)]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 650, color: AppColors.secondary)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 320, color: AppColors.accentInfo)]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 150, color: AppColors.accentWarning)]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 89, color: AppColors.success)]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Department Hiring Stats
          AnimatedCard(
            child: _buildListCard(
              'Hiring by Department',
              [
                _buildDepartmentStat('Engineering', 45, 25, AppColors.primary),
                _buildDepartmentStat('Sales', 30, 18, AppColors.secondary),
                _buildDepartmentStat('Marketing', 20, 12, AppColors.accentInfo),
                _buildDepartmentStat('HR', 15, 8, AppColors.accentWarning),
                _buildDepartmentStat('Operations', 25, 15, AppColors.success),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top Performing Sources
          AnimatedCard(
            child: _buildListCard(
              'Top Application Sources',
              [
                _buildSourceStat('LinkedIn', 35, Icons.business),
                _buildSourceStat('Company Website', 25, Icons.web),
                _buildSourceStat('Employee Referral', 20, Icons.people),
                _buildSourceStat('Job Boards', 15, Icons.work),
                _buildSourceStat('Recruitment Agencies', 5, Icons.business_center),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Performance Metrics
          ...AnimationHelpers.createStaggeredList(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Success Rate', '8.9%', Icons.trending_up, AppColors.success, '+1.2%')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Time to Fill', '18 days', Icons.schedule, AppColors.accentWarning, '-3 days')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Interview Rate', '32%', Icons.rate_review, AppColors.primary, '+5%')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Offer Accept Rate', '85%', Icons.handshake, AppColors.secondary, '+8%')),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // HR Team Performance
          AnimatedCard(
            child: _buildListCard(
              'HR Team Performance',
              [
                _buildTeamMemberStat('Sarah Johnson', 45, 12, 'Senior Recruiter'),
                _buildTeamMemberStat('Mike Chen', 38, 9, 'Recruiter'),
                _buildTeamMemberStat('Emma Davis', 52, 15, 'Lead Recruiter'),
                _buildTeamMemberStat('John Smith', 29, 7, 'Junior Recruiter'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quality Metrics
          AnimatedCard(
            child: _buildChartCard(
              'Quality Metrics Over Time',
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const weeks = ['W1', 'W2', 'W3', 'W4'];
                            if (value.toInt() < weeks.length) {
                              return Text(weeks[value.toInt()], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(0, 7.2), FlSpot(1, 8.1), FlSpot(2, 8.5), FlSpot(3, 8.9)],
                        isCurved: true,
                        color: AppColors.success,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                      LineChartBarData(
                        spots: const [FlSpot(0, 82), FlSpot(1, 78), FlSpot(2, 85), FlSpot(3, 85)],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Market Trends
          AnimatedCard(
            child: _buildChartCard(
              'Application Volume Trends',
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                            if (value.toInt() < months.length) {
                              return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 200),
                          FlSpot(1, 250),
                          FlSpot(2, 180),
                          FlSpot(3, 320),
                          FlSpot(4, 280),
                          FlSpot(5, 350),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Skill Demand Trends
          AnimatedCard(
            child: _buildListCard(
              'Most In-Demand Skills',
              [
                _buildSkillTrend('React/Flutter', 95, '+12%'),
                _buildSkillTrend('Python', 88, '+8%'),
                _buildSkillTrend('Data Analysis', 82, '+15%'),
                _buildSkillTrend('Project Management', 75, '+5%'),
                _buildSkillTrend('Cloud Computing', 70, '+20%'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Predictive Analytics
          AnimatedCard(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'AI Insights & Predictions',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInsightCard(
                      'Hiring Forecast',
                      'Based on current trends, we predict 15% increase in applications next month',
                      Icons.trending_up,
                      AppColors.success,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildInsightCard(
                      'Optimization Opportunity',
                      'Engineering roles take 25% longer to fill. Consider expanding candidate sources.',
                      Icons.lightbulb,
                      AppColors.accentWarning,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildInsightCard(
                      'Quality Alert',
                      'New hire retention improved by 12% this quarter. Current strategies are effective.',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return AnimatedCard(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    change,
                    style: TextStyle(
                      color: change.startsWith('+') ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentStat(String department, int applications, int hired, Color color) {
    final percentage = (hired / applications * 100).toInt();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(department, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$applications applications • $hired hired', 
                     style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceStat(String source, int percentage, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(source, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberStat(String name, int applications, int hired, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              name.split(' ').map((e) => e[0]).join(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(role, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$hired hired', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$applications apps', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillTrend(String skill, int demand, String change) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(skill, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: demand / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$demand%',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            change,
            style: TextStyle(
              color: change.startsWith('+') ? AppColors.success : AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}