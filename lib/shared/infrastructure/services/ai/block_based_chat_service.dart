import '../../../../features/chat/domain/entities/message.dart';
import '../../../../features/chat/domain/entities/message_block.dart';
import '../../../../features/chat/domain/entities/message_block_type.dart';
import '../../../../features/chat/domain/entities/message_block_status.dart';
import '../../../../features/chat/domain/entities/message_status.dart';
import '../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../features/chat/domain/services/message_factory.dart';
import '../media/media_storage_service.dart';
import 'ai_service_manager.dart';
import '../logger_service.dart';

/// 基于块的聊天服务 - 使用新的块化消息系统的AI聊天服务
///
/// 这个服务替代了EnhancedChatService，使用新的块化消息架构：
/// - 🧩 消息块化管理 - 每个消息由多个块组成
/// - 🎨 多媒体块支持 - 图片、音频、文件等作为独立块
/// - 🔄 流式块更新 - 支持实时块状态更新
/// - 📊 精细化状态管理 - 每个块独立的状态跟踪
///
/// ## 核心优势
///
/// ### 1. 更好的内容组织
/// - 文本、图片、音频等内容分离管理
/// - 支持复杂的多模态消息结构
/// - 便于内容的独立操作和展示
///
/// ### 2. 增强的流式体验
/// - 文本块可以流式更新
/// - 多媒体块可以异步生成
/// - 用户可以看到每个块的生成进度
///
/// ### 3. 更好的错误处理
/// - 单个块失败不影响整个消息
/// - 可以重试失败的块
/// - 精确的错误定位和反馈
class BlockBasedChatService {
  final AiServiceManager _serviceManager;
  final MediaStorageService _mediaService;
  final LoggerService _logger = LoggerService();
  final MessageFactory _messageFactory = MessageFactory();

  // 图片生成关键词检测
  static const List<String> _imageGenerationKeywords = [
    '画',
    '绘制',
    '生成图片',
    '创建图像',
    '制作图片',
    '设计图片',
    '画一张',
    '画个',
    '画出',
    '生成一张',
    '创作图片',
    '制作海报',
    'draw',
    'paint',
    'create image',
    'generate image',
    'make picture',
    'design',
    'illustrate',
    'sketch',
    'render'
  ];

  // TTS生成阈值和关键词
  static const int _ttsTextLengthThreshold = 100;
  static const List<String> _ttsRequestKeywords = [
    '读出来',
    '朗读',
    '语音播放',
    '念给我听',
    '用语音说',
    'read aloud',
    'speak',
    'voice',
    'audio',
    'tts'
  ];

  BlockBasedChatService({
    required AiServiceManager serviceManager,
    required MediaStorageService mediaService,
  })  : _serviceManager = serviceManager,
        _mediaService = mediaService;

  /// 发送块化聊天消息（支持多媒体生成）
  Future<Message> sendBlockMessage({
    required String messageId, // 🚀 阶段清理：必需的外部消息ID
    required String conversationId,
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
    bool autoGenerateImages = true,
    bool autoGenerateTts = true,
    bool enableImageAnalysis = true,
  }) async {
    final startTime = DateTime.now();
    final requestId = _generateRequestId();
    final finalMessageId = messageId; // 🚀 直接使用外部传入的ID

    _logger.info('开始块化聊天请求', {
      'requestId': requestId,
      'messageId': finalMessageId,
      'provider': provider.name,
      'model': modelName,
      'autoGenerateImages': autoGenerateImages,
      'autoGenerateTts': autoGenerateTts,
    });

    try {
      // 1. 检测用户消息中的图片生成请求
      final shouldGenerateImage =
          autoGenerateImages && _detectImageGenerationIntent(userMessage);

      // 2. 发送基础聊天请求
      final chatResponse = await _serviceManager.sendMessage(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      );

      if (!chatResponse.isSuccess) {
        // 🚀 使用MessageFactory创建错误消息
        return _messageFactory.createErrorMessage(
          conversationId: conversationId,
          assistantId: assistant.id,
          errorMessage: chatResponse.error ?? '聊天请求失败',
          metadata: {
            'modelName': modelName,
            'errorInfo': chatResponse.error,
            'messageId': finalMessageId, // 保持外部传入的ID
          },
        ).copyWith(id: finalMessageId); // 确保使用外部传入的ID
      }

      final aiContent = chatResponse.content;
      final blocks = <MessageBlock>[];

      // 3. 创建主文本块
      blocks.add(MessageBlock.text(
        id: '${finalMessageId}_text',
        messageId: finalMessageId,
        content: aiContent,
        status: MessageBlockStatus.success,
        createdAt: DateTime.now(),
        modelId: assistant.id,
        modelName: modelName,
      ));

      // 4. 处理图片生成（异步块）
      if (shouldGenerateImage) {
        final imageBlockId = '${finalMessageId}_image';
        blocks.add(MessageBlock(
          id: imageBlockId,
          messageId: finalMessageId,
          type: MessageBlockType.image,
          status: MessageBlockStatus.pending,
          createdAt: DateTime.now(),
          content: '正在生成图片...',
        ));

        // 异步生成图片并更新块
        _generateImageBlock(
          blockId: imageBlockId,
          messageId: finalMessageId,
          provider: provider,
          aiResponse: aiContent,
          userPrompt: userMessage,
        ).then((imageBlock) {
          // 这里需要通过某种机制更新消息块
          // 可能需要通过Repository或者事件系统
          _logger.info('图片块生成完成', {'blockId': imageBlockId});
        }).catchError((e) {
          _logger.warning('图片块生成失败', {
            'blockId': imageBlockId,
            'error': e.toString(),
          });
        });
      }

      // 5. 处理TTS生成（异步块）
      if (autoGenerateTts && _shouldGenerateTts(aiContent, userMessage)) {
        final audioBlockId = '${finalMessageId}_audio';
        blocks.add(MessageBlock(
          id: audioBlockId,
          messageId: finalMessageId,
          type: MessageBlockType.file,
          status: MessageBlockStatus.pending,
          createdAt: DateTime.now(),
          content: '正在生成语音...',
          metadata: {'fileType': 'audio', 'mimeType': 'audio/mpeg'},
        ));

        // 异步生成TTS并更新块
        _generateTtsBlock(
          blockId: audioBlockId,
          messageId: finalMessageId,
          provider: provider,
          text: aiContent,
        ).then((audioBlock) {
          _logger.info('TTS块生成完成', {'blockId': audioBlockId});
        }).catchError((e) {
          _logger.warning('TTS块生成失败', {
            'blockId': audioBlockId,
            'error': e.toString(),
          });
        });
      }

      // 6. 🚀 使用MessageFactory创建AI消息
      final blockMessage = _messageFactory.createAiMessage(
        conversationId: conversationId,
        assistantId: assistant.id,
        content: aiContent,
        modelId: modelName,
        metadata: {
          'modelName': modelName,
          'totalDurationMs':
              DateTime.now().difference(startTime).inMilliseconds,
          'messageId': finalMessageId, // 保持外部传入的ID
        },
      ).copyWith(
        id: finalMessageId, // 确保使用外部传入的ID
        blocks: blocks, // 使用我们创建的块
      );

      _logger.info('块化聊天请求完成', {
        'requestId': requestId,
        'messageId': finalMessageId,
        'duration': '${DateTime.now().difference(startTime).inMilliseconds}ms',
        'blocksCount': blocks.length,
        'textBlocks':
            blocks.where((b) => b.type == MessageBlockType.mainText).length,
        'imageBlocks':
            blocks.where((b) => b.type == MessageBlockType.image).length,
        'audioBlocks': blocks
            .where((b) =>
                b.type == MessageBlockType.file &&
                b.metadata?['fileType'] == 'audio')
            .length,
      });

      return blockMessage;
    } catch (e) {
      _logger.error('块化聊天请求失败', {
        'requestId': requestId,
        'messageId': finalMessageId,
        'error': e.toString(),
      });

      // 🚀 使用MessageFactory创建错误消息
      return _messageFactory.createErrorMessage(
        conversationId: conversationId,
        assistantId: assistant.id,
        errorMessage: '抱歉，处理您的请求时出现了错误。',
        metadata: {
          'modelName': modelName,
          'errorInfo': e.toString(),
          'exception': e.toString(),
          'messageId': finalMessageId, // 保持外部传入的ID
        },
      ).copyWith(id: finalMessageId); // 确保使用外部传入的ID
    }
  }

  /// 流式发送块化聊天消息
  Stream<Message> sendBlockMessageStream({
    required String messageId, // 🚀 阶段清理：必需的外部消息ID
    required String conversationId,
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
    bool autoGenerateImages = true,
    bool autoGenerateTts = true,
  }) async* {
    final requestId = _generateRequestId();
    final finalMessageId = messageId; // 🚀 直接使用外部传入的ID
    final startTime = DateTime.now();

    _logger.info('开始块化流式聊天请求', {
      'requestId': requestId,
      'messageId': finalMessageId,
      'provider': provider.name,
      'model': modelName,
    });

    try {
      // 检测是否需要生成图片
      final shouldGenerateImage =
          autoGenerateImages && _detectImageGenerationIntent(userMessage);

      var accumulatedContent = '';
      final blocks = <MessageBlock>[];

      // 创建初始文本块
      final textBlockId = '${finalMessageId}_text';
      var textBlock = MessageBlock.text(
        id: textBlockId,
        messageId: finalMessageId,
        content: '',
        status: MessageBlockStatus.streaming,
        createdAt: DateTime.now(),
        modelId: assistant.id,
        modelName: modelName,
      );
      blocks.add(textBlock);

      // 🚀 使用MessageFactory创建流式消息
      var currentMessage = _messageFactory.createStreamingMessage(
        conversationId: conversationId,
        assistantId: assistant.id,
        modelId: modelName,
        metadata: {
          'modelName': modelName,
          'messageId': finalMessageId, // 保持外部传入的ID
        },
      ).copyWith(
        id: finalMessageId, // 确保使用外部传入的ID
        blocks: blocks, // 使用我们创建的块
      );

      yield currentMessage;

      // 发送流式聊天请求
      await for (final event in _serviceManager.sendMessageStream(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      )) {
        if (event.isContent) {
          final previousLength = accumulatedContent.length;
          accumulatedContent += event.contentDelta ?? '';

          // 🔍 调试日志：记录内容增量
          _logger.debug('块化服务接收内容增量', {
            'messageId': finalMessageId,
            'deltaLength': event.contentDelta?.length ?? 0,
            'deltaContent':
                event.contentDelta != null && event.contentDelta!.length > 30
                    ? '${event.contentDelta!.substring(0, 30)}...'
                    : event.contentDelta ?? '',
            'previousLength': previousLength,
            'newLength': accumulatedContent.length,
            'accumulatedEnding': accumulatedContent.length > 20
                ? '...${accumulatedContent.substring(accumulatedContent.length - 20)}'
                : accumulatedContent,
            'timestamp': DateTime.now().toIso8601String(),
          });

          // 更新文本块
          textBlock = textBlock.copyWith(
            content: accumulatedContent,
            updatedAt: DateTime.now(),
          );

          // 更新消息
          currentMessage = currentMessage.copyWith(
            blocks: [textBlock, ...blocks.skip(1)],
            updatedAt: DateTime.now(),
          );

          yield currentMessage;
        } else if (event.isCompleted) {
          // 🔍 调试日志：记录流式完成时的状态
          _logger.info('块化服务流式完成', {
            'messageId': finalMessageId,
            'finalContentLength': accumulatedContent.length,
            'finalContentPreview': accumulatedContent.length > 100
                ? '${accumulatedContent.substring(0, 100)}...'
                : accumulatedContent,
            'finalContentEnding': accumulatedContent.length > 50
                ? '...${accumulatedContent.substring(accumulatedContent.length - 50)}'
                : accumulatedContent,
            'duration': DateTime.now().difference(startTime).inMilliseconds,
            'timestamp': DateTime.now().toIso8601String(),
          });

          // 流式完成，更新文本块状态
          textBlock = textBlock.copyWith(
            status: MessageBlockStatus.success,
            updatedAt: DateTime.now(),
          );

          final finalBlocks = [textBlock];

          // 添加多媒体块（如果需要）
          if (shouldGenerateImage) {
            finalBlocks.add(MessageBlock(
              id: '${finalMessageId}_image',
              messageId: finalMessageId,
              type: MessageBlockType.image,
              status: MessageBlockStatus.pending,
              createdAt: DateTime.now(),
              content: '正在生成图片...',
            ));
          }

          if (autoGenerateTts &&
              _shouldGenerateTts(accumulatedContent, userMessage)) {
            finalBlocks.add(MessageBlock(
              id: '${finalMessageId}_audio',
              messageId: finalMessageId,
              type: MessageBlockType.file,
              status: MessageBlockStatus.pending,
              createdAt: DateTime.now(),
              content: '正在生成语音...',
              metadata: {'fileType': 'audio', 'mimeType': 'audio/mpeg'},
            ));
          }

          // 🔍 调试日志：记录最终消息状态
          _logger.debug('创建最终消息', {
            'messageId': finalMessageId,
            'finalBlocksCount': finalBlocks.length,
            'textBlockContentLength': textBlock.content?.length ?? 0,
            'textBlockContentEnding': textBlock.content != null &&
                    textBlock.content!.length > 30
                ? '...${textBlock.content!.substring(textBlock.content!.length - 30)}'
                : textBlock.content ?? '',
          });

          // 发送最终消息
          currentMessage = currentMessage.copyWith(
            status: MessageStatus.aiSuccess,
            blocks: finalBlocks,
            updatedAt: DateTime.now(),
            metadata: {
              ...?currentMessage.metadata,
              'totalDurationMs':
                  DateTime.now().difference(startTime).inMilliseconds,
            },
          );

          yield currentMessage;
        } else if (event.isError) {
          // 更新为错误状态
          textBlock = textBlock.copyWith(
            status: MessageBlockStatus.error,
            error: {'streamError': event.error},
            updatedAt: DateTime.now(),
          );

          currentMessage = currentMessage.copyWith(
            status: MessageStatus.aiError,
            blocks: [textBlock],
            updatedAt: DateTime.now(),
            metadata: {
              ...?currentMessage.metadata,
              'errorInfo': event.error,
            },
          );

          yield currentMessage;
        }
      }
    } catch (e) {
      _logger.error('块化流式聊天请求失败', {
        'requestId': requestId,
        'messageId': finalMessageId,
        'error': e.toString(),
      });

      // 🚀 使用MessageFactory创建错误消息
      yield _messageFactory.createErrorMessage(
        conversationId: conversationId,
        assistantId: assistant.id,
        errorMessage: '抱歉，处理您的请求时出现了错误。',
        metadata: {
          'modelName': modelName,
          'errorInfo': e.toString(),
          'exception': e.toString(),
          'messageId': finalMessageId, // 保持外部传入的ID
        },
      ).copyWith(id: finalMessageId); // 确保使用外部传入的ID
    }
  }

  // 私有辅助方法

  /// 检测用户消息中的图片生成意图
  bool _detectImageGenerationIntent(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    return _imageGenerationKeywords
        .any((keyword) => lowerMessage.contains(keyword.toLowerCase()));
  }

  /// 判断是否应该生成TTS
  bool _shouldGenerateTts(String aiResponse, String userMessage) {
    // 1. 用户明确请求语音
    final lowerUserMessage = userMessage.toLowerCase();
    if (_ttsRequestKeywords
        .any((keyword) => lowerUserMessage.contains(keyword.toLowerCase()))) {
      return true;
    }

    // 2. AI回复文本较长
    if (aiResponse.length > _ttsTextLengthThreshold) {
      return true;
    }

    // 3. 回复包含诗歌、故事等适合朗读的内容
    final lowerResponse = aiResponse.toLowerCase();
    final narrativeKeywords = [
      '故事',
      '诗歌',
      '诗',
      '童话',
      '小说',
      'story',
      'poem',
      'tale'
    ];
    if (narrativeKeywords
        .any((keyword) => lowerResponse.contains(keyword.toLowerCase()))) {
      return true;
    }

    return false;
  }

  /// 异步生成图片块
  Future<MessageBlock> _generateImageBlock({
    required String blockId,
    required String messageId,
    required models.AiProvider provider,
    required String aiResponse,
    required String userPrompt,
  }) async {
    try {
      // 检查提供商是否支持图片生成
      final imageService = _serviceManager.imageGenerationService;
      if (!imageService.supportsImageGeneration(provider)) {
        return MessageBlock.error(
          id: blockId,
          messageId: messageId,
          content: '当前提供商不支持图片生成',
          error: {'reason': 'provider_not_supported'},
        );
      }

      // 提取或生成图片描述
      final imagePrompt = _extractImagePrompt(userPrompt, aiResponse);
      if (imagePrompt.isEmpty) {
        return MessageBlock.error(
          id: blockId,
          messageId: messageId,
          content: '无法提取图片描述',
          error: {'reason': 'no_image_prompt'},
        );
      }

      // 生成图片
      final imageResponse = await imageService.generateImage(
        provider: provider,
        prompt: imagePrompt,
        size: '1024x1024',
        quality: 'standard',
        count: 1,
      );

      if (!imageResponse.isSuccess || imageResponse.images.isEmpty) {
        return MessageBlock.error(
          id: blockId,
          messageId: messageId,
          content: '图片生成失败: ${imageResponse.error}',
          error: {
            'reason': 'generation_failed',
            'details': imageResponse.error
          },
        );
      }

      final generatedImage = imageResponse.images.first;

      // 创建成功的图片块
      return MessageBlock.image(
        id: blockId,
        messageId: messageId,
        url: generatedImage.url!,
        status: MessageBlockStatus.success,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return MessageBlock.error(
        id: blockId,
        messageId: messageId,
        content: '图片生成异常: $e',
        error: {'reason': 'exception', 'details': e.toString()},
      );
    }
  }

  /// 异步生成TTS块
  Future<MessageBlock> _generateTtsBlock({
    required String blockId,
    required String messageId,
    required models.AiProvider provider,
    required String text,
  }) async {
    try {
      // 检查提供商是否支持TTS
      final speechService = _serviceManager.speechService;
      if (!speechService.supportsTts(provider)) {
        return MessageBlock.error(
          id: blockId,
          messageId: messageId,
          content: '当前提供商不支持语音合成',
          error: {'reason': 'provider_not_supported'},
        );
      }

      // 生成TTS
      final audioData = await speechService.textToSpeech(
        provider: provider,
        text: text,
        voice: null, // 使用默认语音
      );

      // 存储音频文件
      final audioMetadata = await _mediaService.storeMedia(
        data: audioData,
        fileName: 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
        mimeType: 'audio/mpeg',
        customProperties: {
          'type': 'tts',
          'provider': provider.name,
          'text_length': text.length,
        },
      );

      // 创建成功的音频块
      return MessageBlock(
        id: blockId,
        messageId: messageId,
        type: MessageBlockType.file,
        status: MessageBlockStatus.success,
        createdAt: DateTime.now(),
        url: audioMetadata.networkUrl ?? audioMetadata.localPath,
        fileId: audioMetadata.id,
        metadata: {
          'fileName': audioMetadata.fileName,
          'mimeType': audioMetadata.mimeType,
          'sizeBytes': audioMetadata.sizeBytes,
          'fileType': 'audio',
        },
      );
    } catch (e) {
      return MessageBlock.error(
        id: blockId,
        messageId: messageId,
        content: 'TTS生成异常: $e',
        error: {'reason': 'exception', 'details': e.toString()},
      );
    }
  }

  /// 提取图片提示词
  String _extractImagePrompt(String userPrompt, String aiResponse) {
    // 简单的提示词提取逻辑
    // 在实际应用中，这里可能需要更复杂的NLP处理
    final lowerUserPrompt = userPrompt.toLowerCase();

    // 如果用户消息包含图片生成关键词，使用用户消息
    if (_imageGenerationKeywords
        .any((keyword) => lowerUserPrompt.contains(keyword.toLowerCase()))) {
      return userPrompt;
    }

    // 否则尝试从AI回复中提取描述
    if (aiResponse.length > 50) {
      return aiResponse.substring(0, 200); // 取前200字符作为提示词
    }

    return userPrompt;
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // 🚀 阶段清理：移除老式的消息ID生成方法
  // 现在所有消息ID都通过MessageIdService统一生成并从外部传入
}
