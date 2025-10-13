import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/performance_service.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/monitoring_service.dart';

class PerformanceDashboardPage extends StatefulWidget {
  const PerformanceDashboardPage({super.key});

  @override
  State<PerformanceDashboardPage> createState() => _PerformanceDashboardPageState();
}

class _PerformanceDashboardPageState extends State<PerformanceDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  PerformanceReport? _performanceReport;
  CacheStatistics? _cacheStats;
  MonitoringSummary? _monitoringSummary;
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPerformanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceData() async {
    setState(() => _isLoading = true);
    
    try {
      final performanceReport = await PerformanceService.getCurrentPerformance();
      final cacheStats = CacheService.getStatistics();
      final monitoringSummary = MonitoringService.getSummary();
      
      setState(() {
        _performanceReport = performanceReport;
        _cacheStats = cacheStats;
        _monitoringSummary = monitoringSummary;
        _isLoading = false;
      });
    } catch (e) {
      MonitoringService.logError('Failed to load performance data', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Performance Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadPerformanceData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.memory), text: 'Cache'),
            Tab(icon: Icon(Icons.monitor), text: 'Monitoring'),
            Tab(icon: Icon(Icons.network_check), text: 'Network'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPerformanceTab(),
                _buildCacheTab(),
                _buildMonitoringTab(),
                _buildNetworkTab(),
              ],
            ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_performanceReport == null) {
      return const Center(child: Text('No performance data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Memory Usage',
                  '${_performanceReport!.memoryUsage.toStringAsFixed(1)} MB',
                  Icons.memory,
                  _getMemoryColor(_performanceReport!.memoryUsage),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Frame Rate',
                  '${_performanceReport!.frameRate.toStringAsFixed(1)} FPS',
                  Icons.speed,
                  _getFrameRateColor(_performanceReport!.frameRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Performance Metrics Chart
          _buildPerformanceChart(),
          const SizedBox(height: 16),
          
          // Recent Performance Events
          _buildPerformanceEvents(),
        ],
      ),
    );
  }

  Widget _buildCacheTab() {
    if (_cacheStats == null) {
      return const Center(child: Text('No cache data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cache Stats Overview
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Memory Cache',
                  '${_cacheStats!.memoryCacheSize} entries',
                  Icons.storage,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Persistent Cache',
                  '${_cacheStats!.persistentCacheSize} entries',
                  Icons.sd_storage,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Cache Hit Rates
          _buildCacheHitRateChart(),
          const SizedBox(height: 16),
          
          // Cache Statistics Details
          _buildCacheDetails(),
        ],
      ),
    );
  }

  Widget _buildMonitoringTab() {
    if (_monitoringSummary == null) {
      return const Center(child: Text('No monitoring data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monitoring Overview
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Logs',
                  '${_monitoringSummary!.totalLogs}',
                  Icons.article,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Errors',
                  '${_monitoringSummary!.totalErrors}',
                  Icons.error,
                  _monitoringSummary!.totalErrors > 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Warnings',
                  '${_monitoringSummary!.totalWarnings}',
                  Icons.warning,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Error Rate',
                  '${(_monitoringSummary!.errorRate * 100).toStringAsFixed(1)}%',
                  Icons.analytics,
                  _getErrorRateColor(_monitoringSummary!.errorRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Log Distribution Chart
          _buildLogDistributionChart(),
          const SizedBox(height: 16),
          
          // Recent Errors
          _buildRecentErrors(),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    final networkRequests = PerformanceService.getRecentNetworkRequests(10);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Network Overview
          _buildMetricCard(
            'Recent Requests',
            '${networkRequests.length}',
            Icons.network_check,
            AppColors.primary,
          ),
          const SizedBox(height: 16),
          
          // Network Requests List
          _buildNetworkRequestsList(networkRequests),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generatePerformanceSpots(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheHitRateChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cache Hit Rates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: AppColors.success,
                    value: _cacheStats!.memoryHitRate * 100,
                    title: 'Memory\n${(_cacheStats!.memoryHitRate * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.info,
                    value: _cacheStats!.persistentHitRate * 100,
                    title: 'Persistent\n${(_cacheStats!.persistentHitRate * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Text('Info', style: TextStyle(fontSize: 12));
                          case 1: return const Text('Warnings', style: TextStyle(fontSize: 12));
                          case 2: return const Text('Errors', style: TextStyle(fontSize: 12));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _monitoringSummary!.totalInfos.toDouble(),
                        color: AppColors.info,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _monitoringSummary!.totalWarnings.toDouble(),
                        color: AppColors.warning,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _monitoringSummary!.totalErrors.toDouble(),
                        color: AppColors.error,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceEvents() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Performance Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ..._performanceReport!.recentEvents.take(5).map((event) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getEventIcon(event.type),
                    size: 16,
                    color: AppColors.mutedLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.operationName ?? 'System Event',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  Text(
                    '${event.value.toStringAsFixed(1)}ms',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildCacheDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cache Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(_cacheStats.toString()),
        ],
      ),
    );
  }

  Widget _buildRecentErrors() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Errors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          if (_monitoringSummary!.recentErrors.isEmpty)
            const Text(
              'No recent errors 🎉',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            ..._monitoringSummary!.recentErrors.take(3).map((error) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            error.message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            error.error,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildNetworkRequestsList(List<NetworkRequest> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No recent network requests',
          style: TextStyle(color: AppColors.mutedLight),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Network Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ...requests.map((request) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusCodeColor(request.statusCode).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.method,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusCodeColor(request.statusCode),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.url,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${request.statusCode} • ${request.duration.inMilliseconds}ms',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  List<FlSpot> _generatePerformanceSpots() {
    // Generate sample performance data
    return List.generate(20, (index) {
      return FlSpot(
        index.toDouble(),
        50 + (index * 2) + (DateTime.now().millisecond % 10),
      );
    });
  }

  Color _getMemoryColor(double memoryUsage) {
    if (memoryUsage > 100) return AppColors.error;
    if (memoryUsage > 75) return AppColors.warning;
    return AppColors.success;
  }

  Color _getFrameRateColor(double frameRate) {
    if (frameRate < 30) return AppColors.error;
    if (frameRate < 50) return AppColors.warning;
    return AppColors.success;
  }

  Color _getErrorRateColor(double errorRate) {
    if (errorRate > 0.1) return AppColors.error;
    if (errorRate > 0.05) return AppColors.warning;
    return AppColors.success;
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return AppColors.success;
    if (statusCode >= 300 && statusCode < 400) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.operation:
        return Icons.play_circle_outline;
      case EventType.networkRequest:
        return Icons.network_check;
      case EventType.memoryUsage:
        return Icons.memory;
      case EventType.frameRate:
        return Icons.speed;
      case EventType.userInteraction:
        return Icons.touch_app;
      case EventType.error:
        return Icons.error_outline;
    }
  }
}