import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_ai_configuration.dart';

part 'ai_configuration_state.freezed.dart';

/// AI配置状态聚合模型
/// 
/// 统一管理AI配置的所有相关状态信息，包括：
/// - 配置数据本身
/// - 验证状态和错误信息
/// - 配置状态和时间戳
/// - 警告信息和加载状态
@freezed
class AiConfigurationState with _$AiConfigurationState {
  const factory AiConfigurationState({
    required UserAiConfiguration configuration,
    required bool isValid,
    required ConfigurationStatus status,
    required DateTime lastUpdated,
    required List<ValidationError> validationErrors,
    @Default([]) List<String> warnings,
    @Default(false) bool isLoading,
  }) = _AiConfigurationState;

  const AiConfigurationState._();

  /// 是否有错误
  bool get hasErrors => validationErrors.isNotEmpty;

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  /// 是否可以使用
  bool get isUsable => isValid && !isLoading && status == ConfigurationStatus.ready;

  /// 获取主要错误信息
  String? get primaryError => validationErrors.isNotEmpty ? validationErrors.first.message : null;

  /// 获取错误数量
  int get errorCount => validationErrors.length;

  /// 获取警告数量
  int get warningCount => warnings.length;

  /// 是否需要用户注意（有错误或警告）
  bool get needsAttention => hasErrors || hasWarnings;

  /// 获取状态描述
  String get statusDescription {
    switch (status) {
      case ConfigurationStatus.notConfigured:
        return '未配置';
      case ConfigurationStatus.configuring:
        return '配置中';
      case ConfigurationStatus.validating:
        return '验证中';
      case ConfigurationStatus.ready:
        return '就绪';
      case ConfigurationStatus.error:
        return '错误';
    }
  }
}

/// 配置状态枚举
enum ConfigurationStatus {
  notConfigured,  // 未配置
  configuring,    // 配置中
  validating,     // 验证中
  ready,          // 就绪
  error,          // 错误
}

/// 验证错误模型
@freezed
class ValidationError with _$ValidationError {
  const factory ValidationError({
    required String field,
    required String message,
    required ValidationErrorType type,
    String? code,
    Map<String, dynamic>? details,
  }) = _ValidationError;

  const ValidationError._();

  /// 是否为严重错误
  bool get isCritical => type == ValidationErrorType.required || type == ValidationErrorType.connection;

  /// 获取错误级别
  ErrorLevel get level {
    switch (type) {
      case ValidationErrorType.required:
        return ErrorLevel.critical;
      case ValidationErrorType.connection:
        return ErrorLevel.high;
      case ValidationErrorType.invalid:
        return ErrorLevel.medium;
      case ValidationErrorType.permission:
        return ErrorLevel.low;
    }
  }
}

/// 验证错误类型
enum ValidationErrorType {
  required,       // 必填字段
  invalid,        // 无效值
  connection,     // 连接错误
  permission,     // 权限错误
}

/// 错误级别
enum ErrorLevel {
  critical,       // 严重错误
  high,           // 高级错误
  medium,         // 中级错误
  low,            // 低级错误
}
