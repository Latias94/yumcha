import 'dart:math' as math;
import '../entities/message.dart';
import '../entities/message_block.dart';
import '../entities/message_block_type.dart';
import '../entities/message_status.dart';
import '../entities/message_block_status.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/infrastructure/services/message_id_service.dart';

/// 统一的消息工厂服务
/// 
/// 负责创建所有类型的消息和消息块，消除重复的消息创建逻辑。
/// 提供一致的消息创建接口，确保消息结构的统一性。
class MessageFactory {
  static final MessageFactory _instance = MessageFactory._internal();
  factory MessageFactory() => _instance;
  MessageFactory._internal();

  final _logger = LoggerService();
  final _messageIdService = MessageIdService();

  /// 创建用户消息
  /// 
  /// [content] 消息内容
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [imageUrls] 可选的图片URL列表
  /// [metadata] 可选的元数据
  Message createUserMessage({
    required String content,
    required String conversationId,
    required String assistantId,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final messageId = _messageIdService.generateUserMessageId();
    
    _logger.debug('创建用户消息', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'contentLength': content.length,
      'hasImages': imageUrls?.isNotEmpty ?? false,
      'imageCount': imageUrls?.length ?? 0,
    });

    // 创建消息块列表
    final blocks = <MessageBlock>[];
    int orderIndex = 0;

    // 添加主文本块
    if (content.isNotEmpty) {
      final textBlock = MessageBlock.text(
        id: '${messageId}_text_$orderIndex',
        messageId: messageId,
        content: content,
      );
      blocks.add(textBlock);
      orderIndex++;
    }

    // 添加图片块
    if (imageUrls != null && imageUrls.isNotEmpty) {
      for (final imageUrl in imageUrls) {
        final imageBlock = MessageBlock.image(
          id: '${messageId}_image_$orderIndex',
          messageId: messageId,
          url: imageUrl,
        );
        blocks.add(imageBlock);
        orderIndex++;
      }
    }

    // 创建用户消息
    final message = Message.user(
      id: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      blockIds: blocks.map((b) => b.id).toList(),
      createdAt: now,
      metadata: {
        'content': content,
        'imageCount': imageUrls?.length ?? 0,
        ...?metadata,
      },
    ).copyWith(blocks: blocks);

    _logger.debug('用户消息创建完成', {
      'messageId': messageId,
      'blocksCount': blocks.length,
      'blockTypes': blocks.map((b) => b.type.name).toList(),
    });

    return message;
  }

  /// 创建AI消息占位符
  /// 
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [modelId] 可选的模型ID
  /// [metadata] 可选的元数据
  Message createAiMessagePlaceholder({
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final messageId = _messageIdService.generateAiMessageId();

    _logger.debug('创建AI消息占位符', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
    });

    final message = Message.assistant(
      id: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      status: MessageStatus.aiProcessing,
      createdAt: now,
      modelId: modelId,
      metadata: metadata,
    );

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
  Message createAiMessage({
    required String conversationId,
    required String assistantId,
    required String content,
    String? thinkingContent,
    List<Map<String, dynamic>>? toolCalls,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final messageId = _messageIdService.generateAiMessageId();

    _logger.debug('创建AI消息', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'contentLength': content.length,
      'hasThinking': thinkingContent?.isNotEmpty ?? false,
      'hasToolCalls': toolCalls?.isNotEmpty ?? false,
      'modelId': modelId,
    });

    // 创建消息块列表
    final blocks = <MessageBlock>[];
    int orderIndex = 0;

    // 添加思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      final thinkingBlock = MessageBlock(
        id: '${messageId}_thinking_$orderIndex',
        messageId: messageId,
        type: MessageBlockType.thinking,
        status: MessageBlockStatus.success,
        createdAt: DateTime.now(),
        content: thinkingContent,
      );
      blocks.add(thinkingBlock);
      orderIndex++;
    }

    // 添加主文本块
    if (content.isNotEmpty) {
      final textBlock = MessageBlock.text(
        id: '${messageId}_text_$orderIndex',
        messageId: messageId,
        content: content,
      );
      blocks.add(textBlock);
      orderIndex++;
    }

    // 添加工具调用块
    if (toolCalls != null && toolCalls.isNotEmpty) {
      for (int i = 0; i < toolCalls.length; i++) {
        final toolCall = toolCalls[i];
        final toolBlock = MessageBlock.tool(
          id: '${messageId}_tool_${orderIndex}',
          messageId: messageId,
          toolName: toolCall['name'] as String? ?? 'unknown',
          arguments: toolCall['arguments'] as Map<String, dynamic>? ?? {},
        );
        blocks.add(toolBlock);
        orderIndex++;
      }
    }

    // 创建AI消息
    final message = Message.assistant(
      id: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      status: MessageStatus.aiSuccess,
      blockIds: blocks.map((b) => b.id).toList(),
      createdAt: now,
      modelId: modelId,
      metadata: {
        'content': content,
        'thinkingLength': thinkingContent?.length ?? 0,
        'toolCallsCount': toolCalls?.length ?? 0,
        ...?metadata,
      },
    ).copyWith(blocks: blocks);

    _logger.debug('AI消息创建完成', {
      'messageId': messageId,
      'blocksCount': blocks.length,
      'blockTypes': blocks.map((b) => b.type.name).toList(),
    });

    return message;
  }

  /// 为现有AI消息添加内容块
  /// 
  /// [message] 现有的AI消息
  /// [content] 主要内容
  /// [thinkingContent] 可选的思考过程内容
  /// [toolCalls] 可选的工具调用列表
  /// [metadata] 可选的元数据
  Message completeAiMessage({
    required Message message,
    required String content,
    String? thinkingContent,
    List<Map<String, dynamic>>? toolCalls,
    Map<String, dynamic>? metadata,
  }) {
    if (message.role != 'assistant') {
      throw ArgumentError('只能完成AI消息');
    }

    _logger.debug('完成AI消息', {
      'messageId': message.id,
      'contentLength': content.length,
      'hasThinking': thinkingContent?.isNotEmpty ?? false,
      'hasToolCalls': toolCalls?.isNotEmpty ?? false,
    });

    // 创建新的消息块列表
    final blocks = <MessageBlock>[...message.blocks];
    int orderIndex = blocks.length;

    // 添加思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      final thinkingBlock = MessageBlock(
        id: '${message.id}_thinking_$orderIndex',
        messageId: message.id!,
        type: MessageBlockType.thinking,
        status: MessageBlockStatus.success,
        createdAt: DateTime.now(),
        content: thinkingContent,
      );
      blocks.add(thinkingBlock);
      orderIndex++;
    }

    // 添加主文本块
    if (content.isNotEmpty) {
      final textBlock = MessageBlock.text(
        id: '${message.id}_text_$orderIndex',
        messageId: message.id!,
        content: content,
      );
      blocks.add(textBlock);
      orderIndex++;
    }

    // 添加工具调用块
    if (toolCalls != null && toolCalls.isNotEmpty) {
      for (int i = 0; i < toolCalls.length; i++) {
        final toolCall = toolCalls[i];
        final toolBlock = MessageBlock.tool(
          id: '${message.id}_tool_${orderIndex}',
          messageId: message.id!,
          toolName: toolCall['name'] as String? ?? 'unknown',
          arguments: toolCall['arguments'] as Map<String, dynamic>? ?? {},
        );
        blocks.add(toolBlock);
        orderIndex++;
      }
    }

    // 更新消息
    final updatedMessage = message.copyWith(
      status: MessageStatus.aiSuccess,
      blockIds: blocks.map((b) => b.id).toList(),
      blocks: blocks,
      updatedAt: DateTime.now(),
      metadata: {
        ...?message.metadata,
        'content': content,
        'thinkingLength': thinkingContent?.length ?? 0,
        'toolCallsCount': toolCalls?.length ?? 0,
        ...?metadata,
      },
    );

    _logger.debug('AI消息完成', {
      'messageId': message.id,
      'totalBlocksCount': blocks.length,
      'newBlocksCount': blocks.length - message.blocks.length,
    });

    return updatedMessage;
  }

  /// 创建错误消息
  ///
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [errorMessage] 错误信息
  /// [originalMessageId] 可选的原始消息ID
  /// [metadata] 可选的元数据
  Message createErrorMessage({
    required String conversationId,
    required String assistantId,
    required String errorMessage,
    String? originalMessageId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final messageId = _messageIdService.generateAiMessageId();

    _logger.debug('创建错误消息', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'errorMessage': errorMessage.substring(0, math.min(100, errorMessage.length)),
      'originalMessageId': originalMessageId,
    });

    // 创建错误文本块
    final errorBlock = MessageBlock.text(
      id: '${messageId}_error_0',
      messageId: messageId,
      content: errorMessage,
      status: MessageBlockStatus.error,
    );

    final message = Message.assistant(
      id: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      status: MessageStatus.aiError,
      blockIds: [errorBlock.id],
      createdAt: now,
      metadata: {
        'isError': true,
        'originalMessageId': originalMessageId,
        ...?metadata,
      },
    ).copyWith(blocks: [errorBlock]);

    return message;
  }

  /// 创建流式消息的初始状态
  ///
  /// [conversationId] 对话ID
  /// [assistantId] 助手ID
  /// [modelId] 可选的模型ID
  /// [metadata] 可选的元数据
  Message createStreamingMessage({
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final messageId = _messageIdService.generateAiMessageId();

    _logger.debug('创建流式消息', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
    });

    // 创建空的文本块作为流式内容的容器
    final textBlock = MessageBlock.text(
      id: '${messageId}_streaming_0',
      messageId: messageId,
      content: '',
      status: MessageBlockStatus.streaming,
    );

    final message = Message.assistant(
      id: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      status: MessageStatus.aiProcessing,
      blockIds: [textBlock.id],
      createdAt: now,
      modelId: modelId,
      metadata: {
        'isStreaming': true,
        ...?metadata,
      },
    ).copyWith(blocks: [textBlock]);

    return message;
  }

  /// 更新流式消息内容
  ///
  /// [message] 现有的流式消息
  /// [content] 新的内容
  /// [isComplete] 是否完成流式传输
  Message updateStreamingMessage({
    required Message message,
    required String content,
    bool isComplete = false,
  }) {
    if (message.status != MessageStatus.aiProcessing) {
      throw ArgumentError('只能更新流式消息');
    }

    // 更新第一个文本块的内容
    final updatedBlocks = message.blocks.map((block) {
      if (block.type == MessageBlockType.mainText) {
        return block.copyWith(
          content: content,
          status: isComplete ? MessageBlockStatus.success : MessageBlockStatus.streaming,
          updatedAt: DateTime.now(),
        );
      }
      return block;
    }).toList();

    final updatedMessage = message.copyWith(
      status: isComplete ? MessageStatus.aiSuccess : MessageStatus.aiProcessing,
      blocks: updatedBlocks,
      updatedAt: DateTime.now(),
      metadata: {
        ...?message.metadata,
        'isStreaming': !isComplete,
        'contentLength': content.length,
      },
    );

    return updatedMessage;
  }

  /// 从现有消息创建副本（用于编辑等场景）
  ///
  /// [originalMessage] 原始消息
  /// [newContent] 新内容（可选）
  /// [preserveId] 是否保留原始ID
  Message copyMessage({
    required Message originalMessage,
    String? newContent,
    bool preserveId = false,
  }) {
    final messageId = preserveId ? originalMessage.id :
        (originalMessage.isFromUser ?
         _messageIdService.generateUserMessageId() :
         _messageIdService.generateAiMessageId());

    _logger.debug('复制消息', {
      'originalId': originalMessage.id,
      'newId': messageId,
      'preserveId': preserveId,
      'hasNewContent': newContent != null,
    });

    // 复制消息块
    final newBlocks = originalMessage.blocks.map((block) {
      final newBlockId = preserveId ? block.id : '${messageId}_${block.type.name}_0';

      return block.copyWith(
        id: newBlockId,
        messageId: messageId,
        content: (newContent != null && block.type == MessageBlockType.mainText)
            ? newContent
            : block.content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    final newMessage = originalMessage.copyWith(
      id: messageId,
      blockIds: newBlocks.map((b) => b.id).toList(),
      blocks: newBlocks,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        ...?originalMessage.metadata,
        'copiedFrom': originalMessage.id,
        'copyTime': DateTime.now().toIso8601String(),
      },
    );

    return newMessage;
  }
}
