import '../src/rust/api/ai_chat.dart' as genai;
import '../models/ai_provider.dart' as models;
import '../models/ai_assistant.dart';
import '../models/message.dart';
import 'logger_service.dart';

/// AI 请求响应结果
class AiRequestResult {
  final String? content;
  final String? error;
  final Duration? duration;
  final genai.TokenUsage? usage;
  final bool wasCancelled;

  const AiRequestResult({
    this.content,
    this.error,
    this.duration,
    this.usage,
    this.wasCancelled = false,
  });

  bool get isSuccess => content != null && error == null;
}

/// AI 流式请求事件
class AiStreamEvent {
  final String? content;
  final String? error;
  final bool isDone;
  final genai.TokenUsage? usage;
  final bool wasCancelled;

  const AiStreamEvent({
    this.content,
    this.error,
    this.isDone = false,
    this.usage,
    this.wasCancelled = false,
  });

  bool get isContent => content != null && !isDone;
  bool get isError => error != null;
}

/// AI 请求服务 - 专门处理与 genai crate 的交互
class AiRequestService {
  static final AiRequestService _instance = AiRequestService._internal();
  factory AiRequestService() => _instance;
  AiRequestService._internal();

  final LoggerService _logger = LoggerService();
  final Map<String, genai.AiChatClient> _clients = {};

  /// 将应用内的 AiProvider 转换为 genai 的 AiProvider
  genai.AiProvider convertProvider(models.AiProvider appProvider) {
    switch (appProvider.type) {
      case models.ProviderType.openai:
        return const genai.AiProvider.openAi();
      case models.ProviderType.anthropic:
        return const genai.AiProvider.anthropic();
      case models.ProviderType.google:
        return const genai.AiProvider.gemini();
      case models.ProviderType.ollama:
        return const genai.AiProvider.ollama();
      case models.ProviderType.custom:
        return genai.AiProvider.custom(name: appProvider.name);
    }
  }

  /// 构建 AI 聊天选项
  genai.AiChatOptions buildChatOptions(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
  ) {
    return genai.AiChatOptions(
      model: modelName,
      apiKey: provider.apiKey,
      baseUrl: provider.baseUrl?.isNotEmpty == true ? provider.baseUrl : null,
      temperature: assistant.temperature,
      topP: assistant.topP,
      maxTokens: assistant.maxTokens,
      systemPrompt: assistant.systemPrompt.isNotEmpty
          ? assistant.systemPrompt
          : null,
      stopSequences: assistant.stopSequences.isNotEmpty
          ? assistant.stopSequences
          : null,
    );
  }

  /// 构建聊天消息列表
  List<genai.ChatMessage> buildChatMessages(
    AiAssistant assistant,
    List<Message> chatHistory,
    String userMessage,
  ) {
    final messages = <genai.ChatMessage>[];

    // 添加系统提示（如果有）
    if (assistant.systemPrompt.isNotEmpty) {
      messages.add(
        genai.ChatMessage(
          role: genai.ChatRole.system,
          content: assistant.systemPrompt,
        ),
      );
    }

    // 添加上下文历史（限制数量）
    final contextHistory = chatHistory.take(assistant.contextLength).toList();
    for (final message in contextHistory.reversed) {
      if (message.isFromUser) {
        messages.add(
          genai.ChatMessage(
            role: genai.ChatRole.user,
            content: message.content,
          ),
        );
      } else {
        messages.add(
          genai.ChatMessage(
            role: genai.ChatRole.assistant,
            content: message.content,
          ),
        );
      }
    }

    // 添加当前用户消息
    messages.add(
      genai.ChatMessage(role: genai.ChatRole.user, content: userMessage),
    );

    return messages;
  }

  /// 获取或创建 AI 聊天客户端
  genai.AiChatClient _getClient(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
  ) {
    final clientKey = '${provider.id}_$modelName';

    if (_clients.containsKey(clientKey)) {
      return _clients[clientKey]!;
    }

    final aiProvider = convertProvider(provider);
    final options = buildChatOptions(provider, assistant, modelName);

    final client = genai.AiChatClient(provider: aiProvider, options: options);

    _clients[clientKey] = client;
    _logger.info('创建 AI 客户端: ${provider.name} -> $modelName');

    return client;
  }

  /// 清除客户端缓存
  void clearClientCache([String? providerId]) {
    if (providerId != null) {
      _clients.removeWhere((key, _) => key.startsWith(providerId));
    } else {
      _clients.clear();
    }
    _logger.info('清除客户端缓存: ${providerId ?? '全部'}');
  }

  /// 验证提供商配置
  String? _validateProvider(models.AiProvider provider) {
    if (!provider.isEnabled) {
      return 'AI提供商未启用';
    }

    if (provider.apiKey.isEmpty &&
        provider.type != models.ProviderType.ollama) {
      return 'API密钥不能为空';
    }

    // 基本的 API 密钥格式验证
    switch (provider.type) {
      case models.ProviderType.openai:
      case models.ProviderType.custom:
        if (!provider.apiKey.startsWith('sk-') &&
            provider.apiKey != 'sk-test-example-key') {
          return 'OpenAI API密钥格式错误，应以 sk- 开头';
        }
        break;
      case models.ProviderType.anthropic:
        if (!provider.apiKey.startsWith('sk-ant-')) {
          return 'Anthropic API密钥格式错误，应以 sk-ant- 开头';
        }
        break;
      default:
        break;
    }

    return null;
  }

  /// 构建请求上下文信息（用于错误报告）
  Map<String, dynamic> _buildRequestContext(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
    String userMessage,
  ) {
    return {
      'provider': {
        'name': provider.name,
        'type': provider.type.name,
        'baseUrl': provider.baseUrl ?? '默认端点',
        'apiKeyPrefix': provider.apiKey.isNotEmpty
            ? provider.apiKey.length > 8
                  ? '${provider.apiKey.substring(0, 8)}...'
                  : '${provider.apiKey}...'
            : '未设置',
      },
      'model': modelName,
      'assistant': assistant.name,
      'parameters': {
        'temperature': assistant.temperature,
        'topP': assistant.topP,
        'maxTokens': assistant.maxTokens,
        'systemPrompt': assistant.systemPrompt.isNotEmpty
            ? assistant.systemPrompt.length > 50
                  ? '${assistant.systemPrompt.substring(0, 50)}...'
                  : assistant.systemPrompt
            : '无',
      },
      'message': userMessage.length > 100
          ? '${userMessage.substring(0, 100)}...'
          : userMessage,
    };
  }

  /// 发送单次聊天请求
  Future<AiRequestResult> sendChatRequest({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    final startTime = DateTime.now();
    final requestContext = _buildRequestContext(
      provider,
      assistant,
      modelName,
      userMessage,
    );

    try {
      // 验证提供商配置
      final validationError = _validateProvider(provider);
      if (validationError != null) {
        _logger.error('AI 请求验证失败', {
          'error': validationError,
          'context': requestContext,
        });
        return AiRequestResult(error: validationError);
      }

      _logger.info('开始 AI 聊天请求', {
        'provider': provider.name,
        'model': modelName,
        'assistant': assistant.name,
        'baseUrl': provider.baseUrl ?? '默认端点',
      });

      // 获取客户端
      final client = _getClient(provider, assistant, modelName);

      // 构建消息
      final messages = buildChatMessages(assistant, chatHistory, userMessage);

      // 发送请求
      final response = await client.chat(messages: messages);
      final duration = DateTime.now().difference(startTime);

      _logger.info('AI 聊天请求完成', {
        'duration': '${duration.inMilliseconds}ms',
        'usage': response.usage?.totalTokens,
        'responseLength': response.content.length,
      });

      return AiRequestResult(
        content: response.content,
        duration: duration,
        usage: response.usage,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      final errorMessage = _handleError(e, requestContext);

      _logger.error('AI 聊天请求失败', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
        'context': requestContext,
      });

      return AiRequestResult(error: errorMessage, duration: duration);
    }
  }

  /// 发送流式聊天请求
  Stream<AiStreamEvent> sendChatStreamRequest({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    final startTime = DateTime.now();
    final requestContext = _buildRequestContext(
      provider,
      assistant,
      modelName,
      userMessage,
    );

    try {
      // 验证提供商配置
      final validationError = _validateProvider(provider);
      if (validationError != null) {
        _logger.error('AI 流式请求验证失败', {
          'error': validationError,
          'context': requestContext,
        });
        yield AiStreamEvent(error: validationError);
        return;
      }

      _logger.info('开始 AI 流式聊天请求', {
        'provider': provider.name,
        'model': modelName,
        'assistant': assistant.name,
        'baseUrl': provider.baseUrl ?? '默认端点',
      });

      // 获取客户端
      final client = _getClient(provider, assistant, modelName);

      // 构建消息
      final messages = buildChatMessages(assistant, chatHistory, userMessage);

      // 发送流式请求
      final stream = client.chatStream(messages: messages);

      await for (final event in stream) {
        switch (event) {
          case genai.ChatStreamEvent_Start():
            _logger.debug('AI 流式聊天开始');
            break;

          case genai.ChatStreamEvent_Content(:final content):
            yield AiStreamEvent(content: content);
            break;

          case genai.ChatStreamEvent_Done(:final totalContent, :final usage):
            final duration = DateTime.now().difference(startTime);

            _logger.info('AI 流式聊天完成', {
              'duration': '${duration.inMilliseconds}ms',
              'totalLength': totalContent.length,
              'usage': usage?.totalTokens,
            });

            yield AiStreamEvent(isDone: true, usage: usage);
            break;

          case genai.ChatStreamEvent_Error(:final message):
            _logger.error('AI 流式聊天错误', {
              'error': message,
              'context': requestContext,
            });
            yield AiStreamEvent(
              error: _formatDetailedError(message, requestContext),
            );
            break;
        }
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      final errorMessage = _handleError(e, requestContext);

      _logger.error('AI 流式聊天请求失败', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
        'context': requestContext,
      });

      yield AiStreamEvent(error: errorMessage);
    }
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required models.AiProvider provider,
    String? modelName,
  }) async {
    final testModel =
        modelName ?? provider.models.firstOrNull?.name ?? 'gpt-3.5-turbo';
    final requestContext = {
      'provider': provider.name,
      'type': provider.type.name,
      'baseUrl': provider.baseUrl ?? '默认端点',
      'model': testModel,
    };

    try {
      // 验证提供商配置
      final validationError = _validateProvider(provider);
      if (validationError != null) {
        _logger.warning('提供商验证失败', {
          'error': validationError,
          'context': requestContext,
        });
        return false;
      }

      _logger.info('开始测试提供商', requestContext);

      final options = genai.AiChatOptions(
        model: testModel,
        apiKey: provider.apiKey,
        baseUrl: provider.baseUrl?.isNotEmpty == true ? provider.baseUrl : null,
        temperature: 0.7,
        maxTokens: 10, // 限制token以节省费用
      );

      final client = genai.AiChatClient(
        provider: convertProvider(provider),
        options: options,
      );

      final messages = [
        genai.ChatMessage(role: genai.ChatRole.user, content: 'Hi'),
      ];

      // 发送简单测试请求，设置短超时
      final response = await client.chat(messages: messages);

      _logger.info('提供商测试成功', {
        ...requestContext,
        'responseLength': response.content.length,
      });

      return response.content.isNotEmpty;
    } catch (e) {
      _logger.error('提供商测试失败', {
        'error': e.toString(),
        'context': requestContext,
      });
      return false;
    }
  }

  /// 处理错误信息（增强版，包含请求上下文）
  String _handleError(dynamic error, Map<String, dynamic> requestContext) {
    final errorMessage = error.toString().toLowerCase();
    String userFriendlyMessage;

    if (errorMessage.contains('unauthorized') ||
        errorMessage.contains('invalid api key')) {
      userFriendlyMessage = 'API密钥无效，请检查配置';
    } else if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      userFriendlyMessage = '请求过于频繁，请稍后重试';
    } else if (errorMessage.contains('insufficient_quota') ||
        errorMessage.contains('quota exceeded')) {
      userFriendlyMessage = '账户余额不足，请检查订阅状态';
    } else if (errorMessage.contains('model') &&
        errorMessage.contains('not found')) {
      userFriendlyMessage = '模型不存在，请检查模型名称';
    } else if (errorMessage.contains('timeout')) {
      userFriendlyMessage = '请求超时，请检查网络连接';
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      userFriendlyMessage = '网络连接失败，请检查网络设置';
    } else if (errorMessage.contains('404') ||
        errorMessage.contains('not found')) {
      userFriendlyMessage = 'API端点不存在，请检查服务器地址';
    } else {
      userFriendlyMessage = '请求失败';
    }

    return _formatDetailedError(
      userFriendlyMessage,
      requestContext,
      error.toString(),
    );
  }

  /// 格式化详细错误信息
  String _formatDetailedError(
    String message,
    Map<String, dynamic> requestContext, [
    String? technicalError,
  ]) {
    final buffer = StringBuffer();
    buffer.writeln('❌ $message');
    buffer.writeln();
    buffer.writeln('📡 请求信息:');
    buffer.writeln(
      '   提供商: ${requestContext['provider']?['name'] ?? 'Unknown'}',
    );
    buffer.writeln(
      '   端点: ${requestContext['provider']?['baseUrl'] ?? requestContext['baseUrl'] ?? 'Unknown'}',
    );
    buffer.writeln('   模型: ${requestContext['model'] ?? 'Unknown'}');

    if (requestContext['parameters'] != null) {
      final params = requestContext['parameters'] as Map<String, dynamic>;
      buffer.writeln(
        '   参数: temperature=${params['temperature']}, maxTokens=${params['maxTokens']}',
      );
    }

    if (technicalError != null) {
      buffer.writeln();
      buffer.writeln('🔧 技术详情:');
      buffer.writeln(
        '   ${technicalError.length > 200 ? '${technicalError.substring(0, 200)}...' : technicalError}',
      );
    }

    return buffer.toString();
  }
}
