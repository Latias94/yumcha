import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/base_http_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';
import '../utils/reasoning_utils.dart';
import '../utils/config_utils.dart';

/// OpenAI provider implementation with enhanced features:
///
/// **Recent Improvements (aligned with Rust implementation):**
/// 1. **Dedicated SSE parsing**: Added _parseSSEChunk() method for better stream handling
/// 2. **Enhanced error handling**: Specific error types for different HTTP status codes
/// 3. **Optimized logging**: Conditional logging checks to improve performance
///
/// **Features:**
/// - All standard LLM provider interfaces (chat, embeddings, TTS, STT, models)
/// - Advanced reasoning model support via ReasoningUtils
/// - Streaming chat with thinking/reasoning content tracking
/// - Multiple provider support (OpenAI, OpenRouter, Groq, DeepSeek)
/// - Comprehensive error handling with detailed status code classification

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
  }) =>
      OpenAIConfig(
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
  final String? _thinkingContent;

  OpenAIChatResponse(this._rawResponse, [this._thinkingContent]);

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
  String? get thinking => _thinkingContent;

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
class OpenAIProvider extends BaseHttpProvider
    implements
        EmbeddingCapability,
        TextToSpeechCapability,
        SpeechToTextCapability,
        ModelListingCapability,
        CompletionCapability {
  final OpenAIConfig config;

  OpenAIProvider(this.config)
      : super(
          BaseHttpProvider.createDio(
            baseUrl: config.baseUrl,
            headers: ConfigUtils.buildOpenAIHeaders(config.apiKey),
            timeout: config.timeout,
          ),
          'OpenAIProvider',
        );

  @override
  String get providerName => 'OpenAI';

  @override
  String get chatEndpoint => 'chat/completions';

  @override
  Map<String, dynamic> buildRequestBody(
    List<ChatMessage> messages,
    List<Tool>? tools,
    bool stream,
  ) {
    return _buildRequestBody(messages, tools, stream);
  }

  @override
  ChatResponse parseResponse(Map<String, dynamic> responseData) {
    // Extract thinking/reasoning content from non-streaming response
    String? thinkingContent;

    // Check for reasoning content in the response
    final choices = responseData['choices'] as List?;
    if (choices != null && choices.isNotEmpty) {
      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>?;

      if (message != null) {
        // Check for reasoning content in various possible fields
        thinkingContent = message['reasoning'] as String? ??
            message['thinking'] as String? ??
            message['reasoning_content'] as String?;

        // For models that use <think> tags, extract thinking content
        final content = message['content'] as String?;
        if (content != null && ReasoningUtils.containsThinkingTags(content)) {
          final thinkMatch = RegExp(
            r'<think>(.*?)</think>',
            dotAll: true,
          ).firstMatch(content);
          if (thinkMatch != null) {
            thinkingContent = thinkMatch.group(1)?.trim();
            // Update the message content to remove thinking tags
            message['content'] = ReasoningUtils.filterThinkingContent(content);
          }
        }

        // For OpenRouter with deepseek-r1, check if include_reasoning was used
        if (thinkingContent == null && config.model.contains('deepseek-r1')) {
          final reasoning = responseData['reasoning'] as String?;
          if (reasoning != null && reasoning.isNotEmpty) {
            thinkingContent = reasoning;
          }
        }
      }
    }

    return OpenAIChatResponse(responseData, thinkingContent);
  }

  @override
  List<ChatStreamEvent> parseStreamEvents(String chunk) {
    final events = <ChatStreamEvent>[];

    // Parse SSE chunk
    final json = _parseSSEChunk(chunk);
    if (json == null) return events;

    // Use existing stream parsing logic
    final parsedEvents = _parseStreamEventWithReasoning(
      json,
      false, // hasReasoningContent - would need to track this
      '', // lastChunk - would need to track this
      StringBuffer(), // thinkingBuffer - would need to track this
    );

    events.addAll(parsedEvents);
    return events;
  }

  /// Get provider ID based on base URL
  String _getProviderId() {
    final baseUrl = config.baseUrl.toLowerCase();
    if (baseUrl.contains('openrouter')) {
      return 'openrouter';
    } else if (baseUrl.contains('groq')) {
      return 'groq';
    } else if (baseUrl.contains('deepseek')) {
      return 'deepseek';
    } else if (baseUrl.contains('openai')) {
      return 'openai';
    } else {
      return 'openai'; // Default fallback
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
            'content': result.function.arguments.isNotEmpty
                ? result.function.arguments
                : message.content,
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

    // Add optional parameters using reasoning utils
    // Handle max tokens based on model type
    body.addAll(
      ReasoningUtils.getMaxTokensParams(
        model: config.model,
        maxTokens: config.maxTokens,
      ),
    );

    // Add temperature if not disabled for reasoning models
    if (config.temperature != null &&
        !ReasoningUtils.shouldDisableTemperature(config.model)) {
      body['temperature'] = config.temperature;
    }

    // Add top_p if not disabled for reasoning models
    if (config.topP != null &&
        !ReasoningUtils.shouldDisableTopP(config.model)) {
      body['top_p'] = config.topP;
    }
    if (config.topK != null) body['top_k'] = config.topK;

    // Add reasoning effort parameters
    final providerId = _getProviderId();
    body.addAll(
      ReasoningUtils.getReasoningEffortParams(
        providerId: providerId,
        model: config.model,
        reasoningEffort: config.reasoningEffort,
      ),
    );

    // Add provider-specific reasoning parameters
    if (providerId == 'openrouter' && config.model.contains('deepseek-r1')) {
      body['include_reasoning'] = true;
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
      case ImageMessage(mime: final mime, data: final data):
        // Handle base64 encoded images
        final base64Data = base64Encode(data);
        result['content'] = [
          {
            'type': 'image_url',
            'image_url': {'url': 'data:${mime.mimeType};base64,$base64Data'},
          },
        ];
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
        result['content'] =
            message.content.isNotEmpty ? message.content : 'Tool result';
        result['tool_call_id'] = results.isNotEmpty ? results.first.id : null;
        break;
      default:
        result['content'] = message.content;
    }

    return result;
  }

  /// Parse a Server-Sent Events (SSE) chunk from OpenAI's streaming API.
  ///
  /// Returns:
  /// - `Some(Map)` - Parsed JSON data if found
  /// - `null` - If chunk should be skipped (e.g., ping, done signal)
  Map<String, dynamic>? _parseSSEChunk(String chunk) {
    for (final line in chunk.split('\n')) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('data: ')) {
        final data = trimmedLine.substring(6).trim();

        // Handle completion signal
        if (data == '[DONE]') {
          return null;
        }

        // Skip empty data
        if (data.isEmpty) {
          continue;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          return json;
        } catch (e) {
          // Skip malformed JSON chunks
          logger.warning('Failed to parse SSE chunk JSON: $e');
          continue;
        }
      }
    }

    return null;
  }

  /// Get delta from JSON response
  Map<String, dynamic>? _getDelta(Map<String, dynamic> json) {
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final choice = choices.first as Map<String, dynamic>;
    return choice['delta'] as Map<String, dynamic>?;
  }

  /// Parse stream events with reasoning support
  List<ChatStreamEvent> _parseStreamEventWithReasoning(
    Map<String, dynamic> json,
    bool hasReasoningContent,
    String lastChunk,
    StringBuffer thinkingBuffer,
  ) {
    final events = <ChatStreamEvent>[];
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) return events;

    final choice = choices.first as Map<String, dynamic>;
    final delta = choice['delta'] as Map<String, dynamic>?;
    if (delta == null) return events;

    // Handle reasoning content using reasoning utils
    final reasoningContent = ReasoningUtils.extractReasoningContent(delta);

    if (reasoningContent != null && reasoningContent.isNotEmpty) {
      thinkingBuffer.write(reasoningContent);
      events.add(ThinkingDeltaEvent(reasoningContent));
      return events;
    }

    // Handle regular content
    final content = delta['content'] as String?;
    if (content != null && content.isNotEmpty) {
      // Check reasoning status using utils
      final reasoningResult = ReasoningUtils.checkReasoningStatus(
        delta: delta,
        hasReasoningContent: hasReasoningContent,
        lastChunk: lastChunk,
      );

      if (reasoningResult.isReasoningJustDone) {
        logger.fine('Reasoning phase completed, starting response phase');
      }

      // Filter out thinking tags for models that use <think> tags
      if (ReasoningUtils.containsThinkingTags(content)) {
        // Don't emit content that contains thinking tags
        return events;
      }

      // If we previously had reasoning content and now have regular content,
      // this might be the start of the actual response
      if (hasReasoningContent && content.trim().isNotEmpty) {
        logger.fine('Transitioning from reasoning to response content');
      }

      events.add(TextDeltaEvent(content));
    }

    // Handle tool calls
    final toolCalls = delta['tool_calls'] as List?;
    if (toolCalls != null && toolCalls.isNotEmpty) {
      final toolCall = toolCalls.first as Map<String, dynamic>;
      if (toolCall.containsKey('id') && toolCall.containsKey('function')) {
        try {
          events.add(ToolCallDeltaEvent(ToolCall.fromJson(toolCall)));
        } catch (e) {
          // Skip malformed tool calls
          logger.warning('Failed to parse tool call: $e');
        }
      }
    }

    // Check for finish reason
    final finishReason = choice['finish_reason'] as String?;
    if (finishReason != null) {
      final usage = json['usage'] as Map<String, dynamic>?;
      final thinkingContent =
          thinkingBuffer.isNotEmpty ? thinkingBuffer.toString() : null;

      final response = OpenAIChatResponse({
        'choices': [
          {
            'message': {'content': '', 'role': 'assistant'},
          },
        ],
        if (usage != null) 'usage': usage,
      }, thinkingContent);

      events.add(CompletionEvent(response));
    }

    return events;
  }

  // ChatCapability methods
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

    // Filter out thinking content for reasoning models (similar to TypeScript implementation)
    return ReasoningUtils.filterThinkingContent(text);
  }

  // CompletionCapability methods
  @override
  Future<CompletionResponse> complete(CompletionRequest request) async {
    // OpenAI doesn't have a separate completion endpoint in newer APIs
    // Convert to chat format
    final messages = [ChatMessage.user(request.prompt)];
    final response = await chat(messages);
    return CompletionResponse(text: response.text ?? '', usage: response.usage);
  }

  // EmbeddingCapability methods
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

      // Optimized logging with condition check
      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI request: POST /embeddings');
      }

      final response = await dio.post('embeddings', data: requestBody);

      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI HTTP status: ${response.statusCode}');
      }

      // Enhanced error handling for embeddings
      if (response.statusCode != 200) {
        final statusCode = response.statusCode;
        final errorData = response.data;

        if (statusCode == 401) {
          throw const AuthError('Invalid OpenAI API key for embeddings');
        } else if (statusCode == 429) {
          throw const ProviderError('Rate limit exceeded for embeddings');
        } else {
          throw ResponseFormatError(
            'OpenAI embeddings API returned error status: $statusCode',
            errorData?.toString() ?? '',
          );
        }
      }

      final data = response.data as Map<String, dynamic>;
      final embeddings = (data['data'] as List)
          .map((item) => (item['embedding'] as List).cast<double>())
          .toList();

      return embeddings;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  // SpeechToTextCapability methods
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

      // Optimized logging with condition check
      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI request: POST /audio/transcriptions');
      }

      final response = await dio.post('audio/transcriptions', data: formData);

      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI HTTP status: ${response.statusCode}');
      }

      // Enhanced error handling for transcription
      if (response.statusCode != 200) {
        final statusCode = response.statusCode;
        final errorData = response.data;

        if (statusCode == 401) {
          throw const AuthError('Invalid OpenAI API key for transcription');
        } else if (statusCode == 429) {
          throw const ProviderError('Rate limit exceeded for transcription');
        } else {
          throw ResponseFormatError(
            'OpenAI transcription API returned error status: $statusCode',
            errorData?.toString() ?? '',
          );
        }
      }

      return response.data as String;
    } on DioException catch (e) {
      throw handleDioError(e);
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

      // Optimized logging with condition check
      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI request: POST /audio/transcriptions (file)');
      }

      final response = await dio.post('audio/transcriptions', data: formData);

      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI HTTP status: ${response.statusCode}');
      }

      // Enhanced error handling for file transcription
      if (response.statusCode != 200) {
        final statusCode = response.statusCode;
        final errorData = response.data;

        if (statusCode == 401) {
          throw const AuthError(
            'Invalid OpenAI API key for file transcription',
          );
        } else if (statusCode == 429) {
          throw const ProviderError(
            'Rate limit exceeded for file transcription',
          );
        } else {
          throw ResponseFormatError(
            'OpenAI file transcription API returned error status: $statusCode',
            errorData?.toString() ?? '',
          );
        }
      }

      return response.data as String;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  // TextToSpeechCapability methods
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

      // Optimized logging with condition check
      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI request: POST /audio/speech');
      }

      final response = await dio.post(
        'audio/speech',
        data: requestBody,
        options: Options(responseType: ResponseType.bytes),
      );

      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI HTTP status: ${response.statusCode}');
      }

      // Enhanced error handling for text-to-speech
      if (response.statusCode != 200) {
        final statusCode = response.statusCode;

        if (statusCode == 401) {
          throw const AuthError('Invalid OpenAI API key for text-to-speech');
        } else if (statusCode == 429) {
          throw const ProviderError('Rate limit exceeded for text-to-speech');
        } else {
          throw ResponseFormatError(
            'OpenAI text-to-speech API returned error status: $statusCode',
            'Binary response data',
          );
        }
      }

      return response.data as List<int>;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  // ModelListingCapability methods
  @override
  Future<List<AIModel>> models() async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing OpenAI API key');
    }

    try {
      // Optimized logging with condition check
      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI request: GET /models');
      }

      final response = await dio.get('models');

      if (logger.isLoggable(Level.FINE)) {
        logger.fine('OpenAI HTTP status: ${response.statusCode}');
      }

      // Enhanced error handling for models endpoint
      if (response.statusCode != 200) {
        final statusCode = response.statusCode;
        final errorData = response.data;

        if (statusCode == 401) {
          throw const AuthError('Invalid OpenAI API key for models endpoint');
        } else if (statusCode == 429) {
          throw const ProviderError('Rate limit exceeded for models endpoint');
        } else {
          throw ResponseFormatError(
            'OpenAI models API returned error status: $statusCode',
            errorData?.toString() ?? '',
          );
        }
      }

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw ResponseFormatError(
          'Invalid response format from OpenAI API',
          responseData.toString(),
        );
      }

      final modelsData = responseData['data'] as List?;
      if (modelsData == null) {
        return [];
      }

      // Convert OpenAI model format to AIModel
      final models = modelsData
          .map((modelData) {
            if (modelData is! Map<String, dynamic>) return null;

            try {
              return AIModel(
                id: modelData['id'] as String,
                description: modelData['description'] as String?,
                object: modelData['object'] as String? ?? 'model',
                ownedBy: modelData['owned_by'] as String?,
              );
            } catch (e) {
              logger.warning('Failed to parse model: $e');
              return null;
            }
          })
          .where((model) => model != null)
          .cast<AIModel>()
          .toList();

      logger.fine('Retrieved ${models.length} models from OpenAI');
      return models;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }
}
