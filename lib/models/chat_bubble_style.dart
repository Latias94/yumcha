/// 聊天消息显示样式枚举
enum ChatBubbleStyle {
  /// 聊天气泡样式（有背景色和圆角）
  bubble('bubble', '聊天气泡'),

  /// 列表样式（无背景色，占满宽度）
  list('list', '列表样式');

  const ChatBubbleStyle(this.value, this.displayName);

  /// 样式值
  final String value;

  /// 显示名称
  final String displayName;

  /// 从字符串值获取样式
  static ChatBubbleStyle fromValue(String value) {
    return ChatBubbleStyle.values.firstWhere(
      (style) => style.value == value,
      orElse: () => ChatBubbleStyle.list, // 默认列表样式
    );
  }
}
