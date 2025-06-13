import '../../domain/entities/message.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

/// 聊天错误处理服务
///
/// 专门处理AI聊天过程中的各种错误情况，提供统一的错误处理策略。
///
/// 核心功能：
/// - 🚨 **错误分类**: 区分网络错误、API错误、系统错误等
/// - 💬 **错误消息**: 创建用户友好的错误消息
/// - 🔄 **重试机制**: 支持自动重试和手动重试
/// - 📊 **错误统计**: 记录错误频率和类型
/// - 🎯 **智能恢复**: 根据错误类型提供恢复建议
class ChatErrorHandler {
  static final ChatErrorHandler _instance = ChatErrorHandler._internal();
  factory ChatErrorHandler() => _instance;
  ChatErrorHandler._internal();

  final LoggerService _logger = LoggerService();
  final NotificationService _notification = NotificationService();

  /// 处理聊天错误
  ///
  /// [error] 原始错误对象
  /// [originalMessage] 发生错误的原始消息
  /// [context] 错误上下文信息
  ///
  /// 返回处理后的错误消息对象
  Message handleChatError({
    required Object error,
    required Message originalMessage,
    Map<String, dynamic>? context,
  }) {
    final errorInfo = _analyzeError(error);

    // 记录错误日志
    _logger.error('聊天错误', {
      'error': error.toString(),
      'errorType': errorInfo.type.name,
      'messageId': originalMessage.id,
      'context': context,
    });

    // 显示用户通知
    _showErrorNotification(errorInfo);

    // 创建错误消息
    return originalMessage.copyWith(
      status: MessageStatus.error,
      errorInfo: errorInfo.userMessage,
      content:
          originalMessage.content.isEmpty ? '消息发送失败' : originalMessage.content,
    );
  }

  /// 处理流式消息错误
  Message handleStreamError({
    required Object error,
    required Message streamingMessage,
    String? partialContent,
  }) {
    final errorInfo = _analyzeError(error);

    _logger.error('流式消息错误', {
      'error': error.toString(),
      'errorType': errorInfo.type.name,
      'messageId': streamingMessage.id,
      'partialContentLength': partialContent?.length ?? 0,
    });

    _showErrorNotification(errorInfo);

    return streamingMessage.copyWith(
      status: MessageStatus.error,
      errorInfo: errorInfo.userMessage,
      content: partialContent ?? streamingMessage.content,
    );
  }

  /// 创建重试消息
  Message createRetryMessage({
    required Message failedMessage,
    required String retryReason,
  }) {
    return failedMessage.copyWith(
      status: MessageStatus.sending,
      errorInfo: null,
      timestamp: DateTime.now(),
    );
  }

  /// 分析错误类型和原因
  ChatErrorInfo _analyzeError(Object error) {
    final errorString = error.toString().toLowerCase();

    // 网络相关错误
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return ChatErrorInfo(
        type: ChatErrorType.network,
        originalError: error,
        userMessage: '网络连接失败，请检查网络设置后重试',
        canRetry: true,
        retryDelay: const Duration(seconds: 3),
      );
    }

    // API相关错误
    if (errorString.contains('api') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return ChatErrorInfo(
        type: ChatErrorType.api,
        originalError: error,
        userMessage: 'API调用失败，请检查配置或稍后重试',
        canRetry: true,
        retryDelay: const Duration(seconds: 5),
      );
    }

    // 限流错误
    if (errorString.contains('rate limit') ||
        errorString.contains('too many requests') ||
        errorString.contains('429')) {
      return ChatErrorInfo(
        type: ChatErrorType.rateLimit,
        originalError: error,
        userMessage: '请求过于频繁，请稍后再试',
        canRetry: true,
        retryDelay: const Duration(seconds: 30),
      );
    }

    // 服务器错误
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return ChatErrorInfo(
        type: ChatErrorType.server,
        originalError: error,
        userMessage: '服务器暂时不可用，请稍后重试',
        canRetry: true,
        retryDelay: const Duration(seconds: 10),
      );
    }

    // 内容过滤错误
    if (errorString.contains('content filter') ||
        errorString.contains('inappropriate') ||
        errorString.contains('violation')) {
      return ChatErrorInfo(
        type: ChatErrorType.contentFilter,
        originalError: error,
        userMessage: '消息内容不符合使用规范，请修改后重试',
        canRetry: false,
      );
    }

    // 默认未知错误
    return ChatErrorInfo(
      type: ChatErrorType.unknown,
      originalError: error,
      userMessage: '发生未知错误，请重试',
      canRetry: true,
      retryDelay: const Duration(seconds: 5),
    );
  }

  /// 显示错误通知
  void _showErrorNotification(ChatErrorInfo errorInfo) {
    switch (errorInfo.type) {
      case ChatErrorType.network:
        _notification.showError(
          errorInfo.userMessage,
          importance: NotificationImportance.medium,
        );
        break;
      case ChatErrorType.api:
      case ChatErrorType.server:
        _notification.showError(
          errorInfo.userMessage,
          importance: NotificationImportance.high,
        );
        break;
      case ChatErrorType.rateLimit:
        _notification.showWarning(
          errorInfo.userMessage,
          importance: NotificationImportance.medium,
        );
        break;
      case ChatErrorType.contentFilter:
        _notification.showWarning(
          errorInfo.userMessage,
          importance: NotificationImportance.high,
        );
        break;
      case ChatErrorType.unknown:
        _notification.showError(
          errorInfo.userMessage,
          importance: NotificationImportance.medium,
        );
        break;
    }
  }
}

/// 聊天错误类型
enum ChatErrorType {
  network, // 网络错误
  api, // API错误
  server, // 服务器错误
  rateLimit, // 限流错误
  contentFilter, // 内容过滤错误
  unknown, // 未知错误
}

/// 聊天错误信息
class ChatErrorInfo {
  final ChatErrorType type;
  final Object originalError;
  final String userMessage;
  final bool canRetry;
  final Duration? retryDelay;

  const ChatErrorInfo({
    required this.type,
    required this.originalError,
    required this.userMessage,
    required this.canRetry,
    this.retryDelay,
  });
}
