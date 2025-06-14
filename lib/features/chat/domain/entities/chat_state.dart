import 'package:flutter/foundation.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../../ai_management/domain/entities/ai_model.dart';
import 'message.dart';
import 'conversation_ui_state.dart';

/// 聊天事件基类
@immutable
abstract class ChatEvent {
  const ChatEvent();
}

/// 消息添加事件
class MessageAddedEvent extends ChatEvent {
  final Message message;
  const MessageAddedEvent(this.message);
}

/// 消息更新事件
class MessageUpdatedEvent extends ChatEvent {
  final Message oldMessage;
  final Message newMessage;
  const MessageUpdatedEvent(this.oldMessage, this.newMessage);
}

/// 流式传输开始事件
class StreamingStartedEvent extends ChatEvent {
  final String messageId;
  const StreamingStartedEvent(this.messageId);
}

/// 流式传输完成事件
class StreamingCompletedEvent extends ChatEvent {
  final String messageId;
  const StreamingCompletedEvent(this.messageId);
}

/// 流式传输错误事件
class StreamingErrorEvent extends ChatEvent {
  final String messageId;
  final String error;
  const StreamingErrorEvent(this.messageId, this.error);
}

/// 对话变更事件
class ConversationChangedEvent extends ChatEvent {
  final ConversationUiState conversation;
  const ConversationChangedEvent(this.conversation);
}

/// 配置变更事件
class ConfigurationChangedEvent extends ChatEvent {
  final AiAssistant? assistant;
  final AiProvider? provider;
  final AiModel? model;
  const ConfigurationChangedEvent(this.assistant, this.provider, this.model);
}

/// 错误发生事件
class ErrorOccurredEvent extends ChatEvent {
  final String error;
  final String source;
  const ErrorOccurredEvent(this.error, this.source);
}

/// 错误清除事件
class ErrorClearedEvent extends ChatEvent {
  const ErrorClearedEvent();
}

/// 聊天配置状态
@immutable
class ChatConfiguration {
  final AiAssistant? selectedAssistant;
  final AiProvider? selectedProvider;
  final AiModel? selectedModel;
  final bool isLoading;
  final String? error;

  const ChatConfiguration({
    this.selectedAssistant,
    this.selectedProvider,
    this.selectedModel,
    this.isLoading = false,
    this.error,
  });

  /// 检查是否有完整配置
  bool get isComplete =>
      selectedAssistant != null &&
      selectedProvider != null &&
      selectedModel != null;

  /// 检查是否有效
  bool get isValid =>
      isComplete &&
      selectedAssistant!.isEnabled &&
      selectedProvider!.isEnabled;

  ChatConfiguration copyWith({
    AiAssistant? selectedAssistant,
    AiProvider? selectedProvider,
    AiModel? selectedModel,
    bool? isLoading,
    String? error,
  }) {
    return ChatConfiguration(
      selectedAssistant: selectedAssistant ?? this.selectedAssistant,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      selectedModel: selectedModel ?? this.selectedModel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatConfiguration &&
        other.selectedAssistant == selectedAssistant &&
        other.selectedProvider == selectedProvider &&
        other.selectedModel == selectedModel &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      selectedAssistant,
      selectedProvider,
      selectedModel,
      isLoading,
      error,
    );
  }
}

/// 消息状态
@immutable
class MessageState {
  final List<Message> messages;
  final Set<String> streamingMessageIds;
  final Map<String, String> messageErrors;
  final bool isLoading;
  final String? error;

  const MessageState({
    this.messages = const [],
    this.streamingMessageIds = const {},
    this.messageErrors = const {},
    this.isLoading = false,
    this.error,
  });

  /// 获取流式消息
  List<Message> get streamingMessages =>
      messages.where((m) => streamingMessageIds.contains(m.id)).toList();

  /// 检查是否有流式消息
  bool get hasStreamingMessages => streamingMessageIds.isNotEmpty;

  /// 获取历史消息（用于AI上下文）
  List<Message> get historyMessages =>
      messages.where((m) => m.shouldPersist).toList();

  /// 获取最近的消息（限制数量以优化性能）
  List<Message> getRecentMessages([int limit = 100]) {
    if (messages.length <= limit) return messages;
    return messages.sublist(messages.length - limit);
  }

  MessageState copyWith({
    List<Message>? messages,
    Set<String>? streamingMessageIds,
    Map<String, String>? messageErrors,
    bool? isLoading,
    String? error,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      streamingMessageIds: streamingMessageIds ?? this.streamingMessageIds,
      messageErrors: messageErrors ?? this.messageErrors,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageState &&
        _listEquals(other.messages, messages) &&
        _setEquals(other.streamingMessageIds, streamingMessageIds) &&
        _mapEquals(other.messageErrors, messageErrors) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(messages),
      Object.hashAll(streamingMessageIds),
      Object.hashAll(messageErrors.entries),
      isLoading,
      error,
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// 对话状态
@immutable
class ConversationState {
  final ConversationUiState? currentConversation;
  final List<ConversationUiState> recentConversations;
  final bool isLoading;
  final String? error;

  const ConversationState({
    this.currentConversation,
    this.recentConversations = const [],
    this.isLoading = false,
    this.error,
  });

  /// 检查是否有当前对话
  bool get hasCurrentConversation => currentConversation != null;

  /// 获取当前对话ID
  String? get currentConversationId => currentConversation?.id;

  ConversationState copyWith({
    ConversationUiState? currentConversation,
    List<ConversationUiState>? recentConversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationState(
      currentConversation: currentConversation ?? this.currentConversation,
      recentConversations: recentConversations ?? this.recentConversations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationState &&
        other.currentConversation == currentConversation &&
        _listEquals(other.recentConversations, recentConversations) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentConversation,
      Object.hashAll(recentConversations),
      isLoading,
      error,
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 统一聊天状态
@immutable
class UnifiedChatState {
  final ChatConfiguration configuration;
  final MessageState messageState;
  final ConversationState conversationState;
  final bool isInitialized;
  final bool isInitializing;
  final String? globalError;
  final ChatEvent? lastEvent;

  const UnifiedChatState({
    this.configuration = const ChatConfiguration(),
    this.messageState = const MessageState(),
    this.conversationState = const ConversationState(),
    this.isInitialized = false,
    this.isInitializing = false,
    this.globalError,
    this.lastEvent,
  });

  /// 检查是否准备就绪（可以发送消息）
  bool get isReady =>
      isInitialized &&
      !isInitializing &&
      configuration.isValid;

  /// 检查是否有活跃对话
  bool get hasActiveConversation =>
      isReady && conversationState.hasCurrentConversation;

  /// 检查是否正在加载
  bool get isLoading =>
      isInitializing ||
      configuration.isLoading ||
      messageState.isLoading ||
      conversationState.isLoading;

  /// 获取所有错误
  List<String> get allErrors {
    final errors = <String>[];
    if (globalError != null) errors.add(globalError!);
    if (configuration.error != null) errors.add(configuration.error!);
    if (messageState.error != null) errors.add(messageState.error!);
    if (conversationState.error != null) errors.add(conversationState.error!);
    return errors;
  }

  /// 检查是否有错误
  bool get hasError => allErrors.isNotEmpty;

  /// 获取主要错误
  String? get primaryError => allErrors.isNotEmpty ? allErrors.first : null;

  UnifiedChatState copyWith({
    ChatConfiguration? configuration,
    MessageState? messageState,
    ConversationState? conversationState,
    bool? isInitialized,
    bool? isInitializing,
    String? globalError,
    ChatEvent? lastEvent,
  }) {
    return UnifiedChatState(
      configuration: configuration ?? this.configuration,
      messageState: messageState ?? this.messageState,
      conversationState: conversationState ?? this.conversationState,
      isInitialized: isInitialized ?? this.isInitialized,
      isInitializing: isInitializing ?? this.isInitializing,
      globalError: globalError ?? this.globalError,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedChatState &&
        other.configuration == configuration &&
        other.messageState == messageState &&
        other.conversationState == conversationState &&
        other.isInitialized == isInitialized &&
        other.isInitializing == isInitializing &&
        other.globalError == globalError &&
        other.lastEvent == lastEvent;
  }

  @override
  int get hashCode {
    return Object.hash(
      configuration,
      messageState,
      conversationState,
      isInitialized,
      isInitializing,
      globalError,
      lastEvent,
    );
  }
}

/// 聊天操作结果基类
@immutable
abstract class ChatOperationResult<T> {
  const ChatOperationResult();

  /// 处理结果
  R when<R>({
    required R Function(T data) success,
    required R Function(String error, String? code, Object? originalError) failure,
    required R Function() loading,
  }) {
    if (this is ChatOperationSuccess<T>) {
      return success((this as ChatOperationSuccess<T>).data);
    } else if (this is ChatOperationFailure<T>) {
      final failure_ = this as ChatOperationFailure<T>;
      return failure(failure_.error, failure_.code, failure_.originalError);
    } else if (this is ChatOperationLoading<T>) {
      return loading();
    }
    throw StateError('Unknown ChatOperationResult type');
  }
}

/// 成功结果
class ChatOperationSuccess<T> extends ChatOperationResult<T> {
  final T data;
  const ChatOperationSuccess(this.data);
}

/// 失败结果
class ChatOperationFailure<T> extends ChatOperationResult<T> {
  final String error;
  final String? code;
  final Object? originalError;
  const ChatOperationFailure(this.error, {this.code, this.originalError});
}

/// 加载中结果
class ChatOperationLoading<T> extends ChatOperationResult<T> {
  const ChatOperationLoading();
}

/// 消息发送参数
@immutable
class SendMessageParams {
  final String content;
  final String conversationId;
  final AiAssistant assistant;
  final AiProvider provider;
  final AiModel model;
  final bool useStreaming;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  const SendMessageParams({
    required this.content,
    required this.conversationId,
    required this.assistant,
    required this.provider,
    required this.model,
    this.useStreaming = true,
    this.attachments = const [],
    this.metadata,
  });

  /// 验证参数
  bool get isValid =>
      content.trim().isNotEmpty &&
      conversationId.isNotEmpty &&
      assistant.isEnabled &&
      provider.isEnabled;

  /// 复制并修改参数
  SendMessageParams copyWith({
    String? content,
    String? conversationId,
    AiAssistant? assistant,
    AiProvider? provider,
    AiModel? model,
    bool? useStreaming,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return SendMessageParams(
      content: content ?? this.content,
      conversationId: conversationId ?? this.conversationId,
      assistant: assistant ?? this.assistant,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      useStreaming: useStreaming ?? this.useStreaming,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 流式消息更新
@immutable
class StreamingUpdate {
  final String messageId;
  final String? contentDelta;
  final String? thinkingDelta;
  final String? fullContent;
  final bool isDone;
  final String? error;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const StreamingUpdate({
    required this.messageId,
    this.contentDelta,
    this.thinkingDelta,
    this.fullContent,
    this.isDone = false,
    this.error,
    this.duration,
    this.metadata,
  });

  /// 检查是否为错误更新
  bool get isError => error != null;

  /// 检查是否为内容更新
  bool get hasContent => contentDelta != null || thinkingDelta != null;
}

/// 聊天统计信息
@immutable
class ChatStatistics {
  final int totalMessages;
  final int totalConversations;
  final int streamingMessages;
  final int failedMessages;
  final Duration totalChatTime;
  final DateTime? lastActivity;

  const ChatStatistics({
    this.totalMessages = 0,
    this.totalConversations = 0,
    this.streamingMessages = 0,
    this.failedMessages = 0,
    this.totalChatTime = Duration.zero,
    this.lastActivity,
  });

  /// 计算成功率
  double get successRate {
    if (totalMessages == 0) return 0.0;
    return (totalMessages - failedMessages) / totalMessages;
  }

  /// 计算平均响应时间
  Duration get averageResponseTime {
    if (totalMessages == 0) return Duration.zero;
    return Duration(
      microseconds: totalChatTime.inMicroseconds ~/ totalMessages,
    );
  }

  ChatStatistics copyWith({
    int? totalMessages,
    int? totalConversations,
    int? streamingMessages,
    int? failedMessages,
    Duration? totalChatTime,
    DateTime? lastActivity,
  }) {
    return ChatStatistics(
      totalMessages: totalMessages ?? this.totalMessages,
      totalConversations: totalConversations ?? this.totalConversations,
      streamingMessages: streamingMessages ?? this.streamingMessages,
      failedMessages: failedMessages ?? this.failedMessages,
      totalChatTime: totalChatTime ?? this.totalChatTime,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

/// 聊天性能指标
@immutable
class ChatPerformanceMetrics {
  final int memoryUsageMB;
  final int activeSubscriptions;
  final int cachedMessages;
  final Duration lastOperationTime;
  final DateTime? lastGarbageCollection;

  const ChatPerformanceMetrics({
    this.memoryUsageMB = 0,
    this.activeSubscriptions = 0,
    this.cachedMessages = 0,
    this.lastOperationTime = Duration.zero,
    this.lastGarbageCollection,
  });

  ChatPerformanceMetrics copyWith({
    int? memoryUsageMB,
    int? activeSubscriptions,
    int? cachedMessages,
    Duration? lastOperationTime,
    DateTime? lastGarbageCollection,
  }) {
    return ChatPerformanceMetrics(
      memoryUsageMB: memoryUsageMB ?? this.memoryUsageMB,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      cachedMessages: cachedMessages ?? this.cachedMessages,
      lastOperationTime: lastOperationTime ?? this.lastOperationTime,
      lastGarbageCollection: lastGarbageCollection ?? this.lastGarbageCollection,
    );
  }
}

/// 常量定义
class ChatConstants {
  static const int maxMessagesInMemory = 100;
  static const int messagesToKeepWhenTrimming = 80;
  static const int maxRecentConversations = 20;
  static const Duration streamingTimeout = Duration(minutes: 5);
  static const Duration initializationTimeout = Duration(seconds: 30);
  static const Duration configurationSaveDelay = Duration(milliseconds: 500);
  
  // 性能相关
  static const int maxConcurrentStreams = 3;
  static const int messageCleanupThreshold = 150;
  static const Duration performanceCheckInterval = Duration(minutes: 1);
}
