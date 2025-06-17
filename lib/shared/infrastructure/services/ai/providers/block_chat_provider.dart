import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/chat/domain/entities/message.dart';
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
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

// 已清理废弃的兼容性Provider - 2025-06-16
// 这些Provider已不再需要，所有功能已迁移到新的块化架构
