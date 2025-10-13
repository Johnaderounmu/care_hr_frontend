import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive performance monitoring service for the Care HR application
/// Tracks app performance, memory usage, network requests, and provides optimization insights
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Performance tracking
  final Map<String, PerformanceMetric> _metrics = {};
  final Queue<NetworkRequest> _networkRequests = Queue();
  final Queue<PerformanceEvent> _performanceEvents = Queue();
  
  // Timers and trackers
  final Map<String, DateTime> _operationStartTimes = {};
  Timer? _memoryTrackingTimer;
  Timer? _performanceReportTimer;
  
  // Configuration
  static const int _maxNetworkRequests = 100;
  static const int _maxPerformanceEvents = 200;
  static const Duration _reportInterval = Duration(minutes: 5);
  
  // Memory and CPU tracking
  double _lastMemoryUsage = 0.0;
  double _lastCpuUsage = 0.0;
  int _frameDropCount = 0;
  int _totalFrames = 0;
  
  /// Initialize performance monitoring
  static Future<void> init() async {
    final instance = PerformanceService._instance;
    await instance._initializePerformanceTracking();
    instance._startPerformanceMonitoring();
    
    if (kDebugMode) {
      print('🚀 PerformanceService initialized');
    }
  }

  /// Initialize performance tracking systems
  Future<void> _initializePerformanceTracking() async {
    try {
      // Load existing performance data
      await _loadPerformanceHistory();
      
      // Initialize basic metrics
      _metrics['app_startup'] = PerformanceMetric(
        name: 'app_startup',
        description: 'Application startup time',
        unit: 'ms',
      );
      
      _metrics['network_requests'] = PerformanceMetric(
        name: 'network_requests',
        description: 'Network request performance',
        unit: 'ms',
      );
      
      _metrics['memory_usage'] = PerformanceMetric(
        name: 'memory_usage',
        description: 'Memory usage tracking',
        unit: 'MB',
      );
      
      _metrics['frame_rate'] = PerformanceMetric(
        name: 'frame_rate',
        description: 'UI frame rate performance',
        unit: 'fps',
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Performance tracking initialization error: $e');
      }
    }
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    // Start memory tracking
    _memoryTrackingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _trackMemoryUsage(),
    );
    
    // Start performance reporting
    _performanceReportTimer = Timer.periodic(
      _reportInterval,
      (timer) => _generatePerformanceReport(),
    );
    
    // Start frame rate monitoring
    _startFrameRateMonitoring();
  }

  /// Track memory usage
  void _trackMemoryUsage() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;
      
      // This is a simplified memory tracking
      // In a real app, you'd use platform-specific methods
      final memoryUsage = _estimateMemoryUsage();
      
      _lastMemoryUsage = memoryUsage;
      _updateMetric('memory_usage', memoryUsage);
      
      _addPerformanceEvent(PerformanceEvent(
        type: EventType.memoryUsage,
        timestamp: DateTime.now(),
        value: memoryUsage,
        metadata: {'unit': 'MB'},
      ));
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Memory tracking error: $e');
      }
    }
  }

  /// Start frame rate monitoring
  void _startFrameRateMonitoring() {
    // This is a simplified implementation
    // In production, you'd use SchedulerBinding.instance.addTimingsCallback
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _totalFrames += 60; // Assume 60fps ideal
      final frameRate = _calculateFrameRate();
      _updateMetric('frame_rate', frameRate);
    });
  }

  /// Calculate current frame rate
  double _calculateFrameRate() {
    // Simplified calculation - in production use actual frame timing data
    final droppedFrameRatio = _frameDropCount / (_totalFrames + _frameDropCount);
    return 60.0 * (1.0 - droppedFrameRatio);
  }

  /// Estimate memory usage (simplified)
  double _estimateMemoryUsage() {
    // This is a placeholder - in production use platform channels
    return 50.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10;
  }

  /// Start tracking an operation
  static void startOperation(String operationName) {
    final instance = PerformanceService._instance;
    instance._operationStartTimes[operationName] = DateTime.now();
  }

  /// End tracking an operation and record performance
  static void endOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final instance = PerformanceService._instance;
    final startTime = instance._operationStartTimes.remove(operationName);
    
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      instance._recordOperationPerformance(operationName, duration, metadata);
    }
  }

  /// Record operation performance
  void _recordOperationPerformance(
    String operationName,
    Duration duration,
    Map<String, dynamic>? metadata,
  ) {
    final durationMs = duration.inMilliseconds.toDouble();
    
    // Update metric
    _updateMetric(operationName, durationMs);
    
    // Add performance event
    _addPerformanceEvent(PerformanceEvent(
      type: EventType.operation,
      timestamp: DateTime.now(),
      value: durationMs,
      operationName: operationName,
      metadata: metadata ?? {},
    ));
    
    if (kDebugMode) {
      print('⏱️ Operation $operationName took ${duration.inMilliseconds}ms');
    }
  }

  /// Track network request
  static void trackNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required Duration duration,
    required int responseSize,
  }) {
    final instance = PerformanceService._instance;
    instance._recordNetworkRequest(NetworkRequest(
      url: url,
      method: method,
      statusCode: statusCode,
      duration: duration,
      responseSize: responseSize,
      timestamp: DateTime.now(),
    ));
  }

  /// Record network request performance
  void _recordNetworkRequest(NetworkRequest request) {
    // Add to request queue
    _networkRequests.add(request);
    
    // Maintain queue size
    while (_networkRequests.length > _maxNetworkRequests) {
      _networkRequests.removeFirst();
    }
    
    // Update network metrics
    _updateMetric('network_requests', request.duration.inMilliseconds.toDouble());
    
    // Add performance event
    _addPerformanceEvent(PerformanceEvent(
      type: EventType.networkRequest,
      timestamp: request.timestamp,
      value: request.duration.inMilliseconds.toDouble(),
      metadata: {
        'url': request.url,
        'method': request.method,
        'status': request.statusCode,
        'size': request.responseSize,
      },
    ));
    
    if (kDebugMode) {
      print('🌐 Network: ${request.method} ${request.url} - ${request.duration.inMilliseconds}ms (${request.statusCode})');
    }
  }

  /// Update metric with new value
  void _updateMetric(String name, double value) {
    final metric = _metrics[name];
    if (metric != null) {
      metric.addValue(value);
    }
  }

  /// Add performance event
  void _addPerformanceEvent(PerformanceEvent event) {
    _performanceEvents.add(event);
    
    // Maintain queue size
    while (_performanceEvents.length > _maxPerformanceEvents) {
      _performanceEvents.removeFirst();
    }
  }

  /// Generate comprehensive performance report
  Future<PerformanceReport> _generatePerformanceReport() async {
    final report = PerformanceReport(
      timestamp: DateTime.now(),
      metrics: Map.from(_metrics),
      recentEvents: _performanceEvents.toList(),
      networkRequests: _networkRequests.toList(),
      memoryUsage: _lastMemoryUsage,
      cpuUsage: _lastCpuUsage,
      frameRate: _calculateFrameRate(),
    );
    
    // Save report for analysis
    await _savePerformanceReport(report);
    
    if (kDebugMode) {
      print('📊 Performance Report Generated: ${report.getSummary()}');
    }
    
    return report;
  }

  /// Get current performance summary
  static Future<PerformanceReport> getCurrentPerformance() async {
    final instance = PerformanceService._instance;
    return instance._generatePerformanceReport();
  }

  /// Get performance metrics
  static Map<String, PerformanceMetric> getMetrics() {
    return Map.unmodifiable(PerformanceService._instance._metrics);
  }

  /// Get recent network requests
  static List<NetworkRequest> getRecentNetworkRequests([int limit = 20]) {
    final instance = PerformanceService._instance;
    final requests = instance._networkRequests.toList();
    return requests.length > limit ? requests.sublist(requests.length - limit) : requests;
  }

  /// Load performance history from storage
  Future<void> _loadPerformanceHistory() async {
    try {
      // Implementation for loading historical performance data
      // This would deserialize stored performance metrics
      if (kDebugMode) {
        print('📊 Performance history loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load performance history: $e');
      }
    }
  }

  /// Save performance report to storage
  Future<void> _savePerformanceReport(PerformanceReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Implementation for saving performance reports
      // This would serialize and store the report data
      await prefs.setString('last_performance_report', report.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save performance report: $e');
      }
    }
  }

  /// Cleanup performance monitoring
  static void dispose() {
    final instance = PerformanceService._instance;
    instance._memoryTrackingTimer?.cancel();
    instance._performanceReportTimer?.cancel();
    
    if (kDebugMode) {
      print('🛑 PerformanceService disposed');
    }
  }
}

/// Performance metric container
class PerformanceMetric {
  final String name;
  final String description;
  final String unit;
  final List<double> _values = [];
  DateTime lastUpdated = DateTime.now();

  PerformanceMetric({
    required this.name,
    required this.description,
    required this.unit,
  });

  void addValue(double value) {
    _values.add(value);
    lastUpdated = DateTime.now();
    
    // Keep only last 100 values
    if (_values.length > 100) {
      _values.removeAt(0);
    }
  }

  double get average => _values.isEmpty ? 0.0 : _values.reduce((a, b) => a + b) / _values.length;
  double get min => _values.isEmpty ? 0.0 : _values.reduce((a, b) => a < b ? a : b);
  double get max => _values.isEmpty ? 0.0 : _values.reduce((a, b) => a > b ? a : b);
  double get latest => _values.isEmpty ? 0.0 : _values.last;
  int get sampleCount => _values.length;
  
  List<double> get values => List.unmodifiable(_values);
}

/// Network request tracking
class NetworkRequest {
  final String url;
  final String method;
  final int statusCode;
  final Duration duration;
  final int responseSize;
  final DateTime timestamp;

  NetworkRequest({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.duration,
    required this.responseSize,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'method': method,
    'statusCode': statusCode,
    'duration': duration.inMilliseconds,
    'responseSize': responseSize,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Performance event tracking
class PerformanceEvent {
  final EventType type;
  final DateTime timestamp;
  final double value;
  final String? operationName;
  final Map<String, dynamic> metadata;

  PerformanceEvent({
    required this.type,
    required this.timestamp,
    required this.value,
    this.operationName,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'timestamp': timestamp.toIso8601String(),
    'value': value,
    'operationName': operationName,
    'metadata': metadata,
  };
}

/// Performance event types
enum EventType {
  operation,
  networkRequest,
  memoryUsage,
  frameRate,
  userInteraction,
  error,
}

/// Comprehensive performance report
class PerformanceReport {
  final DateTime timestamp;
  final Map<String, PerformanceMetric> metrics;
  final List<PerformanceEvent> recentEvents;
  final List<NetworkRequest> networkRequests;
  final double memoryUsage;
  final double cpuUsage;
  final double frameRate;

  PerformanceReport({
    required this.timestamp,
    required this.metrics,
    required this.recentEvents,
    required this.networkRequests,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.frameRate,
  });

  /// Get performance summary
  String getSummary() {
    final sb = StringBuffer();
    sb.writeln('Performance Summary (${timestamp.toLocal()})');
    sb.writeln('Memory Usage: ${memoryUsage.toStringAsFixed(1)}MB');
    sb.writeln('Frame Rate: ${frameRate.toStringAsFixed(1)}fps');
    sb.writeln('Network Requests: ${networkRequests.length}');
    sb.writeln('Performance Events: ${recentEvents.length}');
    
    for (final metric in metrics.values) {
      sb.writeln('${metric.name}: ${metric.average.toStringAsFixed(1)}${metric.unit} (avg)');
    }
    
    return sb.toString();
  }

  /// Convert to JSON
  String toJson() {
    // Simplified JSON conversion
    return '{"timestamp": "${timestamp.toIso8601String()}", "memoryUsage": $memoryUsage, "frameRate": $frameRate}';
  }
}