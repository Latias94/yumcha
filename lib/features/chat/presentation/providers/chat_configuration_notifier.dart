import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../../ai_management/domain/entities/ai_model.dart';
import '../../domain/entities/chat_configuration.dart';
import '../../../../shared/infrastructure/services/preference_service.dart';
import '../../../ai_management/data/repositories/assistant_repository.dart';
import '../../../ai_management/data/repositories/provider_repository.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../ai_management/presentation/providers/unified_ai_management_providers.dart';

/// 聊天配置状态数据模型 - 包含助手、提供商、模型的选择状态
class ChatConfigurationState {
  final AiAssistant? selectedAssistant;
  final AiProvider? selectedProvider;
  final AiModel? selectedModel;
  final bool isLoading;
  final String? error;

  const ChatConfigurationState({
    this.selectedAssistant,
    this.selectedProvider,
    this.selectedModel,
    this.isLoading = false,
    this.error,
  });

  ChatConfigurationState copyWith({
    AiAssistant? selectedAssistant,
    AiProvider? selectedProvider,
    AiModel? selectedModel,
    bool? isLoading,
    String? error,
  }) {
    return ChatConfigurationState(
      selectedAssistant: selectedAssistant ?? this.selectedAssistant,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      selectedModel: selectedModel ?? this.selectedModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 检查是否有完整的聊天配置
  bool get hasCompleteConfiguration =>
      selectedAssistant != null &&
      selectedProvider != null &&
      selectedModel != null;

  /// 获取聊天配置（如果完整）
  ChatConfiguration? get chatConfiguration {
    if (hasCompleteConfiguration) {
      return ChatConfiguration(
        assistant: selectedAssistant!,
        provider: selectedProvider!,
        model: selectedModel!,
      );
    }
    return null;
  }

  /// 获取默认配置信息（用于新建对话等场景）
  ({String? providerId, String? modelName, String? assistantId})
      get defaultConfiguration {
    return (
      providerId: selectedProvider?.id,
      modelName: selectedModel?.name,
      assistantId: selectedAssistant?.id,
    );
  }
}

/// 聊天配置状态管理器 - 管理助手、提供商、模型的选择，支持配置恢复和持久化
class ChatConfigurationNotifier extends StateNotifier<ChatConfigurationState> {
  ChatConfigurationNotifier(this._ref) : super(const ChatConfigurationState()) {
    _initialize();
    _setupListeners();
  }

  final Ref _ref;

  /// 获取服务实例
  PreferenceService get _preferenceService =>
      _ref.read(preferenceServiceProvider);
  AssistantRepository get _assistantRepository =>
      _ref.read(assistantRepositoryProvider);
  ProviderRepository get _providerRepository =>
      _ref.read(providerRepositoryProvider);

  /// 初始化
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await _loadLastConfiguration();
    } catch (e) {
      state = state.copyWith(error: '初始化失败: $e', isLoading: false);
    }
  }

  /// 加载上次使用的配置
  Future<void> _loadLastConfiguration() async {
    try {
      // 1. 加载上次使用的助手
      final lastUsedAssistantId =
          await _preferenceService.getLastUsedAssistantId();
      AiAssistant? assistant;

      if (lastUsedAssistantId != null) {
        assistant = await _assistantRepository.getAssistant(
          lastUsedAssistantId,
        );
      }

      // 如果没有找到，使用第一个可用的助手
      if (assistant == null) {
        final assistants = await _assistantRepository.getEnabledAssistants();
        if (assistants.isNotEmpty) {
          assistant = assistants.first;
        }
      }

      // 2. 加载上次使用的模型
      final lastUsedModel = await _preferenceService.getLastUsedModel();
      AiProvider? provider;
      AiModel? model;

      if (lastUsedModel != null) {
        provider = await _providerRepository.getProvider(
          lastUsedModel['providerId']!,
        );
        if (provider != null) {
          model = provider.models
              .where((m) => m.name == lastUsedModel['modelName'])
              .firstOrNull;
        }
      }

      // 如果没有找到，尝试从设置获取默认模型
      if (provider == null || model == null) {
        final settingsState = _ref.read(settingsNotifierProvider);
        if (!settingsState.isLoading) {
          final defaultChatModel = _ref
              .read(settingsNotifierProvider.notifier)
              .getDefaultChatModel();

          if (defaultChatModel?.providerId != null &&
              defaultChatModel?.modelName != null) {
            provider = await _providerRepository.getProvider(
              defaultChatModel!.providerId!,
            );
            if (provider != null) {
              model = provider.models
                  .where((m) => m.name == defaultChatModel.modelName!)
                  .firstOrNull;
            }
          }
        }
      }

      // 如果仍然没有找到，使用第一个可用的提供商和模型
      if (provider == null || model == null) {
        final providers = await _providerRepository.getEnabledProviders();
        if (providers.isNotEmpty) {
          provider = providers.first;
          if (provider.models.isNotEmpty) {
            model = provider.models.first;
          }
        }
      }

      state = state.copyWith(
        selectedAssistant: assistant,
        selectedProvider: provider,
        selectedModel: model,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: '加载配置失败: $e', isLoading: false);
    }
  }

  /// 选择助手
  Future<void> selectAssistant(AiAssistant assistant) async {
    state = state.copyWith(selectedAssistant: assistant);
    await _preferenceService.saveLastUsedAssistantId(assistant.id);
  }

  /// 选择模型
  Future<void> selectModel(ModelSelection selection) async {
    state = state.copyWith(
      selectedProvider: selection.provider,
      selectedModel: selection.model,
    );

    await _preferenceService.saveLastUsedModel(
      selection.provider.id,
      selection.model.name,
    );
  }

  /// 刷新配置
  Future<void> refresh() async {
    await _loadLastConfiguration();
  }

  /// 强制刷新配置（用于设置更改后）
  Future<void> forceRefresh() async {
    state = state.copyWith(isLoading: true);
    await _loadLastConfiguration();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 设置监听器 - 监听提供商和助手的变化
  void _setupListeners() {
    // 监听提供商变化 - 使用新的统一AI管理Provider
    _ref.listen(aiProvidersProvider, (previous, next) {
      _handleProvidersChanged(previous, next);
    });

    // 监听助手变化 - 使用新的统一AI管理Provider
    _ref.listen(aiAssistantsProvider, (previous, next) {
      _handleAssistantsChanged(previous, next);
    });
  }

  /// 处理提供商变化
  void _handleProvidersChanged(
    List<AiProvider>? previous,
    List<AiProvider> next,
  ) {
    // 只在数据真正变化时处理
    if (previous != next) {
      _validateCurrentProviderAndModel();
    }
  }

  /// 处理助手变化
  void _handleAssistantsChanged(
    List<AiAssistant>? previous,
    List<AiAssistant> next,
  ) {
    // 只在数据真正变化时处理
    if (previous != next) {
      _validateCurrentAssistant();
    }
  }

  /// 验证当前选择的提供商和模型是否仍然有效
  void _validateCurrentProviderAndModel() {
    final currentProvider = state.selectedProvider;
    final currentModel = state.selectedModel;

    if (currentProvider == null || currentModel == null) return;

    // 获取最新的提供商列表 - 使用新的统一AI管理Provider
    final providers = _ref.read(aiProvidersProvider);

    // 检查当前提供商是否仍然存在且启用
    final updatedProvider = providers
        .where((p) => p.id == currentProvider.id && p.isEnabled)
        .firstOrNull;

    if (updatedProvider == null) {
      // 提供商不存在或被禁用，重新选择
      _selectFallbackProviderAndModel(providers);
      return;
    }

    // 检查当前模型是否仍然存在
    final updatedModel = updatedProvider.models
        .where((m) => m.name == currentModel.name)
        .firstOrNull;

    if (updatedModel == null) {
      // 模型不存在，选择该提供商的第一个模型
      if (updatedProvider.models.isNotEmpty) {
        state = state.copyWith(
          selectedProvider: updatedProvider,
          selectedModel: updatedProvider.models.first,
        );
      } else {
        // 提供商没有模型，重新选择
        _selectFallbackProviderAndModel(providers);
      }
      return;
    }

    // 始终更新为最新的提供商和模型数据，确保API密钥等信息是最新的
    state = state.copyWith(
      selectedProvider: updatedProvider,
      selectedModel: updatedModel,
    );
  }

  /// 验证当前选择的助手是否仍然有效
  void _validateCurrentAssistant() {
    final currentAssistant = state.selectedAssistant;
    if (currentAssistant == null) return;

    // 获取最新的助手列表 - 使用新的统一AI管理Provider
    final assistants = _ref.read(aiAssistantsProvider);

    // 检查当前助手是否仍然存在且启用
    final updatedAssistant = assistants
        .where((a) => a.id == currentAssistant.id && a.isEnabled)
        .firstOrNull;

    if (updatedAssistant == null) {
      // 助手不存在或被禁用，选择第一个可用的助手
      final enabledAssistants = assistants.where((a) => a.isEnabled).toList();
      if (enabledAssistants.isNotEmpty) {
        state = state.copyWith(selectedAssistant: enabledAssistants.first);
      } else {
        state = state.copyWith(selectedAssistant: null);
      }
      return;
    }

    // 更新为最新的助手数据
    state = state.copyWith(selectedAssistant: updatedAssistant);
  }

  /// 选择备用的提供商和模型
  void _selectFallbackProviderAndModel(List<AiProvider> providers) {
    final enabledProviders = providers.where((p) => p.isEnabled).toList();
    if (enabledProviders.isNotEmpty) {
      final fallbackProvider = enabledProviders.first;
      if (fallbackProvider.models.isNotEmpty) {
        state = state.copyWith(
          selectedProvider: fallbackProvider,
          selectedModel: fallbackProvider.models.first,
        );
      } else {
        state = state.copyWith(
          selectedProvider: null,
          selectedModel: null,
        );
      }
    } else {
      state = state.copyWith(
        selectedProvider: null,
        selectedModel: null,
      );
    }
  }
}

/// 聊天配置状态提供者
final chatConfigurationProvider =
    StateNotifierProvider<ChatConfigurationNotifier, ChatConfigurationState>(
  (ref) => ChatConfigurationNotifier(ref),
);
