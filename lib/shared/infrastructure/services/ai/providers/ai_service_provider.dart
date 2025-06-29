import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/chat/domain/entities/message.dart';
import '../../../../../features/ai_management/domain/entities/ai_model.dart';
import '../../../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';

import '../chat/chat_service.dart';
import '../capabilities/model_service.dart';
import '../capabilities/speech_service.dart';
import '../capabilities/multimodal_service.dart';
import '../capabilities/image_generation_service.dart';
import '../capabilities/web_search_service.dart';
import '../core/ai_response_models.dart';

// ============================================================================
// 核心服务Providers
// ============================================================================

/// AI聊天服务Provider
final aiChatServiceProvider = Provider<ChatService>((ref) {
  // 使用配置了 Riverpod 依赖注入的 ChatService
  return ref.read(chatServiceProvider);
});

/// AI模型服务Provider
final aiModelServiceProvider = Provider<ModelService>((ref) {
  return ModelService();
});

/// AI语音服务Provider
final aiSpeechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

/// AI多模态服务Provider
final aiMultimodalServiceProvider = Provider<MultimodalService>((ref) {
  return MultimodalService();
});

/// AI图像生成服务Provider
final aiImageGenerationServiceProvider =
    Provider<ImageGenerationService>((ref) {
  return ImageGenerationService();
});

/// AI Web搜索服务Provider
final aiWebSearchServiceProvider = Provider<WebSearchService>((ref) {
  return WebSearchService();
});

// ============================================================================
// 聊天功能Providers
// ============================================================================

/// 发送聊天消息Provider（单次响应）
final sendChatMessageProvider =
    FutureProvider.autoDispose.family<AiResponse, SendChatMessageParams>((
  ref,
  params,
) async {
  final chatService = ref.read(aiChatServiceProvider);

  return await chatService.sendMessage(
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
  );
});

/// 发送流式聊天消息Provider（实时响应）
final sendChatMessageStreamProvider = StreamProvider.autoDispose
    .family<AiStreamEvent, SendChatMessageParams>((ref, params) {
  final chatService = ref.read(aiChatServiceProvider);

  return chatService.sendMessageStream(
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
  );
});

/// 测试AI提供商连接的Provider
///
/// 使用autoDispose避免内存泄漏，因为这是一次性测试操作
final testAiProviderProvider =
    FutureProvider.autoDispose.family<bool, TestProviderParams>((
  ref,
  params,
) async {
  final chatService = ref.read(aiChatServiceProvider);

  return await chatService.testProvider(
    provider: params.provider,
    modelName: params.modelName,
  );
});

/// 获取提供商模型列表的Provider
///
/// 使用autoDispose避免内存泄漏，因为模型列表是临时获取的数据
final providerModelsProvider =
    FutureProvider.autoDispose.family<List<AiModel>, String>((
  ref,
  providerId,
) async {
  final modelService = ref.read(aiModelServiceProvider);

  // 使用新的统一AI管理Provider
  final provider = ref.watch(specificProviderProvider(providerId));

  if (provider == null) {
    throw Exception('Provider not found: $providerId');
  }

  return await modelService.getModelsFromProvider(provider);
});

/// 获取AI服务统计信息的Provider
final aiChatServiceStatsProvider = Provider.family<AiServiceStats, String>((
  ref,
  providerId,
) {
  final chatService = ref.read(aiChatServiceProvider);
  return chatService.getStats(providerId);
});

/// 检测模型能力的Provider
final modelCapabilitiesProvider =
    Provider.family<Set<String>, ModelCapabilityParams>((ref, params) {
  final modelService = ref.read(aiModelServiceProvider);
  return modelService.detectModelCapabilities(
    provider: params.provider,
    modelName: params.modelName,
  );
});

// ============================================================================
// 智能聊天Providers
// ============================================================================

/// 智能聊天Provider - 需要指定providerId和modelName
///
/// 使用autoDispose避免内存泄漏，因为这是一次性聊天请求
final smartChatProvider =
    FutureProvider.autoDispose.family<AiResponse, SmartChatParams>((
  ref,
  params,
) async {
  final providerId = params.providerId;
  final modelName = params.modelName;

  if (providerId == null) {
    throw Exception('Provider ID not specified');
  }

  if (modelName == null) {
    throw Exception('Model name not specified');
  }

  // 使用新的统一AI管理Provider
  final provider = ref.watch(specificProviderProvider(providerId));
  final assistant = params.assistantId != null
      ? ref.watch(specificAssistantProvider(params.assistantId!))
      : ref.watch(aiAssistantsProvider).firstOrNull;

  if (provider == null) {
    throw Exception('Provider not found: $providerId');
  }

  if (assistant == null) {
    throw Exception('No assistant available');
  }

  final chatService = ref.read(aiChatServiceProvider);

  return await chatService.sendMessage(
    provider: provider,
    assistant: assistant,
    modelName: modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
  );
});

/// 智能流式聊天Provider - 需要指定providerId和modelName
///
/// 使用autoDispose避免内存泄漏，因为这是一次性流式聊天请求
final smartChatStreamProvider = StreamProvider.autoDispose
    .family<AiStreamEvent, SmartChatParams>((ref, params) {
  final providerId = params.providerId;
  final modelName = params.modelName;

  if (providerId == null) {
    throw Exception('Provider ID not specified');
  }

  if (modelName == null) {
    throw Exception('Model name not specified');
  }

  // 使用新的统一AI管理Provider
  final provider = ref.watch(specificProviderProvider(providerId));
  final assistant = params.assistantId != null
      ? ref.watch(specificAssistantProvider(params.assistantId!))
      : ref.watch(aiAssistantsProvider).firstOrNull;

  if (provider == null) {
    throw Exception('Provider not found: $providerId');
  }

  if (assistant == null) {
    throw Exception('No assistant available');
  }

  final chatService = ref.read(aiChatServiceProvider);

  return chatService.sendMessageStream(
    provider: provider,
    assistant: assistant,
    modelName: modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
  );
});

// ============================================================================
// 对话聊天Providers - 包含完整业务逻辑
// ============================================================================

/// 对话聊天Provider - 包含标题生成、对话保存等完整业务逻辑
///
/// 使用autoDispose避免内存泄漏，因为这是一次性对话请求
final conversationChatProvider = FutureProvider.autoDispose
    .family<ConversationChatResponse, ConversationChatParams>((
  ref,
  params,
) async {
  // TODO: 实现完整的对话聊天逻辑
  throw UnimplementedError('conversationChatProvider 待实现');
});

/// 对话流式聊天Provider - 包含完整业务逻辑的流式聊天接口
///
/// 使用autoDispose避免内存泄漏，因为这是一次性流式对话请求
final conversationChatStreamProvider = StreamProvider.autoDispose
    .family<ConversationChatStreamEvent, ConversationChatParams>((
  ref,
  params,
) {
  // TODO: 实现完整的对话流式聊天逻辑
  throw UnimplementedError('conversationChatStreamProvider 待实现');
});

/// 清除模型缓存的Provider
final clearModelCacheProvider = Provider.family<void, String?>((
  ref,
  providerId,
) {
  final modelService = ref.read(aiModelServiceProvider);
  modelService.clearCache(providerId);
});

/// 获取模型缓存统计的Provider
final modelCacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final modelService = ref.read(aiModelServiceProvider);
  return modelService.getCacheStats();
});

// ============================================================================
// 图像生成功能Providers
// ============================================================================

/// 图像生成Provider
final generateImageProvider = FutureProvider.autoDispose
    .family<ImageGenerationResponse, ImageGenerationParams>((
  ref,
  params,
) async {
  final imageService = ref.read(aiImageGenerationServiceProvider);

  return await imageService.generateImage(
    provider: params.provider,
    prompt: params.prompt,
    size: params.size,
    quality: params.quality,
    style: params.style,
    count: params.count,
  );
});

/// 检查图像生成支持的Provider
final imageGenerationSupportProvider =
    Provider.family<bool, models.AiProvider>((ref, provider) {
  final imageService = ref.read(aiImageGenerationServiceProvider);
  return imageService.supportsImageGeneration(provider);
});

/// 获取支持的图像尺寸Provider
final supportedImageSizesProvider =
    Provider.family<List<String>, models.AiProvider>((ref, provider) {
  final imageService = ref.read(aiImageGenerationServiceProvider);
  return imageService.getSupportedSizes(provider);
});

// ============================================================================
// Web搜索功能Providers
// ============================================================================

/// Web搜索Provider
final webSearchProvider =
    FutureProvider.autoDispose.family<WebSearchResponse, WebSearchParams>((
  ref,
  params,
) async {
  final webSearchService = ref.read(aiWebSearchServiceProvider);

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
final newsSearchProvider =
    FutureProvider.autoDispose.family<WebSearchResponse, NewsSearchParams>((
  ref,
  params,
) async {
  final webSearchService = ref.read(aiWebSearchServiceProvider);

  return await webSearchService.searchNews(
    provider: params.provider,
    assistant: params.assistant,
    query: params.query,
    maxResults: params.maxResults,
    fromDate: params.fromDate,
    toDate: params.toDate,
  );
});

/// 检查Web搜索支持的Provider
final webSearchSupportProvider =
    Provider.family<bool, models.AiProvider>((ref, provider) {
  final webSearchService = ref.read(aiWebSearchServiceProvider);
  return webSearchService.supportsWebSearch(provider);
});

// ============================================================================
// 语音功能Providers
// ============================================================================

/// 文字转语音Provider
final textToSpeechProvider = FutureProvider.autoDispose
    .family<TextToSpeechResponse, TextToSpeechParams>((
  ref,
  params,
) async {
  final multimodalService = ref.read(aiMultimodalServiceProvider);

  return await multimodalService.textToSpeech(
    provider: params.provider,
    text: params.text,
    voice: params.voice,
    model: params.model,
  );
});

/// 语音转文字Provider
final speechToTextProvider = FutureProvider.autoDispose
    .family<SpeechToTextResponse, SpeechToTextParams>((
  ref,
  params,
) async {
  final multimodalService = ref.read(aiMultimodalServiceProvider);

  return await multimodalService.speechToText(
    provider: params.provider,
    audioData: params.audioData,
    language: params.language,
    model: params.model,
  );
});

/// 检查TTS支持的Provider
final ttsSupportProvider =
    Provider.family<bool, models.AiProvider>((ref, provider) {
  final speechService = ref.read(aiSpeechServiceProvider);
  return speechService.supportsTts(provider);
});

/// 检查STT支持的Provider
final sttSupportProvider =
    Provider.family<bool, models.AiProvider>((ref, provider) {
  final speechService = ref.read(aiSpeechServiceProvider);
  return speechService.supportsStt(provider);
});

/// 获取支持的语音列表Provider
final supportedVoicesProvider =
    Provider.family<List<String>, models.AiProvider>((ref, provider) {
  final speechService = ref.read(aiSpeechServiceProvider);
  return speechService.getSupportedVoices(provider);
});

// ============================================================================
// 多模态功能Providers
// ============================================================================

/// 图像分析Provider
final analyzeImageProvider =
    FutureProvider.autoDispose.family<AiResponse, ImageAnalysisParams>((
  ref,
  params,
) async {
  final multimodalService = ref.read(aiMultimodalServiceProvider);

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
// HTTP配置功能Providers
// ============================================================================

/// HTTP代理配置Provider
final httpProxyConfigProvider =
    Provider.family<HttpProxyConfig?, String?>((ref, proxyUrl) {
  if (proxyUrl == null || proxyUrl.isEmpty) return null;

  return HttpProxyConfig(
    proxyUrl: proxyUrl,
    isEnabled: true,
  );
});

/// HTTP超时配置Provider
final httpTimeoutConfigProvider =
    Provider.family<HttpTimeoutConfig, Duration>((ref, timeout) {
  return HttpTimeoutConfig(
    connectionTimeout: timeout,
    receiveTimeout: timeout,
    sendTimeout: timeout,
  );
});

// ============================================================================
// 参数类定义
// ============================================================================

/// 发送聊天消息的参数类
class SendChatMessageParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final List<Message> chatHistory;
  final String userMessage;

  const SendChatMessageParams({
    required this.provider,
    required this.assistant,
    required this.modelName,
    required this.chatHistory,
    required this.userMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendChatMessageParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          assistant.id == other.assistant.id &&
          modelName == other.modelName &&
          userMessage == other.userMessage;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      modelName.hashCode ^
      userMessage.hashCode;
}

/// 测试提供商的参数类
class TestProviderParams {
  final models.AiProvider provider;
  final String? modelName;

  const TestProviderParams({required this.provider, this.modelName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestProviderParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          modelName == other.modelName;

  @override
  int get hashCode => provider.id.hashCode ^ modelName.hashCode;
}

/// 模型能力检测的参数类
class ModelCapabilityParams {
  final models.AiProvider provider;
  final String modelName;

  const ModelCapabilityParams({
    required this.provider,
    required this.modelName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCapabilityParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          modelName == other.modelName;

  @override
  int get hashCode => provider.id.hashCode ^ modelName.hashCode;
}

/// 智能聊天的参数类
///
/// 这是智能聊天功能的简化参数类，专为便捷使用而设计。
/// 与`SendChatMessageParams`相比，这个类大大简化了参数配置：
///
/// ## 🎯 设计理念
///
/// ### 简化优先
/// - **最少参数**：只需要提供必要的对话信息
/// - **自动配置**：系统自动处理提供商和模型选择
/// - **智能默认**：使用用户设置的默认配置
/// - **渐进增强**：支持可选的高级配置
///
/// ### 用户友好
/// - **零学习成本**：新用户可以立即使用
/// - **配置同步**：自动跟随用户的偏好设置
/// - **错误容忍**：提供友好的错误提示
///
/// ## 📋 参数说明
///
/// ### 💬 必需参数
/// - `chatHistory`: 历史对话消息，维护对话上下文
/// - `userMessage`: 用户当前输入的消息内容
///
/// ### 🎛️ 可选参数
/// - `assistantId`: 可选的助手ID，用于指定特定助手
///   - 如果提供：使用指定的助手配置
///   - 如果不提供：使用系统中的第一个可用助手
///
/// ## 🚀 使用场景
///
/// ### 1. 快速原型开发
/// ```dart
/// final response = await ref.read(smartChatProvider(
///   SmartChatParams(
///     chatHistory: [],
///     userMessage: 'Hello!',
///   ),
/// ).future);
/// ```
///
/// ### 2. 标准聊天界面
/// ```dart
/// final params = SmartChatParams(
///   chatHistory: conversationMessages,
///   userMessage: userInput,
/// );
///
/// ref.listen(smartChatStreamProvider(params), handleResponse);
/// ```
///
/// ### 3. 指定特定助手
/// ```dart
/// final params = SmartChatParams(
///   chatHistory: messages,
///   userMessage: 'Help me with coding',
///   assistantId: 'coding-assistant-id',
/// );
/// ```
///
/// ## 🔄 自动配置流程
/// 1. **获取默认配置**：从用户设置中读取默认聊天配置
/// 2. **选择提供商**：使用配置中指定的AI提供商
/// 3. **选择助手**：使用指定助手或默认助手
/// 4. **验证配置**：确保所有配置都有效可用
/// 5. **执行请求**：使用完整配置执行AI请求
///
/// ## ⚡ 性能特性
/// - **轻量级**：参数对象占用内存小
/// - **缓存友好**：支持高效的相等性比较
/// - **不可变**：线程安全的不可变对象
///
/// ## 🔍 相等性逻辑
/// 两个智能聊天参数被认为相等当且仅当：
/// - 用户消息内容相同
/// - 助手ID相同（都为null或都为相同值）
///
/// 注意：chatHistory不参与相等性比较，这样可以：
/// - 优化缓存性能
/// - 避免因历史消息变化导致的频繁重新计算
/// - 支持相同用户输入的快速响应
class SmartChatParams {
  /// 聊天历史消息列表
  ///
  /// 包含之前的对话消息，用于维护对话上下文。
  /// AI会根据这些历史消息来理解当前对话的背景。
  final List<Message> chatHistory;

  /// 用户当前输入的消息
  ///
  /// 用户在当前轮次中输入的消息内容。
  /// 这是AI需要回应的主要内容。
  final String userMessage;

  /// 可选的助手ID
  ///
  /// 如果指定，将使用对应ID的助手配置；
  /// 如果不指定（null），将使用系统中的第一个可用助手。
  ///
  /// 这允许用户在不同的助手之间切换，例如：
  /// - 'general-assistant': 通用聊天助手
  /// - 'coding-assistant': 编程专用助手
  /// - 'writing-assistant': 写作专用助手
  final String? assistantId;

  /// 可选的提供商ID
  ///
  /// 如果指定，将使用对应ID的提供商配置；
  /// 如果不指定（null），将使用默认聊天配置中的提供商。
  ///
  /// 这允许用户临时切换提供商，例如：
  /// - 'openai-gpt4': 使用OpenAI GPT-4
  /// - 'anthropic-claude': 使用Anthropic Claude
  /// - 'google-gemini': 使用Google Gemini
  final String? providerId;

  /// 可选的模型名称
  ///
  /// 如果指定，将使用指定的模型；
  /// 如果不指定（null），将使用默认聊天配置中的模型。
  ///
  /// 这允许用户临时切换模型，例如：
  /// - 'gpt-4': OpenAI GPT-4
  /// - 'claude-3-opus': Anthropic Claude 3 Opus
  /// - 'gemini-pro': Google Gemini Pro
  final String? modelName;

  /// 构造函数
  ///
  /// 创建智能聊天参数实例。
  ///
  /// @param chatHistory 聊天历史消息（必需）
  /// @param userMessage 用户消息内容（必需）
  /// @param assistantId 助手ID（可选）
  /// @param providerId 提供商ID（可选）
  /// @param modelName 模型名称（可选）
  const SmartChatParams({
    required this.chatHistory,
    required this.userMessage,
    this.assistantId,
    this.providerId,
    this.modelName,
  });

  /// 相等性比较
  ///
  /// 用于Riverpod缓存优化。比较用户消息、助手ID、提供商ID和模型名称，
  /// 不包括聊天历史以提升性能。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartChatParams &&
          runtimeType == other.runtimeType &&
          userMessage == other.userMessage &&
          assistantId == other.assistantId &&
          providerId == other.providerId &&
          modelName == other.modelName;

  /// 哈希码计算
  ///
  /// 基于用户消息、助手ID、提供商ID和模型名称计算哈希码，
  /// 用于高效的缓存查找和去重。
  @override
  int get hashCode =>
      Object.hash(userMessage, assistantId, providerId, modelName);
}

/// 对话聊天的参数类
///
/// 用于包含完整业务逻辑的对话聊天接口。
class ConversationChatParams {
  /// 对话ID（新对话时为null）
  final String? conversationId;

  /// 助手ID
  final String assistantId;

  /// 用户消息
  final String userMessage;

  /// 是否生成标题（默认true）
  final bool generateTitle;

  const ConversationChatParams({
    this.conversationId,
    required this.assistantId,
    required this.userMessage,
    this.generateTitle = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationChatParams &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId &&
          assistantId == other.assistantId &&
          userMessage == other.userMessage &&
          generateTitle == other.generateTitle;

  @override
  int get hashCode =>
      conversationId.hashCode ^
      assistantId.hashCode ^
      userMessage.hashCode ^
      generateTitle.hashCode;
}

/// 对话聊天的响应类
///
/// 包含AI响应和业务处理结果。
class ConversationChatResponse {
  /// AI响应内容
  final String content;

  /// 思考过程（如果有）
  final String? thinking;

  /// 对话ID
  final String conversationId;

  /// 消息ID
  final String messageId;

  /// 是否生成了新标题
  final bool titleGenerated;

  /// 生成的标题（如果有）
  final String? generatedTitle;

  /// 是否成功
  final bool isSuccess;

  /// 错误信息（如果失败）
  final String? error;

  const ConversationChatResponse({
    required this.content,
    this.thinking,
    required this.conversationId,
    required this.messageId,
    this.titleGenerated = false,
    this.generatedTitle,
    this.isSuccess = true,
    this.error,
  });
}

/// 对话流式聊天的事件类
///
/// 包含流式响应和业务处理事件。
class ConversationChatStreamEvent {
  /// 内容增量
  final String? contentDelta;

  /// 思考增量
  final String? thinkingDelta;

  /// 是否完成
  final bool isCompleted;

  /// 对话ID（完成时提供）
  final String? conversationId;

  /// 消息ID（完成时提供）
  final String? messageId;

  /// 是否生成了标题（完成时提供）
  final bool? titleGenerated;

  /// 生成的标题（完成时提供）
  final String? generatedTitle;

  /// 错误信息
  final String? error;

  const ConversationChatStreamEvent({
    this.contentDelta,
    this.thinkingDelta,
    this.isCompleted = false,
    this.conversationId,
    this.messageId,
    this.titleGenerated,
    this.generatedTitle,
    this.error,
  });

  /// 是否为内容事件
  bool get isContent => contentDelta != null;

  /// 是否为思考事件
  bool get isThinking => thinkingDelta != null;

  /// 是否为错误事件
  bool get isError => error != null;
}

// ============================================================================
// 新增功能参数类定义
// ============================================================================

/// 图像生成的参数类
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
          style == other.style &&
          count == other.count;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      prompt.hashCode ^
      size.hashCode ^
      quality.hashCode ^
      style.hashCode ^
      count.hashCode;
}

/// Web搜索的参数类
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
          maxResults == other.maxResults &&
          language == other.language;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      query.hashCode ^
      maxResults.hashCode ^
      language.hashCode;
}

/// 新闻搜索的参数类
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
          maxResults == other.maxResults &&
          fromDate == other.fromDate &&
          toDate == other.toDate;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      query.hashCode ^
      maxResults.hashCode ^
      fromDate.hashCode ^
      toDate.hashCode;
}

/// 文字转语音的参数类
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
          voice == other.voice &&
          model == other.model;

  @override
  int get hashCode =>
      provider.id.hashCode ^ text.hashCode ^ voice.hashCode ^ model.hashCode;
}

/// 语音转文字的参数类
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
          language == other.language &&
          model == other.model;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      audioData.hashCode ^
      language.hashCode ^
      model.hashCode;
}

/// 图像分析的参数类
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
          prompt == other.prompt &&
          imageFormat == other.imageFormat;

  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      modelName.hashCode ^
      imageData.hashCode ^
      prompt.hashCode ^
      imageFormat.hashCode;
}

/// HTTP代理配置类
class HttpProxyConfig {
  final String proxyUrl;
  final bool isEnabled;
  final String? username;
  final String? password;

  const HttpProxyConfig({
    required this.proxyUrl,
    required this.isEnabled,
    this.username,
    this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpProxyConfig &&
          runtimeType == other.runtimeType &&
          proxyUrl == other.proxyUrl &&
          isEnabled == other.isEnabled &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode =>
      proxyUrl.hashCode ^
      isEnabled.hashCode ^
      username.hashCode ^
      password.hashCode;
}

/// HTTP超时配置类
class HttpTimeoutConfig {
  final Duration connectionTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const HttpTimeoutConfig({
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpTimeoutConfig &&
          runtimeType == other.runtimeType &&
          connectionTimeout == other.connectionTimeout &&
          receiveTimeout == other.receiveTimeout &&
          sendTimeout == other.sendTimeout;

  @override
  int get hashCode =>
      connectionTimeout.hashCode ^
      receiveTimeout.hashCode ^
      sendTimeout.hashCode;
}
