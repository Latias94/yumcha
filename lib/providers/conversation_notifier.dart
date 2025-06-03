import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_ui_state.dart';
import '../models/ai_assistant.dart';
import '../models/message.dart';
import '../services/conversation_repository.dart';
import '../services/assistant_repository.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';
import '../services/ai_service.dart';
import 'ai_provider_notifier.dart';
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
  CurrentConversationNotifier(this.ref)
    : super(const CurrentConversationState()) {
    _initialize();
  }

  final Ref ref;

  late final ConversationRepository _conversationRepository;
  late final AssistantRepository _assistantRepository;
  final _uuid = const Uuid();
  final LoggerService _logger = LoggerService();
  final AiService _aiService = AiService();

  // 记住上次的配置
  String? _lastUsedAssistantId;
  String? _lastUsedProviderId;
  String? _lastUsedModelName;

  // 防抖机制
  DateTime? _lastCreateTime;

  // 标题生成相关
  final Set<String> _titleGenerationInProgress = {};
  static const String _defaultTitle = "新对话";

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
    _logger.info('开始创建新对话');

    // 防抖：如果距离上次创建时间少于500毫秒，忽略请求
    final now = DateTime.now();
    if (_lastCreateTime != null &&
        now.difference(_lastCreateTime!).inMilliseconds < 500) {
      _logger.debug('防抖：忽略重复的创建请求');
      return;
    }
    _lastCreateTime = now;

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

      if (selectedAssistant == null) {
        _logger.error('找不到可用的助手');
        state = state.copyWith(isLoading: false, error: '找不到可用的助手');
        return;
      }

      final newConversation = ConversationUiState(
        id: conversationId,
        channelName: _defaultTitle,
        channelMembers: 1,
        assistantId: selectedAssistant.id,
        selectedProviderId: _lastUsedProviderId ?? '',
        selectedModelId: _lastUsedModelName,
        messages: [],
      );

      state = state.copyWith(
        conversation: newConversation,
        isLoading: false,
        selectedMenu: "new_chat",
      );

      _logger.info('新对话创建成功', {
        'conversationId': newConversation.id,
        'assistantName': selectedAssistant.name,
      });

      // 如果有选中的助手，保存其配置
      await _saveCurrentConfiguration(
        selectedAssistant.id,
        _lastUsedProviderId ?? '',
        _lastUsedModelName ?? '',
      );
    } catch (e) {
      // 创建空白对话作为后备方案
      final fallbackConversation = ConversationUiState(
        id: _uuid.v4(),
        channelName: _defaultTitle,
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
      _logger.info('开始加载对话', {'conversationId': conversationId});
      state = state.copyWith(isLoading: true, error: null);

      final conversation = await _conversationRepository.getConversation(
        conversationId,
      );

      _logger.debug('加载的对话', {
        'channelName': conversation?.channelName,
        'messageCount': conversation?.messages.length,
      });

      if (conversation != null) {
        state = state.copyWith(
          conversation: conversation,
          isLoading: false,
          selectedMenu: conversationId,
        );
        _logger.info('对话加载成功');
      } else {
        _logger.warning('对话不存在', {'conversationId': conversationId});
        state = state.copyWith(isLoading: false, error: '对话不存在');
      }
    } catch (e) {
      _logger.error('加载对话失败', {'error': e.toString()});
      state = state.copyWith(isLoading: false, error: '加载对话失败: $e');
    }
  }

  /// 切换对话
  Future<void> switchToConversation(String chatId) async {
    _logger.debug('switchToConversation 被调用', {
      'chatId': chatId,
      'isLoading': state.isLoading,
    });

    // 防止重复调用
    if (state.isLoading) {
      _logger.debug('正在加载中，忽略请求');
      return;
    }

    // 如果已经是当前对话，不需要重复加载
    if (state.conversation?.id == chatId && chatId != "new_chat") {
      _logger.debug('已经是当前对话，忽略请求');
      return;
    }

    if (chatId == "new_chat") {
      _logger.debug('调用 createNewConversation');
      await createNewConversation();
    } else {
      _logger.debug('调用 loadConversation', {'chatId': chatId});
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

  /// 当 AI 助手成功回复后调用，检查是否需要生成标题
  Future<void> onAiMessageAdded(Message aiMessage) async {
    final conversation = state.conversation;
    if (conversation == null) return;

    _logger.info('AI 消息添加，检查是否需要生成标题', {
      'conversationId': conversation.id,
      'messageCount': conversation.messages.length,
      'currentTitle': conversation.channelName,
    });

    // 检查是否满足标题生成条件
    if (!_shouldGenerateTitle(conversation)) {
      _logger.debug('不满足标题生成条件，跳过');
      return;
    }

    // 异步生成标题，不阻塞主流程
    _generateTitleAsync(conversation);
  }

  /// 检查是否应该生成标题
  bool _shouldGenerateTitle(ConversationUiState conversation) {
    // 1. 话题至少有2条消息（用户消息 + AI回复）
    if (conversation.messages.length < 2) {
      _logger.debug('消息数量不足，需要至少2条消息');
      return false;
    }

    // 2. 话题名称仍是默认名称
    if (conversation.channelName != _defaultTitle) {
      _logger.debug('标题已被修改，不是默认标题');
      return false;
    }

    // 3. 确保有用户消息和AI回复
    final hasUserMessage = conversation.messages.any((m) => m.isFromUser);
    final hasAiMessage = conversation.messages.any((m) => !m.isFromUser);

    if (!hasUserMessage || !hasAiMessage) {
      _logger.debug('缺少用户消息或AI回复');
      return false;
    }

    // 4. 检查是否已经在生成标题
    if (_titleGenerationInProgress.contains(conversation.id)) {
      _logger.debug('标题生成已在进行中');
      return false;
    }

    return true;
  }

  /// 异步生成标题
  Future<void> _generateTitleAsync(ConversationUiState conversation) async {
    final conversationId = conversation.id;

    // 标记为正在生成
    _titleGenerationInProgress.add(conversationId);

    try {
      _logger.info('开始异步生成标题', {'conversationId': conversationId});

      // 获取提供商和模型信息
      final providerId = conversation.selectedProviderId;
      final modelId = conversation.selectedModelId;

      if (providerId.isEmpty || modelId == null || modelId.isEmpty) {
        _logger.warning('缺少提供商或模型信息，无法生成标题', {
          'providerId': providerId,
          'modelId': modelId,
        });
        return;
      }

      // 通过 provider notifier 获取提供商对象
      final provider = ref.read(aiProviderProvider(providerId));
      if (provider == null) {
        _logger.warning('无法获取提供商信息，无法生成标题', {'providerId': providerId});
        return;
      }

      // 调用 AI 服务生成标题
      final generatedTitle = await _aiService.generateChatTitle(
        provider: provider,
        modelName: modelId,
        messages: conversation.messages,
      );

      // 检查当前对话是否仍然是我们要更新的对话
      final currentConversation = state.conversation;
      if (currentConversation?.id != conversationId) {
        _logger.debug('对话已切换，取消标题更新');
        return;
      }

      // 检查标题是否仍然是默认标题（用户可能已经手动修改）
      if (currentConversation?.channelName != _defaultTitle) {
        _logger.debug('标题已被用户修改，取消自动更新');
        return;
      }

      if (generatedTitle != null && generatedTitle.isNotEmpty) {
        _logger.info('标题生成成功', {
          'conversationId': conversationId,
          'title': generatedTitle,
        });

        // 更新对话标题
        final updatedConversation = currentConversation!.copyWith(
          channelName: generatedTitle,
        );

        // 更新状态
        state = state.copyWith(conversation: updatedConversation);

        // 保存到数据库
        await _saveConversationIfNeeded(updatedConversation);
      } else {
        _logger.warning('标题生成失败或返回空标题');
      }
    } catch (e) {
      _logger.error('标题生成异常', {
        'conversationId': conversationId,
        'error': e.toString(),
      });
    } finally {
      // 移除生成中标记
      _titleGenerationInProgress.remove(conversationId);
    }
  }
}

/// 当前对话状态Provider
final currentConversationProvider =
    StateNotifierProvider<
      CurrentConversationNotifier,
      CurrentConversationState
    >((ref) => CurrentConversationNotifier(ref));
