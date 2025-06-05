import 'dart:async';
import '../models/ai_provider.dart' as models;
import '../models/ai_assistant.dart';
import '../models/message.dart';
import '../ai_dart/builder/llm_builder.dart';
import '../ai_dart/models/chat_models.dart';
import '../ai_dart/core/chat_provider.dart';
import '../ai_dart/core/llm_error.dart';
import '../ai_dart/utils/reasoning_utils.dart';
import 'logger_service.dart';

/// Service that adapts the new AI Dart library to the existing service architecture
class AiDartService {
  static final AiDartService _instance = AiDartService._internal();
  factory AiDartService() => _instance;
  AiDartService._internal();

  final LoggerService _logger = LoggerService();

  /// Convert app provider model to AI Dart provider
  Future<ChatProvider> createProvider(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
  ) async {
    return _buildProvider(
      provider,
      assistant,
      modelName,
      enableStreaming: false,
    );
  }

  /// Create a streaming provider with stream enabled
  Future<StreamingChatProvider> createStreamingProvider(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
  ) async {
    final chatProvider = await _buildProvider(
      provider,
      assistant,
      modelName,
      enableStreaming: true,
    );
    if (chatProvider is! StreamingChatProvider) {
      throw UnsupportedError(
        '${provider.type} provider does not support streaming',
      );
    }
    return chatProvider;
  }

  /// Internal method to build providers with optional streaming
  Future<ChatProvider> _buildProvider(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName, {
    required bool enableStreaming,
  }) async {
    _logger.info('构建AI Dart提供商', {
      'providerName': provider.name,
      'providerType': provider.type.toString(),
      'modelName': modelName,
      'apiKey': provider.apiKey.isNotEmpty
          ? '${provider.apiKey.substring(0, 8)}...'
          : '空',
      'baseUrl': provider.baseUrl ?? '默认',
      'enableStreaming': enableStreaming,
    });

    // Map provider type to LLMBackend
    final LLMBackend backend;
    switch (provider.type) {
      case models.ProviderType.openai:
      case models
          .ProviderType
          .custom: // Custom providers use OpenAI-compatible APIs
        backend = LLMBackend.openai;
        break;
      case models.ProviderType.anthropic:
        backend = LLMBackend.anthropic;
        break;
      case models.ProviderType.google:
        backend = LLMBackend.google;
        break;
      default:
        throw UnsupportedError(
          'Provider type ${provider.type} is not yet supported by AI Dart library',
        );
    }

    // Create builder
    final builder = LLMBuilder()
        .backend(backend)
        .apiKey(provider.apiKey)
        .model(modelName)
        .maxTokens(assistant.maxTokens)
        .temperature(assistant.temperature)
        .timeout(const Duration(seconds: 60))
        .topP(assistant.topP)
        .stream(enableStreaming);

    // Add optional parameters if they exist
    if (provider.baseUrl?.isNotEmpty == true) {
      builder.baseUrl(provider.baseUrl!);
    }

    if (assistant.systemPrompt.isNotEmpty) {
      builder.systemPrompt(assistant.systemPrompt);
    }

    return await builder.build();
  }

  /// Convert app messages to AI Dart messages
  List<ChatMessage> convertMessages(List<Message> messages) {
    return messages.map((msg) {
      if (msg.isFromUser) {
        return ChatMessage.user(msg.content);
      } else {
        return ChatMessage.assistant(msg.content);
      }
    }).toList();
  }

  /// Send a chat request using the AI Dart library
  Future<AiDartResult> sendChatRequest({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    final startTime = DateTime.now();

    try {
      _logger.info('开始 AI Dart 聊天请求', {
        'provider': provider.name,
        'model': modelName,
        'assistant': assistant.name,
        'baseUrl': provider.baseUrl ?? '默认端点',
        'chatHistoryLength': chatHistory.length,
      });

      // detail log histroy
      _logger.debug('AI Dart 聊天请求历史记录', {
        'history': chatHistory.map((msg) => msg.content).toList(),
      });

      // Create provider
      final aiProvider = await createProvider(provider, assistant, modelName);

      // Convert messages
      final messages = convertMessages(chatHistory);

      // Add user message
      messages.add(ChatMessage.user(userMessage));

      // Send request
      final response = await aiProvider.chat(messages);
      final duration = DateTime.now().difference(startTime);

      final content = response.text ?? '';

      _logger.info('AI Dart 聊天请求完成', {
        'duration': '${duration.inMilliseconds}ms',
        'usage': response.usage?.totalTokens,
        'responseLength': content.length,
      });

      return AiDartResult(
        content: content,
        thinking: response.thinking,
        duration: duration,
        usage: response.usage,
        toolCalls: response.toolCalls,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      final errorMessage = _handleError(e);

      _logger.error('AI Dart 聊天请求失败', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
        'provider': provider.name,
        'model': modelName,
      });

      return AiDartResult(error: errorMessage, duration: duration);
    }
  }

  /// Send a streaming chat request using the AI Dart library
  Stream<AiDartStreamEvent> sendChatStreamRequest({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    final startTime = DateTime.now();

    try {
      _logger.info('开始 AI Dart 流式聊天请求', {
        'provider': provider.name,
        'model': modelName,
        'assistant': assistant.name,
        'baseUrl': provider.baseUrl ?? '默认端点',
      });

      // Create streaming provider with stream enabled
      final aiProvider = await createStreamingProvider(
        provider,
        assistant,
        modelName,
      );

      // Convert messages
      final messages = convertMessages(chatHistory);

      // Add user message
      messages.add(ChatMessage.user(userMessage));

      // Send streaming request
      final stream = aiProvider.chatStream(messages);

      await for (final event in stream) {
        switch (event) {
          case TextDeltaEvent(delta: final delta):
            yield AiDartStreamEvent(delta: delta);
            break;
          case ThinkingDeltaEvent(delta: final delta):
            // Emit thinking content as separate field
            yield AiDartStreamEvent(thinkingDelta: delta);
            break;
          case ToolCallDeltaEvent(toolCall: final toolCall):
            yield AiDartStreamEvent(toolCall: toolCall);
            break;
          case CompletionEvent(response: final response):
            final duration = DateTime.now().difference(startTime);
            _logger.info('AI Dart 流式聊天请求完成', {
              'duration': '${duration.inMilliseconds}ms',
              'usage': response.usage?.totalTokens,
              'hasThinking': response.thinking != null,
              'thinkingLength': response.thinking?.length ?? 0,
            });
            yield AiDartStreamEvent(
              completed: true,
              usage: response.usage,
              duration: duration,
              finalThinking: response.thinking,
            );
            break;
          case ErrorEvent(error: final error):
            final duration = DateTime.now().difference(startTime);
            _logger.error('AI Dart 流式聊天请求失败', {
              'error': error.toString(),
              'duration': '${duration.inMilliseconds}ms',
            });
            yield AiDartStreamEvent(
              error: _handleError(error),
              duration: duration,
            );
            break;
        }
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      final errorMessage = _handleError(e);

      _logger.error('AI Dart 流式聊天请求异常', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
        'provider': provider.name,
        'model': modelName,
      });

      yield AiDartStreamEvent(error: errorMessage, duration: duration);
    }
  }

  /// Test provider connectivity
  Future<bool> testProvider(
    models.AiProvider provider,
    String testModel,
  ) async {
    try {
      _logger.info('开始测试 AI Dart 提供商', {
        'provider': provider.name,
        'model': testModel,
        'baseUrl': provider.baseUrl ?? '默认端点',
      });

      // Create a minimal assistant for testing
      final testAssistant = AiAssistant(
        id: 'test',
        name: 'Test Assistant',
        avatar: '🤖',
        systemPrompt: '',
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 10, // Limit tokens to save costs
        contextLength: 1,
        streamOutput: false,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
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

      final aiProvider = await createProvider(
        provider,
        testAssistant,
        testModel,
      );
      final messages = [ChatMessage.user('Hi')];

      final response = await aiProvider.chat(messages);

      _logger.info('AI Dart 提供商测试成功', {
        'provider': provider.name,
        'model': testModel,
        'responseLength': response.text?.length ?? 0,
      });

      return response.text != null;
    } catch (e) {
      _logger.warning('AI Dart 提供商测试失败', {
        'provider': provider.name,
        'model': testModel,
        'error': e.toString(),
      });
      return false;
    }
  }

  String _handleError(dynamic error) {
    if (error is LLMError) {
      return error.toString();
    } else {
      return 'Unexpected error: $error';
    }
  }
}

/// Result from AI Dart chat request
class AiDartResult {
  final String? content;
  final String? thinking;
  final String? error;
  final Duration duration;
  final UsageInfo? usage;
  final List<ToolCall>? toolCalls;

  const AiDartResult({
    this.content,
    this.thinking,
    this.error,
    required this.duration,
    this.usage,
    this.toolCalls,
  });

  bool get isSuccess => error == null;
  bool get hasThinking => thinking != null && thinking!.isNotEmpty;
}

/// Stream event from AI Dart streaming request
class AiDartStreamEvent {
  final String? delta;
  final String? thinkingDelta;
  final String? error;
  final bool completed;
  final Duration? duration;
  final UsageInfo? usage;
  final ToolCall? toolCall;
  final String?
  finalThinking; // Complete thinking content when stream completes

  const AiDartStreamEvent({
    this.delta,
    this.thinkingDelta,
    this.error,
    this.completed = false,
    this.duration,
    this.usage,
    this.toolCall,
    this.finalThinking,
  });

  bool get isError => error != null;
  bool get isCompleted => completed;
  bool get hasContent => delta != null;
  bool get hasThinking => thinkingDelta != null;
  bool get hasToolCall => toolCall != null;
}
