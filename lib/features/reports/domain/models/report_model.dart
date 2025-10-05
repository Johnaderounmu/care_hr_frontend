import 'package:hive/hive.dart';

part 'report_model.g.dart';

@HiveType(typeId: 17)
class ReportModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  ReportType type;

  @HiveField(4)
  ReportCategory category;

  @HiveField(5)
  DateTime generatedAt;

  @HiveField(6)
  String generatedBy;

  @HiveField(7)
  Map<String, dynamic> parameters;

  @HiveField(8)
  Map<String, dynamic> data;

  @HiveField(9)
  ReportStatus status;

  @HiveField(10)
  String? filePath;

  @HiveField(11)
  String? downloadUrl;

  @HiveField(12)
  int recordCount;

  @HiveField(13)
  DateTime? scheduledFor;

  @HiveField(14)
  String? scheduleFrequency;

  @HiveField(15)
  bool isScheduled;

  @HiveField(16)
  List<String> recipients;

  @HiveField(17)
  Map<String, dynamic>? metadata;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.generatedAt,
    required this.generatedBy,
    required this.parameters,
    required this.data,
    this.status = ReportStatus.pending,
    this.filePath,
    this.downloadUrl,
    this.recordCount = 0,
    this.scheduledFor,
    this.scheduleFrequency,
    this.isScheduled = false,
    this.recipients = const [],
    this.metadata,
  });

  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    ReportType? type,
    ReportCategory? category,
    DateTime? generatedAt,
    String? generatedBy,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? data,
    ReportStatus? status,
    String? filePath,
    String? downloadUrl,
    int? recordCount,
    DateTime? scheduledFor,
    String? scheduleFrequency,
    bool? isScheduled,
    List<String>? recipients,
    Map<String, dynamic>? metadata,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
      parameters: parameters ?? this.parameters,
      data: data ?? this.data,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      recordCount: recordCount ?? this.recordCount,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      scheduleFrequency: scheduleFrequency ?? this.scheduleFrequency,
      isScheduled: isScheduled ?? this.isScheduled,
      recipients: recipients ?? this.recipients,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isCompleted => status == ReportStatus.completed;
  bool get isPending => status == ReportStatus.pending;
  bool get isFailed => status == ReportStatus.failed;
  bool get isProcessing => status == ReportStatus.processing;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

@HiveType(typeId: 18)
enum ReportType {
  @HiveField(0)
  summary,

  @HiveField(1)
  detailed,

  @HiveField(2)
  chart,

  @HiveField(3)
  export,

  @HiveField(4)
  dashboard;

  String get displayName {
    switch (this) {
      case ReportType.summary:
        return 'Summary Report';
      case ReportType.detailed:
        return 'Detailed Report';
      case ReportType.chart:
        return 'Chart Report';
      case ReportType.export:
        return 'Export Report';
      case ReportType.dashboard:
        return 'Dashboard Widget';
    }
  }
}

@HiveType(typeId: 19)
enum ReportCategory {
  @HiveField(0)
  applications,

  @HiveField(1)
  interviews,

  @HiveField(2)
  users,

  @HiveField(3)
  jobs,

  @HiveField(4)
  documents,

  @HiveField(5)
  performance,

  @HiveField(6)
  compliance,

  @HiveField(7)
  system;

  String get displayName {
    switch (this) {
      case ReportCategory.applications:
        return 'Applications';
      case ReportCategory.interviews:
        return 'Interviews';
      case ReportCategory.users:
        return 'Users';
      case ReportCategory.jobs:
        return 'Jobs';
      case ReportCategory.documents:
        return 'Documents';
      case ReportCategory.performance:
        return 'Performance';
      case ReportCategory.compliance:
        return 'Compliance';
      case ReportCategory.system:
        return 'System';
    }
  }
}

@HiveType(typeId: 20)
enum ReportStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  processing,

  @HiveField(2)
  completed,

  @HiveField(3)
  failed;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.processing:
        return 'Processing';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.failed:
        return 'Failed';
    }
  }
}

// Analytics Data Models
@HiveType(typeId: 21)
class AnalyticsDataModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String metricName;

  @HiveField(2)
  AnalyticsMetricType metricType;

  @HiveField(3)
  Map<String, dynamic> data;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? category;

  @HiveField(6)
  Map<String, dynamic>? filters;

  @HiveField(7)
  String? description;

  AnalyticsDataModel({
    required this.id,
    required this.metricName,
    required this.metricType,
    required this.data,
    required this.timestamp,
    this.category,
    this.filters,
    this.description,
  });

  AnalyticsDataModel copyWith({
    String? id,
    String? metricName,
    AnalyticsMetricType? metricType,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? category,
    Map<String, dynamic>? filters,
    String? description,
  }) {
    return AnalyticsDataModel(
      id: id ?? this.id,
      metricName: metricName ?? this.metricName,
      metricType: metricType ?? this.metricType,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      filters: filters ?? this.filters,
      description: description ?? this.description,
    );
  }
}

@HiveType(typeId: 22)
enum AnalyticsMetricType {
  @HiveField(0)
  count,

  @HiveField(1)
  percentage,

  @HiveField(2)
  trend,

  @HiveField(3)
  distribution,

  @HiveField(4)
  comparison,

  @HiveField(5)
  timeSeries;

  String get displayName {
    switch (this) {
      case AnalyticsMetricType.count:
        return 'Count';
      case AnalyticsMetricType.percentage:
        return 'Percentage';
      case AnalyticsMetricType.trend:
        return 'Trend';
      case AnalyticsMetricType.distribution:
        return 'Distribution';
      case AnalyticsMetricType.comparison:
        return 'Comparison';
      case AnalyticsMetricType.timeSeries:
        return 'Time Series';
    }
  }
}

// Chart Data Models
@HiveType(typeId: 23)
class ChartDataModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  ChartType type;

  @HiveField(3)
  List<ChartDataPoint> dataPoints;

  @HiveField(4)
  Map<String, dynamic>? options;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String? category;

  ChartDataModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dataPoints,
    this.options,
    required this.createdAt,
    this.category,
  });

  ChartDataModel copyWith({
    String? id,
    String? title,
    ChartType? type,
    List<ChartDataPoint>? dataPoints,
    Map<String, dynamic>? options,
    DateTime? createdAt,
    String? category,
  }) {
    return ChartDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dataPoints: dataPoints ?? this.dataPoints,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}

@HiveType(typeId: 24)
class ChartDataPoint extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  double value;

  @HiveField(2)
  String? color;

  @HiveField(3)
  Map<String, dynamic>? metadata;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
    this.metadata,
  });

  ChartDataPoint copyWith({
    String? label,
    double? value,
    String? color,
    Map<String, dynamic>? metadata,
  }) {
    return ChartDataPoint(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
    );
  }
}

@HiveType(typeId: 25)
enum ChartType {
  @HiveField(0)
  bar,

  @HiveField(1)
  line,

  @HiveField(2)
  pie,

  @HiveField(3)
  doughnut,

  @HiveField(4)
  area,

  @HiveField(5)
  scatter;

  String get displayName {
    switch (this) {
      case ChartType.bar:
        return 'Bar Chart';
      case ChartType.line:
        return 'Line Chart';
      case ChartType.pie:
        return 'Pie Chart';
      case ChartType.doughnut:
        return 'Doughnut Chart';
      case ChartType.area:
        return 'Area Chart';
      case ChartType.scatter:
        return 'Scatter Plot';
    }
  }
}

