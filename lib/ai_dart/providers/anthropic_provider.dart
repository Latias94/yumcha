import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';

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
class AnthropicProvider implements StreamingChatProvider {
  final AnthropicConfig config;
  final Dio _dio;

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

      final response = await _dio.post('messages', data: requestBody);

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

      final response = await _dio.post(
        'messages',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

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
              return;
            }

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final event = _parseStreamEvent(json);
              if (event != null) {
                yield event;
              }
            } catch (e) {
              // Skip malformed JSON chunks
              continue;
            }
          }
        }
      }
    } on DioException catch (e) {
      yield ErrorEvent(_handleDioError(e));
    } catch (e) {
      yield ErrorEvent(GenericError('Unexpected error: $e'));
    }
  }

  Map<String, dynamic> _buildRequestBody(
    List<ChatMessage> messages,
    List<Tool>? tools,
    bool stream,
  ) {
    final anthropicMessages = <Map<String, dynamic>>[];

    // Convert messages to Anthropic format
    for (final message in messages) {
      // Skip system messages as they are handled separately
      if (message.role == ChatRole.system) continue;

      anthropicMessages.add(_convertMessage(message));
    }

    final body = <String, dynamic>{
      'model': config.model,
      'messages': anthropicMessages,
      'max_tokens': config.maxTokens ?? 1024,
      'stream': stream,
    };

    // Add system prompt if configured
    if (config.systemPrompt != null) {
      body['system'] = config.systemPrompt;
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
        content.add({
          'type': 'image_url',
          'image_url': {'url': url},
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
      case 'content_block_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta != null) {
          final text = delta['text'] as String?;
          if (text != null) {
            return TextDeltaEvent(text);
          }
        }
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
    }

    return null;
  }

  LLMError _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpError('Request timeout: ${e.message}');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (statusCode == 401) {
          return const AuthError('Invalid Anthropic API key');
        } else if (statusCode == 429) {
          return const ProviderError('Rate limit exceeded');
        } else {
          return ProviderError('HTTP $statusCode: $data');
        }
      case DioExceptionType.cancel:
        return const GenericError('Request was cancelled');
      case DioExceptionType.connectionError:
        return HttpError('Connection error: ${e.message}');
      default:
        return HttpError('Network error: ${e.message}');
    }
  }
}
