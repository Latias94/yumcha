import 'dart:convert';

import '../core/chat_provider.dart';
import '../core/base_http_provider.dart';
import '../core/config.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';
import '../utils/config_utils.dart';

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
  final bool interleavedThinking;

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
    this.interleavedThinking = false,
  });

  /// Create AnthropicConfig from unified LLMConfig
  factory AnthropicConfig.fromLLMConfig(LLMConfig config) {
    return AnthropicConfig(
      apiKey: config.apiKey!,
      baseUrl: config.baseUrl,
      model: config.model,
      maxTokens: config.maxTokens,
      temperature: config.temperature,
      systemPrompt: config.systemPrompt,
      timeout: config.timeout,
      stream: config.stream,
      topP: config.topP,
      topK: config.topK,
      tools: config.tools,
      toolChoice: config.toolChoice,
      // Anthropic-specific extensions
      reasoning: config.getExtension<bool>('reasoning') ?? false,
      thinkingBudgetTokens: config.getExtension<int>('thinkingBudgetTokens'),
      interleavedThinking:
          config.getExtension<bool>('interleavedThinking') ?? false,
    );
  }

  /// Check if this model supports reasoning/thinking
  /// Based on official Anthropic documentation
  bool get supportsReasoning {
    // According to official docs, extended thinking is supported in:
    // - Claude Opus 4 (claude-opus-4-20250514)
    // - Claude Sonnet 4 (claude-sonnet-4-20250514)
    // - Claude Sonnet 3.7 (claude-3-7-sonnet-20250219)
    return model == 'claude-opus-4-20250514' ||
        model == 'claude-sonnet-4-20250514' ||
        model == 'claude-3-7-sonnet-20250219' ||
        model.contains('claude-3-7-sonnet') ||
        model.contains('claude-4') ||
        reasoning; // Allow explicit override
  }

  /// Check if this model supports vision
  bool get supportsVision {
    // Most Claude 3+ models support vision
    return model.contains('claude-3') || model.contains('claude-4');
  }

  /// Check if this model supports tool calling
  bool get supportsToolCalling {
    // All modern Claude models support tool calling
    return !model.contains('claude-1') && !model.contains('claude-2');
  }

  /// Check if this model supports interleaved thinking
  bool get supportsInterleavedThinking {
    // Only Claude 4 models support interleaved thinking
    return model.contains('claude-4');
  }

  /// Check if this model supports PDF documents
  bool get supportsPDF {
    // Claude 3+ models support PDF documents
    return model.contains('claude-3') || model.contains('claude-4');
  }

  /// Get the maximum thinking budget tokens for this model
  int get maxThinkingBudgetTokens {
    // Based on official documentation, thinking budget can be quite large
    // but should be less than max_tokens
    if (supportsReasoning) {
      return 32000; // Conservative upper limit
    }
    return 0;
  }

  /// Validate thinking configuration
  String? validateThinkingConfig() {
    if (reasoning && !supportsReasoning) {
      return 'Model $model does not support extended thinking. '
          'Supported models: claude-opus-4-20250514, claude-sonnet-4-20250514, claude-3-7-sonnet-20250219';
    }

    if (interleavedThinking && !supportsInterleavedThinking) {
      return 'Model $model does not support interleaved thinking. '
          'Only Claude 4 models support this feature.';
    }

    if (thinkingBudgetTokens != null) {
      if (thinkingBudgetTokens! < 1024) {
        return 'Thinking budget tokens must be at least 1024, got $thinkingBudgetTokens';
      }

      if (thinkingBudgetTokens! > maxThinkingBudgetTokens) {
        return 'Thinking budget tokens ($thinkingBudgetTokens) exceeds maximum ($maxThinkingBudgetTokens) for model $model';
      }
    }

    return null; // Valid
  }

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
    bool? interleavedThinking,
  }) =>
      AnthropicConfig(
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
        interleavedThinking: interleavedThinking ?? this.interleavedThinking,
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

    // Collect all thinking blocks (including redacted thinking)
    final thinkingBlocks = <String>[];

    for (final block in content) {
      final blockType = block['type'] as String?;
      if (blockType == 'thinking') {
        final thinkingText = block['thinking'] as String?;
        if (thinkingText != null && thinkingText.isNotEmpty) {
          thinkingBlocks.add(thinkingText);
        }
      } else if (blockType == 'redacted_thinking') {
        // For redacted thinking, we can't show the content but we can indicate it exists
        thinkingBlocks
            .add('[Redacted thinking content - encrypted for safety]');
      }
    }

    return thinkingBlocks.isEmpty ? null : thinkingBlocks.join('\n\n');
  }

  @override
  List<ToolCall>? get toolCalls {
    final content = _rawResponse['content'] as List?;
    if (content == null || content.isEmpty) return null;

    final toolUseBlocks =
        content.where((block) => block['type'] == 'tool_use').toList();

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
      totalTokens: (usageData['input_tokens'] as int? ?? 0) +
          (usageData['output_tokens'] as int? ?? 0),
      // Note: Anthropic doesn't provide separate thinking_tokens in usage
      // Thinking content is handled separately through content blocks
      reasoningTokens: null,
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
class AnthropicProvider extends BaseHttpProvider {
  final AnthropicConfig config;

  AnthropicProvider(this.config)
      : super(
          BaseHttpProvider.createDio(
            baseUrl: config.baseUrl,
            headers: _buildHeaders(config),
            timeout: config.timeout ?? const Duration(minutes: 5),
          ),
          'AnthropicProvider',
        ) {
    // Validate configuration on initialization
    final validationError = config.validateThinkingConfig();
    if (validationError != null) {
      logger.warning('Anthropic configuration warning: $validationError');
    }
  }

  static Map<String, String> _buildHeaders(AnthropicConfig config) {
    final headers = ConfigUtils.buildAnthropicHeaders(config.apiKey);

    // Add beta headers for new features
    final betaFeatures = <String>[];

    // Always add output-128k support for thinking and extended features
    betaFeatures.add('output-128k-2025-02-19');

    // Add interleaved thinking if enabled
    if (config.interleavedThinking) {
      betaFeatures.add('interleaved-thinking-2025-05-14');
    }

    if (betaFeatures.isNotEmpty) {
      headers['anthropic-beta'] = betaFeatures.join(',');
    }

    return headers;
  }

  @override
  String get providerName => 'Anthropic';

  @override
  String get chatEndpoint => 'messages';

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
    return AnthropicChatResponse(responseData);
  }

  @override
  List<ChatStreamEvent> parseStreamEvents(String chunk) {
    final events = <ChatStreamEvent>[];
    final lines = chunk.split('\n');

    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();
        if (data == '[DONE]') {
          events.add(CompletionEvent(AnthropicChatResponse({})));
          break;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final event = _parseStreamEvent(json);
          if (event != null) {
            events.add(event);
          }
        } catch (e) {
          // Skip malformed JSON chunks
          logger.warning('Failed to parse stream JSON: $data, error: $e');
          continue;
        }
      }
    }

    return events;
  }

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

    // Validate that we have at least one non-system message
    if (anthropicMessages.isEmpty) {
      throw const InvalidRequestError(
          'At least one non-system message is required');
    }

    // Ensure messages alternate between user and assistant (Anthropic requirement)
    _validateMessageSequence(anthropicMessages);

    final body = <String, dynamic>{
      'model': config.model,
      'messages': anthropicMessages,
      'max_tokens': config.maxTokens ?? 1024,
      'stream': stream,
    };

    // Add system prompt - combine config system prompt with message system prompts
    final allSystemPrompts = <String>[];
    if (config.systemPrompt != null && config.systemPrompt!.isNotEmpty) {
      allSystemPrompts.add(config.systemPrompt!);
    }
    allSystemPrompts.addAll(systemMessages);

    if (allSystemPrompts.isNotEmpty) {
      body['system'] = allSystemPrompts.join('\n\n');
    }

    // Add optional parameters with validation
    if (config.temperature != null) {
      if (config.temperature! < 0.0 || config.temperature! > 1.0) {
        logger.warning(
            'Temperature ${config.temperature} is outside valid range [0.0, 1.0]');
      }
      body['temperature'] = config.temperature;
    }

    if (config.topP != null) {
      if (config.topP! < 0.0 || config.topP! > 1.0) {
        logger.warning('TopP ${config.topP} is outside valid range [0.0, 1.0]');
      }
      body['top_p'] = config.topP;
    }

    if (config.topK != null) {
      if (config.topK! < 1) {
        logger.warning('TopK ${config.topK} should be >= 1');
      }
      body['top_k'] = config.topK;
    }

    // Add tools if provided and model supports them
    final effectiveTools = tools ?? config.tools;
    if (effectiveTools != null && effectiveTools.isNotEmpty) {
      if (!config.supportsToolCalling) {
        logger.warning('Model ${config.model} may not support tool calling');
      }

      body['tools'] = effectiveTools.map((t) => _convertTool(t)).toList();

      final effectiveToolChoice = config.toolChoice;
      if (effectiveToolChoice != null &&
          effectiveToolChoice is! NoneToolChoice) {
        body['tool_choice'] = _convertToolChoice(effectiveToolChoice);
      }
    }

    // Add thinking configuration if reasoning is enabled
    if (config.reasoning) {
      if (!config.supportsReasoning) {
        logger.warning(
            'Model ${config.model} may not support reasoning/thinking');
      }

      final thinkingConfig = <String, dynamic>{
        'type': 'enabled',
      };

      // Add budget tokens if specified
      if (config.thinkingBudgetTokens != null) {
        if (config.thinkingBudgetTokens! < 1024) {
          logger.warning(
              'Thinking budget tokens ${config.thinkingBudgetTokens} is quite low, consider using at least 1024');
        }
        thinkingConfig['budget_tokens'] = config.thinkingBudgetTokens;
      }

      body['thinking'] = thinkingConfig;
    }

    return body;
  }

  /// Validate that messages follow Anthropic's requirements
  void _validateMessageSequence(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return;

    // First message should be from user
    if (messages.first['role'] != 'user') {
      logger.warning('First message should be from user for optimal results');
    }

    // Check for consecutive messages from the same role
    for (int i = 1; i < messages.length; i++) {
      if (messages[i]['role'] == messages[i - 1]['role']) {
        logger.info(
            'Found consecutive messages from ${messages[i]['role']}, this is allowed but may affect conversation flow');
        break; // Only warn once
      }
    }
  }

  Map<String, dynamic> _convertMessage(ChatMessage message) {
    final content = <Map<String, dynamic>>[];

    switch (message.messageType) {
      case TextMessage():
        content.add({'type': 'text', 'text': message.content});
        break;
      case ImageMessage(mime: final mime, data: final data):
        // Validate image format for Anthropic
        final supportedFormats = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp'
        ];
        if (!supportedFormats.contains(mime.mimeType)) {
          content.add({
            'type': 'text',
            'text':
                '[Unsupported image format: ${mime.mimeType}. Supported formats: ${supportedFormats.join(', ')}]',
          });
        } else {
          content.add({
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': mime.mimeType,
              'data': base64Encode(data),
            },
          });
        }
        break;
      case FileMessage(mime: final mime, data: final data):
        // Handle different file types
        if (mime.mimeType == 'application/pdf') {
          // Anthropic supports PDF documents as a special content type
          if (!config.supportsPDF) {
            content.add({
              'type': 'text',
              'text':
                  '[PDF documents are not supported by model ${config.model}]',
            });
          } else {
            content.add({
              'type': 'document',
              'source': {
                'type': 'base64',
                'media_type': 'application/pdf',
                'data': base64Encode(data),
              },
            });
          }
        } else {
          // Other file types are not supported by Anthropic
          content.add({
            'type': 'text',
            'text':
                '[File type ${mime.description} (${mime.mimeType}) is not supported by Anthropic. Only PDF documents are supported.]',
          });
        }
        break;
      case ImageUrlMessage(url: final url):
        // Note: Anthropic doesn't support image URLs directly like OpenAI
        // This would need to be downloaded and converted to base64
        // For now, we'll add a text message indicating this limitation
        content.add({
          'type': 'text',
          'text':
              '[Image URL not supported by Anthropic. Please upload the image directly: $url]',
        });
        break;
      case ToolUseMessage(toolCalls: final toolCalls):
        for (final toolCall in toolCalls) {
          try {
            final input = jsonDecode(toolCall.function.arguments);
            content.add({
              'type': 'tool_use',
              'id': toolCall.id,
              'name': toolCall.function.name,
              'input': input,
            });
          } catch (e) {
            logger.warning(
                'Failed to parse tool call arguments: ${toolCall.function.arguments}, error: $e');
            content.add({
              'type': 'text',
              'text':
                  '[Error: Invalid tool call arguments for ${toolCall.function.name}]',
            });
          }
        }
        break;
      case ToolResultMessage(results: final results):
        for (final result in results) {
          content.add({
            'type': 'tool_result',
            'tool_use_id': result.id,
            'content': result.function.arguments,
            'is_error': false, // Could be enhanced to detect errors
          });
        }
        break;
    }

    return {'role': message.role.name, 'content': content};
  }

  Map<String, dynamic> _convertTool(Tool tool) {
    try {
      final schema = tool.function.parameters.toJson();

      // Validate that the schema is valid for Anthropic
      if (schema['type'] != 'object') {
        logger.warning(
            'Tool ${tool.function.name} has invalid schema type: ${schema['type']}. Anthropic requires object type.');
      }

      return {
        'name': tool.function.name,
        'description': tool.function.description.isNotEmpty
            ? tool.function.description
            : 'No description provided',
        'input_schema': schema,
      };
    } catch (e) {
      logger.warning('Failed to convert tool ${tool.function.name}: $e');
      // Return a minimal valid tool definition
      return {
        'name': tool.function.name,
        'description': tool.function.description.isNotEmpty
            ? tool.function.description
            : 'Tool with invalid schema',
        'input_schema': {
          'type': 'object',
          'properties': {},
        },
      };
    }
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
        // Anthropic doesn't have explicit 'none' type, so we omit tool_choice
        // This should be handled at the request level
        return {'type': 'auto'};
    }
  }

  ChatStreamEvent? _parseStreamEvent(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case 'message_start':
        // Message started - initialize response tracking
        final message = json['message'] as Map<String, dynamic>?;
        if (message != null) {
          final usage = message['usage'] as Map<String, dynamic>?;
          if (usage != null) {
            final response = AnthropicChatResponse({
              'content': [],
              'usage': usage,
            });
            return CompletionEvent(response);
          }
        }
        break;

      case 'content_block_start':
        final contentBlock = json['content_block'] as Map<String, dynamic>?;
        if (contentBlock != null) {
          final blockType = contentBlock['type'] as String?;
          if (blockType == 'tool_use') {
            // Tool use started - could emit tool use start event if needed
            final toolName = contentBlock['name'] as String?;
            final toolId = contentBlock['id'] as String?;
            logger.info('Tool use started: $toolName (ID: $toolId)');
          } else if (blockType == 'thinking') {
            // Thinking block started
            logger.info('Thinking block started');
          }
        }
        break;

      case 'content_block_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta != null) {
          final deltaType = delta['type'] as String?;

          // Handle text delta
          final text = delta['text'] as String?;
          if (text != null) {
            return TextDeltaEvent(text);
          }

          // Handle thinking delta (extended thinking)
          if (deltaType == 'thinking_delta') {
            final thinkingText = delta['thinking'] as String?;
            if (thinkingText != null) {
              // Create a custom thinking delta event
              return ThinkingDeltaEvent(thinkingText);
            }
          }

          // Handle signature delta (thinking encryption)
          if (deltaType == 'signature_delta') {
            // Signature deltas are for verification, typically not shown to users
            // We can safely ignore these or log them for debugging
            logger.fine('Received signature delta for thinking verification');
          }

          // Handle tool use input delta
          final partialJson = delta['partial_json'] as String?;
          if (partialJson != null) {
            // Tool input is being built incrementally
            logger.fine('Tool input delta: $partialJson');
          }
        }
        break;

      case 'content_block_stop':
        final index = json['index'] as int?;
        logger.fine('Content block stopped at index: $index');
        break;

      case 'message_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta != null) {
          final stopReason = delta['stop_reason'] as String?;
          if (stopReason != null) {
            // Message completed with stop reason
            final usage = json['usage'] as Map<String, dynamic>?;
            final response = AnthropicChatResponse({
              'content': [],
              'usage': usage,
              'stop_reason': stopReason,
            });
            return CompletionEvent(response);
          }
        }
        break;

      case 'message_stop':
        // Message fully completed - final completion event
        final response = AnthropicChatResponse({
          'content': [],
          'usage': {},
        });
        return CompletionEvent(response);

      case 'error':
        final error = json['error'] as Map<String, dynamic>?;
        if (error != null) {
          final message = error['message'] as String? ?? 'Unknown error';
          final errorType = error['type'] as String? ?? 'api_error';
          return ErrorEvent(
              ProviderError('Anthropic API error ($errorType): $message'));
        }
        break;

      case 'ping':
        // Ping events to keep connection alive - can be ignored
        break;

      default:
        logger.warning('Unknown stream event type: $type');
    }

    return null;
  }
}
