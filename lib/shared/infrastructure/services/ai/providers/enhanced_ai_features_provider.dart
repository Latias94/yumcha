import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../capabilities/enhanced_chat_configuration_service.dart';
import '../capabilities/image_generation_service.dart';
import '../capabilities/web_search_service.dart';
import '../capabilities/multimodal_service.dart';
import '../capabilities/http_configuration_service.dart';
import '../core/ai_response_models.dart';

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

/// 创建增强聊天配置Provider
final createEnhancedConfigProvider = FutureProvider.autoDispose.family<EnhancedChatConfig, EnhancedConfigParams>((
  ref,
  params,
) async {
  final configService = ref.read(enhancedChatConfigurationServiceProvider);

  return await configService.createEnhancedConfig(
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

/// 图像生成Provider
final generateImageProvider = FutureProvider.autoDispose.family<ImageGenerationResponse, ImageGenerationParams>((
  ref,
  params,
) async {
  final imageService = ref.read(imageGenerationServiceProvider);

  return await imageService.generateImage(
    provider: params.provider,
    prompt: params.prompt,
    size: params.size,
    quality: params.quality,
    style: params.style,
    count: params.count,
  );
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

/// Web搜索Provider
final webSearchProvider = FutureProvider.autoDispose.family<WebSearchResponse, WebSearchParams>((
  ref,
  params,
) async {
  final webSearchService = ref.read(webSearchServiceProvider);

  return await webSearchService.searchWeb(
    provider: params.provider,
    assistant: params.assistant,
    query: params.query,
    maxResults: params.maxResults,
    language: params.language,
    allowedDomains: params.allowedDomains,
    blockedDomains: params.blockedDomains,
  );
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

/// 文字转语音Provider
final textToSpeechProvider = FutureProvider.autoDispose.family<TextToSpeechResponse, TextToSpeechParams>((
  ref,
  params,
) async {
  final multimodalService = ref.read(multimodalServiceProvider);

  return await multimodalService.textToSpeech(
    provider: params.provider,
    text: params.text,
    voice: params.voice,
    model: params.model,
  );
});

/// 语音转文字Provider
final speechToTextProvider = FutureProvider.autoDispose.family<SpeechToTextResponse, SpeechToTextParams>((
  ref,
  params,
) async {
  final multimodalService = ref.read(multimodalServiceProvider);

  return await multimodalService.speechToText(
    provider: params.provider,
    audioData: params.audioData,
    language: params.language,
    model: params.model,
  );
});

/// 图像分析Provider
final analyzeImageProvider = FutureProvider.autoDispose.family<AiResponse, ImageAnalysisParams>((
  ref,
  params,
) async {
  final multimodalService = ref.read(multimodalServiceProvider);

  return await multimodalService.analyzeImage(
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    imageData: params.imageData,
    prompt: params.prompt,
    imageFormat: params.imageFormat,
  );
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
