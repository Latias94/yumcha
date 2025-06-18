/// 流式消息调试辅助工具
///
/// 用于调试流式消息丢字问题，提供详细的日志记录和内容验证功能
library;

import '../../../../shared/infrastructure/services/logger_service.dart';

/// 流式消息调试辅助类
class StreamingDebugHelper {
  static final LoggerService _logger = LoggerService();

  /// 流式消息内容跟踪
  static final Map<String, List<String>> _contentHistory = {};

  /// 流式消息时间戳跟踪
  static final Map<String, List<DateTime>> _timestampHistory = {};

  /// 开始跟踪流式消息
  static void startTracking(String messageId) {
    _contentHistory[messageId] = [];
    _timestampHistory[messageId] = [];

    _logger.info('开始跟踪流式消息: messageId=$messageId, timestamp=${DateTime.now().toIso8601String()}');
  }

  /// 记录内容更新
  static void recordContentUpdate(String messageId, String content,
      {String? source}) {
    if (!_contentHistory.containsKey(messageId)) {
      startTracking(messageId);
    }

    final history = _contentHistory[messageId]!;
    final timestamps = _timestampHistory[messageId]!;

    history.add(content);
    timestamps.add(DateTime.now());

    _logger.debug('记录内容更新: messageId=$messageId, source=${source ?? 'unknown'}, '
        'updateIndex=${history.length - 1}, contentLength=${content.length}, '
        'contentEnding=${content.length > 20 ? '...${content.substring(content.length - 20)}' : content}, '
        'previousLength=${history.length > 1 ? history[history.length - 2].length : 0}, '
        'lengthDiff=${history.length > 1 ? content.length - history[history.length - 2].length : content.length}, '
        'timestamp=${DateTime.now().toIso8601String()}');
  }

  /// 完成跟踪并生成报告
  static Map<String, dynamic> finishTracking(String messageId) {
    final history = _contentHistory[messageId] ?? [];
    final timestamps = _timestampHistory[messageId] ?? [];

    if (history.isEmpty) {
      _logger.warning('完成跟踪但没有历史记录: messageId=$messageId');
      return {'error': 'No history found'};
    }

    final report = {
      'messageId': messageId,
      'totalUpdates': history.length,
      'finalContentLength': history.last.length,
      'finalContent': history.last,
      'contentGrowth': _analyzeContentGrowth(history),
      'timingAnalysis': _analyzeTimings(timestamps),
      'potentialIssues': _detectPotentialIssues(history, timestamps),
    };

    _logger.info('流式消息跟踪完成: messageId=$messageId, totalUpdates=${history.length}, '
        'finalLength=${history.last.length}, '
        'finalEnding=${history.last.length > 30 ? '...${history.last.substring(history.last.length - 30)}' : history.last}, '
        'duration=${timestamps.isNotEmpty && timestamps.length > 1 ? timestamps.last.difference(timestamps.first).inMilliseconds : 0}ms');

    // 清理历史记录
    _contentHistory.remove(messageId);
    _timestampHistory.remove(messageId);

    return report;
  }

  /// 分析内容增长模式
  static List<Map<String, dynamic>> _analyzeContentGrowth(
      List<String> history) {
    final growth = <Map<String, dynamic>>[];

    for (int i = 0; i < history.length; i++) {
      final current = history[i];
      final previous = i > 0 ? history[i - 1] : '';

      growth.add({
        'index': i,
        'length': current.length,
        'lengthDiff': current.length - previous.length,
        'isGrowth': current.length > previous.length,
        'isShrink': current.length < previous.length,
        'ending': current.length > 15
            ? '...${current.substring(current.length - 15)}'
            : current,
      });
    }

    return growth;
  }

  /// 分析时序模式
  static Map<String, dynamic> _analyzeTimings(List<DateTime> timestamps) {
    if (timestamps.length < 2) {
      return {'error': 'Insufficient timestamps'};
    }

    final intervals = <int>[];
    for (int i = 1; i < timestamps.length; i++) {
      intervals.add(timestamps[i].difference(timestamps[i - 1]).inMilliseconds);
    }

    intervals.sort();
    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    final medianInterval = intervals[intervals.length ~/ 2];

    return {
      'totalDuration':
          timestamps.last.difference(timestamps.first).inMilliseconds,
      'updateCount': timestamps.length,
      'averageInterval': avgInterval.round(),
      'medianInterval': medianInterval,
      'minInterval': intervals.first,
      'maxInterval': intervals.last,
    };
  }

  /// 检测潜在问题
  static List<String> _detectPotentialIssues(
      List<String> history, List<DateTime> timestamps) {
    final issues = <String>[];

    // 检查内容是否有缩减
    for (int i = 1; i < history.length; i++) {
      if (history[i].length < history[i - 1].length) {
        issues.add(
            'Content shrinkage detected at update $i: ${history[i - 1].length} -> ${history[i].length}');
      }
    }

    // 检查是否有长时间间隔
    if (timestamps.length > 1) {
      for (int i = 1; i < timestamps.length; i++) {
        final interval =
            timestamps[i].difference(timestamps[i - 1]).inMilliseconds;
        if (interval > 5000) {
          // 超过5秒
          issues.add('Long interval detected at update $i: ${interval}ms');
        }
      }
    }

    // 检查最终内容是否为空或过短
    if (history.isNotEmpty) {
      final finalContent = history.last;
      if (finalContent.isEmpty) {
        issues.add('Final content is empty');
      } else if (finalContent.length < 10) {
        issues.add(
            'Final content is suspiciously short: ${finalContent.length} characters');
      }
    }

    return issues;
  }

  /// 获取当前跟踪的消息列表
  static List<String> getTrackedMessages() {
    return _contentHistory.keys.toList();
  }

  /// 清理所有跟踪数据
  static void clearAll() {
    _contentHistory.clear();
    _timestampHistory.clear();
    _logger.info('清理所有流式消息跟踪数据');
  }
}
