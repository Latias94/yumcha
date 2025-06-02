import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_assistant.dart';
import '../models/ai_provider.dart';
import '../models/ai_model.dart';
import '../models/chat_configuration.dart';
import '../services/preference_service.dart';
import '../services/assistant_repository.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';

/// 聊天配置状态
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
      selectedAssistant != null && selectedProvider != null && selectedModel != null;

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
}

/// 聊天配置状态管理器
class ChatConfigurationNotifier extends StateNotifier<ChatConfigurationState> {
  ChatConfigurationNotifier() : super(const ChatConfigurationState()) {
    _initialize();
  }

  late final PreferenceService _preferenceService;
  late final AssistantRepository _assistantRepository;
  late final ProviderRepository _providerRepository;

  /// 初始化
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      _preferenceService = PreferenceService();
      _assistantRepository = AssistantRepository(DatabaseService.instance.database);
      _providerRepository = ProviderRepository(DatabaseService.instance.database);
      
      await _loadLastConfiguration();
    } catch (e) {
      state = state.copyWith(error: '初始化失败: $e', isLoading: false);
    }
  }

  /// 加载上次使用的配置
  Future<void> _loadLastConfiguration() async {
    try {
      // 1. 加载上次使用的助手
      final lastUsedAssistantId = await _preferenceService.getLastUsedAssistantId();
      AiAssistant? assistant;
      
      if (lastUsedAssistantId != null) {
        assistant = await _assistantRepository.getAssistant(lastUsedAssistantId);
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
        provider = await _providerRepository.getProvider(lastUsedModel['providerId']!);
        if (provider != null) {
          model = provider.models
              .where((m) => m.name == lastUsedModel['modelName'])
              .firstOrNull;
        }
      }
      
      // 如果没有找到，使用第一个可用的提供商和模型
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

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 聊天配置状态提供者
final chatConfigurationProvider = StateNotifierProvider<ChatConfigurationNotifier, ChatConfigurationState>(
  (ref) => ChatConfigurationNotifier(),
);
