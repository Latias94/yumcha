import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../capabilities/enhanced_chat_configuration_service.dart';
import '../capabilities/image_generation_service.dart';
import '../capabilities/web_search_service.dart';
import '../capabilities/multimodal_service.dart';
import '../capabilities/speech_service.dart';
import '../capabilities/http_configuration_service.dart';
import '../core/ai_response_models.dart';
import '../../../../../core/utils/error_handler.dart';
import 'ai_service_provider.dart';

/// 增强AI功能的Riverpod Providers
///
/// 这个文件提供了所有增强AI功能的Riverpod Provider，
/// 遵循Riverpod最佳实践，支持：
/// - 🌐 HTTP代理配置
/// - 🔍 Web搜索功能
/// - 🎨 图像生成功能
/// - 🎵 语音处理功能
/// - 🖼️ 多模态分析功能
/// - ⚙️ 增强配置管理

// ============================================================================
// 核心服务Providers
// ============================================================================

/// 增强聊天配置服务Provider
final enhancedChatConfigurationServiceProvider = Provider<EnhancedChatConfigurationService>((ref) {
  return EnhancedChatConfigurationService();
});

/// HTTP配置服务Provider
final httpConfigurationServiceProvider = Provider<HttpConfigurationService>((ref) {
  return HttpConfigurationService();
});

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

// ============================================================================
// 增强配置管理Providers
// ============================================================================

/// 创建增强聊天配置Provider - 遵循Riverpod最佳实践
final createEnhancedConfigProvider = FutureProvider.autoDispose.family<EnhancedChatConfig, EnhancedConfigParams>((
  ref,
  params,
) async {
  // 1. 基础参数验证
  if (params.modelName.trim().isEmpty) {
    throw ArgumentError('模型名称不能为空');
  }

  // 2. HTTP配置验证
  if (params.proxyUrl != null) {
    final uri = Uri.tryParse(params.proxyUrl!);
    if (uri == null || !uri.scheme.startsWith('http')) {
      throw ArgumentError('无效的代理URL格式');
    }
  }

  // 3. 超时配置验证
  if (params.connectionTimeout != null) {
    if (params.connectionTimeout!.inSeconds < 1 || params.connectionTimeout!.inSeconds > 300) {
      throw ArgumentError('连接超时时间必须在1-300秒之间');
    }
  }

  if (params.receiveTimeout != null) {
    if (params.receiveTimeout!.inSeconds < 1 || params.receiveTimeout!.inSeconds > 600) {
      throw ArgumentError('接收超时时间必须在1-600秒之间');
    }
  }

  // 4. 功能支持检查
  if (params.enableWebSearch) {
    final webSearchService = ref.read(webSearchServiceProvider);
    if (!webSearchService.supportsWebSearch(params.provider)) {
      throw UnsupportedError('提供商不支持Web搜索功能');
    }
  }

  if (params.enableImageGeneration) {
    final imageService = ref.read(imageGenerationServiceProvider);
    if (!imageService.supportsImageGeneration(params.provider)) {
      throw UnsupportedError('提供商不支持图像生成功能');
    }
  }

  // 5. 搜索配置验证
  if (params.maxSearchResults != null) {
    if (params.maxSearchResults! < 1 || params.maxSearchResults! > 50) {
      throw ArgumentError('搜索结果数量必须在1-50之间');
    }
  }

  try {
    // 6. 创建配置
    final configService = ref.read(enhancedChatConfigurationServiceProvider);
    final config = await configService.createEnhancedConfig(
      provider: params.provider,
      assistant: params.assistant,
      modelName: params.modelName,
      proxyUrl: params.proxyUrl,
      connectionTimeout: params.connectionTimeout,
      receiveTimeout: params.receiveTimeout,
      customHeaders: params.customHeaders,
      enableHttpLogging: params.enableHttpLogging,
      enableWebSearch: params.enableWebSearch,
      enableImageGeneration: params.enableImageGeneration,
      enableTTS: params.enableTTS,
      enableSTT: params.enableSTT,
      maxSearchResults: params.maxSearchResults,
      allowedDomains: params.allowedDomains,
      searchLanguage: params.searchLanguage,
      imageSize: params.imageSize,
      imageQuality: params.imageQuality,
      ttsVoice: params.ttsVoice,
      sttLanguage: params.sttLanguage,
    );

    // 7. 配置验证
    if (!configService.validateEnhancedConfig(config)) {
      throw StateError('增强配置验证失败');
    }

    return config;
  } catch (e) {
    // 8. 错误处理
    if (e is ArgumentError || e is UnsupportedError || e is StateError) {
      rethrow;
    }

    throw ApiError(
      message: '创建增强配置失败: ${e.toString()}',
      code: 'CONFIG_CREATION_FAILED',
      originalError: e,
    );
  }
});

/// 验证增强配置Provider
final validateEnhancedConfigProvider = Provider.family<bool, EnhancedChatConfig>((ref, config) {
  final configService = ref.read(enhancedChatConfigurationServiceProvider);
  return configService.validateEnhancedConfig(config);
});

/// 获取配置统计信息Provider
final enhancedConfigStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final configService = ref.read(enhancedChatConfigurationServiceProvider);
  return configService.getConfigStats();
});

// ============================================================================
// HTTP配置功能Providers
// ============================================================================

/// 创建HTTP配置Provider
final createHttpConfigProvider = Provider.family<HttpConfig, HttpConfigParams>((ref, params) {
  final httpService = ref.read(httpConfigurationServiceProvider);
  
  return httpService.createHttpConfig(
    provider: params.provider,
    proxyUrl: params.proxyUrl,
    connectionTimeout: params.connectionTimeout,
    receiveTimeout: params.receiveTimeout,
    sendTimeout: params.sendTimeout,
    customHeaders: params.customHeaders,
    enableLogging: params.enableLogging,
    bypassSSLVerification: params.bypassSSLVerification,
    sslCertificatePath: params.sslCertificatePath,
  );
});

/// 验证HTTP配置Provider
final validateHttpConfigProvider = Provider.family<bool, HttpConfig>((ref, config) {
  final httpService = ref.read(httpConfigurationServiceProvider);
  return httpService.validateHttpConfig(config);
});

/// HTTP配置统计信息Provider
final httpConfigStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final httpService = ref.read(httpConfigurationServiceProvider);
  return httpService.getHttpConfigStats();
});

// ============================================================================
// 图像生成功能Providers
// ============================================================================

/// 图像生成Provider - 遵循Riverpod最佳实践
final generateImageProvider = FutureProvider.autoDispose.family<ImageGenerationResponse, ImageGenerationParams>((
  ref,
  params,
) async {
  // 1. 参数验证
  if (params.prompt.trim().isEmpty) {
    throw ArgumentError('图像生成提示词不能为空');
  }

  if (params.prompt.length > 4000) {
    throw ArgumentError('图像生成提示词过长，最多4000字符');
  }

  if (params.count <= 0 || params.count > 10) {
    throw ArgumentError('图像数量必须在1-10之间');
  }

  // 2. 服务可用性检查
  final imageService = ref.read(imageGenerationServiceProvider);
  if (!imageService.supportsImageGeneration(params.provider)) {
    throw UnsupportedError('提供商 ${params.provider.name} 不支持图像生成');
  }

  // 3. 尺寸验证
  final supportedSizes = imageService.getSupportedSizes(params.provider);
  if (params.size != null && !supportedSizes.contains(params.size)) {
    throw ArgumentError('不支持的图像尺寸: ${params.size}');
  }

  // 4. 质量验证
  final supportedQualities = imageService.getSupportedQualities(params.provider);
  if (params.quality != null && !supportedQualities.contains(params.quality)) {
    throw ArgumentError('不支持的图像质量: ${params.quality}');
  }

  try {
    // 5. 执行生成
    return await imageService.generateImage(
      provider: params.provider,
      prompt: params.prompt,
      size: params.size,
      quality: params.quality,
      style: params.style,
      count: params.count,
    );
  } catch (e) {
    // 6. 错误处理
    if (e.toString().contains('quota') || e.toString().contains('limit')) {
      throw ApiError(
        message: '图像生成配额已用完，请稍后再试',
        code: 'QUOTA_EXCEEDED',
        originalError: e,
      );
    } else if (e.toString().contains('content_policy')) {
      throw ValidationError(
        message: '图像内容违反内容政策，请修改提示词',
        code: 'CONTENT_POLICY_VIOLATION',
        originalError: e,
      );
    }
    rethrow;
  }
});

/// 检查图像生成支持Provider
final imageGenerationSupportProvider = Provider.family<bool, models.AiProvider>((ref, provider) {
  final imageService = ref.read(imageGenerationServiceProvider);
  return imageService.supportsImageGeneration(provider);
});

/// 获取支持的图像尺寸Provider
final supportedImageSizesProvider = Provider.family<List<String>, models.AiProvider>((ref, provider) {
  final imageService = ref.read(imageGenerationServiceProvider);
  return imageService.getSupportedSizes(provider);
});

/// 获取支持的图像质量Provider
final supportedImageQualitiesProvider = Provider.family<List<String>, models.AiProvider>((ref, provider) {
  final imageService = ref.read(imageGenerationServiceProvider);
  return imageService.getSupportedQualities(provider);
});

/// 图像生成统计信息Provider
final imageGenerationStatsProvider = Provider<Map<String, ImageGenerationStats>>((ref) {
  final imageService = ref.read(imageGenerationServiceProvider);
  return imageService.getImageGenerationStats();
});

// ============================================================================
// Web搜索功能Providers
// ============================================================================

/// Web搜索Provider - 遵循Riverpod最佳实践
final webSearchProvider = FutureProvider.autoDispose.family<WebSearchResponse, WebSearchParams>((
  ref,
  params,
) async {
  // 1. 查询验证
  final query = params.query.trim();
  if (query.isEmpty) {
    throw ArgumentError('搜索查询不能为空');
  }

  if (query.length > 500) {
    throw ArgumentError('搜索查询过长，最多500字符');
  }

  // 2. 搜索权限检查
  final webSearchService = ref.read(webSearchServiceProvider);
  if (!webSearchService.supportsWebSearch(params.provider)) {
    throw UnsupportedError('提供商 ${params.provider.name} 不支持Web搜索');
  }

  // 3. 结果数量限制
  final maxResults = params.maxResults.clamp(1, 20); // 限制在1-20之间

  // 4. 域名验证
  if (params.allowedDomains != null && params.allowedDomains!.isNotEmpty) {
    for (final domain in params.allowedDomains!) {
      if (!_isValidDomain(domain)) {
        throw ArgumentError('无效的允许域名格式: $domain');
      }
    }
  }

  if (params.blockedDomains != null && params.blockedDomains!.isNotEmpty) {
    for (final domain in params.blockedDomains!) {
      if (!_isValidDomain(domain)) {
        throw ArgumentError('无效的屏蔽域名格式: $domain');
      }
    }
  }

  try {
    // 5. 执行搜索
    return await webSearchService.searchWeb(
      provider: params.provider,
      assistant: params.assistant,
      query: query,
      maxResults: maxResults,
      language: params.language,
      allowedDomains: params.allowedDomains,
      blockedDomains: params.blockedDomains,
    );
  } catch (e) {
    // 6. 错误处理
    if (e.toString().contains('rate_limit') || e.toString().contains('too_many_requests')) {
      throw ApiError(
        message: '搜索请求过于频繁，请稍后再试',
        code: 'RATE_LIMIT_EXCEEDED',
        originalError: e,
      );
    } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
      throw ApiError(
        message: '搜索配额已用完，请稍后再试',
        code: 'QUOTA_EXCEEDED',
        originalError: e,
      );
    }
    rethrow;
  }
});

/// 新闻搜索Provider
final newsSearchProvider = FutureProvider.autoDispose.family<WebSearchResponse, NewsSearchParams>((
  ref,
  params,
) async {
  final webSearchService = ref.read(webSearchServiceProvider);

  return await webSearchService.searchNews(
    provider: params.provider,
    assistant: params.assistant,
    query: params.query,
    maxResults: params.maxResults,
    fromDate: params.fromDate,
    toDate: params.toDate,
  );
});

/// 检查Web搜索支持Provider
final webSearchSupportProvider = Provider.family<bool, models.AiProvider>((ref, provider) {
  final webSearchService = ref.read(webSearchServiceProvider);
  return webSearchService.supportsWebSearch(provider);
});

/// Web搜索统计信息Provider
final webSearchStatsProvider = Provider<Map<String, WebSearchStats>>((ref) {
  final webSearchService = ref.read(webSearchServiceProvider);
  return webSearchService.getWebSearchStats();
});

// ============================================================================
// 多模态功能Providers
// ============================================================================

/// 文字转语音Provider - 遵循Riverpod最佳实践
final textToSpeechProvider = FutureProvider.autoDispose.family<TextToSpeechResponse, TextToSpeechParams>((
  ref,
  params,
) async {
  // 1. 文本验证
  final text = params.text.trim();
  if (text.isEmpty) {
    throw ArgumentError('TTS文本不能为空');
  }

  if (text.length > 4000) {
    throw ArgumentError('TTS文本过长，最多4000字符');
  }

  // 2. 服务支持检查
  final speechService = ref.read(aiSpeechServiceProvider);
  if (!speechService.supportsTts(params.provider)) {
    throw UnsupportedError('提供商 ${params.provider.name} 不支持TTS');
  }

  // 3. 语音验证
  if (params.voice != null) {
    final supportedVoices = speechService.getSupportedVoices(params.provider);
    if (!supportedVoices.contains(params.voice)) {
      throw ArgumentError('不支持的语音: ${params.voice}');
    }
  }

  try {
    // 4. 执行TTS
    final multimodalService = ref.read(multimodalServiceProvider);
    return await multimodalService.textToSpeech(
      provider: params.provider,
      text: text,
      voice: params.voice,
      model: params.model,
    );
  } catch (e) {
    // 5. 错误处理
    if (e.toString().contains('quota') || e.toString().contains('limit')) {
      throw ApiError(
        message: 'TTS配额已用完，请稍后再试',
        code: 'QUOTA_EXCEEDED',
        originalError: e,
      );
    } else if (e.toString().contains('unsupported_voice')) {
      throw ValidationError(
        message: '不支持的语音类型',
        code: 'UNSUPPORTED_VOICE',
        originalError: e,
      );
    }
    rethrow;
  }
});

/// 语音转文字Provider - 遵循Riverpod最佳实践
final speechToTextProvider = FutureProvider.autoDispose.family<SpeechToTextResponse, SpeechToTextParams>((
  ref,
  params,
) async {
  // 1. 音频数据验证
  if (params.audioData.isEmpty) {
    throw ArgumentError('音频数据不能为空');
  }

  // 音频大小限制 (25MB)
  if (params.audioData.length > 25 * 1024 * 1024) {
    throw ArgumentError('音频文件过大，最大25MB');
  }

  // 2. 服务支持检查
  final multimodalService = ref.read(multimodalServiceProvider);
  // TODO: 添加STT支持检查方法
  // if (!multimodalService.supportsStt(params.provider)) {
  //   throw UnsupportedError('提供商 ${params.provider.name} 不支持STT');
  // }

  try {
    // 3. 执行STT
    return await multimodalService.speechToText(
      provider: params.provider,
      audioData: params.audioData,
      language: params.language,
      model: params.model,
    );
  } catch (e) {
    // 4. 错误处理
    if (e.toString().contains('quota') || e.toString().contains('limit')) {
      throw ApiError(
        message: 'STT配额已用完，请稍后再试',
        code: 'QUOTA_EXCEEDED',
        originalError: e,
      );
    } else if (e.toString().contains('unsupported_format')) {
      throw ValidationError(
        message: '不支持的音频格式',
        code: 'UNSUPPORTED_FORMAT',
        originalError: e,
      );
    } else if (e.toString().contains('file_too_large')) {
      throw ValidationError(
        message: '音频文件过大',
        code: 'FILE_TOO_LARGE',
        originalError: e,
      );
    }
    rethrow;
  }
});

/// 图像分析Provider - 遵循Riverpod最佳实践
final analyzeImageProvider = FutureProvider.autoDispose.family<AiResponse, ImageAnalysisParams>((
  ref,
  params,
) async {
  // 1. 图像数据验证
  if (params.imageData.isEmpty) {
    throw ArgumentError('图像数据不能为空');
  }

  // 图像大小限制 (20MB)
  if (params.imageData.length > 20 * 1024 * 1024) {
    throw ArgumentError('图像文件过大，最大20MB');
  }

  // 2. 提示词验证
  final prompt = params.prompt.trim();
  if (prompt.isEmpty) {
    throw ArgumentError('图像分析提示词不能为空');
  }

  if (prompt.length > 2000) {
    throw ArgumentError('图像分析提示词过长，最多2000字符');
  }

  // 3. 图像格式验证
  final supportedFormats = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
  final format = params.imageFormat?.toLowerCase() ?? 'png';
  if (!supportedFormats.contains(format)) {
    throw ArgumentError('不支持的图像格式: $format');
  }

  // 4. 服务支持检查
  final multimodalService = ref.read(multimodalServiceProvider);
  // TODO: 添加视觉分析支持检查方法
  // if (!multimodalService.supportsVision(params.provider)) {
  //   throw UnsupportedError('提供商 ${params.provider.name} 不支持图像分析');
  // }

  try {
    // 5. 执行图像分析
    return await multimodalService.analyzeImage(
      provider: params.provider,
      assistant: params.assistant,
      modelName: params.modelName,
      imageData: params.imageData,
      prompt: prompt,
      imageFormat: format,
    );
  } catch (e) {
    // 6. 错误处理
    if (e.toString().contains('quota') || e.toString().contains('limit')) {
      throw ApiError(
        message: '图像分析配额已用完，请稍后再试',
        code: 'QUOTA_EXCEEDED',
        originalError: e,
      );
    } else if (e.toString().contains('unsupported_format')) {
      throw ValidationError(
        message: '不支持的图像格式',
        code: 'UNSUPPORTED_FORMAT',
        originalError: e,
      );
    } else if (e.toString().contains('content_policy')) {
      throw ValidationError(
        message: '图像内容违反内容政策',
        code: 'CONTENT_POLICY_VIOLATION',
        originalError: e,
      );
    }
    rethrow;
  }
});

// ============================================================================
// 参数类定义
// ============================================================================

/// 增强配置参数类
class EnhancedConfigParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  
  // HTTP配置
  final String? proxyUrl;
  final Duration? connectionTimeout;
  final Duration? receiveTimeout;
  final Map<String, String>? customHeaders;
  final bool enableHttpLogging;
  
  // 功能开关
  final bool enableWebSearch;
  final bool enableImageGeneration;
  final bool enableTTS;
  final bool enableSTT;
  
  // 功能配置
  final int? maxSearchResults;
  final List<String>? allowedDomains;
  final String? searchLanguage;
  final String? imageSize;
  final String? imageQuality;
  final String? ttsVoice;
  final String? sttLanguage;

  const EnhancedConfigParams({
    required this.provider,
    required this.assistant,
    required this.modelName,
    this.proxyUrl,
    this.connectionTimeout,
    this.receiveTimeout,
    this.customHeaders,
    this.enableHttpLogging = false,
    this.enableWebSearch = false,
    this.enableImageGeneration = false,
    this.enableTTS = false,
    this.enableSTT = false,
    this.maxSearchResults,
    this.allowedDomains,
    this.searchLanguage,
    this.imageSize,
    this.imageQuality,
    this.ttsVoice,
    this.sttLanguage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedConfigParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          assistant.id == other.assistant.id &&
          modelName == other.modelName &&
          proxyUrl == other.proxyUrl &&
          enableWebSearch == other.enableWebSearch &&
          enableImageGeneration == other.enableImageGeneration;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      modelName.hashCode ^
      proxyUrl.hashCode ^
      enableWebSearch.hashCode ^
      enableImageGeneration.hashCode;
}

/// HTTP配置参数类
class HttpConfigParams {
  final models.AiProvider provider;
  final String? proxyUrl;
  final Duration? connectionTimeout;
  final Duration? receiveTimeout;
  final Duration? sendTimeout;
  final Map<String, String>? customHeaders;
  final bool enableLogging;
  final bool bypassSSLVerification;
  final String? sslCertificatePath;

  const HttpConfigParams({
    required this.provider,
    this.proxyUrl,
    this.connectionTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.customHeaders,
    this.enableLogging = false,
    this.bypassSSLVerification = false,
    this.sslCertificatePath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpConfigParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          proxyUrl == other.proxyUrl &&
          enableLogging == other.enableLogging;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      proxyUrl.hashCode ^
      enableLogging.hashCode;
}

/// 图像生成参数类
class ImageGenerationParams {
  final models.AiProvider provider;
  final String prompt;
  final String? size;
  final String? quality;
  final String? style;
  final int count;

  const ImageGenerationParams({
    required this.provider,
    required this.prompt,
    this.size = '1024x1024',
    this.quality = 'standard',
    this.style = 'natural',
    this.count = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          prompt == other.prompt &&
          size == other.size &&
          quality == other.quality &&
          count == other.count;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      prompt.hashCode ^
      size.hashCode ^
      quality.hashCode ^
      count.hashCode;
}

/// Web搜索参数类
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
    this.maxResults = 5,
    this.language,
    this.allowedDomains,
    this.blockedDomains,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          assistant.id == other.assistant.id &&
          query == other.query &&
          maxResults == other.maxResults;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      query.hashCode ^
      maxResults.hashCode;
}

/// 新闻搜索参数类
class NewsSearchParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String query;
  final int maxResults;
  final String? fromDate;
  final String? toDate;

  const NewsSearchParams({
    required this.provider,
    required this.assistant,
    required this.query,
    this.maxResults = 5,
    this.fromDate,
    this.toDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsSearchParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          assistant.id == other.assistant.id &&
          query == other.query &&
          maxResults == other.maxResults;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      query.hashCode ^
      maxResults.hashCode;
}

/// 文字转语音参数类
class TextToSpeechParams {
  final models.AiProvider provider;
  final String text;
  final String? voice;
  final String? model;

  const TextToSpeechParams({
    required this.provider,
    required this.text,
    this.voice,
    this.model,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextToSpeechParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          text == other.text &&
          voice == other.voice;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      text.hashCode ^
      voice.hashCode;
}

/// 语音转文字参数类
class SpeechToTextParams {
  final models.AiProvider provider;
  final Uint8List audioData;
  final String? language;
  final String? model;

  const SpeechToTextParams({
    required this.provider,
    required this.audioData,
    this.language,
    this.model,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechToTextParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          audioData == other.audioData &&
          language == other.language;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      audioData.hashCode ^
      language.hashCode;
}

/// 图像分析参数类
class ImageAnalysisParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final Uint8List imageData;
  final String prompt;
  final String? imageFormat;

  const ImageAnalysisParams({
    required this.provider,
    required this.assistant,
    required this.modelName,
    required this.imageData,
    required this.prompt,
    this.imageFormat = 'png',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageAnalysisParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          assistant.id == other.assistant.id &&
          modelName == other.modelName &&
          imageData == other.imageData &&
          prompt == other.prompt;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      modelName.hashCode ^
      imageData.hashCode ^
      prompt.hashCode;
}

// ============================================================================
// 辅助函数
// ============================================================================

/// 验证域名格式是否有效
bool _isValidDomain(String domain) {
  if (domain.isEmpty) return false;

  // 基本域名格式验证
  final domainRegex = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$');
  return domainRegex.hasMatch(domain);
}
