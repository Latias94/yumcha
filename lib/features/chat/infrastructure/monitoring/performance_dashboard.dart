// 🚀 阶段6：性能监控仪表板
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:yumcha/features/chat/infrastructure/utils/performance_monitor.dart';
import 'package:yumcha/features/chat/data/repositories/message_repository_impl.dart';
import 'package:yumcha/shared/infrastructure/services/logger_service.dart';

/// 性能监控仪表板
/// 
/// 提供统一的性能监控、报告生成和性能分析功能
class PerformanceDashboard {
  static final PerformanceDashboard _instance = PerformanceDashboard._internal();
  factory PerformanceDashboard() => _instance;
  PerformanceDashboard._internal();

  final LoggerService _logger = LoggerService();
  final ChatPerformanceMonitor _performanceMonitor = ChatPerformanceMonitor();
  
  Timer? _reportTimer;
  bool _isEnabled = kDebugMode;
  
  /// 性能阈值配置
  static const Map<String, int> _performanceThresholds = {
    'message_creation_ms': 1,
    'message_filtering_us': 10,
    'batch_processing_ms': 100,
    'database_operation_ms': 500,
    'ui_render_ms': 16, // 60fps
  };

  /// 启用性能监控仪表板
  void enable({Duration reportInterval = const Duration(minutes: 5)}) {
    if (_isEnabled) return;
    
    _isEnabled = true;
    _performanceMonitor.enable();
    
    // 定期生成性能报告
    _reportTimer = Timer.periodic(reportInterval, (_) {
      generatePerformanceReport();
    });
    
    _logger.info('性能监控仪表板已启用', {
      'reportInterval': reportInterval.inMinutes,
    });
  }

  /// 禁用性能监控仪表板
  void disable() {
    _isEnabled = false;
    _performanceMonitor.disable();
    _reportTimer?.cancel();
    _reportTimer = null;
    
    _logger.info('性能监控仪表板已禁用');
  }

  /// 生成综合性能报告
  PerformanceDashboardReport generatePerformanceReport() {
    if (!_isEnabled) {
      return PerformanceDashboardReport.empty();
    }

    final chatReport = _performanceMonitor.getReport();
    final chatSummary = _performanceMonitor.getPerformanceSummary();
    
    // 获取数据库性能统计（如果可用）
    Map<String, Map<String, dynamic>> dbStats = {};
    try {
      // 这里需要访问MessageRepository的性能统计
      // 在实际实现中，可以通过依赖注入获取
      // dbStats = messageRepository.getPerformanceStats();
    } catch (e) {
      _logger.warning('无法获取数据库性能统计', {'error': e.toString()});
    }

    final report = PerformanceDashboardReport(
      timestamp: DateTime.now(),
      chatPerformance: chatReport,
      chatSummary: chatSummary,
      databasePerformance: dbStats,
      performanceAlerts: _generatePerformanceAlerts(chatSummary, dbStats),
      systemHealth: _assessSystemHealth(chatSummary, dbStats),
    );

    // 记录报告生成
    _logger.info('性能报告已生成', {
      'alertCount': report.performanceAlerts.length,
      'systemHealth': report.systemHealth.name,
      'monitoringDuration': chatReport.monitoringDuration.inMinutes,
    });

    // 在调试模式下打印报告
    if (kDebugMode) {
      _printPerformanceReport(report);
    }

    return report;
  }

  /// 生成性能警报
  List<PerformanceAlert> _generatePerformanceAlerts(
    Map<String, dynamic> chatSummary,
    Map<String, Map<String, dynamic>> dbStats,
  ) {
    final alerts = <PerformanceAlert>[];

    // 检查聊天性能指标
    for (final entry in chatSummary.entries) {
      if (entry.key.endsWith('_avg_duration_ms') && entry.value != null) {
        final avgDuration = entry.value as int;
        final category = entry.key.replaceAll('_avg_duration_ms', '');
        
        if (_isPerformanceThresholdExceeded(category, avgDuration)) {
          alerts.add(PerformanceAlert(
            type: PerformanceAlertType.slowOperation,
            category: category,
            message: '$category 平均耗时 ${avgDuration}ms 超过阈值',
            severity: _getAlertSeverity(avgDuration),
            timestamp: DateTime.now(),
            metadata: {'avgDuration': avgDuration},
          ));
        }
      }
    }

    // 检查数据库性能指标
    for (final entry in dbStats.entries) {
      final operation = entry.key;
      final stats = entry.value;
      final avgMs = stats['avg_ms'] as int?;
      
      if (avgMs != null && avgMs > (_performanceThresholds['database_operation_ms'] ?? 500)) {
        alerts.add(PerformanceAlert(
          type: PerformanceAlertType.slowDatabase,
          category: 'database_$operation',
          message: '数据库操作 $operation 平均耗时 ${avgMs}ms 过高',
          severity: PerformanceAlertSeverity.warning,
          timestamp: DateTime.now(),
          metadata: stats,
        ));
      }
    }

    return alerts;
  }

  /// 评估系统健康状态
  SystemHealthStatus _assessSystemHealth(
    Map<String, dynamic> chatSummary,
    Map<String, Map<String, dynamic>> dbStats,
  ) {
    int healthScore = 100;
    
    // 检查聊天性能
    final messageProcessingRate = chatSummary['message_processing_recent_rate_per_sec'];
    if (messageProcessingRate != null) {
      final rate = double.tryParse(messageProcessingRate.toString()) ?? 0.0;
      if (rate > 10) healthScore -= 20; // 处理频率过高
    }

    // 检查数据库性能
    for (final stats in dbStats.values) {
      final avgMs = stats['avg_ms'] as int? ?? 0;
      if (avgMs > 1000) healthScore -= 30; // 数据库操作过慢
      if (avgMs > 500) healthScore -= 15;
    }

    // 检查错误率
    // 这里可以添加更多的健康检查逻辑

    if (healthScore >= 90) return SystemHealthStatus.excellent;
    if (healthScore >= 70) return SystemHealthStatus.good;
    if (healthScore >= 50) return SystemHealthStatus.warning;
    return SystemHealthStatus.critical;
  }

  /// 检查性能阈值是否超过
  bool _isPerformanceThresholdExceeded(String category, int value) {
    final threshold = _performanceThresholds['${category}_ms'] ?? 
                     _performanceThresholds['${category}_us'];
    return threshold != null && value > threshold;
  }

  /// 获取警报严重程度
  PerformanceAlertSeverity _getAlertSeverity(int value) {
    if (value > 1000) return PerformanceAlertSeverity.critical;
    if (value > 500) return PerformanceAlertSeverity.warning;
    return PerformanceAlertSeverity.info;
  }

  /// 打印性能报告
  void _printPerformanceReport(PerformanceDashboardReport report) {
    print('\n🚀 ===== 性能监控仪表板报告 =====');
    print('📅 生成时间: ${report.timestamp}');
    print('🏥 系统健康: ${report.systemHealth.displayName}');
    print('⚠️  性能警报: ${report.performanceAlerts.length} 个');
    
    if (report.performanceAlerts.isNotEmpty) {
      print('\n📋 性能警报详情:');
      for (final alert in report.performanceAlerts) {
        print('  ${alert.severity.icon} [${alert.category}] ${alert.message}');
      }
    }

    print('\n📊 聊天性能摘要:');
    for (final entry in report.chatSummary.entries) {
      if (entry.value != null) {
        print('  ${entry.key}: ${entry.value}');
      }
    }

    if (report.databasePerformance.isNotEmpty) {
      print('\n💾 数据库性能:');
      for (final entry in report.databasePerformance.entries) {
        final stats = entry.value;
        print('  ${entry.key}: 平均${stats['avg_ms']}ms, P95=${stats['p95_ms']}ms, 次数=${stats['count']}');
      }
    }

    print('================================\n');
  }

  /// 导出性能报告为JSON
  String exportReportAsJson(PerformanceDashboardReport report) {
    return jsonEncode(report.toJson());
  }

  /// 获取性能趋势数据
  Map<String, List<double>> getPerformanceTrends({Duration period = const Duration(hours: 1)}) {
    // 这里可以实现性能趋势分析
    // 返回各个指标在指定时间段内的变化趋势
    return {};
  }

  /// 重置所有性能数据
  void resetAllMetrics() {
    _performanceMonitor.reset();
    _logger.info('所有性能指标已重置');
  }
}

/// 性能仪表板报告
class PerformanceDashboardReport {
  final DateTime timestamp;
  final PerformanceReport chatPerformance;
  final Map<String, dynamic> chatSummary;
  final Map<String, Map<String, dynamic>> databasePerformance;
  final List<PerformanceAlert> performanceAlerts;
  final SystemHealthStatus systemHealth;

  const PerformanceDashboardReport({
    required this.timestamp,
    required this.chatPerformance,
    required this.chatSummary,
    required this.databasePerformance,
    required this.performanceAlerts,
    required this.systemHealth,
  });

  factory PerformanceDashboardReport.empty() {
    return PerformanceDashboardReport(
      timestamp: DateTime.now(),
      chatPerformance: PerformanceReport(
        monitoringDuration: Duration.zero,
        categoryReports: {},
        isEnabled: false,
      ),
      chatSummary: {},
      databasePerformance: {},
      performanceAlerts: [],
      systemHealth: SystemHealthStatus.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'systemHealth': systemHealth.name,
      'alertCount': performanceAlerts.length,
      'chatSummary': chatSummary,
      'databasePerformance': databasePerformance,
      'alerts': performanceAlerts.map((a) => a.toJson()).toList(),
    };
  }
}

/// 性能警报
class PerformanceAlert {
  final PerformanceAlertType type;
  final String category;
  final String message;
  final PerformanceAlertSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PerformanceAlert({
    required this.type,
    required this.category,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'category': category,
      'message': message,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// 性能警报类型
enum PerformanceAlertType {
  slowOperation,
  slowDatabase,
  highMemoryUsage,
  highCpuUsage,
  errorRateHigh,
}

/// 性能警报严重程度
enum PerformanceAlertSeverity {
  info,
  warning,
  critical;

  String get icon {
    switch (this) {
      case PerformanceAlertSeverity.info:
        return 'ℹ️';
      case PerformanceAlertSeverity.warning:
        return '⚠️';
      case PerformanceAlertSeverity.critical:
        return '🚨';
    }
  }
}

/// 系统健康状态
enum SystemHealthStatus {
  excellent,
  good,
  warning,
  critical,
  unknown;

  String get displayName {
    switch (this) {
      case SystemHealthStatus.excellent:
        return '优秀 🟢';
      case SystemHealthStatus.good:
        return '良好 🟡';
      case SystemHealthStatus.warning:
        return '警告 🟠';
      case SystemHealthStatus.critical:
        return '严重 🔴';
      case SystemHealthStatus.unknown:
        return '未知 ⚪';
    }
  }
}
