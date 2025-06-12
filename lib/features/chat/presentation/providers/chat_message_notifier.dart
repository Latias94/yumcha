import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../../shared/infrastructure/services/ai/chat/chat_service.dart';
import '../../../../shared/infrastructure/services/ai/providers/ai_service_provider.dart';

import '../../../ai_management/presentation/providers/ai_assistant_notifier.dart';
import '../../../ai_management/presentation/providers/ai_provider_notifier.dart';
import '../../infrastructure/services/chat_error_handler.dart';

/// 待处理的请求信息
class PendingRequest {
  const PendingRequest({
    required this.assistantId,
    required this.providerId,
    required this.modelName,
    required this.userMessage,
    required this.isStreaming,
    required this.timestamp,
  });

  final String assistantId;
  final String providerId;
  final String modelName;
  final String userMessage;
  final bool isStreaming;
  final DateTime timestamp;
}

/// 聊天消息状态
class ChatMessageState {
  const ChatMessageState({
    required this.messages,
    this.isLoading = false,
    this.error,
    this.streamingMessageIds = const {},
    this.pendingRequests = const {},
  });

  /// 消息列表
  final List<Message> messages;

  /// 是否正在加载（全局加载状态）
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 正在流式传输的消息ID集合（支持多个并发流式消息）
  final Set<String> streamingMessageIds;

  /// 待处理的请求队列（assistantId -> 请求信息）
  final Map<String, PendingRequest> pendingRequests;

  ChatMessageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    Set<String>? streamingMessageIds,
    Map<String, PendingRequest>? pendingRequests,
  }) {
    return ChatMessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streamingMessageIds: streamingMessageIds ?? this.streamingMessageIds,
      pendingRequests: pendingRequests ?? this.pendingRequests,
    );
  }

  /// 是否有流式消息正在传输
  bool get hasStreamingMessage => streamingMessageIds.isNotEmpty;

  /// 获取所有流式消息
  List<Message> get streamingMessages {
    return messages.where((m) => streamingMessageIds.contains(m.id)).toList();
  }

  /// 获取第一个流式消息（向后兼容）
  Message? get streamingMessage {
    if (streamingMessageIds.isEmpty) return null;
    try {
      final firstStreamingId = streamingMessageIds.first;
      return messages.firstWhere((m) => m.id == firstStreamingId);
    } catch (e) {
      return null;
    }
  }

  /// 检查特定助手是否正在处理消息
  bool isAssistantBusy(String assistantId) {
    return pendingRequests.containsKey(assistantId) ||
        streamingMessages.any((m) => m.author == assistantId);
  }

  /// 获取特定助手的流式消息
  List<Message> getAssistantStreamingMessages(String assistantId) {
    return streamingMessages.where((m) => m.author == assistantId).toList();
  }

  /// 获取历史消息（排除临时状态的消息）
  List<Message> get historyMessages {
    return messages.where((m) => m.shouldPersist).toList();
  }

  /// 获取最后一条消息
  Message? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// 是否有错误状态的消息
  bool get hasErrorMessages {
    return messages.any((m) => m.isError);
  }
}

/// 聊天消息状态管理器
///
/// 负责管理单个对话的消息状态，遵循 Riverpod 最佳实践：
/// - 📝 消息列表管理
/// - 🔄 流式消息处理
/// - 💾 消息持久化
/// - ⚠️ 错误状态处理
/// - 🎯 单一数据源原则
/// - 🔗 依赖注入模式
class ChatMessageNotifier extends StateNotifier<ChatMessageState> {
  ChatMessageNotifier(this._ref, this._conversationId)
      : super(const ChatMessageState(messages: [])) {
    _logger
        .info('ChatMessageNotifier 初始化', {'conversationId': _conversationId});
  }

  final Ref _ref;
  final String _conversationId;
  final LoggerService _logger = LoggerService();
  final ChatErrorHandler _errorHandler = ChatErrorHandler();

  /// 多个流式订阅管理（messageId -> subscription）
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  /// 获取服务实例 - 使用 getter 避免 late final 重复初始化问题
  ChatService get _chatService => _ref.read(aiChatServiceProvider);

  @override
  void dispose() {
    // 取消所有流式订阅
    for (final subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    _logger.info('ChatMessageNotifier 销毁', {'conversationId': _conversationId});
    super.dispose();
  }

  /// 初始化消息列表
  void initializeMessages(List<Message> messages) {
    _logger.info('初始化消息列表', {
      'conversationId': _conversationId,
      'messageCount': messages.length,
    });
    state = state.copyWith(messages: messages);
  }

  /// 发送消息 - 主要入口方法
  Future<void> sendMessage({
    required String content,
    required String assistantId,
    required String providerId,
    required String modelName,
    bool isStreaming = true,
  }) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(error: '请输入消息内容');
      return;
    }

    _logger.info('开始发送消息', {
      'conversationId': _conversationId,
      'assistantId': assistantId,
      'providerId': providerId,
      'modelName': modelName,
      'isStreaming': isStreaming,
      'contentLength': content.length,
    });

    // 清除之前的错误
    state = state.copyWith(error: null);

    // 添加用户消息
    final userMessage = Message(
      content: content,
      timestamp: DateTime.now(),
      isFromUser: true,
      author: "你",
      status: MessageStatus.normal,
    );

    _addMessage(userMessage);

    // 立即保存用户消息
    await _persistMessage(userMessage);

    try {
      if (isStreaming) {
        await _handleStreamingMessage(
            userMessage, assistantId, providerId, modelName);
      } else {
        await _handleNormalMessage(
            userMessage, assistantId, providerId, modelName);
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  /// 处理流式消息
  Future<void> _handleStreamingMessage(
    Message userMessage,
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    // 获取助手和提供商信息
    final assistant = await _getAssistant(assistantId);
    final provider = await _getProvider(providerId);

    if (assistant == null || provider == null) {
      throw Exception('助手或提供商不存在');
    }

    // 创建AI消息占位符
    final aiMessage = Message(
      content: '',
      timestamp: DateTime.now(),
      isFromUser: false,
      author: assistant.name,
      status: MessageStatus.streaming,
    );

    _addMessage(aiMessage);

    // 添加到流式消息集合
    final updatedStreamingIds = {...state.streamingMessageIds, aiMessage.id!};
    state = state.copyWith(
      isLoading: true,
      streamingMessageIds: updatedStreamingIds,
    );

    _logger.info('开始流式传输', {
      'conversationId': _conversationId,
      'aiMessageId': aiMessage.id,
      'assistantName': assistant.name,
    });

    try {
      // 开始流式传输
      final stream = _chatService.sendMessageStream(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: state.historyMessages,
        userMessage: userMessage.content,
      );

      String accumulatedContent = '';
      String accumulatedThinking = '';

      final subscription = stream.listen(
        (event) {
          if (event.error != null) {
            _handleStreamError(event.error!, aiMessage, accumulatedContent);
            return;
          }

          if (event.contentDelta != null) {
            accumulatedContent += event.contentDelta!;
            _updateStreamingMessage(
                aiMessage, accumulatedContent, accumulatedThinking);
          }

          if (event.thinkingDelta != null) {
            accumulatedThinking += event.thinkingDelta!;
            _updateStreamingMessage(
                aiMessage, accumulatedContent, accumulatedThinking);
          }

          if (event.isDone) {
            _completeStreamingMessage(aiMessage, accumulatedContent,
                accumulatedThinking, event.duration);
          }
        },
        onError: (error) {
          _handleStreamError(error, aiMessage, accumulatedContent);
        },
        onDone: () {
          if (state.streamingMessageIds.contains(aiMessage.id)) {
            _completeStreamingMessage(
                aiMessage, accumulatedContent, accumulatedThinking, null);
          }
        },
      );

      // 保存订阅以便后续管理
      _streamSubscriptions[aiMessage.id!] = subscription;
    } catch (e) {
      _handleStreamError(e, aiMessage, '');
    }
  }

  /// 处理非流式消息
  Future<void> _handleNormalMessage(
    Message userMessage,
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final assistant = await _getAssistant(assistantId);
      final provider = await _getProvider(providerId);

      if (assistant == null || provider == null) {
        throw Exception('助手或提供商不存在');
      }

      _logger.info('开始非流式消息处理', {
        'conversationId': _conversationId,
        'assistantName': assistant.name,
      });

      final response = await _chatService.sendMessage(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: state.historyMessages,
        userMessage: userMessage.content,
      );

      if (response.isSuccess) {
        final aiMessage = Message(
          content: response.content,
          timestamp: DateTime.now(),
          isFromUser: false,
          author: assistant.name,
          duration: response.duration,
          status: MessageStatus.normal,
        );

        _addMessage(aiMessage);
        await _persistMessage(aiMessage);

        _logger.info('非流式消息处理成功', {
          'conversationId': _conversationId,
          'responseLength': response.content.length,
        });
      } else {
        throw Exception(response.error ?? '请求失败');
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 更新流式消息内容
  void _updateStreamingMessage(
      Message originalMessage, String content, String thinking) {
    final fullContent = thinking.isNotEmpty
        ? '<think>\n$thinking\n</think>\n\n$content'
        : content;

    final updatedMessage = originalMessage.copyWith(
      content: fullContent,
      status: MessageStatus.streaming,
    );

    _updateMessage(originalMessage, updatedMessage);
  }

  /// 完成流式消息
  void _completeStreamingMessage(Message originalMessage, String content,
      String thinking, Duration? duration) {
    final fullContent = thinking.isNotEmpty
        ? '<think>\n$thinking\n</think>\n\n$content'
        : content;

    final completedMessage = originalMessage.copyWith(
      content: fullContent,
      duration: duration,
      status: MessageStatus.normal,
    );

    _updateMessage(originalMessage, completedMessage);

    // 从流式消息集合中移除
    final updatedStreamingIds = Set<String>.from(state.streamingMessageIds);
    updatedStreamingIds.remove(originalMessage.id);

    // 清理订阅
    _streamSubscriptions[originalMessage.id!]?.cancel();
    _streamSubscriptions.remove(originalMessage.id);

    state = state.copyWith(
      isLoading: updatedStreamingIds.isNotEmpty, // 如果还有其他流式消息，保持加载状态
      streamingMessageIds: updatedStreamingIds,
    );

    _logger.info('流式消息完成', {
      'conversationId': _conversationId,
      'messageId': completedMessage.id,
      'contentLength': fullContent.length,
      'remainingStreaming': updatedStreamingIds.length,
    });

    // 持久化完成的消息
    _persistMessage(completedMessage);
  }

  /// 处理流式错误
  void _handleStreamError(
      Object error, Message streamingMessage, String partialContent) {
    _logger.error('流式传输错误', {
      'conversationId': _conversationId,
      'messageId': streamingMessage.id,
      'error': error.toString(),
      'partialContentLength': partialContent.length,
    });

    final errorMessage = _errorHandler.handleStreamError(
      error: error,
      streamingMessage: streamingMessage,
      partialContent: partialContent,
    );

    _updateMessage(streamingMessage, errorMessage);

    // 从流式消息集合中移除错误的消息
    final updatedStreamingIds = Set<String>.from(state.streamingMessageIds);
    updatedStreamingIds.remove(streamingMessage.id);

    // 清理订阅
    _streamSubscriptions[streamingMessage.id!]?.cancel();
    _streamSubscriptions.remove(streamingMessage.id);

    state = state.copyWith(
      isLoading: updatedStreamingIds.isNotEmpty, // 如果还有其他流式消息，保持加载状态
      streamingMessageIds: updatedStreamingIds,
      error: error.toString(),
    );
  }

  /// 处理一般错误
  void _handleError(Object error, StackTrace stackTrace) {
    _logger.error('聊天消息处理错误', {
      'conversationId': _conversationId,
      'error': error.toString(),
    });

    state = state.copyWith(
      isLoading: false,
      streamingMessageIds: const {}, // 清空所有流式消息
      error: error.toString(),
    );

    // 清理所有订阅
    for (final subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
  }

  /// 添加消息到列表
  void _addMessage(Message message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  /// 更新消息
  void _updateMessage(Message oldMessage, Message newMessage) {
    final updatedMessages = state.messages.map((m) {
      return m.id == oldMessage.id ? newMessage : m;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  /// 持久化消息
  Future<void> _persistMessage(Message message) async {
    if (!message.shouldPersist) return;

    try {
      final repository = _ref.read(conversationRepositoryProvider);
      await repository.addMessage(
        conversationId: _conversationId,
        content: message.content,
        author: message.author,
        isFromUser: message.isFromUser,
        imageUrl: message.imageUrl,
        avatarUrl: message.avatarUrl,
        duration: message.duration,
        status: message.status,
        errorInfo: message.errorInfo,
      );
    } catch (e) {
      _logger.error('消息持久化失败', {'error': e.toString()});
    }
  }

  /// 获取助手信息
  Future<dynamic> _getAssistant(String assistantId) async {
    final assistantsAsync = _ref.read(aiAssistantNotifierProvider);
    return assistantsAsync.whenOrNull(
      data: (assistants) {
        try {
          return assistants.firstWhere((a) => a.id == assistantId);
        } catch (e) {
          return null;
        }
      },
    );
  }

  /// 获取提供商信息
  Future<dynamic> _getProvider(String providerId) async {
    final providersAsync = _ref.read(aiProviderNotifierProvider);
    return providersAsync.whenOrNull(
      data: (providers) {
        try {
          return providers.firstWhere((p) => p.id == providerId);
        } catch (e) {
          return null;
        }
      },
    );
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 取消所有流式传输
  void cancelStreaming() {
    _logger.info('取消流式传输', {
      'conversationId': _conversationId,
      'streamingCount': state.streamingMessageIds.length,
    });

    // 取消所有流式订阅
    for (final subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();

    if (state.streamingMessageIds.isNotEmpty) {
      state = state.copyWith(
        isLoading: false,
        streamingMessageIds: const {},
      );
    }
  }

  /// 取消特定消息的流式传输
  void cancelMessageStreaming(String messageId) {
    _logger.info('取消特定消息流式传输', {
      'conversationId': _conversationId,
      'messageId': messageId,
    });

    // 取消特定订阅
    _streamSubscriptions[messageId]?.cancel();
    _streamSubscriptions.remove(messageId);

    // 从流式消息集合中移除
    final updatedStreamingIds = Set<String>.from(state.streamingMessageIds);
    updatedStreamingIds.remove(messageId);

    state = state.copyWith(
      isLoading: updatedStreamingIds.isNotEmpty,
      streamingMessageIds: updatedStreamingIds,
    );
  }

  /// 重新发送消息
  Future<void> retryMessage(Message failedMessage) async {
    if (!failedMessage.isFromUser) {
      _logger.warning('只能重试用户消息', {
        'conversationId': _conversationId,
        'messageId': failedMessage.id,
      });
      return;
    }

    // 移除失败的消息
    _removeMessage(failedMessage);

    // 重新发送
    // 注意：这里需要从外部传入配置参数，暂时简化处理
    _logger.info('重新发送消息', {
      'conversationId': _conversationId,
      'originalMessageId': failedMessage.id,
    });
  }

  /// 删除消息
  void deleteMessage(Message message) {
    _logger.info('删除消息', {
      'conversationId': _conversationId,
      'messageId': message.id,
      'isFromUser': message.isFromUser,
    });

    _removeMessage(message);

    // 如果是持久化的消息，也需要从数据库删除
    if (message.shouldPersist && message.id != null) {
      _deleteMessageFromDatabase(message.id!);
    }
  }

  /// 清空所有消息
  void clearAllMessages() {
    _logger.info('清空所有消息', {'conversationId': _conversationId});

    // 取消正在进行的流式传输
    cancelStreaming();

    state = state.copyWith(
      messages: [],
      error: null,
    );
  }

  /// 从列表中移除消息
  void _removeMessage(Message message) {
    final updatedMessages =
        state.messages.where((m) => m.id != message.id).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  /// 从数据库删除消息
  Future<void> _deleteMessageFromDatabase(String messageId) async {
    try {
      final repository = _ref.read(conversationRepositoryProvider);
      await repository.deleteMessage(messageId);
      _logger.info('消息从数据库删除成功', {
        'conversationId': _conversationId,
        'messageId': messageId,
      });
    } catch (e) {
      _logger.error('消息从数据库删除失败', {
        'conversationId': _conversationId,
        'messageId': messageId,
        'error': e.toString(),
      });
    }
  }
}

/// 聊天消息Provider
final chatMessageNotifierProvider =
    StateNotifierProvider.family<ChatMessageNotifier, ChatMessageState, String>(
        (ref, conversationId) {
  return ChatMessageNotifier(ref, conversationId);
});
