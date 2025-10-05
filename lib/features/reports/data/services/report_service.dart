import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/report_model.dart';
import '../../../job_application/data/services/job_service.dart';
import '../../../job_application/data/services/job_application_service.dart';
import '../../../user_management/data/services/user_management_service.dart';
import '../../../documents/data/services/document_service.dart';
import '../../../user_management/domain/models/extended_user_model.dart';
import '../../../documents/domain/models/document_model.dart';

class ReportService {
  static const String _reportsBoxName = 'reports';
  static const String _analyticsBoxName = 'analytics_data';
  static const String _chartsBoxName = 'chart_data';

  static Box<ReportModel>? _reportsBox;
  static Box<AnalyticsDataModel>? _analyticsBox;
  static Box<ChartDataModel>? _chartsBox;

  static Future<void> init() async {
    _reportsBox = await Hive.openBox<ReportModel>(_reportsBoxName);
    _analyticsBox = await Hive.openBox<AnalyticsDataModel>(_analyticsBoxName);
    _chartsBox = await Hive.openBox<ChartDataModel>(_chartsBoxName);
  }

  static Box<ReportModel> get reportsBox {
    if (_reportsBox == null) {
      throw Exception(
          'ReportService not initialized. Call ReportService.init() first.');
    }
    return _reportsBox!;
  }

  static Box<AnalyticsDataModel> get analyticsBox {
    if (_analyticsBox == null) {
      throw Exception(
          'ReportService not initialized. Call ReportService.init() first.');
    }
    return _analyticsBox!;
  }

  static Box<ChartDataModel> get chartsBox {
    if (_chartsBox == null) {
      throw Exception(
          'ReportService not initialized. Call ReportService.init() first.');
    }
    return _chartsBox!;
  }

  // Report Management
  static Future<String> createReport(ReportModel report) async {
    final reportWithId = report.copyWith(id: const Uuid().v4());
    await reportsBox.put(reportWithId.id, reportWithId);
    return reportWithId.id;
  }

  static Future<ReportModel?> getReport(String id) async {
    return reportsBox.get(id);
  }

  static Future<List<ReportModel>> getAllReports() async {
    return reportsBox.values.toList();
  }

  static Future<List<ReportModel>> getReportsByCategory(
      ReportCategory category) async {
    return reportsBox.values
        .where((report) => report.category == category)
        .toList();
  }

  static Future<List<ReportModel>> getReportsByStatus(
      ReportStatus status) async {
    return reportsBox.values
        .where((report) => report.status == status)
        .toList();
  }

  static Future<bool> updateReport(ReportModel report) async {
    await reportsBox.put(report.id, report);
    return true;
  }

  static Future<bool> deleteReport(String id) async {
    await reportsBox.delete(id);
    return true;
  }

  // Report Generation
  static Future<String> generateApplicationSummaryReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? department,
    String generatedBy = 'system',
  }) async {
    try {
      final reportId = const Uuid().v4();

      // Create pending report
      final report = ReportModel(
        id: reportId,
        title: 'Application Summary Report',
        description: 'Summary of job applications',
        type: ReportType.summary,
        category: ReportCategory.applications,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        parameters: {
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'department': department,
        },
        data: {},
        status: ReportStatus.processing,
      );

      await reportsBox.put(reportId, report);

      // Generate report data
      final applications = await JobApplicationService.getAllApplications();
      final jobs = await JobService.getAllJobs();
      final users = await UserManagementService.getAllUsers();

      var filteredApplications = applications;
      if (fromDate != null) {
        filteredApplications = filteredApplications
            .where((app) => app.appliedDate.isAfter(fromDate))
            .toList();
      }
      if (toDate != null) {
        filteredApplications = filteredApplications
            .where((app) => app.appliedDate.isBefore(toDate))
            .toList();
      }

      final reportData = {
        'totalApplications': filteredApplications.length,
        'totalUsers': users.length,
        'applicationsByStatus': _getApplicationsByStatus(filteredApplications),
        'applicationsByJob': _getApplicationsByJob(filteredApplications, jobs),
        'applicationsByMonth': _getApplicationsByMonth(filteredApplications),
        'topApplicants': _getTopApplicants(filteredApplications),
        'averageProcessingTime':
            _getAverageProcessingTime(filteredApplications),
        'conversionRate': _getConversionRate(filteredApplications),
        'generatedAt': DateTime.now().toIso8601String(),
      };

      // Update report with data
      final completedReport = report.copyWith(
        status: ReportStatus.completed,
        data: reportData,
        recordCount: filteredApplications.length,
      );

      await reportsBox.put(reportId, completedReport);
      return reportId;
    } catch (e) {
      // Mark report as failed
      final failedReport = ReportModel(
        id: const Uuid().v4(),
        title: 'Application Summary Report',
        description: 'Summary of job applications',
        type: ReportType.summary,
        category: ReportCategory.applications,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        parameters: {
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'department': department,
        },
        data: {'error': e.toString()},
        status: ReportStatus.failed,
      );

  await reportsBox.put(failedReport.id, failedReport);
  rethrow;
    }
  }

  static Future<String> generateUserActivityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? department,
    String generatedBy = 'system',
  }) async {
    try {
      final reportId = const Uuid().v4();

      final report = ReportModel(
        id: reportId,
        title: 'User Activity Report',
        description: 'User activity and engagement metrics',
        type: ReportType.detailed,
        category: ReportCategory.users,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        parameters: {
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'department': department,
        },
        data: {},
        status: ReportStatus.processing,
      );

      await reportsBox.put(reportId, report);

      final users = await UserManagementService.getAllUsers();
      final auditLogs = await UserManagementService.getAuditLogs(
        fromDate: fromDate,
        toDate: toDate,
      );

      var filteredUsers = users;
      if (department != null) {
        filteredUsers = filteredUsers
            .where((user) => user.department == department)
            .toList();
      }

      final reportData = {
        'totalUsers': filteredUsers.length,
        'usersByRole': _getUsersByRole(filteredUsers),
        'usersByStatus': _getUsersByStatus(filteredUsers),
        'usersByDepartment': _getUsersByDepartment(filteredUsers),
        'activeUsers': filteredUsers
            .where((user) => user.status == UserStatus.active)
            .length,
        'userActivity': _getUserActivity(auditLogs),
        'loginStats': _getLoginStats(auditLogs),
        'generatedAt': DateTime.now().toIso8601String(),
      };

      final completedReport = report.copyWith(
        status: ReportStatus.completed,
        data: reportData,
        recordCount: filteredUsers.length,
      );

      await reportsBox.put(reportId, completedReport);
      return reportId;
    } catch (e) {
      final failedReport = ReportModel(
        id: const Uuid().v4(),
        title: 'User Activity Report',
        description: 'User activity and engagement metrics',
        type: ReportType.detailed,
        category: ReportCategory.users,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        parameters: {
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'department': department,
        },
        data: {'error': e.toString()},
        status: ReportStatus.failed,
      );

  await reportsBox.put(failedReport.id, failedReport);
  rethrow;
    }
  }

  static Future<String> generateJobPerformanceReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? department,
    String generatedBy = 'system',
  }) async {
    try {
      final reportId = const Uuid().v4();

      final report = ReportModel(
        id: reportId,
        title: 'Job Performance Report',
        description: 'Job posting and performance metrics',
        type: ReportType.summary,
        category: ReportCategory.jobs,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        parameters: {
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'department': department,
        },
        data: {},
        status: ReportStatus.processing,
      );

      await reportsBox.put(reportId, report);

      final jobs = await JobService.getAllJobs();
      final applications = await JobApplicationService.getAllApplications();

      var filteredJobs = jobs;
      if (fromDate != null) {
        filteredJobs = filteredJobs
            .where((job) => job.postedDate.isAfter(fromDate))
            .toList();
      }
      if (toDate != null) {
        filteredJobs = filteredJobs
            .where((job) => job.postedDate.isBefore(toDate))
            .toList();
      }
      if (department != null) {
        filteredJobs =
            filteredJobs.where((job) => job.department == department).toList();
      }

      final reportData = {
        'totalJobs': filteredJobs.length,
        'jobsByStatus': _getJobsByStatus(filteredJobs),
        'jobsByDepartment': _getJobsByDepartment(filteredJobs),
        'jobsByLocation': _getJobsByLocation(filteredJobs),
        'applicationStats': _getJobApplicationStats(filteredJobs, applications),
        'topPerformingJobs': _getTopPerformingJobs(filteredJobs, applications),
        'averageTimeToHire': _getAverageTimeToHire(filteredJobs, applications),
        'generatedAt': DateTime.now().toIso8601String(),
      };

      final completedReport = report.copyWith(
        status: ReportStatus.completed,
        data: reportData,
        recordCount: filteredJobs.length,
      );

      await reportsBox.put(reportId, completedReport);
      return reportId;
    } catch (e) {
      final failedReport = ReportModel(
        id: const Uuid().v4(),
        title: 'Job Performance Report',
        description: 'Job posting and performance metrics',
        type: ReportType.summary,
        category: ReportCategory.jobs,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        parameters: {
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'department': department,
        },
        data: {'error': e.toString()},
        status: ReportStatus.failed,
      );

  await reportsBox.put(failedReport.id, failedReport);
  rethrow;
    }
  }

  // Analytics Data Management
  static Future<String> createAnalyticsData(
      AnalyticsDataModel analyticsData) async {
    final analyticsWithId = analyticsData.copyWith(id: const Uuid().v4());
    await analyticsBox.put(analyticsWithId.id, analyticsWithId);
    return analyticsWithId.id;
  }

  static Future<List<AnalyticsDataModel>> getAnalyticsData({
    String? category,
    AnalyticsMetricType? metricType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var data = analyticsBox.values.toList();

    if (category != null) {
      data = data.where((item) => item.category == category).toList();
    }

    if (metricType != null) {
      data = data.where((item) => item.metricType == metricType).toList();
    }

    if (fromDate != null) {
      data = data.where((item) => item.timestamp.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      data = data.where((item) => item.timestamp.isBefore(toDate)).toList();
    }

    data.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return data;
  }

  // Chart Data Management
  static Future<String> createChartData(ChartDataModel chartData) async {
    final chartWithId = chartData.copyWith(id: const Uuid().v4());
    await chartsBox.put(chartWithId.id, chartWithId);
    return chartWithId.id;
  }

  static Future<List<ChartDataModel>> getAllCharts() async {
    return chartsBox.values.toList();
  }

  static Future<List<ChartDataModel>> getChartsByCategory(
      String category) async {
    return chartsBox.values
        .where((chart) => chart.category == category)
        .toList();
  }

  // Dashboard Analytics
  static Future<Map<String, dynamic>> getDashboardAnalytics() async {
    final applications = await JobApplicationService.getAllApplications();
    final jobs = await JobService.getAllJobs();
    final users = await UserManagementService.getAllUsers();
    final documents = await DocumentService.getAllDocuments();

    return {
      'totalApplications': applications.length,
      'totalJobs': jobs.length,
      'totalUsers': users.length,
      'totalDocuments': documents.length,
      'applicationsThisMonth': applications
          .where((app) => app.appliedDate
              .isAfter(DateTime.now().subtract(const Duration(days: 30))))
          .length,
      'activeJobs': jobs.where((job) => job.isActive).length,
      'activeUsers':
          users.where((user) => user.status == UserStatus.active).length,
      'pendingDocuments':
          documents.where((doc) => doc.status == DocumentStatus.pending).length,
      'applicationsByStatus': _getApplicationsByStatus(applications),
      'jobsByStatus': _getJobsByStatus(jobs),
      'usersByRole': _getUsersByRole(users),
      'recentActivity': await _getRecentActivity(),
    };
  }

  // Helper Methods
  static Map<String, int> _getApplicationsByStatus(List applications) {
    final statusCounts = <String, int>{};
    for (final app in applications) {
      final status = app.status.toString().split('.').last;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    return statusCounts;
  }

  static Map<String, int> _getApplicationsByJob(List applications, List jobs) {
    final jobCounts = <String, int>{};
    for (final app in applications) {
      final matching = jobs.where((j) => j.id == app.jobId);
      final job = matching.isEmpty ? null : matching.first;
      if (job != null) {
        jobCounts[job.title] = (jobCounts[job.title] ?? 0) + 1;
      }
    }
    return jobCounts;
  }

  static Map<String, int> _getApplicationsByMonth(List applications) {
    final monthCounts = <String, int>{};
    for (final app in applications) {
      final month =
          '${app.appliedDate.year}-${app.appliedDate.month.toString().padLeft(2, '0')}';
      monthCounts[month] = (monthCounts[month] ?? 0) + 1;
    }
    return monthCounts;
  }

  static List<Map<String, dynamic>> _getTopApplicants(List applications) {
    final applicantCounts = <String, int>{};
    for (final app in applications) {
      applicantCounts[app.applicantName] =
          (applicantCounts[app.applicantName] ?? 0) + 1;
    }

    final sortedApplicants = applicantCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedApplicants
        .take(10)
        .map((entry) => {
              'name': entry.key,
              'count': entry.value,
            })
        .toList();
  }

  static double _getAverageProcessingTime(List applications) {
    final completedApps = applications
        .where((app) =>
            app.status.toString().contains('completed') ||
            app.status.toString().contains('hired') ||
            app.status.toString().contains('rejected'))
        .toList();

    if (completedApps.isEmpty) return 0;

    double totalDays = 0;
    for (final app in completedApps) {
      if (app.reviewedDate != null) {
        totalDays +=
            app.reviewedDate!.difference(app.appliedDate).inDays.toDouble();
      }
    }

    return totalDays / completedApps.length;
  }

  static double _getConversionRate(List applications) {
    if (applications.isEmpty) return 0;
    final hiredCount = applications
        .where((app) => app.status.toString().contains('hired'))
        .length;
    return (hiredCount / applications.length) * 100;
  }

  static Map<String, int> _getUsersByRole(List users) {
    final roleCounts = <String, int>{};
    for (final user in users) {
      final role = user.role.toString().split('.').last;
      roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    }
    return roleCounts;
  }

  static Map<String, int> _getUsersByStatus(List users) {
    final statusCounts = <String, int>{};
    for (final user in users) {
      final status = user.status.toString().split('.').last;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    return statusCounts;
  }

  static Map<String, int> _getUsersByDepartment(List users) {
    final deptCounts = <String, int>{};
    for (final user in users) {
      if (user.department != null) {
        deptCounts[user.department!] = (deptCounts[user.department!] ?? 0) + 1;
      }
    }
    return deptCounts;
  }

  static Map<String, int> _getUserActivity(List auditLogs) {
    final activityCounts = <String, int>{};
    for (final log in auditLogs) {
      activityCounts[log.action] = (activityCounts[log.action] ?? 0) + 1;
    }
    return activityCounts;
  }

  static Map<String, int> _getLoginStats(List auditLogs) {
    final loginLogs =
        auditLogs.where((log) => log.action.contains('LOGIN')).toList();
    final loginCounts = <String, int>{};
    for (final log in loginLogs) {
      final date =
          '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';
      loginCounts[date] = (loginCounts[date] ?? 0) + 1;
    }
    return loginCounts;
  }

  static Map<String, int> _getJobsByStatus(List jobs) {
    final statusCounts = <String, int>{};
    for (final job in jobs) {
      final status = job.status.toString().split('.').last;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    return statusCounts;
  }

  static Map<String, int> _getJobsByDepartment(List jobs) {
    final deptCounts = <String, int>{};
    for (final job in jobs) {
      deptCounts[job.department] = (deptCounts[job.department] ?? 0) + 1;
    }
    return deptCounts;
  }

  static Map<String, int> _getJobsByLocation(List jobs) {
    final locationCounts = <String, int>{};
    for (final job in jobs) {
      locationCounts[job.location] = (locationCounts[job.location] ?? 0) + 1;
    }
    return locationCounts;
  }

  static Map<String, dynamic> _getJobApplicationStats(
      List jobs, List applications) {
    final jobStats = <String, Map<String, dynamic>>{};
    for (final job in jobs) {
      final jobApplications =
          applications.where((app) => app.jobId == job.id).toList();
      jobStats[job.title] = {
        'totalApplications': jobApplications.length,
        'hired': jobApplications
            .where((app) => app.status.toString().contains('hired'))
            .length,
        'rejected': jobApplications
            .where((app) => app.status.toString().contains('rejected'))
            .length,
        'pending': jobApplications
            .where((app) => app.status.toString().contains('pending'))
            .length,
      };
    }
    return jobStats;
  }

  static List<Map<String, dynamic>> _getTopPerformingJobs(
      List jobs, List applications) {
    final jobPerformance = <Map<String, dynamic>>[];
    for (final job in jobs) {
      final jobApplications =
          applications.where((app) => app.jobId == job.id).toList();
      final hiredCount = jobApplications
          .where((app) => app.status.toString().contains('hired'))
          .length;
      final conversionRate = jobApplications.isEmpty
          ? 0
          : (hiredCount / jobApplications.length) * 100;

      jobPerformance.add({
        'jobTitle': job.title,
        'department': job.department,
        'totalApplications': jobApplications.length,
        'hired': hiredCount,
        'conversionRate': conversionRate,
      });
    }

    jobPerformance
        .sort((a, b) => b['conversionRate'].compareTo(a['conversionRate']));
    return jobPerformance.take(10).toList();
  }

  static double _getAverageTimeToHire(List jobs, List applications) {
    final hiredApplications = applications
        .where((app) =>
            app.status.toString().contains('hired') && app.reviewedDate != null)
        .toList();

    if (hiredApplications.isEmpty) return 0;

    double totalDays = 0;
    for (final app in hiredApplications) {
      totalDays +=
          app.reviewedDate!.difference(app.appliedDate).inDays.toDouble();
    }

    return totalDays / hiredApplications.length;
  }

  static Future<List<Map<String, dynamic>>> _getRecentActivity() async {
    final auditLogs = await UserManagementService.getAuditLogs(limit: 10);
    return auditLogs
        .map((log) => {
              'action': log.action,
              'userId': log.userId,
              'timestamp': log.timestamp.toIso8601String(),
              'details': log.details,
            })
        .toList();
  }

  // Initialize sample data
  static Future<void> initializeSampleData() async {
    if (reportsBox.isNotEmpty) return;

    // Generate sample reports
    await generateApplicationSummaryReport(generatedBy: 'admin@carehr.com');
    await generateUserActivityReport(generatedBy: 'admin@carehr.com');
    await generateJobPerformanceReport(generatedBy: 'admin@carehr.com');
  }

  static Future<void> close() async {
    await _reportsBox?.close();
    await _analyticsBox?.close();
    await _chartsBox?.close();
  }
}

