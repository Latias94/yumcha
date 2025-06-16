import 'dart:async';
import 'package:flutter/foundation.dart';
import '../entities/message.dart';
import '../entities/message_status.dart';
import '../entities/message_block.dart';
import '../entities/message_block_type.dart';
import '../entities/message_block_status.dart';
import '../repositories/message_repository.dart';
import 'message_state_machine.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 流式消息更新事件
@immutable
class StreamingMessageUpdate {
  final String messageId;
  final String? contentDelta;
  final String? thinkingDelta;
  final String? fullContent;
  final String? fullThinking;
  final MessageStatus status;
  final bool isDone;
  final String? error;
  final Map<String, dynamic>? metadata;

  const StreamingMessageUpdate({
    required this.messageId,
    this.contentDelta,
    this.thinkingDelta,
    this.fullContent,
    this.fullThinking,
    required this.status,
    this.isDone = false,
    this.error,
    this.metadata,
  });

  /// 创建内容更新事件
  factory StreamingMessageUpdate.contentUpdate({
    required String messageId,
    String? contentDelta,
    String? thinkingDelta,
    String? fullContent,
    String? fullThinking,
    Map<String, dynamic>? metadata,
  }) {
    return StreamingMessageUpdate(
      messageId: messageId,
      contentDelta: contentDelta,
      thinkingDelta: thinkingDelta,
      fullContent: fullContent,
      fullThinking: fullThinking,
      status: MessageStatus.aiStreaming,
      metadata: metadata,
    );
  }

  /// 创建完成事件
  factory StreamingMessageUpdate.completed({
    required String messageId,
    String? fullContent,
    String? fullThinking,
    Map<String, dynamic>? metadata,
  }) {
    return StreamingMessageUpdate(
      messageId: messageId,
      fullContent: fullContent,
      fullThinking: fullThinking,
      status: MessageStatus.aiSuccess,
      isDone: true,
      metadata: metadata,
    );
  }

  /// 创建错误事件
  factory StreamingMessageUpdate.error({
    required String messageId,
    required String error,
    String? partialContent,
    String? partialThinking,
  }) {
    return StreamingMessageUpdate(
      messageId: messageId,
      fullContent: partialContent,
      fullThinking: partialThinking,
      status: MessageStatus.aiError,
      isDone: true,
      error: error,
    );
  }

  bool get isError => error != null;
  bool get hasContent => contentDelta != null || fullContent != null;
  bool get hasThinking => thinkingDelta != null || fullThinking != null;
}

/// 流式消息上下文
class _StreamingContext {
  final String messageId;
  final String conversationId;
  final String assistantId;
  final String? modelId;
  final DateTime startTime;
  final Map<String, dynamic>? initialMetadata;
  
  // 内容累积
  final StringBuffer _contentBuffer = StringBuffer();
  final StringBuffer _thinkingBuffer = StringBuffer();
  
  // 状态管理
  MessageStatus _status = MessageStatus.aiPending;
  final MessageStateMachine _stateMachine = MessageStateMachine();

  _StreamingContext({
    required this.messageId,
    required this.conversationId,
    required this.assistantId,
    this.modelId,
    this.initialMetadata,
  }) : startTime = DateTime.now();

  String get fullContent => _contentBuffer.toString();
  String get fullThinking => _thinkingBuffer.toString();
  MessageStatus get status => _status;
  Duration get duration => DateTime.now().difference(startTime);

  void appendContent(String content) {
    _contentBuffer.write(content);
  }

  void appendThinking(String thinking) {
    _thinkingBuffer.write(thinking);
  }

  bool updateStatus(MessageStateEvent event) {
    final result = _stateMachine.transition(
      currentStatus: _status,
      event: event,
    );
    
    if (result.isValid) {
      _status = result.newStatus;
      return true;
    }
    return false;
  }

  void setContent(String content) {
    _contentBuffer.clear();
    _contentBuffer.write(content);
  }

  void setThinking(String thinking) {
    _thinkingBuffer.clear();
    _thinkingBuffer.write(thinking);
  }
}

/// 流式消息服务
/// 
/// 专门处理流式消息的业务逻辑，包括：
/// - 流式消息的生命周期管理
/// - 内容累积和状态转换
/// - 错误处理和恢复
/// - 与Repository层的协调
class StreamingMessageService {
  final MessageRepository _messageRepository;
  final LoggerService _logger = LoggerService();
  
  /// 活跃的流式上下文
  final Map<String, _StreamingContext> _activeContexts = {};
  
  /// 流式更新控制器
  final StreamController<StreamingMessageUpdate> _updateController = 
      StreamController<StreamingMessageUpdate>.broadcast();

  StreamingMessageService(this._messageRepository);

  /// 流式更新流
  Stream<StreamingMessageUpdate> get updateStream => _updateController.stream;

  /// 初始化流式消息
  Future<void> initializeStreaming({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 创建流式上下文
      final context = _StreamingContext(
        messageId: messageId,
        conversationId: conversationId,
        assistantId: assistantId,
        modelId: modelId,
        initialMetadata: metadata,
      );

      _activeContexts[messageId] = context;

      // 更新状态为开始流式传输
      context.updateStatus(MessageStateEvent.startStreaming);

      // 初始化Repository层的流式处理
      await _messageRepository.startStreamingMessage(messageId);
      _messageRepository.setStreamingMessageInfo(
        messageId: messageId,
        conversationId: conversationId,
        assistantId: assistantId,
        modelId: modelId,
        metadata: metadata,
      );

      _logger.info('流式消息已初始化', {
        'messageId': messageId,
        'conversationId': conversationId,
        'assistantId': assistantId,
      });

    } catch (error) {
      _logger.error('初始化流式消息失败', {
        'messageId': messageId,
        'error': error.toString(),
      });
      rethrow;
    }
  }

  /// 更新流式内容
  Future<void> updateContent({
    required String messageId,
    String? contentDelta,
    String? thinkingDelta,
    String? fullContent,
    String? fullThinking,
    Map<String, dynamic>? metadata,
  }) async {
    final context = _activeContexts[messageId];
    if (context == null) {
      _logger.warning('流式上下文不存在', {'messageId': messageId});
      return;
    }

    try {
      // 更新内容缓冲区
      if (contentDelta != null) {
        context.appendContent(contentDelta);
      }
      if (thinkingDelta != null) {
        context.appendThinking(thinkingDelta);
      }
      if (fullContent != null) {
        context.setContent(fullContent);
      }
      if (fullThinking != null) {
        context.setThinking(fullThinking);
      }

      // 确保状态为流式传输中
      context.updateStatus(MessageStateEvent.streaming);

      // 更新Repository层
      await _messageRepository.updateStreamingContent(
        messageId: messageId,
        content: context.fullContent,
        thinkingContent: context.fullThinking.isNotEmpty ? context.fullThinking : null,
      );

      // 发送更新事件
      _updateController.add(StreamingMessageUpdate.contentUpdate(
        messageId: messageId,
        contentDelta: contentDelta,
        thinkingDelta: thinkingDelta,
        fullContent: context.fullContent,
        fullThinking: context.fullThinking.isNotEmpty ? context.fullThinking : null,
        metadata: metadata,
      ));

    } catch (error) {
      _logger.error('更新流式内容失败', {
        'messageId': messageId,
        'error': error.toString(),
      });
      await _handleStreamingError(messageId, error.toString());
    }
  }

  /// 完成流式消息
  Future<void> completeStreaming({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    final context = _activeContexts[messageId];
    if (context == null) {
      _logger.warning('流式上下文不存在', {'messageId': messageId});
      return;
    }

    try {
      // 更新状态为完成
      context.updateStatus(MessageStateEvent.complete);

      // 完成Repository层的流式处理
      await _messageRepository.finishStreamingMessage(
        messageId: messageId,
        metadata: {
          ...?context.initialMetadata,
          ...?metadata,
          'duration': context.duration.inMilliseconds,
          'contentLength': context.fullContent.length,
          'hasThinking': context.fullThinking.isNotEmpty,
        },
      );

      // 发送完成事件
      _updateController.add(StreamingMessageUpdate.completed(
        messageId: messageId,
        fullContent: context.fullContent,
        fullThinking: context.fullThinking.isNotEmpty ? context.fullThinking : null,
        metadata: metadata,
      ));

      // 清理上下文
      _activeContexts.remove(messageId);

      _logger.info('流式消息已完成', {
        'messageId': messageId,
        'duration': context.duration.inMilliseconds,
        'contentLength': context.fullContent.length,
      });

    } catch (error) {
      _logger.error('完成流式消息失败', {
        'messageId': messageId,
        'error': error.toString(),
      });
      await _handleStreamingError(messageId, error.toString());
    }
  }

  /// 处理流式错误
  Future<void> _handleStreamingError(String messageId, String errorMessage) async {
    final context = _activeContexts[messageId];
    if (context == null) return;

    try {
      // 更新状态为错误
      context.updateStatus(MessageStateEvent.error);

      // 处理Repository层的错误
      await _messageRepository.handleStreamingError(
        messageId: messageId,
        errorMessage: errorMessage,
        partialContent: context.fullContent.isNotEmpty ? context.fullContent : null,
      );

      // 发送错误事件
      _updateController.add(StreamingMessageUpdate.error(
        messageId: messageId,
        error: errorMessage,
        partialContent: context.fullContent.isNotEmpty ? context.fullContent : null,
        partialThinking: context.fullThinking.isNotEmpty ? context.fullThinking : null,
      ));

      // 清理上下文
      _activeContexts.remove(messageId);

    } catch (error) {
      _logger.error('处理流式错误失败', {
        'messageId': messageId,
        'originalError': errorMessage,
        'handlingError': error.toString(),
      });
    }
  }

  /// 暂停流式消息
  Future<void> pauseStreaming(String messageId) async {
    final context = _activeContexts[messageId];
    if (context == null) return;

    if (context.updateStatus(MessageStateEvent.pause)) {
      _logger.info('流式消息已暂停', {'messageId': messageId});
    }
  }

  /// 恢复流式消息
  Future<void> resumeStreaming(String messageId) async {
    final context = _activeContexts[messageId];
    if (context == null) return;

    if (context.updateStatus(MessageStateEvent.resume)) {
      _logger.info('流式消息已恢复', {'messageId': messageId});
    }
  }

  /// 取消流式消息
  Future<void> cancelStreaming(String messageId) async {
    final context = _activeContexts[messageId];
    if (context == null) return;

    await _handleStreamingError(messageId, '用户取消');
  }

  /// 获取活跃的流式消息数量
  int get activeStreamingCount => _activeContexts.length;

  /// 获取流式消息状态
  MessageStatus? getStreamingStatus(String messageId) {
    return _activeContexts[messageId]?.status;
  }

  /// 清理资源
  Future<void> dispose() async {
    // 取消所有活跃的流式消息
    final messageIds = _activeContexts.keys.toList();
    for (final messageId in messageIds) {
      await cancelStreaming(messageId);
    }

    // 关闭流控制器
    await _updateController.close();

    _logger.info('StreamingMessageService已清理', {
      'cancelledStreams': messageIds.length,
    });
  }
}
