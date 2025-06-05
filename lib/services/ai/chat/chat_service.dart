import 'dart:async';
import '../../../models/ai_provider.dart' as models;
import '../../../models/ai_assistant.dart';
import '../../../models/message.dart';
import '../core/ai_service_base.dart';
import '../core/ai_response_models.dart';
import '../../../ai_dart/ai_dart.dart';

/// 聊天服务，负责处理AI聊天请求
class ChatService extends AiServiceBase {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<String, AiProviderAdapter> _adapters = {};
  final Map<String, AiServiceStats> _stats = {};
  bool _isInitialized = false;

  @override
  String get serviceName => 'ChatService';

  @override
  Set<AiCapability> get supportedCapabilities => {
    AiCapability.chat,
    AiCapability.streaming,
    AiCapability.toolCalling,
    AiCapability.reasoning,
    AiCapability.vision,
  };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化聊天服务');
    _isInitialized = true;
    logger.info('聊天服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理聊天服务资源');
    _adapters.clear();
    _stats.clear();
    _isInitialized = false;
  }

  /// 发送聊天消息
  Future<AiResponse> sendMessage({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final context = AiRequestContext(
      requestId: requestId,
      config: AiServiceConfig(
        providerId: provider.id,
        modelName: modelName,
        enableStreaming: false,
      ),
    );

    logger.info('开始聊天请求', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'assistant': assistant.name,
    });

    try {
      // 获取或创建适配器
      final adapter = await _getOrCreateAdapter(provider, assistant, modelName);

      // 创建提供商实例
      final chatProvider = await adapter.createProvider(enableStreaming: false);

      // 构建消息列表
      final messages = _buildMessageList(adapter, chatHistory, userMessage);

      // 发送请求
      final response = await chatProvider.chatWithTools(messages, null);

      final duration = context.elapsed;

      // 更新统计信息
      _updateStats(provider.id, true, duration);

      logger.info('聊天请求完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'hasThinking': response.thinking != null,
        'usage': response.usage?.totalTokens,
      });

      return AiResponse.success(
        content: response.text ?? '',
        thinking: response.thinking,
        usage: response.usage,
        duration: duration,
        toolCalls: response.toolCalls,
      );
    } catch (e) {
      final duration = context.elapsed;
      _updateStats(provider.id, false, duration);

      logger.error('聊天请求失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return AiResponse.error(error: '聊天请求失败: $e', duration: duration);
    }
  }

  /// 发送流式聊天消息
  Stream<AiStreamEvent> sendMessageStream({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    await initialize();

    final requestId = _generateRequestId();
    final context = AiRequestContext(
      requestId: requestId,
      config: AiServiceConfig(
        providerId: provider.id,
        modelName: modelName,
        enableStreaming: true,
      ),
    );

    logger.info('开始流式聊天请求', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'assistant': assistant.name,
    });

    try {
      // 获取或创建适配器
      final adapter = await _getOrCreateAdapter(provider, assistant, modelName);

      // 创建流式提供商实例
      final chatProvider = await adapter.createProvider(enableStreaming: true);

      if (chatProvider is! StreamingChatProvider) {
        yield AiStreamEvent.error('提供商不支持流式聊天');
        return;
      }

      // 构建消息列表
      final messages = _buildMessageList(adapter, chatHistory, userMessage);

      // 发送流式请求
      final streamProvider = chatProvider;
      final stream = streamProvider.chatStream(messages);

      String? finalThinking;
      List<ToolCall>? allToolCalls;

      await for (final event in stream) {
        switch (event) {
          case TextDeltaEvent(delta: final delta):
            yield AiStreamEvent.contentDelta(delta);
            break;
          case ThinkingDeltaEvent(delta: final delta):
            yield AiStreamEvent.thinkingDelta(delta);
            break;
          case ToolCallDeltaEvent(toolCall: final toolCall):
            yield AiStreamEvent.toolCall(toolCall);
            allToolCalls ??= [];
            allToolCalls.add(toolCall);
            break;
          case CompletionEvent(response: final response):
            finalThinking = response.thinking;
            final duration = context.elapsed;

            _updateStats(provider.id, true, duration);

            logger.info('流式聊天请求完成', {
              'requestId': requestId,
              'duration': '${duration.inMilliseconds}ms',
              'hasThinking': finalThinking != null,
              'usage': response.usage?.totalTokens,
            });

            yield AiStreamEvent.completed(
              finalThinking: finalThinking,
              usage: response.usage,
              duration: duration,
              allToolCalls: allToolCalls,
            );
            break;
          case ErrorEvent(error: final error):
            final duration = context.elapsed;
            _updateStats(provider.id, false, duration);

            logger.error('流式聊天请求出错', {
              'requestId': requestId,
              'error': error.toString(),
              'duration': '${duration.inMilliseconds}ms',
            });

            yield AiStreamEvent.error(error.toString());
            break;
        }
      }
    } catch (e) {
      final duration = context.elapsed;
      _updateStats(provider.id, false, duration);

      logger.error('流式聊天请求失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      yield AiStreamEvent.error('流式聊天请求失败: $e');
    }
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required models.AiProvider provider,
    String? modelName,
  }) async {
    await initialize();

    try {
      // 创建测试助手
      final testAssistant = _createTestAssistant();
      final testModel = modelName ?? _getDefaultModel(provider);

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: testAssistant,
        modelName: testModel,
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 发送测试消息
      final testMessages = [ChatMessage.user('Hello')];
      final response = await chatProvider.chatWithTools(testMessages, null);

      logger.info('提供商测试成功', {
        'provider': provider.name,
        'model': testModel,
        'responseLength': response.text?.length ?? 0,
      });

      return response.text?.isNotEmpty == true;
    } catch (e) {
      logger.error('提供商测试失败', {
        'provider': provider.name,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 获取服务统计信息
  AiServiceStats getStats(String providerId) {
    return _stats[providerId] ?? AiServiceStats();
  }

  /// 获取或创建适配器
  Future<AiProviderAdapter> _getOrCreateAdapter(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
  ) async {
    final key = '${provider.id}_${assistant.id}_$modelName';

    if (!_adapters.containsKey(key)) {
      _adapters[key] = DefaultAiProviderAdapter(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
      );
    }

    return _adapters[key]!;
  }

  /// 构建消息列表
  List<ChatMessage> _buildMessageList(
    AiProviderAdapter adapter,
    List<Message> chatHistory,
    String userMessage,
  ) {
    final messages = <ChatMessage>[];

    // 添加系统消息
    messages.addAll(adapter.buildSystemMessages());

    // 添加聊天历史
    messages.addAll(adapter.convertMessages(chatHistory));

    // 添加用户消息
    messages.add(ChatMessage.user(userMessage));

    return messages;
  }

  /// 创建测试助手
  AiAssistant _createTestAssistant() {
    return AiAssistant(
      id: 'test-assistant',
      name: 'Test Assistant',
      avatar: '🤖',
      systemPrompt: '',
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 10,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Test assistant for provider validation',
      customHeaders: {},
      customBody: {},
      stopSequences: [],
      frequencyPenalty: 0.0,
      presencePenalty: 0.0,
      enableCodeExecution: false,
      enableImageGeneration: false,
      enableTools: false,
      enableReasoning: false,
      enableVision: false,
      enableEmbedding: false,
    );
  }

  /// 获取提供商的第一个可用模型作为默认模型
  String _getDefaultModel(models.AiProvider provider) {
    // 如果提供商有配置的模型，使用第一个
    if (provider.models.isNotEmpty) {
      return provider.models.first.name;
    }

    // 否则根据提供商类型返回常见的模型名
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return 'gpt-3.5-turbo';
      case 'anthropic':
        return 'claude-3-5-sonnet-20241022';
      case 'google':
        return 'gemini-1.5-flash';
      case 'deepseek':
        return 'deepseek-chat';
      case 'ollama':
        return 'llama3.1';
      case 'xai':
        return 'grok-2-latest';
      case 'groq':
        return 'llama3-8b-8192';
      default:
        return 'default-model';
    }
  }

  /// 更新统计信息
  void _updateStats(String providerId, bool success, Duration duration) {
    final currentStats = _stats[providerId] ?? AiServiceStats();

    _stats[providerId] = currentStats.copyWith(
      totalRequests: currentStats.totalRequests + 1,
      successfulRequests: success
          ? currentStats.successfulRequests + 1
          : currentStats.successfulRequests,
      failedRequests: success
          ? currentStats.failedRequests
          : currentStats.failedRequests + 1,
      totalDuration: currentStats.totalDuration + duration,
      lastRequestTime: DateTime.now(),
    );
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'chat_${DateTime.now().millisecondsSinceEpoch}_${_stats.length}';
  }
}
