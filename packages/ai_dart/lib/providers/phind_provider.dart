import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/base_http_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';
import '../utils/config_utils.dart';

/// Phind provider configuration
class PhindConfig {
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

  const PhindConfig({
    required this.apiKey,
    this.baseUrl = 'https://https.extension.phind.com/agent/',
    this.model = 'Phind-70B',
    this.maxTokens,
    this.temperature,
    this.systemPrompt,
    this.timeout,
    this.stream = false,
    this.topP,
    this.topK,
    this.tools,
    this.toolChoice,
  });

  PhindConfig copyWith({
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
  }) =>
      PhindConfig(
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
      );
}

/// Phind chat response implementation for parsed streaming responses
class _PhindChatResponse implements ChatResponse {
  final String _content;

  _PhindChatResponse(this._content);

  @override
  String? get text => _content;

  @override
  List<ToolCall>? get toolCalls => null; // Phind doesn't support tool calls

  @override
  UsageInfo? get usage => null; // Phind doesn't provide usage info

  @override
  String? get thinking =>
      null; // Phind doesn't support thinking/reasoning content

  @override
  String toString() => _content;
}

/// Phind provider implementation
class PhindProvider implements ChatCapability {
  static final Logger _logger = Logger('PhindProvider');

  final PhindConfig config;
  final Dio _dio;

  PhindProvider(this.config) : _dio = _createDio(config);

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

  static Dio _createDio(PhindConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 30),
        receiveTimeout: config.timeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': '', // Phind requires empty User-Agent
          'Accept': '*/*',
          'Accept-Encoding': 'Identity',
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
    try {
      final requestBody = _buildPhindRequestBody(messages);

      if (_logger.isLoggable(Level.FINE)) {
        _logger.fine('Phind request payload: ${jsonEncode(requestBody)}');
      }

      final response = await _dio.post('', data: requestBody);

      _logger.info('Phind HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ProviderError(
          'Phind API returned status ${response.statusCode}: ${response.data}',
        );
      }

      // Phind returns streaming response even for non-streaming requests
      final responseText = response.data as String;
      final content = _parsePhindStreamResponse(responseText);

      if (content.isEmpty) {
        throw const ProviderError('No completion choice returned.');
      }

      return _PhindChatResponse(content);
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
    try {
      final requestBody = _buildPhindRequestBody(messages);

      if (_logger.isLoggable(Level.FINE)) {
        _logger.fine(
          'Phind stream request payload: ${jsonEncode(requestBody)}',
        );
      }

      final response = await _dio.post(
        '',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      _logger.info('Phind stream HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        yield ErrorEvent(
          ProviderError('Phind API returned status ${response.statusCode}'),
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
              final event = _parsePhindStreamEvent(json);
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

  /// Builds the Phind-specific request body format
  Map<String, dynamic> _buildPhindRequestBody(List<ChatMessage> messages) {
    final messageHistory = <Map<String, dynamic>>[];

    // Convert messages to Phind format
    for (final message in messages) {
      final roleStr = message.role == ChatRole.user ? 'user' : 'assistant';
      messageHistory.add({'content': message.content, 'role': roleStr});
    }

    // Add system message if configured
    if (config.systemPrompt != null) {
      messageHistory.insert(0, {
        'content': config.systemPrompt,
        'role': 'system',
      });
    }

    // Find the last user message for user_input field
    final lastUserMessage =
        messages.where((m) => m.role == ChatRole.user).lastOrNull;

    return {
      'additional_extension_context': '',
      'allow_magic_buttons': true,
      'is_vscode_extension': true,
      'message_history': messageHistory,
      'requested_model': config.model,
      'user_input': lastUserMessage?.content ?? '',
    };
  }

  /// Parses a single line from the Phind streaming response
  String? _parsePhindLine(String line) {
    if (!line.startsWith('data: ')) return null;

    final data = line.substring(6);
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return json['choices']?.first?['delta']?['content'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Parses the complete Phind streaming response into a single string
  String _parsePhindStreamResponse(String responseText) {
    return responseText
        .split('\n')
        .map(_parsePhindLine)
        .where((content) => content != null)
        .join();
  }

  /// Parses stream events for Phind streaming responses
  ChatStreamEvent? _parsePhindStreamEvent(Map<String, dynamic> json) {
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final delta = choices.first['delta'] as Map<String, dynamic>?;
    if (delta == null) return null;

    final content = delta['content'] as String?;
    if (content != null) {
      return TextDeltaEvent(content);
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
