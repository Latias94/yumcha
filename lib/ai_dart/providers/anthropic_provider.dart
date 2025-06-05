import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// Anthropic provider configuration
class AnthropicConfig {
  final String apiKey;
  final String baseUrl;
  final String model;
  final int? maxTokens;
  final double? temperature;
  final String? systemPrompt;
  final Duration? timeout;
  final bool stream;
  final double? topP;
  final int? topK;
  final List<Tool>? tools;
  final ToolChoice? toolChoice;
  final bool reasoning;
  final int? thinkingBudgetTokens;

  const AnthropicConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.anthropic.com/v1/',
    this.model = 'claude-3-5-sonnet-20241022',
    this.maxTokens,
    this.temperature,
    this.systemPrompt,
    this.timeout,
    this.stream = false,
    this.topP,
    this.topK,
    this.tools,
    this.toolChoice,
    this.reasoning = false,
    this.thinkingBudgetTokens,
  });

  AnthropicConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? model,
    int? maxTokens,
    double? temperature,
    String? systemPrompt,
    Duration? timeout,
    bool? stream,
    double? topP,
    int? topK,
    List<Tool>? tools,
    ToolChoice? toolChoice,
    bool? reasoning,
    int? thinkingBudgetTokens,
  }) => AnthropicConfig(
    apiKey: apiKey ?? this.apiKey,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    maxTokens: maxTokens ?? this.maxTokens,
    temperature: temperature ?? this.temperature,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    timeout: timeout ?? this.timeout,
    stream: stream ?? this.stream,
    topP: topP ?? this.topP,
    topK: topK ?? this.topK,
    tools: tools ?? this.tools,
    toolChoice: toolChoice ?? this.toolChoice,
    reasoning: reasoning ?? this.reasoning,
    thinkingBudgetTokens: thinkingBudgetTokens ?? this.thinkingBudgetTokens,
  );
}

/// Anthropic chat response implementation
class AnthropicChatResponse implements ChatResponse {
  final Map<String, dynamic> _rawResponse;

  AnthropicChatResponse(this._rawResponse);

  @override
  String? get text {
    final content = _rawResponse['content'] as List?;
    if (content == null || content.isEmpty) return null;

    final textBlocks = content
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String?)
        .where((text) => text != null)
        .cast<String>();

    return textBlocks.isEmpty ? null : textBlocks.join('\n');
  }

  @override
  String? get thinking {
    final content = _rawResponse['content'] as List?;
    if (content == null || content.isEmpty) return null;

    final thinkingBlock = content.firstWhere(
      (block) => block['type'] == 'thinking',
      orElse: () => null,
    );

    return thinkingBlock?['thinking'] as String?;
  }

  @override
  List<ToolCall>? get toolCalls {
    final content = _rawResponse['content'] as List?;
    if (content == null || content.isEmpty) return null;

    final toolUseBlocks = content
        .where((block) => block['type'] == 'tool_use')
        .toList();

    if (toolUseBlocks.isEmpty) return null;

    return toolUseBlocks
        .map(
          (block) => ToolCall(
            id: block['id'] as String,
            callType: 'function',
            function: FunctionCall(
              name: block['name'] as String,
              arguments: jsonEncode(block['input']),
            ),
          ),
        )
        .toList();
  }

  @override
  UsageInfo? get usage {
    final usageData = _rawResponse['usage'] as Map<String, dynamic>?;
    if (usageData == null) return null;

    return UsageInfo(
      promptTokens: usageData['input_tokens'] as int?,
      completionTokens: usageData['output_tokens'] as int?,
      totalTokens:
          (usageData['input_tokens'] as int? ?? 0) +
          (usageData['output_tokens'] as int? ?? 0),
    );
  }

  @override
  String toString() {
    final textContent = text;
    final calls = toolCalls;
    final thinkingContent = thinking;

    final parts = <String>[];

    if (thinkingContent != null) {
      parts.add('Thinking: $thinkingContent');
    }

    if (calls != null) {
      parts.add(calls.map((c) => c.toString()).join('\n'));
    }

    if (textContent != null) {
      parts.add(textContent);
    }

    return parts.join('\n');
  }
}

/// Anthropic provider implementation
class AnthropicProvider implements StreamingChatProvider, LLMProvider {
  final AnthropicConfig config;
  final Dio _dio;
  final Logger _logger = Logger('AnthropicProvider');

  AnthropicProvider(this.config) : _dio = _createDio(config);

  @override
  Future<ChatResponse> chat(List<ChatMessage> messages) async {
    return chatWithTools(messages, null);
  }

  @override
  Future<List<ChatMessage>?> memoryContents() async => null;

  @override
  Future<String> summarizeHistory(List<ChatMessage> messages) async {
    final prompt =
        'Summarize in 2-3 sentences:\n${messages.map((m) => '${m.role.name}: ${m.content}').join('\n')}';
    final request = [ChatMessage.user(prompt)];
    final response = await chat(request);
    final text = response.text;
    if (text == null) {
      throw const GenericError('no text in summary response');
    }
    return text;
  }

  static Dio _createDio(AnthropicConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 30),
        receiveTimeout: config.timeout ?? const Duration(seconds: 30),
        headers: {
          'x-api-key': config.apiKey,
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
      ),
    );

    return dio;
  }

  @override
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  ) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing Anthropic API key');
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, false);

      // Log request payload at trace level
      if (_logger.level <= Level.FINEST) {
        _logger.finest('Anthropic request payload: ${jsonEncode(requestBody)}');
      }

      _logger.fine('Anthropic request: POST /v1/messages');

      final response = await _dio.post('messages', data: requestBody);

      _logger.fine('Anthropic HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ProviderError(
          'Anthropic API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return AnthropicChatResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) async* {
    if (config.apiKey.isEmpty) {
      yield ErrorEvent(const AuthError('Missing Anthropic API key'));
      return;
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, true);

      // Log request payload at trace level
      if (_logger.level <= Level.FINEST) {
        _logger.finest(
          'Anthropic stream request payload: ${jsonEncode(requestBody)}',
        );
      }

      _logger.fine('Anthropic stream request: POST /v1/messages');

      final response = await _dio.post(
        'messages',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      _logger.fine('Anthropic stream HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        yield ErrorEvent(
          ProviderError('Anthropic API returned status ${response.statusCode}'),
        );
        return;
      }

      final stream = response.data as ResponseBody;
      await for (final chunk in stream.stream.map(utf8.decode)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') {
              _logger.finer('Anthropic stream completed with [DONE]');
              return;
            }

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;

              // Log stream events at finest level
              if (_logger.level <= Level.FINEST) {
                _logger.finest('Anthropic stream event: ${jsonEncode(json)}');
              }

              final event = _parseStreamEvent(json);
              if (event != null) {
                yield event;
              }
            } catch (e) {
              // Log malformed JSON but continue processing
              _logger.warning('Failed to parse stream JSON: $data, error: $e');
              continue;
            }
          }
        }
      }
    } on DioException catch (e) {
      _logger.severe('Anthropic stream DioException: ${e.message}');
      yield ErrorEvent(_handleDioError(e));
    } catch (e) {
      _logger.severe('Anthropic stream unexpected error: $e');
      yield ErrorEvent(GenericError('Unexpected error: $e'));
    }
  }

  Map<String, dynamic> _buildRequestBody(
    List<ChatMessage> messages,
    List<Tool>? tools,
    bool stream,
  ) {
    final anthropicMessages = <Map<String, dynamic>>[];
    final systemMessages = <String>[];

    // Extract system messages and convert other messages to Anthropic format
    for (final message in messages) {
      if (message.role == ChatRole.system) {
        systemMessages.add(message.content);
      } else {
        anthropicMessages.add(_convertMessage(message));
      }
    }

    final body = <String, dynamic>{
      'model': config.model,
      'messages': anthropicMessages,
      'max_tokens': config.maxTokens ?? 1024,
      'stream': stream,
    };

    // Add system prompt - combine config system prompt with message system prompts
    final allSystemPrompts = <String>[];
    if (config.systemPrompt != null) {
      allSystemPrompts.add(config.systemPrompt!);
    }
    allSystemPrompts.addAll(systemMessages);

    if (allSystemPrompts.isNotEmpty) {
      body['system'] = allSystemPrompts.join('\n\n');
    }

    // Add optional parameters
    if (config.temperature != null) body['temperature'] = config.temperature;
    if (config.topP != null) body['top_p'] = config.topP;
    if (config.topK != null) body['top_k'] = config.topK;

    // Add tools if provided
    final effectiveTools = tools ?? config.tools;
    if (effectiveTools != null && effectiveTools.isNotEmpty) {
      body['tools'] = effectiveTools.map((t) => _convertTool(t)).toList();

      final effectiveToolChoice = config.toolChoice;
      if (effectiveToolChoice != null) {
        body['tool_choice'] = _convertToolChoice(effectiveToolChoice);
      }
    }

    // Add thinking configuration if reasoning is enabled
    if (config.reasoning) {
      body['thinking'] = {
        'type': 'enabled',
        'budget_tokens': config.thinkingBudgetTokens ?? 16000,
      };
    }

    return body;
  }

  Map<String, dynamic> _convertMessage(ChatMessage message) {
    final content = <Map<String, dynamic>>[];

    switch (message.messageType) {
      case TextMessage():
        content.add({'type': 'text', 'text': message.content});
        break;
      case ImageMessage(mime: final mime, data: final data):
        content.add({
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': mime.mimeType,
            'data': base64Encode(data),
          },
        });
        break;
      case ImageUrlMessage(url: final url):
        // Note: Anthropic doesn't support image URLs directly like OpenAI
        // This would need to be downloaded and converted to base64
        // For now, we'll add a text message indicating this limitation
        content.add({
          'type': 'text',
          'text': '[Image URL not supported by Anthropic: $url]',
        });
        break;
      case ToolUseMessage(toolCalls: final toolCalls):
        for (final toolCall in toolCalls) {
          content.add({
            'type': 'tool_use',
            'id': toolCall.id,
            'name': toolCall.function.name,
            'input': jsonDecode(toolCall.function.arguments),
          });
        }
        break;
      case ToolResultMessage(results: final results):
        for (final result in results) {
          content.add({
            'type': 'tool_result',
            'tool_use_id': result.id,
            'content': result.function.arguments,
          });
        }
        break;
      default:
        content.add({'type': 'text', 'text': message.content});
    }

    return {'role': message.role.name, 'content': content};
  }

  Map<String, dynamic> _convertTool(Tool tool) {
    return {
      'name': tool.function.name,
      'description': tool.function.description,
      'input_schema': tool.function.parameters.toJson(),
    };
  }

  Map<String, dynamic> _convertToolChoice(ToolChoice toolChoice) {
    switch (toolChoice) {
      case AutoToolChoice():
        return {'type': 'auto'};
      case AnyToolChoice():
        return {'type': 'any'};
      case SpecificToolChoice(toolName: final toolName):
        return {'type': 'tool', 'name': toolName};
      case NoneToolChoice():
        return {'type': 'none'};
    }
  }

  ChatStreamEvent? _parseStreamEvent(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case 'message_start':
        // Message started - could emit a start event if needed
        break;
      case 'content_block_start':
        final contentBlock = json['content_block'] as Map<String, dynamic>?;
        if (contentBlock != null) {
          final blockType = contentBlock['type'] as String?;
          if (blockType == 'tool_use') {
            // Tool use started - could emit tool use start event if needed
          }
        }
        break;
      case 'content_block_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta != null) {
          final text = delta['text'] as String?;
          if (text != null) {
            return TextDeltaEvent(text);
          }
          // Handle tool use input delta if needed
          final partialJson = delta['partial_json'] as String?;
          if (partialJson != null) {
            // Could emit tool use delta event if needed
          }
        }
        break;
      case 'content_block_stop':
        // Content block completed
        break;
      case 'message_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta != null && delta['stop_reason'] != null) {
          // Message completed
          final usage = json['usage'] as Map<String, dynamic>?;
          final response = AnthropicChatResponse({
            'content': [],
            'usage': usage,
          });
          return CompletionEvent(response);
        }
        break;
      case 'message_stop':
        // Message fully completed
        break;
      case 'error':
        final error = json['error'] as Map<String, dynamic>?;
        if (error != null) {
          final message = error['message'] as String? ?? 'Unknown error';
          return ErrorEvent(ProviderError('Anthropic API error: $message'));
        }
        break;
    }

    return null;
  }

  LLMError _handleDioError(DioException e) {
    _logger.warning('Anthropic DioException: ${e.type}, message: ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        final error = HttpError('Request timeout: ${e.message}');
        _logger.warning('Anthropic timeout error: ${error.message}');
        return error;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        _logger.warning('Anthropic bad response: $statusCode, data: $data');

        if (statusCode == 401) {
          return const AuthError('Invalid Anthropic API key');
        } else if (statusCode == 429) {
          return const ProviderError('Rate limit exceeded');
        } else {
          return ProviderError('HTTP $statusCode: $data');
        }
      case DioExceptionType.cancel:
        _logger.info('Anthropic request was cancelled');
        return const GenericError('Request was cancelled');
      case DioExceptionType.connectionError:
        final error = HttpError('Connection error: ${e.message}');
        _logger.warning('Anthropic connection error: ${error.message}');
        return error;
      default:
        final error = HttpError('Network error: ${e.message}');
        _logger.warning('Anthropic network error: ${error.message}');
        return error;
    }
  }

  // CompletionProvider methods
  @override
  Future<CompletionResponse> complete(CompletionRequest request) async {
    // Convert completion request to chat format (similar to Rust implementation)
    final messages = [ChatMessage.user(request.prompt)];

    // Create a temporary config for completion
    final completionConfig = config.copyWith(
      maxTokens: request.maxTokens ?? config.maxTokens,
      temperature: request.temperature ?? config.temperature,
      topP: request.topP ?? config.topP,
      topK: request.topK ?? config.topK,
    );

    // Create temporary provider with completion config
    final tempProvider = AnthropicProvider(completionConfig);
    final response = await tempProvider.chat(messages);

    final text = response.text;
    if (text == null) {
      throw const GenericError('No text in completion response');
    }

    return CompletionResponse(text: text, usage: response.usage);
  }

  // EmbeddingProvider methods
  @override
  Future<List<List<double>>> embed(List<String> input) async {
    throw const ProviderError('Embedding not supported by Anthropic');
  }

  // SpeechToTextProvider methods
  @override
  Future<String> transcribe(List<int> audio) async {
    throw const ProviderError('Speech to text not supported by Anthropic');
  }

  @override
  Future<String> transcribeFile(String filePath) async {
    throw const ProviderError('Speech to text not supported by Anthropic');
  }

  // TextToSpeechProvider methods
  @override
  Future<List<int>> speech(String text) async {
    throw const ProviderError('Text to speech not supported by Anthropic');
  }

  // ModelProvider methods
  @override
  Future<List<AIModel>> models() async {
    throw const ProviderError('Model listing not supported by Anthropic');
  }

  // LLMProvider methods
  @override
  List<Tool>? get tools => config.tools;
}
