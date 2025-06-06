import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// Ollama provider configuration
class OllamaConfig {
  final String baseUrl;
  final String? apiKey;
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

  const OllamaConfig({
    this.baseUrl = 'http://localhost:11434',
    this.apiKey,
    this.model = 'llama3.1',
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

  OllamaConfig copyWith({
    String? baseUrl,
    String? apiKey,
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
  }) =>
      OllamaConfig(
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
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

/// Ollama chat response implementation
class OllamaChatResponse implements ChatResponse {
  final Map<String, dynamic> _rawResponse;

  OllamaChatResponse(this._rawResponse);

  @override
  String? get text {
    // Try different response formats
    final content = _rawResponse['content'] as String?;
    if (content != null && content.isNotEmpty) return content;

    final response = _rawResponse['response'] as String?;
    if (response != null && response.isNotEmpty) return response;

    final message = _rawResponse['message'] as Map<String, dynamic>?;
    if (message != null) {
      final messageContent = message['content'] as String?;
      if (messageContent != null && messageContent.isNotEmpty) {
        return messageContent;
      }
    }

    return null;
  }

  @override
  List<ToolCall>? get toolCalls {
    final message = _rawResponse['message'] as Map<String, dynamic>?;
    if (message == null) return null;

    final toolCalls = message['tool_calls'] as List?;
    if (toolCalls == null || toolCalls.isEmpty) return null;

    return toolCalls.map((tc) {
      final function = tc['function'] as Map<String, dynamic>;
      return ToolCall(
        id: 'call_${function['name']}',
        callType: 'function',
        function: FunctionCall(
          name: function['name'] as String,
          arguments: jsonEncode(function['arguments']),
        ),
      );
    }).toList();
  }

  @override
  UsageInfo? get usage => null; // Ollama doesn't provide usage info

  @override
  String? get thinking =>
      null; // Ollama doesn't support thinking/reasoning content

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

/// Ollama provider implementation
class OllamaProvider
    implements
        ChatCapability,
        CompletionCapability,
        EmbeddingCapability,
        ModelListingCapability {
  final OllamaConfig config;
  final Dio _dio;
  static final Logger _logger = Logger('OllamaProvider');

  OllamaProvider(this.config) : _dio = _createDio(config);

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

  static Dio _createDio(OllamaConfig config) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (config.apiKey != null) {
      headers['Authorization'] = 'Bearer ${config.apiKey}';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 30),
        receiveTimeout: config.timeout ?? const Duration(seconds: 30),
        headers: headers,
      ),
    );

    return dio;
  }

  @override
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  ) async {
    if (config.baseUrl.isEmpty) {
      throw const InvalidRequestError('Missing Ollama base URL');
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, false);

      _logger.fine('Ollama request payload: ${jsonEncode(requestBody)}');

      final response = await _dio.post('/api/chat', data: requestBody);

      _logger.fine('Ollama HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ProviderError(
          'Ollama API returned status ${response.statusCode}: ${response.data}',
        );
      }

      return OllamaChatResponse(response.data as Map<String, dynamic>);
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
    if (config.baseUrl.isEmpty) {
      yield ErrorEvent(const InvalidRequestError('Missing Ollama base URL'));
      return;
    }

    try {
      final requestBody = _buildRequestBody(messages, tools, true);

      _logger.fine(
        'Ollama streaming request payload: ${jsonEncode(requestBody)}',
      );

      final response = await _dio.post(
        '/api/chat',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      _logger.fine('Ollama streaming HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        yield ErrorEvent(
          ProviderError('Ollama API returned status ${response.statusCode}'),
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
    final chatMessages = <Map<String, dynamic>>[];

    // Add system message if configured
    if (config.systemPrompt != null) {
      chatMessages.add({'role': 'system', 'content': config.systemPrompt});
    }

    // Convert messages to Ollama format
    for (final message in messages) {
      chatMessages.add(_convertMessage(message));
    }

    final body = <String, dynamic>{
      'model': config.model,
      'messages': chatMessages,
      'stream': stream,
    };

    // Add options if needed (excluding temperature as Ollama handles it differently)
    final options = <String, dynamic>{};
    if (config.topP != null) options['top_p'] = config.topP;
    if (config.topK != null) options['top_k'] = config.topK;

    if (options.isNotEmpty) {
      body['options'] = options;
    }

    // Add structured output format if configured
    // Ollama doesn't require the "name" field in the schema, so we just use the schema itself
    if (config.jsonSchema?.schema != null) {
      body['format'] = config.jsonSchema!.schema;
    }

    // Add tools if provided
    final effectiveTools = tools ?? config.tools;
    if (effectiveTools != null && effectiveTools.isNotEmpty) {
      body['tools'] = effectiveTools.map((t) => _convertTool(t)).toList();
    }

    return body;
  }

  Map<String, dynamic> _convertMessage(ChatMessage message) {
    final result = <String, dynamic>{
      'role': message.role.name,
      'content': message.content,
    };

    return result;
  }

  Map<String, dynamic> _convertTool(Tool tool) {
    // Convert properties to proper JSON format for Ollama
    final propertiesJson = <String, dynamic>{};
    for (final entry in tool.function.parameters.properties.entries) {
      propertiesJson[entry.key] = entry.value.toJson();
    }

    return {
      'type': 'function',
      'function': {
        'name': tool.function.name,
        'description': tool.function.description,
        'parameters': {
          'type': tool.function.parameters.schemaType,
          'properties': propertiesJson,
          'required': tool.function.parameters.required,
        },
      },
    };
  }

  ChatStreamEvent? _parseStreamEvent(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>?;
    if (message != null) {
      final content = message['content'] as String?;
      if (content != null && content.isNotEmpty) {
        return TextDeltaEvent(content);
      }
    }

    // Check if this is the final message
    final done = json['done'] as bool?;
    if (done == true) {
      final response = OllamaChatResponse(json);
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

  @override
  Future<CompletionResponse> complete(CompletionRequest request) async {
    if (config.baseUrl.isEmpty) {
      throw const InvalidRequestError('Missing Ollama base URL');
    }

    try {
      final requestBody = {
        'model': config.model,
        'prompt': request.prompt,
        'raw': true,
        'stream': false,
      };

      _logger.fine('Ollama completion request: ${jsonEncode(requestBody)}');

      final response = await _dio.post('/api/generate', data: requestBody);

      _logger.fine('Ollama completion HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ProviderError(
          'Ollama API returned status ${response.statusCode}: ${response.data}',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final text = responseData['response'] as String? ??
          responseData['content'] as String?;

      if (text == null || text.isEmpty) {
        throw const ProviderError('No answer returned by Ollama');
      }

      return CompletionResponse(text: text);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  @override
  Future<List<List<double>>> embed(List<String> input) async {
    if (config.baseUrl.isEmpty) {
      throw const InvalidRequestError('Missing Ollama base URL');
    }

    try {
      final requestBody = {'model': config.model, 'input': input};

      _logger.fine('Ollama embedding request: ${jsonEncode(requestBody)}');

      final response = await _dio.post('/api/embed', data: requestBody);

      _logger.fine('Ollama embedding HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ProviderError(
          'Ollama API returned status ${response.statusCode}: ${response.data}',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final embeddings = responseData['embeddings'] as List?;

      if (embeddings == null) {
        throw const ProviderError('No embeddings returned by Ollama');
      }

      return embeddings.map((e) => List<double>.from(e as List)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  @override
  Future<List<AIModel>> models() async {
    if (config.baseUrl.isEmpty) {
      throw const InvalidRequestError('Missing Ollama base URL');
    }

    try {
      _logger.fine('Ollama request: GET /api/tags');

      final response = await _dio.get('/api/tags');

      _logger.fine('Ollama HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ProviderError(
          'Ollama API returned status ${response.statusCode}: ${response.data}',
        );
      }

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw ResponseFormatError(
          'Invalid response format from Ollama API',
          responseData.toString(),
        );
      }

      final modelsData = responseData['models'] as List?;
      if (modelsData == null) {
        return [];
      }

      // Convert Ollama model format to AIModel
      final models = modelsData
          .map((modelData) {
            if (modelData is! Map<String, dynamic>) return null;

            try {
              return AIModel(
                id: modelData['name'] as String,
                description: modelData['details']?['family'] as String?,
                object: 'model',
                ownedBy: 'ollama',
              );
            } catch (e) {
              _logger.warning('Failed to parse model: $e');
              return null;
            }
          })
          .where((model) => model != null)
          .cast<AIModel>()
          .toList();

      _logger.fine('Retrieved ${models.length} models from Ollama');
      return models;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }
}
