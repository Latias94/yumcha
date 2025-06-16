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
class MessageStateMachine {
  final LoggerService _logger = LoggerService();
  
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
      return StateTransitionResult.invalid('未知的状态事件: ${event.name}');
    }

    if (!canTransition(currentStatus, targetStatus)) {
      return StateTransitionResult.invalid(
        '不允许的状态转换: ${currentStatus.name} -> ${targetStatus.name}',
      );
    }

    _logger.debug('消息状态转换', {
      'from': currentStatus.name,
      'to': targetStatus.name,
      'event': event.name,
      'metadata': metadata,
    });

    return StateTransitionResult.success(targetStatus, metadata: metadata);
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
}
