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
import '../../infrastructure/debug/streaming_debug_helper.dart';

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

      // 🔍 开始调试跟踪
      StreamingDebugHelper.startTracking(messageId);

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
      // 🔍 调试日志：记录更新前的状态
      final beforeContent = context.fullContent;
      final beforeLength = beforeContent.length;

      // 更新内容缓冲区
      if (contentDelta != null) {
        context.appendContent(contentDelta);
        _logger.debug('流式内容增量更新', {
          'messageId': messageId,
          'deltaLength': contentDelta.length,
          'deltaContent': contentDelta.length > 50
              ? '${contentDelta.substring(0, 50)}...'
              : contentDelta,
          'beforeLength': beforeLength,
          'afterLength': context.fullContent.length,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      if (thinkingDelta != null) {
        context.appendThinking(thinkingDelta);
        _logger.debug('流式思考增量更新', {
          'messageId': messageId,
          'thinkingDeltaLength': thinkingDelta.length,
          'thinkingDelta': thinkingDelta.length > 30
              ? '${thinkingDelta.substring(0, 30)}...'
              : thinkingDelta,
        });
      }
      if (fullContent != null) {
        context.setContent(fullContent);
        _logger.debug('流式内容全量更新', {
          'messageId': messageId,
          'fullContentLength': fullContent.length,
          'contentPreview': fullContent.length > 100
              ? '${fullContent.substring(0, 100)}...'
              : fullContent,
          'contentSuffix': fullContent.length > 50
              ? '...${fullContent.substring(fullContent.length - 50)}'
              : fullContent,
          'beforeLength': beforeLength,
          'lengthDiff': fullContent.length - beforeLength,
        });
      }
      if (fullThinking != null) {
        context.setThinking(fullThinking);
      }

      // 🔍 调试日志：记录更新后的完整状态
      final afterContent = context.fullContent;

      // 🔍 记录到调试跟踪器
      StreamingDebugHelper.recordContentUpdate(
        messageId,
        afterContent,
        source: 'StreamingMessageService.updateContent'
      );

      _logger.info('流式内容更新完成', {
        'messageId': messageId,
        'finalLength': afterContent.length,
        'contentEnding': afterContent.length > 20
            ? '...${afterContent.substring(afterContent.length - 20)}'
            : afterContent,
        'hasThinking': context.fullThinking.isNotEmpty,
        'thinkingLength': context.fullThinking.length,
        'updateType': contentDelta != null ? 'delta' : 'full',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 确保状态为流式传输中
      context.updateStatus(MessageStateEvent.streaming);

      // 🚀 修复：必须调用Repository的updateStreamingContent来缓存内容
      // 这样在流式完成时才有内容可以保存到数据库
      await _messageRepository.updateStreamingContent(
        messageId: messageId,
        content: context.fullContent,
        thinkingContent: context.fullThinking.isNotEmpty ? context.fullThinking : null,
      );

      // 🔍 调试日志：验证Repository更新
      _logger.debug('Repository内容更新完成', {
        'messageId': messageId,
        'sentContentLength': context.fullContent.length,
        'sentContentEnding': context.fullContent.length > 15
            ? '...${context.fullContent.substring(context.fullContent.length - 15)}'
            : context.fullContent,
      });

      // 发送UI更新事件
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
        'contentLength': context.fullContent.length,
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
      _logger.warning('流式上下文不存在，可能是应用重启导致', {
        'messageId': messageId,
        'action': '尝试直接完成Repository层处理',
      });

      // 🚀 修复：即使没有上下文，也尝试完成Repository层的处理
      // 这种情况可能发生在应用重启后
      try {
        await _messageRepository.finishStreamingMessage(
          messageId: messageId,
          metadata: metadata,
        );
        _logger.info('无上下文情况下完成流式消息', {'messageId': messageId});
      } catch (error) {
        _logger.error('无上下文情况下完成流式消息失败', {
          'messageId': messageId,
          'error': error.toString(),
        });
      }
      return;
    }

    try {
      // 🔍 调试日志：记录完成前的最终状态
      final finalContent = context.fullContent;
      final finalThinking = context.fullThinking;

      _logger.info('开始完成流式消息', {
        'messageId': messageId,
        'finalContentLength': finalContent.length,
        'finalContentPreview': finalContent.length > 100
            ? '${finalContent.substring(0, 100)}...'
            : finalContent,
        'finalContentEnding': finalContent.length > 30
            ? '...${finalContent.substring(finalContent.length - 30)}'
            : finalContent,
        'hasThinking': finalThinking.isNotEmpty,
        'thinkingLength': finalThinking.length,
        'duration': context.duration.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 更新状态为完成
      context.updateStatus(MessageStateEvent.complete);

      // 🔍 调试日志：准备发送到Repository的内容
      _logger.debug('发送到Repository的最终内容', {
        'messageId': messageId,
        'contentToSend': finalContent.length > 200
            ? '${finalContent.substring(0, 100)}...${finalContent.substring(finalContent.length - 100)}'
            : finalContent,
        'contentLength': finalContent.length,
        'lastCharacters': finalContent.length > 10
            ? finalContent.substring(finalContent.length - 10)
            : finalContent,
      });

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

      // 🔍 调试日志：Repository完成后验证
      _logger.debug('Repository完成流式消息处理', {
        'messageId': messageId,
        'sentContentLength': finalContent.length,
      });

      // 发送完成事件
      _updateController.add(StreamingMessageUpdate.completed(
        messageId: messageId,
        fullContent: context.fullContent,
        fullThinking: context.fullThinking.isNotEmpty ? context.fullThinking : null,
        metadata: metadata,
      ));

      // 🔍 调试日志：发送UI更新事件
      _logger.debug('发送流式完成事件到UI', {
        'messageId': messageId,
        'eventContentLength': context.fullContent.length,
        'eventContentEnding': context.fullContent.length > 20
            ? '...${context.fullContent.substring(context.fullContent.length - 20)}'
            : context.fullContent,
      });

      // 🔍 生成调试报告
      final debugReport = StreamingDebugHelper.finishTracking(messageId);

      // 清理上下文
      _activeContexts.remove(messageId);

      _logger.info('流式消息已完成', {
        'messageId': messageId,
        'duration': context.duration.inMilliseconds,
        'contentLength': context.fullContent.length,
        'finalContent': context.fullContent.length > 50
            ? '...${context.fullContent.substring(context.fullContent.length - 50)}'
            : context.fullContent,
        'success': true,
        'debugReport': debugReport,
      });

    } catch (error) {
      _logger.error('完成流式消息失败', {
        'messageId': messageId,
        'error': error.toString(),
        'contextContentLength': context.fullContent.length,
        'contextContent': context.fullContent.length > 100
            ? '...${context.fullContent.substring(context.fullContent.length - 100)}'
            : context.fullContent,
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

  /// 清理所有活跃的流式上下文
  /// 在应用重启或需要重置状态时调用
  void cleanupAllActiveContexts() {
    final activeCount = _activeContexts.length;
    if (activeCount > 0) {
      _logger.info('清理所有活跃的流式上下文', {
        'activeContextsCount': activeCount,
        'messageIds': _activeContexts.keys.toList(),
      });

      _activeContexts.clear();
    }
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
