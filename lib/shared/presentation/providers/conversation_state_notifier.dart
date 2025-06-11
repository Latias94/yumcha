import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../infrastructure/services/data_initialization_service.dart';
import 'dependency_providers.dart';
import '../../../features/ai_management/presentation/providers/ai_assistant_notifier.dart';
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
      final assistantsAsync = _ref.read(aiAssistantNotifierProvider);

      // 检查是否加载完成且有数据
      final hasData = assistantsAsync.whenOrNull(
            data: (assistants) => assistants.isNotEmpty,
          ) ??
          false;

      if (hasData) {
        _logger.info('助手数据加载完成');
        return;
      }

      // 检查是否有错误
      final hasError = assistantsAsync.whenOrNull(
            error: (error, stack) => true,
          ) ??
          false;

      if (hasError) {
        _logger.warning('助手数据加载失败，但继续创建对话');
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
      final config = _getDefaultConfiguration();

      final newConversation = ConversationUiState(
        id: conversationId,
        channelName: "新对话",
        channelMembers: 1,
        assistantId: assistant.id,
        selectedProviderId: config.providerId ?? '',
        selectedModelId: config.modelName,
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
        config.providerId ?? '',
        config.modelName ?? '',
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
      _logger.info('开始加载对话', {'conversationId': conversationId});
      state = state.copyWith(isLoading: true, error: null);

      final repository = _ref.read(conversationRepositoryProvider);
      final conversation = await repository.getConversation(conversationId);

      if (conversation != null) {
        state = state.copyWith(
          currentConversation: conversation,
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
    if (state.isLoading) return;

    if (state.currentConversation?.id == chatId && chatId != "new_chat") {
      return;
    }

    if (chatId == "new_chat") {
      await createNewConversation();
    } else {
      await loadConversation(chatId);
    }
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
    final assistantsAsync = _ref.read(aiAssistantNotifierProvider);
    final persistedConfig = _ref.read(configurationPersistenceNotifierProvider);

    // 如果数据还在加载中，等待加载完成
    if (assistantsAsync is AsyncLoading) {
      _logger.debug('助手数据正在加载中，等待完成...');
      await _waitForAssistantsToLoad();
      // 重新获取数据
      final updatedAssistantsAsync = _ref.read(aiAssistantNotifierProvider);
      return _extractAssistantFromAsync(
          updatedAssistantsAsync, persistedConfig);
    }

    return _extractAssistantFromAsync(assistantsAsync, persistedConfig);
  }

  /// 从AsyncValue中提取助手
  AiAssistant? _extractAssistantFromAsync(
    AsyncValue<List<AiAssistant>> assistantsAsync,
    dynamic persistedConfig,
  ) {
    return assistantsAsync.whenOrNull(
      data: (assistants) {
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
      },
    );
  }

  /// 获取默认配置
  ({String? providerId, String? modelName}) _getDefaultConfiguration() {
    final defaultConfig =
        _ref.read(chatConfigurationProvider).defaultConfiguration;
    final persistedConfig = _ref.read(configurationPersistenceNotifierProvider);

    return (
      providerId:
          persistedConfig.lastUsedProviderId ?? defaultConfig.providerId,
      modelName: persistedConfig.lastUsedModelName ?? defaultConfig.modelName,
    );
  }

  /// 保存当前配置
  Future<void> _saveCurrentConfiguration(
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    // 这里需要获取实际的对象，暂时简化处理
    _logger.info('保存配置', {
      'assistantId': assistantId,
      'providerId': providerId,
      'modelName': modelName,
    });
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

/// 当前对话Provider
final currentConversationProvider = Provider<ConversationUiState?>((ref) {
  final state = ref.watch(conversationStateNotifierProvider);
  return state.currentConversation;
});
