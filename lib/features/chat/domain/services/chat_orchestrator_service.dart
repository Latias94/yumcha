import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../entities/chat_state.dart';
import '../entities/message.dart';

import '../entities/message_block_type.dart';
import 'message_factory.dart';
import 'message_id_manager.dart';
import 'unified_message_creator.dart';
import 'streaming_message_service.dart';

import '../../../../shared/infrastructure/services/ai/block_based_chat_service.dart';
import '../../data/repositories/conversation_repository.dart';
import '../repositories/message_repository.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../../shared/infrastructure/services/ai/providers/block_chat_provider.dart';
import '../../../../shared/infrastructure/services/message_id_service.dart';

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
    _initializeServices();
    _initializePerformanceMonitoring();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();
  final MessageFactory _messageFactory = MessageFactory();

  /// 获取消息ID服务
  MessageIdService get _messageIdService => _ref.read(messageIdServiceProvider);

  /// 消息ID管理器（延迟初始化）
  MessageIdManager? _idManager;

  /// 统一消息创建器（延迟初始化）
  UnifiedMessageCreator? _unifiedMessageCreator;

  /// 流式消息服务（延迟初始化）
  StreamingMessageService? _streamingService;

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

  /// 获取消息ID管理器（延迟初始化）
  MessageIdManager get _messageIdManager {
    _idManager ??= MessageIdManager(_messageIdService);
    return _idManager!;
  }

  /// 获取统一消息创建器（延迟初始化）
  UnifiedMessageCreator get _messageCreator {
    _unifiedMessageCreator ??= UnifiedMessageCreator(
      messageFactory: _messageFactory,
      messageRepository: _messageRepository,
    );
    return _unifiedMessageCreator!;
  }

  /// 获取流式消息服务（延迟初始化）
  StreamingMessageService get _streamingMessageService {
    _streamingService ??= StreamingMessageService(_messageRepository);
    return _streamingService!;
  }

  /// 初始化服务
  void _initializeServices() {
    // 监听流式消息更新
    _streamingMessageService.updateStream.listen(
      (update) => _handleStreamingMessageUpdate(update),
      onError: (error) => _logger.error('流式消息更新错误', {'error': error.toString()}),
    );
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

      // 📝 第一步：创建并保存用户消息
      //
      // 用户消息需要立即保存到数据库，原因：
      // 1. 确保用户输入不丢失，即使AI处理失败也能保留用户消息
      // 2. 为AI处理提供完整的对话历史上下文
      // 3. 支持对话恢复和消息重发功能
      // 4. 符合聊天应用的标准业务流程：用户发送 → 立即显示 → AI处理
      final userMessage = await _messageCreator.createUserMessage(
        content: params.content,
        conversationId: params.conversationId,
        assistantId: params.assistant.id,
        saveToDatabase: true, // 用户消息必须立即保存，确保不丢失
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

  /// 处理流式消息更新
  void _handleStreamingMessageUpdate(StreamingMessageUpdate update) {
    // 转换为UI层的StreamingUpdate格式
    final streamingUpdate = StreamingUpdate(
      messageId: update.messageId,
      contentDelta: update.contentDelta,
      thinkingDelta: update.thinkingDelta,
      fullContent: update.fullContent,
      isDone: update.isDone,
      error: update.error,
      metadata: update.metadata,
    );

    // 通知UI更新
    _onStreamingUpdate?.call(streamingUpdate);
  }

  /// 处理流式响应 - 重构版本，使用新的流式服务
  Future<ChatOperationResult<Message>> _handleStreamingResponse(
    Message userMessage,
    SendMessageParams params,
  ) async {
    // 检查并发流数量限制
    if (_streamingMessageService.activeStreamingCount >= ChatConstants.maxConcurrentStreams) {
      _logger.warning('达到最大并发流数量限制', {
        'activeStreams': _streamingMessageService.activeStreamingCount,
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
      // 🚀 使用MessageIdManager生成AI消息ID并记录状态
      final messageId = _messageIdManager.generateAiMessageId(
        conversationId: params.conversationId,
        assistantId: params.assistant.id,
        modelId: params.model.name,
        metadata: params.metadata,
      );

      // 开始流式消息处理
      _messageIdManager.startStreamingMessage(messageId);

      // 获取聊天历史
      final chatHistory = await _getChatHistory(params.conversationId);

      // 初始化流式消息服务时传入统一ID
      await _streamingMessageService.initializeStreaming(
        messageId: messageId,
        conversationId: params.conversationId,
        assistantId: params.assistant.id,
        modelId: params.model.name,
        metadata: params.metadata,
      );

      // 开始流式传输，传递统一ID
      final stream = _blockChatService.sendBlockMessageStream(
        messageId: messageId,
        conversationId: params.conversationId,
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.model.name,
        chatHistory: chatHistory,
        userMessage: userMessage.content,
      );

      final completer = Completer<ChatOperationResult<Message>>();
      Message? lastMessage;
      StreamSubscription? subscription;

      subscription = stream.listen(
        (message) async {
          lastMessage = message;
          // 使用统一的messageId而不是message.id来保持一致性
          await _handleStreamingMessageFromBlock(message, messageId, completer);
        },
        onError: (error) async {
          await _streamingMessageService.cancelStreaming(messageId);
          _messageIdManager.cancelStreamingMessage(messageId);
          // 创建临时消息用于错误处理
          final tempMessage = _messageFactory.createErrorMessage(
            conversationId: params.conversationId,
            assistantId: params.assistant.id,
            errorMessage: error.toString(),
          );
          _handleStreamingError(error, lastMessage ?? tempMessage, params.conversationId, messageId, completer, params);
        },
        onDone: () async {
          if (!completer.isCompleted && lastMessage != null) {
            // 🚀 修复：正确计算流式传输持续时间
            final streamContext = _activeStreams[messageId];
            final duration = streamContext?.duration ?? Duration.zero;

            await _streamingMessageService.completeStreaming(
              messageId: messageId, // 使用统一的messageId
              metadata: {
                'duration': duration.inMilliseconds,
              },
            );
            _messageIdManager.completeStreamingMessage(messageId);
            completer.complete(ChatOperationSuccess(lastMessage!));
          }
        },
      );

      // 注册到活跃流管理
      _activeStreams[messageId] = _StreamingContext(
        subscription: subscription,
        startTime: DateTime.now(),
        messageId: messageId,
        completer: completer,
      );

      // 设置超时处理
      Timer(ChatConstants.streamingTimeout, () async {
        if (!completer.isCompleted) {
          await subscription?.cancel();
          await _streamingMessageService.cancelStreaming(messageId);
          _messageIdManager.cancelStreamingMessage(messageId);
          _activeStreams.remove(messageId);
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
      // 🚀 使用MessageIdManager生成AI消息ID并记录状态
      final messageId = _messageIdManager.generateAiMessageId(
        conversationId: params.conversationId,
        assistantId: params.assistant.id,
        modelId: params.model.name,
        metadata: params.metadata,
      );

      // 获取聊天历史
      final chatHistory = await _getChatHistory(params.conversationId);

      final startTime = DateTime.now();

      // 发送请求，传递统一ID
      final blockMessage = await _blockChatService.sendBlockMessage(
        messageId: messageId, // 🚀 传递统一的消息ID
        conversationId: params.conversationId,
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.model.name,
        chatHistory: chatHistory,
        userMessage: userMessage.content,
      );

      final duration = DateTime.now().difference(startTime);

      // 📝 第二步：创建并保存AI响应消息
      //
      // AI消息与用户消息分别保存是正常的业务逻辑，原因：
      // 1. 时间差异：用户消息立即保存，AI消息在处理完成后保存
      // 2. 状态不同：用户消息状态固定，AI消息状态需要根据处理结果设置
      // 3. 内容结构：AI消息包含复杂的块结构（文本、思考、工具调用等）
      // 4. 元数据差异：AI消息包含处理时长、模型信息等额外元数据
      // 5. 错误处理：AI消息可能失败，需要保存错误状态和部分内容
      final finalMessage = await _messageCreator.createAiMessageFromBlockService(
        blockMessage: blockMessage,
        conversationId: params.conversationId,
        assistantId: params.assistant.id,
        additionalMetadata: {
          'duration': duration.inMilliseconds,
        },
        saveToDatabase: true, // AI消息在处理完成后保存，包含完整的响应内容
      );

      _updateStatistics(duration: duration);

      _logger.info('普通消息处理成功', {
        'conversationId': params.conversationId,
        'messageId': finalMessage.id,
        'blocksCount': finalMessage.blocks.length,
        'duration': duration.inMilliseconds,
      });

      return ChatOperationSuccess(finalMessage);
    } catch (error) {
      _updateStatistics(failed: true);

      // 🚀 优化：使用统一错误处理
      try {
        await _messageCreator.createUnifiedErrorMessage(
          conversationId: params.conversationId,
          assistantId: params.assistant.id,
          error: error,
          isStreaming: false,
          saveToDatabase: true,
        );
      } catch (errorHandlingError) {
        _logger.error('错误处理失败', {
          'originalError': error.toString(),
          'errorHandlingError': errorHandlingError.toString(),
        });
      }

      rethrow;
    }
  }

  /// 处理来自块化服务的流式消息
  Future<void> _handleStreamingMessageFromBlock(
    Message message,
    String streamingMessageId,
    Completer<ChatOperationResult<Message>> completer,
  ) async {
    try {
      // 从块化消息中提取内容
      final fullContent = _extractContentFromMessage(message);
      final thinkingContent = _extractThinkingFromMessage(message);

      // 更新流式消息服务，使用统一的streamingMessageId
      await _streamingMessageService.updateContent(
        messageId: streamingMessageId,
        fullContent: fullContent,
        fullThinking: thinkingContent,
        metadata: message.metadata,
      );

    } catch (error) {
      _logger.error('处理流式消息失败', {
        'messageId': streamingMessageId,
        'originalMessageId': message.id,
        'error': error.toString(),
      });
      await _streamingMessageService.cancelStreaming(streamingMessageId);
    }
  }

  /// 从消息中提取主要内容
  String _extractContentFromMessage(Message message) {
    final contentParts = <String>[];

    for (final block in message.blocks) {
      if (block.type == MessageBlockType.mainText &&
          block.content != null &&
          block.content!.isNotEmpty) {
        contentParts.add(block.content!);
      }
    }

    return contentParts.join('\n\n');
  }

  /// 从消息中提取思考内容
  String _extractThinkingFromMessage(Message message) {
    final thinkingParts = <String>[];

    for (final block in message.blocks) {
      if (block.type == MessageBlockType.thinking &&
          block.content != null &&
          block.content!.isNotEmpty) {
        thinkingParts.add(block.content!);
      }
    }

    return thinkingParts.join('\n\n');
  }



  /// 处理流式错误
  Future<void> _handleStreamingError(
    Object error,
    Message aiMessage,
    String conversationId,
    String streamingMessageId,
    Completer<ChatOperationResult<Message>> completer,
    SendMessageParams params,
  ) async {
    // 防止重复处理错误
    if (completer.isCompleted) {
      _logger.warning('错误处理时发现completer已完成', {
        'streamingMessageId': streamingMessageId,
        'originalMessageId': aiMessage.id,
        'error': error.toString(),
      });
      return;
    }

    _logger.error('流式传输错误', {
      'streamingMessageId': streamingMessageId,
      'originalMessageId': aiMessage.id,
      'error': error.toString(),
    });

    // 🚀 优化：使用统一错误处理
    try {
      final partialContent = _extractContentFromMessage(aiMessage);
      await _messageCreator.createUnifiedErrorMessage(
        conversationId: conversationId,
        assistantId: params.assistant.id,
        error: error,
        messageId: streamingMessageId,
        partialContent: partialContent.isNotEmpty ? partialContent : null,
        isStreaming: true,
        saveToDatabase: true,
      );
    } catch (handlingError) {
      _logger.error('统一错误处理失败', {
        'streamingMessageId': streamingMessageId,
        'originalError': error.toString(),
        'handlingError': handlingError.toString(),
      });
    }

    // 🚀 修复：清理订阅 - 使用统一的streamingMessageId作为key
    final streamContext = _activeStreams[streamingMessageId];
    if (streamContext != null) {
      await streamContext.cancel();
      _activeStreams.remove(streamingMessageId);
    }

    _updateStatistics(failed: true);

    // 确保只完成一次
    if (!completer.isCompleted) {
      final errorMessage = _getUserFriendlyErrorMessage(error);
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







  /// 清理资源 - 重构版本，使用新的服务架构
  Future<void> dispose() async {
    _logger.info('开始清理ChatOrchestratorService资源');

    // 取消性能监控
    _performanceTimer?.cancel();

    // 清理流式消息服务
    if (_streamingService != null) {
      await _streamingService!.dispose();
    }

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
      'streamingServiceDisposed': _streamingService != null,
    });
  }
}
