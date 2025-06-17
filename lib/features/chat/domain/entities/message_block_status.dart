/// 消息块状态枚举
///
/// 定义消息块的处理状态，支持流式处理和错误处理
enum MessageBlockStatus {
  /// 等待处理
  pending,

  /// 正在处理
  processing,

  /// 正在流式接收
  streaming,

  /// 处理成功
  success,

  /// 处理错误
  error,

  /// 处理暂停
  paused,
}

/// 消息块状态扩展方法
extension MessageBlockStatusExtension on MessageBlockStatus {
  /// 获取状态的显示名称
  String get displayName {
    switch (this) {
      case MessageBlockStatus.pending:
        return '等待中';
      case MessageBlockStatus.processing:
        return '处理中';
      case MessageBlockStatus.streaming:
        return '接收中';
      case MessageBlockStatus.success:
        return '完成';
      case MessageBlockStatus.error:
        return '错误';
      case MessageBlockStatus.paused:
        return '暂停';
    }
  }

  /// 是否是进行中的状态
  bool get isInProgress {
    return this == MessageBlockStatus.pending ||
        this == MessageBlockStatus.processing ||
        this == MessageBlockStatus.streaming;
  }

  /// 是否是完成状态
  bool get isCompleted {
    return this == MessageBlockStatus.success ||
        this == MessageBlockStatus.error;
  }

  /// 是否是错误状态
  bool get isError {
    return this == MessageBlockStatus.error;
  }

  /// 是否是成功状态
  bool get isSuccess {
    return this == MessageBlockStatus.success;
  }

  /// 是否可以重试
  bool get canRetry {
    return this == MessageBlockStatus.error ||
        this == MessageBlockStatus.paused;
  }

  /// 是否可以暂停
  bool get canPause {
    return this == MessageBlockStatus.processing ||
        this == MessageBlockStatus.streaming;
  }

  /// 是否可以继续
  bool get canResume {
    return this == MessageBlockStatus.paused;
  }

  /// 是否显示加载指示器
  bool get showLoadingIndicator {
    return this == MessageBlockStatus.processing ||
        this == MessageBlockStatus.streaming;
  }
}
