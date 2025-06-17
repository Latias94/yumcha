import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 聊天性能监控器
///
/// 用于监控聊天系统的性能指标，包括状态更新频率、UI重建次数等
class ChatPerformanceMonitor {
  static final ChatPerformanceMonitor _instance =
      ChatPerformanceMonitor._internal();
  factory ChatPerformanceMonitor() => _instance;
  ChatPerformanceMonitor._internal();

  /// 性能指标记录
  final Map<String, List<PerformanceMetric>> _metrics = {};

  /// 监控开始时间
  DateTime? _monitoringStartTime;

  /// 是否启用监控
  bool _isEnabled = kDebugMode;

  /// 最大记录数量
  static const int _maxRecords = 1000;

  /// 启用性能监控
  void enable() {
    _isEnabled = true;
    _monitoringStartTime = DateTime.now();
  }

  /// 禁用性能监控
  void disable() {
    _isEnabled = false;
  }

  /// 记录性能指标
  void recordMetric(
    String category,
    String name, {
    Duration? duration,
    int? count,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

    final metric = PerformanceMetric(
      category: category,
      name: name,
      timestamp: DateTime.now(),
      duration: duration,
      count: count,
      metadata: metadata,
    );

    _metrics.putIfAbsent(category, () => []).add(metric);

    // 限制记录数量
    if (_metrics[category]!.length > _maxRecords) {
      _metrics[category]!.removeAt(0);
    }
  }

  /// 记录状态更新
  void recordStateUpdate(String updateType, {Duration? duration}) {
    recordMetric('state_updates', updateType, duration: duration);
  }

  /// 记录UI重建
  void recordUIRebuild(String componentName, {Duration? duration}) {
    recordMetric('ui_rebuilds', componentName, duration: duration);
  }

  /// 记录消息处理
  void recordMessageProcessing(String operation,
      {Duration? duration, int? messageCount}) {
    recordMetric('message_processing', operation,
        duration: duration, count: messageCount);
  }

  /// 记录流式更新
  void recordStreamingUpdate(String messageId,
      {Duration? duration, int? updateCount}) {
    recordMetric('streaming_updates', messageId,
        duration: duration, count: updateCount);
  }

  /// 记录事件发送
  void recordEventEmission(String eventType, {bool wasDeduplicated = false}) {
    recordMetric('event_emissions', eventType,
        metadata: {'deduplicated': wasDeduplicated});
  }

  /// 获取性能报告
  PerformanceReport getReport() {
    final now = DateTime.now();
    final monitoringDuration = _monitoringStartTime != null
        ? now.difference(_monitoringStartTime!)
        : Duration.zero;

    final categoryReports = <String, CategoryReport>{};

    for (final entry in _metrics.entries) {
      final category = entry.key;
      final metrics = entry.value;

      if (metrics.isEmpty) continue;

      final totalCount = metrics.length;
      final avgDuration = _calculateAverageDuration(metrics);
      final maxDuration = _calculateMaxDuration(metrics);
      final minDuration = _calculateMinDuration(metrics);
      final recentMetrics = _getRecentMetrics(metrics, Duration(minutes: 1));
      final recentRate = recentMetrics.length / 60.0; // per second

      categoryReports[category] = CategoryReport(
        category: category,
        totalCount: totalCount,
        averageDuration: avgDuration,
        maxDuration: maxDuration,
        minDuration: minDuration,
        recentRate: recentRate,
        metrics: metrics,
      );
    }

    return PerformanceReport(
      monitoringDuration: monitoringDuration,
      categoryReports: categoryReports,
      isEnabled: _isEnabled,
    );
  }

  /// 获取简化的性能摘要
  Map<String, dynamic> getPerformanceSummary() {
    final report = getReport();
    final summary = <String, dynamic>{};

    summary['monitoring_duration_minutes'] =
        report.monitoringDuration.inMinutes;
    summary['is_enabled'] = report.isEnabled;

    for (final entry in report.categoryReports.entries) {
      final category = entry.key;
      final categoryReport = entry.value;

      summary['${category}_total_count'] = categoryReport.totalCount;
      summary['${category}_avg_duration_ms'] =
          categoryReport.averageDuration?.inMilliseconds;
      summary['${category}_recent_rate_per_sec'] =
          categoryReport.recentRate.toStringAsFixed(2);
    }

    return summary;
  }

  /// 重置所有指标
  void reset() {
    _metrics.clear();
    _monitoringStartTime = DateTime.now();
  }

  /// 计算平均持续时间
  Duration? _calculateAverageDuration(List<PerformanceMetric> metrics) {
    final durationsMs = metrics
        .where((m) => m.duration != null)
        .map((m) => m.duration!.inMilliseconds)
        .toList();

    if (durationsMs.isEmpty) return null;

    final avgMs = durationsMs.reduce((a, b) => a + b) / durationsMs.length;
    return Duration(milliseconds: avgMs.round());
  }

  /// 计算最大持续时间
  Duration? _calculateMaxDuration(List<PerformanceMetric> metrics) {
    final durations = metrics
        .where((m) => m.duration != null)
        .map((m) => m.duration!)
        .toList();

    if (durations.isEmpty) return null;

    return durations.reduce((a, b) => a > b ? a : b);
  }

  /// 计算最小持续时间
  Duration? _calculateMinDuration(List<PerformanceMetric> metrics) {
    final durations = metrics
        .where((m) => m.duration != null)
        .map((m) => m.duration!)
        .toList();

    if (durations.isEmpty) return null;

    return durations.reduce((a, b) => a < b ? a : b);
  }

  /// 获取最近的指标
  List<PerformanceMetric> _getRecentMetrics(
      List<PerformanceMetric> metrics, Duration timeWindow) {
    final cutoff = DateTime.now().subtract(timeWindow);
    return metrics.where((m) => m.timestamp.isAfter(cutoff)).toList();
  }

  /// 打印性能报告
  void printReport() {
    if (!kDebugMode) return;

    final report = getReport();
    print('\n=== 聊天性能监控报告 ===');
    print('监控时长: ${report.monitoringDuration.inMinutes} 分钟');
    print('监控状态: ${report.isEnabled ? "启用" : "禁用"}');

    for (final entry in report.categoryReports.entries) {
      final category = entry.key;
      final categoryReport = entry.value;

      print('\n[$category]');
      print('  总计数: ${categoryReport.totalCount}');
      print(
          '  平均耗时: ${categoryReport.averageDuration?.inMilliseconds ?? "N/A"} ms');
      print(
          '  最大耗时: ${categoryReport.maxDuration?.inMilliseconds ?? "N/A"} ms');
      print(
          '  最小耗时: ${categoryReport.minDuration?.inMilliseconds ?? "N/A"} ms');
      print('  最近频率: ${categoryReport.recentRate.toStringAsFixed(2)} 次/秒');
    }

    print('\n========================\n');
  }
}

/// 性能指标
class PerformanceMetric {
  final String category;
  final String name;
  final DateTime timestamp;
  final Duration? duration;
  final int? count;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.category,
    required this.name,
    required this.timestamp,
    this.duration,
    this.count,
    this.metadata,
  });

  @override
  String toString() {
    return 'PerformanceMetric(category: $category, name: $name, duration: ${duration?.inMilliseconds}ms, count: $count)';
  }
}

/// 分类报告
class CategoryReport {
  final String category;
  final int totalCount;
  final Duration? averageDuration;
  final Duration? maxDuration;
  final Duration? minDuration;
  final double recentRate;
  final List<PerformanceMetric> metrics;

  const CategoryReport({
    required this.category,
    required this.totalCount,
    this.averageDuration,
    this.maxDuration,
    this.minDuration,
    required this.recentRate,
    required this.metrics,
  });
}

/// 性能报告
class PerformanceReport {
  final Duration monitoringDuration;
  final Map<String, CategoryReport> categoryReports;
  final bool isEnabled;

  const PerformanceReport({
    required this.monitoringDuration,
    required this.categoryReports,
    required this.isEnabled,
  });
}

/// 性能监控装饰器
///
/// 用于包装方法调用并自动记录性能指标
class PerformanceDecorator {
  static T measureSync<T>(
    String category,
    String operation,
    T Function() function, {
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = function();
      stopwatch.stop();
      ChatPerformanceMonitor().recordMetric(
        category,
        operation,
        duration: stopwatch.elapsed,
        metadata: metadata,
      );
      return result;
    } catch (error) {
      stopwatch.stop();
      ChatPerformanceMonitor().recordMetric(
        category,
        '${operation}_error',
        duration: stopwatch.elapsed,
        metadata: {...?metadata, 'error': error.toString()},
      );
      rethrow;
    }
  }

  static Future<T> measureAsync<T>(
    String category,
    String operation,
    Future<T> Function() function, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      ChatPerformanceMonitor().recordMetric(
        category,
        operation,
        duration: stopwatch.elapsed,
        metadata: metadata,
      );
      return result;
    } catch (error) {
      stopwatch.stop();
      ChatPerformanceMonitor().recordMetric(
        category,
        '${operation}_error',
        duration: stopwatch.elapsed,
        metadata: {...?metadata, 'error': error.toString()},
      );
      rethrow;
    }
  }
}
