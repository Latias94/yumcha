/// 新的消息状态枚举（块化消息系统）
///
/// 定义消息级别的状态，与消息块状态分离
enum MessageStatus {
  // 用户消息状态
  /// 用户消息成功
  userSuccess,

  // AI消息状态
  /// AI消息处理中
  aiProcessing,

  /// AI消息等待处理
  aiPending,

  /// AI消息流式传输中
  aiStreaming,

  /// AI消息成功
  aiSuccess,

  /// AI消息错误
  aiError,

  /// AI消息暂停
  aiPaused,

  // 系统消息状态
  /// 系统消息
  system,

  // 特殊状态
  /// 临时消息（不持久化）
  temporary,
}

/// 消息状态扩展方法
extension MessageStatusExtension on MessageStatus {
  /// 获取状态的显示名称
  String get displayName {
    switch (this) {
      case MessageStatus.userSuccess:
        return '已发送';
      case MessageStatus.aiProcessing:
        return '处理中';
      case MessageStatus.aiPending:
        return '等待中';
      case MessageStatus.aiStreaming:
        return '流式传输中';
      case MessageStatus.aiSuccess:
        return '完成';
      case MessageStatus.aiError:
        return '错误';
      case MessageStatus.aiPaused:
        return '暂停';
      case MessageStatus.system:
        return '系统消息';
      case MessageStatus.temporary:
        return '临时消息';
    }
  }

  /// 是否是用户消息状态
  bool get isUserStatus {
    return this == MessageStatus.userSuccess;
  }

  /// 是否是AI消息状态
  bool get isAiStatus {
    return this == MessageStatus.aiProcessing ||
        this == MessageStatus.aiPending ||
        this == MessageStatus.aiStreaming ||
        this == MessageStatus.aiSuccess ||
        this == MessageStatus.aiError ||
        this == MessageStatus.aiPaused;
  }

  /// 是否是系统消息状态
  bool get isSystemStatus {
    return this == MessageStatus.system;
  }

  /// 是否是进行中的状态
  bool get isInProgress {
    return this == MessageStatus.aiProcessing ||
        this == MessageStatus.aiPending ||
        this == MessageStatus.aiStreaming;
  }

  /// 是否是完成状态
  bool get isCompleted {
    return this == MessageStatus.userSuccess ||
        this == MessageStatus.aiSuccess ||
        this == MessageStatus.system;
  }

  /// 是否是错误状态
  bool get isError {
    return this == MessageStatus.aiError;
  }

  /// 是否是成功状态
  bool get isSuccess {
    return this == MessageStatus.userSuccess || this == MessageStatus.aiSuccess;
  }

  /// 是否应该持久化到数据库
  bool get shouldPersist {
    return this != MessageStatus.temporary;
  }

  /// 是否是临时状态
  bool get isTemporary {
    return this == MessageStatus.temporary ||
        this == MessageStatus.aiProcessing ||
        this == MessageStatus.aiPending ||
        this == MessageStatus.aiStreaming;
  }

  /// 是否可以重试
  bool get canRetry {
    return this == MessageStatus.aiError || this == MessageStatus.aiPaused;
  }

  /// 是否可以暂停
  bool get canPause {
    return this == MessageStatus.aiProcessing ||
        this == MessageStatus.aiStreaming;
  }

  /// 是否可以继续
  bool get canResume {
    return this == MessageStatus.aiPaused;
  }

  /// 是否显示加载指示器
  bool get showLoadingIndicator {
    return this == MessageStatus.aiProcessing ||
        this == MessageStatus.aiPending ||
        this == MessageStatus.aiStreaming;
  }

  /// 转换为数据库枚举索引（与database.dart中的DbMessageStatus对应）
  int get dbIndex {
    switch (this) {
      case MessageStatus.userSuccess:
        return 0;
      case MessageStatus.aiProcessing:
        return 1;
      case MessageStatus.aiPending:
        return 2;
      case MessageStatus.aiStreaming:
        return 3;
      case MessageStatus.aiSuccess:
        return 4;
      case MessageStatus.aiError:
        return 5;
      case MessageStatus.aiPaused:
        return 6;
      case MessageStatus.system:
        return 7;
      case MessageStatus.temporary:
        return 8;
    }
  }

  /// 从数据库枚举索引创建状态
  static MessageStatus fromDbIndex(int index) {
    switch (index) {
      case 0:
        return MessageStatus.userSuccess;
      case 1:
        return MessageStatus.aiProcessing;
      case 2:
        return MessageStatus.aiPending;
      case 3:
        return MessageStatus.aiStreaming;
      case 4:
        return MessageStatus.aiSuccess;
      case 5:
        return MessageStatus.aiError;
      case 6:
        return MessageStatus.aiPaused;
      case 7:
        return MessageStatus.system;
      case 8:
        return MessageStatus.temporary;
      default:
        return MessageStatus.userSuccess;
    }
  }
}
