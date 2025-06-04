import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// xAI provider configuration
class XAIConfig {
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
  final StructuredOutputFormat? jsonSchema;

  const XAIConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.x.ai/v1/',
    this.model = 'grok-2-latest',
    this.maxTokens,
    this.temperature,
    this.systemPrompt,
    this.timeout,
    this.stream = false,
    this.topP,
    this.topK,
    this.tools,
    this.toolChoice,
    this.jsonSchema,
  });

  XAIConfig copyWith({
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
    StructuredOutputFormat? jsonSchema,
  }) => XAIConfig(
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
    jsonSchema: jsonSchema ?? this.jsonSchema,
  );
}

/// xAI chat response implementation
class XAIChatResponse implements ChatResponse {
  final Map<String, dynamic> _rawResponse;

  XAIChatResponse(this._rawResponse);

  @override
  String? get text {
    final choices = _rawResponse['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final message = choices.first['message'] as Map<String, dynamic>?;
    return message?['content'] as String?;
  }

  @override
  List<ToolCall>? get toolCalls {
    final choices = _rawResponse['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final message = choices.first['message'] as Map<String, dynamic>?;
    final toolCalls = message?['tool_calls'] as List?;

    if (toolCalls == null) return null;

    return toolCalls
        .map((tc) => ToolCall.fromJson(tc as Map<String, dynamic>))
        .toList();
  }

  @override
  UsageInfo? get usage {
    final usageData = _rawResponse['usage'] as Map<String, dynamic>?;
    if (usageData == null) return null;

    return UsageInfo.fromJson(usageData);
  }

  @override
  String? get thinking => null; // XAI doesn't support thinking/reasoning content

  @override
  String toString() {
    final textContent = text;
    final calls = toolCalls;

    if (textContent != null && calls != null) {
      return '${calls.map((c) => c.toString()).join('\n')}\n$textContent';
    } else if (textContent != null) {
      return textContent;
    } else if (calls != null) {
      return calls.map((c) => c.toString()).join('\n');
    } else {
      return '';
    }
  }
}

/// xAI provider implementation
class XAIProvider implements StreamingChatProvider {
  final XAIConfig config;
  final Dio _dio;

  XAIProvider(this.config) : _dio = _createDio(config);

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

  static Dio _createDio(XAIConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 30),
        receiveTimeout: config.timeout ?? const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
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
      throw const AuthError('Missing xAI API key');
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, false);

      final response = await _dio.post('chat/completions', data: requestBody);

      if (response.statusCode != 200) {
        throw ProviderError(
          'xAI API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return XAIChatResponse(response.data as Map<String, dynamic>);
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
      yield ErrorEvent(const AuthError('Missing xAI API key'));
      return;
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, true);

      final response = await _dio.post(
        'chat/completions',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      if (response.statusCode != 200) {
        yield ErrorEvent(
          ProviderError('xAI API returned status ${response.statusCode}'),
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
    final apiMessages = <Map<String, dynamic>>[];

    // Add system message if configured
    if (config.systemPrompt != null) {
      apiMessages.add({'role': 'system', 'content': config.systemPrompt});
    }

    // Convert messages to xAI format
    for (final message in messages) {
      apiMessages.add(_convertMessage(message));
    }

    final body = <String, dynamic>{
      'model': config.model,
      'messages': apiMessages,
      'stream': stream,
    };

    // Add optional parameters
    if (config.maxTokens != null) body['max_tokens'] = config.maxTokens;
    if (config.temperature != null) body['temperature'] = config.temperature;
    if (config.topP != null) body['top_p'] = config.topP;
    if (config.topK != null) body['top_k'] = config.topK;

    // Add tools if provided
    final effectiveTools = tools ?? config.tools;
    if (effectiveTools != null && effectiveTools.isNotEmpty) {
      body['tools'] = effectiveTools.map((t) => t.toJson()).toList();

      final effectiveToolChoice = config.toolChoice;
      if (effectiveToolChoice != null) {
        body['tool_choice'] = effectiveToolChoice.toJson();
      }
    }

    // Add structured output if configured
    if (config.jsonSchema != null) {
      body['response_format'] = {
        'type': 'json_schema',
        'json_schema': config.jsonSchema!.toJson(),
      };
    }

    return body;
  }

  Map<String, dynamic> _convertMessage(ChatMessage message) {
    final result = <String, dynamic>{'role': message.role.name};

    switch (message.messageType) {
      case TextMessage():
        result['content'] = message.content;
        break;
      case ToolUseMessage(toolCalls: final toolCalls):
        result['tool_calls'] = toolCalls.map((tc) => tc.toJson()).toList();
        break;
      case ToolResultMessage():
        // Tool results are handled as separate messages in xAI
        // This should be handled at a higher level
        result['content'] = message.content;
        break;
      default:
        result['content'] = message.content;
    }

    return result;
  }

  ChatStreamEvent? _parseStreamEvent(Map<String, dynamic> json) {
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final delta = choices.first['delta'] as Map<String, dynamic>?;
    if (delta == null) return null;

    final content = delta['content'] as String?;
    if (content != null) {
      return TextDeltaEvent(content);
    }

    final toolCalls = delta['tool_calls'] as List?;
    if (toolCalls != null && toolCalls.isNotEmpty) {
      final toolCall = toolCalls.first as Map<String, dynamic>;
      return ToolCallDeltaEvent(ToolCall.fromJson(toolCall));
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
          return const AuthError('Invalid API key');
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
