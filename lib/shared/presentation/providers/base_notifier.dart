import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/logger_service.dart';

/// 统一错误处理基类
///
/// 为所有StateNotifier提供统一的错误处理机制，确保：
/// - 一致的错误日志记录
/// - 统一的错误状态管理
/// - 标准化的错误恢复流程
///
/// ## 使用方式
/// ```dart
/// class MyNotifier extends BaseNotifier<MyState> {
///   MyNotifier() : super(MyState.initial());
///
///   @override
///   void _updateErrorState(Object error, String context) {
///     state = state.copyWith(error: error.toString());
///   }
///
///   @override
///   void _clearErrorState() {
///     state = state.copyWith(error: null);
///   }
///
///   Future<void> doSomething() async {
///     try {
///       // 业务逻辑
///     } catch (error, stackTrace) {
///       handleError(error, stackTrace, '执行操作');
///     }
///   }
/// }
/// ```
abstract class BaseNotifier<T> extends StateNotifier<T> {
  BaseNotifier(super.state);

  final LoggerService _logger = LoggerService();

  /// 统一错误处理
  ///
  /// @param error 错误对象
  /// @param stackTrace 堆栈跟踪
  /// @param context 错误上下文描述
  /// @param shouldRethrow 是否重新抛出异常
  void handleError(
    Object error,
    StackTrace stackTrace,
    String context, {
    bool shouldRethrow = false,
  }) {
    _logger.error('$context 失败', {
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
      'context': context,
    });

    // 更新错误状态
    _updateErrorState(error, context);

    // 是否重新抛出异常
    if (shouldRethrow) {
      throw error;
    }
  }

  /// 清除错误状态
  void clearError() {
    _clearErrorState();
  }

  /// 子类需要实现的错误状态更新方法
  ///
  /// 根据具体的状态类型更新错误信息
  void _updateErrorState(Object error, String context);

  /// 子类需要实现的错误状态清除方法
  ///
  /// 清除状态中的错误信息
  void _clearErrorState();

  /// 安全执行异步操作
  ///
  /// 自动处理错误并记录日志
  Future<R?> safeExecute<R>(
    Future<R> Function() operation,
    String context, {
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context, shouldRethrow: shouldRethrow);
      return null;
    }
  }

  /// 安全执行同步操作
  ///
  /// 自动处理错误并记录日志
  R? safeExecuteSync<R>(
    R Function() operation,
    String context, {
    bool shouldRethrow = false,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context, shouldRethrow: shouldRethrow);
      return null;
    }
  }
}

/// 简单状态的基础Notifier
///
/// 适用于只需要基本错误处理的简单状态
abstract class SimpleBaseNotifier<T> extends BaseNotifier<T> {
  SimpleBaseNotifier(super.state);

  @override
  void _updateErrorState(Object error, String context) {
    // 简单状态通常不需要错误状态，只记录日志
  }

  @override
  void _clearErrorState() {
    // 简单状态通常不需要错误状态，什么都不做
  }
}
