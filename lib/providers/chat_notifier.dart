import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/ai_provider.dart';
import '../models/ai_assistant.dart';
import '../services/ai_service.dart';
import '../services/preference_service.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';

/// 聊天状态
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final String? selectedProviderId;
  final String? selectedAssistantId;
  final String? selectedModelName;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedProviderId,
    this.selectedAssistantId,
    this.selectedModelName,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    String? selectedProviderId,
    String? selectedAssistantId,
    String? selectedModelName,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedProviderId: selectedProviderId ?? this.selectedProviderId,
      selectedAssistantId: selectedAssistantId ?? this.selectedAssistantId,
      selectedModelName: selectedModelName ?? this.selectedModelName,
    );
  }
}

/// 聊天状态管理类
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _initializeDefaults();
  }

  final AiService _aiService = AiService();
  final PreferenceService _preferenceService = PreferenceService();

  /// 初始化默认配置
  Future<void> _initializeDefaults() async {
    // 如果已经有选择的模型，就不需要初始化
    if (state.selectedModelName != null &&
        state.selectedModelName!.isNotEmpty) {
      return;
    }

    try {
      // 尝试获取最后使用的模型
      final lastUsedModel = await _preferenceService.getLastUsedModel();
      if (lastUsedModel != null) {
        // 验证最后使用的模型是否仍然可用
        final isValid = await _validateModelConfiguration(
          lastUsedModel['providerId']!,
          lastUsedModel['modelName']!,
        );

        if (isValid) {
          state = state.copyWith(
            selectedProviderId: lastUsedModel['providerId'],
            selectedModelName: lastUsedModel['modelName'],
          );
          return;
        }
      }

      // 如果没有最后使用的模型或者无效，选择第一个可用的模型
      final success = await _selectFirstAvailableModel();
      if (!success) {
        // 如果没有可用的模型，设置错误状态
        state = state.copyWith(error: '没有可用的AI模型配置，请先在设置中配置提供商和模型');
      }
    } catch (e) {
      // 初始化失败时设置错误状态
      state = state.copyWith(error: '模型初始化失败: $e');
    }
  }

  /// 验证模型配置是否有效
  Future<bool> _validateModelConfiguration(
    String providerId,
    String modelName,
  ) async {
    try {
      final providerRepository = ProviderRepository(
        DatabaseService.instance.database,
      );
      final provider = await providerRepository.getProvider(providerId);

      if (provider == null || !provider.isEnabled) {
        return false;
      }

      // 检查模型是否在提供商的模型列表中
      final hasModel = provider.models.any((model) => model.name == modelName);
      if (!hasModel) {
        // 如果没有配置模型，检查是否是默认模型
        final defaultModels = AiProvider.getDefaultModels(provider.type);
        return defaultModels.contains(modelName);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 选择第一个可用的模型
  Future<bool> _selectFirstAvailableModel() async {
    try {
      final providerRepository = ProviderRepository(
        DatabaseService.instance.database,
      );
      final providers = await providerRepository.getAllProviders();

      // 寻找第一个启用的提供商
      final enabledProvider = providers.where((p) => p.isEnabled).firstOrNull;
      if (enabledProvider != null) {
        // 获取提供商的第一个模型
        String? firstModel;
        if (enabledProvider.models.isNotEmpty) {
          firstModel = enabledProvider.models.first.name;
        } else {
          // 使用默认模型
          final defaultModels = AiProvider.getDefaultModels(
            enabledProvider.type,
          );
          if (defaultModels.isNotEmpty) {
            firstModel = defaultModels.first;
          }
        }

        if (firstModel != null) {
          state = state.copyWith(
            selectedProviderId: enabledProvider.id,
            selectedModelName: firstModel,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 设置选中的提供商
  void setSelectedProvider(String providerId) {
    state = state.copyWith(selectedProviderId: providerId);
  }

  /// 设置选中的助手
  void setSelectedAssistant(String assistantId) {
    state = state.copyWith(selectedAssistantId: assistantId);
  }

  /// 设置选中的模型
  void setSelectedModel(String modelName) {
    state = state.copyWith(selectedModelName: modelName);

    // 保存最后使用的模型到偏好设置
    if (state.selectedProviderId != null) {
      _preferenceService.saveLastUsedModel(
        state.selectedProviderId!,
        modelName,
      );
    }
  }

  /// 同时设置提供商和模型
  void setProviderAndModel(String providerId, String modelName) {
    state = state.copyWith(
      selectedProviderId: providerId,
      selectedModelName: modelName,
    );

    // 保存到偏好设置
    _preferenceService.saveLastUsedModel(providerId, modelName);
  }

  /// 确保有有效的模型配置
  Future<void> ensureValidModelConfiguration() async {
    // 如果当前没有选择模型，或者模型无效，则重新初始化
    if (state.selectedModelName == null ||
        state.selectedModelName!.isEmpty ||
        state.selectedProviderId == null ||
        state.selectedProviderId!.isEmpty) {
      await _initializeDefaults();
    } else {
      // 验证当前配置是否仍然有效
      final isValid = await _validateModelConfiguration(
        state.selectedProviderId!,
        state.selectedModelName!,
      );

      if (!isValid) {
        await _initializeDefaults();
      }
    }
  }

  /// 添加消息到聊天历史
  void addMessage(Message message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  /// 清空聊天历史
  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  /// 发送消息
  Future<void> sendMessage(String userMessage) async {
    // 确保有有效的模型配置
    await ensureValidModelConfiguration();

    if (state.selectedAssistantId == null ||
        state.selectedProviderId == null ||
        state.selectedModelName == null) {
      state = state.copyWith(error: '请先选择AI助手、提供商和模型');
      return;
    }

    // 添加用户消息
    final userMsg = Message(
      author: '用户',
      content: userMessage,
      isFromUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(userMsg);

    // 设置加载状态
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 发送请求到AI服务
      final response = await _aiService.sendMessage(
        assistantId: state.selectedAssistantId!,
        chatHistory: state.messages,
        userMessage: userMessage,
        selectedProviderId: state.selectedProviderId!,
        selectedModelName: state.selectedModelName!,
      );

      if (response != null) {
        // 添加AI回复
        final aiMsg = Message(
          author: 'AI助手',
          content: response,
          isFromUser: false,
          timestamp: DateTime.now(),
        );
        addMessage(aiMsg);
      }
    } catch (error) {
      state = state.copyWith(error: error.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 发送流式消息
  Stream<String> sendStreamMessage(String userMessage) async* {
    // 确保有有效的模型配置
    await ensureValidModelConfiguration();

    if (state.selectedAssistantId == null ||
        state.selectedProviderId == null ||
        state.selectedModelName == null) {
      state = state.copyWith(error: '请先选择AI助手、提供商和模型');
      return;
    }

    // 添加用户消息
    final userMsg = Message(
      author: '用户',
      content: userMessage,
      isFromUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(userMsg);

    // 设置加载状态
    state = state.copyWith(isLoading: true, error: null);

    try {
      var fullResponse = '';
      await for (final chunk in _aiService.sendMessageStream(
        assistantId: state.selectedAssistantId!,
        chatHistory: state.messages,
        userMessage: userMessage,
        selectedProviderId: state.selectedProviderId!,
        selectedModelName: state.selectedModelName!,
      )) {
        fullResponse += chunk;
        yield chunk;
      }

      // 完成后添加完整的AI回复到聊天历史
      final aiMsg = Message(
        author: 'AI助手',
        content: fullResponse,
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      addMessage(aiMsg);
    } catch (error) {
      state = state.copyWith(error: error.toString());
      yield '[错误] $error';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 聊天状态Provider
final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);
