import 'package:flutter/foundation.dart';
import 'ai_provider.dart';
import 'ai_assistant.dart';
import 'ai_model.dart';
import 'unified_ai_management_state.dart';

/// 用户AI配置状态
@immutable
class UserAiConfiguration {
  final AiAssistant? selectedAssistant;
  final AiProvider? selectedProvider;
  final AiModel? selectedModel;
  final Map<String, ProviderConnectionStatus> connectionStatuses;
  final Map<String, ModelCapabilities> modelCapabilities;  // 模型能力映射
  final List<String> favoriteProviderIds;
  final List<String> favoriteAssistantIds;
  final List<String> favoriteModelIds;
  final UserConfigPreferences preferences;
  final DateTime? lastConfigBackup;
  final Map<String, DateTime> lastConnectionTests;
  final Map<String, DateTime> lastCapabilityUpdates;  // 能力更新时间

  const UserAiConfiguration({
    this.selectedAssistant,
    this.selectedProvider,
    this.selectedModel,
    this.connectionStatuses = const {},
    this.modelCapabilities = const {},
    this.favoriteProviderIds = const [],
    this.favoriteAssistantIds = const [],
    this.favoriteModelIds = const [],
    this.preferences = const UserConfigPreferences(),
    this.lastConfigBackup,
    this.lastConnectionTests = const {},
    this.lastCapabilityUpdates = const {},
  });

  /// 检查当前配置是否有效
  bool get isValid =>
      selectedAssistant != null &&
      selectedProvider != null &&
      selectedModel != null &&
      _isProviderConnected;

  bool get _isProviderConnected =>
      selectedProvider != null &&
      connectionStatuses[selectedProvider!.id] == ProviderConnectionStatus.connected;

  /// 检查是否需要备份配置
  bool get needsBackup {
    if (!preferences.enableConfigBackup) return false;
    if (lastConfigBackup == null) return true;
    return DateTime.now().difference(lastConfigBackup!).inDays > 7;
  }

  /// 获取需要测试连接的提供商
  List<String> getProvidersNeedingTest(List<AiProvider> providers) {
    if (!preferences.autoTestConnection) return [];

    return providers
        .where((p) => p.isEnabled)
        .where((p) {
          final lastTest = lastConnectionTests[p.id];
          if (lastTest == null) return true;
          return DateTime.now().difference(lastTest).inHours > 1;
        })
        .map((p) => p.id)
        .toList();
  }

  /// 获取支持特定能力的模型
  List<AiModel> getModelsWithCapability(
    List<AiProvider> providers,
    bool Function(ModelCapabilities) capabilityCheck,
  ) {
    final models = <AiModel>[];
    for (final provider in providers) {
      for (final model in provider.models) {
        final capabilities = modelCapabilities[model.name];
        if (capabilities != null && capabilityCheck(capabilities)) {
          models.add(model);
        }
      }
    }
    return models;
  }

  /// 获取支持视觉的模型
  List<AiModel> getVisionModels(List<AiProvider> providers) {
    return getModelsWithCapability(
      providers,
      (capabilities) => capabilities.supportsVision,
    );
  }

  /// 获取支持工具调用的模型
  List<AiModel> getToolModels(List<AiProvider> providers) {
    return getModelsWithCapability(
      providers,
      (capabilities) => capabilities.supportsTools,
    );
  }

  /// 获取支持TTS的模型
  List<AiModel> getTTSModels(List<AiProvider> providers) {
    return getModelsWithCapability(
      providers,
      (capabilities) => capabilities.supportsTTS,
    );
  }

  /// 获取支持推理的模型
  List<AiModel> getReasoningModels(List<AiProvider> providers) {
    return getModelsWithCapability(
      providers,
      (capabilities) => capabilities.supportsReasoning,
    );
  }

  /// 检查模型是否满足助手需求
  bool isModelCompatibleWithAssistant(AiModel model, AiAssistant assistant) {
    final capabilities = modelCapabilities[model.name];
    if (capabilities == null) return false;

    // 检查基础能力
    if (!capabilities.supportsChat) return false;

    // 检查流式输出需求
    if (assistant.streamOutput && !capabilities.supportsStreaming) return false;

    // 检查视觉需求
    if (assistant.enableVision && !capabilities.supportsVision) return false;

    // 检查工具调用需求
    if (assistant.enableTools && !capabilities.supportsTools) return false;

    return true;
  }

  /// 获取模型能力评分
  int getModelCapabilityScore(String modelName) {
    final capabilities = modelCapabilities[modelName];
    return capabilities?.capabilityScore ?? 0;
  }

  UserAiConfiguration copyWith({
    AiAssistant? selectedAssistant,
    AiProvider? selectedProvider,
    AiModel? selectedModel,
    Map<String, ProviderConnectionStatus>? connectionStatuses,
    Map<String, ModelCapabilities>? modelCapabilities,
    List<String>? favoriteProviderIds,
    List<String>? favoriteAssistantIds,
    List<String>? favoriteModelIds,
    UserConfigPreferences? preferences,
    DateTime? lastConfigBackup,
    Map<String, DateTime>? lastConnectionTests,
    Map<String, DateTime>? lastCapabilityUpdates,
  }) {
    return UserAiConfiguration(
      selectedAssistant: selectedAssistant ?? this.selectedAssistant,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      selectedModel: selectedModel ?? this.selectedModel,
      connectionStatuses: connectionStatuses ?? this.connectionStatuses,
      modelCapabilities: modelCapabilities ?? this.modelCapabilities,
      favoriteProviderIds: favoriteProviderIds ?? this.favoriteProviderIds,
      favoriteAssistantIds: favoriteAssistantIds ?? this.favoriteAssistantIds,
      favoriteModelIds: favoriteModelIds ?? this.favoriteModelIds,
      preferences: preferences ?? this.preferences,
      lastConfigBackup: lastConfigBackup ?? this.lastConfigBackup,
      lastConnectionTests: lastConnectionTests ?? this.lastConnectionTests,
      lastCapabilityUpdates: lastCapabilityUpdates ?? this.lastCapabilityUpdates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedAssistantId': selectedAssistant?.id,
      'selectedProviderId': selectedProvider?.id,
      'selectedModelId': selectedModel?.id,
      'connectionStatuses': connectionStatuses.map((k, v) => MapEntry(k, v.name)),
      'modelCapabilities': modelCapabilities.map((k, v) => MapEntry(k, v.toJson())),
      'favoriteProviderIds': favoriteProviderIds,
      'favoriteAssistantIds': favoriteAssistantIds,
      'favoriteModelIds': favoriteModelIds,
      'preferences': preferences.toJson(),
      'lastConfigBackup': lastConfigBackup?.toIso8601String(),
      'lastConnectionTests': lastConnectionTests.map((k, v) => MapEntry(k, v.toIso8601String())),
      'lastCapabilityUpdates': lastCapabilityUpdates.map((k, v) => MapEntry(k, v.toIso8601String())),
    };
  }

  factory UserAiConfiguration.fromJson(Map<String, dynamic> json) {
    return UserAiConfiguration(
      // 注意：这里只保存ID，实际的对象需要从Repository中获取
      connectionStatuses: (json['connectionStatuses'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, ProviderConnectionStatus.values.byName(v))),
      modelCapabilities: (json['modelCapabilities'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, ModelCapabilities.fromJson(v))),
      favoriteProviderIds: List<String>.from(json['favoriteProviderIds'] ?? []),
      favoriteAssistantIds: List<String>.from(json['favoriteAssistantIds'] ?? []),
      favoriteModelIds: List<String>.from(json['favoriteModelIds'] ?? []),
      preferences: json['preferences'] != null
          ? UserConfigPreferences.fromJson(json['preferences'])
          : const UserConfigPreferences(),
      lastConfigBackup: json['lastConfigBackup'] != null
          ? DateTime.parse(json['lastConfigBackup'])
          : null,
      lastConnectionTests: (json['lastConnectionTests'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, DateTime.parse(v))),
      lastCapabilityUpdates: (json['lastCapabilityUpdates'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, DateTime.parse(v))),
    );
  }
}
