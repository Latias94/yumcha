import 'dart:convert';
import 'package:dio/dio.dart';

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

  final int? candidateCount;
  final List<String>? stopSequences;

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
    this.candidateCount,
    this.stopSequences,
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
    int? candidateCount,
    List<String>? stopSequences,
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
        candidateCount: candidateCount ?? this.candidateCount,
        stopSequences: stopSequences ?? this.stopSequences,
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
///
/// This implementation differs from the official google_generative_ai library in several ways:
/// 1. Uses Dio HTTP client instead of standard http package
/// 2. Uses query parameter authentication (?key=) instead of x-goog-api-key header
/// 3. Uses JSON array streaming format instead of SSE (Server-Sent Events)
/// 4. Integrates with llm_dart's unified ChatMessage system
/// 5. Supports additional features like file upload caching and safety settings
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
    // Note: We use query parameter authentication for compatibility
    // Official google_generative_ai uses x-goog-api-key header instead
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
    // Matches official google_generative_ai GenerationConfig structure
    final generationConfig = <String, dynamic>{};

    // Standard GenerationConfig fields (matching official library)
    if (config.candidateCount != null) {
      generationConfig['candidateCount'] = config.candidateCount;
    }
    if (config.stopSequences != null && config.stopSequences!.isNotEmpty) {
      generationConfig['stopSequences'] = config.stopSequences;
    }
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
    // Check for Google API errors first
    if (responseData.containsKey('error')) {
      final error = responseData['error'] as Map<String, dynamic>;
      final message = error['message'] as String? ?? 'Unknown error';
      final details = error['details'] as List?;

      // Handle specific Google API error types
      if (details != null) {
        for (final detail in details) {
          if (detail is Map && detail['reason'] == 'API_KEY_INVALID') {
            throw const AuthError('Invalid Google API key');
          }
        }
      }

      throw ProviderError('Google API error: $message');
    }

    return GoogleChatResponse(responseData);
  }

  // Buffer for incomplete JSON chunks
  String _streamBuffer = '';
  bool _isFirstChunk = true;

  /// Reset stream parsing state for new requests
  void _resetStreamState() {
    _streamBuffer = '';
    _isFirstChunk = true;
  }

  @override
  List<ChatStreamEvent> parseStreamEvents(String chunk) {
    final events = <ChatStreamEvent>[];

    // Google's streaming format returns a JSON array: [{...}, {...}, {...}]
    // Note: Official google_generative_ai uses SSE format with ?alt=sse
    // We use the default JSON array format for compatibility with our HTTP client
    // Based on flutter_gemini implementation

    try {
      // Add chunk to buffer
      _streamBuffer += chunk;

      String processedData = _streamBuffer.trim();

      // Handle array format - remove brackets and commas
      if (_isFirstChunk && processedData.startsWith('[')) {
        processedData = processedData.replaceFirst('[', '');
        _isFirstChunk = false;
      }

      if (processedData.startsWith(',')) {
        processedData = processedData.replaceFirst(',', '');
      }

      if (processedData.endsWith(']')) {
        processedData = processedData.substring(0, processedData.length - 1);
      }

      processedData = processedData.trim();

      // Split by lines and try to parse complete JSON objects
      final lines = const LineSplitter().convert(processedData);
      String jsonAccumulator = '';

      for (final line in lines) {
        if (jsonAccumulator == '' && line == ',') {
          continue;
        }

        jsonAccumulator += line;

        try {
          // Try to parse the accumulated JSON
          final json = jsonDecode(jsonAccumulator) as Map<String, dynamic>;
          final streamEvents = _parseStreamEvents(json);
          events.addAll(streamEvents);

          // Successfully parsed, clear accumulator and update buffer
          jsonAccumulator = '';
          _streamBuffer = '';
        } catch (e) {
          // JSON incomplete, continue accumulating
          continue;
        }
      }

      // Keep incomplete JSON in buffer for next chunk
      if (jsonAccumulator.isNotEmpty) {
        _streamBuffer = jsonAccumulator;
      }
    } catch (e) {
      logger.warning('Failed to parse Google stream chunk: $e');
      logger.fine('Raw chunk: $chunk');
      logger.fine('Buffer content: $_streamBuffer');
    }

    return events;
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) {
    // Reset stream state for new requests
    _resetStreamState();
    return super.chatStream(messages, tools: tools);
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
        final errorMessage = response.data?['error']?['message'] ??
            'File upload failed: ${response.statusCode}';
        throw ProviderError(errorMessage);
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
  /// Converts llm_dart ChatMessage to Google API Content format
  /// Similar to official google_generative_ai Content.toJson() structure
  Map<String, dynamic> _convertMessageSync(ChatMessage message) {
    final parts = <Map<String, dynamic>>[];

    // Determine role - Google API uses 'user', 'model', 'function'
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

  /// Convert llm_dart Tool to Google API FunctionDeclaration format
  /// Matches the structure used in official google_generative_ai library
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
