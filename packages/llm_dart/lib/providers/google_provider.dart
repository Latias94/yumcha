import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/base_http_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// Google AI harm categories
enum HarmCategory {
  harmCategoryUnspecified('HARM_CATEGORY_UNSPECIFIED'),
  harmCategoryDerogatory('HARM_CATEGORY_DEROGATORY'),
  harmCategoryToxicity('HARM_CATEGORY_TOXICITY'),
  harmCategoryViolence('HARM_CATEGORY_VIOLENCE'),
  harmCategorySexual('HARM_CATEGORY_SEXUAL'),
  harmCategoryMedical('HARM_CATEGORY_MEDICAL'),
  harmCategoryDangerous('HARM_CATEGORY_DANGEROUS'),
  harmCategoryHarassment('HARM_CATEGORY_HARASSMENT'),
  harmCategoryHateSpeech('HARM_CATEGORY_HATE_SPEECH'),
  harmCategorySexuallyExplicit('HARM_CATEGORY_SEXUALLY_EXPLICIT'),
  harmCategoryDangerousContent('HARM_CATEGORY_DANGEROUS_CONTENT');

  const HarmCategory(this.value);
  final String value;
}

/// Google AI harm block thresholds
enum HarmBlockThreshold {
  harmBlockThresholdUnspecified('HARM_BLOCK_THRESHOLD_UNSPECIFIED'),
  blockLowAndAbove('BLOCK_LOW_AND_ABOVE'),
  blockMediumAndAbove('BLOCK_MEDIUM_AND_ABOVE'),
  blockOnlyHigh('BLOCK_ONLY_HIGH'),
  blockNone('BLOCK_NONE'),
  off('OFF');

  const HarmBlockThreshold(this.value);
  final String value;
}

/// Google AI safety setting
class SafetySetting {
  final HarmCategory category;
  final HarmBlockThreshold threshold;

  const SafetySetting({
    required this.category,
    required this.threshold,
  });

  Map<String, dynamic> toJson() => {
        'category': category.value,
        'threshold': threshold.value,
      };
}

/// Google AI file upload response
class GoogleFile {
  final String name;
  final String displayName;
  final String mimeType;
  final int sizeBytes;
  final String state;
  final String? uri;

  const GoogleFile({
    required this.name,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.state,
    this.uri,
  });

  factory GoogleFile.fromJson(Map<String, dynamic> json) => GoogleFile(
        name: json['name'] as String,
        displayName: json['displayName'] as String,
        mimeType: json['mimeType'] as String,
        sizeBytes: int.parse(json['sizeBytes'] as String),
        state: json['state'] as String,
        uri: json['uri'] as String?,
      );

  bool get isActive => state == 'ACTIVE';
}

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
  final ReasoningEffort? reasoningEffort;
  final int? thinkingBudgetTokens;
  final bool? includeThoughts;
  final bool? enableImageGeneration;
  final List<String>? responseModalities;
  final List<SafetySetting>? safetySettings;
  final int maxInlineDataSize;

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
    this.reasoningEffort,
    this.thinkingBudgetTokens,
    this.includeThoughts,
    this.enableImageGeneration,
    this.responseModalities,
    this.safetySettings,
    this.maxInlineDataSize = 20 * 1024 * 1024, // 20MB default
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
    ReasoningEffort? reasoningEffort,
    int? thinkingBudgetTokens,
    bool? includeThoughts,
    bool? enableImageGeneration,
    List<String>? responseModalities,
    List<SafetySetting>? safetySettings,
    int? maxInlineDataSize,
  }) =>
      GoogleConfig(
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
        reasoningEffort: reasoningEffort ?? this.reasoningEffort,
        thinkingBudgetTokens: thinkingBudgetTokens ?? this.thinkingBudgetTokens,
        includeThoughts: includeThoughts ?? this.includeThoughts,
        enableImageGeneration:
            enableImageGeneration ?? this.enableImageGeneration,
        responseModalities: responseModalities ?? this.responseModalities,
        safetySettings: safetySettings ?? this.safetySettings,
        maxInlineDataSize: maxInlineDataSize ?? this.maxInlineDataSize,
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
      reasoningTokens: usageMetadata['thoughtsTokenCount'] as int?,
    );
  }

  @override
  String? get thinking {
    // Extract thinking content from candidates
    final candidates = _rawResponse['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    if (content == null) return null;

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    // According to Google API docs, thinking content has thought: true flag
    final thinkingParts = parts
        .where((part) {
          final isThought = part['thought'] as bool? ?? false;
          final text = part['text'] as String?;
          return isThought && text != null && text.isNotEmpty;
        })
        .map((part) => part['text'] as String)
        .toList();

    return thinkingParts.isEmpty ? null : thinkingParts.join('\n');
  }

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
class GoogleProvider extends BaseHttpProvider {
  final GoogleConfig config;

  /// Cache for uploaded files to avoid re-uploading
  static final Map<String, GoogleFile> _fileCache = {};

  GoogleProvider(this.config)
      : super(
          BaseHttpProvider.createDio(
            baseUrl: config.baseUrl,
            headers: {'Content-Type': 'application/json'},
            timeout: config.timeout,
          ),
          'GoogleProvider',
        );

  /// Get default safety settings (permissive for development)
  static List<SafetySetting> get defaultSafetySettings => [
        const SafetySetting(
          category: HarmCategory.harmCategoryHarassment,
          threshold: HarmBlockThreshold.blockOnlyHigh,
        ),
        const SafetySetting(
          category: HarmCategory.harmCategoryHateSpeech,
          threshold: HarmBlockThreshold.blockOnlyHigh,
        ),
        const SafetySetting(
          category: HarmCategory.harmCategorySexuallyExplicit,
          threshold: HarmBlockThreshold.blockOnlyHigh,
        ),
        const SafetySetting(
          category: HarmCategory.harmCategoryDangerousContent,
          threshold: HarmBlockThreshold.blockOnlyHigh,
        ),
      ];

  @override
  String get providerName => 'Google';

  @override
  String get chatEndpoint {
    final endpoint = config.stream
        ? 'models/${config.model}:streamGenerateContent'
        : 'models/${config.model}:generateContent';
    // Google Gemini API requires API key as query parameter
    return '$endpoint?key=${config.apiKey}';
  }

  @override
  Map<String, dynamic> buildRequestBody(
    List<ChatMessage> messages,
    List<Tool>? tools,
    bool stream,
  ) {
    // For synchronous interface, we'll use a simplified version without file upload
    return _buildRequestBodySync(messages, tools, stream);
  }

  /// Synchronous version for compatibility with base class
  Map<String, dynamic> _buildRequestBodySync(
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

    // Convert messages to Google format (sync version)
    for (final message in messages) {
      // Skip system messages as they are handled separately
      if (message.role == ChatRole.system) continue;

      contents.add(_convertMessageSync(message));
    }

    return _buildBodyWithConfig(contents, tools);
  }

  /// Create request body with configuration
  Map<String, dynamic> _buildBodyWithConfig(
    List<Map<String, dynamic>> contents,
    List<Tool>? tools,
  ) {
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
    if (config.jsonSchema != null && config.jsonSchema!.schema != null) {
      generationConfig['responseMimeType'] = 'application/json';

      // Remove additionalProperties if present (Google API doesn't support it)
      final schema = Map<String, dynamic>.from(config.jsonSchema!.schema!);
      schema.remove('additionalProperties');

      generationConfig['responseSchema'] = schema;
    }

    // Add thinking configuration for reasoning models
    // According to Google API docs, thinking is enabled by default for 2.5 series models
    if (config.reasoningEffort != null ||
        config.thinkingBudgetTokens != null ||
        config.includeThoughts != null) {
      final thinkingConfig = <String, dynamic>{};

      // Include thoughts in response (for getting thinking summaries)
      if (config.includeThoughts != null) {
        thinkingConfig['includeThoughts'] = config.includeThoughts;
      } else if (config.stream) {
        // For streaming, we want to include thoughts by default to get thinking deltas
        thinkingConfig['includeThoughts'] = true;
      }

      // Set thinking budget (token limit for thinking)
      if (config.thinkingBudgetTokens != null) {
        thinkingConfig['thinkingBudget'] = config.thinkingBudgetTokens;
      }

      if (thinkingConfig.isNotEmpty) {
        generationConfig['thinkingConfig'] = thinkingConfig;
      }
    } else if (config.stream) {
      // For streaming without explicit thinking config, still enable includeThoughts
      // to get thinking deltas in the stream
      generationConfig['thinkingConfig'] = {
        'includeThoughts': true,
      };
    }

    // Add image generation configuration
    if (config.enableImageGeneration == true) {
      if (config.responseModalities != null) {
        generationConfig['responseModalities'] = config.responseModalities;
      } else {
        // Default to text and image modalities for image generation
        generationConfig['responseModalities'] = ['TEXT', 'IMAGE'];
      }
      generationConfig['responseMimeType'] = 'text/plain';
    }

    if (generationConfig.isNotEmpty) {
      body['generationConfig'] = generationConfig;
    }

    // Add safety settings
    final effectiveSafetySettings =
        config.safetySettings ?? defaultSafetySettings;
    if (effectiveSafetySettings.isNotEmpty) {
      body['safetySettings'] =
          effectiveSafetySettings.map((s) => s.toJson()).toList();
    }

    // Add tools if provided
    final effectiveTools = tools ?? config.tools;
    if (effectiveTools != null && effectiveTools.isNotEmpty) {
      body['tools'] = [
        {
          'functionDeclarations':
              effectiveTools.map((t) => _convertTool(t)).toList(),
        },
      ];
    }

    return body;
  }

  @override
  ChatResponse parseResponse(Map<String, dynamic> responseData) {
    return GoogleChatResponse(responseData);
  }

  @override
  List<ChatStreamEvent> parseStreamEvents(String chunk) {
    final events = <ChatStreamEvent>[];
    final lines = chunk.split('\n');

    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        try {
          // Handle Google's streaming format which may have data: prefix
          String jsonLine = line.trim();
          if (jsonLine.startsWith('data: ')) {
            jsonLine = jsonLine.substring(6).trim();
          }

          // Skip empty lines or [DONE] markers
          if (jsonLine.isEmpty || jsonLine == '[DONE]') {
            continue;
          }

          final json = jsonDecode(jsonLine) as Map<String, dynamic>;
          final streamEvents = _parseStreamEvents(json);
          events.addAll(streamEvents);
        } catch (e) {
          // Skip malformed JSON chunks
          logger.warning('Failed to parse stream JSON: $line, error: $e');
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

  /// Upload a file to Google AI Files API
  Future<GoogleFile> uploadFile({
    required List<int> data,
    required String mimeType,
    required String displayName,
  }) async {
    try {
      // Create file metadata
      final metadata = {
        'file': {
          'displayName': displayName,
          'mimeType': mimeType,
        }
      };

      // Create multipart form data
      final formData = FormData.fromMap({
        'metadata': jsonEncode(metadata),
        'data': MultipartFile.fromBytes(
          data,
          filename: displayName,
        ),
      });

      final response = await dio.post(
        'upload/v1beta/files?key=${config.apiKey}',
        data: formData,
        options: Options(
          headers: {
            'X-Goog-Upload-Protocol': 'multipart',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ProviderError('File upload failed: ${response.statusCode}');
      }

      final fileData = response.data['file'] as Map<String, dynamic>;
      final uploadedFile = GoogleFile.fromJson(fileData);

      // Cache the uploaded file
      final cacheKey = '${displayName}_${data.length}_$mimeType';
      _fileCache[cacheKey] = uploadedFile;

      return uploadedFile;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw GenericError('File upload error: $e');
    }
  }

  /// Get or upload a file, using cache when possible
  Future<GoogleFile?> getOrUploadFile({
    required List<int> data,
    required String mimeType,
    required String displayName,
  }) async {
    final cacheKey = '${displayName}_${data.length}_$mimeType';

    // Check cache first
    final cachedFile = _fileCache[cacheKey];
    if (cachedFile != null && cachedFile.isActive) {
      return cachedFile;
    }

    // Upload new file
    try {
      return await uploadFile(
        data: data,
        mimeType: mimeType,
        displayName: displayName,
      );
    } catch (e) {
      logger.warning('File upload failed: $e');
      return null;
    }
  }

  /// Synchronous message conversion (without file upload)
  Map<String, dynamic> _convertMessageSync(ChatMessage message) {
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
          'inlineData': {
            'mimeType': mime.mimeType,
            'data': base64Encode(data),
          },
        });
        break;

      case ImageUrlMessage(url: final url):
        parts.add({
          'text': '[Image URL: $url - Note: Google AI requires base64 data]',
        });
        break;

      case FileMessage(mime: final mime, data: final data):
        // For sync version, always use inline data
        if (mime.isDocument || mime.isAudio || mime.isVideo) {
          parts.add({
            'inlineData': {
              'mimeType': mime.mimeType,
              'data': base64Encode(data),
            },
          });
        } else {
          parts.add({
            'text':
                '[File type ${mime.description} (${mime.mimeType}) may not be supported by Google AI]',
          });
        }
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
    }

    return {
      'role': role,
      'parts': parts,
    };
  }

  Map<String, dynamic> _convertTool(Tool tool) {
    return {
      'name': tool.function.name,
      'description': tool.function.description,
      'parameters': tool.function.parameters.toJson(),
    };
  }

  List<ChatStreamEvent> _parseStreamEvents(Map<String, dynamic> json) {
    final events = <ChatStreamEvent>[];
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return events;

    final content = candidates.first['content'] as Map<String, dynamic>?;
    if (content == null) return events;

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) return events;

    // Process all parts in the response
    for (final part in parts) {
      // Check for thinking content first - according to Google API docs,
      // thinking content has a 'thought' boolean flag set to true
      final isThought = part['thought'] as bool? ?? false;
      final text = part['text'] as String?;

      if (isThought && text != null && text.isNotEmpty) {
        events.add(ThinkingDeltaEvent(text));
        continue;
      }

      // Regular text content (not thinking)
      if (!isThought && text != null && text.isNotEmpty) {
        events.add(TextDeltaEvent(text));
        continue;
      }

      // Check for inline image data (generated images)
      final inlineData = part['inlineData'] as Map<String, dynamic>?;
      if (inlineData != null) {
        final mimeType = inlineData['mimeType'] as String?;
        final data = inlineData['data'] as String?;
        if (mimeType != null && data != null && mimeType.startsWith('image/')) {
          // This is a generated image - we could emit a custom event for this
          // For now, we'll include it as text content indicating image generation
          events.add(TextDeltaEvent('[Generated image: $mimeType]'));
          continue;
        }
      }

      // Function calls
      final functionCall = part['functionCall'] as Map<String, dynamic>?;
      if (functionCall != null) {
        final name = functionCall['name'] as String;
        final args = functionCall['args'] as Map<String, dynamic>? ?? {};

        final toolCall = ToolCall(
          id: 'call_$name',
          callType: 'function',
          function: FunctionCall(name: name, arguments: jsonEncode(args)),
        );

        events.add(ToolCallDeltaEvent(toolCall));
        continue;
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
      events.add(CompletionEvent(response));
    }

    return events;
  }
}
