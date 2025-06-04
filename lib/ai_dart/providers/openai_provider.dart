import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// OpenAI provider configuration
class OpenAIConfig {
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
  final String? reasoningEffort;
  final StructuredOutputFormat? jsonSchema;
  final String? voice;
  final String? embeddingEncodingFormat;
  final int? embeddingDimensions;

  const OpenAIConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1/',
    this.model = 'gpt-3.5-turbo',
    this.maxTokens,
    this.temperature,
    this.systemPrompt,
    this.timeout,
    this.stream = false,
    this.topP,
    this.topK,
    this.tools,
    this.toolChoice,
    this.reasoningEffort,
    this.jsonSchema,
    this.voice,
    this.embeddingEncodingFormat,
    this.embeddingDimensions,
  });

  OpenAIConfig copyWith({
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
    String? reasoningEffort,
    StructuredOutputFormat? jsonSchema,
    String? voice,
    String? embeddingEncodingFormat,
    int? embeddingDimensions,
  }) => OpenAIConfig(
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
    reasoningEffort: reasoningEffort ?? this.reasoningEffort,
    jsonSchema: jsonSchema ?? this.jsonSchema,
    voice: voice ?? this.voice,
    embeddingEncodingFormat:
        embeddingEncodingFormat ?? this.embeddingEncodingFormat,
    embeddingDimensions: embeddingDimensions ?? this.embeddingDimensions,
  );
}

/// OpenAI chat response implementation
class OpenAIChatResponse implements ChatResponse {
  final Map<String, dynamic> _rawResponse;

  OpenAIChatResponse(this._rawResponse);

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
  String? get thinking => null; // OpenAI doesn't support thinking/reasoning content

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

/// OpenAI provider implementation
class OpenAIProvider implements StreamingChatProvider, LLMProvider {
  final OpenAIConfig config;
  final Dio _dio;

  OpenAIProvider(this.config) : _dio = _createDio(config);

  static Dio _createDio(OpenAIConfig config) {
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
      throw const AuthError('Missing OpenAI API key');
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, false);

      final response = await _dio.post('chat/completions', data: requestBody);

      if (response.statusCode != 200) {
        throw ProviderError(
          'OpenAI API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return OpenAIChatResponse(response.data as Map<String, dynamic>);
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
      yield ErrorEvent(const AuthError('Missing OpenAI API key'));
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
          ProviderError('OpenAI API returned status ${response.statusCode}'),
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

    // Convert messages to OpenAI format
    for (final message in messages) {
      if (message.messageType is ToolResultMessage) {
        // Handle tool results as separate messages
        final toolResults = (message.messageType as ToolResultMessage).results;
        for (final result in toolResults) {
          apiMessages.add({
            'role': 'tool',
            'tool_call_id': result.id,
            'content': result.function.arguments,
          });
        }
      } else {
        apiMessages.add(_convertMessage(message));
      }
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
    if (config.reasoningEffort != null) {
      body['reasoning_effort'] = config.reasoningEffort;
    }

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
      final schema = config.jsonSchema!;
      final responseFormat = <String, dynamic>{
        'type': 'json_schema',
        'json_schema': schema.toJson(),
      };

      // Ensure additionalProperties is set to false for OpenAI compliance
      if (schema.schema != null) {
        final schemaMap = Map<String, dynamic>.from(schema.schema!);
        if (!schemaMap.containsKey('additionalProperties')) {
          schemaMap['additionalProperties'] = false;
        }
        responseFormat['json_schema'] = {
          'name': schema.name,
          if (schema.description != null) 'description': schema.description,
          'schema': schemaMap,
          if (schema.strict != null) 'strict': schema.strict,
        };
      }

      body['response_format'] = responseFormat;
    }

    return body;
  }

  Map<String, dynamic> _convertMessage(ChatMessage message) {
    final result = <String, dynamic>{'role': message.role.name};

    switch (message.messageType) {
      case TextMessage():
        result['content'] = message.content;
        break;
      case ImageUrlMessage(url: final url):
        result['content'] = [
          {
            'type': 'image_url',
            'image_url': {'url': url},
          },
        ];
        break;
      case ToolUseMessage(toolCalls: final toolCalls):
        result['tool_calls'] = toolCalls.map((tc) => tc.toJson()).toList();
        break;
      case ToolResultMessage(results: final results):
        // Tool results need to be converted to separate tool messages
        // This case should not happen in normal message conversion
        // as tool results are handled separately in _buildRequestBody
        result['content'] = message.content.isNotEmpty
            ? message.content
            : 'Tool result';
        result['tool_call_id'] = results.isNotEmpty ? results.first.id : null;
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

  // ChatProvider methods
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

  // CompletionProvider methods
  @override
  Future<CompletionResponse> complete(CompletionRequest request) async {
    // OpenAI doesn't have a separate completion endpoint in newer APIs
    // Convert to chat format
    final messages = [ChatMessage.user(request.prompt)];
    final response = await chat(messages);
    return CompletionResponse(text: response.text ?? '', usage: response.usage);
  }

  // EmbeddingProvider methods
  @override
  Future<List<List<double>>> embed(List<String> input) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing OpenAI API key');
    }

    try {
      final requestBody = {
        'model': config.model,
        'input': input,
        'encoding_format': config.embeddingEncodingFormat ?? 'float',
        if (config.embeddingDimensions != null)
          'dimensions': config.embeddingDimensions,
      };

      final response = await _dio.post('embeddings', data: requestBody);

      if (response.statusCode != 200) {
        throw ProviderError(
          'OpenAI API returned status ${response.statusCode}: ${response.data}',
        );
      }

      final data = response.data as Map<String, dynamic>;
      final embeddings = (data['data'] as List)
          .map((item) => (item['embedding'] as List).cast<double>())
          .toList();

      return embeddings;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  // SpeechToTextProvider methods
  @override
  Future<String> transcribe(List<int> audio) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing OpenAI API key');
    }

    try {
      final formData = FormData.fromMap({
        'model': config.model,
        'response_format': 'text',
        'file': MultipartFile.fromBytes(audio, filename: 'audio.m4a'),
      });

      final response = await _dio.post('audio/transcriptions', data: formData);

      if (response.statusCode != 200) {
        throw ProviderError(
          'OpenAI API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  @override
  Future<String> transcribeFile(String filePath) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing OpenAI API key');
    }

    try {
      final formData = FormData.fromMap({
        'model': config.model,
        'response_format': 'text',
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('audio/transcriptions', data: formData);

      if (response.statusCode != 200) {
        throw ProviderError(
          'OpenAI API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return response.data as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  // TextToSpeechProvider methods
  @override
  Future<List<int>> speech(String text) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing OpenAI API key');
    }

    try {
      final requestBody = {
        'model': config.model,
        'input': text,
        'voice': config.voice ?? 'alloy',
      };

      final response = await _dio.post(
        'audio/speech',
        data: requestBody,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        throw ProviderError(
          'OpenAI API returned status ${response.statusCode}',
        );
      }

      return response.data as List<int>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  // LLMProvider methods
  @override
  List<Tool>? get tools => config.tools;
}
