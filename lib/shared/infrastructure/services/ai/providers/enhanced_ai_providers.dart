import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/settings/presentation/providers/multimedia_settings_notifier.dart';
import '../capabilities/image_generation_service.dart';
import '../capabilities/web_search_service.dart';
import '../capabilities/multimodal_service.dart';
import '../capabilities/enhanced_chat_configuration_service.dart';
import '../../logger_service.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';

/// 增强AI功能Providers
///
/// 提供所有多媒体AI功能的Provider，遵循Riverpod最佳实践：
/// - 使用autoDispose防止内存泄漏
/// - 完整的参数验证和错误处理
/// - 统一的日志记录
/// - 类型安全的参数定义

// === 图像生成相关 ===

/// 图像生成参数
class ImageGenerationParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String prompt;
  final String? size;
  final String? quality;
  final String? style;
  final int count;

  const ImageGenerationParams({
    required this.provider,
    required this.assistant,
    required this.prompt,
    this.size,
    this.quality,
    this.style,
    this.count = 1,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageGenerationParams &&
        other.provider == provider &&
        other.assistant == assistant &&
        other.prompt == prompt &&
        other.size == size &&
        other.quality == quality &&
        other.style == style &&
        other.count == count;
  }

  @override
  int get hashCode {
    return Object.hash(provider, assistant, prompt, size, quality, style, count);
  }
}

/// 图像生成响应
class ImageGenerationResponse {
  final List<String> imageUrls;
  final String? revisedPrompt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const ImageGenerationResponse({
    required this.imageUrls,
    this.revisedPrompt,
    this.metadata,
    required this.createdAt,
  });
}

/// 图像生成Provider - 遵循最佳实践
final generateImageProvider = FutureProvider.autoDispose.family<
    ImageGenerationResponse, ImageGenerationParams>((ref, params) async {
  final logger = LoggerService();
  
  try {
    // 1. 检查多媒体功能是否启用
    final multimediaSettings = ref.read(multimediaSettingsProvider);
    if (!multimediaSettings.isEnabled || !multimediaSettings.imageGenerationEnabled) {
      throw UnsupportedError('图像生成功能未启用');
    }

    // 2. 参数验证
    if (params.prompt.trim().isEmpty) {
      throw ArgumentError('图像生成提示词不能为空');
    }

    if (params.prompt.length > 1000) {
      throw ArgumentError('提示词过长，最多1000字符');
    }

    if (params.count <= 0 || params.count > 4) {
      throw ArgumentError('图像数量必须在1-4之间');
    }

    // 3. 服务支持检查
    final imageService = ref.read(imageGenerationServiceProvider);
    if (!imageService.supportsImageGeneration(params.provider)) {
      throw UnsupportedError('提供商 ${params.provider.name} 不支持图像生成');
    }

    // 4. 尺寸验证
    if (params.size != null) {
      final supportedSizes = imageService.getSupportedSizes(params.provider);
      if (!supportedSizes.contains(params.size)) {
        throw ArgumentError('不支持的图像尺寸: ${params.size}');
      }
    }

    logger.info('开始图像生成', {
      'provider': params.provider.name,
      'assistant': params.assistant.name,
      'promptLength': params.prompt.length,
      'count': params.count,
      'size': params.size,
    });

    // 5. 执行图像生成
    final response = await imageService.generateImage(
      provider: params.provider,
      prompt: params.prompt,
      size: params.size,
      quality: params.quality,
      style: params.style,
      count: params.count,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? '图像生成失败');
    }

    logger.info('图像生成成功', {
      'imageCount': response.images.length,
    });

    return ImageGenerationResponse(
      imageUrls: response.images.map((img) => img.url ?? '').where((url) => url.isNotEmpty).toList(),
      revisedPrompt: response.images.isNotEmpty ? response.images.first.revisedPrompt : null,
      createdAt: DateTime.now(),
    );
  } catch (error) {
    logger.error('图像生成失败', {
      'provider': params.provider.name,
      'error': error.toString(),
    });
    rethrow;
  }
});

// === Web搜索相关 ===

/// Web搜索参数
class WebSearchParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String query;
  final int maxResults;
  final String? language;
  final List<String>? allowedDomains;
  final List<String>? blockedDomains;

  const WebSearchParams({
    required this.provider,
    required this.assistant,
    required this.query,
    this.maxResults = 10,
    this.language,
    this.allowedDomains,
    this.blockedDomains,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebSearchParams &&
        other.provider == provider &&
        other.assistant == assistant &&
        other.query == query &&
        other.maxResults == maxResults &&
        other.language == language &&
        _listEquals(other.allowedDomains, allowedDomains) &&
        _listEquals(other.blockedDomains, blockedDomains);
  }

  @override
  int get hashCode {
    return Object.hash(
      provider,
      assistant,
      query,
      maxResults,
      language,
      allowedDomains,
      blockedDomains,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Web搜索响应
class WebSearchResponse {
  final List<SearchResult> results;
  final String? query;
  final int totalResults;
  final DateTime searchTime;

  const WebSearchResponse({
    required this.results,
    this.query,
    required this.totalResults,
    required this.searchTime,
  });
}

/// 搜索结果
class SearchResult {
  final String title;
  final String url;
  final String snippet;
  final DateTime? publishedDate;
  final String? source;

  const SearchResult({
    required this.title,
    required this.url,
    required this.snippet,
    this.publishedDate,
    this.source,
  });
}

/// Web搜索Provider
final webSearchProvider = FutureProvider.autoDispose.family<
    WebSearchResponse, WebSearchParams>((ref, params) async {
  final logger = LoggerService();
  
  try {
    // 1. 检查多媒体功能是否启用
    final multimediaSettings = ref.read(multimediaSettingsProvider);
    if (!multimediaSettings.isEnabled || !multimediaSettings.webSearchEnabled) {
      throw UnsupportedError('Web搜索功能未启用');
    }

    // 2. 查询验证
    final query = params.query.trim();
    if (query.isEmpty) {
      throw ArgumentError('搜索查询不能为空');
    }

    if (query.length > 500) {
      throw ArgumentError('搜索查询过长，最多500字符');
    }

    // 3. 搜索权限检查
    final webSearchService = ref.read(webSearchServiceProvider);
    if (!webSearchService.supportsWebSearch(params.provider)) {
      throw UnsupportedError('提供商 ${params.provider.name} 不支持Web搜索');
    }

    // 4. 结果数量限制
    final maxResults = params.maxResults.clamp(1, 20); // 限制在1-20之间

    logger.info('开始Web搜索', {
      'provider': params.provider.name,
      'query': query,
      'maxResults': maxResults,
      'language': params.language,
    });

    // 5. 创建默认助手
    final defaultAssistant = AiAssistant(
      id: 'web-search-assistant',
      name: 'Web Search Assistant',
      avatar: '🔍',
      systemPrompt: 'You are a helpful assistant that can search the web for information.',
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 2048,
      contextLength: 5,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Assistant for web search tasks',
      customHeaders: {},
      customBody: {},
      stopSequences: [],
      frequencyPenalty: 0.0,
      presencePenalty: 0.0,
      enableCodeExecution: false,
      enableImageGeneration: false,
      enableTools: true,
      enableReasoning: false,
      enableVision: false,
      enableEmbedding: false,
    );

    // 6. 执行搜索
    final response = await webSearchService.searchWeb(
      provider: params.provider,
      assistant: defaultAssistant,
      query: query,
      maxResults: maxResults,
      language: params.language,
      allowedDomains: params.allowedDomains,
      blockedDomains: params.blockedDomains,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'Web搜索失败');
    }

    logger.info('Web搜索成功', {
      'resultCount': response.results.length,
    });

    return WebSearchResponse(
      results: response.results.map((result) => SearchResult(
        title: result.title,
        url: result.url,
        snippet: result.snippet,
        publishedDate: result.publishDate,
        source: Uri.tryParse(result.url)?.host,
      )).toList(),
      query: response.query,
      totalResults: response.results.length,
      searchTime: DateTime.now(),
    );
  } catch (error) {
    logger.error('Web搜索失败', {
      'provider': params.provider.name,
      'query': params.query,
      'error': error.toString(),
    });
    rethrow;
  }
});

// === 语音处理相关 ===

/// TTS参数
class TextToSpeechParams {
  final models.AiProvider provider;
  final String text;
  final String? voice;
  final String? model;
  final double? speed;
  final String? format;

  const TextToSpeechParams({
    required this.provider,
    required this.text,
    this.voice,
    this.model,
    this.speed,
    this.format,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextToSpeechParams &&
        other.provider == provider &&
        other.text == text &&
        other.voice == voice &&
        other.model == model &&
        other.speed == speed &&
        other.format == format;
  }

  @override
  int get hashCode {
    return Object.hash(provider, text, voice, model, speed, format);
  }
}

/// TTS响应
class TtsResponse {
  final List<int> audioData;
  final String format;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const TtsResponse({
    required this.audioData,
    required this.format,
    this.duration,
    this.metadata,
  });
}

/// TTS Provider
final textToSpeechProvider = FutureProvider.autoDispose.family<
    TtsResponse, TextToSpeechParams>((ref, params) async {
  final logger = LoggerService();

  try {
    // 1. 检查多媒体功能是否启用
    final multimediaSettings = ref.read(multimediaSettingsProvider);
    if (!multimediaSettings.isEnabled || !multimediaSettings.ttsEnabled) {
      throw UnsupportedError('TTS功能未启用');
    }

    // 2. 文本验证
    final text = params.text.trim();
    if (text.isEmpty) {
      throw ArgumentError('TTS文本不能为空');
    }

    if (text.length > 4000) {
      throw ArgumentError('TTS文本过长，最多4000字符');
    }

    // 3. 检查提供商是否支持TTS（简化检查）
    final supportedProviders = ['openai'];
    if (!supportedProviders.contains(params.provider.type.id)) {
      throw UnsupportedError('提供商 ${params.provider.name} 不支持TTS');
    }

    logger.info('开始TTS转换', {
      'provider': params.provider.name,
      'textLength': text.length,
      'voice': params.voice,
      'model': params.model,
    });

    // 4. 执行TTS
    final multimodalService = ref.read(multimodalServiceProvider);
    final response = await multimodalService.textToSpeech(
      provider: params.provider,
      text: text,
      voice: params.voice,
      model: params.model,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'TTS转换失败');
    }

    logger.info('TTS转换成功', {
      'audioSize': response.audioData.length,
      'duration': response.duration.inSeconds,
    });

    return TtsResponse(
      audioData: response.audioData.toList(),
      format: 'mp3', // 默认格式
      duration: response.duration,
    );
  } catch (error) {
    logger.error('TTS转换失败', {
      'provider': params.provider.name,
      'error': error.toString(),
    });
    rethrow;
  }
});

/// STT参数
class SpeechToTextParams {
  final models.AiProvider provider;
  final List<int> audioData;
  final String? language;
  final String? model;
  final String? format;

  const SpeechToTextParams({
    required this.provider,
    required this.audioData,
    this.language,
    this.model,
    this.format,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeechToTextParams &&
        other.provider == provider &&
        _listEquals(other.audioData, audioData) &&
        other.language == language &&
        other.model == model &&
        other.format == format;
  }

  @override
  int get hashCode {
    return Object.hash(provider, audioData, language, model, format);
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// STT响应
class SttResponse {
  final String text;
  final double? confidence;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const SttResponse({
    required this.text,
    this.confidence,
    this.duration,
    this.metadata,
  });
}

/// STT Provider
final speechToTextProvider = FutureProvider.autoDispose.family<
    SttResponse, SpeechToTextParams>((ref, params) async {
  final logger = LoggerService();

  try {
    // 1. 检查多媒体功能是否启用
    final multimediaSettings = ref.read(multimediaSettingsProvider);
    if (!multimediaSettings.isEnabled || !multimediaSettings.sttEnabled) {
      throw UnsupportedError('STT功能未启用');
    }

    // 2. 音频数据验证
    if (params.audioData.isEmpty) {
      throw ArgumentError('音频数据不能为空');
    }

    // 音频大小限制 (25MB)
    if (params.audioData.length > 25 * 1024 * 1024) {
      throw ArgumentError('音频文件过大，最大25MB');
    }

    // 3. 检查提供商是否支持STT（简化检查）
    final supportedProviders = ['openai'];
    if (!supportedProviders.contains(params.provider.type.id)) {
      throw UnsupportedError('提供商 ${params.provider.name} 不支持STT');
    }

    logger.info('开始STT转换', {
      'provider': params.provider.name,
      'audioSize': params.audioData.length,
      'language': params.language,
      'model': params.model,
    });

    // 4. 执行STT
    final multimodalService = ref.read(multimodalServiceProvider);
    final response = await multimodalService.speechToText(
      provider: params.provider,
      audioData: Uint8List.fromList(params.audioData),
      language: params.language,
      model: params.model,
    );

    if (!response.isSuccess) {
      throw Exception(response.error ?? 'STT转换失败');
    }

    logger.info('STT转换成功', {
      'textLength': response.text.length,
    });

    return SttResponse(
      text: response.text,
      duration: response.duration,
    );
  } catch (error) {
    logger.error('STT转换失败', {
      'provider': params.provider.name,
      'error': error.toString(),
    });
    rethrow;
  }
});

// === 服务Provider ===

/// 图像生成服务Provider
final imageGenerationServiceProvider = Provider<ImageGenerationService>((ref) {
  return ImageGenerationService();
});

/// Web搜索服务Provider
final webSearchServiceProvider = Provider<WebSearchService>((ref) {
  return WebSearchService();
});

/// 多模态服务Provider
final multimodalServiceProvider = Provider<MultimodalService>((ref) {
  return MultimodalService();
});

/// 增强聊天配置服务Provider
final enhancedChatConfigurationServiceProvider = Provider<EnhancedChatConfigurationService>((ref) {
  return EnhancedChatConfigurationService();
});
