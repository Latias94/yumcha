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

/// 优化的流式更新管理器
///
/// 专门用于管理流式消息更新，提供防抖、批处理和优化功能
/// 使用单一Timer池和智能批量更新机制
class StreamingUpdateManager {
  /// 防抖延迟时间
  final Duration _debounceDelay;

  /// 最大批处理大小
  final int _maxBatchSize;

  /// 待处理的更新映射
  final Map<String, _PendingStreamingUpdate> _pendingUpdates = {};

  /// 单一Timer池管理器
  static final _TimerPool _timerPool = _TimerPool();

  /// 批处理定时器ID
  String? _batchTimerId;

  /// 更新回调
  final Function(StreamingUpdate) _onUpdate;

  /// 统计信息
  int _totalUpdates = 0;
  int _debouncedUpdates = 0;
  int _batchedUpdates = 0;
  int _skippedUpdates = 0;
  
  StreamingUpdateManager({
    required Function(StreamingUpdate) onUpdate,
    Duration debounceDelay = const Duration(milliseconds: 100),
    int maxBatchSize = 10,
  }) : _onUpdate = onUpdate,
       _debounceDelay = debounceDelay,
       _maxBatchSize = maxBatchSize;
  
  /// 防抖定时器ID映射
  final Map<String, String> _debounceTimerIds = {};

  /// 处理流式更新
  void handleUpdate(StreamingUpdate update) {
    _totalUpdates++;

    // 如果是完成状态，立即处理
    if (update.isDone) {
      _flushUpdate(update.messageId);
      _processUpdate(update);
      return;
    }

    // 检查是否应该跳过此更新（智能防抖）
    if (_shouldSkipUpdate(update)) {
      _skippedUpdates++;
      return;
    }

    // 更新待处理的更新
    _pendingUpdates[update.messageId] = _PendingStreamingUpdate(
      update: update,
      timestamp: DateTime.now(),
    );

    // 取消之前的防抖定时器
    final oldTimerId = _debounceTimerIds[update.messageId];
    if (oldTimerId != null) {
      _timerPool.cancelTimer(oldTimerId);
    }

    // 设置新的防抖定时器
    final newTimerId = _timerPool.createTimer(_debounceDelay, () {
      _flushUpdate(update.messageId);
    });
    _debounceTimerIds[update.messageId] = newTimerId;

    // 如果批次过大，立即处理
    if (_pendingUpdates.length >= _maxBatchSize) {
      _processBatch();
    } else {
      _scheduleBatch();
    }
  }

  /// 智能判断是否应该跳过更新
  bool _shouldSkipUpdate(StreamingUpdate update) {
    final existing = _pendingUpdates[update.messageId];
    if (existing == null) return false;

    // 如果内容变化很小且时间间隔很短，跳过更新
    final timeDiff = DateTime.now().difference(existing.timestamp).inMilliseconds;
    if (timeDiff < 50) { // 50ms内的重复更新
      final oldContent = existing.update.fullContent ?? '';
      final newContent = update.fullContent ?? '';

      // 如果内容变化小于5%，跳过
      if (oldContent.isNotEmpty && newContent.isNotEmpty) {
        final changeRatio = (newContent.length - oldContent.length).abs() / oldContent.length;
        if (changeRatio < 0.05) {
          return true;
        }
      }
    }

    return false;
  }
  
  /// 强制完成指定消息的更新
  void forceComplete(String messageId) {
    _flushUpdate(messageId);
  }
  
  /// 强制处理所有待处理的更新
  void flushAll() {
    if (_batchTimerId != null) {
      _timerPool.cancelTimer(_batchTimerId!);
      _batchTimerId = null;
    }
    _processBatch();
  }

  /// 刷新指定消息的更新
  void _flushUpdate(String messageId) {
    final timerId = _debounceTimerIds.remove(messageId);
    if (timerId != null) {
      _timerPool.cancelTimer(timerId);
    }

    final pending = _pendingUpdates.remove(messageId);
    if (pending != null) {
      _processUpdate(pending.update);
    }
  }

  /// 调度批处理
  void _scheduleBatch() {
    if (_batchTimerId != null && _timerPool.hasTimer(_batchTimerId!)) return;

    // 优化：增加批处理间隔，减少频繁的批处理操作
    _batchTimerId = _timerPool.createTimer(const Duration(milliseconds: 32), () {
      _processBatch();
    });
  }

  /// 处理批次
  void _processBatch() {
    if (_batchTimerId != null) {
      _timerPool.cancelTimer(_batchTimerId!);
      _batchTimerId = null;
    }

    if (_pendingUpdates.isEmpty) return;

    // 按时间戳排序，确保更新顺序
    final updates = _pendingUpdates.values.toList();
    updates.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 清理待处理的更新和定时器
    for (final update in updates) {
      final timerId = _debounceTimerIds.remove(update.update.messageId);
      if (timerId != null) {
        _timerPool.cancelTimer(timerId);
      }
    }
    _pendingUpdates.clear();

    // 批量处理更新
    _batchedUpdates += updates.length;
    for (final pending in updates) {
      _processUpdate(pending.update);
    }
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
      debouncedUpdates: _debouncedUpdates,
      batchedUpdates: _batchedUpdates,
      skippedUpdates: _skippedUpdates,
      pendingUpdates: _pendingUpdates.length,
      activeTimers: _timerPool.activeCount,
      debounceRatio: _totalUpdates > 0 ? _debouncedUpdates / _totalUpdates : 0.0,
      skipRatio: _totalUpdates > 0 ? _skippedUpdates / _totalUpdates : 0.0,
    );
  }

  /// 重置统计信息
  void resetStats() {
    _totalUpdates = 0;
    _debouncedUpdates = 0;
    _batchedUpdates = 0;
    _skippedUpdates = 0;
  }

  /// 释放资源
  void dispose() {
    // 取消批处理定时器
    if (_batchTimerId != null) {
      _timerPool.cancelTimer(_batchTimerId!);
      _batchTimerId = null;
    }

    // 取消所有防抖定时器
    for (final timerId in _debounceTimerIds.values) {
      _timerPool.cancelTimer(timerId);
    }
    _debounceTimerIds.clear();
    _pendingUpdates.clear();
  }
}

/// 待处理的流式更新
class _PendingStreamingUpdate {
  final StreamingUpdate update;
  final DateTime timestamp;
  
  _PendingStreamingUpdate({
    required this.update,
    required this.timestamp,
  });
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

/// 智能流式更新管理器
/// 
/// 提供更智能的更新策略，根据内容变化程度调整更新频率
class IntelligentStreamingUpdateManager extends StreamingUpdateManager {
  /// 内容变化阈值
  final double _contentChangeThreshold;
  
  /// 最后处理的内容映射
  final Map<String, String> _lastContent = {};
  
  /// 内容变化历史
  final Map<String, List<double>> _changeHistory = {};
  
  IntelligentStreamingUpdateManager({
    required super.onUpdate,
    super.debounceDelay = const Duration(milliseconds: 100),
    super.maxBatchSize = 10,
    double contentChangeThreshold = 0.1, // 10%的内容变化才触发更新
  }) : _contentChangeThreshold = contentChangeThreshold;
  
  @override
  void handleUpdate(StreamingUpdate update) {
    // 如果是完成状态，直接处理
    if (update.isDone) {
      _lastContent.remove(update.messageId);
      _changeHistory.remove(update.messageId);
      super.handleUpdate(update);
      return;
    }
    
    // 计算内容变化程度
    final currentContent = update.fullContent ?? '';
    final lastContent = _lastContent[update.messageId] ?? '';
    final changeRatio = _calculateChangeRatio(lastContent, currentContent);
    
    // 记录变化历史
    _changeHistory.putIfAbsent(update.messageId, () => []).add(changeRatio);
    if (_changeHistory[update.messageId]!.length > 10) {
      _changeHistory[update.messageId]!.removeAt(0);
    }
    
    // 根据变化程度决定是否更新
    if (changeRatio >= _contentChangeThreshold || _shouldForceUpdate(update.messageId)) {
      _lastContent[update.messageId] = currentContent;
      super.handleUpdate(update);
    }
  }
  
  /// 计算内容变化比例
  double _calculateChangeRatio(String oldContent, String newContent) {
    if (oldContent.isEmpty) return 1.0;
    if (newContent.isEmpty) return 1.0;
    
    final lengthDiff = (newContent.length - oldContent.length).abs();
    final maxLength = oldContent.length > newContent.length ? oldContent.length : newContent.length;
    
    return lengthDiff / maxLength;
  }
  
  /// 判断是否应该强制更新
  bool _shouldForceUpdate(String messageId) {
    final history = _changeHistory[messageId];
    if (history == null || history.length < 5) return false;
    
    // 如果最近的变化都很小，强制更新一次
    final recentChanges = history.take(5);
    final avgChange = recentChanges.reduce((a, b) => a + b) / recentChanges.length;
    
    return avgChange < _contentChangeThreshold * 0.5;
  }
  
  @override
  void dispose() {
    _lastContent.clear();
    _changeHistory.clear();
    super.dispose();
  }
}

/// 全局流式更新管理器
class GlobalStreamingUpdateManager {
  static StreamingUpdateManager? _instance;
  
  /// 获取全局实例
  static StreamingUpdateManager getInstance(Function(StreamingUpdate) onUpdate) {
    _instance ??= IntelligentStreamingUpdateManager(onUpdate: onUpdate);
    return _instance!;
  }
  
  /// 释放全局实例
  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
