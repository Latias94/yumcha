import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../entities/chat_state.dart';
import '../entities/message.dart';
import '../../../../shared/infrastructure/services/ai/chat/chat_service.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../../shared/infrastructure/services/ai/providers/ai_service_provider.dart';
import '../../../../shared/infrastructure/services/message_id_service.dart';

/// 流式内容累积器
class _StreamAccumulator {
  String content = '';
  String thinking = '';

  void addContent(String delta) {
    content += delta;
  }

  void addThinking(String delta) {
    thinking += delta;
  }

  String buildFullContent() {
    if (thinking.isEmpty) return content;
    return '<think>\n$thinking\n</think>\n\n$content';
  }
}

/// 聊天编排服务 - 核心业务逻辑处理
///
/// 负责协调所有聊天相关的业务逻辑：
/// - 消息发送和接收
/// - 流式消息处理
/// - 对话管理
/// - 配置管理
/// - 错误处理和恢复
class ChatOrchestratorService {
  ChatOrchestratorService(this._ref);

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 活跃的流式订阅管理
  final Map<String, StreamSubscription> _activeStreams = {};

  /// 消息队列（用于处理并发请求）
  final Queue<SendMessageParams> _messageQueue = Queue();

  /// 是否正在处理队列
  bool _isProcessingQueue = false;

  /// 性能指标
  ChatPerformanceMetrics _performanceMetrics = const ChatPerformanceMetrics();

  /// 统计信息
  ChatStatistics _statistics = const ChatStatistics();

  /// 流式更新回调
  void Function(StreamingUpdate)? _onStreamingUpdate;

  /// 用户消息创建回调
  void Function(Message)? _onUserMessageCreated;

  /// 已保存的消息ID集合，防止重复保存
  final Set<String> _persistedMessageIds = <String>{};

  /// 获取聊天服务
  ChatService get _chatService => _ref.read(aiChatServiceProvider);

  /// 获取对话存储库
  ConversationRepository get _conversationRepository =>
      _ref.read(conversationRepositoryProvider);

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

      // 创建用户消息
      final userMessage = _createUserMessage(params.content);

      // 保存用户消息到数据库
      await _persistMessage(userMessage, params.conversationId);

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
      _messageQueue.add(params);
      _processMessageQueue();

      return const ChatOperationLoading();
    }

    // 创建AI消息占位符（但不立即持久化）
    final aiMessage = _createAiMessage(params.assistant.name);

    // 立即通知UI创建流式消息占位符 - 确保有内容以便UI显示
    _logger.info('创建流式消息占位符', {
      'messageId': aiMessage.id,
      'assistantName': params.assistant.name,
    });
    _notifyStreamingUpdate(StreamingUpdate(
      messageId: aiMessage.id!,
      fullContent: '', // 空内容，但会创建消息框
      isDone: false,
    ));

    try {
      // 获取聊天历史
      final chatHistory = await _getChatHistory(params.conversationId);

      // 开始流式传输
      final stream = _chatService.sendMessageStream(
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.model.name,
        chatHistory: chatHistory,
        userMessage: userMessage.content,
      );

      // 处理流式更新 - 使用可变的累积器
      final completer = Completer<ChatOperationResult<Message>>();
      final accumulator = _StreamAccumulator();

      final subscription = stream.listen(
        (event) async {
          await _handleStreamingEvent(
            event,
            aiMessage,
            params.conversationId,
            accumulator,
            completer,
          );
        },
        onError: (error) {
          _handleStreamingError(
              error, aiMessage, params.conversationId, completer);
        },
        onDone: () async {
          // 只有在completer未完成时才处理完成逻辑
          if (!completer.isCompleted) {
            _logger.debug('流式传输onDone回调触发', {
              'messageId': aiMessage.id,
              'completerCompleted': completer.isCompleted,
            });
            await _completeStreamingMessage(
              aiMessage,
              params.conversationId,
              accumulator,
              completer,
            );
          } else {
            _logger.debug('流式传输onDone回调跳过（completer已完成）', {
              'messageId': aiMessage.id,
            });
          }
        },
      );

      // 保存订阅以便管理
      _activeStreams[aiMessage.id!] = subscription;

      // 设置超时
      Timer(ChatConstants.streamingTimeout, () {
        if (!completer.isCompleted) {
          subscription.cancel();
          _activeStreams.remove(aiMessage.id);
          completer.complete(
            const ChatOperationFailure('流式传输超时'),
          );
        }
      });

      return await completer.future;
    } catch (error) {
      _activeStreams.remove(aiMessage.id);
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
      final response = await _chatService.sendMessage(
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.model.name,
        chatHistory: chatHistory,
        userMessage: userMessage.content,
      );

      final duration = DateTime.now().difference(startTime);

      if (response.isSuccess) {
        // 创建AI消息
        final aiMessage = Message(
          id: MessageIdService().generateAiMessageId(),
          content: response.content,
          timestamp: DateTime.now(),
          isFromUser: false,
          author: params.assistant.name,
          duration: duration,
          status: MessageStatus.normal,
        );

        await _persistMessage(aiMessage, params.conversationId);
        _updateStatistics(duration: duration);

        _logger.info('普通消息处理成功', {
          'conversationId': params.conversationId,
          'responseLength': response.content.length,
          'duration': duration.inMilliseconds,
        });

        return ChatOperationSuccess(aiMessage);
      } else {
        _updateStatistics(failed: true);
        return ChatOperationFailure(
          response.error ?? '请求失败',
        );
      }
    } catch (error) {
      _updateStatistics(failed: true);
      rethrow;
    }
  }

  /// 处理流式事件
  Future<void> _handleStreamingEvent(
    dynamic event,
    Message aiMessage,
    String conversationId,
    _StreamAccumulator accumulator,
    Completer<ChatOperationResult<Message>> completer,
  ) async {
    try {
      if (event.error != null) {
        _handleStreamingError(
            event.error, aiMessage, conversationId, completer);
        return;
      }

      // 更新累积内容
      if (event.contentDelta != null) {
        accumulator.addContent(event.contentDelta!);
      }

      if (event.thinkingDelta != null) {
        accumulator.addThinking(event.thinkingDelta!);
      }

      // 处理工具调用事件 - 记录工具调用但不添加到内容中
      // 工具调用的处理由ChatService负责，这里只需要记录日志
      if (event.toolCall != null) {
        final toolCall = event.toolCall!;
        _logger.debug('检测到工具调用事件', {
          'messageId': aiMessage.id,
          'toolName': toolCall.function.name,
          'toolCallId': toolCall.id,
          'arguments': toolCall.function.arguments,
        });
      }

      // 构建完整内容
      final fullContent = accumulator.buildFullContent();

      // 通知UI更新流式消息
      // _logger.debug('流式内容更新', {
      //   'messageId': aiMessage.id,
      //   'contentDelta': event.contentDelta?.length ?? 0,
      //   'fullContentLength': fullContent.length,
      // });
      _notifyStreamingUpdate(StreamingUpdate(
        messageId: aiMessage.id!,
        contentDelta: event.contentDelta,
        thinkingDelta: event.thinkingDelta,
        fullContent: fullContent,
      ));

      if (event.isDone) {
        // 标记流式传输完成，但不在这里持久化
        // 持久化将在 onDone 回调中统一处理
        _logger.debug('流式事件标记完成', {
          'messageId': aiMessage.id,
          'contentLength': fullContent.length,
        });
      }
    } catch (error) {
      _handleStreamingError(error, aiMessage, conversationId, completer);
    }
  }

  /// 完成流式消息
  Future<void> _completeStreamingMessage(
    Message aiMessage,
    String conversationId,
    _StreamAccumulator accumulator,
    Completer<ChatOperationResult<Message>> completer,
  ) async {
    // 防止重复完成同一个消息
    if (completer.isCompleted) {
      _logger.warning('消息已完成，跳过重复处理', {
        'messageId': aiMessage.id,
        'conversationId': conversationId,
      });
      return;
    }

    try {
      final fullContent = accumulator.buildFullContent();

      final completedMessage = aiMessage.copyWith(
        content: fullContent,
        status: MessageStatus.normal,
      );

      // 通知UI流式完成
      _notifyStreamingUpdate(StreamingUpdate(
        messageId: aiMessage.id!,
        fullContent: fullContent,
        isDone: true,
      ));

      // 持久化完成的消息 - 遵循业界最佳实践
      // 1. 只保存有实际内容的完整消息
      // 2. 确保消息完整性和数据一致性
      // 3. 避免保存空消息或不完整的流式片段
      // 4. 工具调用已由ChatService处理，最终响应包含工具执行结果
      if (fullContent.trim().isNotEmpty) {
        await _persistMessage(completedMessage, conversationId);
        _logger.info('流式消息已持久化', {
          'messageId': aiMessage.id,
          'contentLength': fullContent.length,
          'conversationId': conversationId,
        });
      } else {
        _logger.warning('流式消息内容为空，跳过持久化', {
          'messageId': aiMessage.id,
          'conversationId': conversationId,
        });
      }

      // 清理订阅
      _activeStreams[aiMessage.id!]?.cancel();
      _activeStreams.remove(aiMessage.id);

      _updateStatistics();

      _logger.info('流式消息完成', {
        'messageId': aiMessage.id,
        'contentLength': fullContent.length,
      });

      // 确保只完成一次
      if (!completer.isCompleted) {
        completer.complete(ChatOperationSuccess(completedMessage));
      }
    } catch (error) {
      // 只有在completer未完成时才处理错误
      if (!completer.isCompleted) {
        _handleStreamingError(error, aiMessage, conversationId, completer);
      } else {
        _logger.error('流式消息完成时发生错误（但completer已完成）', {
          'messageId': aiMessage.id,
          'error': error.toString(),
        });
      }
    }
  }

  /// 处理流式错误
  void _handleStreamingError(
    Object error,
    Message aiMessage,
    String conversationId,
    Completer<ChatOperationResult<Message>> completer,
  ) {
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

    // 清理订阅
    _activeStreams[aiMessage.id!]?.cancel();
    _activeStreams.remove(aiMessage.id);

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

  /// 取消流式传输
  Future<void> cancelStreaming(String messageId) async {
    final subscription = _activeStreams[messageId];
    if (subscription != null) {
      await subscription.cancel();
      _activeStreams.remove(messageId);

      _logger.info('流式传输已取消', {'messageId': messageId});
    }
  }

  /// 取消所有流式传输
  Future<void> cancelAllStreaming() async {
    final futures = _activeStreams.values.map((s) => s.cancel());
    await Future.wait(futures);
    _activeStreams.clear();

    _logger.info('所有流式传输已取消', {
      'cancelledCount': futures.length,
    });
  }

  /// 处理消息队列
  Future<void> _processMessageQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      while (_messageQueue.isNotEmpty &&
          _activeStreams.length < ChatConstants.maxConcurrentStreams) {
        final params = _messageQueue.removeFirst();
        await sendMessage(params);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// 创建用户消息
  Message _createUserMessage(String content) {
    return Message(
      id: MessageIdService().generateUserMessageId(),
      content: content,
      timestamp: DateTime.now(),
      isFromUser: true,
      author: "你",
      status: MessageStatus.normal,
    );
  }

  /// 创建AI消息
  Message _createAiMessage(String assistantName) {
    return Message(
      id: MessageIdService().generateAiMessageId(),
      content: '',
      timestamp: DateTime.now(),
      isFromUser: false,
      author: assistantName,
      status: MessageStatus.streaming,
    );
  }

  /// 获取聊天历史
  Future<List<Message>> _getChatHistory(String conversationId) async {
    try {
      final conversation =
          await _conversationRepository.getConversation(conversationId);
      return conversation?.messages ?? [];
    } catch (error) {
      _logger.warning('获取聊天历史失败', {
        'conversationId': conversationId,
        'error': error.toString(),
      });
      return [];
    }
  }

  /// 持久化消息
  Future<void> _persistMessage(Message message, String conversationId) async {
    // 检查是否已经保存过
    if (message.id != null && _persistedMessageIds.contains(message.id!)) {
      _logger.warning('消息已存在，跳过重复保存', {
        'messageId': message.id,
        'conversationId': conversationId,
      });
      return;
    }

    try {
      _logger.info('开始持久化消息', {
        'messageId': message.id,
        'conversationId': conversationId,
        'isFromUser': message.isFromUser,
        'contentLength': message.content.length,
      });

      await _conversationRepository.addMessage(
        id: message.id,
        conversationId: conversationId,
        content: message.content,
        author: message.author,
        isFromUser: message.isFromUser,
        imageUrl: message.imageUrl,
        avatarUrl: message.avatarUrl,
        duration: message.duration,
        status: message.status,
        errorInfo: message.errorInfo,
      );

      // 记录已保存的消息ID
      if (message.id != null) {
        _persistedMessageIds.add(message.id!);
      }

      _logger.info('消息持久化成功', {
        'messageId': message.id,
        'conversationId': conversationId,
        'totalPersistedMessages': _persistedMessageIds.length,
      });
    } catch (error) {
      // 检查是否是重复ID错误
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('unique constraint failed') &&
          errorString.contains('messages.id')) {
        _logger.warning('消息ID重复，可能已被其他进程保存', {
          'messageId': message.id,
          'conversationId': conversationId,
          'error': error.toString(),
        });

        // 将ID添加到已保存集合中，避免后续重复尝试
        if (message.id != null) {
          _persistedMessageIds.add(message.id!);
        }

        // 对于重复ID错误，不重新抛出，因为消息已经存在
        return;
      }

      _logger.error('消息持久化失败', {
        'messageId': message.id,
        'conversationId': conversationId,
        'error': error.toString(),
      });

      // 对于其他错误，重新抛出
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

  /// 清理资源
  Future<void> dispose() async {
    await cancelAllStreaming();
    _messageQueue.clear();
    _logger.info('ChatOrchestratorService 已清理');
  }
}
