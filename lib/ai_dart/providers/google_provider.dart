import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// Google (Gemini) provider configuration
class GoogleConfig {
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
  final StructuredOutputFormat? jsonSchema;

  const GoogleConfig({
    required this.apiKey,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/',
    this.model = 'gemini-1.5-flash',
    this.maxTokens,
    this.temperature,
    this.systemPrompt,
    this.timeout,
    this.stream = false,
    this.topP,
    this.topK,
    this.tools,
    this.jsonSchema,
  });

  GoogleConfig copyWith({
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
    StructuredOutputFormat? jsonSchema,
  }) => GoogleConfig(
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
    jsonSchema: jsonSchema ?? this.jsonSchema,
  );
}

/// Google chat response implementation
class GoogleChatResponse implements ChatResponse {
  final Map<String, dynamic> _rawResponse;

  GoogleChatResponse(this._rawResponse);

  @override
  String? get text {
    final candidates = _rawResponse['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    if (content == null) return null;

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    final textParts = parts
        .where((part) => part['text'] != null)
        .map((part) => part['text'] as String)
        .toList();

    return textParts.isEmpty ? null : textParts.join('\n');
  }

  @override
  List<ToolCall>? get toolCalls {
    final candidates = _rawResponse['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    if (content == null) return null;

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    final functionCalls = <ToolCall>[];

    for (final part in parts) {
      final functionCall = part['functionCall'] as Map<String, dynamic>?;
      if (functionCall != null) {
        final name = functionCall['name'] as String;
        final args = functionCall['args'] as Map<String, dynamic>? ?? {};

        functionCalls.add(
          ToolCall(
            id: 'call_$name',
            callType: 'function',
            function: FunctionCall(name: name, arguments: jsonEncode(args)),
          ),
        );
      }
    }

    return functionCalls.isEmpty ? null : functionCalls;
  }

  @override
  UsageInfo? get usage {
    final usageMetadata =
        _rawResponse['usageMetadata'] as Map<String, dynamic>?;
    if (usageMetadata == null) return null;

    return UsageInfo(
      promptTokens: usageMetadata['promptTokenCount'] as int?,
      completionTokens: usageMetadata['candidatesTokenCount'] as int?,
      totalTokens: usageMetadata['totalTokenCount'] as int?,
    );
  }

  @override
  String? get thinking => null; // Google doesn't support thinking/reasoning content

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

/// Google (Gemini) provider implementation
class GoogleProvider implements StreamingChatProvider {
  final GoogleConfig config;
  final Dio _dio;

  GoogleProvider(this.config) : _dio = _createDio(config);

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

  static Dio _createDio(GoogleConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 30),
        receiveTimeout: config.timeout ?? const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
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
      throw const AuthError('Missing Google API key');
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, false);
      final endpoint = config.stream
          ? 'models/${config.model}:streamGenerateContent'
          : 'models/${config.model}:generateContent';

      final response = await _dio.post(
        '$endpoint?key=${config.apiKey}',
        data: requestBody,
      );

      if (response.statusCode != 200) {
        throw ProviderError(
          'Google API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return GoogleChatResponse(response.data as Map<String, dynamic>);
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
      yield ErrorEvent(const AuthError('Missing Google API key'));
      return;
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, true);
      final endpoint = 'models/${config.model}:streamGenerateContent';

      final response = await _dio.post(
        '$endpoint?key=${config.apiKey}',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      if (response.statusCode != 200) {
        yield ErrorEvent(
          ProviderError('Google API returned status ${response.statusCode}'),
        );
        return;
      }

      final stream = response.data as ResponseBody;
      await for (final chunk in stream.stream.map(utf8.decode)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            try {
              final json = jsonDecode(line) as Map<String, dynamic>;
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
    final contents = <Map<String, dynamic>>[];

    // Add system message if configured
    if (config.systemPrompt != null) {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': config.systemPrompt},
        ],
      });
    }

    // Convert messages to Google format
    for (final message in messages) {
      // Skip system messages as they are handled separately
      if (message.role == ChatRole.system) continue;

      contents.add(_convertMessage(message));
    }

    final body = <String, dynamic>{'contents': contents};

    // Add generation config if needed
    final generationConfig = <String, dynamic>{};
    if (config.maxTokens != null) {
      generationConfig['maxOutputTokens'] = config.maxTokens;
    }
    if (config.temperature != null) {
      generationConfig['temperature'] = config.temperature;
    }
    if (config.topP != null) {
      generationConfig['topP'] = config.topP;
    }
    if (config.topK != null) {
      generationConfig['topK'] = config.topK;
    }

    // Add structured output if configured
    if (config.jsonSchema != null) {
      generationConfig['responseMimeType'] = 'application/json';
      if (config.jsonSchema!.schema != null) {
        generationConfig['responseSchema'] = config.jsonSchema!.schema;
      }
    }

    if (generationConfig.isNotEmpty) {
      body['generationConfig'] = generationConfig;
    }

    // Add tools if provided
    final effectiveTools = tools ?? config.tools;
    if (effectiveTools != null && effectiveTools.isNotEmpty) {
      body['tools'] = [
        {
          'functionDeclarations': effectiveTools
              .map((t) => _convertTool(t))
              .toList(),
        },
      ];
    }

    return body;
  }

  Map<String, dynamic> _convertMessage(ChatMessage message) {
    final parts = <Map<String, dynamic>>[];

    // Determine role
    String role;
    switch (message.messageType) {
      case ToolResultMessage():
        role = 'function';
        break;
      default:
        role = message.role == ChatRole.user ? 'user' : 'model';
    }

    switch (message.messageType) {
      case TextMessage():
        parts.add({'text': message.content});
        break;
      case ImageMessage(mime: final mime, data: final data):
        parts.add({
          'inlineData': {'mimeType': mime.mimeType, 'data': base64Encode(data)},
        });
        break;
      case PdfMessage(data: final data):
        parts.add({
          'inlineData': {
            'mimeType': 'application/pdf',
            'data': base64Encode(data),
          },
        });
        break;
      case ToolUseMessage(toolCalls: final toolCalls):
        for (final toolCall in toolCalls) {
          parts.add({
            'functionCall': {
              'name': toolCall.function.name,
              'args': jsonDecode(toolCall.function.arguments),
            },
          });
        }
        break;
      case ToolResultMessage(results: final results):
        for (final result in results) {
          parts.add({
            'functionResponse': {
              'name': result.function.name,
              'response': {
                'name': result.function.name,
                'content': jsonDecode(result.function.arguments),
              },
            },
          });
        }
        break;
      default:
        parts.add({'text': message.content});
    }

    return {'role': role, 'parts': parts};
  }

  Map<String, dynamic> _convertTool(Tool tool) {
    return {
      'name': tool.function.name,
      'description': tool.function.description,
      'parameters': tool.function.parameters.toJson(),
    };
  }

  ChatStreamEvent? _parseStreamEvent(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    if (content == null) return null;

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    for (final part in parts) {
      final text = part['text'] as String?;
      if (text != null) {
        return TextDeltaEvent(text);
      }

      final functionCall = part['functionCall'] as Map<String, dynamic>?;
      if (functionCall != null) {
        final name = functionCall['name'] as String;
        final args = functionCall['args'] as Map<String, dynamic>? ?? {};

        final toolCall = ToolCall(
          id: 'call_$name',
          callType: 'function',
          function: FunctionCall(name: name, arguments: jsonEncode(args)),
        );

        return ToolCallDeltaEvent(toolCall);
      }
    }

    // Check if this is the final message
    final finishReason = candidates.first['finishReason'] as String?;
    if (finishReason != null) {
      final usage = json['usageMetadata'] as Map<String, dynamic>?;
      final response = GoogleChatResponse({
        'candidates': [],
        'usageMetadata': usage,
      });
      return CompletionEvent(response);
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
          return const AuthError('Invalid Google API key');
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
