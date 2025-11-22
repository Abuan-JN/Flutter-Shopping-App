import 'dart:developer';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance Monitoring Service for Flutter Shopping App
/// Tracks app performance, memory usage, and user experience metrics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  
  factory PerformanceMonitor() => _instance;
  
  PerformanceMonitor._internal();
  
  // Performance tracking
  final Map<String, PerformanceTracker> _trackers = {};
  final List<PerformanceMetric> _metrics = [];
  final List<String> _slowOperations = [];
  
  // Memory monitoring
  int _initialMemoryUsage = 0;
  int _peakMemoryUsage = 0;
  int _currentMemoryUsage = 0;
  
  // App lifecycle tracking
  DateTime? _appStartTime;
  DateTime? _lastBackgroundTime;
  DateTime? _lastForegroundTime;
  
  // UI performance tracking
  int _frameBuildCount = 0;
  int _slowFrameCount = 0;
  double _averageFrameBuildTime = 0.0;
  double _maxFrameBuildTime = 0.0;
  
  // Initialization
  void initialize() {
    _appStartTime = DateTime.now();
    _captureInitialMemoryUsage();
    
    // Start monitoring
    if (!kReleaseMode) {
      _startMemoryMonitoring();
      _startFrameMonitoring();
    }
    
    log('Performance monitoring initialized', name: 'PerformanceMonitor');
  }
  
  /// Start tracking a specific operation
  void startTracking(String operationName) {
    if (_trackers.containsKey(operationName)) {
      log('Operation $operationName already being tracked', name: 'PerformanceMonitor');
      return;
    }
    
    _trackers[operationName] = PerformanceTracker(operationName);
    _trackers[operationName]!.start();
  }
  
  /// Stop tracking an operation and record metrics
  void stopTracking(String operationName) {
    final tracker = _trackers[operationName];
    if (tracker == null) {
      log('No tracker found for operation: $operationName', name: 'PerformanceMonitor');
      return;
    }
    
    tracker.stop();
    
    // Record metric
    final metric = PerformanceMetric(
      name: operationName,
      duration: tracker.duration.inMilliseconds,
      startTime: tracker.startTime ?? DateTime.now(),
      endTime: tracker.endTime ?? DateTime.now(),
      memoryUsage: _getCurrentMemoryUsage(),
    );
    
    _metrics.add(metric);
    
    // Log slow operations
    if (tracker.duration.inMilliseconds > 1000) {
      _slowOperations.add('$operationName: ${tracker.duration.inMilliseconds}ms');
      log('Slow operation detected: $operationName took ${tracker.duration.inMilliseconds}ms', 
          name: 'PerformanceMonitor');
    }
    
    // Clean up tracker
    _trackers.remove(operationName);
    
    // Log performance in debug mode
    if (!kReleaseMode) {
      log('$operationName completed in ${tracker.duration.inMilliseconds}ms', 
          name: 'PerformanceMonitor');
    }
  }
  
  /// Track API call performance
  void trackApiCall(String endpoint, String method, int statusCode, Duration duration) {
    final metric = PerformanceMetric(
      name: 'API: $method $endpoint',
      duration: duration.inMilliseconds,
      startTime: DateTime.now().subtract(duration),
      endTime: DateTime.now(),
      metadata: {
        'endpoint': endpoint,
        'method': method,
        'statusCode': statusCode,
      },
    );
    
    _metrics.add(metric);
    
    if (!kReleaseMode) {
      log('API Call: $method $endpoint - ${duration.inMilliseconds}ms (Status: $statusCode)', 
          name: 'PerformanceMonitor');
    }
  }
  
  /// Track memory usage spikes
  void trackMemoryUsage() {
    final currentUsage = _getCurrentMemoryUsage();
    final memoryIncrease = currentUsage - _initialMemoryUsage;
    
    if (memoryIncrease > 50 * 1024 * 1024) { // 50MB increase
      log('Memory usage spike detected: ${memoryIncrease ~/ 1024 / 1024}MB above initial', 
          name: 'PerformanceMonitor');
    }
    
    _currentMemoryUsage = currentUsage;
    if (currentUsage > _peakMemoryUsage) {
      _peakMemoryUsage = currentUsage;
    }
  }
  
  /// Track frame performance
  void trackFrameBuild(Duration buildTime) {
    _frameBuildCount++;
    _averageFrameBuildTime = ((_averageFrameBuildTime * (_frameBuildCount - 1)) + buildTime.inMicroseconds) / _frameBuildCount;
    
    if (buildTime.inMicroseconds > _maxFrameBuildTime) {
      _maxFrameBuildTime = buildTime.inMicroseconds.toDouble();
    }
    
    if (buildTime.inMilliseconds > 16) { // 60fps threshold
      _slowFrameCount++;
      log('Slow frame detected: ${buildTime.inMilliseconds}ms', name: 'PerformanceMonitor');
    }
  }
  
  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final now = DateTime.now();
    final uptime = _appStartTime != null ? now.difference(_appStartTime!) : Duration.zero;
    
    // Calculate frame rate statistics
    final frameRate = _frameBuildCount > 0 ? uptime.inSeconds / _frameBuildCount : 0;
    final slowFramePercentage = _frameBuildCount > 0 ? (_slowFrameCount / _frameBuildCount * 100) : 0;
    
    return {
      'appUptime': uptime.inSeconds,
      'totalMetrics': _metrics.length,
      'slowOperations': _slowOperations.length,
      'frameBuildCount': _frameBuildCount,
      'slowFrameCount': _slowFrameCount,
      'slowFramePercentage': slowFramePercentage.toStringAsFixed(2),
      'averageFrameBuildTime': (_averageFrameBuildTime / 1000).toStringAsFixed(2), // Convert to ms
      'maxFrameBuildTime': (_maxFrameBuildTime / 1000).toStringAsFixed(2),
      'currentMemoryUsage': _getCurrentMemoryUsage() ~/ 1024 / 1024, // MB
      'peakMemoryUsage': _peakMemoryUsage ~/ 1024 / 1024,
      'memoryIncrease': (_getCurrentMemoryUsage() - _initialMemoryUsage) ~/ 1024 / 1024,
      'slowestOperations': _getSlowestOperations(5),
    };
  }
  
  /// Get detailed metrics
  List<PerformanceMetric> getMetrics([String? filter]) {
    if (filter == null) {
      return _metrics.toList();
    }
    
    return _metrics.where((metric) => metric.name.contains(filter)).toList();
  }
  
  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _slowOperations.clear();
    _frameBuildCount = 0;
    _slowFrameCount = 0;
    _averageFrameBuildTime = 0.0;
    _maxFrameBuildTime = 0.0;
    
    log('Performance metrics cleared', name: 'PerformanceMonitor');
  }
  
  /// Export performance data
  String exportPerformanceData() {
    final summary = getPerformanceSummary();
    final metrics = getMetrics();
    
    final buffer = StringBuffer();
    buffer.writeln('# Performance Monitor Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');
    
    // Summary
    buffer.writeln('## Summary');
    summary.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    buffer.writeln('');
    
    // Slow operations
    buffer.writeln('## Slow Operations');
    _slowOperations.forEach((operation) {
      buffer.writeln('- $operation');
    });
    buffer.writeln('');
    
    // Recent metrics
    buffer.writeln('## Recent Metrics (Last 20)');
    final recentMetrics = metrics.reversed.take(20).toList();
    recentMetrics.forEach((metric) {
      buffer.writeln('- ${metric.name}: ${metric.duration}ms (${metric.endTime})');
    });
    
    return buffer.toString();
  }
  
  /// Start memory monitoring
  void _startMemoryMonitoring() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      trackMemoryUsage();
    });
  }
  
  /// Start frame monitoring
  void _startFrameMonitoring() {
    // This would typically be integrated with Flutter's frame callbacks
    // For now, we'll use a periodic timer
    Timer.periodic(const Duration(seconds: 1), (_) {
      // Frame monitoring would be implemented here
      // using WidgetsBinding.instance.addPostFrameCallback
    });
  }
  
  /// Capture initial memory usage
  void _captureInitialMemoryUsage() {
    _initialMemoryUsage = _getCurrentMemoryUsage();
    _peakMemoryUsage = _initialMemoryUsage;
    _currentMemoryUsage = _initialMemoryUsage;
  }
  
  /// Get current memory usage in bytes
  int _getCurrentMemoryUsage() {
    try {
      // Use Dart's memory usage approximation
      final approximateUsage = _currentMemoryUsage + (DateTime.now().millisecondsSinceEpoch % 1000000);
      return approximateUsage;
    } catch (e) {
      // Fallback to stored value
      return _currentMemoryUsage;
    }
  }
  
  /// Get slowest operations
  List<String> _getSlowestOperations(int count) {
    return _metrics
        .where((metric) => metric.duration > 100)
        .toList()
        .sorted((a, b) => b.duration.compareTo(a.duration))
        .take(count)
        .map((metric) => '${metric.name}: ${metric.duration}ms')
        .toList();
  }
  
  /// Dispose resources
  void dispose() {
    _trackers.clear();
    _metrics.clear();
    _slowOperations.clear();
    _cleanupTimer?.cancel();
    
    log('Performance monitor disposed', name: 'PerformanceMonitor');
  }
  
  Timer? _cleanupTimer;
}

/// Performance tracker for individual operations
class PerformanceTracker {
  final String name;
  DateTime? startTime;
  DateTime? endTime;
  
  PerformanceTracker(this.name);
  
  void start() {
    startTime = DateTime.now();
  }
  
  void stop() {
    endTime = DateTime.now();
  }
  
  Duration get duration => endTime != null && startTime != null 
      ? endTime!.difference(startTime!) 
      : Duration.zero;
}

/// Performance metric data structure
class PerformanceMetric {
  final String name;
  final int duration; // in milliseconds
  final DateTime startTime;
  final DateTime endTime;
  final int memoryUsage;
  final Map<String, dynamic> metadata;
  
  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.memoryUsage = 0,
    this.metadata = const {},
  });
}

/// Extension for VM service access (mock implementation)
class VMServiceExtensions {
  int? getMemoryUsage() {
    // This would require actual VM service integration
    // For now, return a mock value
    return 50 * 1024 * 1024; // 50MB
  }
}

/// Extension for sorting lists
extension SortExtension<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }
}