import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/chat/domain/entities/message.dart';
import '../../infrastructure/services/logger_service.dart';
import 'conversation_state_notifier.dart';
import 'conversation_title_notifier.dart';
import 'configuration_persistence_notifier.dart';

/// 对话协调器 - 协调3个专门的Provider工作
///
/// 这个类作为门面模式，协调以下3个专门的Provider：
/// 1. ConversationStateNotifier - 对话状态管理
/// 2. ConversationTitleNotifier - 标题生成管理
/// 3. ConfigurationPersistenceNotifier - 配置持久化
///
/// 职责：
/// - 🎭 **门面模式**: 为UI提供统一的接口
/// - 🔄 **协调工作**: 协调各个Provider之间的交互
/// - 📊 **状态聚合**: 聚合多个Provider的状态
/// - 🎯 **业务流程**: 管理复杂的业务流程
class ConversationCoordinator {
  ConversationCoordinator(this._ref);

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 创建新对话
  Future<void> createNewConversation() async {
    _logger.info('协调器：开始创建新对话');

    // 委托给状态管理器
    final stateNotifier = _ref.read(conversationStateNotifierProvider.notifier);
    await stateNotifier.createNewConversation();

    _logger.info('协调器：新对话创建完成');
  }

  /// 加载现有对话
  Future<void> loadConversation(String conversationId) async {
    _logger.info('协调器：开始加载对话', {'conversationId': conversationId});

    // 委托给状态管理器
    final stateNotifier = _ref.read(conversationStateNotifierProvider.notifier);
    await stateNotifier.loadConversation(conversationId);

    _logger.info('协调器：对话加载完成');
  }

  /// 切换对话
  Future<void> switchToConversation(String chatId) async {
    _logger.info('协调器：切换对话', {'chatId': chatId});

    // 委托给状态管理器
    final stateNotifier = _ref.read(conversationStateNotifierProvider.notifier);
    await stateNotifier.switchToConversation(chatId);
  }

  /// 更新对话
  void updateConversation(ConversationUiState conversation) {
    _logger.debug('协调器：更新对话', {'conversationId': conversation.id});

    // 委托给状态管理器
    final stateNotifier = _ref.read(conversationStateNotifierProvider.notifier);
    stateNotifier.updateConversation(conversation);

    // 如果对话有消息，可能需要生成标题
    if (conversation.messages.isNotEmpty) {
      _checkAndGenerateTitle(conversation);
    }
  }

  /// 当AI消息添加后调用
  Future<void> onAiMessageAdded(Message aiMessage) async {
    final currentState = _ref.read(conversationStateNotifierProvider);
    final conversation = currentState.currentConversation;

    if (conversation == null) return;

    _logger.debug('协调器：AI消息添加', {
      'conversationId': conversation.id,
      'messageCount': conversation.messages.length,
    });

    // 委托给标题管理器
    final titleNotifier = _ref.read(conversationTitleNotifierProvider.notifier);
    await titleNotifier.onAiMessageAdded(
        conversation.id, conversation.messages);
  }

  /// 手动重新生成标题
  Future<void> regenerateTitle(String conversationId) async {
    _logger.info('协调器：手动重新生成标题', {'conversationId': conversationId});

    // 获取对话信息
    final currentState = _ref.read(conversationStateNotifierProvider);
    final conversation = currentState.currentConversation;

    if (conversation?.id != conversationId) {
      _logger.warning('当前对话与请求的对话ID不匹配');
      return;
    }

    // 检查对话是否存在
    if (conversation == null) {
      _logger.warning('对话不存在，无法重新生成标题', {'conversationId': conversationId});
      return;
    }

    // 委托给标题管理器
    final titleNotifier = _ref.read(conversationTitleNotifierProvider.notifier);
    await titleNotifier.regenerateTitle(conversationId, conversation.messages);
  }

  /// 当助手配置改变时调用
  Future<void> onAssistantConfigChanged(
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    _logger.info('协调器：助手配置改变', {
      'assistantId': assistantId,
      'providerId': providerId,
      'modelName': modelName,
    });

    // 委托给配置持久化管理器
    // TODO: 实现完整的配置保存逻辑
    // final configNotifier = _ref.read(configurationPersistenceNotifierProvider.notifier);
    // await configNotifier.saveCompleteConfiguration(...);

    _logger.info('配置已更新，等待实现完整的保存逻辑');
  }

  /// 清除错误
  void clearError() {
    final stateNotifier = _ref.read(conversationStateNotifierProvider.notifier);
    stateNotifier.clearError();
  }

  /// 检查并生成标题（内部方法）
  void _checkAndGenerateTitle(ConversationUiState conversation) {
    // 简单检查：如果有足够的消息且标题是默认的，触发标题生成
    if (conversation.messages.length >= 2 &&
        conversation.channelName == "新对话") {
      final titleNotifier =
          _ref.read(conversationTitleNotifierProvider.notifier);
      titleNotifier.onAiMessageAdded(conversation.id, conversation.messages);
    }
  }

  /// 获取当前对话状态
  ConversationState getCurrentState() {
    return _ref.read(conversationStateNotifierProvider);
  }

  /// 获取对话标题
  String? getConversationTitle(String conversationId) {
    return _ref.read(conversationTitleProvider(conversationId));
  }

  /// 获取持久化配置
  PersistedConfiguration getPersistedConfiguration() {
    return _ref.read(configurationPersistenceNotifierProvider);
  }
}

/// 对话协调器Provider
final conversationCoordinatorProvider =
    Provider<ConversationCoordinator>((ref) {
  return ConversationCoordinator(ref);
});

/// 兼容性Provider - 保持与原有代码的兼容性
///
/// 这个Provider提供与原来CurrentConversationNotifier相同的接口，
/// 但内部使用新的拆分架构。这样可以在不破坏现有代码的情况下进行重构。
final currentConversationProvider = Provider<ConversationUiState?>((ref) {
  final state = ref.watch(conversationStateNotifierProvider);
  return state.currentConversation;
});

/// 兼容性状态Provider
final currentConversationStateProvider = Provider<ConversationState>((ref) {
  return ref.watch(conversationStateNotifierProvider);
});

/// 对话列表刷新通知器 - 保持原有功能
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

/// 便捷方法Provider - 提供常用的操作方法
final conversationActionsProvider = Provider<ConversationActions>((ref) {
  return ConversationActions(ref);
});

/// 对话操作类 - 提供便捷的操作方法
class ConversationActions {
  ConversationActions(this._ref);

  final Ref _ref;

  /// 创建新对话
  Future<void> createNew() async {
    final coordinator = _ref.read(conversationCoordinatorProvider);
    await coordinator.createNewConversation();
  }

  /// 切换对话
  Future<void> switchTo(String chatId) async {
    final coordinator = _ref.read(conversationCoordinatorProvider);
    await coordinator.switchToConversation(chatId);
  }

  /// 更新对话
  void update(ConversationUiState conversation) {
    final coordinator = _ref.read(conversationCoordinatorProvider);
    coordinator.updateConversation(conversation);
  }

  /// AI消息添加
  Future<void> onAiMessage(Message aiMessage) async {
    final coordinator = _ref.read(conversationCoordinatorProvider);
    await coordinator.onAiMessageAdded(aiMessage);
  }

  /// 重新生成标题
  Future<void> regenerateTitle(String conversationId) async {
    final coordinator = _ref.read(conversationCoordinatorProvider);
    await coordinator.regenerateTitle(conversationId);
  }

  /// 清除错误
  void clearError() {
    final coordinator = _ref.read(conversationCoordinatorProvider);
    coordinator.clearError();
  }
}
