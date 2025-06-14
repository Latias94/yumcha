import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../domain/entities/chat_state.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/legacy_message.dart';
import '../../domain/entities/message_metadata.dart';
import '../../domain/services/chat_orchestrator_service.dart';
import '../../domain/entities/conversation_ui_state.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../../ai_management/domain/entities/ai_model.dart';
import '../../../ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';

import '../../../../shared/infrastructure/services/preference_service.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/providers/conversation_title_notifier.dart';

/// 统一聊天状态管理器
/// 
/// 这是聊天功能的核心状态管理器，采用最佳实践：
/// - 🎯 单一数据源：所有聊天状态统一管理
/// - 🔄 事件驱动：使用事件系统处理状态变化
/// - 🛡️ 类型安全：使用Freezed确保类型安全
/// - ⚡ 性能优化：智能的状态更新和内存管理
/// - 🧪 可测试：依赖注入和清晰的业务逻辑分离
class UnifiedChatNotifier extends StateNotifier<UnifiedChatState> {
  UnifiedChatNotifier(this._ref) : super(const UnifiedChatState()) {
    // 异步初始化，避免在构造函数中直接实例化依赖
    _initialize();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();
  final NotificationService _notificationService = NotificationService();

  /// 获取聊天编排服务实例 - 使用getter避免late final重复初始化问题
  ChatOrchestratorService get _orchestrator {
    // 通过Provider获取服务实例，确保依赖注入
    return ChatOrchestratorService(_ref);
  }
  
  /// 事件流控制器
  final StreamController<ChatEvent> _eventController = StreamController.broadcast();
  
  /// 初始化锁
  bool _isInitializing = false;
  
  /// 配置保存定时器
  Timer? _configSaveTimer;
  
  /// 性能监控定时器
  Timer? _performanceTimer;

  /// 事件流
  Stream<ChatEvent> get eventStream => _eventController.stream;

  /// 获取服务实例
  PreferenceService get _preferenceService => _ref.read(preferenceServiceProvider);

  @override
  void dispose() {
    _eventController.close();
    _configSaveTimer?.cancel();
    _performanceTimer?.cancel();
    // 编排服务通过getter获取，不需要手动dispose
    super.dispose();
  }

  /// 初始化
  Future<void> _initialize() async {
    if (_isInitializing || state.isInitialized) return;
    
    _isInitializing = true;
    _logger.info('开始初始化统一聊天状态管理器');

    try {
      state = state.copyWith(isInitializing: true);

      // 编排服务已在构造函数中初始化，这里只需要设置其他监听器
      _setupListeners();

      // 2. 等待基础数据加载
      await _waitForBasicData();

      // 3. 加载配置
      await _loadConfiguration();

      // 4. 初始化对话
      await _initializeConversation();

      // 5. 启动性能监控
      _startPerformanceMonitoring();

      state = state.copyWith(
        isInitialized: true,
        isInitializing: false,
      );

      _emitEvent(const ConfigurationChangedEvent(null, null, null));
      _logger.info('统一聊天状态管理器初始化完成');

    } catch (error, stackTrace) {
      _logger.error('初始化失败', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });

      state = state.copyWith(
        isInitializing: false,
      );

      // 使用 NotificationService 显示初始化错误
      _notificationService.showError(
        '初始化失败: $error',
        importance: NotificationImportance.critical,
      );

      _emitEvent(ErrorOccurredEvent(error.toString(), 'initialization'));
    }
  }

  /// 设置监听器
  void _setupListeners() {
    // 监听助手变化 - 使用新的统一AI管理Provider
    _ref.listen(aiAssistantsProvider, (previous, next) {
      _handleAssistantsChanged(previous, next);
    });

    // 监听提供商变化 - 使用新的统一AI管理Provider
    _ref.listen(aiProvidersProvider, (previous, next) {
      _handleProvidersChanged(previous, next);
    });

    _logger.debug('统一AI管理监听器设置完成');
  }

  /// 等待基础数据加载
  Future<void> _waitForBasicData() async {
    const maxWaitTime = ChatConstants.initializationTimeout;
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      try {
        // 使用新的统一AI管理Provider
        final assistants = _ref.read(aiAssistantsProvider);
        final providers = _ref.read(aiProvidersProvider);

        final assistantsReady = assistants.where((a) => a.isEnabled).isNotEmpty;
        final providersReady = providers.where((p) => p.isEnabled).isNotEmpty;

        if (assistantsReady && providersReady) {
          _logger.info('基础数据加载完成', {
            'enabledAssistants': assistants.where((a) => a.isEnabled).length,
            'enabledProviders': providers.where((p) => p.isEnabled).length,
          });
          return;
        }

        _logger.debug('等待基础数据加载...', {
          'assistantsReady': assistantsReady,
          'providersReady': providersReady,
        });

      } catch (error) {
        _logger.warning('基础数据检查失败，继续等待', {'error': error.toString()});
      }

      await Future.delayed(checkInterval);
    }

    throw TimeoutException('基础数据加载超时', maxWaitTime);
  }

  /// 加载配置
  Future<void> _loadConfiguration() async {
    try {
      state = state.copyWith(
        configuration: state.configuration.copyWith(isLoading: true),
      );

      // 获取助手
      final assistant = await _getDefaultAssistant();
      
      // 获取提供商和模型
      final (provider, model) = await _getDefaultProviderAndModel();

      final newConfiguration = ChatConfiguration(
        selectedAssistant: assistant,
        selectedProvider: provider,
        selectedModel: model,
        isLoading: false,
      );

      state = state.copyWith(configuration: newConfiguration);

      _logger.info('配置加载完成', {
        'assistant': assistant?.name,
        'provider': provider?.name,
        'model': model?.name,
        'isComplete': newConfiguration.isComplete,
      });

    } catch (error) {
      state = state.copyWith(
        configuration: state.configuration.copyWith(
          isLoading: false,
          error: '配置加载失败: $error',
        ),
      );
      rethrow;
    }
  }

  /// 初始化对话状态（不创建实际对话）
  Future<void> _initializeConversation() async {
    if (!state.configuration.isComplete) {
      _logger.warning('配置不完整，跳过对话初始化');
      return;
    }

    try {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(isLoading: false),
      );

      // 不再自动创建对话，只是准备好配置
      // 对话将在用户发送第一条消息时创建
      _logger.info('对话状态初始化完成，等待用户创建对话');

    } catch (error) {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(
          isLoading: false,
          error: '对话初始化失败: $error',
        ),
      );
      rethrow;
    }
  }

  /// 发送消息
  Future<void> sendMessage(String content, {bool useStreaming = true}) async {
    if (!state.isReady) {
      _notificationService.showError(
        '聊天未准备就绪，无法发送消息',
        importance: NotificationImportance.medium,
      );
      return;
    }

    if (content.trim().isEmpty) {
      _notificationService.showError(
        '消息内容不能为空',
        importance: NotificationImportance.medium,
      );
      return;
    }

    // 清除之前的错误
    _clearError();

    await _sendMessageInternal(content, useStreaming: useStreaming);
  }

  /// 重新生成AI响应
  Future<void> regenerateResponse({
    required String aiMessageId,
    bool useStreaming = true,
  }) async {
    if (!state.isReady) {
      _notificationService.showError(
        '聊天未准备就绪，无法重新生成',
        importance: NotificationImportance.medium,
      );
      return;
    }

    // 清除之前的错误
    _clearError();

    await _regenerateResponseInternal(aiMessageId, useStreaming: useStreaming);
  }

  /// 内部发送消息实现
  Future<void> _sendMessageInternal(String content, {bool useStreaming = true}) async {

    try {
      // 如果没有当前对话，先创建一个
      if (state.conversationState.currentConversation == null) {
        _logger.info('没有当前对话，自动创建新对话');
        await createNewConversation();

        // 检查对话是否创建成功
        if (state.conversationState.currentConversation == null) {
          _notificationService.showError(
            '无法创建对话，请重试',
            importance: NotificationImportance.high,
          );
          return;
        }
      }

      final params = SendMessageParams(
        content: content,
        conversationId: state.conversationState.currentConversation!.id,
        assistant: state.configuration.selectedAssistant!,
        provider: state.configuration.selectedProvider!,
        model: state.configuration.selectedModel!,
        useStreaming: useStreaming,
      );

      // 用户消息由ChatOrchestratorService统一创建和保存
      // 这里不再重复创建用户消息

      // 发送消息
      final result = await _orchestrator.sendMessage(params);

      result.when(
        success: (aiMessage) {
          // 对于流式消息，AI消息已经通过_handleStreamingUpdate添加了
          // 这里只处理非流式消息的情况
          if (!useStreaming) {
            _addMessage(aiMessage);
            _emitEvent(MessageAddedEvent(aiMessage));
            // 非流式AI消息完成后，检查是否需要生成标题
            _checkAndTriggerTitleGeneration();
          } else {
            // 流式消息已经完成，只需要发出事件
            _emitEvent(MessageAddedEvent(aiMessage));
          }
        },
        failure: (error, code, originalError) {
          // 使用 NotificationService 显示错误通知，不设置 globalError
          _notificationService.showError(
            '发送消息失败: $error',
            importance: NotificationImportance.high,
          );
          _emitEvent(ErrorOccurredEvent(error, 'sendMessage'));
        },
        loading: () {
          // 流式消息正在处理中
          _logger.info('消息正在流式处理中');
        },
      );

    } catch (error) {
      // 使用 NotificationService 显示错误通知，不设置 globalError
      _notificationService.showError(
        '发送消息失败: $error',
        importance: NotificationImportance.high,
      );
      _emitEvent(ErrorOccurredEvent(error.toString(), 'sendMessage'));
    }
  }

  /// 内部重新生成响应实现
  Future<void> _regenerateResponseInternal(String aiMessageId, {bool useStreaming = true}) async {
    try {
      // 如果没有当前对话，先创建一个
      if (state.conversationState.currentConversation == null) {
        _logger.info('没有当前对话，自动创建新对话');
        await createNewConversation();

        if (state.conversationState.currentConversation == null) {
          _notificationService.showError(
            '无法创建对话，请重试',
            importance: NotificationImportance.high,
          );
          return;
        }
      }

      // 找到要重新生成的AI消息
      final aiMessageIndex = state.messageState.messages.indexWhere((m) => m.id == aiMessageId);
      if (aiMessageIndex == -1) {
        throw Exception('找不到要重新生成的AI消息');
      }

      // 获取AI消息之前的所有消息作为上下文
      final contextMessages = state.messageState.messages.take(aiMessageIndex).toList();

      if (contextMessages.isEmpty) {
        throw Exception('没有足够的上下文进行重新生成');
      }

      // 使用最后一条用户消息作为重新生成的内容
      final lastUserMessage = contextMessages.lastWhere(
        (msg) => msg.isFromUser,
        orElse: () => throw Exception('没有找到用户消息'),
      );

      final params = SendMessageParams(
        content: lastUserMessage.content,
        conversationId: state.conversationState.currentConversation!.id,
        assistant: state.configuration.selectedAssistant!,
        provider: state.configuration.selectedProvider!,
        model: state.configuration.selectedModel!,
        useStreaming: useStreaming,
      );

      _logger.info('准备重新生成响应', {
        'aiMessageId': aiMessageId,
        'contextMessageCount': contextMessages.length,
        'useStreaming': useStreaming,
        'assistant': params.assistant.name,
        'provider': params.provider.name,
        'model': params.model.name,
      });

      // 先清空原AI消息的内容，设置为重新生成状态
      _updateMessageContent(aiMessageId, '', MessageStatus.aiProcessing);

      // 发送重新生成请求
      final result = await _orchestrator.sendMessage(params);

      result.when(
        success: (newAiMessage) {
          // 获取原消息
          final originalMessage = state.messageState.messages.firstWhere((m) => m.id == aiMessageId);

          // 用新的AI消息内容替换原消息
          _updateMessageContent(aiMessageId, newAiMessage.content, MessageStatus.aiSuccess, newAiMessage.metadata);

          // 获取更新后的消息
          final updatedMessage = state.messageState.messages.firstWhere((m) => m.id == aiMessageId);

          _emitEvent(MessageUpdatedEvent(originalMessage, updatedMessage));
        },
        failure: (error, code, originalError) {
          // 获取原消息
          final originalMessage = state.messageState.messages.firstWhere((m) => m.id == aiMessageId);

          // 恢复原消息状态，显示错误
          _updateMessageContent(aiMessageId, '重新生成失败: $error', MessageStatus.aiError);

          // 获取更新后的消息
          final updatedMessage = state.messageState.messages.firstWhere((m) => m.id == aiMessageId);

          _notificationService.showError(
            '重新生成失败: $error',
            importance: NotificationImportance.high,
          );
          _emitEvent(MessageUpdatedEvent(originalMessage, updatedMessage));
          _emitEvent(ErrorOccurredEvent(error, 'regenerateResponse'));
        },
        loading: () {
          _logger.info('重新生成正在处理中');
        },
      );

    } catch (error) {
      _notificationService.showError(
        '重新生成失败: $error',
        importance: NotificationImportance.high,
      );
      _emitEvent(ErrorOccurredEvent(error.toString(), 'regenerateResponse'));
    }
  }

  /// 选择助手
  Future<void> selectAssistant(AiAssistant assistant) async {
    final newConfiguration = state.configuration.copyWith(
      selectedAssistant: assistant,
    );

    state = state.copyWith(configuration: newConfiguration);
    
    _emitEvent(ConfigurationChangedEvent(
      assistant,
      newConfiguration.selectedProvider,
      newConfiguration.selectedModel,
    ));

    _scheduleConfigurationSave();
    _logger.info('助手已选择', {'assistantName': assistant.name});
  }

  /// 选择模型
  Future<void> selectModel(AiProvider provider, AiModel model) async {
    final newConfiguration = state.configuration.copyWith(
      selectedProvider: provider,
      selectedModel: model,
    );

    state = state.copyWith(configuration: newConfiguration);
    
    _emitEvent(ConfigurationChangedEvent(
      newConfiguration.selectedAssistant,
      provider,
      model,
    ));

    _scheduleConfigurationSave();
    _logger.info('模型已选择', {
      'providerName': provider.name,
      'modelName': model.name,
    });
  }

  /// 创建新对话
  Future<void> createNewConversation() async {
    if (!state.configuration.isComplete) {
      _notificationService.showError(
        '配置不完整，无法创建对话',
        importance: NotificationImportance.high,
      );
      return;
    }

    try {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(isLoading: true),
      );

      // 创建并保存对话到数据库
      final repository = _ref.read(conversationRepositoryProvider);
      final conversationId = await repository.createConversation(
        title: "新对话",
        assistantId: state.configuration.selectedAssistant!.id,
        providerId: state.configuration.selectedProvider!.id,
        modelId: state.configuration.selectedModel!.name,
      );

      final newConversation = ConversationUiState(
        id: conversationId,
        channelName: "新对话",
        channelMembers: 1,
        assistantId: state.configuration.selectedAssistant!.id,
        selectedProviderId: state.configuration.selectedProvider!.id,
        selectedModelId: state.configuration.selectedModel!.name,
        messages: [],
      );

      state = state.copyWith(
        conversationState: state.conversationState.copyWith(
          currentConversation: newConversation,
          isLoading: false,
        ),
        messageState: const MessageState(),
      );

      _emitEvent(ConversationChangedEvent(newConversation));
      _logger.info('新对话创建完成', {'conversationId': conversationId});

    } catch (error) {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(isLoading: false),
      );
      _notificationService.showError(
        '创建对话失败: $error',
        importance: NotificationImportance.high,
      );
    }
  }

  /// 加载对话
  Future<void> loadConversation(String conversationId) async {
    try {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(isLoading: true),
      );

      final repository = _ref.read(conversationRepositoryProvider);
      final conversation = await repository.getConversation(conversationId);

      if (conversation != null) {
        state = state.copyWith(
          conversationState: state.conversationState.copyWith(
            currentConversation: conversation,
            isLoading: false,
          ),
          messageState: MessageState(messages: _convertLegacyMessagesToMessages(conversation.messages)),
        );

        _emitEvent(ConversationChangedEvent(conversation));
        _logger.info('对话加载完成', {'conversationId': conversationId});
      } else {
        throw Exception('对话不存在');
      }

    } catch (error) {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(
          isLoading: false,
          error: '加载对话失败: $error',
        ),
      );
      _notificationService.showError(
        '加载对话失败: $error',
        importance: NotificationImportance.high,
      );
    }
  }

  /// 取消流式传输
  Future<void> cancelStreaming([String? messageId]) async {
    if (messageId != null) {
      await _orchestrator.cancelStreaming(messageId);

      // 更新状态
      final updatedStreamingIds = Set<String>.from(state.messageState.streamingMessageIds);
      updatedStreamingIds.remove(messageId);

      state = state.copyWith(
        messageState: state.messageState.copyWith(
          streamingMessageIds: updatedStreamingIds,
        ),
      );

      _emitEvent(StreamingCompletedEvent(messageId));
    } else {
      await _orchestrator.cancelAllStreaming();

      state = state.copyWith(
        messageState: state.messageState.copyWith(
          streamingMessageIds: const {},
        ),
      );
    }
  }

  /// 清除错误
  void clearError() {
    _clearError();
    _emitEvent(const ErrorClearedEvent());
  }

  /// 获取统计信息
  ChatStatistics get statistics => _orchestrator.statistics;

  /// 获取性能指标
  ChatPerformanceMetrics get performanceMetrics => _orchestrator.performanceMetrics;

  /// 获取编排服务实例（用于Provider）
  ChatOrchestratorService get orchestrator => _orchestrator;

  // === 私有方法 ===

  /// 将LegacyMessage列表转换为Message列表
  List<Message> _convertLegacyMessagesToMessages(List<LegacyMessage> legacyMessages) {
    return legacyMessages.map((legacyMessage) => _convertLegacyMessageToMessage(legacyMessage)).toList();
  }

  /// 将LegacyMessage转换为新的Message
  Message _convertLegacyMessageToMessage(LegacyMessage legacyMessage) {
    // 转换状态
    MessageStatus messageStatus;
    switch (legacyMessage.status) {
      case LegacyMessageStatus.normal:
        messageStatus = legacyMessage.isFromUser ? MessageStatus.userSuccess : MessageStatus.aiSuccess;
        break;
      case LegacyMessageStatus.sending:
        messageStatus = MessageStatus.aiPending;
        break;
      case LegacyMessageStatus.streaming:
        messageStatus = MessageStatus.aiProcessing;
        break;
      case LegacyMessageStatus.error:
      case LegacyMessageStatus.failed:
        messageStatus = MessageStatus.aiError;
        break;
      case LegacyMessageStatus.system:
        messageStatus = MessageStatus.system;
        break;
      case LegacyMessageStatus.temporary:
        messageStatus = MessageStatus.temporary;
        break;
      case LegacyMessageStatus.regenerating:
        messageStatus = MessageStatus.aiProcessing;
        break;
    }

    // 创建主文本块
    final textBlock = MessageBlock.text(
      id: '${legacyMessage.id}_text_block',
      messageId: legacyMessage.id ?? '',
      content: legacyMessage.content,
    );

    return Message(
      id: legacyMessage.id ?? '',
      conversationId: state.conversationState.currentConversation?.id ?? '',
      role: legacyMessage.isFromUser ? 'user' : 'assistant',
      assistantId: state.configuration.selectedAssistant?.id ?? '',
      blockIds: [textBlock.id],
      status: messageStatus,
      createdAt: legacyMessage.timestamp,
      updatedAt: legacyMessage.timestamp,
      modelId: legacyMessage.metadata?.modelName,
      metadata: legacyMessage.metadata?.toJson(),
      blocks: [textBlock],
    );
  }

  /// 添加消息
  void _addMessage(Message message) {
    var updatedMessages = [...state.messageState.messages, message];

    // 内存优化：限制消息数量
    if (updatedMessages.length > ChatConstants.maxMessagesInMemory) {
      updatedMessages = updatedMessages.sublist(
        updatedMessages.length - ChatConstants.messagesToKeepWhenTrimming,
      );

      _logger.info('消息列表已修剪', {
        'originalCount': state.messageState.messages.length + 1,
        'newCount': updatedMessages.length,
      });
    }

    state = state.copyWith(
      messageState: state.messageState.copyWith(messages: updatedMessages),
    );
  }

  /// 更新消息内容
  void _updateMessageContent(String messageId, String content, MessageStatus status, [Map<String, dynamic>? metadata]) {
    final updatedMessages = state.messageState.messages.map((message) {
      if (message.id == messageId) {
        // 对于块化消息，我们需要更新主文本块的内容
        // 这是一个临时解决方案，完整的实现需要通过MessageRepository来更新块
        return message.copyWith(
          status: status,
          metadata: metadata,
          // 注意：这里不能直接设置content，因为新的Message类没有content参数
          // 实际的内容更新需要通过更新MessageBlock来实现
        );
      }
      return message;
    }).toList();

    state = state.copyWith(
      messageState: state.messageState.copyWith(messages: updatedMessages),
    );
  }

  // 注意：原有的 _handleUserMessageCreated 和 _handleStreamingUpdate 方法已删除
  // 因为新的架构中，这些回调不再需要，流式更新通过其他方式处理

  /// 清除错误
  void _clearError() {
    // 清除全局错误状态（如果有的话）
    if (state.globalError != null) {
      state = state.copyWith(globalError: null);
    }

    // 清除其他错误状态
    if (state.configuration.error != null) {
      state = state.copyWith(
        configuration: state.configuration.copyWith(error: null),
      );
    }

    if (state.messageState.error != null) {
      state = state.copyWith(
        messageState: state.messageState.copyWith(error: null),
      );
    }

    if (state.conversationState.error != null) {
      state = state.copyWith(
        conversationState: state.conversationState.copyWith(error: null),
      );
    }
  }

  /// 发出事件
  void _emitEvent(ChatEvent event) {
    state = state.copyWith(lastEvent: event);
    _eventController.add(event);
  }

  /// 检查并触发标题生成
  void _checkAndTriggerTitleGeneration() {
    try {
      // 检查是否有当前对话
      final currentConversation = state.conversationState.currentConversation;
      if (currentConversation == null) {
        _logger.debug('没有当前对话，跳过标题生成检查');
        return;
      }

      // 获取当前消息列表
      final messages = state.messageState.messages;
      if (messages.isEmpty) {
        _logger.debug('没有消息，跳过标题生成检查');
        return;
      }

      // 检查最后一条消息是否是AI消息
      final lastMessage = messages.last;
      if (lastMessage.isFromUser) {
        _logger.debug('最后一条消息不是AI消息，跳过标题生成检查');
        return;
      }

      _logger.info('AI消息完成，触发标题生成检查', {
        'conversationId': currentConversation.id,
        'messageCount': messages.length,
        'lastMessageId': lastMessage.id,
      });

      // 调用标题生成器
      final titleNotifier = _ref.read(conversationTitleNotifierProvider.notifier);
      titleNotifier.onAiMessageAdded(currentConversation.id, messages);

    } catch (error) {
      _logger.error('标题生成检查失败', {
        'error': error.toString(),
      });
    }
  }





  /// 获取默认助手
  Future<AiAssistant?> _getDefaultAssistant() async {
    try {
      // 使用新的统一AI管理Provider
      final assistants = _ref.read(aiAssistantsProvider);
      final enabledAssistants = assistants.where((a) => a.isEnabled).toList();
      return enabledAssistants.isNotEmpty ? enabledAssistants.first : null;
    } catch (error) {
      _logger.error('获取默认助手失败', {'error': error.toString()});
      return null;
    }
  }

  /// 获取默认提供商和模型
  Future<(AiProvider?, AiModel?)> _getDefaultProviderAndModel() async {
    try {
      // 使用新的统一AI管理Provider
      final providers = _ref.read(aiProvidersProvider);
      final enabledProviders = providers.where((p) => p.isEnabled).toList();
      if (enabledProviders.isNotEmpty) {
        final provider = enabledProviders.first;
        if (provider.models.isNotEmpty) {
          return (provider, provider.models.first);
        }
      }
      return (null, null);
    } catch (error) {
      _logger.error('获取默认提供商和模型失败', {'error': error.toString()});
      return (null, null);
    }
  }

  /// 处理助手变化
  void _handleAssistantsChanged(
    List<AiAssistant>? previous,
    List<AiAssistant> next,
  ) {
    // 验证当前选择的助手是否仍然有效
    final currentAssistant = state.configuration.selectedAssistant;
    if (currentAssistant != null) {
      final updatedAssistant = next
          .where((a) => a.id == currentAssistant.id && a.isEnabled)
          .firstOrNull;

      if (updatedAssistant == null) {
        // 助手不再可用，选择新的助手
        final enabledAssistants = next.where((a) => a.isEnabled).toList();
        final newAssistant = enabledAssistants.isNotEmpty ? enabledAssistants.first : null;

        state = state.copyWith(
          configuration: state.configuration.copyWith(selectedAssistant: newAssistant),
        );

        _logger.info('助手已自动切换', {
          'oldAssistant': currentAssistant.name,
          'newAssistant': newAssistant?.name,
        });
      }
    }
  }

  /// 处理提供商变化
  void _handleProvidersChanged(
    List<AiProvider>? previous,
    List<AiProvider> next,
  ) {
    // 验证当前选择的提供商和模型是否仍然有效
    final currentProvider = state.configuration.selectedProvider;
    final currentModel = state.configuration.selectedModel;

    if (currentProvider != null && currentModel != null) {
      final updatedProvider = next
          .where((p) => p.id == currentProvider.id && p.isEnabled)
          .firstOrNull;

      if (updatedProvider == null) {
        // 提供商不再可用，选择新的提供商和模型
        final enabledProviders = next.where((p) => p.isEnabled).toList();
        if (enabledProviders.isNotEmpty) {
          final newProvider = enabledProviders.first;
          final newModel = newProvider.models.isNotEmpty ? newProvider.models.first : null;

          state = state.copyWith(
            configuration: state.configuration.copyWith(
              selectedProvider: newProvider,
              selectedModel: newModel,
            ),
          );

          _logger.info('提供商和模型已自动切换', {
            'oldProvider': currentProvider.name,
            'newProvider': newProvider.name,
            'newModel': newModel?.name,
          });
        }
      } else {
        // 检查模型是否仍然存在
        final updatedModel = updatedProvider.models
            .where((m) => m.name == currentModel.name)
            .firstOrNull;

        if (updatedModel == null && updatedProvider.models.isNotEmpty) {
          // 模型不再可用，选择该提供商的第一个模型
          state = state.copyWith(
            configuration: state.configuration.copyWith(
              selectedProvider: updatedProvider,
              selectedModel: updatedProvider.models.first,
            ),
          );

          _logger.info('模型已自动切换', {
            'provider': updatedProvider.name,
            'oldModel': currentModel.name,
            'newModel': updatedProvider.models.first.name,
          });
        }
      }
    }
  }

  /// 调度配置保存
  void _scheduleConfigurationSave() {
    _configSaveTimer?.cancel();
    _configSaveTimer = Timer(ChatConstants.configurationSaveDelay, () {
      _saveConfiguration();
    });
  }

  /// 保存配置
  Future<void> _saveConfiguration() async {
    try {
      final config = state.configuration;
      if (config.isComplete) {
        await Future.wait([
          _preferenceService.saveLastUsedAssistantId(config.selectedAssistant!.id),
          _preferenceService.saveLastUsedModel(
            config.selectedProvider!.id,
            config.selectedModel!.name,
          ),
        ]);
        
        _logger.debug('配置已保存');
      }
    } catch (error) {
      _logger.error('保存配置失败', {'error': error.toString()});
    }
  }

  /// 启动性能监控
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(
      ChatConstants.performanceCheckInterval,
      (_) => _checkPerformance(),
    );
  }

  /// 检查性能
  void _checkPerformance() {
    final messageCount = state.messageState.messages.length;
    final streamingCount = state.messageState.streamingMessageIds.length;

    _logger.debug('性能检查', {
      'messageCount': messageCount,
      'streamingCount': streamingCount,
      'isReady': state.isReady,
    });

    // 如果消息过多，触发清理
    if (messageCount > ChatConstants.messageCleanupThreshold) {
      _logger.info('触发消息清理', {'messageCount': messageCount});
      // 这里可以实现更智能的清理策略
    }
  }
}

// === Provider 定义 ===

/// 统一聊天状态Provider
final unifiedChatProvider = StateNotifierProvider<UnifiedChatNotifier, UnifiedChatState>(
  (ref) => UnifiedChatNotifier(ref),
);

/// 聊天编排服务Provider - 从UnifiedChatNotifier获取实例
final chatOrchestratorProvider = Provider<ChatOrchestratorService>((ref) {
  return ref.watch(unifiedChatProvider.notifier).orchestrator;
});

// === 便捷访问Provider ===

/// 当前对话Provider
final currentConversationProvider = Provider<ConversationUiState?>((ref) {
  return ref.watch(unifiedChatProvider).conversationState.currentConversation;
});

/// 聊天消息Provider
final chatMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(unifiedChatProvider).messageState.messages;
});

/// 聊天配置Provider
final chatConfigurationProvider = Provider<ChatConfiguration>((ref) {
  return ref.watch(unifiedChatProvider).configuration;
});

/// 聊天加载状态Provider
final chatLoadingStateProvider = Provider<bool>((ref) {
  return ref.watch(unifiedChatProvider).isLoading;
});

/// 聊天错误Provider
final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(unifiedChatProvider).primaryError;
});

/// 聊天准备状态Provider
final chatReadyStateProvider = Provider<bool>((ref) {
  return ref.watch(unifiedChatProvider).isReady;
});

/// 流式消息Provider
final streamingMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(unifiedChatProvider).messageState.streamingMessages;
});

/// 聊天事件Provider
final chatEventProvider = StreamProvider<ChatEvent>((ref) {
  final notifier = ref.watch(unifiedChatProvider.notifier);
  return notifier.eventStream;
});

/// 聊天统计Provider
final chatStatisticsProvider = Provider<ChatStatistics>((ref) {
  return ref.watch(unifiedChatProvider.notifier).statistics;
});

/// 聊天性能指标Provider
final chatPerformanceProvider = Provider<ChatPerformanceMetrics>((ref) {
  return ref.watch(unifiedChatProvider.notifier).performanceMetrics;
});

// === 特定功能Provider ===

/// 选中助手Provider
final selectedAssistantProvider = Provider<AiAssistant?>((ref) {
  return ref.watch(unifiedChatProvider).configuration.selectedAssistant;
});

/// 选中提供商Provider
final selectedProviderProvider = Provider<AiProvider?>((ref) {
  return ref.watch(unifiedChatProvider).configuration.selectedProvider;
});

/// 选中模型Provider
final selectedModelProvider = Provider<AiModel?>((ref) {
  return ref.watch(unifiedChatProvider).configuration.selectedModel;
});

/// 是否有流式消息Provider
final hasStreamingMessagesProvider = Provider<bool>((ref) {
  return ref.watch(unifiedChatProvider).messageState.hasStreamingMessages;
});

/// 消息数量Provider
final messageCountProvider = Provider<int>((ref) {
  return ref.watch(unifiedChatProvider).messageState.messages.length;
});

/// 对话ID Provider
final currentConversationIdProvider = Provider<String?>((ref) {
  return ref.watch(unifiedChatProvider).conversationState.currentConversationId;
});
