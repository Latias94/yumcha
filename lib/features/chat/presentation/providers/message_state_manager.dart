import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/services/message_state_machine.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 消息状态管理器
/// 
/// 为UnifiedChatNotifier提供状态机集成，管理消息状态的转换和验证
/// 
/// 核心功能：
/// - 🔄 状态转换管理：使用状态机确保合法的状态转换
/// - 🛡️ 状态验证：验证状态转换的合法性
/// - 📊 状态统计：提供状态转换的统计信息
/// - 🔍 状态追踪：记录状态转换历史用于调试
/// - ⚡ 批量操作：支持批量状态转换
class MessageStateManager {
  final MessageStateMachine _stateMachine = MessageStateMachine();
  final LoggerService _logger = LoggerService();

  /// 单例实例
  static final MessageStateManager _instance = MessageStateManager._internal();
  factory MessageStateManager() => _instance;
  MessageStateManager._internal();

  /// 转换消息状态
  /// 
  /// 使用状态机验证并执行状态转换
  MessageStateTransitionResult transitionMessageState({
    required Message message,
    required MessageStateEvent event,
    Map<String, dynamic>? metadata,
  }) {
    final result = _stateMachine.transition(
      currentStatus: message.status,
      event: event,
      metadata: metadata,
    );

    if (result.isValid) {
      _logger.debug('消息状态转换成功', {
        'messageId': message.id,
        'from': message.status.name,
        'to': result.newStatus.name,
        'event': event.name,
      });

      return MessageStateTransitionResult.success(
        message: message,
        newStatus: result.newStatus,
        event: event,
        metadata: result.metadata,
      );
    } else {
      _logger.warning('消息状态转换失败', {
        'messageId': message.id,
        'from': message.status.name,
        'event': event.name,
        'error': result.errorMessage,
      });

      return MessageStateTransitionResult.failure(
        message: message,
        event: event,
        error: result.errorMessage ?? '未知错误',
        metadata: metadata,
      );
    }
  }

  /// 批量转换消息状态
  Map<String, MessageStateTransitionResult> batchTransitionMessageStates({
    required List<Message> messages,
    required MessageStateEvent event,
    Map<String, dynamic>? metadata,
  }) {
    final results = <String, MessageStateTransitionResult>{};
    
    for (final message in messages) {
      results[message.id] = transitionMessageState(
        message: message,
        event: event,
        metadata: metadata,
      );
    }

    return results;
  }

  /// 验证状态转换是否合法
  bool canTransitionMessageState({
    required MessageStatus currentStatus,
    required MessageStateEvent event,
  }) {
    final targetStatus = _stateMachine.getTargetStatus(event);
    if (targetStatus == null) return false;
    
    return _stateMachine.canTransition(currentStatus, targetStatus);
  }

  /// 获取消息状态的建议操作
  List<MessageStateEvent> getSuggestedActionsForMessage(Message message) {
    return _stateMachine.getSuggestedActions(message.status);
  }

  /// 解决状态冲突
  MessageStatus resolveMessageStateConflict({
    required Message message,
    required List<MessageStatus> candidateStatuses,
    String? reason,
  }) {
    return _stateMachine.resolveStateConflict(
      currentStatus: message.status,
      candidateStatuses: candidateStatuses,
      reason: reason,
    );
  }

  /// 检查是否可以到达目标状态
  bool canReachMessageState({
    required MessageStatus fromStatus,
    required MessageStatus toStatus,
  }) {
    return _stateMachine.canReachState(
      fromStatus: fromStatus,
      toStatus: toStatus,
    );
  }

  /// 获取状态转换路径
  List<MessageStatus>? getMessageStateTransitionPath({
    required MessageStatus fromStatus,
    required MessageStatus toStatus,
  }) {
    return _stateMachine.getShortestPath(
      fromStatus: fromStatus,
      toStatus: toStatus,
    );
  }

  /// 获取状态转换统计
  Map<String, dynamic> getTransitionStatistics() {
    return _stateMachine.getTransitionStatistics();
  }

  /// 获取状态转换历史
  List<StateTransitionRecord> getTransitionHistory() {
    return _stateMachine.getTransitionHistory();
  }

  /// 清除状态转换历史
  void clearTransitionHistory() {
    _stateMachine.clearTransitionHistory();
  }

  /// 获取最近的状态转换
  StateTransitionRecord? getLastTransition() {
    return _stateMachine.getLastTransition();
  }
}

/// 消息状态转换结果
class MessageStateTransitionResult {
  final Message message;
  final MessageStatus? newStatus;
  final MessageStateEvent event;
  final bool isSuccess;
  final String? error;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const MessageStateTransitionResult._({
    required this.message,
    this.newStatus,
    required this.event,
    required this.isSuccess,
    this.error,
    this.metadata,
    required this.timestamp,
  });

  factory MessageStateTransitionResult.success({
    required Message message,
    required MessageStatus newStatus,
    required MessageStateEvent event,
    Map<String, dynamic>? metadata,
  }) {
    return MessageStateTransitionResult._(
      message: message,
      newStatus: newStatus,
      event: event,
      isSuccess: true,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  factory MessageStateTransitionResult.failure({
    required Message message,
    required MessageStateEvent event,
    required String error,
    Map<String, dynamic>? metadata,
  }) {
    return MessageStateTransitionResult._(
      message: message,
      event: event,
      isSuccess: false,
      error: error,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  /// 创建更新后的消息
  Message? get updatedMessage {
    if (!isSuccess || newStatus == null) return null;
    
    return message.copyWith(
      status: newStatus!,
      updatedAt: timestamp,
      metadata: metadata != null 
        ? {...?message.metadata, ...metadata!}
        : message.metadata,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'MessageStateTransition(${message.id}: ${message.status.name} -> ${newStatus?.name} via ${event.name})';
    } else {
      return 'MessageStateTransitionError(${message.id}: ${event.name} failed - $error)';
    }
  }
}

/// Provider for MessageStateManager
final messageStateManagerProvider = Provider<MessageStateManager>((ref) {
  return MessageStateManager();
});
