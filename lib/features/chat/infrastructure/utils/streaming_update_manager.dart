import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_state.dart';

/// Timer池管理器 - 统一管理所有Timer，避免内存泄漏
class _TimerPool {
  static final _TimerPool _instance = _TimerPool._internal();
  factory _TimerPool() => _instance;
  _TimerPool._internal();

  final Map<String, Timer> _timers = {};
  int _nextId = 0;

  /// 创建一个新的Timer
  String createTimer(Duration duration, VoidCallback callback) {
    final id = 'timer_${_nextId++}';
    _timers[id] = Timer(duration, () {
      callback();
      _timers.remove(id);
    });
    return id;
  }

  /// 取消Timer
  void cancelTimer(String id) {
    final timer = _timers.remove(id);
    timer?.cancel();
  }

  /// 检查Timer是否存在
  bool hasTimer(String id) => _timers.containsKey(id);

  /// 清理所有Timer
  void clearAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// 获取活跃Timer数量
  int get activeCount => _timers.length;
}

/// 简化的流式更新管理器
///
/// 专门用于管理流式消息更新，直接处理所有更新，不使用防抖和批处理
/// 确保流式消息的完整性和实时性
class StreamingUpdateManager {
  /// 更新回调
  final Function(StreamingUpdate) _onUpdate;

  /// 统计信息
  int _totalUpdates = 0;

  StreamingUpdateManager({
    required Function(StreamingUpdate) onUpdate,
    Duration? debounceDelay, // 保留参数以兼容现有代码，但不使用
    int? maxBatchSize, // 保留参数以兼容现有代码，但不使用
  }) : _onUpdate = onUpdate;

  /// 处理流式更新
  void handleUpdate(StreamingUpdate update) {
    _totalUpdates++;

    // 直接处理所有更新，不使用防抖或批处理
    _processUpdate(update);
  }

  /// 强制完成指定消息的更新（保留接口兼容性）
  void forceComplete(String messageId) {
    // 在简化版本中，所有更新都是立即处理的，所以这个方法不需要做任何事情
  }

  /// 强制处理所有待处理的更新（保留接口兼容性）
  void flushAll() {
    // 在简化版本中，所有更新都是立即处理的，所以这个方法不需要做任何事情
  }


  
  /// 处理单个更新
  void _processUpdate(StreamingUpdate update) {
    try {
      _onUpdate(update);
    } catch (error) {
      // 记录错误但继续处理
      developer.log('Error processing streaming update: $error', name: 'StreamingUpdateManager');
    }
  }

  /// 获取统计信息
  StreamingUpdateStats getStats() {
    return StreamingUpdateStats(
      totalUpdates: _totalUpdates,
      debouncedUpdates: 0, // 不再使用防抖
      batchedUpdates: 0, // 不再使用批处理
      skippedUpdates: 0, // 不再跳过更新
      pendingUpdates: 0, // 不再有待处理的更新
      activeTimers: 0, // 不再使用定时器
      debounceRatio: 0.0, // 不再使用防抖
      skipRatio: 0.0, // 不再跳过更新
    );
  }

  /// 重置统计信息
  void resetStats() {
    _totalUpdates = 0;
  }

  /// 释放资源
  void dispose() {
    // 简化版本中没有需要清理的资源
  }
}



/// 流式更新统计信息
class StreamingUpdateStats {
  final int totalUpdates;
  final int debouncedUpdates;
  final int batchedUpdates;
  final int skippedUpdates;
  final int pendingUpdates;
  final int activeTimers;
  final double debounceRatio;
  final double skipRatio;

  const StreamingUpdateStats({
    required this.totalUpdates,
    required this.debouncedUpdates,
    required this.batchedUpdates,
    required this.skippedUpdates,
    required this.pendingUpdates,
    required this.activeTimers,
    required this.debounceRatio,
    required this.skipRatio,
  });

  @override
  String toString() {
    return 'StreamingUpdateStats('
        'total: $totalUpdates, '
        'debounced: $debouncedUpdates, '
        'batched: $batchedUpdates, '
        'skipped: $skippedUpdates, '
        'pending: $pendingUpdates, '
        'activeTimers: $activeTimers, '
        'debounceRatio: ${(debounceRatio * 100).toStringAsFixed(1)}%, '
        'skipRatio: ${(skipRatio * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// 智能流式更新管理器（简化版本）
///
/// 现在直接继承基础管理器，不再使用智能过滤逻辑
/// 确保所有流式更新都被及时处理
class IntelligentStreamingUpdateManager extends StreamingUpdateManager {
  IntelligentStreamingUpdateManager({
    required super.onUpdate,
    super.debounceDelay, // 保留参数兼容性，但不使用
    super.maxBatchSize, // 保留参数兼容性，但不使用
    double? contentChangeThreshold, // 保留参数兼容性，但不使用
  });

  // 不再重写handleUpdate方法，直接使用父类的简化实现
}

/// 全局流式更新管理器
class GlobalStreamingUpdateManager {
  static StreamingUpdateManager? _instance;

  /// 获取全局实例（现在使用简化的管理器）
  static StreamingUpdateManager getInstance(Function(StreamingUpdate) onUpdate) {
    _instance ??= StreamingUpdateManager(onUpdate: onUpdate);
    return _instance!;
  }

  /// 释放全局实例
  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
