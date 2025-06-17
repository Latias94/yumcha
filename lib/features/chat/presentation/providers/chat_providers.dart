import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../domain/repositories/message_repository.dart';
import '../../../ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';

// 导出新的聊天状态摘要Provider
export 'chat_status_summary_provider.dart';

/// 消息仓库Provider
/// 提供消息数据访问功能
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return MessageRepositoryImpl(database);
});


/// 聊天设置Provider
/// 管理聊天相关的设置选项（区别于聊天配置Provider）
final chatSettingsProvider = StateNotifierProvider<ChatSettingsNotifier, ChatSettings>((ref) {
  return ChatSettingsNotifier();
});

/// 聊天设置状态类
class ChatSettings {
  final bool enableBlockView;
  final bool enableBlockEditing;
  final bool showBlockTypeLabels;
  final bool enableStreamingByDefault;
  final bool showThinkingProcess;
  final int maxMessagesPerConversation;
  final bool enableMessageSearch;
  final bool enableAutoScroll;

  const ChatSettings({
    this.enableBlockView = true,
    this.enableBlockEditing = false,
    this.showBlockTypeLabels = false,
    this.enableStreamingByDefault = true,
    this.showThinkingProcess = true,
    this.maxMessagesPerConversation = 1000,
    this.enableMessageSearch = true,
    this.enableAutoScroll = true,
  });

  ChatSettings copyWith({
    bool? enableBlockView,
    bool? enableBlockEditing,
    bool? showBlockTypeLabels,
    bool? enableStreamingByDefault,
    bool? showThinkingProcess,
    int? maxMessagesPerConversation,
    bool? enableMessageSearch,
    bool? enableAutoScroll,
  }) {
    return ChatSettings(
      enableBlockView: enableBlockView ?? this.enableBlockView,
      enableBlockEditing: enableBlockEditing ?? this.enableBlockEditing,
      showBlockTypeLabels: showBlockTypeLabels ?? this.showBlockTypeLabels,
      enableStreamingByDefault: enableStreamingByDefault ?? this.enableStreamingByDefault,
      showThinkingProcess: showThinkingProcess ?? this.showThinkingProcess,
      maxMessagesPerConversation: maxMessagesPerConversation ?? this.maxMessagesPerConversation,
      enableMessageSearch: enableMessageSearch ?? this.enableMessageSearch,
      enableAutoScroll: enableAutoScroll ?? this.enableAutoScroll,
    );
  }
}

/// 聊天设置管理器
class ChatSettingsNotifier extends StateNotifier<ChatSettings> {
  ChatSettingsNotifier() : super(const ChatSettings());

  /// 启用/禁用块化视图
  void toggleBlockView() {
    state = state.copyWith(enableBlockView: !state.enableBlockView);
  }

  /// 启用/禁用块编辑功能
  void toggleBlockEditing() {
    state = state.copyWith(enableBlockEditing: !state.enableBlockEditing);
  }

  /// 显示/隐藏块类型标签
  void toggleBlockTypeLabels() {
    state = state.copyWith(showBlockTypeLabels: !state.showBlockTypeLabels);
  }

  /// 启用/禁用默认流式处理
  void toggleStreamingByDefault() {
    state = state.copyWith(enableStreamingByDefault: !state.enableStreamingByDefault);
  }

  /// 显示/隐藏思考过程
  void toggleThinkingProcess() {
    state = state.copyWith(showThinkingProcess: !state.showThinkingProcess);
  }

  /// 设置最大消息数量
  void setMaxMessagesPerConversation(int maxMessages) {
    state = state.copyWith(maxMessagesPerConversation: maxMessages);
  }

  /// 启用/禁用消息搜索
  void toggleMessageSearch() {
    state = state.copyWith(enableMessageSearch: !state.enableMessageSearch);
  }

  /// 启用/禁用自动滚动
  void toggleAutoScroll() {
    state = state.copyWith(enableAutoScroll: !state.enableAutoScroll);
  }

  /// 重置为默认配置
  void resetToDefaults() {
    state = const ChatSettings();
  }

  /// 从JSON加载配置
  void loadFromJson(Map<String, dynamic> json) {
    state = ChatSettings(
      enableBlockView: json['enableBlockView'] ?? true,
      enableBlockEditing: json['enableBlockEditing'] ?? false,
      showBlockTypeLabels: json['showBlockTypeLabels'] ?? false,
      enableStreamingByDefault: json['enableStreamingByDefault'] ?? true,
      showThinkingProcess: json['showThinkingProcess'] ?? true,
      maxMessagesPerConversation: json['maxMessagesPerConversation'] ?? 1000,
      enableMessageSearch: json['enableMessageSearch'] ?? true,
      enableAutoScroll: json['enableAutoScroll'] ?? true,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'enableBlockView': state.enableBlockView,
      'enableBlockEditing': state.enableBlockEditing,
      'showBlockTypeLabels': state.showBlockTypeLabels,
      'enableStreamingByDefault': state.enableStreamingByDefault,
      'showThinkingProcess': state.showThinkingProcess,
      'maxMessagesPerConversation': state.maxMessagesPerConversation,
      'enableMessageSearch': state.enableMessageSearch,
      'enableAutoScroll': state.enableAutoScroll,
    };
  }
}

/// 当前对话Provider
/// 管理当前活跃的对话ID
final currentConversationIdProvider = StateProvider<String?>((ref) => null);

/// 当前助手Provider（从AI管理模块获取）
final currentAssistantProvider = Provider((ref) {
  return ref.watch(selectedAssistantProvider);
});

/// 当前AI提供商Provider（从AI管理模块获取）
final currentProviderProvider = Provider((ref) {
  return ref.watch(selectedProviderProvider);
});

/// 当前AI模型Provider（从AI管理模块获取）
final currentModelProvider = Provider((ref) {
  return ref.watch(selectedModelProvider);
});

/// 消息视图配置Provider
/// 控制消息的显示方式
final messageViewConfigProvider = StateNotifierProvider<MessageViewConfigNotifier, MessageViewConfig>((ref) {
  final chatSettings = ref.watch(chatSettingsProvider);
  return MessageViewConfigNotifier(chatSettings);
});

/// 消息视图配置状态类
class MessageViewConfig {
  final bool useBlockView;
  final bool showTimestamps;
  final bool showTokenUsage;
  final bool enableMessageActions;
  final String layoutStyle; // 'list', 'card', 'bubble'

  const MessageViewConfig({
    this.useBlockView = true,
    this.showTimestamps = true,
    this.showTokenUsage = true,
    this.enableMessageActions = true,
    this.layoutStyle = 'list',
  });

  MessageViewConfig copyWith({
    bool? useBlockView,
    bool? showTimestamps,
    bool? showTokenUsage,
    bool? enableMessageActions,
    String? layoutStyle,
  }) {
    return MessageViewConfig(
      useBlockView: useBlockView ?? this.useBlockView,
      showTimestamps: showTimestamps ?? this.showTimestamps,
      showTokenUsage: showTokenUsage ?? this.showTokenUsage,
      enableMessageActions: enableMessageActions ?? this.enableMessageActions,
      layoutStyle: layoutStyle ?? this.layoutStyle,
    );
  }
}

/// 消息视图配置管理器
class MessageViewConfigNotifier extends StateNotifier<MessageViewConfig> {
  final ChatSettings _chatSettings;

  MessageViewConfigNotifier(this._chatSettings)
    : super(MessageViewConfig(useBlockView: _chatSettings.enableBlockView));

  /// 切换视图模式
  void toggleViewMode() {
    state = state.copyWith(useBlockView: !state.useBlockView);
  }

  /// 设置布局样式
  void setLayoutStyle(String style) {
    state = state.copyWith(layoutStyle: style);
  }

  /// 切换时间戳显示
  void toggleTimestamps() {
    state = state.copyWith(showTimestamps: !state.showTimestamps);
  }

  /// 切换Token使用量显示
  void toggleTokenUsage() {
    state = state.copyWith(showTokenUsage: !state.showTokenUsage);
  }

  /// 切换消息操作按钮
  void toggleMessageActions() {
    state = state.copyWith(enableMessageActions: !state.enableMessageActions);
  }
}
