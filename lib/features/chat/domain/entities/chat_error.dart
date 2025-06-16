/// 聊天错误类型枚举
enum ChatErrorType {
  /// 网络错误
  network,
  /// 认证错误
  authentication,
  /// 配额错误
  quota,
  /// 验证错误
  validation,
  /// 服务器错误
  server,
  /// 流式处理错误
  streaming,
  /// 数据持久化错误
  persistence,
  /// 未知错误
  unknown,
}

/// 聊天错误实体
class ChatError implements Exception {
  /// 错误类型
  final ChatErrorType type;
  
  /// 错误消息
  final String message;
  
  /// 原始错误
  final dynamic originalError;
  
  /// 错误上下文
  final String? context;
  
  /// 错误代码
  final String? code;
  
  /// 错误元数据
  final Map<String, dynamic>? metadata;
  
  /// 是否可重试
  final bool isRetryable;
  
  /// 错误时间戳
  final DateTime timestamp;
  
  ChatError({
    required this.type,
    required this.message,
    this.originalError,
    this.context,
    this.code,
    this.metadata,
    this.isRetryable = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 创建网络错误
  factory ChatError.network({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.network,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: true,
    );
  }
  
  /// 创建认证错误
  factory ChatError.authentication({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.authentication,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: false,
    );
  }
  
  /// 创建配额错误
  factory ChatError.quota({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.quota,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: true,
    );
  }
  
  /// 创建验证错误
  factory ChatError.validation({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.validation,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: false,
    );
  }
  
  /// 创建服务器错误
  factory ChatError.server({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.server,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: true,
    );
  }
  
  /// 创建流式处理错误
  factory ChatError.streaming({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.streaming,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: true,
    );
  }
  
  /// 创建数据持久化错误
  factory ChatError.persistence({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.persistence,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: true,
    );
  }
  
  /// 创建未知错误
  factory ChatError.unknown({
    required String message,
    dynamic originalError,
    String? context,
    String? code,
    Map<String, dynamic>? metadata,
  }) {
    return ChatError(
      type: ChatErrorType.unknown,
      message: message,
      originalError: originalError,
      context: context,
      code: code,
      metadata: metadata,
      isRetryable: false,
    );
  }
  
  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    switch (type) {
      case ChatErrorType.network:
        return '网络连接失败，请检查网络设置后重试';
      case ChatErrorType.authentication:
        return 'API认证失败，请检查配置';
      case ChatErrorType.quota:
        return 'API配额已用完，请稍后重试';
      case ChatErrorType.validation:
        return '请求参数无效，请检查输入';
      case ChatErrorType.server:
        return '服务器暂时不可用，请稍后重试';
      case ChatErrorType.streaming:
        return '消息处理中断，请重新发送';
      case ChatErrorType.persistence:
        return '数据保存失败，请重试';
      case ChatErrorType.unknown:
        return '发生未知错误，请重试';
    }
  }
  
  /// 获取错误的严重程度
  ErrorSeverity get severity {
    switch (type) {
      case ChatErrorType.network:
      case ChatErrorType.quota:
      case ChatErrorType.server:
        return ErrorSeverity.warning;
      case ChatErrorType.authentication:
      case ChatErrorType.validation:
        return ErrorSeverity.error;
      case ChatErrorType.streaming:
      case ChatErrorType.persistence:
        return ErrorSeverity.info;
      case ChatErrorType.unknown:
        return ErrorSeverity.critical;
    }
  }
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('ChatError(');
    buffer.write('type: $type, ');
    buffer.write('message: $message');
    if (context != null) buffer.write(', context: $context');
    if (code != null) buffer.write(', code: $code');
    buffer.write(', isRetryable: $isRetryable');
    buffer.write(', timestamp: $timestamp');
    buffer.write(')');
    return buffer.toString();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatError &&
           other.type == type &&
           other.message == message &&
           other.context == context &&
           other.code == code;
  }
  
  @override
  int get hashCode {
    return Object.hash(type, message, context, code);
  }
}

/// 错误严重程度
enum ErrorSeverity {
  /// 信息级别
  info,
  /// 警告级别
  warning,
  /// 错误级别
  error,
  /// 严重错误级别
  critical,
}
