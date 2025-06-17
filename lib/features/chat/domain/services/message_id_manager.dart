import '../../../../shared/infrastructure/services/message_id_service.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 消息ID管理器
///
/// 🎯 **核心职责**：
/// - 统一管理聊天系统中的所有ID生成和关联
/// - 提供高级ID管理功能，如ID追踪、关联管理等
/// - 简化上层业务代码的ID操作
/// - 确保ID的一致性和可追溯性
///
/// 🔧 **设计原则**：
/// - 封装复杂性：隐藏底层ID生成的复杂逻辑
/// - 业务导向：提供面向聊天业务的ID管理方法
/// - 状态管理：跟踪ID的生命周期和状态变化
/// - 错误处理：提供完善的错误处理和日志记录
class MessageIdManager {
  final MessageIdService _idService;
  final LoggerService _logger = LoggerService();

  /// ID状态跟踪
  final Map<String, MessageIdState> _idStates = {};

  /// 流式消息ID映射 - 用于追踪流式消息的ID关系
  final Map<String, String> _streamingIdMap = {};

  MessageIdManager(this._idService);

  // ========== 消息ID生成 ==========

  /// 生成用户消息ID并记录状态
  String generateUserMessageId({
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    final messageId = _idService.generateUserMessageId();

    _recordIdState(
        messageId,
        MessageIdState(
          id: messageId,
          type: MessageIdType.userMessage,
          status: MessageIdStatus.created,
          conversationId: conversationId,
          metadata: metadata,
          createdAt: DateTime.now(),
        ));

    _logger.debug('生成用户消息ID', {
      'messageId': messageId,
      'conversationId': conversationId,
    });

    return messageId;
  }

  /// 生成AI消息ID并记录状态
  String generateAiMessageId({
    String? conversationId,
    String? assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    final messageId = _idService.generateAiMessageId();

    _recordIdState(
        messageId,
        MessageIdState(
          id: messageId,
          type: MessageIdType.aiMessage,
          status: MessageIdStatus.created,
          conversationId: conversationId,
          assistantId: assistantId,
          modelId: modelId,
          metadata: metadata,
          createdAt: DateTime.now(),
        ));

    _logger.debug('生成AI消息ID', {
      'messageId': messageId,
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
    });

    return messageId;
  }

  /// 生成消息块ID并建立关联
  String generateMessageBlockId({
    required String messageId,
    required String blockType,
    required int index,
  }) {
    final blockId = _idService.generateMessageBlockId(
      messageId: messageId,
      blockType: blockType,
      index: index,
    );

    // 建立消息和块的关联关系
    _idService.linkIds(messageId, blockId);

    _recordIdState(
        blockId,
        MessageIdState(
          id: blockId,
          type: MessageIdType.messageBlock,
          status: MessageIdStatus.created,
          parentId: messageId,
          metadata: {
            'blockType': blockType,
            'index': index,
          },
          createdAt: DateTime.now(),
        ));

    _logger.debug('生成消息块ID', {
      'blockId': blockId,
      'messageId': messageId,
      'blockType': blockType,
      'index': index,
    });

    return blockId;
  }

  // ========== 流式消息ID管理 ==========

  /// 开始流式消息处理
  void startStreamingMessage(String messageId) {
    _updateIdStatus(messageId, MessageIdStatus.streaming);
    _streamingIdMap[messageId] = messageId;

    _logger.info('开始流式消息处理', {
      'messageId': messageId,
      'streamingCount': _streamingIdMap.length,
    });
  }

  /// 完成流式消息处理
  void completeStreamingMessage(String messageId) {
    _updateIdStatus(messageId, MessageIdStatus.completed);
    _streamingIdMap.remove(messageId);

    _logger.info('完成流式消息处理', {
      'messageId': messageId,
      'remainingStreamingCount': _streamingIdMap.length,
    });
  }

  /// 取消流式消息处理
  void cancelStreamingMessage(String messageId) {
    _updateIdStatus(messageId, MessageIdStatus.cancelled);
    _streamingIdMap.remove(messageId);

    _logger.warning('取消流式消息处理', {
      'messageId': messageId,
      'remainingStreamingCount': _streamingIdMap.length,
    });
  }

  /// 获取当前流式消息ID列表
  List<String> getActiveStreamingMessageIds() {
    return _streamingIdMap.keys.toList();
  }

  /// 检查消息是否正在流式处理
  bool isStreamingMessage(String messageId) {
    return _streamingIdMap.containsKey(messageId);
  }

  // ========== ID状态管理 ==========

  /// 更新消息ID状态
  void _updateIdStatus(String messageId, MessageIdStatus status) {
    final state = _idStates[messageId];
    if (state != null) {
      _idStates[messageId] = state.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// 记录ID状态
  void _recordIdState(String id, MessageIdState state) {
    _idStates[id] = state;
  }

  /// 获取ID状态
  MessageIdState? getIdState(String id) {
    return _idStates[id];
  }

  /// 获取指定类型的所有ID
  List<String> getIdsByType(MessageIdType type) {
    return _idStates.entries
        .where((entry) => entry.value.type == type)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取指定状态的所有ID
  List<String> getIdsByStatus(MessageIdStatus status) {
    return _idStates.entries
        .where((entry) => entry.value.status == status)
        .map((entry) => entry.key)
        .toList();
  }

  // ========== 清理和维护 ==========

  /// 清理指定消息的所有相关ID
  void cleanupMessageIds(String messageId) {
    // 获取相关联的所有ID
    final relatedIds = _idService.getRelatedIds(messageId);

    // 清理状态记录
    _idStates.remove(messageId);
    for (final relatedId in relatedIds) {
      _idStates.remove(relatedId);
    }

    // 清理ID关联关系
    _idService.clearIdRelations(messageId);

    // 清理流式映射
    _streamingIdMap.remove(messageId);

    _logger.debug('清理消息ID', {
      'messageId': messageId,
      'relatedIdsCount': relatedIds.length,
    });
  }

  /// 清理过期的ID状态（超过指定时间的已完成或已取消状态）
  void cleanupExpiredIds({Duration? maxAge}) {
    final cutoffTime =
        DateTime.now().subtract(maxAge ?? const Duration(hours: 24));
    final expiredIds = <String>[];

    for (final entry in _idStates.entries) {
      final state = entry.value;
      if ((state.status == MessageIdStatus.completed ||
              state.status == MessageIdStatus.cancelled) &&
          state.updatedAt.isBefore(cutoffTime)) {
        expiredIds.add(entry.key);
      }
    }

    for (final id in expiredIds) {
      cleanupMessageIds(id);
    }

    _logger.info('清理过期ID', {
      'expiredCount': expiredIds.length,
      'cutoffTime': cutoffTime.toIso8601String(),
    });
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    final typeStats = <String, int>{};
    final statusStats = <String, int>{};

    for (final state in _idStates.values) {
      typeStats[state.type.name] = (typeStats[state.type.name] ?? 0) + 1;
      statusStats[state.status.name] =
          (statusStats[state.status.name] ?? 0) + 1;
    }

    return {
      'totalIds': _idStates.length,
      'streamingIds': _streamingIdMap.length,
      'typeStats': typeStats,
      'statusStats': statusStats,
      'relationCount': _idService.relationCount,
    };
  }

  /// 清理所有状态
  void dispose() {
    _idStates.clear();
    _streamingIdMap.clear();
    _idService.clearAllRelations();

    _logger.info('MessageIdManager已清理');
  }
}

/// 消息ID状态
class MessageIdState {
  final String id;
  final MessageIdType type;
  final MessageIdStatus status;
  final String? conversationId;
  final String? assistantId;
  final String? modelId;
  final String? parentId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MessageIdState({
    required this.id,
    required this.type,
    required this.status,
    this.conversationId,
    this.assistantId,
    this.modelId,
    this.parentId,
    this.metadata,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  MessageIdState copyWith({
    MessageIdStatus? status,
    String? conversationId,
    String? assistantId,
    String? modelId,
    String? parentId,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return MessageIdState(
      id: id,
      type: type,
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      assistantId: assistantId ?? this.assistantId,
      modelId: modelId ?? this.modelId,
      parentId: parentId ?? this.parentId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// 消息ID类型
enum MessageIdType {
  userMessage,
  aiMessage,
  systemMessage,
  messageBlock,
  request,
}

/// 消息ID状态
enum MessageIdStatus {
  created,
  processing,
  streaming,
  completed,
  failed,
  cancelled,
}
