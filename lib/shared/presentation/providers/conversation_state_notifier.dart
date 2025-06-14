import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../infrastructure/services/data_initialization_service.dart';
import 'dependency_providers.dart';
import '../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../features/chat/presentation/providers/chat_configuration_notifier.dart';
import 'configuration_persistence_notifier.dart';
import 'package:uuid/uuid.dart';

/// 对话状态数据模型 - 简化版，专注于状态管理
class ConversationState {
  final ConversationUiState? currentConversation;
  final bool isLoading;
  final String? error;
  final String selectedMenu;

  const ConversationState({
    this.currentConversation,
    this.isLoading = false,
    this.error,
    this.selectedMenu = "new_chat",
  });

  ConversationState copyWith({
    ConversationUiState? currentConversation,
    bool? isLoading,
    String? error,
    String? selectedMenu,
  }) {
    return ConversationState(
      currentConversation: currentConversation ?? this.currentConversation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMenu: selectedMenu ?? this.selectedMenu,
    );
  }
}

/// 对话状态管理器 - 专注于对话的基本状态管理
///
/// 职责简化为：
/// - 🔄 对话创建和切换
/// - 📝 对话状态更新
/// - 💾 基本的持久化
/// - 🎯 菜单状态管理
class ConversationStateNotifier extends StateNotifier<ConversationState> {
  ConversationStateNotifier(this._ref) : super(const ConversationState()) {
    _initialize();
  }

  final Ref _ref;
  final _uuid = const Uuid();
  final LoggerService _logger = LoggerService();

  // 防抖机制
  DateTime? _lastCreateTime;

  Future<void> _initialize() async {
    // 等待数据初始化完成
    try {
      await _ref.read(initializeDefaultDataProvider.future);
    } catch (e) {
      _logger.warning('数据初始化失败，继续创建对话', {'error': e.toString()});
    }

    // 等待助手数据加载完成
    await _waitForAssistantsToLoad();

    await createNewConversation();
  }

  /// 等待助手数据加载完成
  Future<void> _waitForAssistantsToLoad() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);

    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      // 使用新的统一AI管理Provider - 直接检查助手列表
      final assistants = _ref.read(aiAssistantsProvider);

      // 检查是否有数据
      if (assistants.isNotEmpty) {
        _logger.info('助手数据加载完成');
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('等待助手数据超时，继续创建对话');
  }

  /// 创建新对话 - 简化版
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

      // 生成对话ID
      final conversationId = _uuid.v4();

      // 获取默认助手
      final assistant = await _getDefaultAssistant();
      if (assistant == null) {
        _logger.error('找不到可用的助手');
        state = state.copyWith(isLoading: false, error: '找不到可用的助手');
        return;
      }

      // 获取默认配置
      final config = await _getDefaultConfiguration();

      // 确保有有效的提供商和模型配置
      String providerId = config.providerId ?? '';
      String? modelName = config.modelName;

      // 如果配置不完整，尝试获取第一个可用的提供商和模型
      if (providerId.isEmpty || modelName == null) {
        // 使用新的统一AI管理Provider - 直接获取提供商列表
        final providers = _ref.read(aiProvidersProvider);
        final enabledProviders = providers.where((p) => p.isEnabled).toList();

        if (enabledProviders.isNotEmpty) {
          final firstProvider = enabledProviders.first;
          if (firstProvider.models.isNotEmpty) {
            providerId = firstProvider.id;
            modelName = firstProvider.models.first.name;
            _logger.info('使用fallback提供商和模型', {
              'providerId': providerId,
              'modelName': modelName,
            });
          }
        } else {
          _logger.warning('没有可用的提供商，使用空配置');
        }
      }

      final newConversation = ConversationUiState(
        id: conversationId,
        channelName: "新对话",
        channelMembers: 1,
        assistantId: assistant.id,
        selectedProviderId: providerId,
        selectedModelId: modelName,
        messages: [],
      );

      state = state.copyWith(
        currentConversation: newConversation,
        isLoading: false,
        selectedMenu: "new_chat",
      );

      _logger.info('新对话创建成功', {
        'conversationId': newConversation.id,
        'assistantName': assistant.name,
      });

      // 保存配置
      await _saveCurrentConfiguration(
        assistant.id,
        providerId,
        modelName ?? '',
      );
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
        currentConversation: fallbackConversation,
        isLoading: false,
        error: '创建对话失败: $e',
      );
    }
  }

  /// 加载现有对话
  Future<void> loadConversation(String conversationId) async {
    try {
      _logger.info('ConversationStateNotifier 开始加载对话', {'conversationId': conversationId});
      state = state.copyWith(isLoading: true, error: null);

      final repository = _ref.read(conversationRepositoryProvider);
      final conversation = await repository.getConversation(conversationId);

      if (conversation != null) {
        _logger.info('对话数据加载成功', {
          'conversationId': conversation.id,
          'title': conversation.channelName,
          'messageCount': conversation.messages.length,
        });

        state = state.copyWith(
          currentConversation: conversation,
          isLoading: false,
          selectedMenu: conversationId,
        );

        _logger.info('对话状态更新完成', {
          'currentConversationId': state.currentConversation?.id,
          'selectedMenu': state.selectedMenu,
          'isLoading': state.isLoading,
        });
      } else {
        _logger.warning('对话不存在', {'conversationId': conversationId});
        state = state.copyWith(isLoading: false, error: '对话不存在');
      }
    } catch (e) {
      _logger.error('加载对话失败', {
        'conversationId': conversationId,
        'error': e.toString(),
      });
      state = state.copyWith(isLoading: false, error: '加载对话失败: $e');
    }
  }

  /// 切换对话
  Future<void> switchToConversation(String chatId) async {
    _logger.info('ConversationStateNotifier 开始切换对话', {
      'targetChatId': chatId,
      'currentConversationId': state.currentConversation?.id,
      'isLoading': state.isLoading,
    });

    if (state.isLoading) {
      _logger.warning('对话正在加载中，忽略切换请求');
      return;
    }

    if (state.currentConversation?.id == chatId && chatId != "new_chat") {
      _logger.info('目标对话已经是当前对话，无需切换');
      return;
    }

    if (chatId == "new_chat") {
      _logger.info('切换到新对话');
      await createNewConversation();
    } else {
      _logger.info('切换到现有对话', {'conversationId': chatId});
      await loadConversation(chatId);
    }

    _logger.info('对话切换完成', {
      'newConversationId': state.currentConversation?.id,
      'selectedMenu': state.selectedMenu,
    });
  }

  /// 更新对话
  void updateConversation(ConversationUiState conversation) {
    state = state.copyWith(currentConversation: conversation);

    // 异步保存到数据库
    _saveConversationToDatabase(conversation);
  }

  /// 保存对话到数据库
  Future<void> _saveConversationToDatabase(
      ConversationUiState conversation) async {
    try {
      final repository = _ref.read(conversationRepositoryProvider);
      await repository.saveConversation(conversation);
      _logger.info('对话保存成功', {'conversationId': conversation.id});
    } catch (e) {
      _logger.error('对话保存失败', {
        'conversationId': conversation.id,
        'error': e.toString(),
      });
    }
  }

  /// 获取默认助手
  Future<AiAssistant?> _getDefaultAssistant() async {
    // 使用新的统一AI管理Provider - 直接获取助手列表
    final assistants = _ref.read(aiAssistantsProvider);
    final persistedConfig = _ref.read(configurationPersistenceNotifierProvider);

    // 如果助手列表为空，等待数据加载
    if (assistants.isEmpty) {
      _logger.debug('助手数据为空，等待加载完成...');
      await _waitForAssistantsToLoad();
      // 重新获取数据
      final updatedAssistants = _ref.read(aiAssistantsProvider);
      return _extractAssistantFromList(updatedAssistants, persistedConfig);
    }

    return _extractAssistantFromList(assistants, persistedConfig);
  }

  /// 从助手列表中提取助手
  AiAssistant? _extractAssistantFromList(
    List<AiAssistant> assistants,
    dynamic persistedConfig,
  ) {
    final enabledAssistants = assistants.where((a) => a.isEnabled).toList();

    // 尝试获取上次使用的助手
    if (persistedConfig.lastUsedAssistantId != null) {
      final lastAssistant = assistants
          .where((a) =>
              a.id == persistedConfig.lastUsedAssistantId! && a.isEnabled)
          .firstOrNull;
      if (lastAssistant != null) return lastAssistant;
    }

    // 选择默认助手或第一个可用助手
    return enabledAssistants
            .where((a) => a.id == 'default-assistant')
            .firstOrNull ??
        enabledAssistants.firstOrNull;
  }

  /// 获取默认配置 - 改进版，依赖ChatConfigurationNotifier
  Future<({String? providerId, String? modelName})>
      _getDefaultConfiguration() async {
    final chatConfig = _ref.read(chatConfigurationProvider);

    // 优先使用 ChatConfigurationNotifier 的配置，它有更完善的fallback逻辑
    if (chatConfig.hasCompleteConfiguration) {
      return (
        providerId: chatConfig.selectedProvider!.id,
        modelName: chatConfig.selectedModel!.name,
      );
    }

    // 如果 ChatConfigurationNotifier 还没有完整配置，等待其初始化完成
    if (chatConfig.isLoading) {
      _logger.info('等待ChatConfigurationNotifier初始化完成');
      // 等待一段时间让ChatConfigurationNotifier完成初始化
      await Future.delayed(const Duration(milliseconds: 500));
      final updatedConfig = _ref.read(chatConfigurationProvider);
      if (updatedConfig.hasCompleteConfiguration) {
        return (
          providerId: updatedConfig.selectedProvider!.id,
          modelName: updatedConfig.selectedModel!.name,
        );
      }
    }

    // 如果仍然没有配置，使用持久化配置作为最后的fallback
    final persistedConfig = _ref.read(configurationPersistenceNotifierProvider);

    return (
      providerId: persistedConfig.lastUsedProviderId,
      modelName: persistedConfig.lastUsedModelName,
    );
  }

  /// 保存当前配置
  Future<void> _saveCurrentConfiguration(
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    try {
      // 直接使用PreferenceService保存配置
      final preferenceService = _ref.read(preferenceServiceProvider);

      // 分别保存助手和模型配置
      await Future.wait([
        preferenceService.saveLastUsedAssistantId(assistantId),
        if (providerId.isNotEmpty && modelName.isNotEmpty)
          preferenceService.saveLastUsedModel(providerId, modelName),
      ]);

      _logger.info('配置保存成功', {
        'assistantId': assistantId,
        'providerId': providerId,
        'modelName': modelName,
      });
    } catch (e) {
      _logger.error('配置保存失败', {
        'assistantId': assistantId,
        'providerId': providerId,
        'modelName': modelName,
        'error': e.toString(),
      });
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 对话状态Provider
final conversationStateNotifierProvider =
    StateNotifierProvider<ConversationStateNotifier, ConversationState>(
  (ref) => ConversationStateNotifier(ref),
);
