import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../features/chat/domain/entities/message.dart';
import '../../../features/chat/data/repositories/conversation_repository.dart';
import '../../../features/ai_management/data/repositories/assistant_repository.dart';
import '../../infrastructure/services/database_service.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../infrastructure/services/ai/providers/ai_service_provider.dart';
import '../../../features/ai_management/presentation/providers/ai_provider_notifier.dart';
import '../../../features/chat/presentation/providers/chat_configuration_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 当前对话状态数据模型 - 包含当前活跃对话的所有状态信息
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

/// 当前对话状态管理器 - 管理对话创建、切换、标题生成和持久化等核心功能
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

      // 获取默认模型配置
      String? defaultProviderId = _lastUsedProviderId;
      String? defaultModelName = _lastUsedModelName;
      String? defaultAssistantId;

      // 如果没有上次使用的配置，从聊天配置获取默认配置
      if (defaultProviderId == null || defaultModelName == null) {
        final defaultConfig = ref
            .read(chatConfigurationProvider)
            .defaultConfiguration;
        defaultProviderId ??= defaultConfig.providerId;
        defaultModelName ??= defaultConfig.modelName;
        defaultAssistantId = defaultConfig.assistantId;
      }

      final newConversation = ConversationUiState(
        id: conversationId,
        channelName: _defaultTitle,
        channelMembers: 1,
        assistantId: defaultAssistantId ?? selectedAssistant.id,
        selectedProviderId: defaultProviderId ?? '',
        selectedModelId: defaultModelName,
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

    // _logger.info('AI 消息添加，检查是否需要生成标题', {
    //   'conversationId': conversation.id,
    //   'messageCount': conversation.messages.length,
    //   'currentTitle': conversation.channelName,
    // });

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
    await _generateTitleForConversation(
      conversation,
      forceRegenerate: false,
      checkDefaultTitle: true,
    );
  }

  /// 手动重新生成标题
  Future<void> regenerateTitle(String conversationId) async {
    _logger.info('手动重新生成标题', {'conversationId': conversationId});

    // 检查是否已经在生成标题
    if (_titleGenerationInProgress.contains(conversationId)) {
      _logger.debug('标题生成已在进行中，跳过重复请求');
      return;
    }

    try {
      // 获取对话信息
      final conversation = await _conversationRepository.getConversation(
        conversationId,
      );
      if (conversation == null) {
        _logger.warning('找不到对话，无法重新生成标题', {'conversationId': conversationId});
        return;
      }

      // 检查是否有足够的消息
      if (conversation.messages.length < 2) {
        _logger.warning('消息数量不足，无法生成标题', {
          'conversationId': conversationId,
          'messageCount': conversation.messages.length,
        });
        return;
      }

      // 强制重新生成标题（忽略默认标题检查）
      await _generateTitleForConversation(
        conversation,
        forceRegenerate: true,
        checkDefaultTitle: false,
      );
    } catch (e) {
      _logger.error('手动重新生成标题失败', {
        'conversationId': conversationId,
        'error': e.toString(),
      });
    }
  }

  /// 为指定对话生成标题
  Future<void> _generateTitleForConversation(
    ConversationUiState conversation, {
    bool forceRegenerate = false,
    bool checkDefaultTitle = true,
  }) async {
    final conversationId = conversation.id;

    // 标记为正在生成
    _titleGenerationInProgress.add(conversationId);

    try {
      _logger.info('为对话生成标题', {
        'conversationId': conversationId,
        'forceRegenerate': forceRegenerate,
        'checkDefaultTitle': checkDefaultTitle,
      });

      // 如果需要检查默认标题且不是强制重新生成，检查当前标题
      if (checkDefaultTitle && !forceRegenerate) {
        final currentConversation = state.conversation;
        if (currentConversation?.id == conversationId &&
            currentConversation?.channelName != _defaultTitle) {
          _logger.debug('标题已被用户修改，取消自动更新');
          return;
        }
      }

      String? generatedTitle;

      // 使用新AI模块的智能聊天功能生成标题
      try {
        _logger.info('使用新AI模块生成标题');
        generatedTitle = await _generateTitleWithSmartChat(
          conversation.messages,
        );
      } catch (e) {
        _logger.warning('智能聊天生成标题失败', {'error': e.toString()});
        generatedTitle = null;
      }

      // 如果智能聊天生成失败，回退到使用当前对话的模型
      if (generatedTitle == null) {
        _logger.info('智能聊天生成标题失败，回退到当前对话模型');

        // 验证提供商和模型信息
        final validationResult = _validateTitleGenerationRequirements(
          conversation,
        );
        if (!validationResult.isValid) {
          _logger.warning('标题生成验证失败: ${validationResult.errorMessage}');
          return;
        }

        // 使用当前对话的模型生成标题
        generatedTitle = await _generateTitle(
          validationResult.provider!,
          validationResult.modelId!,
          conversation.messages,
          conversation.selectedProviderId,
        );
      }

      if (generatedTitle != null && generatedTitle.isNotEmpty) {
        await _updateConversationTitle(
          conversation,
          generatedTitle,
          checkDefaultTitle,
        );
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

  /// 验证标题生成的必要条件
  _TitleGenerationValidationResult _validateTitleGenerationRequirements(
    ConversationUiState conversation,
  ) {
    final providerId = conversation.selectedProviderId;
    final modelId = conversation.selectedModelId;

    if (providerId.isEmpty || modelId == null || modelId.isEmpty) {
      return _TitleGenerationValidationResult(
        isValid: false,
        errorMessage: '缺少提供商或模型信息',
      );
    }

    // 通过 provider notifier 获取提供商对象
    final provider = ref.read(aiProviderProvider(providerId));
    if (provider == null) {
      return _TitleGenerationValidationResult(
        isValid: false,
        errorMessage: '无法获取提供商信息',
      );
    }

    return _TitleGenerationValidationResult(
      isValid: true,
      provider: provider,
      modelId: modelId,
    );
  }

  /// 使用智能聊天生成标题
  Future<String?> _generateTitleWithSmartChat(
    List<Message> messages, {
    String? providerId,
    String? modelName,
  }) async {
    if (messages.isEmpty) return null;

    // 如果没有指定提供商和模型，从聊天配置获取默认配置
    if (providerId == null || modelName == null) {
      final defaultConfig = ref
          .read(chatConfigurationProvider)
          .defaultConfiguration;
      providerId ??= defaultConfig.providerId;
      modelName ??= defaultConfig.modelName;
    }

    // 如果仍然没有配置，无法生成标题
    if (providerId == null || modelName == null) {
      _logger.debug('没有可用的提供商和模型配置，无法生成标题');
      return null;
    }

    // 构建标题生成提示
    final titlePrompt = _buildTitleGenerationPrompt(messages);

    try {
      final response = await ref.read(
        smartChatProvider(
          SmartChatParams(
            chatHistory: [], // 不需要历史记录
            userMessage: titlePrompt,
            providerId: providerId,
            modelName: modelName,
          ),
        ).future,
      );

      if (response.isSuccess && response.content.isNotEmpty) {
        return _cleanTitle(response.content);
      }
    } catch (e) {
      _logger.warning('生成标题失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': e.toString(),
      });
    }

    return null;
  }

  /// 生成标题（回退方法）
  Future<String?> _generateTitle(
    dynamic provider,
    String modelId,
    List<Message> messages,
    String providerId,
  ) async {
    // 使用当前对话的提供商和模型生成标题
    return await _generateTitleWithSmartChat(
      messages,
      providerId: providerId,
      modelName: modelId,
    );
  }

  /// 构建标题生成提示
  String _buildTitleGenerationPrompt(List<Message> messages) {
    // 获取最近的几条消息作为上下文
    final recentMessages = messages.take(6).toList();

    final conversationSummary = recentMessages
        .map((msg) {
          final author = msg.isFromUser ? '用户' : 'AI';
          return '$author: ${msg.content}';
        })
        .join('\n');

    return '''请为以下对话生成一个简洁的标题（不超过20个字符）：

$conversationSummary

要求：
1. 标题要简洁明了，能概括对话主题
2. 不要包含引号或特殊符号
3. 直接返回标题，不要其他解释
4. 标题长度控制在20个字符以内''';
  }

  /// 清理标题文本
  String _cleanTitle(String title) {
    // 移除换行符和多余空格
    String cleaned = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 移除引号
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }

    // 限制长度
    if (cleaned.length > 20) {
      cleaned = '${cleaned.substring(0, 17)}...';
    }

    return cleaned;
  }

  /// 更新对话标题
  Future<void> _updateConversationTitle(
    ConversationUiState conversation,
    String newTitle,
    bool checkDefaultTitle,
  ) async {
    final conversationId = conversation.id;

    // _logger.info('标题生成成功', {
    //   'conversationId': conversationId,
    //   'title': newTitle,
    // });

    // 如果需要检查默认标题，再次验证当前对话状态
    if (checkDefaultTitle) {
      final currentConversation = state.conversation;
      if (currentConversation?.id == conversationId &&
          currentConversation?.channelName != _defaultTitle) {
        _logger.debug('标题已被用户修改，取消自动更新');
        return;
      }
    }

    // 更新对话标题
    final updatedConversation = conversation.copyWith(channelName: newTitle);

    // 如果是当前对话，更新状态
    if (state.conversation?.id == conversationId) {
      state = state.copyWith(conversation: updatedConversation);
    }

    // 保存到数据库
    await _saveConversationIfNeeded(updatedConversation);

    // 通知对话列表刷新
    ref.read(conversationListRefreshProvider.notifier).notifyRefresh();
  }
}

/// 标题生成验证结果
class _TitleGenerationValidationResult {
  final bool isValid;
  final String? errorMessage;
  final dynamic provider;
  final String? modelId;

  const _TitleGenerationValidationResult({
    required this.isValid,
    this.errorMessage,
    this.provider,
    this.modelId,
  });
}

/// 对话列表刷新通知器 - 通知对话列表需要刷新的简单计数器
class ConversationListRefreshNotifier extends StateNotifier<int> {
  ConversationListRefreshNotifier() : super(0);

  /// 通知对话列表需要刷新
  void notifyRefresh() {
    state = state + 1;
  }
}

/// 对话列表刷新通知Provider
final conversationListRefreshProvider =
    StateNotifierProvider<ConversationListRefreshNotifier, int>(
      (ref) => ConversationListRefreshNotifier(),
    );

/// 当前对话状态Provider
final currentConversationProvider =
    StateNotifierProvider<
      CurrentConversationNotifier,
      CurrentConversationState
    >((ref) => CurrentConversationNotifier(ref));
