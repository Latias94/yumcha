import 'dart:typed_data';
import '../../../../features/chat/domain/entities/message.dart';
import '../../../../features/chat/domain/entities/enhanced_message.dart';
import '../../../../features/chat/domain/entities/legacy_message.dart';
import '../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../media/media_storage_service.dart';
import 'ai_service_manager.dart';
import '../logger_service.dart';

/// 增强聊天服务 - 集成多媒体功能的AI聊天服务
///
/// ⚠️ **已弃用 (DEPRECATED)** ⚠️
///
/// 这个服务已被 `BlockBasedChatService` 替代，请使用新的块化消息系统。
/// 新系统提供了更好的架构和更强大的功能：
///
/// - 🧩 **块化消息架构** - 更灵活的内容组织
/// - 🎨 **多媒体块支持** - 独立的多媒体内容管理
/// - 🔄 **流式块更新** - 更好的实时体验
/// - 📊 **精细化状态管理** - 每个块独立的状态跟踪
///
/// ## 迁移指南
///
/// 请参考 `docs/enhanced_to_block_migration_guide.md` 了解如何迁移到新系统。
///
/// ### 替代方案
/// - 使用 `BlockBasedChatService` 替代此服务
/// - 使用 `blockChatProvider` 替代 `enhancedChatProvider`
/// - 使用 `Message` 和 `MessageBlock` 替代 `EnhancedMessage`
///
/// ## 原有功能（已迁移到新系统）
///
/// ### 1. 智能内容检测 ➜ 块化内容识别
/// - 检测用户请求中的图片生成意图
/// - 识别需要TTS的文本内容
/// - 分析上传的图片内容
///
/// ### 2. 自动多媒体生成 ➜ 多媒体块生成
/// - AI回复包含图片时自动生成
/// - 长文本自动生成TTS音频
/// - 多媒体内容智能存储
///
/// ### 3. 增强消息处理 ➜ 块化消息处理
/// - 创建包含多媒体的块化消息
/// - 自动管理多媒体文件生命周期
/// - 支持多媒体内容的导入导出
///
/// @deprecated 使用 BlockBasedChatService 替代
@Deprecated('使用 BlockBasedChatService 替代。参考 docs/enhanced_to_block_migration_guide.md')
class EnhancedChatService {
  final AiServiceManager _serviceManager;
  final MediaStorageService _mediaService;
  final LoggerService _logger = LoggerService();

  // 图片生成关键词检测
  static const List<String> _imageGenerationKeywords = [
    '画', '绘制', '生成图片', '创建图像', '制作图片', '设计图片',
    '画一张', '画个', '画出', '生成一张', '创作图片', '制作海报',
    'draw', 'paint', 'create image', 'generate image', 'make picture',
    'design', 'illustrate', 'sketch', 'render'
  ];

  // TTS生成阈值和关键词
  static const int _ttsTextLengthThreshold = 100; // 超过100字符自动生成TTS
  static const List<String> _ttsRequestKeywords = [
    '读出来', '朗读', '语音播放', '念给我听', '用语音说',
    'read aloud', 'speak', 'voice', 'audio', 'tts'
  ];

  EnhancedChatService({
    required AiServiceManager serviceManager,
    required MediaStorageService mediaService,
  }) : _serviceManager = serviceManager,
       _mediaService = mediaService;

  /// 发送增强聊天消息（支持多媒体生成）
  Future<EnhancedMessage> sendEnhancedMessage({
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

    _logger.info('开始增强聊天请求', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'autoGenerateImages': autoGenerateImages,
      'autoGenerateTts': autoGenerateTts,
    });

    try {
      // 1. 检测用户消息中的图片生成请求
      final shouldGenerateImage = autoGenerateImages && 
          _detectImageGenerationIntent(userMessage);

      // 2. 发送基础聊天请求
      final chatResponse = await _serviceManager.sendMessage(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      );

      if (!chatResponse.isSuccess) {
        // 如果聊天失败，返回错误消息
        return EnhancedMessage(
          author: assistant.name,
          content: chatResponse.error ?? '聊天请求失败',
          timestamp: DateTime.now(),
          isFromUser: false,
          status: LegacyMessageStatus.error,
          errorInfo: chatResponse.error,
        );
      }

      final aiContent = chatResponse.content;
      final mediaFiles = <MediaMetadata>[];

      // 3. 处理图片生成
      if (shouldGenerateImage) {
        try {
          final imageMetadata = await _generateImageFromResponse(
            provider: provider,
            aiResponse: aiContent,
            userPrompt: userMessage,
          );
          if (imageMetadata != null) {
            mediaFiles.add(imageMetadata);
          }
        } catch (e) {
          _logger.warning('图片生成失败', {
            'requestId': requestId,
            'error': e.toString(),
          });
        }
      }

      // 4. 处理TTS生成
      if (autoGenerateTts && _shouldGenerateTts(aiContent, userMessage)) {
        try {
          final audioMetadata = await _generateTtsFromResponse(
            provider: provider,
            text: aiContent,
            voice: null, // 使用默认语音
          );
          if (audioMetadata != null) {
            mediaFiles.add(audioMetadata);
          }
        } catch (e) {
          _logger.warning('TTS生成失败', {
            'requestId': requestId,
            'error': e.toString(),
          });
        }
      }

      // 5. 创建增强消息
      final enhancedMessage = EnhancedMessage.withMedia(
        author: assistant.name,
        content: aiContent,
        timestamp: DateTime.now(),
        isFromUser: false,
        duration: DateTime.now().difference(startTime),
        mediaFiles: mediaFiles,
      );

      _logger.info('增强聊天请求完成', {
        'requestId': requestId,
        'duration': '${DateTime.now().difference(startTime).inMilliseconds}ms',
        'mediaFilesCount': mediaFiles.length,
        'hasImages': enhancedMessage.hasImages,
        'hasAudio': enhancedMessage.hasAudio,
      });

      return enhancedMessage;

    } catch (e) {
      _logger.error('增强聊天请求失败', {
        'requestId': requestId,
        'error': e.toString(),
      });

      return EnhancedMessage(
        author: assistant.name,
        content: '抱歉，处理您的请求时出现了错误。',
        timestamp: DateTime.now(),
        isFromUser: false,
        status: LegacyMessageStatus.error,
        errorInfo: e.toString(),
      );
    }
  }

  /// 流式发送增强聊天消息
  Stream<EnhancedMessage> sendEnhancedMessageStream({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
    bool autoGenerateImages = true,
    bool autoGenerateTts = true,
  }) async* {
    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    _logger.info('开始增强流式聊天请求', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
    });

    try {
      // 检测是否需要生成图片
      final shouldGenerateImage = autoGenerateImages && 
          _detectImageGenerationIntent(userMessage);

      var accumulatedContent = '';
      var finalMessage = EnhancedMessage(
        author: assistant.name,
        content: '',
        timestamp: DateTime.now(),
        isFromUser: false,
        status: LegacyMessageStatus.streaming,
      );

      // 发送流式聊天请求
      await for (final event in _serviceManager.sendMessageStream(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      )) {
        if (event.isContent) {
          accumulatedContent += event.contentDelta ?? '';
          finalMessage = finalMessage.copyWith(
            content: accumulatedContent,
          );
          yield finalMessage;
        } else if (event.isCompleted) {
          // 流式完成，开始处理多媒体内容
          final mediaFiles = <MediaMetadata>[];

          // 处理图片生成
          if (shouldGenerateImage) {
            try {
              final imageMetadata = await _generateImageFromResponse(
                provider: provider,
                aiResponse: accumulatedContent,
                userPrompt: userMessage,
              );
              if (imageMetadata != null) {
                mediaFiles.add(imageMetadata);
              }
            } catch (e) {
              _logger.warning('流式聊天图片生成失败', {
                'requestId': requestId,
                'error': e.toString(),
              });
            }
          }

          // 处理TTS生成
          if (autoGenerateTts && _shouldGenerateTts(accumulatedContent, userMessage)) {
            try {
              final audioMetadata = await _generateTtsFromResponse(
                provider: provider,
                text: accumulatedContent,
                voice: null, // 使用默认语音
              );
              if (audioMetadata != null) {
                mediaFiles.add(audioMetadata);
              }
            } catch (e) {
              _logger.warning('流式聊天TTS生成失败', {
                'requestId': requestId,
                'error': e.toString(),
              });
            }
          }

          // 发送最终的增强消息
          finalMessage = finalMessage.copyWith(
            status: LegacyMessageStatus.normal,
            mediaFiles: mediaFiles,
            duration: DateTime.now().difference(startTime),
          );

          yield finalMessage;
        } else if (event.isError) {
          yield finalMessage.copyWith(
            status: LegacyMessageStatus.error,
            errorInfo: event.error,
          );
        }
      }

    } catch (e) {
      _logger.error('增强流式聊天请求失败', {
        'requestId': requestId,
        'error': e.toString(),
      });

      yield EnhancedMessage(
        author: assistant.name,
        content: '抱歉，处理您的请求时出现了错误。',
        timestamp: DateTime.now(),
        isFromUser: false,
        status: LegacyMessageStatus.error,
        errorInfo: e.toString(),
      );
    }
  }

  /// 分析图片内容
  Future<EnhancedMessage> analyzeImage({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required Uint8List imageData,
    required String prompt,
    String? fileName,
  }) async {
    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    _logger.info('开始图片分析', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'imageSize': imageData.length,
    });

    try {
      // 1. 存储用户上传的图片
      final imageMetadata = await _mediaService.storeMedia(
        data: imageData,
        fileName: fileName ?? 'user_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        mimeType: 'image/jpeg',
        customProperties: {
          'type': 'user_upload',
          'analysis_prompt': prompt,
        },
      );

      // 2. 使用多模态服务分析图片
      final analysisResponse = await _serviceManager.multimodalService.analyzeImage(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        imageData: imageData,
        prompt: prompt,
      );

      if (!analysisResponse.isSuccess) {
        return EnhancedMessage(
          author: assistant.name,
          content: '图片分析失败: ${analysisResponse.error}',
          timestamp: DateTime.now(),
          isFromUser: false,
          status: LegacyMessageStatus.error,
          errorInfo: analysisResponse.error,
          mediaFiles: [imageMetadata],
        );
      }

      // 3. 检查是否需要生成TTS
      final mediaFiles = [imageMetadata];
      if (_shouldGenerateTts(analysisResponse.content, prompt)) {
        try {
          final audioMetadata = await _generateTtsFromResponse(
            provider: provider,
            text: analysisResponse.content,
            voice: null, // 使用默认语音
          );
          if (audioMetadata != null) {
            mediaFiles.add(audioMetadata);
          }
        } catch (e) {
          _logger.warning('图片分析TTS生成失败', {
            'requestId': requestId,
            'error': e.toString(),
          });
        }
      }

      // 4. 创建增强消息
      final enhancedMessage = EnhancedMessage.withMedia(
        author: assistant.name,
        content: analysisResponse.content,
        timestamp: DateTime.now(),
        isFromUser: false,
        duration: DateTime.now().difference(startTime),
        mediaFiles: mediaFiles,
      );

      _logger.info('图片分析完成', {
        'requestId': requestId,
        'duration': '${DateTime.now().difference(startTime).inMilliseconds}ms',
        'responseLength': analysisResponse.content.length,
      });

      return enhancedMessage;

    } catch (e) {
      _logger.error('图片分析失败', {
        'requestId': requestId,
        'error': e.toString(),
      });

      return EnhancedMessage(
        author: assistant.name,
        content: '抱歉，图片分析时出现了错误。',
        timestamp: DateTime.now(),
        isFromUser: false,
        status: LegacyMessageStatus.error,
        errorInfo: e.toString(),
      );
    }
  }

  // 私有辅助方法

  /// 检测用户消息中的图片生成意图
  bool _detectImageGenerationIntent(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    return _imageGenerationKeywords.any((keyword) =>
        lowerMessage.contains(keyword.toLowerCase()));
  }

  /// 判断是否应该生成TTS
  bool _shouldGenerateTts(String aiResponse, String userMessage) {
    // 1. 用户明确请求语音
    final lowerUserMessage = userMessage.toLowerCase();
    if (_ttsRequestKeywords.any((keyword) =>
        lowerUserMessage.contains(keyword.toLowerCase()))) {
      return true;
    }

    // 2. AI回复文本较长
    if (aiResponse.length > _ttsTextLengthThreshold) {
      return true;
    }

    // 3. 回复包含诗歌、故事等适合朗读的内容
    final lowerResponse = aiResponse.toLowerCase();
    final narrativeKeywords = ['故事', '诗歌', '诗', '童话', '小说', 'story', 'poem', 'tale'];
    if (narrativeKeywords.any((keyword) =>
        lowerResponse.contains(keyword.toLowerCase()))) {
      return true;
    }

    return false;
  }

  /// 从AI回复生成图片
  Future<MediaMetadata?> _generateImageFromResponse({
    required models.AiProvider provider,
    required String aiResponse,
    required String userPrompt,
  }) async {
    try {
      // 检查提供商是否支持图片生成
      final imageService = _serviceManager.imageGenerationService;
      if (!imageService.supportsImageGeneration(provider)) {
        _logger.debug('提供商不支持图片生成', {'provider': provider.name});
        return null;
      }

      // 提取或生成图片描述
      final imagePrompt = _extractImagePrompt(userPrompt, aiResponse);
      if (imagePrompt.isEmpty) {
        return null;
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
        _logger.warning('图片生成失败', {
          'prompt': imagePrompt,
          'error': imageResponse.error,
        });
        return null;
      }

      final generatedImage = imageResponse.images.first;

      // 下载并存储图片
      if (generatedImage.url != null) {
        try {
          // 这里需要实际下载图片数据
          // 暂时使用模拟数据
          final imageData = Uint8List.fromList([]);

          return await _mediaService.storeMedia(
            data: imageData,
            fileName: 'ai_generated_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
            networkUrl: generatedImage.url,
            customProperties: {
              'type': 'ai_generated',
              'prompt': imagePrompt,
              'revised_prompt': generatedImage.revisedPrompt,
              'generation_time': DateTime.now().toIso8601String(),
            },
          );
        } catch (e) {
          _logger.error('存储AI生成图片失败', {'error': e.toString()});
          return null;
        }
      }

      return null;
    } catch (e) {
      _logger.error('生成图片失败', {'error': e.toString()});
      return null;
    }
  }

  /// 从AI回复生成TTS音频
  Future<MediaMetadata?> _generateTtsFromResponse({
    required models.AiProvider provider,
    required String text,
    String? voice,
  }) async {
    try {
      // 检查提供商是否支持TTS
      final multimodalService = _serviceManager.multimodalService;
      if (!_supportsTts(provider)) {
        _logger.debug('提供商不支持TTS', {'provider': provider.name});
        return null;
      }

      // 清理文本（移除markdown标记等）
      final cleanText = _cleanTextForTts(text);
      if (cleanText.isEmpty) {
        return null;
      }

      // 生成TTS音频
      final ttsResponse = await multimodalService.textToSpeech(
        provider: provider,
        text: cleanText,
        voice: voice ?? 'alloy',
      );

      if (!ttsResponse.isSuccess || ttsResponse.audioData.isEmpty) {
        _logger.warning('TTS生成失败', {
          'textLength': cleanText.length,
          'error': ttsResponse.error,
        });
        return null;
      }

      // 存储音频
      return await _mediaService.storeMedia(
        data: ttsResponse.audioData,
        fileName: 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
        mimeType: 'audio/mpeg',
        cacheExpiry: const Duration(days: 7),
        customProperties: {
          'type': 'tts_generated',
          'text_length': cleanText.length,
          'voice': voice ?? 'alloy',
          'generation_time': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.error('生成TTS失败', {'error': e.toString()});
      return null;
    }
  }

  /// 提取图片生成提示词
  String _extractImagePrompt(String userPrompt, String aiResponse) {
    // 1. 如果用户消息包含明确的图片描述，使用用户的描述
    final userLower = userPrompt.toLowerCase();
    for (final keyword in _imageGenerationKeywords) {
      if (userLower.contains(keyword.toLowerCase())) {
        // 提取关键词后的描述
        final index = userLower.indexOf(keyword.toLowerCase());
        if (index != -1) {
          final afterKeyword = userPrompt.substring(index + keyword.length).trim();
          if (afterKeyword.isNotEmpty) {
            return afterKeyword;
          }
        }
      }
    }

    // 2. 从AI回复中提取图片描述
    final lines = aiResponse.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.length > 20 && trimmed.length < 200) {
        // 简单的启发式：选择中等长度的描述性句子
        if (trimmed.contains('图片') || trimmed.contains('画面') ||
            trimmed.contains('场景') || trimmed.contains('image')) {
          return trimmed;
        }
      }
    }

    // 3. 使用用户原始提示作为后备
    return userPrompt.length > 200 ? userPrompt.substring(0, 200) : userPrompt;
  }

  /// 清理文本用于TTS
  String _cleanTextForTts(String text) {
    // 移除markdown标记
    var cleaned = text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // 粗体
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')     // 斜体
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')       // 代码
        .replaceAll(RegExp(r'#{1,6}\s*'), '')        // 标题
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // 链接
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '')  // 图片
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')   // 代码块
        .replaceAll(RegExp(r'`[^`]*`'), '');         // 行内代码

    // 移除多余的空白字符
    cleaned = cleaned
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 限制长度（TTS通常有字符限制）
    if (cleaned.length > 4000) {
      cleaned = cleaned.substring(0, 4000);
      // 尝试在句号处截断
      final lastPeriod = cleaned.lastIndexOf('。');
      if (lastPeriod > 3000) {
        cleaned = cleaned.substring(0, lastPeriod + 1);
      }
    }

    return cleaned;
  }

  /// 检查提供商是否支持TTS
  bool _supportsTts(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
      case 'elevenlabs':
        return true;
      default:
        return false;
    }
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'enhanced_chat_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }
}
