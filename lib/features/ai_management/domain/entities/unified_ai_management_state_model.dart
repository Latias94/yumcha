import 'package:flutter/foundation.dart';
import 'ai_provider.dart';
import 'ai_assistant.dart';
import 'ai_model.dart';
import 'unified_ai_management_state.dart';
import 'user_ai_configuration.dart';

/// 统一AI管理状态
@immutable
class UnifiedAiManagementState {
  final List<AiProvider> providers;
  final List<AiAssistant> assistants;
  final UserAiConfiguration configuration;
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final AiManagementEvent? lastEvent;
  final Map<String, ConfigTemplate> availableTemplates;

  const UnifiedAiManagementState({
    this.providers = const [],
    this.assistants = const [],
    this.configuration = const UserAiConfiguration(),
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.lastEvent,
    this.availableTemplates = const {},
  });

  /// 获取用户的提供商（包括自定义的）
  List<AiProvider> get userProviders => providers;

  /// 获取用户的助手（包括自定义的）
  List<AiAssistant> get userAssistants => assistants;

  /// 获取收藏的提供商
  List<AiProvider> get favoriteProviders =>
      providers.where((p) => configuration.favoriteProviderIds.contains(p.id)).toList();

  /// 获取收藏的助手
  List<AiAssistant> get favoriteAssistants =>
      assistants.where((a) => configuration.favoriteAssistantIds.contains(a.id)).toList();

  /// 获取已连接的提供商
  List<AiProvider> get connectedProviders =>
      providers.where((p) =>
          configuration.connectionStatuses[p.id] == ProviderConnectionStatus.connected
      ).toList();

  /// 获取启用的提供商
  List<AiProvider> get enabledProviders =>
      providers.where((p) => p.isEnabled).toList();

  /// 获取启用的助手
  List<AiAssistant> get enabledAssistants =>
      assistants.where((a) => a.isEnabled).toList();

  /// 检查是否有配置需要备份
  bool get needsConfigBackup => configuration.needsBackup;

  /// 检查是否有完整的配置
  bool get hasCompleteConfiguration => configuration.isValid;

  /// 获取当前选择的配置信息
  ({AiAssistant? assistant, AiProvider? provider, AiModel? model}) get currentSelection => (
    assistant: configuration.selectedAssistant,
    provider: configuration.selectedProvider,
    model: configuration.selectedModel,
  );

  /// 获取可用的模板列表
  List<ConfigTemplate> get availableTemplatesList => availableTemplates.values.toList();

  /// 检查是否有错误
  bool get hasError => error != null;

  /// 检查是否正在加载
  bool get isLoadingData => isLoading;

  /// 获取提供商统计信息
  ({int total, int enabled, int connected}) get providerStats {
    final total = providers.length;
    final enabled = enabledProviders.length;
    final connected = connectedProviders.length;
    return (total: total, enabled: enabled, connected: connected);
  }

  /// 获取助手统计信息
  ({int total, int enabled, int custom}) get assistantStats {
    final total = assistants.length;
    final enabled = enabledAssistants.length;
    // 暂时使用ID前缀判断是否为自定义助手
    final custom = assistants.where((a) => a.id.startsWith('custom_')).length;
    return (total: total, enabled: enabled, custom: custom);
  }

  /// 获取支持特定能力的提供商
  List<AiProvider> getProvidersWithCapability(bool Function(ModelCapabilities) capabilityCheck) {
    return providers.where((provider) {
      return provider.models.any((model) {
        final capabilities = configuration.modelCapabilities[model.name];
        return capabilities != null && capabilityCheck(capabilities);
      });
    }).toList();
  }

  /// 获取支持视觉的提供商
  List<AiProvider> get visionProviders => getProvidersWithCapability(
    (capabilities) => capabilities.supportsVision,
  );

  /// 获取支持工具调用的提供商
  List<AiProvider> get toolProviders => getProvidersWithCapability(
    (capabilities) => capabilities.supportsTools,
  );

  /// 获取支持TTS的提供商
  List<AiProvider> get ttsProviders => getProvidersWithCapability(
    (capabilities) => capabilities.supportsTTS,
  );

  /// 获取支持推理的提供商
  List<AiProvider> get reasoningProviders => getProvidersWithCapability(
    (capabilities) => capabilities.supportsReasoning,
  );

  /// 根据助手需求获取兼容的提供商
  List<AiProvider> getCompatibleProviders(AiAssistant assistant) {
    return providers.where((provider) {
      return provider.models.any((model) {
        return configuration.isModelCompatibleWithAssistant(model, assistant);
      });
    }).toList();
  }

  /// 根据提供商获取兼容的助手
  List<AiAssistant> getCompatibleAssistants(AiProvider provider) {
    return assistants.where((assistant) {
      return provider.models.any((model) {
        return configuration.isModelCompatibleWithAssistant(model, assistant);
      });
    }).toList();
  }

  UnifiedAiManagementState copyWith({
    List<AiProvider>? providers,
    List<AiAssistant>? assistants,
    UserAiConfiguration? configuration,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    AiManagementEvent? lastEvent,
    Map<String, ConfigTemplate>? availableTemplates,
  }) {
    return UnifiedAiManagementState(
      providers: providers ?? this.providers,
      assistants: assistants ?? this.assistants,
      configuration: configuration ?? this.configuration,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      lastEvent: lastEvent ?? this.lastEvent,
      availableTemplates: availableTemplates ?? this.availableTemplates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedAiManagementState &&
        _listEquals(other.providers, providers) &&
        _listEquals(other.assistants, assistants) &&
        other.configuration == configuration &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.error == error &&
        other.lastEvent == lastEvent &&
        _mapEquals(other.availableTemplates, availableTemplates);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(providers),
      Object.hashAll(assistants),
      configuration,
      isLoading,
      isInitialized,
      error,
      lastEvent,
      Object.hashAll(availableTemplates.entries),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
