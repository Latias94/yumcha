import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_status_summary.freezed.dart';

/// 聊天状态摘要模型
///
/// 统一管理聊天相关的所有状态信息，包括：
/// - 加载状态和错误信息
/// - 消息统计和流式状态
/// - 准备状态和连接状态
/// - 性能指标和时间戳
@freezed
class ChatStatusSummary with _$ChatStatusSummary {
  const factory ChatStatusSummary({
    required bool isLoading,
    required bool isReady,
    required bool hasStreamingMessages,
    required int totalMessages,
    required int pendingMessages,
    required int errorMessages,
    required List<ChatError> errors,
    required DateTime lastUpdated,
    @Default([]) List<String> warnings,
    @Default(false) bool isConnected,
    @Default(0) int activeConnections,
    ChatPerformanceMetrics? performance,
  }) = _ChatStatusSummary;

  const ChatStatusSummary._();

  /// 是否有错误
  bool get hasErrors => errors.isNotEmpty;

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  /// 是否可以发送消息
  bool get canSendMessage => isReady && isConnected && !isLoading;

  /// 获取主要错误信息
  String? get primaryError => errors.isNotEmpty ? errors.first.message : null;

  /// 获取错误数量
  int get errorCount => errors.length;

  /// 获取警告数量
  int get warningCount => warnings.length;

  /// 是否需要用户注意
  bool get needsAttention => hasErrors || hasWarnings || !isConnected;

  /// 获取状态描述
  String get statusDescription {
    if (!isConnected) return '连接断开';
    if (isLoading) return '加载中';
    if (hasErrors) return '发生错误';
    if (hasStreamingMessages) return '流式响应中';
    if (isReady) return '就绪';
    return '未知状态';
  }

  /// 获取消息统计摘要
  String get messagesSummary =>
      '总计: $totalMessages, 待处理: $pendingMessages, 错误: $errorMessages';

  /// 是否处于活跃状态
  bool get isActive => isLoading || hasStreamingMessages || pendingMessages > 0;

  /// 获取健康状态
  HealthStatus get healthStatus {
    if (!isConnected) return HealthStatus.critical;
    if (hasErrors) return HealthStatus.warning;
    if (hasWarnings) return HealthStatus.caution;
    return HealthStatus.healthy;
  }
}

/// 聊天错误模型
@freezed
class ChatError with _$ChatError {
  const factory ChatError({
    required String id,
    required String message,
    required ChatErrorType type,
    required DateTime timestamp,
    String? code,
    String? conversationId,
    String? messageId,
    Map<String, dynamic>? details,
  }) = _ChatError;

  const ChatError._();

  /// 是否为严重错误
  bool get isCritical =>
      type == ChatErrorType.connection || type == ChatErrorType.authentication;

  /// 获取错误级别
  ErrorLevel get level {
    switch (type) {
      case ChatErrorType.connection:
        return ErrorLevel.critical;
      case ChatErrorType.authentication:
        return ErrorLevel.high;
      case ChatErrorType.rateLimit:
        return ErrorLevel.medium;
      case ChatErrorType.validation:
        return ErrorLevel.low;
      case ChatErrorType.timeout:
        return ErrorLevel.medium;
      case ChatErrorType.unknown:
        return ErrorLevel.low;
    }
  }

  /// 是否可以重试
  bool get canRetry {
    switch (type) {
      case ChatErrorType.connection:
      case ChatErrorType.timeout:
      case ChatErrorType.rateLimit:
        return true;
      case ChatErrorType.authentication:
      case ChatErrorType.validation:
      case ChatErrorType.unknown:
        return false;
    }
  }
}

/// 聊天错误类型
enum ChatErrorType {
  connection, // 连接错误
  authentication, // 认证错误
  rateLimit, // 速率限制
  validation, // 验证错误
  timeout, // 超时错误
  unknown, // 未知错误
}

/// 错误级别
enum ErrorLevel {
  critical, // 严重错误
  high, // 高级错误
  medium, // 中级错误
  low, // 低级错误
}

/// 健康状态
enum HealthStatus {
  healthy, // 健康
  caution, // 注意
  warning, // 警告
  critical, // 严重
}

/// 聊天性能指标
@freezed
class ChatPerformanceMetrics with _$ChatPerformanceMetrics {
  const factory ChatPerformanceMetrics({
    required double averageResponseTime,
    required double lastResponseTime,
    required int totalRequests,
    required int successfulRequests,
    required int failedRequests,
    required DateTime lastMeasurement,
  }) = _ChatPerformanceMetrics;

  const ChatPerformanceMetrics._();

  /// 成功率
  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;

  /// 失败率
  double get failureRate =>
      totalRequests > 0 ? failedRequests / totalRequests : 0.0;

  /// 性能等级
  PerformanceLevel get performanceLevel {
    if (averageResponseTime < 1000) return PerformanceLevel.excellent;
    if (averageResponseTime < 3000) return PerformanceLevel.good;
    if (averageResponseTime < 5000) return PerformanceLevel.fair;
    return PerformanceLevel.poor;
  }
}

/// 性能等级
enum PerformanceLevel {
  excellent, // 优秀
  good, // 良好
  fair, // 一般
  poor, // 较差
}
