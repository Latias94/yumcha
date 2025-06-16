/// 增强聊天Provider - 提供增强聊天功能的Riverpod Provider
///
/// ⚠️ **已弃用 (DEPRECATED)** ⚠️
///
/// 这个文件中的Provider已被新的块化聊天系统替代，请使用：
/// - `blockChatProvider` 替代 `enhancedChatProvider`
/// - `blockBasedChatServiceProvider` 替代 `enhancedChatServiceProvider`
/// - `BlockBasedChatService` 替代 `EnhancedChatService`
///
/// ## 迁移指南
///
/// 参考 `docs/enhanced_to_block_migration_guide.md` 了解详细的迁移步骤。
///
/// @deprecated 使用块化聊天系统替代
library;

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/chat/domain/entities/message.dart';
import '../../../../../features/chat/domain/entities/enhanced_message.dart';
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../media/media_storage_service.dart';
import '../enhanced_chat_service.dart';
import '../ai_service_manager.dart';

// ============================================================================
// 增强聊天服务Providers (已弃用)
// ============================================================================

/// 增强聊天服务Provider
/// @deprecated 使用 blockBasedChatServiceProvider 替代
@Deprecated('使用 blockBasedChatServiceProvider 替代')
final enhancedChatServiceProvider = Provider<EnhancedChatService>((ref) {
  final serviceManager = ref.read(aiServiceManagerProvider);
  final mediaService = MediaStorageService();

  return EnhancedChatService(
    serviceManager: serviceManager,
    mediaService: mediaService,
  );
});

/// 增强聊天参数
/// @deprecated 使用块化聊天系统的参数替代
@Deprecated('使用块化聊天系统的参数替代')
class EnhancedChatParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final List<Message> chatHistory;
  final String userMessage;
  final bool autoGenerateImages;
  final bool autoGenerateTts;
  final bool enableImageAnalysis;

  const EnhancedChatParams({
    required this.provider,
    required this.assistant,
    required this.modelName,
    required this.chatHistory,
    required this.userMessage,
    this.autoGenerateImages = true,
    this.autoGenerateTts = true,
    this.enableImageAnalysis = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedChatParams &&
        other.provider == provider &&
        other.assistant == assistant &&
        other.modelName == modelName &&
        other.chatHistory == chatHistory &&
        other.userMessage == userMessage &&
        other.autoGenerateImages == autoGenerateImages &&
        other.autoGenerateTts == autoGenerateTts &&
        other.enableImageAnalysis == enableImageAnalysis;
  }

  @override
  int get hashCode {
    return Object.hash(
      provider,
      assistant,
      modelName,
      chatHistory,
      userMessage,
      autoGenerateImages,
      autoGenerateTts,
      enableImageAnalysis,
    );
  }
}

/// 增强聊天Provider - 单次请求
/// @deprecated 使用 blockChatProvider 替代
@Deprecated('使用 blockChatProvider 替代')
final enhancedChatProvider = FutureProvider.autoDispose.family<EnhancedMessage, EnhancedChatParams>((
  ref,
  params,
) async {
  final enhancedChatService = ref.read(enhancedChatServiceProvider);

  return await enhancedChatService.sendEnhancedMessage(
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
    autoGenerateImages: params.autoGenerateImages,
    autoGenerateTts: params.autoGenerateTts,
    enableImageAnalysis: params.enableImageAnalysis,
  );
});

/// 增强聊天流式Provider
/// @deprecated 使用 blockChatStreamProvider 替代
@Deprecated('使用 blockChatStreamProvider 替代')
final enhancedChatStreamProvider = StreamProvider.autoDispose.family<EnhancedMessage, EnhancedChatParams>((
  ref,
  params,
) {
  final enhancedChatService = ref.read(enhancedChatServiceProvider);

  return enhancedChatService.sendEnhancedMessageStream(
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
    autoGenerateImages: params.autoGenerateImages,
    autoGenerateTts: params.autoGenerateTts,
  );
});

/// 图片分析参数
class ImageAnalysisParams {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final Uint8List imageData;
  final String prompt;
  final String? fileName;

  const ImageAnalysisParams({
    required this.provider,
    required this.assistant,
    required this.modelName,
    required this.imageData,
    required this.prompt,
    this.fileName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageAnalysisParams &&
        other.provider == provider &&
        other.assistant == assistant &&
        other.modelName == modelName &&
        other.imageData == imageData &&
        other.prompt == prompt &&
        other.fileName == fileName;
  }

  @override
  int get hashCode {
    return Object.hash(
      provider,
      assistant,
      modelName,
      imageData,
      prompt,
      fileName,
    );
  }
}

/// 图片分析Provider
final imageAnalysisProvider = FutureProvider.autoDispose.family<EnhancedMessage, ImageAnalysisParams>((
  ref,
  params,
) async {
  final enhancedChatService = ref.read(enhancedChatServiceProvider);

  return await enhancedChatService.analyzeImage(
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    imageData: params.imageData,
    prompt: params.prompt,
    fileName: params.fileName,
  );
});

// ============================================================================
// 多媒体功能检测Providers
// ============================================================================

/// 检查提供商是否支持图片生成
final supportsImageGenerationProvider = Provider.family<bool, models.AiProvider>((
  ref,
  provider,
) {
  switch (provider.type.name.toLowerCase()) {
    case 'openai':
    case 'stability':
    case 'midjourney':
      return true;
    default:
      return false;
  }
});

/// 检查提供商是否支持TTS
final supportsTtsProvider = Provider.family<bool, models.AiProvider>((
  ref,
  provider,
) {
  switch (provider.type.name.toLowerCase()) {
    case 'openai':
    case 'elevenlabs':
      return true;
    default:
      return false;
  }
});

/// 检查提供商是否支持图片分析
final supportsImageAnalysisProvider = Provider.family<bool, models.AiProvider>((
  ref,
  provider,
) {
  switch (provider.type.name.toLowerCase()) {
    case 'openai':
    case 'anthropic':
    case 'google':
      return true;
    default:
      return false;
  }
});

// ============================================================================
// 多媒体设置Providers
// ============================================================================

/// 自动图片生成设置
final autoImageGenerationProvider = StateProvider<bool>((ref) => true);

/// 自动TTS生成设置
final autoTtsGenerationProvider = StateProvider<bool>((ref) => true);

/// 图片分析功能设置
final imageAnalysisEnabledProvider = StateProvider<bool>((ref) => true);

/// TTS语音选择
final preferredTtsVoiceProvider = StateProvider<String>((ref) => 'alloy');

/// 图片生成质量设置
final imageGenerationQualityProvider = StateProvider<String>((ref) => 'standard');

/// 图片生成尺寸设置
final imageGenerationSizeProvider = StateProvider<String>((ref) => '1024x1024');

// ============================================================================
// 使用示例和工具函数
// ============================================================================

/// 创建增强聊天参数的便捷函数
EnhancedChatParams createEnhancedChatParams({
  required models.AiProvider provider,
  required AiAssistant assistant,
  required String modelName,
  required List<Message> chatHistory,
  required String userMessage,
  bool? autoGenerateImages,
  bool? autoGenerateTts,
  bool? enableImageAnalysis,
}) {
  return EnhancedChatParams(
    provider: provider,
    assistant: assistant,
    modelName: modelName,
    chatHistory: chatHistory,
    userMessage: userMessage,
    autoGenerateImages: autoGenerateImages ?? true,
    autoGenerateTts: autoGenerateTts ?? true,
    enableImageAnalysis: enableImageAnalysis ?? true,
  );
}

/// 创建图片分析参数的便捷函数
ImageAnalysisParams createImageAnalysisParams({
  required models.AiProvider provider,
  required AiAssistant assistant,
  required String modelName,
  required Uint8List imageData,
  required String prompt,
  String? fileName,
}) {
  return ImageAnalysisParams(
    provider: provider,
    assistant: assistant,
    modelName: modelName,
    imageData: imageData,
    prompt: prompt,
    fileName: fileName,
  );
}

/// 检查提供商的多媒体能力
class MultimediaCapabilities {
  final bool supportsImageGeneration;
  final bool supportsTts;
  final bool supportsImageAnalysis;

  const MultimediaCapabilities({
    required this.supportsImageGeneration,
    required this.supportsTts,
    required this.supportsImageAnalysis,
  });

  bool get hasAnyCapability => 
      supportsImageGeneration || supportsTts || supportsImageAnalysis;

  bool get hasAllCapabilities => 
      supportsImageGeneration && supportsTts && supportsImageAnalysis;
}

/// 获取提供商的多媒体能力
final providerMultimediaCapabilitiesProvider = Provider.family<MultimediaCapabilities, models.AiProvider>((
  ref,
  provider,
) {
  return MultimediaCapabilities(
    supportsImageGeneration: ref.read(supportsImageGenerationProvider(provider)),
    supportsTts: ref.read(supportsTtsProvider(provider)),
    supportsImageAnalysis: ref.read(supportsImageAnalysisProvider(provider)),
  );
});
