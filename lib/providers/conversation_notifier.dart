import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_ui_state.dart';
import '../models/ai_assistant.dart';
import '../services/conversation_repository.dart';
import '../services/assistant_repository.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 当前对话状态
class CurrentConversationState {
  final ConversationUiState? conversation;
  final bool isLoading;
  final String? error;
  final String selectedMenu;

  const CurrentConversationState({
    this.conversation,
    this.isLoading = false,
    this.error,
    this.selectedMenu = "new_chat",
  });

  CurrentConversationState copyWith({
    ConversationUiState? conversation,
    bool? isLoading,
    String? error,
    String? selectedMenu,
  }) {
    return CurrentConversationState(
      conversation: conversation ?? this.conversation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMenu: selectedMenu ?? this.selectedMenu,
    );
  }
}

/// 当前对话状态管理
class CurrentConversationNotifier
    extends StateNotifier<CurrentConversationState> {
  CurrentConversationNotifier() : super(const CurrentConversationState()) {
    _initialize();
  }

  late final ConversationRepository _conversationRepository;
  late final AssistantRepository _assistantRepository;
  final _uuid = const Uuid();

  // 记住上次的配置
  String? _lastUsedAssistantId;
  String? _lastUsedProviderId;
  String? _lastUsedModelName;

  Future<void> _initialize() async {
    _conversationRepository = ConversationRepository(
      DatabaseService.instance.database,
    );
    _assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );

    await _loadLastConfiguration();
  }

  /// 加载上次使用的配置
  Future<void> _loadLastConfiguration() async {
    try {
      state = state.copyWith(isLoading: true);

      final prefs = await SharedPreferences.getInstance();
      _lastUsedAssistantId = prefs.getString('last_assistant_id');
      _lastUsedProviderId = prefs.getString('last_provider_id');
      _lastUsedModelName = prefs.getString('last_model_name');

      // 创建新对话，使用上次的配置
      await createNewConversation();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载配置失败: $e');
      // 如果加载失败，创建默认对话
      await createNewConversation();
    }
  }

  /// 保存当前配置
  Future<void> _saveCurrentConfiguration(
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_assistant_id', assistantId);
      await prefs.setString('last_provider_id', providerId);
      await prefs.setString('last_model_name', modelName);

      _lastUsedAssistantId = assistantId;
      _lastUsedProviderId = providerId;
      _lastUsedModelName = modelName;
    } catch (e) {
      // 保存失败不影响主要功能
    }
  }

  /// 创建新对话
  Future<void> createNewConversation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 生成固定的UUID作为对话ID
      final conversationId = _uuid.v4();

      // 获取所有可用的助手
      final assistants = await _assistantRepository.getAllAssistants();
      final enabledAssistants = assistants.where((a) => a.isEnabled).toList();

      AiAssistant? selectedAssistant;

      // 如果有上次的助手ID，尝试获取助手信息
      if (_lastUsedAssistantId != null) {
        selectedAssistant = assistants
            .where((a) => a.id == _lastUsedAssistantId!)
            .firstOrNull;

        // 如果上次使用的助手已被禁用，选择其他助手
        if (selectedAssistant != null && !selectedAssistant.isEnabled) {
          selectedAssistant = null;
        }
      }

      // 如果没有找到上次的助手，选择默认助手或第一个可用助手
      if (selectedAssistant == null) {
        // 优先选择默认助手
        selectedAssistant = enabledAssistants
            .where((a) => a.id == 'default-assistant')
            .firstOrNull;

        // 如果没有默认助手，选择第一个启用的助手
        selectedAssistant ??= enabledAssistants.isNotEmpty
            ? enabledAssistants.first
            : assistants.firstOrNull;
      }

      final newConversation = ConversationUiState(
        id: conversationId,
        channelName: selectedAssistant != null
            ? "与${selectedAssistant.name}的新对话"
            : "新对话",
        channelMembers: 1,
        assistantId: selectedAssistant?.id ?? '',
        selectedProviderId: _lastUsedProviderId ?? '',
        selectedModelId: _lastUsedModelName,
        messages: [],
      );

      state = state.copyWith(
        conversation: newConversation,
        isLoading: false,
        selectedMenu: "new_chat",
      );

      // 如果有选中的助手，保存其配置
      if (selectedAssistant != null) {
        await _saveCurrentConfiguration(
          selectedAssistant.id,
          _lastUsedProviderId ?? '',
          _lastUsedModelName ?? '',
        );
      }
    } catch (e) {
      // 创建空白对话作为后备方案
      final fallbackConversation = ConversationUiState(
        id: _uuid.v4(),
        channelName: "新对话",
        channelMembers: 1,
        assistantId: '',
        selectedProviderId: '',
        messages: [],
      );

      state = state.copyWith(
        conversation: fallbackConversation,
        isLoading: false,
        error: '创建对话失败: $e',
      );
    }
  }

  /// 加载现有对话
  Future<void> loadConversation(String conversationId) async {
    try {
      print('开始加载对话: $conversationId'); // 调试信息
      state = state.copyWith(isLoading: true, error: null);

      final conversation = await _conversationRepository.getConversation(
        conversationId,
      );

      print(
        '加载的对话: ${conversation?.channelName}, 消息数量: ${conversation?.messages.length}',
      ); // 调试信息

      if (conversation != null) {
        state = state.copyWith(
          conversation: conversation,
          isLoading: false,
          selectedMenu: conversationId,
        );
        print('对话加载成功'); // 调试信息
      } else {
        print('对话不存在: $conversationId'); // 调试信息
        state = state.copyWith(isLoading: false, error: '对话不存在');
      }
    } catch (e) {
      print('加载对话失败: $e'); // 调试信息
      state = state.copyWith(isLoading: false, error: '加载对话失败: $e');
    }
  }

  /// 切换对话
  Future<void> switchToConversation(String chatId) async {
    if (chatId == "new_chat") {
      await createNewConversation();
    } else {
      await loadConversation(chatId);
    }
  }

  /// 更新对话
  void updateConversation(ConversationUiState conversation) {
    state = state.copyWith(conversation: conversation);

    // 如果对话有消息，保存到数据库
    if (conversation.messages.isNotEmpty) {
      _saveConversationIfNeeded(conversation);
    }
  }

  /// 当助手配置改变时调用
  void onAssistantConfigChanged(
    String assistantId,
    String providerId,
    String modelName,
  ) {
    _saveCurrentConfiguration(assistantId, providerId, modelName);
  }

  /// 当对话有内容时，保存到数据库
  Future<void> _saveConversationIfNeeded(
    ConversationUiState conversation,
  ) async {
    try {
      await _conversationRepository.saveConversation(conversation);
    } catch (e) {
      // 保存失败不影响主要功能，但可以记录错误
      state = state.copyWith(error: '保存对话失败: $e');
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 当前对话状态Provider
final currentConversationProvider =
    StateNotifierProvider<
      CurrentConversationNotifier,
      CurrentConversationState
    >((ref) => CurrentConversationNotifier());
