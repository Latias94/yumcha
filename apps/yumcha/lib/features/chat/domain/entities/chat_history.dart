/// 聊天历史项数据模型
///
/// 表示聊天历史列表中的单个对话项，包含对话的基本信息和预览。
/// 用于在聊天历史界面快速展示对话概要。
///
/// 使用场景：
/// - 聊天历史列表的数据展示
/// - 对话搜索和筛选
/// - 对话预览和快速访问
class ChatHistoryItem {
  /// 对话唯一标识符
  final String id;

  /// 对话标题
  final String title;

  /// 对话预览内容（通常是最后一条消息的摘要）
  final String preview;

  /// 对话时间戳（最后更新时间）
  final DateTime timestamp;

  /// 助手类型（"ai", "character", "developer" 等）
  final String assistantType;

  /// 消息数量
  final int messageCount;

  /// 关联的助手 ID
  final String? assistantId;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
    required this.assistantType,
    required this.messageCount,
    this.assistantId,
  });
}

/// 聊天历史分组数据模型
///
/// 用于将聊天历史按时间或类型分组显示，如"今天"、"昨天"、"本周"等。
///
/// 使用场景：
/// - 聊天历史的分组展示
/// - 时间线式的对话组织
class ChatHistoryGroup {
  /// 分组标题（如"今天"、"昨天"）
  final String title;

  /// 分组内的聊天历史项列表
  final List<ChatHistoryItem> items;

  const ChatHistoryGroup({required this.title, required this.items});
}

/// 助手类型数据模型
///
/// 定义不同类型的 AI 助手，用于分类和展示。
///
/// 使用场景：
/// - 助手类型的分类展示
/// - 助手图标和名称的统一管理
class AssistantType {
  /// 助手类型唯一标识符
  final String id;

  /// 助手类型名称
  final String name;

  /// 助手类型图标
  final String icon;

  const AssistantType({
    required this.id,
    required this.name,
    required this.icon,
  });
}
