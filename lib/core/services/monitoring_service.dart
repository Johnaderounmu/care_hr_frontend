import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive logging and monitoring service for the Care HR application
/// Provides structured logging, error tracking, performance monitoring, and analytics
class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  // Core logger instance
  late Logger _logger;
  
  // Log storage and management
  final List<LogEntry> _logBuffer = [];
  final List<ErrorReport> _errorReports = [];
  final List<PerformanceMetric> _performanceMetrics = [];
  
  // Configuration
  static const int _maxLogBufferSize = 1000;
  static const int _maxErrorReports = 100;
  static const int _maxPerformanceMetrics = 500;
  static const Duration _logFlushInterval = Duration(minutes: 5);
  
  // Monitoring state
  Timer? _logFlushTimer;
  bool _initialized = false;
  String? _sessionId;
  String? _userId;
  
  // Statistics
  int _totalLogs = 0;
  int _totalErrors = 0;
  int _totalWarnings = 0;
  int _totalInfos = 0;

  /// Initialize monitoring service
  static Future<void> init({
    String? sessionId,
    String? userId,
    Level logLevel = Level.info,
  }) async {
    final instance = MonitoringService._instance;
    await instance._initialize(sessionId, userId, logLevel);
    
    if (kDebugMode) {
      print('📊 MonitoringService initialized');
    }
  }

  /// Initialize the monitoring service
  Future<void> _initialize(String? sessionId, String? userId, Level logLevel) async {
    try {
      _sessionId = sessionId ?? _generateSessionId();
      _userId = userId;
      
      // Initialize logger with custom configuration
      _logger = Logger(
        level: logLevel,
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: _CustomLogOutput(),
      );
      
      // Start log flushing timer
      _logFlushTimer = Timer.periodic(_logFlushInterval, (timer) {
        _flushLogs();
      });
      
      _initialized = true;
      
      // Log initialization
      logInfo('MonitoringService initialized', {
        'sessionId': _sessionId,
        'userId': _userId,
        'logLevel': logLevel.toString(),
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ MonitoringService initialization failed: $e');
      }
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Log information message
  static void logInfo(String message, [Map<String, dynamic>? metadata]) {
    final instance = MonitoringService._instance;
    instance._log(Level.info, message, metadata);
  }

  /// Log warning message
  static void logWarning(String message, [Map<String, dynamic>? metadata]) {
    final instance = MonitoringService._instance;
    instance._log(Level.warning, message, metadata);
  }

  /// Log error message
  static void logError(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? metadata]) {
    final instance = MonitoringService._instance;
    instance._log(Level.error, message, metadata, error, stackTrace);
  }

  /// Log debug message
  static void logDebug(String message, [Map<String, dynamic>? metadata]) {
    final instance = MonitoringService._instance;
    instance._log(Level.debug, message, metadata);
  }

  /// Internal logging method
  void _log(Level level, String message, Map<String, dynamic>? metadata, [dynamic error, StackTrace? stackTrace]) {
    if (!_initialized) return;
    
    try {
      // Create log entry
      final logEntry = LogEntry(
        level: level,
        message: message,
        timestamp: DateTime.now(),
        sessionId: _sessionId!,
        userId: _userId,
        metadata: metadata ?? {},
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
      );
      
      // Add to buffer
      _logBuffer.add(logEntry);
      
      // Maintain buffer size
      if (_logBuffer.length > _maxLogBufferSize) {
        _logBuffer.removeAt(0);
      }
      
      // Update statistics
      _updateLogStatistics(level);
      
      // Use logger for console output
      switch (level) {
        case Level.debug:
          _logger.d(message);
          break;
        case Level.info:
          _logger.i(message);
          break;
        case Level.warning:
          _logger.w(message);
          break;
        case Level.error:
          _logger.e(message, error: error, stackTrace: stackTrace);
          if (error != null) {
            _recordError(message, error, stackTrace, metadata);
          }
          break;
        case Level.fatal:
          _logger.f(message, error: error, stackTrace: stackTrace);
          break;
        case Level.trace:
          _logger.t(message);
          break;
        default:
          _logger.i(message);
          break;
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Logging error: $e');
      }
    }
  }

  /// Update log statistics
  void _updateLogStatistics(Level level) {
    _totalLogs++;
    
    switch (level) {
      case Level.error:
      case Level.fatal:
        _totalErrors++;
        break;
      case Level.warning:
        _totalWarnings++;
        break;
      case Level.info:
        _totalInfos++;
        break;
      default:
        break;
    }
  }

  /// Record error for tracking
  void _recordError(String message, dynamic error, StackTrace? stackTrace, Map<String, dynamic>? metadata) {
    try {
      final errorReport = ErrorReport(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        message: message,
        error: error?.toString() ?? 'Unknown error',
        stackTrace: stackTrace?.toString(),
        timestamp: DateTime.now(),
        sessionId: _sessionId!,
        userId: _userId,
        metadata: metadata ?? {},
        deviceInfo: _getDeviceInfo(),
      );
      
      _errorReports.add(errorReport);
      
      // Maintain error report size
      if (_errorReports.length > _maxErrorReports) {
        _errorReports.removeAt(0);
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error recording failed: $e');
      }
    }
  }

  /// Get device information
  Map<String, dynamic> _getDeviceInfo() {
    final deviceInfo = <String, dynamic>{};
    
    try {
      deviceInfo['platform'] = Platform.operatingSystem;
      deviceInfo['version'] = Platform.operatingSystemVersion;
      deviceInfo['isDebug'] = kDebugMode;
      deviceInfo['timestamp'] = DateTime.now().toIso8601String();
    } catch (e) {
      deviceInfo['error'] = 'Failed to get device info: $e';
    }
    
    return deviceInfo;
  }

  /// Track performance metric
  static void trackPerformance(String name, double value, String unit, [Map<String, dynamic>? metadata]) {
    final instance = MonitoringService._instance;
    instance._trackPerformanceMetric(name, value, unit, metadata);
  }

  /// Internal performance tracking
  void _trackPerformanceMetric(String name, double value, String unit, Map<String, dynamic>? metadata) {
    try {
      final metric = PerformanceMetric(
        name: name,
        value: value,
        unit: unit,
        timestamp: DateTime.now(),
        sessionId: _sessionId!,
        userId: _userId,
        metadata: metadata ?? {},
      );
      
      _performanceMetrics.add(metric);
      
      // Maintain metrics size
      if (_performanceMetrics.length > _maxPerformanceMetrics) {
        _performanceMetrics.removeAt(0);
      }
      
      // Log performance metric
      logDebug('Performance: $name = $value $unit', metadata);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Performance tracking error: $e');
      }
    }
  }

  /// Track user event
  static void trackEvent(String eventName, [Map<String, dynamic>? parameters]) {
    final instance = MonitoringService._instance;
    instance._trackUserEvent(eventName, parameters);
  }

  /// Internal event tracking
  void _trackUserEvent(String eventName, Map<String, dynamic>? parameters) {
    try {
      final eventData = {
        'event': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _sessionId,
        'userId': _userId,
        ...?parameters,
      };
      
      logInfo('Event: $eventName', eventData);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Event tracking error: $e');
      }
    }
  }

  /// Set user context
  static void setUserContext(String userId, [Map<String, dynamic>? userProperties]) {
    final instance = MonitoringService._instance;
    instance._userId = userId;
    
    logInfo('User context set', {
      'userId': userId,
      ...?userProperties,
    });
  }

  /// Add breadcrumb for debugging
  static void addBreadcrumb(String message, [Map<String, dynamic>? data]) {
    logDebug('Breadcrumb: $message', data);
  }

  /// Flush logs to storage
  Future<void> _flushLogs() async {
    if (_logBuffer.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final logData = _logBuffer.map((entry) => entry.toJson()).toList();
      
      // Save recent logs to storage
      await prefs.setString('monitoring_logs', jsonEncode(logData));
      
      // Save error reports
      if (_errorReports.isNotEmpty) {
        final errorData = _errorReports.map((error) => error.toJson()).toList();
        await prefs.setString('monitoring_errors', jsonEncode(errorData));
      }
      
      // Save performance metrics
      if (_performanceMetrics.isNotEmpty) {
        final performanceData = _performanceMetrics.map((metric) => metric.toJson()).toList();
        await prefs.setString('monitoring_performance', jsonEncode(performanceData));
      }
      
      if (kDebugMode) {
        print('💾 Flushed ${_logBuffer.length} logs, ${_errorReports.length} errors, ${_performanceMetrics.length} metrics');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Log flush error: $e');
      }
    }
  }

  /// Get monitoring summary
  static MonitoringSummary getSummary() {
    final instance = MonitoringService._instance;
    
    return MonitoringSummary(
      sessionId: instance._sessionId ?? 'unknown',
      totalLogs: instance._totalLogs,
      totalErrors: instance._totalErrors,
      totalWarnings: instance._totalWarnings,
      totalInfos: instance._totalInfos,
      recentErrors: instance._errorReports.take(10).toList(),
      recentPerformanceMetrics: instance._performanceMetrics.take(20).toList(),
      bufferSize: instance._logBuffer.length,
    );
  }

  /// Export logs for analysis
  static Future<String> exportLogs() async {
    final instance = MonitoringService._instance;
    
    try {
      final exportData = {
        'metadata': {
          'sessionId': instance._sessionId,
          'userId': instance._userId,
          'exportTime': DateTime.now().toIso8601String(),
          'platform': Platform.operatingSystem,
        },
        'statistics': {
          'totalLogs': instance._totalLogs,
          'totalErrors': instance._totalErrors,
          'totalWarnings': instance._totalWarnings,
          'totalInfos': instance._totalInfos,
        },
        'logs': instance._logBuffer.map((entry) => entry.toJson()).toList(),
        'errors': instance._errorReports.map((error) => error.toJson()).toList(),
        'performance': instance._performanceMetrics.map((metric) => metric.toJson()).toList(),
      };
      
      return jsonEncode(exportData);
      
    } catch (e) {
      logError('Failed to export logs', e);
      return '{"error": "Failed to export logs: $e"}';
    }
  }

  /// Clear all monitoring data
  static Future<void> clearAll() async {
    final instance = MonitoringService._instance;
    
    instance._logBuffer.clear();
    instance._errorReports.clear();
    instance._performanceMetrics.clear();
    instance._totalLogs = 0;
    instance._totalErrors = 0;
    instance._totalWarnings = 0;
    instance._totalInfos = 0;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('monitoring_logs');
      await prefs.remove('monitoring_errors');
      await prefs.remove('monitoring_performance');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear monitoring data: $e');
      }
    }
    
    logInfo('Monitoring data cleared');
  }

  /// Dispose monitoring service
  static void dispose() {
    final instance = MonitoringService._instance;
    instance._logFlushTimer?.cancel();
    instance._flushLogs();
    
    if (kDebugMode) {
      print('🛑 MonitoringService disposed');
    }
  }
}

/// Custom log output for capturing logs
class _CustomLogOutput extends LogOutput {
  _CustomLogOutput();
  
  @override
  void output(OutputEvent event) {
    // Output to console in debug mode
    if (kDebugMode) {
      for (final line in event.lines) {
        print(line);
      }
    }
  }
}

/// Log entry container
class LogEntry {
  final Level level;
  final String message;
  final DateTime timestamp;
  final String sessionId;
  final String? userId;
  final Map<String, dynamic> metadata;
  final String? error;
  final String? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.sessionId,
    this.userId,
    required this.metadata,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    'level': level.toString(),
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'userId': userId,
    'metadata': metadata,
    'error': error,
    'stackTrace': stackTrace,
  };
}

/// Error report container
class ErrorReport {
  final String id;
  final String message;
  final String error;
  final String? stackTrace;
  final DateTime timestamp;
  final String sessionId;
  final String? userId;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> deviceInfo;

  ErrorReport({
    required this.id,
    required this.message,
    required this.error,
    this.stackTrace,
    required this.timestamp,
    required this.sessionId,
    this.userId,
    required this.metadata,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'error': error,
    'stackTrace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'userId': userId,
    'metadata': metadata,
    'deviceInfo': deviceInfo,
  };
}

/// Performance metric container
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String sessionId;
  final String? userId;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.sessionId,
    this.userId,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'userId': userId,
    'metadata': metadata,
  };
}

/// Monitoring summary container
class MonitoringSummary {
  final String sessionId;
  final int totalLogs;
  final int totalErrors;
  final int totalWarnings;
  final int totalInfos;
  final List<ErrorReport> recentErrors;
  final List<PerformanceMetric> recentPerformanceMetrics;
  final int bufferSize;

  MonitoringSummary({
    required this.sessionId,
    required this.totalLogs,
    required this.totalErrors,
    required this.totalWarnings,
    required this.totalInfos,
    required this.recentErrors,
    required this.recentPerformanceMetrics,
    required this.bufferSize,
  });

  double get errorRate => totalLogs == 0 ? 0.0 : totalErrors / totalLogs;
  
  @override
  String toString() {
    return 'Monitoring Summary (Session: $sessionId)\n'
           'Logs: $totalLogs (Errors: $totalErrors, Warnings: $totalWarnings, Info: $totalInfos)\n'
           'Error Rate: ${(errorRate * 100).toStringAsFixed(1)}%\n'
           'Buffer Size: $bufferSize\n'
           'Recent Errors: ${recentErrors.length}\n'
           'Performance Metrics: ${recentPerformanceMetrics.length}';
  }
}