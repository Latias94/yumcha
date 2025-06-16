import 'dart:async';
import 'dart:collection';

/// 状态更新类型
enum StateUpdateType {
  messageAdd,
  messageUpdate,
  messageRemove,
  conversationUpdate,
  configurationUpdate,
  streamingUpdate,
}

/// 状态更新操作
abstract class StateUpdate {
  final StateUpdateType type;
  final String key;
  final DateTime timestamp;
  final int priority;
  
  const StateUpdate({
    required this.type,
    required this.key,
    this.priority = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 应用状态更新
  void apply();
  
  /// 检查是否可以与其他更新合并
  bool canMergeWith(StateUpdate other);
  
  /// 与其他更新合并
  StateUpdate mergeWith(StateUpdate other);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateUpdate &&
        other.type == type &&
        other.key == key;
  }
  
  @override
  int get hashCode => Object.hash(type, key);
}

/// 消息添加更新
class MessageAddUpdate extends StateUpdate {
  final dynamic message;
  final Function(dynamic) addCallback;
  
  const MessageAddUpdate({
    required this.message,
    required this.addCallback,
    required String messageId,
    int priority = 0,
  }) : super(
    type: StateUpdateType.messageAdd,
    key: messageId,
    priority: priority,
  );
  
  @override
  void apply() {
    addCallback(message);
  }
  
  @override
  bool canMergeWith(StateUpdate other) {
    // 消息添加操作不能合并
    return false;
  }
  
  @override
  StateUpdate mergeWith(StateUpdate other) {
    throw UnsupportedError('MessageAddUpdate cannot be merged');
  }
}

/// 消息内容更新
class MessageContentUpdate extends StateUpdate {
  final String messageId;
  final String content;
  final dynamic status;
  final Map<String, dynamic>? metadata;
  final Function(String, String, dynamic, Map<String, dynamic>?) updateCallback;
  
  const MessageContentUpdate({
    required this.messageId,
    required this.content,
    required this.status,
    required this.updateCallback,
    this.metadata,
    int priority = 0,
  }) : super(
    type: StateUpdateType.messageUpdate,
    key: messageId,
    priority: priority,
  );
  
  @override
  void apply() {
    updateCallback(messageId, content, status, metadata);
  }
  
  @override
  bool canMergeWith(StateUpdate other) {
    return other is MessageContentUpdate && 
           other.messageId == messageId;
  }
  
  @override
  StateUpdate mergeWith(StateUpdate other) {
    if (other is MessageContentUpdate && other.messageId == messageId) {
      // 使用最新的内容和状态
      return MessageContentUpdate(
        messageId: messageId,
        content: other.content,
        status: other.status,
        updateCallback: updateCallback,
        metadata: {...?metadata, ...?other.metadata},
        priority: priority > other.priority ? priority : other.priority,
      );
    }
    throw ArgumentError('Cannot merge with incompatible update type');
  }
}

/// 流式更新
class StreamingUpdate extends StateUpdate {
  final String messageId;
  final String? fullContent;
  final bool isDone;
  final Function(String, String?, bool) streamingCallback;
  
  const StreamingUpdate({
    required this.messageId,
    required this.streamingCallback,
    this.fullContent,
    this.isDone = false,
    int priority = 0,
  }) : super(
    type: StateUpdateType.streamingUpdate,
    key: messageId,
    priority: priority,
  );
  
  @override
  void apply() {
    streamingCallback(messageId, fullContent, isDone);
  }
  
  @override
  bool canMergeWith(StateUpdate other) {
    return other is StreamingUpdate && 
           other.messageId == messageId;
  }
  
  @override
  StateUpdate mergeWith(StateUpdate other) {
    if (other is StreamingUpdate && other.messageId == messageId) {
      // 使用最新的内容，但保留完成状态
      return StreamingUpdate(
        messageId: messageId,
        fullContent: other.fullContent ?? fullContent,
        isDone: other.isDone || isDone,
        streamingCallback: streamingCallback,
        priority: priority > other.priority ? priority : other.priority,
      );
    }
    throw ArgumentError('Cannot merge with incompatible update type');
  }
}

/// 批量状态更新器
class BatchStateUpdater {
  /// 批处理间隔
  final Duration _batchInterval;
  
  /// 最大批处理大小
  final int _maxBatchSize;
  
  /// 待处理的更新队列
  final Queue<StateUpdate> _pendingUpdates = Queue();
  
  /// 更新去重映射
  final Map<String, StateUpdate> _updateMap = {};
  
  /// 批处理定时器
  Timer? _batchTimer;
  
  /// 是否正在处理批次
  bool _isProcessing = false;
  
  /// 统计信息
  int _totalUpdates = 0;
  int _mergedUpdates = 0;
  int _batchesProcessed = 0;
  
  BatchStateUpdater({
    Duration batchInterval = const Duration(milliseconds: 16), // 60fps
    int maxBatchSize = 50,
  }) : _batchInterval = batchInterval,
       _maxBatchSize = maxBatchSize;
  
  /// 添加状态更新
  void addUpdate(StateUpdate update) {
    _totalUpdates++;
    
    // 检查是否可以与现有更新合并
    final existingUpdate = _updateMap[update.key];
    if (existingUpdate != null && existingUpdate.canMergeWith(update)) {
      // 合并更新
      final mergedUpdate = existingUpdate.mergeWith(update);
      _updateMap[update.key] = mergedUpdate;
      _mergedUpdates++;
    } else {
      // 添加新更新
      _updateMap[update.key] = update;
      _pendingUpdates.add(update);
    }
    
    _scheduleBatch();
    
    // 如果批次过大，立即处理
    if (_pendingUpdates.length >= _maxBatchSize) {
      _processBatch();
    }
  }
  
  /// 强制处理当前批次
  void flush() {
    if (_pendingUpdates.isNotEmpty) {
      _processBatch();
    }
  }
  
  /// 调度批处理
  void _scheduleBatch() {
    if (_batchTimer?.isActive == true) return;
    
    _batchTimer = Timer(_batchInterval, () {
      if (!_isProcessing) {
        _processBatch();
      }
    });
  }
  
  /// 处理批次
  void _processBatch() {
    if (_isProcessing || _pendingUpdates.isEmpty) return;
    
    _isProcessing = true;
    _batchTimer?.cancel();
    
    try {
      // 按优先级排序
      final updates = _pendingUpdates.toList();
      updates.sort((a, b) => b.priority.compareTo(a.priority));
      
      // 应用所有更新
      for (final update in updates) {
        try {
          update.apply();
        } catch (error) {
          // 记录错误但继续处理其他更新
          print('Error applying state update: $error');
        }
      }
      
      // 清理
      _pendingUpdates.clear();
      _updateMap.clear();
      _batchesProcessed++;
      
    } finally {
      _isProcessing = false;
    }
  }
  
  /// 获取统计信息
  BatchUpdateStats getStats() {
    return BatchUpdateStats(
      totalUpdates: _totalUpdates,
      mergedUpdates: _mergedUpdates,
      batchesProcessed: _batchesProcessed,
      pendingUpdates: _pendingUpdates.length,
      mergeRatio: _totalUpdates > 0 ? _mergedUpdates / _totalUpdates : 0.0,
    );
  }
  
  /// 重置统计信息
  void resetStats() {
    _totalUpdates = 0;
    _mergedUpdates = 0;
    _batchesProcessed = 0;
  }
  
  /// 释放资源
  void dispose() {
    _batchTimer?.cancel();
    _pendingUpdates.clear();
    _updateMap.clear();
  }
}

/// 批量更新统计信息
class BatchUpdateStats {
  final int totalUpdates;
  final int mergedUpdates;
  final int batchesProcessed;
  final int pendingUpdates;
  final double mergeRatio;
  
  const BatchUpdateStats({
    required this.totalUpdates,
    required this.mergedUpdates,
    required this.batchesProcessed,
    required this.pendingUpdates,
    required this.mergeRatio,
  });
  
  @override
  String toString() {
    return 'BatchUpdateStats('
        'total: $totalUpdates, '
        'merged: $mergedUpdates, '
        'batches: $batchesProcessed, '
        'pending: $pendingUpdates, '
        'mergeRatio: ${(mergeRatio * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// 全局批量更新器
class GlobalBatchUpdater {
  static final BatchStateUpdater _instance = BatchStateUpdater();
  
  /// 获取全局实例
  static BatchStateUpdater get instance => _instance;
  
  /// 释放资源
  static void dispose() {
    _instance.dispose();
  }
}
