import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/infrastructure/services/logger_service.dart';
import '../../shared/infrastructure/services/notification_service.dart';

/// 错误类型枚举
enum ErrorType { network, database, api, validation, permission, unknown }

/// 应用错误基类
class AppError implements Exception {
  final String message;
  final ErrorType type;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    required this.type,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError($type): $message';
}

/// 网络错误
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          type: ErrorType.network,
        );
}

/// 数据库错误
class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          type: ErrorType.database,
        );
}

/// API错误
class ApiError extends AppError {
  final int? statusCode;

  const ApiError({
    required super.message,
    this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          type: ErrorType.api,
        );
}

/// 验证错误
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  const ValidationError({
    required super.message,
    this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          type: ErrorType.validation,
        );
}

/// 权限错误
class PermissionError extends AppError {
  const PermissionError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          type: ErrorType.permission,
        );
}

/// 统一错误处理工具类
class ErrorHandler {
  static final LoggerService _logger = LoggerService();

  /// 处理异步操作错误
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? context,
    bool showUserError = true,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);

      if (showUserError) {
        _showUserError(error, context);
      }

      return fallbackValue;
    }
  }

  /// 处理同步操作错误
  static T? handleSync<T>(
    T Function() operation, {
    String? context,
    bool showUserError = true,
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);

      if (showUserError) {
        _showUserError(error, context);
      }

      return fallbackValue;
    }
  }

  /// 记录错误日志
  static void _logError(dynamic error, StackTrace stackTrace, String? context) {
    final contextInfo = context != null ? '[$context] ' : '';

    if (kDebugMode) {
      _logger.error(
        '${contextInfo}Error occurred: ${error.toString()}',
        error,
        stackTrace,
      );
    } else {
      // 生产环境只记录错误信息，不记录堆栈跟踪
      _logger.error('${contextInfo}Error occurred: ${error.toString()}');
    }
  }

  /// 将原始错误转换为应用错误
  static AppError convertToAppError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    // 网络相关错误
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return NetworkError(
        message: '网络连接失败',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // 数据库相关错误
    if (errorString.contains('database') ||
        errorString.contains('sql') ||
        errorString.contains('sqlite')) {
      return DatabaseError(
        message: '数据操作失败',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // API相关错误
    if (errorString.contains('api') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return ApiError(
        message: 'API调用失败',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // 权限相关错误
    if (errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return PermissionError(
        message: '权限不足',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // 默认为未知错误
    return AppError(
      message: error.toString(),
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// 显示用户友好的错误信息
  static void _showUserError(dynamic error, String? context) {
    String userMessage = _getUserFriendlyMessage(error, context);
    NotificationService().showError(userMessage);
  }

  /// 获取用户友好的错误信息
  static String _getUserFriendlyMessage(dynamic error, String? context) {
    if (error is AppError) {
      return _getAppErrorMessage(error, context);
    }
    final errorString = error.toString().toLowerCase();

    // 网络相关错误
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return '网络连接失败，请检查网络设置';
    }

    // 数据库相关错误
    if (errorString.contains('database') || errorString.contains('sql')) {
      return '数据操作失败，请稍后重试';
    }

    // API相关错误
    if (errorString.contains('api') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return 'API调用失败，请检查配置';
    }

    // 文件相关错误
    if (errorString.contains('file') || errorString.contains('permission')) {
      return '文件操作失败，请检查权限';
    }

    // 默认错误信息
    final contextInfo = context != null ? '$context: ' : '';
    return '$contextInfo操作失败，请稍后重试';
  }

  /// 获取应用错误的用户友好信息
  static String _getAppErrorMessage(AppError error, String? context) {
    final contextInfo = context != null ? '$context: ' : '';

    switch (error.type) {
      case ErrorType.network:
        return '$contextInfo网络连接失败，请检查网络设置';
      case ErrorType.database:
        return '$contextInfo数据操作失败，请稍后重试';
      case ErrorType.api:
        if (error is ApiError && error.statusCode == 401) {
          return '$contextInfo认证失败，请重新登录';
        } else if (error is ApiError && error.statusCode == 403) {
          return '$contextInfo权限不足，无法执行此操作';
        }
        return '$contextInfo服务调用失败，请稍后重试';
      case ErrorType.validation:
        return '$contextInfo输入数据有误，请检查后重试';
      case ErrorType.permission:
        return '$contextInfo权限不足，请检查应用权限设置';
      case ErrorType.unknown:
        return '$contextInfo操作失败，请稍后重试';
    }
  }

  /// 处理Riverpod Provider错误
  static AsyncValue<T> handleProviderError<T>(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
  }) {
    _logError(error, stackTrace, context);
    return AsyncValue.error(error, stackTrace);
  }

  /// 安全执行操作（不抛出异常）
  static Future<bool> safeExecute(
    Future<void> Function() operation, {
    String? context,
    bool showUserError = false,
  }) async {
    try {
      await operation();
      return true;
    } catch (error, stackTrace) {
      _logError(error, stackTrace, context);

      if (showUserError) {
        _showUserError(error, context);
      }

      return false;
    }
  }
}

/// 扩展方法，为Future添加错误处理
extension FutureErrorHandling<T> on Future<T> {
  /// 安全执行，自动处理错误
  Future<T?> safely({
    String? context,
    bool showUserError = true,
    T? fallbackValue,
  }) {
    return ErrorHandler.handleAsync<T>(
      () => this,
      context: context,
      showUserError: showUserError,
      fallbackValue: fallbackValue,
    );
  }
}

/// 扩展方法，为函数添加错误处理
extension FunctionErrorHandling<T> on T Function() {
  /// 安全执行，自动处理错误
  T? safely({String? context, bool showUserError = true, T? fallbackValue}) {
    return ErrorHandler.handleSync<T>(
      this,
      context: context,
      showUserError: showUserError,
      fallbackValue: fallbackValue,
    );
  }
}
