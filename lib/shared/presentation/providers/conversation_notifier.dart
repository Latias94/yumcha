import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/chat/domain/entities/message.dart';
import 'conversation_coordinator.dart';
import 'conversation_state_notifier.dart';
import '../../infrastructure/services/logger_service.dart';

/// 🔄 重构后的对话管理器
///
/// 这个文件现在作为新拆分架构的门面，保持与原有代码的兼容性。
/// 原来的739行巨大Notifier已经被拆分为3个专门的Provider：
///
/// 1. **ConversationStateNotifier** - 对话状态管理
/// 2. **ConversationTitleNotifier** - 标题生成管理
/// 3. **ConfigurationPersistenceNotifier** - 配置持久化
/// 4. **ConversationCoordinator** - 协调器
///
/// ## 🎯 重构优势
/// - ✅ **职责分离**: 每个Provider专注一个领域
/// - ✅ **可测试性**: 更容易进行单元测试
/// - ✅ **可维护性**: 代码更清晰，更容易理解和修改
/// - ✅ **性能优化**: 更精确的依赖关系，减少不必要的重建
/// - ✅ **兼容性**: 保持与现有代码的兼容性

/// 兼容性状态类 - 保持与原有代码的兼容性
///
/// 这个类扩展了新的ConversationState，添加了原有代码期望的属性名。
/// 这样可以在不修改现有代码的情况下完成重构。
class CurrentConversationState extends ConversationState {
  const CurrentConversationState({
    super.currentConversation,
    super.isLoading,
    super.error,
    super.selectedMenu,
  });

  /// 兼容性属性 - 映射到新的属性名
  ConversationUiState? get conversation => currentConversation;

  @override
  CurrentConversationState copyWith({
    ConversationUiState? currentConversation,
    bool? isLoading,
    String? error,
    String? selectedMenu,
  }) {
    return CurrentConversationState(
      currentConversation: currentConversation ?? this.currentConversation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMenu: selectedMenu ?? this.selectedMenu,
    );
  }
}

/// 兼容性Notifier - 使用新的拆分架构但保持原有接口
///
/// 这个类作为适配器，将原有的接口调用转发给新的拆分Provider。
/// 这样可以在不破坏现有代码的情况下完成重构。
class CurrentConversationNotifier
    extends StateNotifier<CurrentConversationState> {
  CurrentConversationNotifier(this.ref)
      : super(const CurrentConversationState()) {
    _logger.info('CurrentConversationNotifier 初始化');

    // 监听新的状态管理器的变化，保持状态同步
    ref.listen(conversationStateNotifierProvider, (previous, next) {
      _logger.debug('状态同步：从新架构同步到兼容性层', {
        'previousConversationId': previous?.currentConversation?.id,
        'nextConversationId': next.currentConversation?.id,
        'isLoading': next.isLoading,
        'hasError': next.error != null,
      });

      final newState = CurrentConversationState(
        currentConversation: next.currentConversation,
        isLoading: next.isLoading,
        error: next.error,
        selectedMenu: next.selectedMenu,
      );

      state = newState;

      _logger.debug('兼容性层状态已更新', {
        'conversationId': newState.currentConversation?.id,
        'selectedMenu': newState.selectedMenu,
      });
    });
  }

  final Ref ref;
  final LoggerService _logger = LoggerService();

  /// 创建新对话 - 转发给协调器
  Future<void> createNewConversation() async {
    final coordinator = ref.read(conversationCoordinatorProvider);
    await coordinator.createNewConversation();
  }

  /// 加载现有对话 - 转发给协调器
  Future<void> loadConversation(String conversationId) async {
    final coordinator = ref.read(conversationCoordinatorProvider);
    await coordinator.loadConversation(conversationId);
  }

  /// 切换对话 - 转发给协调器
  Future<void> switchToConversation(String chatId) async {
    final coordinator = ref.read(conversationCoordinatorProvider);
    await coordinator.switchToConversation(chatId);
  }

  /// 更新对话 - 转发给协调器
  void updateConversation(ConversationUiState conversation) {
    final coordinator = ref.read(conversationCoordinatorProvider);
    coordinator.updateConversation(conversation);
  }

  /// 当AI消息添加后调用 - 转发给协调器
  Future<void> onAiMessageAdded(Message aiMessage) async {
    final coordinator = ref.read(conversationCoordinatorProvider);
    await coordinator.onAiMessageAdded(aiMessage);
  }

  /// 手动重新生成标题 - 转发给协调器
  Future<void> regenerateTitle(String conversationId) async {
    final coordinator = ref.read(conversationCoordinatorProvider);
    await coordinator.regenerateTitle(conversationId);
  }

  /// 当助手配置改变时调用 - 转发给协调器
  Future<void> onAssistantConfigChanged(
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    final coordinator = ref.read(conversationCoordinatorProvider);
    await coordinator.onAssistantConfigChanged(
        assistantId, providerId, modelName);
  }

  /// 清除错误 - 转发给协调器
  void clearError() {
    final coordinator = ref.read(conversationCoordinatorProvider);
    coordinator.clearError();
  }
}

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

/// 当前对话状态Provider - 兼容性接口 (已弃用)
///
/// ⚠️ **已弃用**: 请使用 unified_chat_notifier.dart 中的新版本
/// 这个Provider保持与原有代码的完全兼容性，
/// 但内部使用新的拆分架构。
@Deprecated('使用 unified_chat_notifier.dart 中的 currentConversationProvider')
final legacyCurrentConversationProvider = StateNotifierProvider<
    CurrentConversationNotifier, CurrentConversationState>(
  (ref) => CurrentConversationNotifier(ref),
);

/// 便捷访问当前对话的Provider (已弃用)
@Deprecated('使用 unified_chat_notifier.dart 中的对应Provider')
final currentConversationDataProvider = Provider<ConversationUiState?>((ref) {
  final state = ref.watch(legacyCurrentConversationProvider);
  return state.currentConversation;
});

/// 检查当前对话是否正在加载 (已弃用)
@Deprecated('使用 unified_chat_notifier.dart 中的对应Provider')
final isConversationLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(legacyCurrentConversationProvider);
  return state.isLoading;
});

/// 获取当前对话的错误信息 (已弃用)
@Deprecated('使用 unified_chat_notifier.dart 中的对应Provider')
final conversationErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(legacyCurrentConversationProvider);
  return state.error;
});

/// 获取当前选中的菜单 (已弃用)
@Deprecated('使用 unified_chat_notifier.dart 中的对应Provider')
final selectedMenuProvider = Provider<String>((ref) {
  final state = ref.watch(legacyCurrentConversationProvider);
  return state.selectedMenu;
});
