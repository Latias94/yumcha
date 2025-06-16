import 'message.dart';

/// 对话 UI 状态数据模型
///
/// 表示聊天对话的完整状态，包含对话信息、消息列表、配置信息等。
/// 这是对话管理的核心数据模型，用于在 UI 层展示和管理对话状态。
///
/// 核心特性：
/// - 💬 **对话信息**: 对话 ID、名称、成员数等基本信息
/// - 📝 **消息管理**: 包含完整的消息历史列表（块化架构）
/// - 🤖 **助手配置**: 关联的 AI 助手 ID
/// - 🔌 **提供商配置**: 当前选择的提供商和模型
/// - 🔄 **状态操作**: 支持添加消息、清空消息等操作
/// - 📊 **UI 适配**: 专为 UI 层设计的状态管理
/// - 🧩 **块化支持**: 支持新的块化消息架构
///
/// 业务逻辑：
/// - 每个对话有唯一的 ID 和用户友好的名称
/// - 对话关联一个 AI 助手，定义聊天的角色和参数
/// - 对话记录当前使用的提供商和模型组合
/// - 消息按时间顺序存储，支持动态添加和清空
/// - 支持块化消息的多模态内容和精细状态管理
///
/// 使用场景：
/// - 对话界面的状态管理
/// - 对话列表的数据展示
/// - 对话持久化的数据结构
/// - 块化消息的渲染和交互
class ConversationUiState {
  /// 对话唯一标识符
  final String id;

  /// 对话名称（频道名称）
  final String channelName;

  /// 频道成员数（通常为 1，表示用户与 AI 的对话）
  final int channelMembers;

  /// 消息列表（按时间顺序，使用新的块化消息架构）
  final List<Message> messages;

  /// 关联的 AI 助手 ID
  final String? assistantId;

  /// 当前选择的提供商 ID
  final String selectedProviderId;

  /// 当前选择的模型 ID
  final String? selectedModelId;

  const ConversationUiState({
    required this.id,
    required this.channelName,
    required this.channelMembers,
    this.messages = const [],
    this.assistantId,
    required this.selectedProviderId,
    this.selectedModelId,
  });

  ConversationUiState copyWith({
    String? id,
    String? channelName,
    int? channelMembers,
    List<Message>? messages,
    String? assistantId,
    String? selectedProviderId,
    String? selectedModelId,
  }) {
    return ConversationUiState(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      channelMembers: channelMembers ?? this.channelMembers,
      messages: messages ?? this.messages,
      assistantId: assistantId ?? this.assistantId,
      selectedProviderId: selectedProviderId ?? this.selectedProviderId,
      selectedModelId: selectedModelId ?? this.selectedModelId,
    );
  }

  /// 添加新消息到对话中
  /// 新消息会被添加到消息列表的末尾（按时间顺序）
  ConversationUiState addMessage(Message message) {
    return copyWith(messages: [...messages, message]);
  }

  /// 清空对话中的所有消息
  ConversationUiState clearMessages() {
    return copyWith(messages: []);
  }
}
