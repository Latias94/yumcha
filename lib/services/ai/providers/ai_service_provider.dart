import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ai_provider.dart' as models;
import '../../../models/ai_assistant.dart';
import '../../../models/message.dart';
import '../../../models/ai_model.dart';
import '../../../providers/ai_provider_notifier.dart';
import '../../../providers/ai_assistant_notifier.dart';
import '../../../providers/settings_notifier.dart';
import '../chat/chat_service.dart';
import '../capabilities/model_service.dart';
import '../core/ai_response_models.dart';

/// AI聊天服务的Riverpod Provider
final aiChatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// AI模型服务的Riverpod Provider
final aiModelServiceProvider = Provider<ModelService>((ref) {
  return ModelService();
});

/// 发送聊天消息的Provider
final sendChatMessageProvider =
    FutureProvider.family<AiResponse, SendChatMessageParams>((
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

/// 发送流式聊天消息的Provider
final sendChatMessageStreamProvider =
    StreamProvider.family<AiStreamEvent, SendChatMessageParams>((ref, params) {
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
final testAiProviderProvider = FutureProvider.family<bool, TestProviderParams>((
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
final providerModelsProvider = FutureProvider.family<List<AiModel>, String>((
  ref,
  providerId,
) async {
  final modelService = ref.read(aiModelServiceProvider);
  final provider = ref.read(aiProviderProvider(providerId));

  if (provider == null) {
    throw Exception('Provider not found: $providerId');
  }

  return await modelService.getModelsFromProvider(provider);
});

/// 获取AI服务统计信息的Provider
final aiServiceStatsProvider = Provider.family<AiServiceStats, String>((
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

/// 获取默认聊天配置的Provider
final defaultChatConfigProvider = Provider<AiServiceConfig?>((ref) {
  final defaultChatModel = ref
      .read(settingsNotifierProvider.notifier)
      .getDefaultChatModel();

  if (defaultChatModel == null ||
      defaultChatModel.providerId == null ||
      defaultChatModel.modelName == null) {
    return null;
  }

  return AiServiceConfig(
    providerId: defaultChatModel.providerId!,
    modelName: defaultChatModel.modelName!,
    enableStreaming: true,
    enableThinking: true,
    enableToolCalls: false,
  );
});

/// 智能聊天Provider - 自动使用默认配置
final smartChatProvider = FutureProvider.family<AiResponse, SmartChatParams>((
  ref,
  params,
) async {
  final config = ref.read(defaultChatConfigProvider);
  if (config == null) {
    throw Exception('No default chat configuration found');
  }

  final provider = ref.read(aiProviderProvider(config.providerId));
  // 使用默认助手或从参数中获取
  final assistant = params.assistantId != null
      ? ref.read(aiAssistantProvider(params.assistantId!))
      : ref.read(aiAssistantNotifierProvider).value?.firstOrNull;

  if (provider == null) {
    throw Exception('Provider not found: ${config.providerId}');
  }

  if (assistant == null) {
    throw Exception('No assistant available');
  }

  final chatService = ref.read(aiChatServiceProvider);

  return await chatService.sendMessage(
    provider: provider,
    assistant: assistant,
    modelName: config.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
  );
});

/// 智能流式聊天Provider - 自动使用默认配置
final smartChatStreamProvider =
    StreamProvider.family<AiStreamEvent, SmartChatParams>((ref, params) {
      final config = ref.read(defaultChatConfigProvider);
      if (config == null) {
        throw Exception('No default chat configuration found');
      }

      final provider = ref.read(aiProviderProvider(config.providerId));
      // 使用默认助手或从参数中获取
      final assistant = params.assistantId != null
          ? ref.read(aiAssistantProvider(params.assistantId!))
          : ref.read(aiAssistantNotifierProvider).value?.firstOrNull;

      if (provider == null) {
        throw Exception('Provider not found: ${config.providerId}');
      }

      if (assistant == null) {
        throw Exception('No assistant available');
      }

      final chatService = ref.read(aiChatServiceProvider);

      return chatService.sendMessageStream(
        provider: provider,
        assistant: assistant,
        modelName: config.modelName,
        chatHistory: params.chatHistory,
        userMessage: params.userMessage,
      );
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

/// 参数类定义

/// 发送聊天消息的参数
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

/// 测试提供商的参数
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

/// 模型能力检测的参数
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

/// 智能聊天的参数
class SmartChatParams {
  final List<Message> chatHistory;
  final String userMessage;
  final String? assistantId; // 可选的助手ID，如果不提供则使用默认助手

  const SmartChatParams({
    required this.chatHistory,
    required this.userMessage,
    this.assistantId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartChatParams &&
          runtimeType == other.runtimeType &&
          userMessage == other.userMessage &&
          assistantId == other.assistantId;

  @override
  int get hashCode => userMessage.hashCode ^ assistantId.hashCode;
}
