import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';
import '../models/audio_models.dart';

/// ElevenLabs provider configuration
class ElevenLabsConfig {
  final String apiKey;
  final String baseUrl;
  final String? voiceId;
  final String? model;
  final Duration? timeout;
  final double? stability;
  final double? similarityBoost;
  final double? style;
  final bool? useSpeakerBoost;

  const ElevenLabsConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.elevenlabs.io/v1/',
    this.voiceId,
    this.model,
    this.timeout,
    this.stability,
    this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
  });

  ElevenLabsConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? voiceId,
    String? model,
    Duration? timeout,
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
  }) =>
      ElevenLabsConfig(
        apiKey: apiKey ?? this.apiKey,
        baseUrl: baseUrl ?? this.baseUrl,
        voiceId: voiceId ?? this.voiceId,
        model: model ?? this.model,
        timeout: timeout ?? this.timeout,
        stability: stability ?? this.stability,
        similarityBoost: similarityBoost ?? this.similarityBoost,
        style: style ?? this.style,
        useSpeakerBoost: useSpeakerBoost ?? this.useSpeakerBoost,
      );
}

/// Word with timing information from ElevenLabs STT
class Word {
  final String text;
  final double start;
  final double end;

  const Word({required this.text, required this.start, required this.end});

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        text: json['text'] as String,
        start: (json['start'] as num?)?.toDouble() ?? 0.0,
        end: (json['end'] as num?)?.toDouble() ?? 0.0,
      );
}

/// ElevenLabs response for TTS
class ElevenLabsTTSResponse {
  final Uint8List audioData;
  final String? contentType;

  const ElevenLabsTTSResponse({required this.audioData, this.contentType});
}

/// ElevenLabs response for STT
class ElevenLabsSTTResponse {
  final String text;
  final String? languageCode;
  final double? languageProbability;
  final List<Word>? words;

  const ElevenLabsSTTResponse({
    required this.text,
    this.languageCode,
    this.languageProbability,
    this.words,
  });

  factory ElevenLabsSTTResponse.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>?;
    final words = wordsJson
        ?.map((w) => Word.fromJson(w as Map<String, dynamic>))
        .toList();

    return ElevenLabsSTTResponse(
      text: json['text'] as String? ?? '',
      languageCode: json['language_code'] as String?,
      languageProbability: (json['language_probability'] as num?)?.toDouble(),
      words: words,
    );
  }
}

/// ElevenLabs provider implementation for TTS and STT
class ElevenLabsProvider
    implements ChatCapability, TextToSpeechCapability, SpeechToTextCapability {
  final ElevenLabsConfig config;
  final Dio _dio;
  final Logger _logger = Logger('ElevenLabsProvider');

  ElevenLabsProvider(this.config) : _dio = _createDio(config);

  static Dio _createDio(ElevenLabsConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 60),
        receiveTimeout: config.timeout ?? const Duration(seconds: 60),
        headers: {
          'xi-api-key': config.apiKey,
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
    throw const ProviderError('ElevenLabs does not support chat functionality');
  }

  @override
  Future<ChatResponse> chat(List<ChatMessage> messages) async {
    return chatWithTools(messages, null);
  }

  @override
  Future<List<ChatMessage>?> memoryContents() async => null;

  @override
  Future<String> summarizeHistory(List<ChatMessage> messages) async {
    throw const ProviderError('ElevenLabs does not support chat functionality');
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) async* {
    yield ErrorEvent(
        const ProviderError('ElevenLabs does not support chat functionality'));
  }

  // TextToSpeechCapability implementation
  @override
  Future<TTSResponse> textToSpeech(TTSRequest request) async {
    final response = await _textToSpeechInternal(
      request.text,
      voiceId: request.voice,
      model: request.model,
    );

    return TTSResponse(
      audioData: response.audioData,
      contentType: response.contentType,
      voice: request.voice,
      model: request.model,
      // ElevenLabs doesn't provide duration/sample rate in response
      duration: null,
      sampleRate: null,
      usage: null,
    );
  }

  @override
  Future<List<VoiceInfo>> getVoices() async {
    final rawVoices = await _getVoicesRaw();

    return rawVoices.map((voice) {
      return VoiceInfo(
        id: voice['voice_id'] as String? ?? '',
        name: voice['name'] as String? ?? '',
        description: voice['description'] as String?,
        category: voice['category'] as String?,
        gender: voice['labels']?['gender'] as String?,
        accent: voice['labels']?['accent'] as String?,
        previewUrl: voice['preview_url'] as String?,
      );
    }).toList();
  }

  @override
  List<String> getSupportedAudioFormats() {
    return [
      'mp3_44100_128',
      'mp3_44100_192',
      'pcm_16000',
      'pcm_22050',
      'pcm_24000',
      'pcm_44100',
      'ulaw_8000',
    ];
  }

  // SpeechToTextCapability implementation
  @override
  Future<STTResponse> speechToText(STTRequest request) async {
    late ElevenLabsSTTResponse response;

    if (request.audioData != null) {
      response = await _speechToTextInternal(
        Uint8List.fromList(request.audioData!),
        model: request.model,
      );
    } else if (request.filePath != null) {
      response = await _speechToTextFromFileInternal(
        request.filePath!,
        model: request.model,
      );
    } else {
      throw const InvalidRequestError(
          'Either audioData or filePath must be provided');
    }

    return STTResponse(
      text: response.text,
      language: response.languageCode,
      confidence: response.languageProbability,
      words: response.words
          ?.map((w) => WordTiming(
                word: w.text,
                start: w.start,
                end: w.end,
                confidence:
                    null, // ElevenLabs doesn't provide word-level confidence
              ))
          .toList(),
      model: request.model,
      duration: null,
      usage: null,
    );
  }

  @override
  Future<List<LanguageInfo>> getSupportedLanguages() async {
    // ElevenLabs supports multiple languages but doesn't provide a dynamic API
    // Return commonly supported languages
    return const [
      LanguageInfo(code: 'en', name: 'English', supportsRealtime: true),
      LanguageInfo(code: 'es', name: 'Spanish', supportsRealtime: true),
      LanguageInfo(code: 'fr', name: 'French', supportsRealtime: true),
      LanguageInfo(code: 'de', name: 'German', supportsRealtime: true),
      LanguageInfo(code: 'it', name: 'Italian', supportsRealtime: true),
      LanguageInfo(code: 'pt', name: 'Portuguese', supportsRealtime: true),
      LanguageInfo(code: 'pl', name: 'Polish', supportsRealtime: true),
      LanguageInfo(code: 'tr', name: 'Turkish', supportsRealtime: true),
      LanguageInfo(code: 'ru', name: 'Russian', supportsRealtime: true),
      LanguageInfo(code: 'nl', name: 'Dutch', supportsRealtime: true),
      LanguageInfo(code: 'cs', name: 'Czech', supportsRealtime: true),
      LanguageInfo(code: 'ar', name: 'Arabic', supportsRealtime: true),
      LanguageInfo(code: 'zh', name: 'Chinese', supportsRealtime: true),
      LanguageInfo(code: 'ja', name: 'Japanese', supportsRealtime: true),
      LanguageInfo(code: 'hi', name: 'Hindi', supportsRealtime: true),
      LanguageInfo(code: 'ko', name: 'Korean', supportsRealtime: true),
    ];
  }

  // Convenience methods for backward compatibility
  @override
  Future<List<int>> speech(String text) async {
    final response = await textToSpeech(TTSRequest(text: text));
    return response.audioData;
  }

  @override
  Future<String> transcribe(List<int> audio) async {
    final response = await speechToText(STTRequest.fromAudio(audio));
    return response.text;
  }

  @override
  Future<String> transcribeFile(String filePath) async {
    final response = await speechToText(STTRequest.fromFile(filePath));
    return response.text;
  }

  /// Convert text to speech using ElevenLabs TTS (internal method)
  Future<ElevenLabsTTSResponse> _textToSpeechInternal(
    String text, {
    String? voiceId,
    String? model,
  }) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing ElevenLabs API key');
    }

    final effectiveVoiceId = voiceId ??
        config.voiceId ??
        'JBFqnCBsd6RMkjVDRZzb'; // Default voice to match Rust
    final effectiveModel = model ?? config.model ?? 'eleven_monolingual_v1';

    _logger.info(
      'Converting text to speech with voice: $effectiveVoiceId, model: $effectiveModel',
    );

    try {
      final requestBody = {
        'text': text,
        'model_id': effectiveModel,
        'voice_settings': {
          if (config.stability != null) 'stability': config.stability,
          if (config.similarityBoost != null)
            'similarity_boost': config.similarityBoost,
          if (config.style != null) 'style': config.style,
          if (config.useSpeakerBoost != null)
            'use_speaker_boost': config.useSpeakerBoost,
        },
      };

      // Add query parameter for output format to match Rust implementation
      final response = await _dio.post(
        'text-to-speech/$effectiveVoiceId?output_format=mp3_44100_128',
        data: requestBody,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        throw ProviderError(
          'ElevenLabs TTS API returned status ${response.statusCode}',
        );
      }

      final audioData = Uint8List.fromList(response.data as List<int>);
      final contentType = response.headers.value('content-type');

      return ElevenLabsTTSResponse(
        audioData: audioData,
        contentType: contentType,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  /// Convert speech to text using ElevenLabs STT (internal method)
  Future<ElevenLabsSTTResponse> _speechToTextInternal(
    Uint8List audioData, {
    String? model,
  }) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing ElevenLabs API key');
    }

    final effectiveModel = model ?? config.model ?? 'eleven_multilingual_v2';

    _logger.info('Converting speech to text with model: $effectiveModel');

    try {
      // Use 'file' as the field name to match Rust implementation
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioData,
          filename: 'audio.wav', // Use .wav to match Rust implementation
          contentType: DioMediaType('audio', 'wav'),
        ),
        'model_id': effectiveModel,
      });

      final response = await _dio.post(
        'speech-to-text',
        data: formData,
        options: Options(headers: {'xi-api-key': config.apiKey}),
      );

      if (response.statusCode != 200) {
        throw ProviderError(
          'ElevenLabs STT API returned status ${response.statusCode}',
        );
      }

      final responseText = response.data.toString();
      final rawResponse = responseText;

      try {
        final responseData = response.data as Map<String, dynamic>;
        final sttResponse = ElevenLabsSTTResponse.fromJson(responseData);

        // Extract text from words if available, similar to Rust implementation
        if (sttResponse.words != null && sttResponse.words!.isNotEmpty) {
          final wordsText = sttResponse.words!.map((w) => w.text).join(' ');
          return ElevenLabsSTTResponse(
            text: wordsText,
            languageCode: sttResponse.languageCode,
            languageProbability: sttResponse.languageProbability,
            words: sttResponse.words,
          );
        }

        return sttResponse;
      } catch (e) {
        throw ResponseFormatError(
          'Failed to parse ElevenLabs STT response: $e',
          rawResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  /// Convert speech file to text using ElevenLabs STT (internal method)
  Future<ElevenLabsSTTResponse> _speechToTextFromFileInternal(
    String filePath, {
    String? model,
  }) async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing ElevenLabs API key');
    }

    final effectiveModel = model ?? config.model ?? 'eleven_multilingual_v2';

    _logger.info(
      'Converting speech file to text: $filePath, model: $effectiveModel',
    );

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'model_id': effectiveModel,
      });

      final response = await _dio.post(
        'speech-to-text',
        data: formData,
        options: Options(headers: {'xi-api-key': config.apiKey}),
      );

      if (response.statusCode != 200) {
        throw ProviderError(
          'ElevenLabs STT API returned status ${response.statusCode}',
        );
      }

      final responseText = response.data.toString();
      final rawResponse = responseText;

      try {
        final responseData = response.data as Map<String, dynamic>;
        final sttResponse = ElevenLabsSTTResponse.fromJson(responseData);

        // Extract text from words if available, similar to Rust implementation
        if (sttResponse.words != null && sttResponse.words!.isNotEmpty) {
          final wordsText = sttResponse.words!.map((w) => w.text).join(' ');
          return ElevenLabsSTTResponse(
            text: wordsText,
            languageCode: sttResponse.languageCode,
            languageProbability: sttResponse.languageProbability,
            words: sttResponse.words,
          );
        }

        return sttResponse;
      } catch (e) {
        throw ResponseFormatError(
          'Failed to parse ElevenLabs STT response: $e',
          rawResponse,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  /// Get available voices (internal method)
  Future<List<Map<String, dynamic>>> _getVoicesRaw() async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing ElevenLabs API key');
    }

    try {
      final response = await _dio.get('voices');

      if (response.statusCode != 200) {
        throw ProviderError(
          'ElevenLabs API returned status ${response.statusCode}',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final voices = responseData['voices'] as List<dynamic>? ?? [];

      return voices.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  /// Get available models
  Future<List<Map<String, dynamic>>> getModels() async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing ElevenLabs API key');
    }

    try {
      final response = await _dio.get('models');

      if (response.statusCode != 200) {
        throw ProviderError(
          'ElevenLabs API returned status ${response.statusCode}',
        );
      }

      final models = response.data as List<dynamic>? ?? [];
      return models.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  /// Get user subscription info
  Future<Map<String, dynamic>> getUserInfo() async {
    if (config.apiKey.isEmpty) {
      throw const AuthError('Missing ElevenLabs API key');
    }

    try {
      final response = await _dio.get('user');

      if (response.statusCode != 200) {
        throw ProviderError(
          'ElevenLabs API returned status ${response.statusCode}',
        );
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
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
          return const AuthError('Invalid ElevenLabs API key');
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
