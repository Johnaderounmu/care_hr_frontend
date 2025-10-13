class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Mock data for analytics
  Map<String, dynamic> getOverviewMetrics() {
    return {
      'totalApplications': 1234,
      'activeJobs': 45,
      'hired': 89,
      'averageTimeToHire': 12,
      'applicationTrend': '+12%',
      'jobsTrend': '+5%',
      'hiredTrend': '+18%',
      'timeTrend': '-2 days',
    };
  }

  Map<String, dynamic> getApplicationStatusDistribution() {
    return {
      'underReview': 45.0,
      'interviewed': 25.0,
      'hired': 20.0,
      'rejected': 10.0,
    };
  }

  List<Map<String, dynamic>> getMonthlyApplicationTrend() {
    return [
      {'month': 'Jan', 'applications': 120},
      {'month': 'Feb', 'applications': 180},
      {'month': 'Mar', 'applications': 150},
      {'month': 'Apr', 'applications': 220},
      {'month': 'May', 'applications': 280},
      {'month': 'Jun', 'applications': 320},
    ];
  }

  List<Map<String, dynamic>> getHiringFunnelData() {
    return [
      {'stage': 'Applied', 'count': 1000},
      {'stage': 'Screened', 'count': 650},
      {'stage': 'Interviewed', 'count': 320},
      {'stage': 'Offered', 'count': 150},
      {'stage': 'Hired', 'count': 89},
    ];
  }

  List<Map<String, dynamic>> getDepartmentStats() {
    return [
      {'department': 'Engineering', 'applications': 45, 'hired': 25},
      {'department': 'Sales', 'applications': 30, 'hired': 18},
      {'department': 'Marketing', 'applications': 20, 'hired': 12},
      {'department': 'HR', 'applications': 15, 'hired': 8},
      {'department': 'Operations', 'applications': 25, 'hired': 15},
    ];
  }

  List<Map<String, dynamic>> getApplicationSources() {
    return [
      {'source': 'LinkedIn', 'percentage': 35, 'icon': 'business'},
      {'source': 'Company Website', 'percentage': 25, 'icon': 'web'},
      {'source': 'Employee Referral', 'percentage': 20, 'icon': 'people'},
      {'source': 'Job Boards', 'percentage': 15, 'icon': 'work'},
      {'source': 'Recruitment Agencies', 'percentage': 5, 'icon': 'business_center'},
    ];
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'successRate': 8.9,
      'timeToFill': 18,
      'interviewRate': 32,
      'offerAcceptRate': 85,
      'successTrend': '+1.2%',
      'timeTrend': '-3 days',
      'interviewTrend': '+5%',
      'acceptTrend': '+8%',
    };
  }

  List<Map<String, dynamic>> getTeamPerformance() {
    return [
      {'name': 'Sarah Johnson', 'applications': 45, 'hired': 12, 'role': 'Senior Recruiter'},
      {'name': 'Mike Chen', 'applications': 38, 'hired': 9, 'role': 'Recruiter'},
      {'name': 'Emma Davis', 'applications': 52, 'hired': 15, 'role': 'Lead Recruiter'},
      {'name': 'John Smith', 'applications': 29, 'hired': 7, 'role': 'Junior Recruiter'},
    ];
  }

  List<Map<String, dynamic>> getQualityMetricsOverTime() {
    return [
      {'week': 'W1', 'quality': 7.2, 'retention': 82},
      {'week': 'W2', 'quality': 8.1, 'retention': 78},
      {'week': 'W3', 'quality': 8.5, 'retention': 85},
      {'week': 'W4', 'quality': 8.9, 'retention': 85},
    ];
  }

  List<Map<String, dynamic>> getApplicationVolumeTrends() {
    return [
      {'month': 'Jan', 'volume': 200},
      {'month': 'Feb', 'volume': 250},
      {'month': 'Mar', 'volume': 180},
      {'month': 'Apr', 'volume': 320},
      {'month': 'May', 'volume': 280},
      {'month': 'Jun', 'volume': 350},
    ];
  }

  List<Map<String, dynamic>> getSkillDemandTrends() {
    return [
      {'skill': 'React/Flutter', 'demand': 95, 'change': '+12%'},
      {'skill': 'Python', 'demand': 88, 'change': '+8%'},
      {'skill': 'Data Analysis', 'demand': 82, 'change': '+15%'},
      {'skill': 'Project Management', 'demand': 75, 'change': '+5%'},
      {'skill': 'Cloud Computing', 'demand': 70, 'change': '+20%'},
    ];
  }

  List<Map<String, dynamic>> getAIInsights() {
    return [
      {
        'title': 'Hiring Forecast',
        'description': 'Based on current trends, we predict 15% increase in applications next month',
        'icon': 'trending_up',
        'type': 'success',
      },
      {
        'title': 'Optimization Opportunity',
        'description': 'Engineering roles take 25% longer to fill. Consider expanding candidate sources.',
        'icon': 'lightbulb',
        'type': 'warning',
      },
      {
        'title': 'Quality Alert',
        'description': 'New hire retention improved by 12% this quarter. Current strategies are effective.',
        'icon': 'check_circle',
        'type': 'success',
      },
    ];
  }

  // Analytics tracking methods
  void trackUserAction(String action, Map<String, dynamic> properties) {
    // Implementation for tracking user actions
    print('Analytics: $action - $properties');
  }

  void trackScreenView(String screenName) {
    // Implementation for tracking screen views
    print('Analytics: Screen view - $screenName');
  }

  void trackEvent(String event, Map<String, dynamic> parameters) {
    // Implementation for tracking custom events
    print('Analytics: Event - $event - $parameters');
  }

  // Report generation
  Future<Map<String, dynamic>> generateReport(String reportType, String timeRange) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'reportType': reportType,
      'timeRange': timeRange,
      'generatedAt': DateTime.now(),
      'data': _getReportData(reportType),
    };
  }

  Map<String, dynamic> _getReportData(String reportType) {
    switch (reportType) {
      case 'hiring':
        return {
          'totalHires': 89,
          'averageTime': 18,
          'successRate': 8.9,
          'topSources': getApplicationSources(),
        };
      case 'performance':
        return {
          'teamStats': getTeamPerformance(),
          'metrics': getPerformanceMetrics(),
        };
      case 'trends':
        return {
          'volumeTrends': getApplicationVolumeTrends(),
          'skillTrends': getSkillDemandTrends(),
        };
      default:
        return {};
    }
  }
}