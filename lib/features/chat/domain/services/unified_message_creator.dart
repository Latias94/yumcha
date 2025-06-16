import 'package:flutter/foundation.dart';

import '../entities/message.dart';
import '../entities/message_status.dart';
import '../repositories/message_repository.dart';
import 'message_factory.dart';
import '../../infrastructure/services/chat_logger_service.dart';

/// 统一的消息创建服务
/// 
/// 提供一致的消息创建接口，整合MessageFactory和MessageRepository的功能
/// 确保所有消息创建都遵循相同的模式和最佳实践
class UnifiedMessageCreator {
  final MessageFactory _messageFactory;
  final MessageRepository _messageRepository;

  UnifiedMessageCreator({
    required MessageFactory messageFactory,
    required MessageRepository messageRepository,
  })  : _messageFactory = messageFactory,
        _messageRepository = messageRepository;

  /// 创建并保存用户消息
  /// 
  /// [content] 消息内容
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [imageUrls] 可选的图片URL列表
  /// [metadata] 可选的元数据
  /// [saveToDatabase] 是否立即保存到数据库，默认为true
  Future<Message> createUserMessage({
    required String content,
    required String conversationId,
    required String assistantId,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
    bool saveToDatabase = true,
  }) async {
    ChatLoggerService.logDebug('创建用户消息', context: {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'contentLength': content.length,
      'hasImages': imageUrls?.isNotEmpty ?? false,
      'saveToDatabase': saveToDatabase,
    });

    // 使用MessageFactory创建消息
    final message = _messageFactory.createUserMessage(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      imageUrls: imageUrls,
      metadata: metadata,
    );

    // 根据参数决定是否保存到数据库
    if (saveToDatabase) {
      await _messageRepository.saveMessage(message);
      ChatLoggerService.logMessageCreated(message);
    }

    return message;
  }

  /// 创建并保存AI消息占位符
  /// 
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [modelId] 可选的模型ID
  /// [metadata] 可选的元数据
  /// [saveToDatabase] 是否立即保存到数据库，默认为true
  Future<Message> createAiMessagePlaceholder({
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
    bool saveToDatabase = true,
  }) async {
    ChatLoggerService.logDebug('创建AI消息占位符', context: {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
      'saveToDatabase': saveToDatabase,
    });

    // 使用MessageFactory创建消息
    final message = _messageFactory.createAiMessagePlaceholder(
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      metadata: metadata,
    );

    // 根据参数决定是否保存到数据库
    if (saveToDatabase) {
      await _messageRepository.saveMessage(message);
      ChatLoggerService.logMessageCreated(message);
    }

    return message;
  }

  /// 创建流式消息
  /// 
  /// 流式消息在创建时只保存基本信息，内容在流式过程中更新
  /// 
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [modelId] 可选的模型ID
  /// [metadata] 可选的元数据
  Future<Message> createStreamingMessage({
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) async {
    ChatLoggerService.logDebug('创建流式消息', context: {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
    });

    // 使用MessageFactory创建流式消息
    final message = _messageFactory.createStreamingMessage(
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      metadata: metadata,
    );

    // 保存消息基本信息到数据库
    await _messageRepository.saveMessage(message);

    // 初始化流式处理
    await _messageRepository.startStreamingMessage(message.id);

    ChatLoggerService.logMessageCreated(message);
    return message;
  }

  /// 创建完整的AI消息
  /// 
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [content] 主要内容
  /// [thinkingContent] 可选的思考过程内容
  /// [toolCalls] 可选的工具调用列表
  /// [modelId] 可选的模型ID
  /// [metadata] 可选的元数据
  /// [saveToDatabase] 是否立即保存到数据库，默认为true
  Future<Message> createCompleteAiMessage({
    required String conversationId,
    required String assistantId,
    required String content,
    String? thinkingContent,
    List<Map<String, dynamic>>? toolCalls,
    String? modelId,
    Map<String, dynamic>? metadata,
    bool saveToDatabase = true,
  }) async {
    ChatLoggerService.logDebug('创建完整AI消息', context: {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'contentLength': content.length,
      'hasThinking': thinkingContent?.isNotEmpty ?? false,
      'hasToolCalls': toolCalls?.isNotEmpty ?? false,
      'saveToDatabase': saveToDatabase,
    });

    // 使用MessageFactory创建消息
    final message = _messageFactory.createAiMessage(
      conversationId: conversationId,
      assistantId: assistantId,
      content: content,
      thinkingContent: thinkingContent,
      toolCalls: toolCalls,
      modelId: modelId,
      metadata: metadata,
    );

    // 根据参数决定是否保存到数据库
    if (saveToDatabase) {
      await _messageRepository.saveMessage(message);
      ChatLoggerService.logMessageCreated(message);
    }

    return message;
  }

  /// 创建错误消息
  /// 
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [errorMessage] 错误信息
  /// [originalMessageId] 可选的原始消息ID
  /// [metadata] 可选的元数据
  /// [saveToDatabase] 是否立即保存到数据库，默认为true
  Future<Message> createErrorMessage({
    required String conversationId,
    required String assistantId,
    required String errorMessage,
    String? originalMessageId,
    Map<String, dynamic>? metadata,
    bool saveToDatabase = true,
  }) async {
    ChatLoggerService.logDebug('创建错误消息', context: {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'errorMessage': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
      'originalMessageId': originalMessageId,
      'saveToDatabase': saveToDatabase,
    });

    // 使用MessageFactory创建消息
    final message = _messageFactory.createErrorMessage(
      conversationId: conversationId,
      assistantId: assistantId,
      errorMessage: errorMessage,
      originalMessageId: originalMessageId,
      metadata: metadata,
    );

    // 根据参数决定是否保存到数据库
    if (saveToDatabase) {
      await _messageRepository.saveMessage(message);
      ChatLoggerService.logMessageCreated(message);
    }

    return message;
  }

  /// 更新流式消息内容
  /// 
  /// [messageId] 消息ID
  /// [content] 新的内容
  /// [thinkingContent] 可选的思考过程内容
  Future<void> updateStreamingContent({
    required String messageId,
    required String content,
    String? thinkingContent,
  }) async {
    await _messageRepository.updateStreamingContent(
      messageId: messageId,
      content: content,
      thinkingContent: thinkingContent,
    );
  }

  /// 完成流式消息
  /// 
  /// [messageId] 消息ID
  /// [metadata] 可选的元数据
  Future<void> finishStreamingMessage({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    await _messageRepository.finishStreamingMessage(
      messageId: messageId,
      metadata: metadata,
    );
    
    ChatLoggerService.logDebug('流式消息完成', context: {
      'messageId': messageId,
    });
  }

  /// 处理流式消息错误
  /// 
  /// [messageId] 消息ID
  /// [errorMessage] 错误信息
  /// [partialContent] 可选的部分内容
  Future<void> handleStreamingError({
    required String messageId,
    required String errorMessage,
    String? partialContent,
  }) async {
    await _messageRepository.handleStreamingError(
      messageId: messageId,
      errorMessage: errorMessage,
      partialContent: partialContent,
    );
    
    ChatLoggerService.logDebug('流式消息错误处理完成', context: {
      'messageId': messageId,
      'errorMessage': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
    });
  }
}
