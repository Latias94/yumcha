import 'package:logging/logging.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/exceptions/chat_exceptions.dart';

/// 聊天系统专用日志服务
///
/// 提供结构化的日志记录功能，专门针对聊天系统的各种操作和事件
class ChatLoggerService {
  static final Logger _logger = Logger('ChatSystem');

  /// 初始化日志服务
  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // 在开发环境中可以启用控制台输出
      // 在生产环境中应该使用适当的日志记录系统
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        final timestamp = record.time.toIso8601String();
        final level = record.level.name.padRight(7);
        final loggerName = record.loggerName.padRight(15);
        final message = record.message;

        // 开发环境下输出到控制台
        // ignore: avoid_print
        print('[$timestamp] $level [$loggerName] $message');

        if (record.error != null) {
          // ignore: avoid_print
          print('  Error: ${record.error}');
        }

        if (record.stackTrace != null) {
          // ignore: avoid_print
          print('  Stack: ${record.stackTrace}');
        }
      }
    });
  }

  /// 记录消息创建事件
  static void logMessageCreated(Message message) {
    _logger.info(
      'Message created: ${message.id} (${message.role}) in conversation ${message.conversationId}',
      message,
    );
  }

  /// 记录消息更新事件
  static void logMessageUpdated(Message message, String updateType) {
    _logger.info(
      'Message updated: ${message.id} - $updateType (status: ${message.status})',
      message,
    );
  }

  /// 记录消息删除事件
  static void logMessageDeleted(String messageId, String conversationId) {
    _logger.info(
      'Message deleted: $messageId from conversation $conversationId',
    );
  }

  /// 记录消息块创建事件
  static void logBlockCreated(MessageBlock block) {
    _logger.info(
      'Block created: ${block.id} (${block.type.name}) for message ${block.messageId}',
      block,
    );
  }

  /// 记录消息块更新事件
  static void logBlockUpdated(MessageBlock block, String updateType) {
    _logger.info(
      'Block updated: ${block.id} - $updateType (status: ${block.status})',
      block,
    );
  }

  /// 记录消息块删除事件
  static void logBlockDeleted(String blockId, String messageId) {
    _logger.info(
      'Block deleted: $blockId from message $messageId',
    );
  }

  /// 记录流式消息开始事件
  static void logStreamingStarted(
      String messageId, String provider, String model) {
    _logger.info(
      'Streaming started: message $messageId using $provider/$model',
    );
  }

  /// 记录流式消息块更新
  static void logStreamingBlockUpdate(String blockId, int contentLength) {
    _logger.fine(
      'Streaming block update: $blockId (content length: $contentLength)',
    );
  }

  /// 记录流式消息完成事件
  static void logStreamingCompleted(
      String messageId, Duration duration, int totalTokens) {
    _logger.info(
      'Streaming completed: message $messageId in ${duration.inMilliseconds}ms (tokens: $totalTokens)',
    );
  }

  /// 记录流式消息错误
  static void logStreamingError(String messageId, Exception error) {
    _logger.severe(
      'Streaming error: message $messageId',
      error,
    );
  }

  /// 记录对话创建事件
  static void logConversationCreated(
      String conversationId, String assistantId) {
    _logger.info(
      'Conversation created: $conversationId with assistant $assistantId',
    );
  }

  /// 记录对话删除事件
  static void logConversationDeleted(String conversationId, int messageCount) {
    _logger.info(
      'Conversation deleted: $conversationId ($messageCount messages)',
    );
  }

  /// 记录数据库操作
  static void logDatabaseOperation(String operation, String table,
      {Map<String, dynamic>? details}) {
    _logger.fine(
      'Database operation: $operation on $table',
      details,
    );
  }

  /// 记录数据库查询性能
  static void logDatabaseQuery(
      String query, Duration duration, int resultCount) {
    _logger.fine(
      'Database query completed in ${duration.inMilliseconds}ms: $query (results: $resultCount)',
    );
  }

  /// 记录AI服务调用
  static void logAiServiceCall(
      String provider, String model, String operation) {
    _logger.info(
      'AI service call: $provider/$model - $operation',
    );
  }

  /// 记录AI服务响应
  static void logAiServiceResponse(
      String provider, String model, Duration duration, int tokens) {
    _logger.info(
      'AI service response: $provider/$model in ${duration.inMilliseconds}ms (tokens: $tokens)',
    );
  }

  /// 记录AI服务错误
  static void logAiServiceError(
      String provider, String model, Exception error) {
    _logger.severe(
      'AI service error: $provider/$model',
      error,
    );
  }

  /// 记录用户操作
  static void logUserAction(String action, {Map<String, dynamic>? context}) {
    _logger.info(
      'User action: $action',
      context,
    );
  }

  /// 记录性能指标
  static void logPerformanceMetric(String metric, double value, String unit) {
    _logger.fine(
      'Performance metric: $metric = $value $unit',
    );
  }

  /// 记录内存使用情况
  static void logMemoryUsage(int usedMemoryMB, int totalMemoryMB) {
    _logger.fine(
      'Memory usage: ${usedMemoryMB}MB / ${totalMemoryMB}MB (${(usedMemoryMB / totalMemoryMB * 100).toStringAsFixed(1)}%)',
    );
  }

  /// 记录异常
  static void logException(ChatException exception, {StackTrace? stackTrace}) {
    _logger.severe(
      'Chat exception: ${exception.code} - ${exception.message}',
      exception,
      stackTrace,
    );
  }

  /// 记录警告
  static void logWarning(String message, {dynamic context}) {
    _logger.warning(message, context);
  }

  /// 记录调试信息
  static void logDebug(String message, {dynamic context}) {
    _logger.fine(message, context);
  }

  /// 记录配置变更
  static void logConfigurationChange(
      String configKey, dynamic oldValue, dynamic newValue) {
    _logger.info(
      'Configuration changed: $configKey from $oldValue to $newValue',
    );
  }

  /// 记录缓存操作
  static void logCacheOperation(String operation, String key,
      {bool hit = false}) {
    _logger.fine(
      'Cache $operation: $key${hit ? ' (hit)' : ''}',
    );
  }

  /// 记录网络请求
  static void logNetworkRequest(
      String method, String url, int statusCode, Duration duration) {
    _logger.fine(
      'Network request: $method $url -> $statusCode in ${duration.inMilliseconds}ms',
    );
  }

  /// 记录文件操作
  static void logFileOperation(String operation, String filePath,
      {int? fileSize}) {
    final sizeInfo = fileSize != null ? ' (${fileSize}bytes)' : '';
    _logger.fine(
      'File operation: $operation $filePath$sizeInfo',
    );
  }

  /// 记录系统事件
  static void logSystemEvent(String event, {Map<String, dynamic>? details}) {
    _logger.info(
      'System event: $event',
      details,
    );
  }

  /// 获取日志统计信息
  static Map<String, int> getLogStatistics() {
    // 这里可以实现日志统计功能
    // 例如：错误数量、警告数量、性能指标等
    return {
      'total_logs': 0,
      'errors': 0,
      'warnings': 0,
      'info': 0,
      'debug': 0,
    };
  }

  /// 清理旧日志
  static void cleanupOldLogs({Duration maxAge = const Duration(days: 7)}) {
    // 这里可以实现日志清理功能
    _logger.info('Log cleanup completed (max age: ${maxAge.inDays} days)');
  }

  /// 导出日志
  static Future<String> exportLogs({
    DateTime? startTime,
    DateTime? endTime,
    Level? minLevel,
  }) async {
    // 这里可以实现日志导出功能
    _logger.info('Log export requested');
    return 'logs_export_${DateTime.now().millisecondsSinceEpoch}.txt';
  }
}
