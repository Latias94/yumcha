import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/unified_ai_management_state_model.dart';
import '../../domain/entities/unified_ai_management_state.dart';
import '../../domain/entities/user_ai_configuration.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../domain/entities/ai_model.dart';
import 'unified_ai_management_notifier.dart';

// 导出新的AI配置状态Provider
export 'ai_configuration_state_provider.dart';

/// 统一AI管理Provider
final unifiedAiManagementProvider = StateNotifierProvider<UnifiedAiManagementNotifier, UnifiedAiManagementState>(
  (ref) => UnifiedAiManagementNotifier(ref),
);

/// 便捷访问Provider - AI提供商相关
final aiProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).providers;
});

final enabledAiProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).enabledProviders;
});

final connectedAiProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).connectedProviders;
});

final favoriteAiProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).favoriteProviders;
});

/// 便捷访问Provider - AI助手相关
final aiAssistantsProvider = Provider<List<AiAssistant>>((ref) {
  return ref.watch(unifiedAiManagementProvider).assistants;
});

final enabledAiAssistantsProvider = Provider<List<AiAssistant>>((ref) {
  return ref.watch(unifiedAiManagementProvider).enabledAssistants;
});

final favoriteAiAssistantsProvider = Provider<List<AiAssistant>>((ref) {
  return ref.watch(unifiedAiManagementProvider).favoriteAssistants;
});

/// 便捷访问Provider - 配置相关
final aiConfigurationProvider = Provider<UserAiConfiguration>((ref) {
  return ref.watch(unifiedAiManagementProvider).configuration;
});

final currentAiSelectionProvider = Provider<({AiAssistant? assistant, AiProvider? provider, AiModel? model})>((ref) {
  return ref.watch(unifiedAiManagementProvider).currentSelection;
});

final selectedAssistantProvider = Provider<AiAssistant?>((ref) {
  return ref.watch(unifiedAiManagementProvider).configuration.selectedAssistant;
});

final selectedProviderProvider = Provider<AiProvider?>((ref) {
  return ref.watch(unifiedAiManagementProvider).configuration.selectedProvider;
});

final selectedModelProvider = Provider<AiModel?>((ref) {
  return ref.watch(unifiedAiManagementProvider).configuration.selectedModel;
});

/// 便捷访问Provider - 状态相关
final aiManagementLoadingProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAiManagementProvider).isLoading;
});

final aiManagementErrorProvider = Provider<String?>((ref) {
  return ref.watch(unifiedAiManagementProvider).error;
});

final aiManagementInitializedProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAiManagementProvider).isInitialized;
});

final aiManagementEventProvider = Provider<AiManagementEvent?>((ref) {
  return ref.watch(unifiedAiManagementProvider).lastEvent;
});

/// 便捷访问Provider - 统计信息
final providerStatsProvider = Provider<({int total, int enabled, int connected})>((ref) {
  return ref.watch(unifiedAiManagementProvider).providerStats;
});

final assistantStatsProvider = Provider<({int total, int enabled, int custom})>((ref) {
  return ref.watch(unifiedAiManagementProvider).assistantStats;
});

/// 便捷访问Provider - 能力相关
final visionProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).visionProviders;
});

final toolProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).toolProviders;
});

final ttsProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).ttsProviders;
});

final reasoningProvidersProvider = Provider<List<AiProvider>>((ref) {
  return ref.watch(unifiedAiManagementProvider).reasoningProviders;
});

/// 便捷访问Provider - 配置模板
final availableTemplatesProvider = Provider<Map<String, ConfigTemplate>>((ref) {
  return ref.watch(unifiedAiManagementProvider).availableTemplates;
});

final configTemplatesListProvider = Provider<List<ConfigTemplate>>((ref) {
  return ref.watch(unifiedAiManagementProvider).availableTemplatesList;
});

/// 便捷访问Provider - 配置检查
final hasCompleteConfigurationProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAiManagementProvider).hasCompleteConfiguration;
});

final needsConfigBackupProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAiManagementProvider).needsConfigBackup;
});

/// 便捷访问Provider - 详细统计信息（计算版本）
final detailedProviderStatsProvider = Provider<({int total, int enabled, int connected})>((ref) {
  final providers = ref.watch(aiProvidersProvider);
  final connectedProviders = ref.watch(connectedAiProvidersProvider);
  final enabledProviders = ref.watch(enabledAiProvidersProvider);

  return (
    total: providers.length,
    enabled: enabledProviders.length,
    connected: connectedProviders.length,
  );
});

final detailedAssistantStatsProvider = Provider<({int total, int enabled, int custom})>((ref) {
  final assistants = ref.watch(aiAssistantsProvider);
  final enabledAssistants = ref.watch(enabledAiAssistantsProvider);
  // 暂时将所有助手都视为自定义助手，后续可以根据需要添加isCustom属性
  final customAssistants = assistants;

  return (
    total: assistants.length,
    enabled: enabledAssistants.length,
    custom: customAssistants.length,
  );
});

/// 便捷访问Provider - 状态检查
final isAiManagementLoadingProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAiManagementProvider).isLoading;
});

final hasAiManagementErrorProvider = Provider<bool>((ref) {
  return ref.watch(unifiedAiManagementProvider).hasError;
});

/// 家族Provider - 特定提供商
final specificProviderProvider = Provider.family<AiProvider?, String>((ref, providerId) {
  final providers = ref.watch(aiProvidersProvider);
  return providers.where((p) => p.id == providerId).firstOrNull;
});

/// 家族Provider - 特定助手
final specificAssistantProvider = Provider.family<AiAssistant?, String>((ref, assistantId) {
  final assistants = ref.watch(aiAssistantsProvider);
  return assistants.where((a) => a.id == assistantId).firstOrNull;
});

/// 家族Provider - 兼容的提供商
final compatibleProvidersProvider = Provider.family<List<AiProvider>, AiAssistant>((ref, assistant) {
  final state = ref.watch(unifiedAiManagementProvider);
  return state.getCompatibleProviders(assistant);
});

/// 家族Provider - 兼容的助手
final compatibleAssistantsProvider = Provider.family<List<AiAssistant>, AiProvider>((ref, provider) {
  final state = ref.watch(unifiedAiManagementProvider);
  return state.getCompatibleAssistants(provider);
});

/// 家族Provider - 支持特定能力的模型
final modelsWithCapabilityProvider = Provider.family<List<AiModel>, bool Function(ModelCapabilities)>((ref, capabilityCheck) {
  final configuration = ref.watch(aiConfigurationProvider);
  final providers = ref.watch(aiProvidersProvider);
  return configuration.getModelsWithCapability(providers, capabilityCheck);
});

/// 家族Provider - 视觉模型
final visionModelsProvider = Provider<List<AiModel>>((ref) {
  final configuration = ref.watch(aiConfigurationProvider);
  final providers = ref.watch(aiProvidersProvider);
  return configuration.getVisionModels(providers);
});

/// 家族Provider - 工具模型
final toolModelsProvider = Provider<List<AiModel>>((ref) {
  final configuration = ref.watch(aiConfigurationProvider);
  final providers = ref.watch(aiProvidersProvider);
  return configuration.getToolModels(providers);
});

/// 家族Provider - TTS模型
final ttsModelsProvider = Provider<List<AiModel>>((ref) {
  final configuration = ref.watch(aiConfigurationProvider);
  final providers = ref.watch(aiProvidersProvider);
  return configuration.getTTSModels(providers);
});

/// 家族Provider - 推理模型
final reasoningModelsProvider = Provider<List<AiModel>>((ref) {
  final configuration = ref.watch(aiConfigurationProvider);
  final providers = ref.watch(aiProvidersProvider);
  return configuration.getReasoningModels(providers);
});

/// 家族Provider - 提供商连接状态
final providerConnectionStatusProvider = Provider.family<ProviderConnectionStatus?, String>((ref, providerId) {
  final configuration = ref.watch(aiConfigurationProvider);
  return configuration.connectionStatuses[providerId];
});

/// 家族Provider - 模型能力
final modelCapabilitiesProvider = Provider.family<ModelCapabilities?, String>((ref, modelName) {
  final configuration = ref.watch(aiConfigurationProvider);
  return configuration.modelCapabilities[modelName];
});

/// 家族Provider - 模型兼容性检查
final modelCompatibilityProvider = Provider.family<bool, ({AiModel model, AiAssistant assistant})>((ref, params) {
  final configuration = ref.watch(aiConfigurationProvider);
  return configuration.isModelCompatibleWithAssistant(params.model, params.assistant);
});

/// 家族Provider - 模型能力评分
final modelCapabilityScoreProvider = Provider.family<int, String>((ref, modelName) {
  final configuration = ref.watch(aiConfigurationProvider);
  return configuration.getModelCapabilityScore(modelName);
});

/// 便捷操作Provider - 管理器操作
final aiManagementActionsProvider = Provider<UnifiedAiManagementNotifier>((ref) {
  return ref.read(unifiedAiManagementProvider.notifier);
});

/// 便捷操作Provider - 添加自定义提供商
final addCustomProviderProvider = Provider<Future<void> Function({
  required String name,
  required String apiKey,
  required String baseUrl,
  ConfigTemplate? template,
})>((ref) {
  final notifier = ref.read(unifiedAiManagementProvider.notifier);
  return notifier.addCustomProvider;
});

/// 便捷操作Provider - 创建自定义助手
final createCustomAssistantProvider = Provider<Future<void> Function({
  required String name,
  required String systemPrompt,
  String? description,
  bool streamOutput,
  bool supportsVision,
  bool supportsTools,
})>((ref) {
  final notifier = ref.read(unifiedAiManagementProvider.notifier);
  return notifier.createCustomAssistant;
});

/// 事件流Provider - AI管理事件
final aiManagementEventStreamProvider = StreamProvider<AiManagementEvent>((ref) {
  final controller = StreamController<AiManagementEvent>();
  
  // 监听事件变化
  ref.listen(aiManagementEventProvider, (previous, next) {
    if (next != null && next != previous) {
      controller.add(next);
    }
  });
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});


