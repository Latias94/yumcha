import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_status.dart' as msg_status;
import '../../domain/entities/message_block_status.dart';
import '../../domain/services/message_factory.dart';
import '../../../../shared/data/database/database.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/infrastructure/services/message_id_service.dart';

/// 错误严重程度枚举
enum ErrorSeverity {
  low,      // 低严重程度，通常可以重试
  medium,   // 中等严重程度，需要注意
  high,     // 高严重程度，需要立即处理
  critical, // 严重错误，可能需要人工干预
}

/// 错误类型枚举
enum TransactionErrorType {
  networkTimeout,     // 网络超时
  databaseLock,      // 数据库锁定
  constraintViolation, // 约束违反
  diskSpace,         // 磁盘空间不足
  corruption,        // 数据损坏
  unknown,           // 未知错误
}

/// 事务错误上下文
class TransactionErrorContext {
  final TransactionErrorType type;
  final ErrorSeverity severity;
  final bool retryable;
  final String suggestedAction;
  final Map<String, dynamic> details;

  const TransactionErrorContext({
    required this.type,
    required this.severity,
    required this.retryable,
    required this.suggestedAction,
    this.details = const {},
  });
}

/// 消息仓库实现类
class MessageRepositoryImpl implements MessageRepository {
  final AppDatabase _database;
  final _uuid = Uuid(); // 🚀 保留用于消息块ID生成
  final _messageFactory = MessageFactory();
  final _messageIdService = MessageIdService(); // 🚀 阶段4优化：统一消息ID生成
  final _logger = LoggerService();

  MessageRepositoryImpl(this._database);

  @override
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    try {
      // 🚀 修复：在加载对话消息时清理可能残留的流式缓存
      cleanupStreamingCache();

      final messageDataList = await _database.getMessagesByConversation(conversationId);
      final messages = <Message>[];

      for (final messageData in messageDataList) {
        final blocks = await _database.getMessageBlocks(messageData.id);
        final message = _dataToMessage(messageData, blocks);
        messages.add(message);
      }

      return messages;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Message?> getMessage(String id) async {
    try {
      final messageData = await _database.getMessage(id);
      if (messageData == null) return null;

      final blocks = await _database.getMessageBlocks(id);
      return _dataToMessage(messageData, blocks);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createMessage({
    required String conversationId,
    required String role,
    required String assistantId,
    msg_status.MessageStatus status = msg_status.MessageStatus.userSuccess,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) async {
    // 🚀 阶段4优化：使用MessageIdService统一生成消息ID
    final messageId = role == 'user'
        ? _messageIdService.generateUserMessageId()
        : _messageIdService.generateAiMessageId();
    final now = DateTime.now();

    await _database.insertMessage(MessagesCompanion.insert(
      id: messageId,
      conversationId: conversationId,
      role: role,
      assistantId: assistantId,
      createdAt: now,
      updatedAt: now,
      status: Value(status.name),
      modelId: Value(modelId),
      metadata: Value(metadata != null ? _encodeJson(metadata) : null),
    ));

    return messageId;
  }

  @override
  Future<void> updateMessageStatus(String messageId, msg_status.MessageStatus status) async {
    await _database.updateMessage(messageId, MessagesCompanion(
      status: Value(status.name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> updateMessageMetadata(String messageId, Map<String, dynamic> metadata) async {
    await _database.updateMessage(messageId, MessagesCompanion(
      metadata: Value(_encodeJson(metadata)),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _database.deleteMessage(messageId);
  }

  @override
  Future<List<MessageBlock>> getMessageBlocks(String messageId) async {
    try {
      final blockDataList = await _database.getMessageBlocks(messageId);
      return blockDataList.map(_dataToMessageBlock).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MessageBlock?> getMessageBlock(String blockId) async {
    try {
      final blockData = await _database.getMessageBlock(blockId);
      return blockData != null ? _dataToMessageBlock(blockData) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> addTextBlock({
    required String messageId,
    required String content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.mainText,
      content: content,
      orderIndex: orderIndex,
      status: status,
    );
  }

  @override
  Future<String> addThinkingBlock({
    required String messageId,
    required String content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.thinking,
      content: content,
      orderIndex: orderIndex,
      status: status,
    );
  }

  @override
  Future<String> addImageBlock({
    required String messageId,
    required String imageUrl,
    int orderIndex = 0,
    Map<String, dynamic>? metadata,
  }) async {
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.image,
      content: imageUrl,
      orderIndex: orderIndex,
      metadata: metadata,
    );
  }

  @override
  Future<String> addCodeBlock({
    required String messageId,
    required String code,
    String? language,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    final metadata = language != null ? {'language': language} : null;
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.code,
      content: code,
      orderIndex: orderIndex,
      status: status,
      metadata: metadata,
    );
  }

  @override
  Future<String> addToolBlock({
    required String messageId,
    required String toolName,
    required Map<String, dynamic> arguments,
    String? result,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    final metadata = {
      'toolName': toolName,
      'arguments': arguments,
    };
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.tool,
      content: result,
      orderIndex: orderIndex,
      status: status,
      metadata: metadata,
    );
  }

  @override
  Future<String> addErrorBlock({
    required String messageId,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? errorDetails,
    int orderIndex = 0,
  }) async {
    final metadata = <String, dynamic>{};
    if (errorCode != null) metadata['errorCode'] = errorCode;
    if (errorDetails != null) metadata['errorDetails'] = errorDetails;

    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.error,
      content: errorMessage,
      orderIndex: orderIndex,
      status: MessageBlockStatus.error,
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  @override
  Future<void> updateBlockContent(String blockId, String content) async {
    await _database.updateMessageBlock(blockId, MessageBlocksCompanion(
      content: Value(content),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> updateBlockStatus(String blockId, MessageBlockStatus status) async {
    await _database.updateMessageBlock(blockId, MessageBlocksCompanion(
      status: Value(status.name),
      updatedAt: Value(DateTime.now()),
    ));
  }



  @override
  Future<void> deleteMessageBlock(String blockId) async {
    await _database.deleteMessageBlock(blockId);
  }

  /// 添加消息块的通用方法
  Future<String> _addBlock({
    required String messageId,
    required MessageBlockType type,
    String? content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
    Map<String, dynamic>? metadata,
  }) async {
    final blockId = _uuid.v4();
    final now = DateTime.now();

    await _database.insertMessageBlock(MessageBlocksCompanion.insert(
      id: blockId,
      messageId: messageId,
      type: type.name,
      createdAt: now,
      updatedAt: now,
      content: Value(content),
      status: Value(status.name),
      orderIndex: Value(orderIndex),
      metadata: Value(metadata != null ? _encodeJson(metadata) : null),
    ));

    // 更新消息的blockIds
    await _updateMessageBlockIds(messageId);

    return blockId;
  }

  /// 更新消息的blockIds字段
  Future<void> _updateMessageBlockIds(String messageId) async {
    final blocks = await _database.getMessageBlocks(messageId);
    final blockIds = blocks.map((block) => block.id).toList();

    await _database.updateMessage(messageId, MessagesCompanion(
      blockIds: Value(blockIds),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> saveMessage(Message message) async {
    final stopwatch = Stopwatch()..start();

    // 🚀 阶段4重构：使用事务确保消息和消息块的原子性保存
    await _database.transaction(() async {
      try {
        _logger.debug('开始保存消息事务', {
          'messageId': message.id,
          'blocksCount': message.blocks.length,
          'conversationId': message.conversationId,
        });

        // 1. 保存或更新消息
        await _upsertMessage(message);

        // 2. 批量保存消息块（在同一事务中）
        if (message.blocks.isNotEmpty) {
          await _batchUpsertMessageBlocks(message.blocks);
        }

        // 3. 更新消息的blockIds字段
        await _updateMessageBlockIds(message.id);

        stopwatch.stop();
        _logger.debug('消息事务保存成功', {
          'messageId': message.id,
          'duration': stopwatch.elapsedMilliseconds,
          'blocksCount': message.blocks.length,
        });

        // 记录性能指标
        _recordTransactionMetrics(
          operation: 'saveMessage',
          duration: stopwatch.elapsedMilliseconds,
          success: true,
          messageId: message.id,
          blocksCount: message.blocks.length,
        );

        // 记录操作性能统计
        _recordOperationPerformance('saveMessage', stopwatch.elapsedMilliseconds);

      } catch (e) {
        stopwatch.stop();

        // 🚀 阶段4增强：详细的错误分类和处理
        final errorContext = _analyzeTransactionError(e, message);

        _logger.error('保存消息失败，事务回滚', {
          'messageId': message.id,
          'error': e.toString(),
          'errorType': errorContext.type,
          'errorSeverity': errorContext.severity,
          'duration': stopwatch.elapsedMilliseconds,
          'blocksCount': message.blocks.length,
          'retryable': errorContext.retryable,
          'suggestedAction': errorContext.suggestedAction,
        });

        // 记录失败指标
        _recordTransactionMetrics(
          operation: 'saveMessage',
          duration: stopwatch.elapsedMilliseconds,
          success: false,
          messageId: message.id,
          blocksCount: message.blocks.length,
          error: e.toString(),
          errorType: errorContext.type,
        );

        // 根据错误类型决定是否重试或抛出特定异常
        if (errorContext.retryable && errorContext.severity != ErrorSeverity.critical) {
          _logger.info('错误可重试，建议稍后重试', {
            'messageId': message.id,
            'errorType': errorContext.type,
          });
        }

        rethrow; // 事务会自动回滚
      }
    });
  }

  /// 记录事务性能指标
  void _recordTransactionMetrics({
    required String operation,
    required int duration,
    required bool success,
    required String messageId,
    required int blocksCount,
    String? error,
    TransactionErrorType? errorType,
  }) {
    // 记录到日志系统，便于性能分析
    _logger.info('事务性能指标', {
      'operation': operation,
      'messageId': messageId,
      'duration_ms': duration,
      'success': success,
      'blocks_count': blocksCount,
      'error': error,
      'error_type': errorType?.name,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // TODO: 可以在这里添加更详细的性能监控，如发送到监控系统
    // 例如：发送到Prometheus、DataDog等监控系统
  }

  /// 分析事务错误并返回错误上下文
  TransactionErrorContext _analyzeTransactionError(dynamic error, Message message) {
    final errorString = error.toString().toLowerCase();

    // 网络超时错误
    if (errorString.contains('timeout') || errorString.contains('connection')) {
      return const TransactionErrorContext(
        type: TransactionErrorType.networkTimeout,
        severity: ErrorSeverity.medium,
        retryable: true,
        suggestedAction: '检查网络连接，稍后重试',
      );
    }

    // 数据库锁定错误
    if (errorString.contains('lock') || errorString.contains('busy')) {
      return const TransactionErrorContext(
        type: TransactionErrorType.databaseLock,
        severity: ErrorSeverity.medium,
        retryable: true,
        suggestedAction: '数据库繁忙，建议稍后重试',
      );
    }

    // 约束违反错误
    if (errorString.contains('constraint') || errorString.contains('unique')) {
      return TransactionErrorContext(
        type: TransactionErrorType.constraintViolation,
        severity: ErrorSeverity.high,
        retryable: false,
        suggestedAction: '数据约束违反，检查消息ID是否重复',
        details: {'messageId': message.id, 'blocksCount': message.blocks.length},
      );
    }

    // 磁盘空间不足
    if (errorString.contains('disk') || errorString.contains('space')) {
      return const TransactionErrorContext(
        type: TransactionErrorType.diskSpace,
        severity: ErrorSeverity.critical,
        retryable: false,
        suggestedAction: '磁盘空间不足，需要清理存储空间',
      );
    }

    // 数据损坏错误
    if (errorString.contains('corrupt') || errorString.contains('malformed')) {
      return const TransactionErrorContext(
        type: TransactionErrorType.corruption,
        severity: ErrorSeverity.critical,
        retryable: false,
        suggestedAction: '数据库可能损坏，需要检查数据完整性',
      );
    }

    // 未知错误
    return TransactionErrorContext(
      type: TransactionErrorType.unknown,
      severity: ErrorSeverity.medium,
      retryable: true,
      suggestedAction: '未知错误，建议检查日志并重试',
      details: {'originalError': error.toString()},
    );
  }

  /// 单个消息的UPSERT操作
  Future<void> _upsertMessage(Message message) async {
    try {
      // 尝试插入
      await _database.insertMessage(MessagesCompanion.insert(
        id: message.id,
        conversationId: message.conversationId,
        role: message.role,
        assistantId: message.assistantId,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        status: Value(message.status.name),
        modelId: Value(message.modelId),
        metadata: Value(message.metadata != null ? _encodeJson(message.metadata!) : null),
        blockIds: Value(message.blockIds),
      ));
    } catch (e) {
      // 如果插入失败（通常是主键冲突），则更新
      await _database.updateMessage(message.id, MessagesCompanion(
        status: Value(message.status.name),
        updatedAt: Value(message.updatedAt),
        metadata: Value(message.metadata != null ? _encodeJson(message.metadata!) : null),
        blockIds: Value(message.blockIds),
      ));
    }
  }

  /// 批量UPSERT消息块 - 优化版本
  Future<void> _batchUpsertMessageBlocks(List<MessageBlock> blocks) async {
    if (blocks.isEmpty) return;

    final stopwatch = Stopwatch()..start();

    try {
      // 🚀 阶段4优化：批量处理，减少数据库往返次数
      _logger.debug('开始批量保存消息块', {
        'blocksCount': blocks.length,
        'messageId': blocks.first.messageId,
      });

      // 分批处理，避免单次事务过大
      const batchSize = 50; // 每批最多50个块
      for (int i = 0; i < blocks.length; i += batchSize) {
        final batch = blocks.skip(i).take(batchSize).toList();
        await _processBatchBlocks(batch);
      }

      stopwatch.stop();
      _logger.debug('批量保存消息块完成', {
        'blocksCount': blocks.length,
        'duration': stopwatch.elapsedMilliseconds,
        'messageId': blocks.first.messageId,
      });

      // 记录批量操作性能
      _recordOperationPerformance('batchUpsert', stopwatch.elapsedMilliseconds);

    } catch (e) {
      stopwatch.stop();
      _logger.error('批量保存消息块失败', {
        'blocksCount': blocks.length,
        'error': e.toString(),
        'duration': stopwatch.elapsedMilliseconds,
      });
      rethrow;
    }
  }

  /// 处理单批消息块
  Future<void> _processBatchBlocks(List<MessageBlock> batch) async {
    // 先尝试批量插入，失败的再单独处理
    final failedBlocks = <MessageBlock>[];

    for (final block in batch) {
      try {
        // 尝试插入
        await _database.insertMessageBlock(MessageBlocksCompanion.insert(
          id: block.id,
          messageId: block.messageId,
          type: block.type.name,
          createdAt: block.createdAt,
          updatedAt: block.updatedAt ?? block.createdAt,
          content: Value(block.content),
          status: Value(block.status.name),
          orderIndex: Value(0),
          metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
        ));
      } catch (e) {
        // 插入失败，标记为需要更新
        failedBlocks.add(block);
      }
    }

    // 批量更新失败的块
    for (final block in failedBlocks) {
      await _database.updateMessageBlock(block.id, MessageBlocksCompanion(
        content: Value(block.content),
        status: Value(block.status.name),
        updatedAt: Value(block.updatedAt ?? DateTime.now()),
        metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
      ));
    }

    if (failedBlocks.isNotEmpty) {
      _logger.debug('批量处理中有块需要更新', {
        'totalBlocks': batch.length,
        'updatedBlocks': failedBlocks.length,
      });
    }
  }

  /// 单个消息块的UPSERT操作
  Future<void> _upsertMessageBlock(MessageBlock block) async {
    try {
      // 尝试插入
      await _database.insertMessageBlock(MessageBlocksCompanion.insert(
        id: block.id,
        messageId: block.messageId,
        type: block.type.name,
        createdAt: block.createdAt,
        updatedAt: block.updatedAt ?? block.createdAt,
        content: Value(block.content),
        status: Value(block.status.name),
        orderIndex: Value(0),
        metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
      ));
    } catch (e) {
      // 如果插入失败（通常是主键冲突），则更新
      await _database.updateMessageBlock(block.id, MessageBlocksCompanion(
        content: Value(block.content),
        status: Value(block.status.name),
        updatedAt: Value(block.updatedAt ?? DateTime.now()),
        metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
      ));
    }
  }



  // 🚀 阶段4：性能监控相关方法

  /// 事务性能统计
  static final Map<String, List<int>> _performanceStats = {
    'saveMessage': [],
    'batchUpsert': [],
    'streamingFinish': [],
  };

  /// 获取性能统计信息
  Map<String, Map<String, dynamic>> getPerformanceStats() {
    final stats = <String, Map<String, dynamic>>{};

    for (final entry in _performanceStats.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        durations.sort();
        final count = durations.length;
        final sum = durations.reduce((a, b) => a + b);
        final avg = sum / count;
        final median = count % 2 == 0
            ? (durations[count ~/ 2 - 1] + durations[count ~/ 2]) / 2
            : durations[count ~/ 2].toDouble();
        final p95Index = (count * 0.95).ceil() - 1;
        final p95 = durations[p95Index.clamp(0, count - 1)].toDouble();

        stats[entry.key] = {
          'count': count,
          'avg_ms': avg.round(),
          'median_ms': median.round(),
          'p95_ms': p95.round(),
          'min_ms': durations.first,
          'max_ms': durations.last,
        };
      }
    }

    return stats;
  }

  /// 记录操作性能
  void _recordOperationPerformance(String operation, int durationMs) {
    final stats = _performanceStats[operation];
    if (stats != null) {
      stats.add(durationMs);

      // 保持最近1000条记录，避免内存泄漏
      if (stats.length > 1000) {
        stats.removeRange(0, stats.length - 1000);
      }
    }
  }

  /// 清理性能统计
  void clearPerformanceStats() {
    for (final stats in _performanceStats.values) {
      stats.clear();
    }
  }

  /// 🚀 阶段4优化：移除重复的保存方法，统一使用saveMessage的事务逻辑
  /// 此方法已被移除，所有保存操作统一使用saveMessage方法

  /// 将数据库数据转换为Message实体
  Message _dataToMessage(MessageData data, List<MessageBlockData> blockDataList) {
    final blocks = blockDataList.map(_dataToMessageBlock).toList();
    
    return Message(
      id: data.id,
      conversationId: data.conversationId,
      role: data.role,
      assistantId: data.assistantId,
      blockIds: data.blockIds,
      status: msg_status.MessageStatus.values.firstWhere(
        (s) => s.name == data.status,
        orElse: () => msg_status.MessageStatus.userSuccess,
      ),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      modelId: data.modelId,
      metadata: data.metadata != null ? _decodeJson(data.metadata!) : null,
      blocks: blocks,
    );
  }

  /// 将数据库数据转换为MessageBlock实体
  MessageBlock _dataToMessageBlock(MessageBlockData data) {
    return MessageBlock(
      id: data.id,
      messageId: data.messageId,
      type: MessageBlockType.values.firstWhere(
        (t) => t.name == data.type,
        orElse: () => MessageBlockType.mainText,
      ),
      status: MessageBlockStatus.values.firstWhere(
        (s) => s.name == data.status,
        orElse: () => MessageBlockStatus.success,
      ),
      content: data.content,
      metadata: data.metadata != null ? _decodeJson(data.metadata!) : null,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// JSON编码
  String _encodeJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return '{}';
    }
  }

  /// JSON解码
  Map<String, dynamic> _decodeJson(String json) {
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  // ========== 复合操作 ==========

  @override
  Future<Message> getMessageWithBlocks(String messageId) async {
    final message = await getMessage(messageId);
    if (message == null) {
      throw Exception('消息不存在: $messageId');
    }
    return message;
  }

  @override
  Future<List<Message>> getConversationWithBlocks(String conversationId) async {
    return await getMessagesByConversation(conversationId);
  }

  @override
  Future<Message> createUserMessage({
    required String conversationId,
    required String assistantId,
    required String content,
    List<String>? imageUrls,
  }) async {
    // 使用MessageFactory创建完整的用户消息
    final message = _messageFactory.createUserMessage(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      imageUrls: imageUrls,
    );

    // 🚀 阶段4优化：使用统一的事务性保存方法
    await saveMessage(message);

    return message;
  }

  @override
  Future<Message> createAiMessagePlaceholder({
    required String conversationId,
    required String assistantId,
    String? modelId,
  }) async {
    // 使用MessageFactory创建AI消息占位符
    final message = _messageFactory.createAiMessagePlaceholder(
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
    );

    // 🚀 阶段4优化：使用统一的事务性保存方法
    await saveMessage(message);

    return message;
  }

  @override
  Future<void> completeAiMessage({
    required String messageId,
    required String content,
    String? thinkingContent,
    List<Map<String, dynamic>>? toolCalls,
    Map<String, dynamic>? metadata,
  }) async {
    int orderIndex = 0;

    // 添加思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      await addThinkingBlock(
        messageId: messageId,
        content: thinkingContent,
        orderIndex: orderIndex++,
      );
    }

    // 添加主文本块
    if (content.isNotEmpty) {
      await addTextBlock(
        messageId: messageId,
        content: content,
        orderIndex: orderIndex++,
      );
    }

    // 添加工具调用块
    if (toolCalls != null && toolCalls.isNotEmpty) {
      for (final toolCall in toolCalls) {
        await addToolBlock(
          messageId: messageId,
          toolName: toolCall['name'] as String,
          arguments: toolCall['arguments'] as Map<String, dynamic>,
          result: toolCall['result'] as String?,
          orderIndex: orderIndex++,
        );
      }
    }

    // 更新消息状态和元数据
    await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);
    if (metadata != null) {
      await updateMessageMetadata(messageId, metadata);
    }
  }

  // ========== 流式处理支持 ==========

  /// 流式消息块缓存，避免重复查询数据库
  final Map<String, List<MessageBlock>> _streamingBlocksCache = {};

  /// 流式消息内容缓存，只在内存中更新，不写入数据库
  final Map<String, Map<String, String>> _streamingContentCache = {};

  /// 流式消息的基本信息缓存，用于在完成时创建完整消息
  final Map<String, Map<String, dynamic>> _streamingMessageInfoCache = {};

  @override
  Future<void> startStreamingMessage(String messageId) async {
    // 🚀 修复：流式消息在开始时不保存到数据库，只初始化内存缓存
    // 只有在流式结束或错误时才保存到数据库

    _logger.debug('开始流式消息', {
      'messageId': messageId,
      'existingCache': _streamingBlocksCache.containsKey(messageId),
    });

    // 初始化流式消息的块缓存和内容缓存
    _streamingBlocksCache[messageId] = [];
    _streamingContentCache[messageId] = {};
    _streamingMessageInfoCache[messageId] = {};

    // 注意：这里不再调用updateMessageStatus，避免过早保存到数据库
  }

  /// 设置流式消息的基本信息（用于在完成时创建完整消息）
  @override
  void setStreamingMessageInfo({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    _logger.debug('设置流式消息信息', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
    });

    _streamingMessageInfoCache[messageId] = {
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
      'metadata': metadata,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// 清理过期的流式消息缓存
  /// 在应用重启或对话加载时调用，清理可能残留的流式状态
  void cleanupStreamingCache() {
    final cacheCount = _streamingBlocksCache.length +
                      _streamingContentCache.length +
                      _streamingMessageInfoCache.length;

    if (cacheCount > 0) {
      _logger.info('清理流式消息缓存', {
        'blocksCache': _streamingBlocksCache.length,
        'contentCache': _streamingContentCache.length,
        'infoCache': _streamingMessageInfoCache.length,
      });

      _streamingBlocksCache.clear();
      _streamingContentCache.clear();
      _streamingMessageInfoCache.clear();
    }
  }

  @override
  Future<void> updateStreamingContent({
    required String messageId,
    required String content,
    String? thinkingContent,
  }) async {
    // 🚀 优化：流式过程中只更新内存缓存，不写入数据库
    // 这样可以避免频繁的数据库写入操作

    // 更新内存中的内容缓存
    final contentCache = _streamingContentCache[messageId] ?? {};
    contentCache['mainText'] = content;
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      contentCache['thinking'] = thinkingContent;
    }
    _streamingContentCache[messageId] = contentCache;

    // 获取或创建块缓存
    List<MessageBlock> blocks = _streamingBlocksCache[messageId] ?? [];
    if (blocks.isEmpty) {
      // 如果缓存为空，从数据库加载一次
      blocks = await getMessageBlocks(messageId);
      _streamingBlocksCache[messageId] = blocks;
    }

    // 更新缓存中的块内容（仅内存操作）
    final now = DateTime.now();

    // 更新或创建文本块
    var textBlock = blocks.where((b) => b.type == MessageBlockType.mainText).firstOrNull;
    if (textBlock != null) {
      final index = blocks.indexWhere((b) => b.id == textBlock!.id);
      if (index != -1) {
        blocks[index] = textBlock.copyWith(content: content, updatedAt: now);
      }
    } else {
      // 创建新的文本块（仅在缓存中）
      textBlock = MessageBlock.text(
        id: '${messageId}_text',
        messageId: messageId,
        content: content,
        status: MessageBlockStatus.streaming,
        createdAt: now,
      );
      blocks.add(textBlock);
    }

    // 更新或创建思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      var thinkingBlock = blocks.where((b) => b.type == MessageBlockType.thinking).firstOrNull;
      if (thinkingBlock != null) {
        final index = blocks.indexWhere((b) => b.id == thinkingBlock!.id);
        if (index != -1) {
          blocks[index] = thinkingBlock.copyWith(content: thinkingContent, updatedAt: now);
        }
      } else {
        // 创建新的思考块（仅在缓存中）
        thinkingBlock = MessageBlock.thinking(
          id: '${messageId}_thinking',
          messageId: messageId,
          content: thinkingContent,
          status: MessageBlockStatus.streaming,
          createdAt: now,
        );
        blocks.insert(0, thinkingBlock); // 思考块放在开头
      }
    }

    _streamingBlocksCache[messageId] = blocks;

    // 注意：这里不再写入数据库，只在流式结束时统一写入
  }



  @override
  Future<void> finishStreamingMessage({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    // 🚀 修复：流式结束时一次性将缓存内容写入数据库
    // 这是流式消息第一次真正保存到数据库

    _logger.debug('开始完成流式消息', {
      'messageId': messageId,
      'hasCache': _streamingBlocksCache.containsKey(messageId),
      'hasInfoCache': _streamingMessageInfoCache.containsKey(messageId),
    });

    // 获取缓存的块信息
    final cachedBlocks = _streamingBlocksCache[messageId];
    if (cachedBlocks == null || cachedBlocks.isEmpty) {
      // 🚀 修复：如果没有缓存，这是一个严重问题，应该记录错误
      _logger.error('流式消息完成时没有缓存的块信息', {
        'messageId': messageId,
        'hasInfoCache': _streamingMessageInfoCache.containsKey(messageId),
        'hasContentCache': _streamingContentCache.containsKey(messageId),
        'reason': '可能是updateStreamingContent没有被正确调用',
      });

      // 检查消息是否已存在于数据库中
      try {
        final existingMessage = await getMessage(messageId);
        if (existingMessage != null) {
          // 如果消息已存在，只更新状态
          _logger.info('流式消息已存在于数据库，更新状态为成功', {
            'messageId': messageId,
            'currentStatus': existingMessage.status.name,
          });
          await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);
          if (metadata != null) {
            await updateMessageMetadata(messageId, metadata);
          }
          return;
        }
      } catch (error) {
        _logger.error('检查现有消息时发生错误', {
          'messageId': messageId,
          'error': error.toString(),
        });
      }

      // 如果没有缓存也没有现有消息，抛出异常以便上层处理
      throw Exception('流式消息完成失败：没有缓存的内容且消息不存在于数据库中 (messageId: $messageId)');
    }

    // 使用事务确保数据一致性
    await _database.transaction(() async {
      // 🚀 修复：首先确保消息本身存在于数据库中
      // 获取流式消息的基本信息
      final messageInfo = _streamingMessageInfoCache[messageId];
      if (messageInfo == null) {
        throw Exception('流式消息信息缓存不存在: $messageId');
      }

      // 检查消息是否已存在
      final existingMessage = await getMessage(messageId);
      if (existingMessage == null) {
        // 如果消息不存在，创建完整的消息记录
        final createdAt = DateTime.parse(messageInfo['createdAt'] as String);
        final finalMetadata = <String, dynamic>{
          ...?messageInfo['metadata'] as Map<String, dynamic>?,
          ...?metadata,
        };

        await _database.insertMessage(MessagesCompanion.insert(
          id: messageId,
          conversationId: messageInfo['conversationId'] as String,
          role: 'assistant',
          assistantId: messageInfo['assistantId'] as String,
          createdAt: createdAt,
          updatedAt: DateTime.now(),
          status: Value(msg_status.MessageStatus.aiSuccess.name),
          modelId: Value(messageInfo['modelId'] as String?),
          metadata: Value(finalMetadata.isNotEmpty ? _encodeJson(finalMetadata) : null),
          blockIds: Value(cachedBlocks.map((b) => b.id).toList()),
        ));
      } else {
        // 如果消息已存在，只更新状态和元数据
        await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);
        if (metadata != null) {
          await updateMessageMetadata(messageId, metadata);
        }
      }

      // 1. 批量保存或更新所有消息块
      for (final block in cachedBlocks) {
        final finalBlock = block.copyWith(
          status: MessageBlockStatus.success,
          updatedAt: DateTime.now(),
        );
        await _upsertMessageBlock(finalBlock);
      }

      // 2. 更新消息的blockIds字段
      await _updateMessageBlockIds(messageId);
    });

    // 清理缓存
    _streamingBlocksCache.remove(messageId);
    _streamingContentCache.remove(messageId);
    _streamingMessageInfoCache.remove(messageId);
  }

  @override
  Future<void> handleStreamingError({
    required String messageId,
    required String errorMessage,
    String? partialContent,
  }) async {
    // 🚀 修复：流式错误时也需要先保存消息到数据库

    // 获取流式消息的基本信息
    final messageInfo = _streamingMessageInfoCache[messageId];
    if (messageInfo == null) {
      throw Exception('流式消息信息缓存不存在: $messageId');
    }

    await _database.transaction(() async {
      // 检查消息是否已存在
      final existingMessage = await getMessage(messageId);
      if (existingMessage == null) {
        // 如果消息不存在，创建消息记录
        final createdAt = DateTime.parse(messageInfo['createdAt'] as String);

        await _database.insertMessage(MessagesCompanion.insert(
          id: messageId,
          conversationId: messageInfo['conversationId'] as String,
          role: 'assistant',
          assistantId: messageInfo['assistantId'] as String,
          createdAt: createdAt,
          updatedAt: DateTime.now(),
          status: Value(msg_status.MessageStatus.aiError.name),
          modelId: Value(messageInfo['modelId'] as String?),
          metadata: Value(messageInfo['metadata'] != null ? _encodeJson(messageInfo['metadata'] as Map<String, dynamic>) : null),
          blockIds: Value(<String>[]),
        ));
      } else {
        // 如果消息已存在，更新状态为错误
        await updateMessageStatus(messageId, msg_status.MessageStatus.aiError);
      }

      // 如果有部分内容，保存它
      if (partialContent != null && partialContent.isNotEmpty) {
        await addTextBlock(
          messageId: messageId,
          content: partialContent,
          orderIndex: 0,
          status: MessageBlockStatus.success,
        );
      }

      // 添加错误块
      await addErrorBlock(
        messageId: messageId,
        errorMessage: errorMessage,
        orderIndex: 999, // 错误块放在最后
      );

      // 更新消息的blockIds字段
      await _updateMessageBlockIds(messageId);
    });

    // 清理缓存
    _streamingBlocksCache.remove(messageId);
    _streamingContentCache.remove(messageId);
    _streamingMessageInfoCache.remove(messageId);
  }

  // ========== 搜索和查询 ==========

  @override
  Future<List<Message>> searchMessages({
    required String query,
    String? conversationId,
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messages = await _database.searchMessages(
        query,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );

      final result = <Message>[];
      for (final messageData in messages) {
        // 如果指定了对话ID，过滤结果
        if (conversationId != null && messageData.conversationId != conversationId) {
          continue;
        }

        final blocks = await _database.getMessageBlocks(messageData.id);
        final message = _dataToMessage(messageData, blocks);
        result.add(message);
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> getSearchResultCount({
    required String query,
    String? conversationId,
    String? assistantId,
  }) async {
    try {
      return await _database.getSearchResultCount(
        query,
        assistantId: assistantId,
      );
    } catch (e) {
      return 0;
    }
  }

  // ========== 统计和分析 ==========

  @override
  Future<int> getMessageCount(String conversationId) async {
    try {
      final messages = await _database.getMessagesByConversation(conversationId);
      return messages.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Message?> getLastMessage(String conversationId) async {
    try {
      final messageData = await _database.getLastMessageByConversation(conversationId);
      if (messageData == null) return null;

      final blocks = await _database.getMessageBlocks(messageData.id);
      return _dataToMessage(messageData, blocks);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getBlockCount(String messageId) async {
    try {
      final blocks = await _database.getMessageBlocks(messageId);
      return blocks.length;
    } catch (e) {
      return 0;
    }
  }
}
