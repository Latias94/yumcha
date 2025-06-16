import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/entities/message_block_status.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/services/block_chat_service.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../../ai_management/domain/entities/ai_model.dart';
import 'chat_providers.dart'; // 导入正确的Provider定义

/// 块化消息状态
class BlockMessageState {
  final List<Message> messages;
  final Map<String, StreamSubscription> streamingSubscriptions;
  final bool isLoading;
  final String? error;

  const BlockMessageState({
    this.messages = const [],
    this.streamingSubscriptions = const {},
    this.isLoading = false,
    this.error,
  });

  BlockMessageState copyWith({
    List<Message>? messages,
    Map<String, StreamSubscription>? streamingSubscriptions,
    bool? isLoading,
    String? error,
  }) {
    return BlockMessageState(
      messages: messages ?? this.messages,
      streamingSubscriptions: streamingSubscriptions ?? this.streamingSubscriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 获取流式消息
  List<Message> get streamingMessages {
    return messages.where((m) => 
      m.status == MessageStatus.aiProcessing ||
      m.blocks.any((b) => b.status == MessageBlockStatus.streaming)
    ).toList();
  }

  /// 是否有流式消息
  bool get hasStreamingMessages => streamingMessages.isNotEmpty;
}

/// 块化消息状态管理器
class BlockMessageNotifier extends StateNotifier<BlockMessageState> {
  final MessageRepository _messageRepository;
  final BlockChatService _chatService;

  BlockMessageNotifier({
    required MessageRepository messageRepository,
    required BlockChatService chatService,
  }) : _messageRepository = messageRepository,
       _chatService = chatService,
       super(const BlockMessageState());

  /// 加载对话消息
  Future<void> loadConversationMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final messages = await _messageRepository.getConversationWithBlocks(conversationId);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 发送消息
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required AiAssistant assistant,
    required AiProvider provider,
    required AiModel model,
    List<String>? imageUrls,
    bool useStreaming = true,
  }) async {
    try {
      // 发送消息并获取AI响应
      final aiMessage = await _chatService.sendMessage(
        conversationId: conversationId,
        content: content,
        assistant: assistant,
        provider: provider,
        model: model,
        imageUrls: imageUrls,
        useStreaming: useStreaming,
      );

      // 重新加载消息列表
      await loadConversationMessages(conversationId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 重新生成消息
  Future<void> regenerateMessage({
    required String messageId,
    required AiAssistant assistant,
    required AiProvider provider,
    required AiModel model,
    bool useStreaming = true,
  }) async {
    try {
      final newMessage = await _chatService.regenerateMessage(
        messageId: messageId,
        assistant: assistant,
        provider: provider,
        model: model,
        useStreaming: useStreaming,
      );

      // 更新消息列表
      final updatedMessages = state.messages.map((m) {
        return m.id == messageId ? newMessage : m;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);

      // 从状态中移除消息
      final updatedMessages = state.messages.where((m) => m.id != messageId).toList();
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 编辑消息块
  Future<void> editMessageBlock(String blockId, String newContent) async {
    try {
      await _messageRepository.updateBlockContent(blockId, newContent);

      // 重新加载消息以获取最新状态
      final message = state.messages.firstWhere(
        (m) => m.blocks.any((b) => b.id == blockId),
      );
      await loadConversationMessages(message.conversationId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 删除消息块
  Future<void> deleteMessageBlock(String blockId) async {
    try {
      await _messageRepository.deleteMessageBlock(blockId);

      // 重新加载消息以获取最新状态
      final message = state.messages.firstWhere(
        (m) => m.blocks.any((b) => b.id == blockId),
      );
      await loadConversationMessages(message.conversationId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 重新生成消息块
  Future<void> regenerateMessageBlock({
    required String blockId,
    required AiAssistant assistant,
    required AiProvider provider,
    required AiModel model,
  }) async {
    try {
      // 找到包含该块的消息
      final message = state.messages.firstWhere(
        (m) => m.blocks.any((b) => b.id == blockId),
      );

      // 重新生成整个消息（简化实现）
      await regenerateMessage(
        messageId: message.id,
        assistant: assistant,
        provider: provider,
        model: model,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 搜索消息
  Future<List<Message>> searchMessages({
    required String query,
    String? conversationId,
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _chatService.searchMessages(
        query: query,
        conversationId: conversationId,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 添加消息到状态（用于实时更新）
  void addMessage(Message message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  /// 更新消息（用于实时更新）
  void updateMessage(Message updatedMessage) {
    final updatedMessages = state.messages.map((m) {
      return m.id == updatedMessage.id ? updatedMessage : m;
    }).toList();
    state = state.copyWith(messages: updatedMessages);
  }

  /// 更新消息块（用于流式更新）
  void updateMessageBlock(String messageId, MessageBlock updatedBlock) {
    final updatedMessages = state.messages.map((m) {
      if (m.id == messageId) {
        final updatedBlocks = m.blocks.map((b) {
          return b.id == updatedBlock.id ? updatedBlock : b;
        }).toList();
        return m.copyWith(blocks: updatedBlocks);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updatedMessages);
  }

  @override
  void dispose() {
    // 取消所有流式订阅
    for (final subscription in state.streamingSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}

/// 块化消息状态Provider
final blockMessageProvider = StateNotifierProvider.family<BlockMessageNotifier, BlockMessageState, String>(
  (ref, conversationId) {
    final messageRepository = ref.watch(messageRepositoryProvider);
    final chatService = ref.watch(domainBlockChatServiceProvider);

    final notifier = BlockMessageNotifier(
      messageRepository: messageRepository,
      chatService: chatService,
    );

    // 自动加载对话消息
    Future.microtask(() => notifier.loadConversationMessages(conversationId));

    return notifier;
  },
);

// 注意：messageRepositoryProvider 和 domainBlockChatServiceProvider
// 已在 chat_providers.dart 中定义，这里不再重复定义
// 如需使用，请导入：import '../providers/chat_providers.dart';

/// 当前对话消息Provider - 使用autoDispose避免内存泄漏
final currentConversationMessagesProvider = Provider.autoDispose.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(blockMessageProvider(conversationId)).messages;
});

/// 流式消息Provider - 使用autoDispose避免内存泄漏
final streamingMessagesProvider = Provider.autoDispose.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(blockMessageProvider(conversationId)).streamingMessages;
});

/// 是否有流式消息Provider - 使用autoDispose避免内存泄漏
final hasStreamingMessagesProvider = Provider.autoDispose.family<bool, String>((ref, conversationId) {
  return ref.watch(blockMessageProvider(conversationId)).hasStreamingMessages;
});
