import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 状态更新去重器
/// 
/// 用于防止短时间内的重复状态更新，提升性能和用户体验
class StateUpdateDeduplicator {
  /// 最小更新间隔
  final Duration _minInterval;
  
  /// 最后更新时间记录
  final Map<String, DateTime> _lastUpdates = {};
  
  /// 待处理的更新队列
  final Map<String, _PendingUpdate> _pendingUpdates = {};
  
  /// 清理定时器
  Timer? _cleanupTimer;
  
  /// 最大记录数量，防止内存泄漏
  static const int _maxRecords = 1000;
  
  StateUpdateDeduplicator({
    Duration minInterval = const Duration(milliseconds: 16), // 60fps
  }) : _minInterval = minInterval {
    _startCleanupTimer();
  }
  
  /// 检查是否应该执行更新
  bool shouldUpdate(String key) {
    final now = DateTime.now();
    final lastUpdate = _lastUpdates[key];
    
    if (lastUpdate == null || now.difference(lastUpdate) >= _minInterval) {
      _lastUpdates[key] = now;
      _cleanupIfNeeded();
      return true;
    }
    
    return false;
  }
  
  /// 延迟执行更新（带去重）
  void scheduleUpdate(String key, VoidCallback callback) {
    // 取消之前的待处理更新
    _pendingUpdates[key]?.timer.cancel();
    
    // 检查是否可以立即执行
    if (shouldUpdate(key)) {
      callback();
      return;
    }
    
    // 计算延迟时间
    final lastUpdate = _lastUpdates[key]!;
    final elapsed = DateTime.now().difference(lastUpdate);
    final delay = _minInterval - elapsed;
    
    // 调度延迟执行
    final timer = Timer(delay, () {
      _pendingUpdates.remove(key);
      if (shouldUpdate(key)) {
        callback();
      }
    });
    
    _pendingUpdates[key] = _PendingUpdate(timer, callback);
  }
  
  /// 强制执行更新（忽略去重）
  void forceUpdate(String key, VoidCallback callback) {
    // 取消待处理的更新
    _pendingUpdates[key]?.timer.cancel();
    _pendingUpdates.remove(key);
    
    // 更新时间戳
    _lastUpdates[key] = DateTime.now();
    
    // 执行回调
    callback();
    
    _cleanupIfNeeded();
  }
  
  /// 取消待处理的更新
  void cancelUpdate(String key) {
    final pending = _pendingUpdates.remove(key);
    pending?.timer.cancel();
  }
  
  /// 获取统计信息
  StateUpdateStats getStats() {
    return StateUpdateStats(
      totalKeys: _lastUpdates.length,
      pendingUpdates: _pendingUpdates.length,
      oldestRecord: _lastUpdates.values.isEmpty 
          ? null 
          : _lastUpdates.values.reduce((a, b) => a.isBefore(b) ? a : b),
    );
  }
  
  /// 清理过期记录
  void _cleanupIfNeeded() {
    if (_lastUpdates.length > _maxRecords) {
      _performCleanup();
    }
  }
  
  /// 执行清理
  void _performCleanup() {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(minutes: 5)); // 保留5分钟内的记录
    
    _lastUpdates.removeWhere((key, time) => time.isBefore(cutoff));
  }
  
  /// 启动定期清理
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _performCleanup();
    });
  }
  
  /// 释放资源
  void dispose() {
    _cleanupTimer?.cancel();
    
    // 取消所有待处理的更新
    for (final pending in _pendingUpdates.values) {
      pending.timer.cancel();
    }
    _pendingUpdates.clear();
    _lastUpdates.clear();
  }
}

/// 待处理的更新
class _PendingUpdate {
  final Timer timer;
  final VoidCallback callback;
  
  _PendingUpdate(this.timer, this.callback);
}

/// 状态更新统计信息
class StateUpdateStats {
  final int totalKeys;
  final int pendingUpdates;
  final DateTime? oldestRecord;
  
  const StateUpdateStats({
    required this.totalKeys,
    required this.pendingUpdates,
    this.oldestRecord,
  });
  
  @override
  String toString() {
    return 'StateUpdateStats(totalKeys: $totalKeys, pendingUpdates: $pendingUpdates, oldestRecord: $oldestRecord)';
  }
}

/// 消息状态更新去重器
///
/// 专门用于消息相关的状态更新去重
class MessageStateDeduplicator extends StateUpdateDeduplicator {
  /// 流式消息ID集合，用于特殊处理
  final Set<String> _streamingMessageIds = <String>{};

  /// 最后内容记录，用于内容变化检测
  final Map<String, String> _lastContent = <String, String>{};

  MessageStateDeduplicator() : super(
    minInterval: const Duration(milliseconds: 50), // 消息更新稍微宽松一些
  );

  /// 标记消息为流式状态
  void markAsStreaming(String messageId) {
    _streamingMessageIds.add(messageId);
  }

  /// 取消流式状态标记
  void unmarkAsStreaming(String messageId) {
    _streamingMessageIds.remove(messageId);
    _lastContent.remove(messageId);
  }

  /// 检查消息内容更新是否应该执行
  bool shouldUpdateMessageContent(String messageId, String newContent) {
    // 🚀 修复：对于流式消息，使用更宽松的去重策略
    if (_streamingMessageIds.contains(messageId)) {
      return _shouldUpdateStreamingContent(messageId, newContent);
    }

    final key = 'message_content_$messageId';
    return shouldUpdate(key);
  }

  /// 流式消息内容更新检查
  bool _shouldUpdateStreamingContent(String messageId, String newContent) {
    final lastContent = _lastContent[messageId];

    // 如果是第一次更新，直接允许
    if (lastContent == null) {
      _lastContent[messageId] = newContent;
      return true;
    }

    // 如果内容确实发生了变化，允许更新
    if (lastContent != newContent) {
      _lastContent[messageId] = newContent;
      return true;
    }

    // 内容相同，跳过更新
    return false;
  }

  /// 检查消息状态更新是否应该执行
  bool shouldUpdateMessageStatus(String messageId, String newStatus) {
    final key = 'message_status_$messageId';
    return shouldUpdate(key);
  }

  /// 调度消息内容更新
  void scheduleMessageContentUpdate(String messageId, String newContent, VoidCallback callback) {
    final key = 'message_content_$messageId';
    scheduleUpdate(key, callback);
  }

  @override
  void dispose() {
    _streamingMessageIds.clear();
    _lastContent.clear();
    super.dispose();
  }
  
  /// 调度消息状态更新
  void scheduleMessageStatusUpdate(String messageId, String newStatus, VoidCallback callback) {
    final key = 'message_status_$messageId';
    scheduleUpdate(key, callback);
  }
}

/// 流式更新去重器
/// 
/// 专门用于流式消息更新的去重处理
class StreamingUpdateDeduplicator extends StateUpdateDeduplicator {
  StreamingUpdateDeduplicator() : super(
    minInterval: const Duration(milliseconds: 100), // 流式更新间隔稍长
  );
  
  /// 检查流式更新是否应该执行
  bool shouldUpdateStreaming(String messageId) {
    final key = 'streaming_$messageId';
    return shouldUpdate(key);
  }
  
  /// 调度流式更新
  void scheduleStreamingUpdate(String messageId, VoidCallback callback) {
    final key = 'streaming_$messageId';
    scheduleUpdate(key, callback);
  }
  
  /// 强制执行流式更新完成
  void forceStreamingComplete(String messageId, VoidCallback callback) {
    final key = 'streaming_$messageId';
    forceUpdate(key, callback);
  }
}

/// 全局去重器实例
class GlobalDeduplicators {
  static final StateUpdateDeduplicator _general = StateUpdateDeduplicator();
  static final MessageStateDeduplicator _message = MessageStateDeduplicator();
  static final StreamingUpdateDeduplicator _streaming = StreamingUpdateDeduplicator();
  
  /// 通用状态更新去重器
  static StateUpdateDeduplicator get general => _general;
  
  /// 消息状态更新去重器
  static MessageStateDeduplicator get message => _message;
  
  /// 流式更新去重器
  static StreamingUpdateDeduplicator get streaming => _streaming;
  
  /// 释放所有资源
  static void disposeAll() {
    _general.dispose();
    _message.dispose();
    _streaming.dispose();
  }
}
