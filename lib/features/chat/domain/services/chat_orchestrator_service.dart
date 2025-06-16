import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../entities/chat_state.dart';
import '../entities/message.dart';
import '../entities/message_status.dart';
import 'message_factory.dart';
import 'unified_message_creator.dart';

import '../../../../shared/infrastructure/services/ai/block_based_chat_service.dart';
import '../../data/repositories/conversation_repository.dart';
import '../repositories/message_repository.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../../shared/infrastructure/services/ai/providers/block_chat_provider.dart';

/// 流式传输上下文 - 管理单个流式消息的完整生命周期
class _StreamingContext {
  final StreamSubscription subscription;
  final DateTime startTime;
  final String messageId;
  final Completer<ChatOperationResult<Message>>? completer;

  _StreamingContext({
    required this.subscription,
    required this.startTime,
    required this.messageId,
    this.completer,
  });

  /// 取消流式传输
  Future<void> cancel() async {
    await subscription.cancel();
  }

  /// 获取持续时间
  Duration get duration => DateTime.now().difference(startTime);
}

/// 队列消息 - 支持优先级的消息队列项
class _QueuedMessage {
  final SendMessageParams params;
  final DateTime queueTime;

  _QueuedMessage({
    required this.params,
    required this.queueTime,
  });

  /// 获取等待时间
  Duration get waitTime => DateTime.now().difference(queueTime);
}

/// 聊天编排服务 - 核心业务逻辑处理
///
/// 重构优化版本，遵循Riverpod最佳实践和性能优化原则：
///
/// 核心职责：
/// - 🚀 **消息编排**: 协调用户消息和AI响应的完整流程
/// - 📡 **流式处理**: 高效管理实时流式消息传输
/// - 🔄 **状态管理**: 维护聊天状态和消息生命周期
/// - ⚡ **性能优化**: 内存管理、并发控制、资源清理
/// - 🛡️ **错误恢复**: 完善的错误处理和恢复机制
///
/// 设计原则：
/// - 单一职责：专注于消息编排，不处理UI逻辑
/// - 依赖注入：通过Provider获取所有依赖
/// - 资源管理：自动清理订阅和缓存
/// - 性能优先：优化内存使用和响应速度
/// - 错误隔离：单个消息错误不影响整体服务
class ChatOrchestratorService {
  ChatOrchestratorService(this._ref) {
    _initializePerformanceMonitoring();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();
  final MessageFactory _messageFactory = MessageFactory();

  /// 统一消息创建器（延迟初始化）
  UnifiedMessageCreator? _unifiedMessageCreator;

  /// 活跃的流式订阅管理 - 优化内存使用
  final Map<String, _StreamingContext> _activeStreams = {};

  /// 消息队列（用于处理并发请求）- 增加优先级支持
  final Queue<_QueuedMessage> _messageQueue = Queue();

  /// 队列处理状态
  bool _isProcessingQueue = false;

  /// 性能指标 - 实时更新
  ChatPerformanceMetrics _performanceMetrics = const ChatPerformanceMetrics();

  /// 统计信息 - 增强统计
  ChatStatistics _statistics = const ChatStatistics();

  /// 流式更新回调
  void Function(StreamingUpdate)? _onStreamingUpdate;

  /// 用户消息创建回调
  void Function(Message)? _onUserMessageCreated;



  /// 性能监控定时器
  Timer? _performanceTimer;

  /// 消息内容缓存 - 优化重复内容处理
  final Map<String, String> _contentCache = {};

  /// 最大缓存大小
  static const int _maxCacheSize = 50;

  /// 获取块化聊天服务
  BlockBasedChatService get _blockChatService => _ref.read(blockBasedChatServiceProvider);

  /// 获取对话存储库
  ConversationRepository get _conversationRepository =>
      _ref.read(conversationRepositoryProvider);

  /// 获取消息存储库
  MessageRepository get _messageRepository =>
      _ref.read(messageRepositoryProvider);

  /// 获取统一消息创建器（延迟初始化）
  UnifiedMessageCreator get _messageCreator {
    _unifiedMessageCreator ??= UnifiedMessageCreator(
      messageFactory: _messageFactory,
      messageRepository: _messageRepository,
    );
    return _unifiedMessageCreator!;
  }

  /// 初始化性能监控
  void _initializePerformanceMonitoring() {
    _performanceTimer = Timer.periodic(
      ChatConstants.performanceCheckInterval,
      (_) => _updatePerformanceMetrics(),
    );
    _logger.info('性能监控已启动');
  }

  /// 更新性能指标
  void _updatePerformanceMetrics() {
    _performanceMetrics = _performanceMetrics.copyWith(
      activeSubscriptions: _activeStreams.length,
      cachedMessages: _contentCache.length,
      lastOperationTime: DateTime.now().difference(
        _statistics.lastActivity ?? DateTime.now(),
      ),
    );



    // 清理内容缓存
    _cleanupContentCache();
  }



  /// 清理内容缓存
  void _cleanupContentCache() {
    if (_contentCache.length > _maxCacheSize) {
      final keysToRemove = _contentCache.keys.take(_contentCache.length - _maxCacheSize);
      for (final key in keysToRemove) {
        _contentCache.remove(key);
      }
      _logger.debug('清理内容缓存', {'清理数量': keysToRemove.length});
    }
  }

  /// 设置流式更新回调
  void setStreamingUpdateCallback(void Function(StreamingUpdate) callback) {
    _logger.info('设置流式更新回调', {
      'callbackSet': true,
      'callbackType': callback.runtimeType.toString(),
      'previousCallback': _onStreamingUpdate != null,
      'callbackHashCode': callback.hashCode,
    });
    _onStreamingUpdate = callback;

    // 验证回调设置
    if (_onStreamingUpdate != null) {
      _logger.info('流式更新回调设置成功', {
        'callbackHashCode': _onStreamingUpdate.hashCode,
        'isCallbackSame': identical(_onStreamingUpdate, callback),
      });
    } else {
      _logger.error('流式更新回调设置失败');
    }
  }

  /// 设置用户消息创建回调
  void setUserMessageCreatedCallback(void Function(Message) callback) {
    _logger.info('设置用户消息创建回调');
    _onUserMessageCreated = callback;
  }

  /// 发送消息
  Future<ChatOperationResult<Message>> sendMessage(
    SendMessageParams params,
  ) async {
    try {
      // 参数验证
      if (!params.isValid) {
        return const ChatOperationFailure('无效的消息参数');
      }

      _logger.info('开始发送消息', {
        'conversationId': params.conversationId,
        'contentLength': params.content.length,
        'useStreaming': params.useStreaming,
        'assistant': params.assistant.name,
        'provider': params.provider.name,
        'model': params.model.name,
      });

      // 🚀 优化：使用统一消息创建器，自动处理保存
      final userMessage = await _messageCreator.createUserMessage(
        content: params.content,
        conversationId: params.conversationId,
        assistantId: params.assistant.id,
        saveToDatabase: true, // 用户消息立即保存
      );

      // 通知UI添加用户消息
      _onUserMessageCreated?.call(userMessage);

      // 处理AI响应
      if (params.useStreaming) {
        return await _handleStreamingResponse(userMessage, params);
      } else {
        return await _handleNormalResponse(userMessage, params);
      }
    } catch (error, stackTrace) {
      _logger.error('发送消息失败', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });

      _updateStatistics(failed: true);
      return ChatOperationFailure(
        '发送消息失败: $error',
        originalError: error,
      );
    }
  }

  /// 处理流式响应
  Future<ChatOperationResult<Message>> _handleStreamingResponse(
    Message userMessage,
    SendMessageParams params,
  ) async {
    // 检查并发流数量限制
    if (_activeStreams.length >= ChatConstants.maxConcurrentStreams) {
      _logger.warning('达到最大并发流数量限制', {
        'activeStreams': _activeStreams.length,
        'maxConcurrent': ChatConstants.maxConcurrentStreams,
      });

      // 将请求加入队列
      _messageQueue.add(_QueuedMessage(
        params: params,
        queueTime: DateTime.now(),
      ));
      _processMessageQueue();

      return const ChatOperationLoading();
    }

    try {
      // 获取聊天历史
      final chatHistory = await _getChatHistory(params.conversationId);

      // 开始流式传输
      final stream = _blockChatService.sendBlockMessageStream(
        conversationId: params.conversationId,
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.model.name,
        chatHistory: chatHistory,
        userMessage: userMessage.content,
      );

      // 简化的流式处理 - 直接使用消息ID作为key
      final completer = Completer<ChatOperationResult<Message>>();
      Message? lastMessage;
      String? messageId; // 流式消息的唯一ID
      StreamSubscription? subscription;

      subscription = stream.listen(
        (message) async {
          lastMessage = message;
          messageId ??= message.id;

          // 首次收到消息时，注册到活跃流管理
          if (!_activeStreams.containsKey(messageId)) {
            _activeStreams[messageId!] = _StreamingContext(
              subscription: subscription!,
              startTime: DateTime.now(),
              messageId: messageId!,
              completer: completer,
            );
          }

          await _handleStreamingMessage(
            message,
            messageId!,
            params.conversationId,
            completer,
          );
        },
        onError: (error) {
          final errorMessage = lastMessage ?? _messageFactory.createAiMessagePlaceholder(
            conversationId: params.conversationId,
            assistantId: params.assistant.id,
          );
          _handleStreamingError(error, errorMessage, params.conversationId, completer);
        },
        onDone: () async {
          if (!completer.isCompleted && lastMessage != null) {
            _logger.debug('流式传输完成', {'messageId': lastMessage!.id});
            await _completeStreamingMessageFromBlock(
              lastMessage!,
              params.conversationId,
              completer,
            );
          }
        },
      );

      // 设置超时处理
      Timer(ChatConstants.streamingTimeout, () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          if (messageId != null) {
            _activeStreams.remove(messageId);
          }
          completer.complete(const ChatOperationFailure('流式传输超时'));
        }
      });

      return await completer.future;
    } catch (error) {
      _logger.error('流式传输启动失败', {
        'error': error.toString(),
        'conversationId': params.conversationId,
      });
      rethrow;
    }
  }

  /// 处理普通响应
  Future<ChatOperationResult<Message>> _handleNormalResponse(
    Message userMessage,
    SendMessageParams params,
  ) async {
    try {
      // 获取聊天历史
      final chatHistory = await _getChatHistory(params.conversationId);

      final startTime = DateTime.now();

      // 发送请求
      final aiMessage = await _blockChatService.sendBlockMessage(
        conversationId: params.conversationId,
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.model.name,
        chatHistory: chatHistory,
        userMessage: userMessage.content,
      );

      final duration = DateTime.now().difference(startTime);

      // 块化消息已经包含了完整的消息结构，直接使用
      final completedMessage = aiMessage.copyWith(
        status: MessageStatus.aiSuccess,
        updatedAt: DateTime.now(),
        metadata: {
          ...?aiMessage.metadata,
          'duration': duration.inMilliseconds,
        },
      );

      await _persistMessage(completedMessage, params.conversationId);
      _updateStatistics(duration: duration);

      _logger.info('普通消息处理成功', {
        'conversationId': params.conversationId,
        'messageId': completedMessage.id,
        'blocksCount': completedMessage.blocks.length,
        'duration': duration.inMilliseconds,
      });

      return ChatOperationSuccess(completedMessage);
    } catch (error) {
      _updateStatistics(failed: true);
      rethrow;
    }
  }

  /// 处理流式消息更新
  Future<void> _handleStreamingMessage(
    Message message,
    String originalMessageId,
    String conversationId,
    Completer<ChatOperationResult<Message>> completer,
  ) async {
    try {
      // 从块化消息中提取内容
      final fullContent = _extractContentFromMessage(message);

      // 通知UI更新流式消息
      _notifyStreamingUpdate(StreamingUpdate(
        messageId: originalMessageId,
        fullContent: fullContent,
        isDone: message.status == MessageStatus.aiSuccess,
      ));
    } catch (error) {
      await _handleStreamingError(error, message, conversationId, completer);
    }
  }

  /// 从消息中提取内容
  String _extractContentFromMessage(Message message) {
    final contentParts = <String>[];

    for (final block in message.blocks) {
      if (block.content != null && block.content!.isNotEmpty) {
        contentParts.add(block.content!);
      }
    }

    return contentParts.join('\n\n');
  }

  /// 完成块化流式消息
  Future<void> _completeStreamingMessageFromBlock(
    Message completedMessage,
    String conversationId,
    Completer<ChatOperationResult<Message>> completer,
  ) async {
    // 防止重复完成同一个消息
    if (completer.isCompleted) {
      _logger.warning('消息已完成，跳过重复处理', {
        'messageId': completedMessage.id,
        'conversationId': conversationId,
      });
      return;
    }

    try {
      final fullContent = _extractContentFromMessage(completedMessage);

      final finalMessage = completedMessage.copyWith(
        status: MessageStatus.aiSuccess,
        updatedAt: DateTime.now(),
      );

      // 通知UI流式完成（只有在消息状态不是已成功时才发送，避免重复通知）
      if (completedMessage.status != MessageStatus.aiSuccess) {
        _notifyStreamingUpdate(StreamingUpdate(
          messageId: completedMessage.id,
          fullContent: fullContent,
          isDone: true,
        ));
      }

      // 🚀 优化：不再重复保存消息，因为MessageRepository.finishStreamingMessage已经处理了保存
      // 只需要确保消息状态正确即可

      // 清理订阅 - 直接使用消息ID作为key
      final streamContext = _activeStreams[completedMessage.id];
      if (streamContext != null) {
        await streamContext.cancel();
        _activeStreams.remove(completedMessage.id);
      }

      _updateStatistics();

      _logger.info('块化流式消息完成', {
        'messageId': completedMessage.id,
        'blocksCount': completedMessage.blocks.length,
        'contentLength': fullContent.length,
        'conversationId': conversationId,
      });

      // 确保只完成一次
      if (!completer.isCompleted) {
        completer.complete(ChatOperationSuccess(finalMessage));
      }
    } catch (error) {
      // 只有在completer未完成时才处理错误
      if (!completer.isCompleted) {
        await _handleStreamingError(error, completedMessage, conversationId, completer);
      } else {
        _logger.error('块化流式消息完成时发生错误（但completer已完成）', {
          'messageId': completedMessage.id,
          'error': error.toString(),
        });
      }
    }
  }

  /// 处理流式错误
  Future<void> _handleStreamingError(
    Object error,
    Message aiMessage,
    String conversationId,
    Completer<ChatOperationResult<Message>> completer,
  ) async {
    // 防止重复处理错误
    if (completer.isCompleted) {
      _logger.warning('错误处理时发现completer已完成', {
        'messageId': aiMessage.id,
        'error': error.toString(),
      });
      return;
    }

    // 分析错误类型并提供用户友好的错误信息
    final errorMessage = _getUserFriendlyErrorMessage(error);

    _logger.error('流式传输错误', {
      'messageId': aiMessage.id,
      'error': error.toString(),
      'userMessage': errorMessage,
    });

    // 清理订阅 - 直接使用消息ID作为key
    final streamContext = _activeStreams[aiMessage.id];
    if (streamContext != null) {
      await streamContext.cancel();
      _activeStreams.remove(aiMessage.id);
    }

    _updateStatistics(failed: true);

    // 确保只完成一次
    if (!completer.isCompleted) {
      completer.complete(
        ChatOperationFailure(errorMessage),
      );
    }
  }

  /// 获取用户友好的错误信息
  String _getUserFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return '网络连接失败，请检查网络设置';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('api key')) {
      return 'API密钥无效，请检查配置';
    }

    if (errorString.contains('rate limit') ||
        errorString.contains('quota')) {
      return '请求过于频繁，请稍后再试';
    }

    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'AI服务暂时不可用，请稍后重试';
    }

    if (errorString.contains('model') && errorString.contains('not found')) {
      return '所选模型不可用，请尝试其他模型';
    }

    // 对于"Unknown error: null"这类错误
    if (errorString.contains('unknown') ||
        errorString.contains('null') ||
        errorString.trim().isEmpty) {
      return '连接失败，请检查网络和API配置';
    }

    return '发送失败，请重试';
  }

  /// 取消流式传输 - 优化版本，支持优雅关闭
  Future<void> cancelStreaming(String messageId) async {
    final context = _activeStreams[messageId];
    if (context != null) {
      await context.cancel();
      _activeStreams.remove(messageId);

      _logger.info('流式传输已取消', {
        'messageId': messageId,
        'duration': context.duration.inMilliseconds,
      });
    }
  }

  /// 取消所有流式传输 - 优化版本，支持批量取消
  Future<void> cancelAllStreaming() async {
    final contexts = _activeStreams.values.toList();
    final futures = contexts.map((context) => context.cancel());
    await Future.wait(futures);
    _activeStreams.clear();

    _logger.info('所有流式传输已取消', {
      'cancelledCount': contexts.length,
    });
  }

  /// 处理消息队列 - 优化版本，支持优先级处理
  Future<void> _processMessageQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      while (_messageQueue.isNotEmpty &&
          _activeStreams.length < ChatConstants.maxConcurrentStreams) {
        final queuedMessage = _messageQueue.removeFirst();

        // 记录队列等待时间
        final waitTime = queuedMessage.waitTime;
        _logger.debug('处理队列消息', {
          'messageId': queuedMessage.params.conversationId,
          'waitTime': waitTime.inMilliseconds,
        });

        await sendMessage(queuedMessage.params);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // 注意：_createUserMessage 和 _createAiMessage 方法已被移除
  // 现在统一使用 UnifiedMessageCreator 来创建消息

  /// 获取聊天历史
  Future<List<Message>> _getChatHistory(String conversationId) async {
    try {
      final conversation =
          await _conversationRepository.getConversation(conversationId);

      // ConversationRepository 现在直接返回新的 Message 对象
      final messages = conversation?.messages ?? [];

      _logger.info('获取聊天历史成功', {
        'conversationId': conversationId,
        'messageCount': messages.length,
      });

      return messages;
    } catch (error) {
      _logger.warning('获取聊天历史失败', {
        'conversationId': conversationId,
        'error': error.toString(),
      });
      return [];
    }
  }

  /// 持久化消息 - 简化版本，统一在Repository层处理重复检测
  Future<void> _persistMessage(Message message, String conversationId) async {
    try {
      _logger.info('开始持久化消息', {
        'messageId': message.id,
        'conversationId': conversationId,
        'role': message.role,
        'contentLength': message.content.length,
      });

      // 使用MessageRepository统一保存消息，Repository层会处理重复检测
      await _messageRepository.saveMessage(message);

      _logger.info('消息持久化成功', {
        'messageId': message.id,
        'conversationId': conversationId,
      });
    } catch (error) {
      _logger.error('消息持久化失败', {
        'messageId': message.id,
        'conversationId': conversationId,
        'error': error.toString(),
      });

      // 重新抛出错误，让上层处理
      rethrow;
    }
  }

  /// 通知流式更新
  void _notifyStreamingUpdate(StreamingUpdate update) {
    // _logger.info('通知流式更新', {
    //   'messageId': update.messageId,
    //   'hasCallback': _onStreamingUpdate != null,
    //   'isDone': update.isDone,
    //   'contentLength': update.fullContent?.length ?? 0,
    //   'callbackType': _onStreamingUpdate?.runtimeType.toString(),
    // });

    if (_onStreamingUpdate != null) {
      _onStreamingUpdate!(update);
      // _logger.info('流式更新回调已调用', {'messageId': update.messageId});
    } else {
      _logger.warning('流式更新回调为空', {'messageId': update.messageId});
    }
  }

  /// 更新统计信息
  void _updateStatistics({Duration? duration, bool failed = false}) {
    _statistics = _statistics.copyWith(
      totalMessages: _statistics.totalMessages + 1,
      failedMessages:
          failed ? _statistics.failedMessages + 1 : _statistics.failedMessages,
      totalChatTime: duration != null
          ? _statistics.totalChatTime + duration
          : _statistics.totalChatTime,
      lastActivity: DateTime.now(),
    );
  }

  /// 获取统计信息
  ChatStatistics get statistics => _statistics;

  /// 获取性能指标
  ChatPerformanceMetrics get performanceMetrics => _performanceMetrics;



  /// 清理资源 - 优化版本，完整的资源清理
  Future<void> dispose() async {
    _logger.info('开始清理ChatOrchestratorService资源');

    // 取消性能监控
    _performanceTimer?.cancel();

    // 取消所有流式传输
    await cancelAllStreaming();

    // 清理队列
    _messageQueue.clear();

    // 清理缓存
    _contentCache.clear();

    // 重置统计信息
    _statistics = const ChatStatistics();
    _performanceMetrics = const ChatPerformanceMetrics();

    _logger.info('ChatOrchestratorService 资源清理完成', {
      'activeStreams': _activeStreams.length,
      'queueSize': _messageQueue.length,
      'cacheSize': _contentCache.length,
    });
  }
}
