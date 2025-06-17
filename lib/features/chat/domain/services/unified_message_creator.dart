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

  /// 创建并保存用户消息（第一步：用户输入处理）
  ///
  /// 🔍 **为什么用户消息需要立即保存？**
  /// 用户消息与AI消息分别保存是正常的业务逻辑，原因：
  /// 1. 📝 **数据安全**：确保用户输入不丢失，即使后续AI处理失败
  /// 2. 🔄 **对话连续性**：为AI处理提供完整的对话历史上下文
  /// 3. 🛡️ **故障恢复**：支持对话恢复和消息重发功能
  /// 4. 📱 **用户体验**：符合聊天应用标准流程（发送→显示→处理）
  /// 5. 🔍 **审计追踪**：记录完整的用户交互历史
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

    // 💾 用户消息立即保存：确保用户输入不丢失，为AI处理提供上下文
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
      'errorMessage':
          errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
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
      'errorMessage':
          errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
    });
  }

  /// 从BlockBasedChatService的结果创建AI消息（第二步：AI响应处理）
  ///
  /// 🔍 **为什么AI消息需要单独保存？**
  /// AI消息与用户消息分别保存是正常的业务逻辑，原因：
  /// 1. ⏰ **时间差异**：用户消息立即保存，AI消息在处理完成后保存
  /// 2. 📊 **状态不同**：用户消息状态固定，AI消息状态需要根据处理结果设置
  /// 3. 🧩 **内容结构**：AI消息包含复杂的块结构（文本、思考、工具调用等）
  /// 4. 📈 **元数据差异**：AI消息包含处理时长、模型信息等额外元数据
  /// 5. ⚠️ **错误处理**：AI消息可能失败，需要保存错误状态和部分内容
  ///
  /// [blockMessage] 来自块化服务的消息对象
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [additionalMetadata] 可选的额外元数据
  /// [saveToDatabase] 是否立即保存到数据库，默认为true
  Future<Message> createAiMessageFromBlockService({
    required Message blockMessage,
    required String conversationId,
    required String assistantId,
    Map<String, dynamic>? additionalMetadata,
    bool saveToDatabase = true,
  }) async {
    ChatLoggerService.logDebug('从块服务创建AI消息', context: {
      'messageId': blockMessage.id,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'hasAdditionalMetadata': additionalMetadata != null,
      'saveToDatabase': saveToDatabase,
    });

    // 验证输入参数
    if (blockMessage.role != 'assistant') {
      throw ArgumentError('blockMessage必须是assistant角色的消息');
    }

    // 合并元数据
    final finalMetadata = <String, dynamic>{
      ...?blockMessage.metadata,
      ...?additionalMetadata,
      'createdBy': 'UnifiedMessageCreator.createAiMessageFromBlockService',
      'processedAt': DateTime.now().toIso8601String(),
    };

    // 创建最终消息
    final finalMessage = blockMessage.copyWith(
      status: MessageStatus.aiSuccess,
      updatedAt: DateTime.now(),
      metadata: finalMetadata,
    );

    // 💾 AI消息处理完成后保存：包含完整的响应内容、状态和元数据
    if (saveToDatabase) {
      await _messageRepository.saveMessage(finalMessage);
      ChatLoggerService.logMessageCreated(finalMessage);
    }

    return finalMessage;
  }

  /// 统一创建错误消息（支持流式和非流式）
  ///
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [error] 错误对象
  /// [messageId] 可选的消息ID（流式错误时使用）
  /// [partialContent] 可选的部分内容
  /// [isStreaming] 是否为流式错误，默认为false
  /// [saveToDatabase] 是否立即保存到数据库，默认为true
  Future<Message> createUnifiedErrorMessage({
    required String conversationId,
    required String assistantId,
    required Object error,
    String? messageId,
    String? partialContent,
    bool isStreaming = false,
    bool saveToDatabase = true,
  }) async {
    ChatLoggerService.logDebug('创建统一错误消息', context: {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'messageId': messageId,
      'isStreaming': isStreaming,
      'hasPartialContent': partialContent != null,
      'saveToDatabase': saveToDatabase,
      'errorType': error.runtimeType.toString(),
    });

    final errorMessage = _getUserFriendlyErrorMessage(error);

    if (isStreaming && messageId != null) {
      // 流式错误：更新现有消息
      await _messageRepository.handleStreamingError(
        messageId: messageId,
        errorMessage: errorMessage,
        partialContent: partialContent,
      );

      // 返回更新后的消息
      final updatedMessage = await _messageRepository.getMessage(messageId);
      if (updatedMessage != null) {
        ChatLoggerService.logDebug('流式错误消息已更新', context: {
          'messageId': messageId,
          'status': updatedMessage.status.name,
        });
        return updatedMessage;
      } else {
        // 如果无法获取更新后的消息，创建一个备用错误消息
        return _createFallbackErrorMessage(
            conversationId, assistantId, errorMessage);
      }
    } else {
      // 非流式错误：创建新的错误消息
      return await createErrorMessage(
        conversationId: conversationId,
        assistantId: assistantId,
        errorMessage: errorMessage,
        originalMessageId: messageId,
        metadata: {
          'errorType': error.runtimeType.toString(),
          'originalError': error.toString(),
          'isStreaming': isStreaming,
          'hasPartialContent': partialContent != null,
        },
        saveToDatabase: saveToDatabase,
      );
    }
  }

  /// 获取用户友好的错误信息
  String _getUserFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return '网络连接失败，请检查网络设置';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('api key')) {
      return 'API密钥无效，请检查配置';
    }

    if (errorString.contains('rate limit') || errorString.contains('quota')) {
      return '请求过于频繁，请稍后再试';
    }

    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'AI服务暂时不可用，请稍后重试';
    }

    if (errorString.contains('model') && errorString.contains('not found')) {
      return '所选模型不可用，请尝试其他模型';
    }

    if (errorString.contains('unknown') ||
        errorString.contains('null') ||
        errorString.trim().isEmpty) {
      return '连接失败，请检查网络和API配置';
    }

    return '发送失败，请重试';
  }

  /// 创建备用错误消息
  Message _createFallbackErrorMessage(
    String conversationId,
    String assistantId,
    String errorMessage,
  ) {
    return _messageFactory.createErrorMessage(
      conversationId: conversationId,
      assistantId: assistantId,
      errorMessage: errorMessage,
      metadata: {
        'createdBy': 'UnifiedMessageCreator._createFallbackErrorMessage',
        'isFallback': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
