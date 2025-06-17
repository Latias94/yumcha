import 'package:flutter/foundation.dart';
import '../entities/message_status.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 消息状态转换事件
enum MessageStateEvent {
  /// 开始处理AI消息
  startAiProcessing,
  
  /// 开始流式传输
  startStreaming,
  
  /// 流式传输中
  streaming,
  
  /// 完成处理
  complete,
  
  /// 发生错误
  error,
  
  /// 暂停处理
  pause,
  
  /// 恢复处理
  resume,
  
  /// 重试处理
  retry,
  
  /// 取消处理
  cancel,
}

/// 状态转换记录（用于历史追踪和调试）
@immutable
class StateTransitionRecord {
  final MessageStatus fromStatus;
  final MessageStatus toStatus;
  final MessageStateEvent? event;
  final bool isSuccess;
  final String? errorMessage;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const StateTransitionRecord({
    required this.fromStatus,
    required this.toStatus,
    this.event,
    required this.isSuccess,
    this.errorMessage,
    required this.timestamp,
    this.metadata,
  });

  @override
  String toString() {
    final eventStr = event != null ? ' (${event!.name})' : '';
    final statusStr = isSuccess ? '✅' : '❌';
    return '$statusStr ${fromStatus.name} -> ${toStatus.name}$eventStr @ ${timestamp.toIso8601String()}';
  }
}

/// 状态转换结果
@immutable
class StateTransitionResult {
  final MessageStatus newStatus;
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const StateTransitionResult({
    required this.newStatus,
    required this.isValid,
    this.errorMessage,
    this.metadata,
  });

  const StateTransitionResult.success(MessageStatus status, {Map<String, dynamic>? metadata})
      : newStatus = status,
        isValid = true,
        errorMessage = null,
        metadata = metadata;

  const StateTransitionResult.invalid(String error)
      : newStatus = MessageStatus.aiError,
        isValid = false,
        errorMessage = error,
        metadata = null;
}

/// 消息状态机
///
/// 管理消息状态的转换，确保状态转换的合法性和一致性
/// 特别适用于AI聊天场景中的复杂状态管理
///
/// 核心功能：
/// - 🔄 状态转换验证：确保只允许合法的状态转换
/// - 📊 状态优先级管理：处理并发状态冲突
/// - 🎯 事件驱动：通过事件触发状态转换
/// - 🛡️ 错误处理：提供详细的错误信息和恢复建议
/// - 📈 状态分析：提供状态统计和分析功能
class MessageStateMachine {
  final LoggerService _logger = LoggerService();

  /// 状态转换历史记录（用于调试和分析）
  final List<StateTransitionRecord> _transitionHistory = [];

  /// 最大历史记录数量
  static const int _maxHistorySize = 100;
  
  /// 状态转换映射表
  static const Map<MessageStatus, Set<MessageStatus>> _allowedTransitions = {
    // 用户消息状态（通常不会改变）
    MessageStatus.userSuccess: {
      MessageStatus.userSuccess, // 允许重复设置
    },
    
    // AI消息状态转换
    MessageStatus.aiPending: {
      MessageStatus.aiProcessing,
      MessageStatus.aiStreaming,
      MessageStatus.aiError,
      MessageStatus.aiPaused,
    },
    
    MessageStatus.aiProcessing: {
      MessageStatus.aiStreaming,
      MessageStatus.aiSuccess,
      MessageStatus.aiError,
      MessageStatus.aiPaused,
    },
    
    MessageStatus.aiStreaming: {
      MessageStatus.aiSuccess,
      MessageStatus.aiError,
      MessageStatus.aiPaused,
      MessageStatus.aiStreaming, // 允许流式过程中的状态更新
    },
    
    MessageStatus.aiSuccess: {
      MessageStatus.aiSuccess, // 允许重复设置
      MessageStatus.aiProcessing, // 允许重新生成
    },
    
    MessageStatus.aiError: {
      MessageStatus.aiPending,
      MessageStatus.aiProcessing,
      MessageStatus.aiStreaming,
      MessageStatus.aiError, // 允许重复设置错误
    },
    
    MessageStatus.aiPaused: {
      MessageStatus.aiProcessing,
      MessageStatus.aiStreaming,
      MessageStatus.aiError,
      MessageStatus.aiSuccess,
    },
    
    // 系统消息状态
    MessageStatus.system: {
      MessageStatus.system,
    },
    
    // 临时消息状态
    MessageStatus.temporary: {
      MessageStatus.userSuccess,
      MessageStatus.aiPending,
      MessageStatus.aiProcessing,
      MessageStatus.aiStreaming,
      MessageStatus.aiSuccess,
      MessageStatus.aiError,
    },
  };

  /// 事件到状态的映射
  static const Map<MessageStateEvent, MessageStatus> _eventToStatus = {
    MessageStateEvent.startAiProcessing: MessageStatus.aiProcessing,
    MessageStateEvent.startStreaming: MessageStatus.aiStreaming,
    MessageStateEvent.streaming: MessageStatus.aiStreaming,
    MessageStateEvent.complete: MessageStatus.aiSuccess,
    MessageStateEvent.error: MessageStatus.aiError,
    MessageStateEvent.pause: MessageStatus.aiPaused,
    MessageStateEvent.resume: MessageStatus.aiProcessing,
    MessageStateEvent.retry: MessageStatus.aiPending,
    MessageStateEvent.cancel: MessageStatus.aiError,
  };

  /// 验证状态转换是否合法
  bool canTransition(MessageStatus from, MessageStatus to) {
    final allowedStates = _allowedTransitions[from];
    if (allowedStates == null) {
      _logger.warning('未定义的源状态转换规则', {
        'from': from.name,
        'to': to.name,
      });
      return false;
    }
    
    return allowedStates.contains(to);
  }

  /// 执行状态转换
  StateTransitionResult transition({
    required MessageStatus currentStatus,
    required MessageStateEvent event,
    Map<String, dynamic>? metadata,
  }) {
    final targetStatus = _eventToStatus[event];
    if (targetStatus == null) {
      final record = StateTransitionRecord(
        fromStatus: currentStatus,
        toStatus: currentStatus, // 保持原状态
        event: event,
        isSuccess: false,
        errorMessage: '未知的状态事件: ${event.name}',
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      _addTransitionRecord(record);
      return StateTransitionResult.invalid('未知的状态事件: ${event.name}');
    }

    if (!canTransition(currentStatus, targetStatus)) {
      final errorMessage = '不允许的状态转换: ${currentStatus.name} -> ${targetStatus.name}';
      final record = StateTransitionRecord(
        fromStatus: currentStatus,
        toStatus: targetStatus,
        event: event,
        isSuccess: false,
        errorMessage: errorMessage,
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      _addTransitionRecord(record);
      return StateTransitionResult.invalid(errorMessage);
    }

    // 记录成功的状态转换
    final record = StateTransitionRecord(
      fromStatus: currentStatus,
      toStatus: targetStatus,
      event: event,
      isSuccess: true,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
    _addTransitionRecord(record);

    _logger.debug('消息状态转换成功', {
      'from': currentStatus.name,
      'to': targetStatus.name,
      'event': event.name,
      'metadata': metadata,
    });

    return StateTransitionResult.success(targetStatus, metadata: metadata);
  }

  /// 添加状态转换记录
  void _addTransitionRecord(StateTransitionRecord record) {
    _transitionHistory.add(record);

    // 限制历史记录大小
    if (_transitionHistory.length > _maxHistorySize) {
      _transitionHistory.removeAt(0);
    }
  }

  /// 获取状态转换历史
  List<StateTransitionRecord> getTransitionHistory() {
    return List.unmodifiable(_transitionHistory);
  }

  /// 清除状态转换历史
  void clearTransitionHistory() {
    _transitionHistory.clear();
  }

  /// 获取最近的状态转换记录
  StateTransitionRecord? getLastTransition() {
    return _transitionHistory.isNotEmpty ? _transitionHistory.last : null;
  }

  /// 根据事件获取目标状态
  MessageStatus? getTargetStatus(MessageStateEvent event) {
    return _eventToStatus[event];
  }

  /// 获取状态的可能转换目标
  Set<MessageStatus> getAllowedTransitions(MessageStatus status) {
    return _allowedTransitions[status] ?? {};
  }

  /// 检查状态是否为终态
  bool isFinalState(MessageStatus status) {
    return status == MessageStatus.aiSuccess || 
           status == MessageStatus.userSuccess ||
           status == MessageStatus.system;
  }

  /// 检查状态是否为错误态
  bool isErrorState(MessageStatus status) {
    return status == MessageStatus.aiError;
  }

  /// 检查状态是否为进行中
  bool isActiveState(MessageStatus status) {
    return status == MessageStatus.aiProcessing ||
           status == MessageStatus.aiStreaming ||
           status == MessageStatus.aiPending;
  }

  /// 获取状态的优先级（用于UI显示排序）
  int getStatusPriority(MessageStatus status) {
    switch (status) {
      case MessageStatus.aiError:
        return 100; // 最高优先级
      case MessageStatus.aiStreaming:
        return 90;
      case MessageStatus.aiProcessing:
        return 80;
      case MessageStatus.aiPending:
        return 70;
      case MessageStatus.aiPaused:
        return 60;
      case MessageStatus.aiSuccess:
        return 50;
      case MessageStatus.userSuccess:
        return 40;
      case MessageStatus.system:
        return 30;
      case MessageStatus.temporary:
        return 10; // 最低优先级
    }
  }

  /// 获取状态的建议操作
  List<MessageStateEvent> getSuggestedActions(MessageStatus status) {
    switch (status) {
      case MessageStatus.aiError:
        return [MessageStateEvent.retry];
      case MessageStatus.aiPaused:
        return [MessageStateEvent.resume, MessageStateEvent.cancel];
      case MessageStatus.aiStreaming:
      case MessageStatus.aiProcessing:
        return [MessageStateEvent.pause, MessageStateEvent.cancel];
      case MessageStatus.aiSuccess:
        return [MessageStateEvent.retry]; // 重新生成
      default:
        return [];
    }
  }

  /// 批量状态转换（用于处理多个消息的状态变化）
  Map<String, StateTransitionResult> batchTransition({
    required Map<String, MessageStatus> currentStatuses,
    required MessageStateEvent event,
    Map<String, dynamic>? metadata,
  }) {
    final results = <String, StateTransitionResult>{};

    for (final entry in currentStatuses.entries) {
      final messageId = entry.key;
      final currentStatus = entry.value;

      results[messageId] = transition(
        currentStatus: currentStatus,
        event: event,
        metadata: metadata,
      );
    }

    return results;
  }

  /// 状态冲突解决（当多个状态转换同时发生时）
  MessageStatus resolveStateConflict({
    required MessageStatus currentStatus,
    required List<MessageStatus> candidateStatuses,
    String? reason,
  }) {
    if (candidateStatuses.isEmpty) return currentStatus;
    if (candidateStatuses.length == 1) return candidateStatuses.first;

    // 按优先级排序
    final sortedCandidates = List<MessageStatus>.from(candidateStatuses);
    sortedCandidates.sort((a, b) => getStatusPriority(b).compareTo(getStatusPriority(a)));

    // 选择第一个合法的转换
    for (final candidate in sortedCandidates) {
      if (canTransition(currentStatus, candidate)) {
        _logger.info('状态冲突解决', {
          'currentStatus': currentStatus.name,
          'candidates': candidateStatuses.map((s) => s.name).toList(),
          'resolved': candidate.name,
          'reason': reason,
        });
        return candidate;
      }
    }

    // 如果没有合法转换，保持当前状态
    _logger.warning('无法解决状态冲突，保持当前状态', {
      'currentStatus': currentStatus.name,
      'candidates': candidateStatuses.map((s) => s.name).toList(),
      'reason': reason,
    });
    return currentStatus;
  }

  /// 获取状态转换统计信息
  Map<String, dynamic> getTransitionStatistics() {
    if (_transitionHistory.isEmpty) {
      return {
        'totalTransitions': 0,
        'successfulTransitions': 0,
        'failedTransitions': 0,
        'successRate': 0.0,
        'mostCommonTransition': null,
        'mostCommonError': null,
      };
    }

    final successful = _transitionHistory.where((r) => r.isSuccess).length;
    final failed = _transitionHistory.length - successful;

    // 统计最常见的转换
    final transitionCounts = <String, int>{};
    final errorCounts = <String, int>{};

    for (final record in _transitionHistory) {
      final transitionKey = '${record.fromStatus.name}->${record.toStatus.name}';
      transitionCounts[transitionKey] = (transitionCounts[transitionKey] ?? 0) + 1;

      if (!record.isSuccess && record.errorMessage != null) {
        errorCounts[record.errorMessage!] = (errorCounts[record.errorMessage!] ?? 0) + 1;
      }
    }

    String? mostCommonTransition;
    int maxTransitionCount = 0;
    for (final entry in transitionCounts.entries) {
      if (entry.value > maxTransitionCount) {
        maxTransitionCount = entry.value;
        mostCommonTransition = entry.key;
      }
    }

    String? mostCommonError;
    int maxErrorCount = 0;
    for (final entry in errorCounts.entries) {
      if (entry.value > maxErrorCount) {
        maxErrorCount = entry.value;
        mostCommonError = entry.key;
      }
    }

    return {
      'totalTransitions': _transitionHistory.length,
      'successfulTransitions': successful,
      'failedTransitions': failed,
      'successRate': successful / _transitionHistory.length,
      'mostCommonTransition': mostCommonTransition,
      'mostCommonTransitionCount': maxTransitionCount,
      'mostCommonError': mostCommonError,
      'mostCommonErrorCount': maxErrorCount,
    };
  }

  /// 验证状态转换路径是否可达
  bool canReachState({
    required MessageStatus fromStatus,
    required MessageStatus toStatus,
    int maxDepth = 5,
  }) {
    if (fromStatus == toStatus) return true;
    if (maxDepth <= 0) return false;

    final allowedNext = _allowedTransitions[fromStatus] ?? {};
    if (allowedNext.contains(toStatus)) return true;

    // 递归检查是否可以通过中间状态到达目标状态
    for (final nextStatus in allowedNext) {
      if (canReachState(
        fromStatus: nextStatus,
        toStatus: toStatus,
        maxDepth: maxDepth - 1,
      )) {
        return true;
      }
    }

    return false;
  }

  /// 获取到达目标状态的最短路径
  List<MessageStatus>? getShortestPath({
    required MessageStatus fromStatus,
    required MessageStatus toStatus,
    int maxDepth = 5,
  }) {
    if (fromStatus == toStatus) return [fromStatus];

    final queue = <List<MessageStatus>>[[fromStatus]];
    final visited = <MessageStatus>{fromStatus};

    while (queue.isNotEmpty) {
      final currentPath = queue.removeAt(0);
      final currentStatus = currentPath.last;

      if (currentPath.length > maxDepth) continue;

      final allowedNext = _allowedTransitions[currentStatus] ?? {};
      for (final nextStatus in allowedNext) {
        if (nextStatus == toStatus) {
          return [...currentPath, nextStatus];
        }

        if (!visited.contains(nextStatus)) {
          visited.add(nextStatus);
          queue.add([...currentPath, nextStatus]);
        }
      }
    }

    return null; // 无法到达
  }
}
