import 'dart:async';
import 'package:uuid/uuid.dart';
import '../entities/message.dart';

import '../entities/message_block.dart';
import '../entities/message_block_type.dart';
import '../entities/message_status.dart';
import '../entities/message_block_status.dart';
import '../exceptions/chat_exceptions.dart';
import '../repositories/message_repository.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/domain/entities/ai_provider.dart' as models;
import '../../../ai_management/domain/entities/ai_model.dart';
import '../../../../shared/infrastructure/services/ai/chat/chat_service.dart';
import '../../../../shared/infrastructure/services/ai/core/ai_response_models.dart';
import '../../infrastructure/services/chat_logger_service.dart';
import '../../infrastructure/services/error_recovery_service.dart';

/// 块化聊天服务
/// 
/// 基于新的块化消息架构的聊天服务，支持：
/// - 块化消息处理
/// - 流式消息更新
/// - 多模态内容
/// - 精细化状态管理
class BlockChatService {
  final MessageRepository _messageRepository;
  final ChatService _chatService;
  final ErrorRecoveryService _errorRecoveryService;
  final _uuid = Uuid();

  BlockChatService({
    required MessageRepository messageRepository,
    required ChatService chatService,
  }) : _messageRepository = messageRepository,
       _chatService = chatService,
       _errorRecoveryService = ErrorRecoveryService(messageRepository: messageRepository);

  /// 发送用户消息并获取AI响应
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    required AiAssistant assistant,
    required models.AiProvider provider,
    required AiModel model,
    List<String>? imageUrls,
    bool useStreaming = false,
  }) async {
    ChatLoggerService.logDebug(
      'Sending message: conversation=$conversationId, assistant=${assistant.id}, model=${model.id}, streaming=$useStreaming',
    );

    try {
      // 1. 创建用户消息
      final userMessage = await _messageRepository.createUserMessage(
        conversationId: conversationId,
        assistantId: assistant.id,
        content: content,
        imageUrls: imageUrls,
      );

      ChatLoggerService.logMessageCreated(userMessage);

      // 2. 创建AI消息占位符
      final aiMessage = await _messageRepository.createAiMessagePlaceholder(
        conversationId: conversationId,
        assistantId: assistant.id,
        modelId: model.id,
      );

      ChatLoggerService.logMessageCreated(aiMessage);

      try {
        if (useStreaming) {
          // 流式处理
          ChatLoggerService.logStreamingStarted(aiMessage.id, provider.name, model.name);
          await _handleStreamingResponse(
            aiMessage.id,
            conversationId,
            assistant,
            provider,
            model,
          );
        } else {
          // 非流式处理
          ChatLoggerService.logAiServiceCall(provider.name, model.name, 'sendMessage');
          await _handleNormalResponse(
            aiMessage.id,
            conversationId,
            assistant,
            provider,
            model,
          );
        }

        // 返回完整的AI消息
        final completedMessage = await _messageRepository.getMessageWithBlocks(aiMessage.id);
        ChatLoggerService.logMessageUpdated(completedMessage, 'completed');
        return completedMessage;

      } catch (e) {
        // 处理错误
        ChatLoggerService.logException(
          AiServiceException(
            message: 'Failed to process AI response for message ${aiMessage.id}',
            code: 'AI_RESPONSE_PROCESSING_FAILED',
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );

        await _messageRepository.handleStreamingError(
          messageId: aiMessage.id,
          errorMessage: e.toString(),
        );
        rethrow;
      }
    } catch (e) {
      ChatLoggerService.logException(
        MessageException(
          message: 'Failed to send message in conversation $conversationId',
          code: 'MESSAGE_SEND_FAILED',
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
      rethrow;
    }
  }

  /// 处理流式响应
  Future<void> _handleStreamingResponse(
    String messageId,
    String conversationId,
    AiAssistant assistant,
    models.AiProvider provider,
    AiModel model,
  ) async {
    await _messageRepository.startStreamingMessage(messageId);

    // 获取历史消息
    final historyMessages = await _getHistoryMessages(conversationId);

    // 获取当前消息的用户输入
    final currentMessage = await _messageRepository.getMessage(messageId);
    if (currentMessage == null) {
      throw Exception('消息不存在: $messageId');
    }

    // 构建用户消息内容
    final userContent = await _buildUserContent(conversationId);

    final streamController = StreamController<String>();
    String accumulatedContent = '';
    String? accumulatedThinking;

    // 监听流式事件
    final streamSubscription = _chatService.sendMessageStream(
      provider: provider,
      assistant: assistant,
      modelName: model.name,
      chatHistory: historyMessages,
      userMessage: userContent,
    ).listen(
      (event) async {
        if (event.isContent) {
          accumulatedContent += event.contentDelta!;
          await _messageRepository.updateStreamingContent(
            messageId: messageId,
            content: accumulatedContent,
            thinkingContent: accumulatedThinking,
          );
        } else if (event.isThinking) {
          accumulatedThinking = (accumulatedThinking ?? '') + event.thinkingDelta!;
          await _messageRepository.updateStreamingContent(
            messageId: messageId,
            content: accumulatedContent,
            thinkingContent: accumulatedThinking,
          );
        } else if (event.isToolCall) {
          // 处理工具调用
          // TODO: 实现工具调用块的创建
        } else if (event.isCompleted) {
          final metadata = <String, dynamic>{};

          if (event.usage != null) {
            metadata['usage'] = {
              'totalTokens': event.usage!.totalTokens,
              'promptTokens': event.usage!.promptTokens,
              'completionTokens': event.usage!.completionTokens,
            };
          }
          if (event.duration != null) {
            metadata['duration'] = event.duration!.inMilliseconds;
          }

          await _messageRepository.finishStreamingMessage(
            messageId: messageId,
            metadata: metadata.isNotEmpty ? metadata : null,
          );
        } else if (event.isError) {
          await _messageRepository.handleStreamingError(
            messageId: messageId,
            errorMessage: event.error!,
            partialContent: accumulatedContent.isNotEmpty ? accumulatedContent : null,
          );
        }
      },
      onError: (error) async {
        await _messageRepository.handleStreamingError(
          messageId: messageId,
          errorMessage: error.toString(),
          partialContent: accumulatedContent.isNotEmpty ? accumulatedContent : null,
        );
      },
    );

    // 等待流完成
    await streamSubscription.asFuture();
  }

  /// 处理非流式响应
  Future<void> _handleNormalResponse(
    String messageId,
    String conversationId,
    AiAssistant assistant,
    models.AiProvider provider,
    AiModel model,
  ) async {
    // 获取历史消息
    final historyMessages = await _getHistoryMessages(conversationId);

    // 构建用户消息内容
    final userContent = await _buildUserContent(conversationId);

    // 发送请求
    final response = await _chatService.sendMessage(
      provider: provider,
      assistant: assistant,
      modelName: model.name,
      chatHistory: historyMessages,
      userMessage: userContent,
    );

    if (response.isSuccess) {
      // 完成AI消息
      await _messageRepository.completeAiMessage(
        messageId: messageId,
        content: response.content,
        thinkingContent: response.thinking,
        toolCalls: response.toolCalls?.map((tc) => {
          'name': tc.function.name,
          'arguments': tc.function.arguments,
          'result': null, // ToolCall doesn't have result field
        }).toList(),
        metadata: {
          if (response.usage != null) 'usage': {
            'totalTokens': response.usage!.totalTokens,
            'promptTokens': response.usage!.promptTokens,
            'completionTokens': response.usage!.completionTokens,
          },
          if (response.duration != null) 'duration': response.duration!.inMilliseconds,
        },
      );
    } else {
      // 处理错误
      await _messageRepository.handleStreamingError(
        messageId: messageId,
        errorMessage: response.error ?? '未知错误',
      );
    }
  }

  /// 获取历史消息（新格式）
  Future<List<Message>> _getHistoryMessages(String conversationId) async {
    final messages = await _messageRepository.getMessagesByConversation(conversationId);
    return messages;
  }

  /// 构建用户消息内容
  Future<String> _buildUserContent(String conversationId) async {
    final messages = await _messageRepository.getMessagesByConversation(conversationId);
    final lastUserMessage = messages.lastWhere(
      (msg) => msg.role == 'user',
      orElse: () => throw Exception('找不到用户消息'),
    );

    // 从主文本块中提取内容
    final mainTextContent = lastUserMessage.blocks
        .where((block) => block.type == MessageBlockType.mainText)
        .map((block) => block.content ?? '')
        .join('\n');

    return mainTextContent;
  }

  /// 获取对话的所有消息
  Future<List<Message>> getConversationMessages(String conversationId) async {
    return await _messageRepository.getConversationWithBlocks(conversationId);
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    await _messageRepository.deleteMessage(messageId);
  }

  /// 重新生成AI消息
  Future<Message> regenerateMessage({
    required String messageId,
    required AiAssistant assistant,
    required models.AiProvider provider,
    required AiModel model,
    bool useStreaming = false,
  }) async {
    final originalMessage = await _messageRepository.getMessage(messageId);
    if (originalMessage == null) {
      throw Exception('消息不存在: $messageId');
    }

    // 创建新的AI消息
    final newMessage = await _messageRepository.createAiMessagePlaceholder(
      conversationId: originalMessage.conversationId,
      assistantId: assistant.id,
      modelId: model.id,
    );

    try {
      if (useStreaming) {
        await _handleStreamingResponse(
          newMessage.id,
          originalMessage.conversationId,
          assistant,
          provider,
          model,
        );
      } else {
        await _handleNormalResponse(
          newMessage.id,
          originalMessage.conversationId,
          assistant,
          provider,
          model,
        );
      }

      // 删除原消息
      await _messageRepository.deleteMessage(messageId);

      return await _messageRepository.getMessageWithBlocks(newMessage.id);
    } catch (e) {
      // 如果失败，删除新消息并保留原消息
      await _messageRepository.deleteMessage(newMessage.id);
      rethrow;
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
    return await _messageRepository.searchMessages(
      query: query,
      conversationId: conversationId,
      assistantId: assistantId,
      limit: limit,
      offset: offset,
    );
  }
}
