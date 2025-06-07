import 'dart:convert';

import '../core/chat_provider.dart';
import '../core/base_http_provider.dart';
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
            timeout: config.timeout,
          ),
          'AnthropicProvider',
        );

  static Map<String, String> _buildHeaders(AnthropicConfig config) {
    final headers = ConfigUtils.buildAnthropicHeaders(config.apiKey);

    // Add beta header for interleaved thinking if enabled
    if (config.interleavedThinking) {
      headers['anthropic-beta'] = 'interleaved-thinking-2025-05-14';
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
              // For now, we'll treat thinking deltas as text deltas
              // In a more sophisticated implementation, you might want a separate ThinkingDeltaEvent
              return TextDeltaEvent('[Thinking] $thinkingText');
            }
          }

          // Handle signature delta (thinking encryption)
          if (deltaType == 'signature_delta') {
            // Signature deltas are for verification, typically not shown to users
            // We can safely ignore these or log them for debugging
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
}
