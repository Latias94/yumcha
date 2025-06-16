import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/chat/domain/entities/message.dart';
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../media/media_storage_service.dart';
import '../block_based_chat_service.dart';
import '../ai_service_manager.dart';

// ============================================================================
// 块化聊天服务Providers
// ============================================================================

/// 基础设施层块化聊天服务Provider
/// 提供BlockBasedChatService实例（基础设施层服务）
final blockBasedChatServiceProvider = Provider<BlockBasedChatService>((ref) {
  final serviceManager = ref.read(aiServiceManagerProvider);
  final mediaService = MediaStorageService();

  return BlockBasedChatService(
    serviceManager: serviceManager,
    mediaService: mediaService,
  );
});

/// 块化聊天参数
class BlockChatParams {
  final String conversationId;
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final List<Message> chatHistory;
  final String userMessage;
  final bool autoGenerateImages;
  final bool autoGenerateTts;
  final bool enableImageAnalysis;

  const BlockChatParams({
    required this.conversationId,
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
    return other is BlockChatParams &&
        other.conversationId == conversationId &&
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
      conversationId,
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

/// 块化聊天Provider - 单次请求
final blockChatProvider = FutureProvider.autoDispose.family<Message, BlockChatParams>((
  ref,
  params,
) async {
  final blockChatService = ref.read(blockBasedChatServiceProvider);

  return await blockChatService.sendBlockMessage(
    conversationId: params.conversationId,
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

/// 块化聊天流式Provider
final blockChatStreamProvider = StreamProvider.autoDispose.family<Message, BlockChatParams>((
  ref,
  params,
) {
  final blockChatService = ref.read(blockBasedChatServiceProvider);

  return blockChatService.sendBlockMessageStream(
    conversationId: params.conversationId,
    provider: params.provider,
    assistant: params.assistant,
    modelName: params.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
    autoGenerateImages: params.autoGenerateImages,
    autoGenerateTts: params.autoGenerateTts,
  );
});

// ============================================================================
// 工具函数
// ============================================================================

/// 创建块化聊天参数的便捷函数
BlockChatParams createBlockChatParams({
  required String conversationId,
  required models.AiProvider provider,
  required AiAssistant assistant,
  required String modelName,
  required List<Message> chatHistory,
  required String userMessage,
  bool? autoGenerateImages,
  bool? autoGenerateTts,
  bool? enableImageAnalysis,
}) {
  return BlockChatParams(
    conversationId: conversationId,
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

// ============================================================================
// 兼容性支持 - 逐步迁移
// ============================================================================

/// 兼容性：从EnhancedChatParams转换为BlockChatParams
BlockChatParams convertFromEnhancedChatParams({
  required String conversationId,
  required dynamic enhancedParams, // EnhancedChatParams
}) {
  return BlockChatParams(
    conversationId: conversationId,
    provider: enhancedParams.provider,
    assistant: enhancedParams.assistant,
    modelName: enhancedParams.modelName,
    chatHistory: enhancedParams.chatHistory,
    userMessage: enhancedParams.userMessage,
    autoGenerateImages: enhancedParams.autoGenerateImages,
    autoGenerateTts: enhancedParams.autoGenerateTts,
    enableImageAnalysis: enhancedParams.enableImageAnalysis,
  );
}

/// 兼容性：支持旧的增强聊天接口，但使用新的块化服务
@Deprecated('使用 blockChatProvider 替代')
final legacyEnhancedChatProvider = FutureProvider.autoDispose.family<Message, dynamic>((
  ref,
  params,
) async {
  // 这里可以添加从旧参数到新参数的转换逻辑
  throw UnimplementedError('请使用 blockChatProvider 替代');
});

/// 兼容性：支持旧的增强聊天流式接口，但使用新的块化服务
@Deprecated('使用 blockChatStreamProvider 替代')
final legacyEnhancedChatStreamProvider = StreamProvider.autoDispose.family<Message, dynamic>((
  ref,
  params,
) {
  // 这里可以添加从旧参数到新参数的转换逻辑
  throw UnimplementedError('请使用 blockChatStreamProvider 替代');
});
