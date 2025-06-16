import 'dart:developer' as developer;
import '../../domain/entities/chat_error.dart';

/// 统一错误处理中间件
/// 
/// 提供标准化的错误处理、日志记录和用户友好的错误消息
class ErrorHandlingMiddleware {
  static const String _loggerName = 'ChatErrorHandler';
  
  /// 处理聊天相关错误
  static ChatError handleChatError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    // 记录错误日志
    _logError(error, context: context, metadata: metadata);
    
    // 转换为标准化的ChatError
    if (error is ChatError) {
      return error;
    }
    
    // 根据错误类型创建相应的ChatError
    return _createChatError(error, context: context);
  }
  
  /// 处理流式消息错误
  static ChatError handleStreamingError(
    dynamic error, {
    String? messageId,
    String? conversationId,
  }) {
    final context = 'Streaming message processing';
    final metadata = {
      if (messageId != null) 'messageId': messageId,
      if (conversationId != null) 'conversationId': conversationId,
    };
    
    return handleChatError(
      error,
      context: context,
      metadata: metadata,
    );
  }
  
  /// 处理AI服务错误
  static ChatError handleAiServiceError(
    dynamic error, {
    String? provider,
    String? model,
    String? operation,
  }) {
    final context = 'AI service operation: ${operation ?? 'unknown'}';
    final metadata = {
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (operation != null) 'operation': operation,
    };
    
    return handleChatError(
      error,
      context: context,
      metadata: metadata,
    );
  }
  
  /// 处理数据持久化错误
  static ChatError handlePersistenceError(
    dynamic error, {
    String? operation,
    String? entityType,
    String? entityId,
  }) {
    final context = 'Data persistence: ${operation ?? 'unknown'}';
    final metadata = {
      if (operation != null) 'operation': operation,
      if (entityType != null) 'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
    };
    
    return handleChatError(
      error,
      context: context,
      metadata: metadata,
    );
  }
  
  /// 记录错误日志
  static void _logError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final message = [
      if (context != null) '[$context]',
      error.toString(),
      if (metadata != null && metadata.isNotEmpty) 
        'Metadata: ${metadata.toString()}',
    ].join(' ');
    
    developer.log(
      message,
      name: _loggerName,
      error: error,
      stackTrace: error is Error ? error.stackTrace : null,
    );
  }
  
  /// 创建标准化的ChatError
  static ChatError _createChatError(
    dynamic error, {
    String? context,
  }) {
    // 网络相关错误
    if (_isNetworkError(error)) {
      return ChatError.network(
        message: '网络连接失败，请检查网络设置',
        originalError: error,
        context: context,
      );
    }
    
    // 认证相关错误
    if (_isAuthError(error)) {
      return ChatError.authentication(
        message: 'API认证失败，请检查配置',
        originalError: error,
        context: context,
      );
    }
    
    // 配额相关错误
    if (_isQuotaError(error)) {
      return ChatError.quota(
        message: 'API配额已用完，请稍后重试',
        originalError: error,
        context: context,
      );
    }
    
    // 参数验证错误
    if (_isValidationError(error)) {
      return ChatError.validation(
        message: '请求参数无效',
        originalError: error,
        context: context,
      );
    }
    
    // 服务器错误
    if (_isServerError(error)) {
      return ChatError.server(
        message: '服务器暂时不可用，请稍后重试',
        originalError: error,
        context: context,
      );
    }
    
    // 默认为未知错误
    return ChatError.unknown(
      message: '发生未知错误，请重试',
      originalError: error,
      context: context,
    );
  }
  
  /// 判断是否为网络错误
  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('unreachable');
  }
  
  /// 判断是否为认证错误
  static bool _isAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unauthorized') ||
           errorString.contains('authentication') ||
           errorString.contains('invalid api key') ||
           errorString.contains('401');
  }
  
  /// 判断是否为配额错误
  static bool _isQuotaError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('quota') ||
           errorString.contains('rate limit') ||
           errorString.contains('429') ||
           errorString.contains('too many requests');
  }
  
  /// 判断是否为验证错误
  static bool _isValidationError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('validation') ||
           errorString.contains('invalid parameter') ||
           errorString.contains('bad request') ||
           errorString.contains('400');
  }
  
  /// 判断是否为服务器错误
  static bool _isServerError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('server error') ||
           errorString.contains('internal server') ||
           errorString.contains('500') ||
           errorString.contains('502') ||
           errorString.contains('503') ||
           errorString.contains('504');
  }
}

/// 错误处理扩展方法
extension ErrorHandlingExtension on Future {
  /// 为Future添加统一的错误处理
  Future<T> handleChatError<T>({
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await this as T;
    } catch (error) {
      throw ErrorHandlingMiddleware.handleChatError(
        error,
        context: context,
        metadata: metadata,
      );
    }
  }
}

/// 流式错误处理扩展
extension StreamErrorHandlingExtension<T> on Stream<T> {
  /// 为Stream添加统一的错误处理
  Stream<T> handleChatError({
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return handleError((error) {
      throw ErrorHandlingMiddleware.handleChatError(
        error,
        context: context,
        metadata: metadata,
      );
    });
  }
}
