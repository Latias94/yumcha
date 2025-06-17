import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_status_summary.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_status.dart';
import 'unified_chat_notifier.dart';

/// 聊天状态摘要Provider
///
/// 统一管理聊天相关的所有状态信息，包括加载、错误、流式消息等。
/// 这是一个聚合Provider，将分散的聊天状态统一管理。
final chatStatusSummaryProvider = Provider<ChatStatusSummary>((ref) {
  final chatState = ref.watch(unifiedChatProvider);

  return ChatStatusSummary(
    isLoading: chatState.isLoading,
    isReady: chatState.isReady,
    hasStreamingMessages: chatState.messageState.hasStreamingMessages,
    totalMessages: chatState.messageState.messages.length,
    pendingMessages: _countPendingMessages(chatState.messageState.messages),
    errorMessages: _countErrorMessages(chatState.messageState.messages),
    errors: _extractChatErrors(chatState),
    lastUpdated: DateTime.now(),
    warnings: _extractWarnings(chatState),
    isConnected: _checkConnectionStatus(chatState),
    activeConnections: _countActiveConnections(chatState),
    performance: _calculatePerformanceMetrics(chatState),
  );
});

/// 计算待处理消息数量
int _countPendingMessages(List<Message> messages) {
  return messages.where((message) {
    return message.status.isInProgress;
  }).length;
}

/// 计算错误消息数量
int _countErrorMessages(List<Message> messages) {
  return messages.where((message) {
    return message.status.isError;
  }).length;
}

/// 提取聊天错误信息
List<ChatError> _extractChatErrors(dynamic chatState) {
  final errors = <ChatError>[];

  // 从全局错误中提取
  if (chatState.globalError != null) {
    errors.add(ChatError(
      id: 'global_error_${DateTime.now().millisecondsSinceEpoch}',
      message: chatState.globalError!,
      type: ChatErrorType.unknown,
      timestamp: DateTime.now(),
    ));
  }

  // 从消息状态中提取错误
  if (chatState.messageState.error != null) {
    errors.add(ChatError(
      id: 'message_error_${DateTime.now().millisecondsSinceEpoch}',
      message: chatState.messageState.error!,
      type: ChatErrorType.validation,
      timestamp: DateTime.now(),
    ));
  }

  // 从对话状态中提取错误
  if (chatState.conversationState.error != null) {
    errors.add(ChatError(
      id: 'conversation_error_${DateTime.now().millisecondsSinceEpoch}',
      message: chatState.conversationState.error!,
      type: ChatErrorType.connection,
      timestamp: DateTime.now(),
    ));
  }

  return errors;
}

/// 提取警告信息
List<String> _extractWarnings(dynamic chatState) {
  final warnings = <String>[];

  // 检查流式消息过多的警告
  if (chatState.messageState.streamingMessages.length > 5) {
    warnings.add('当前有多个流式消息正在处理，可能影响性能');
  }

  // 检查消息数量过多的警告
  if (chatState.messageState.messages.length > 100) {
    warnings.add('当前对话消息较多，建议创建新对话以提升性能');
  }

  // 检查配置警告
  if (!chatState.configuration.isValid) {
    warnings.add('聊天配置不完整，可能影响功能使用');
  }

  return warnings;
}

/// 检查连接状态
bool _checkConnectionStatus(dynamic chatState) {
  // 基于聊天状态判断连接状态
  return chatState.isInitialized &&
      chatState.globalError == null &&
      chatState.configuration.isValid;
}

/// 计算活跃连接数
int _countActiveConnections(dynamic chatState) {
  // 基于流式消息数量估算活跃连接
  return chatState.messageState.streamingMessages.length;
}

/// 计算性能指标
ChatPerformanceMetrics? _calculatePerformanceMetrics(dynamic chatState) {
  // 这里可以基于实际的性能数据计算
  // 目前返回模拟数据
  return ChatPerformanceMetrics(
    averageResponseTime: 2000.0, // 2秒平均响应时间
    lastResponseTime: 1500.0, // 最后响应时间
    totalRequests: 10, // 总请求数
    successfulRequests: 9, // 成功请求数
    failedRequests: 1, // 失败请求数
    lastMeasurement: DateTime.now(), // 最后测量时间
  );
}

// ============================================================================
// 向后兼容的访问器Provider
// ============================================================================

/// 聊天加载状态Provider（向后兼容）
final chatLoadingStateProviderCompat =
    Provider<bool>((ref) => ref.watch(chatStatusSummaryProvider).isLoading);

/// 聊天错误Provider（向后兼容）
final chatErrorProviderCompat = Provider<String?>(
    (ref) => ref.watch(chatStatusSummaryProvider).primaryError);

/// 聊天准备状态Provider（向后兼容）
final chatReadyStateProviderCompat =
    Provider<bool>((ref) => ref.watch(chatStatusSummaryProvider).isReady);

/// 是否有流式消息Provider（向后兼容）
final hasStreamingMessagesProviderCompat = Provider<bool>(
    (ref) => ref.watch(chatStatusSummaryProvider).hasStreamingMessages);

/// 消息数量Provider（向后兼容）
final messageCountProviderCompat =
    Provider<int>((ref) => ref.watch(chatStatusSummaryProvider).totalMessages);

// ============================================================================
// 新增的便捷访问Provider
// ============================================================================

/// 聊天错误列表Provider（新增）
final chatErrorsProvider = Provider<List<ChatError>>(
    (ref) => ref.watch(chatStatusSummaryProvider).errors);

/// 聊天警告Provider（新增）
final chatWarningsProvider = Provider<List<String>>(
    (ref) => ref.watch(chatStatusSummaryProvider).warnings);

/// 聊天连接状态Provider（新增）
final chatConnectionStatusProvider =
    Provider<bool>((ref) => ref.watch(chatStatusSummaryProvider).isConnected);

/// 聊天可发送状态Provider（新增）
final chatCanSendMessageProvider = Provider<bool>(
    (ref) => ref.watch(chatStatusSummaryProvider).canSendMessage);

/// 聊天需要注意Provider（新增）
final chatNeedsAttentionProvider = Provider<bool>(
    (ref) => ref.watch(chatStatusSummaryProvider).needsAttention);

/// 聊天健康状态Provider（新增）
final chatHealthStatusProvider = Provider<HealthStatus>(
    (ref) => ref.watch(chatStatusSummaryProvider).healthStatus);

/// 聊天性能指标Provider（新增）
final chatPerformanceProvider = Provider<ChatPerformanceMetrics?>(
    (ref) => ref.watch(chatStatusSummaryProvider).performance);
