/// 聊天消息显示样式枚举
///
/// 定义聊天界面中消息的显示样式，用户可以根据偏好选择不同的样式。
///
/// 核心特性：
/// - 🎨 **样式选择**: 提供多种消息显示样式
/// - 🔄 **动态切换**: 支持运行时切换样式
/// - 💾 **偏好保存**: 可以保存用户的样式偏好
/// - 📱 **响应式**: 适配不同屏幕尺寸和设备
///
/// 使用场景：
/// - 聊天界面的样式配置
/// - 用户偏好设置
/// - 主题和外观管理
enum ChatBubbleStyle {
  /// 聊天气泡样式
  /// 特点：有背景色和圆角，类似传统聊天应用的气泡效果
  bubble('bubble', '聊天气泡'),

  /// 列表样式
  /// 特点：无背景色，占满宽度，类似文档或邮件的显示方式
  list('list', '列表样式');

  const ChatBubbleStyle(this.value, this.displayName);

  /// 样式的字符串值（用于存储和传输）
  final String value;

  /// 样式的显示名称（用于 UI 展示）
  final String displayName;

  /// 从字符串值获取对应的样式枚举
  /// 如果找不到匹配的样式，默认返回列表样式
  static ChatBubbleStyle fromValue(String value) {
    return ChatBubbleStyle.values.firstWhere(
      (style) => style.value == value,
      orElse: () => ChatBubbleStyle.list, // 默认列表样式
    );
  }
}
