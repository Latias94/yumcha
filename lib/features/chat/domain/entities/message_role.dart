/// 消息角色枚举
/// 
/// 定义消息的发送者角色
enum MessageRole {
  /// 用户消息
  user,
  
  /// AI助手消息
  assistant,
  
  /// 系统消息
  system,
}

/// 消息角色扩展方法
extension MessageRoleExtension on MessageRole {
  /// 获取角色的显示名称
  String get displayName {
    switch (this) {
      case MessageRole.user:
        return '用户';
      case MessageRole.assistant:
        return '助手';
      case MessageRole.system:
        return '系统';
    }
  }

  /// 是否是用户消息
  bool get isUser {
    return this == MessageRole.user;
  }

  /// 是否是助手消息
  bool get isAssistant {
    return this == MessageRole.assistant;
  }

  /// 是否是系统消息
  bool get isSystem {
    return this == MessageRole.system;
  }

  /// 转换为旧版本的isFromUser字段
  bool get isFromUser {
    return this == MessageRole.user;
  }

  /// 从旧版本的isFromUser字段创建角色
  static MessageRole fromIsFromUser(bool isFromUser) {
    return isFromUser ? MessageRole.user : MessageRole.assistant;
  }
}
