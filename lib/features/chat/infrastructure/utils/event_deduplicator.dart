import 'dart:async';
import 'dart:collection';
import '../../domain/entities/chat_state.dart';

/// 事件去重器
/// 
/// 用于防止短时间内的重复事件发送，提升性能和用户体验
class EventDeduplicator {
  /// 最小事件间隔
  final Duration _minInterval;
  
  /// 最后事件时间记录
  final Map<Type, DateTime> _lastEvents = {};
  
  /// 事件内容哈希记录（用于内容去重）
  final Map<Type, String> _lastEventHashes = {};
  
  /// 待处理的事件队列
  final Map<Type, _PendingEvent> _pendingEvents = {};
  
  /// 清理定时器
  Timer? _cleanupTimer;
  
  /// 最大记录数量，防止内存泄漏
  static const int _maxRecords = 100;
  
  EventDeduplicator({
    Duration minInterval = const Duration(milliseconds: 50),
  }) : _minInterval = minInterval {
    _startCleanupTimer();
  }
  
  /// 检查是否应该发送事件
  bool shouldEmit<T extends ChatEvent>(T event) {
    final eventType = T;
    final now = DateTime.now();
    final lastEvent = _lastEvents[eventType];
    
    // 检查时间间隔
    if (lastEvent != null && now.difference(lastEvent) < _minInterval) {
      return false;
    }
    
    // 检查内容是否相同（避免重复的相同内容事件）
    final eventHash = _generateEventHash(event);
    final lastHash = _lastEventHashes[eventType];
    if (lastHash == eventHash) {
      return false;
    }
    
    // 更新记录
    _lastEvents[eventType] = now;
    _lastEventHashes[eventType] = eventHash;
    _cleanupIfNeeded();
    
    return true;
  }
  
  /// 延迟发送事件（带去重）
  void scheduleEmit<T extends ChatEvent>(T event, Function(T) emitCallback) {
    final eventType = T;
    
    // 取消之前的待处理事件
    _pendingEvents[eventType]?.timer.cancel();
    
    // 检查是否可以立即发送
    if (shouldEmit(event)) {
      emitCallback(event);
      return;
    }
    
    // 计算延迟时间
    final lastEvent = _lastEvents[eventType];
    if (lastEvent != null) {
      final elapsed = DateTime.now().difference(lastEvent);
      final delay = _minInterval - elapsed;
      
      // 调度延迟发送
      final timer = Timer(delay, () {
        _pendingEvents.remove(eventType);
        if (shouldEmit(event)) {
          emitCallback(event);
        }
      });
      
      _pendingEvents[eventType] = _PendingEvent(timer, event, emitCallback);
    }
  }
  
  /// 强制发送事件（忽略去重）
  void forceEmit<T extends ChatEvent>(T event, Function(T) emitCallback) {
    final eventType = T;
    
    // 取消待处理的事件
    _pendingEvents[eventType]?.timer.cancel();
    _pendingEvents.remove(eventType);
    
    // 更新时间戳和哈希
    _lastEvents[eventType] = DateTime.now();
    _lastEventHashes[eventType] = _generateEventHash(event);
    
    // 发送事件
    emitCallback(event);
    
    _cleanupIfNeeded();
  }
  
  /// 取消待处理的事件
  void cancelPending<T extends ChatEvent>() {
    final eventType = T;
    final pending = _pendingEvents.remove(eventType);
    pending?.timer.cancel();
  }
  
  /// 获取统计信息
  EventDeduplicationStats getStats() {
    return EventDeduplicationStats(
      totalEventTypes: _lastEvents.length,
      pendingEvents: _pendingEvents.length,
      oldestRecord: _lastEvents.values.isEmpty 
          ? null 
          : _lastEvents.values.reduce((a, b) => a.isBefore(b) ? a : b),
    );
  }
  
  /// 生成事件哈希
  String _generateEventHash(ChatEvent event) {
    // 根据事件类型生成不同的哈希
    switch (event.runtimeType) {
      case MessageAddedEvent:
        final e = event as MessageAddedEvent;
        return '${e.message.id}_${e.message.content.hashCode}';
      case MessageUpdatedEvent:
        final e = event as MessageUpdatedEvent;
        return '${e.updatedMessage.id}_${e.updatedMessage.content.hashCode}';
      case ErrorOccurredEvent:
        final e = event as ErrorOccurredEvent;
        return '${e.error}_${e.context}';
      case ConfigurationChangedEvent:
        final e = event as ConfigurationChangedEvent;
        return '${e.assistant?.id}_${e.provider?.id}_${e.model?.name}';
      default:
        return event.toString().hashCode.toString();
    }
  }
  
  /// 清理过期记录
  void _cleanupIfNeeded() {
    if (_lastEvents.length > _maxRecords) {
      _performCleanup();
    }
  }
  
  /// 执行清理
  void _performCleanup() {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(minutes: 5)); // 保留5分钟内的记录
    
    _lastEvents.removeWhere((type, time) => time.isBefore(cutoff));
    
    // 清理对应的哈希记录
    final validTypes = _lastEvents.keys.toSet();
    _lastEventHashes.removeWhere((type, hash) => !validTypes.contains(type));
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
    
    // 取消所有待处理的事件
    for (final pending in _pendingEvents.values) {
      pending.timer.cancel();
    }
    _pendingEvents.clear();
    _lastEvents.clear();
    _lastEventHashes.clear();
  }
}

/// 待处理的事件
class _PendingEvent {
  final Timer timer;
  final ChatEvent event;
  final Function(ChatEvent) callback;
  
  _PendingEvent(this.timer, this.event, this.callback);
}

/// 事件去重统计信息
class EventDeduplicationStats {
  final int totalEventTypes;
  final int pendingEvents;
  final DateTime? oldestRecord;
  
  const EventDeduplicationStats({
    required this.totalEventTypes,
    required this.pendingEvents,
    this.oldestRecord,
  });
  
  @override
  String toString() {
    return 'EventDeduplicationStats(totalEventTypes: $totalEventTypes, pendingEvents: $pendingEvents, oldestRecord: $oldestRecord)';
  }
}

/// 智能事件去重器
/// 
/// 根据事件类型和重要性调整去重策略
class IntelligentEventDeduplicator extends EventDeduplicator {
  /// 事件优先级映射
  static const Map<Type, EventPriority> _eventPriorities = {
    MessageAddedEvent: EventPriority.high,
    MessageUpdatedEvent: EventPriority.normal,
    ErrorOccurredEvent: EventPriority.critical,
    ConfigurationChangedEvent: EventPriority.low,
    ConversationChangedEvent: EventPriority.normal,
    StreamingCompletedEvent: EventPriority.high,
  };
  
  IntelligentEventDeduplicator() : super(
    minInterval: const Duration(milliseconds: 50),
  );
  
  @override
  bool shouldEmit<T extends ChatEvent>(T event) {
    final priority = _eventPriorities[T] ?? EventPriority.normal;
    
    // 关键事件总是发送
    if (priority == EventPriority.critical) {
      _lastEvents[T] = DateTime.now();
      _lastEventHashes[T] = _generateEventHash(event);
      return true;
    }
    
    // 高优先级事件使用更短的间隔
    final interval = priority == EventPriority.high 
        ? Duration(milliseconds: 25)
        : _minInterval;
    
    final now = DateTime.now();
    final lastEvent = _lastEvents[T];
    
    if (lastEvent != null && now.difference(lastEvent) < interval) {
      return false;
    }
    
    // 检查内容去重
    final eventHash = _generateEventHash(event);
    final lastHash = _lastEventHashes[T];
    if (lastHash == eventHash && priority != EventPriority.high) {
      return false;
    }
    
    _lastEvents[T] = now;
    _lastEventHashes[T] = eventHash;
    return true;
  }
}

/// 事件优先级
enum EventPriority {
  low,
  normal,
  high,
  critical,
}

/// 全局事件去重器
class GlobalEventDeduplicator {
  static final IntelligentEventDeduplicator _instance = IntelligentEventDeduplicator();
  
  /// 获取全局实例
  static IntelligentEventDeduplicator get instance => _instance;
  
  /// 释放资源
  static void dispose() {
    _instance.dispose();
  }
}
