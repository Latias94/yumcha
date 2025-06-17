/// 聊天系统异常定义
///
/// 定义聊天系统中可能出现的各种异常类型，
/// 提供详细的错误信息和恢复建议。

/// 聊天系统基础异常
abstract class ChatException implements Exception {
  /// 错误消息
  final String message;

  /// 错误代码
  final String code;

  /// 原始异常
  final Exception? cause;

  /// 错误详情
  final Map<String, dynamic>? details;

  const ChatException({
    required this.message,
    required this.code,
    this.cause,
    this.details,
  });

  @override
  String toString() {
    return 'ChatException(code: $code, message: $message, cause: $cause)';
  }
}

/// 消息相关异常
class MessageException extends ChatException {
  const MessageException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// 消息不存在
  factory MessageException.notFound(String messageId) {
    return MessageException(
      message: '消息不存在: $messageId',
      code: 'MESSAGE_NOT_FOUND',
      details: {'messageId': messageId},
    );
  }

  /// 消息格式无效
  factory MessageException.invalidFormat(String reason) {
    return MessageException(
      message: '消息格式无效: $reason',
      code: 'MESSAGE_INVALID_FORMAT',
      details: {'reason': reason},
    );
  }

  /// 消息块不存在
  factory MessageException.blockNotFound(String blockId) {
    return MessageException(
      message: '消息块不存在: $blockId',
      code: 'MESSAGE_BLOCK_NOT_FOUND',
      details: {'blockId': blockId},
    );
  }

  /// 消息状态无效
  factory MessageException.invalidStatus(
      String currentStatus, String targetStatus) {
    return MessageException(
      message: '无法从状态 $currentStatus 转换到 $targetStatus',
      code: 'MESSAGE_INVALID_STATUS_TRANSITION',
      details: {
        'currentStatus': currentStatus,
        'targetStatus': targetStatus,
      },
    );
  }
}

/// 消息块相关异常
class MessageBlockException extends ChatException {
  const MessageBlockException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// 消息块类型不支持
  factory MessageBlockException.unsupportedType(String blockType) {
    return MessageBlockException(
      message: '不支持的消息块类型: $blockType',
      code: 'BLOCK_UNSUPPORTED_TYPE',
      details: {'blockType': blockType},
    );
  }

  /// 消息块内容无效
  factory MessageBlockException.invalidContent(String blockId, String reason) {
    return MessageBlockException(
      message: '消息块内容无效: $reason',
      code: 'BLOCK_INVALID_CONTENT',
      details: {'blockId': blockId, 'reason': reason},
    );
  }

  /// 消息块顺序错误
  factory MessageBlockException.invalidOrder(
      String blockId, int currentOrder, int targetOrder) {
    return MessageBlockException(
      message: '消息块顺序错误: 当前 $currentOrder, 目标 $targetOrder',
      code: 'BLOCK_INVALID_ORDER',
      details: {
        'blockId': blockId,
        'currentOrder': currentOrder,
        'targetOrder': targetOrder,
      },
    );
  }
}

/// 对话相关异常
class ConversationException extends ChatException {
  const ConversationException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// 对话不存在
  factory ConversationException.notFound(String conversationId) {
    return ConversationException(
      message: '对话不存在: $conversationId',
      code: 'CONVERSATION_NOT_FOUND',
      details: {'conversationId': conversationId},
    );
  }

  /// 对话已结束
  factory ConversationException.ended(String conversationId) {
    return ConversationException(
      message: '对话已结束: $conversationId',
      code: 'CONVERSATION_ENDED',
      details: {'conversationId': conversationId},
    );
  }

  /// 对话消息过多
  factory ConversationException.tooManyMessages(
      String conversationId, int messageCount, int maxCount) {
    return ConversationException(
      message: '对话消息过多: $messageCount/$maxCount',
      code: 'CONVERSATION_TOO_MANY_MESSAGES',
      details: {
        'conversationId': conversationId,
        'messageCount': messageCount,
        'maxCount': maxCount,
      },
    );
  }
}

/// AI服务相关异常
class AiServiceException extends ChatException {
  const AiServiceException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// AI服务不可用
  factory AiServiceException.unavailable(String serviceName) {
    return AiServiceException(
      message: 'AI服务不可用: $serviceName',
      code: 'AI_SERVICE_UNAVAILABLE',
      details: {'serviceName': serviceName},
    );
  }

  /// API配额超限
  factory AiServiceException.quotaExceeded(String serviceName) {
    return AiServiceException(
      message: 'API配额超限: $serviceName',
      code: 'AI_SERVICE_QUOTA_EXCEEDED',
      details: {'serviceName': serviceName},
    );
  }

  /// 模型不支持
  factory AiServiceException.modelNotSupported(String modelName) {
    return AiServiceException(
      message: '模型不支持: $modelName',
      code: 'AI_SERVICE_MODEL_NOT_SUPPORTED',
      details: {'modelName': modelName},
    );
  }

  /// 流式响应中断
  factory AiServiceException.streamInterrupted(String reason) {
    return AiServiceException(
      message: '流式响应中断: $reason',
      code: 'AI_SERVICE_STREAM_INTERRUPTED',
      details: {'reason': reason},
    );
  }
}

/// 数据库相关异常
class DatabaseException extends ChatException {
  const DatabaseException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// 数据库连接失败
  factory DatabaseException.connectionFailed(Exception cause) {
    return DatabaseException(
      message: '数据库连接失败',
      code: 'DATABASE_CONNECTION_FAILED',
      cause: cause,
    );
  }

  /// 数据库操作失败
  factory DatabaseException.operationFailed(String operation, Exception cause) {
    return DatabaseException(
      message: '数据库操作失败: $operation',
      code: 'DATABASE_OPERATION_FAILED',
      cause: cause,
      details: {'operation': operation},
    );
  }

  /// 数据库迁移失败
  factory DatabaseException.migrationFailed(
      int fromVersion, int toVersion, Exception cause) {
    return DatabaseException(
      message: '数据库迁移失败: v$fromVersion -> v$toVersion',
      code: 'DATABASE_MIGRATION_FAILED',
      cause: cause,
      details: {
        'fromVersion': fromVersion,
        'toVersion': toVersion,
      },
    );
  }
}

/// 验证相关异常
class ValidationException extends ChatException {
  const ValidationException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// 参数无效
  factory ValidationException.invalidParameter(
      String parameterName, String reason) {
    return ValidationException(
      message: '参数无效: $parameterName - $reason',
      code: 'VALIDATION_INVALID_PARAMETER',
      details: {
        'parameterName': parameterName,
        'reason': reason,
      },
    );
  }

  /// 数据格式错误
  factory ValidationException.invalidFormat(
      String fieldName, String expectedFormat) {
    return ValidationException(
      message: '数据格式错误: $fieldName，期望格式: $expectedFormat',
      code: 'VALIDATION_INVALID_FORMAT',
      details: {
        'fieldName': fieldName,
        'expectedFormat': expectedFormat,
      },
    );
  }

  /// 必填字段缺失
  factory ValidationException.requiredFieldMissing(String fieldName) {
    return ValidationException(
      message: '必填字段缺失: $fieldName',
      code: 'VALIDATION_REQUIRED_FIELD_MISSING',
      details: {'fieldName': fieldName},
    );
  }
}

/// 权限相关异常
class PermissionException extends ChatException {
  const PermissionException({
    required super.message,
    required super.code,
    super.cause,
    super.details,
  });

  /// 操作未授权
  factory PermissionException.unauthorized(String operation) {
    return PermissionException(
      message: '操作未授权: $operation',
      code: 'PERMISSION_UNAUTHORIZED',
      details: {'operation': operation},
    );
  }

  /// 资源访问被拒绝
  factory PermissionException.accessDenied(
      String resourceType, String resourceId) {
    return PermissionException(
      message: '资源访问被拒绝: $resourceType($resourceId)',
      code: 'PERMISSION_ACCESS_DENIED',
      details: {
        'resourceType': resourceType,
        'resourceId': resourceId,
      },
    );
  }
}
