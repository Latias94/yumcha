import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

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
class ElevenLabsProvider implements ChatCapability {
  final ElevenLabsConfig config;
  final Dio _dio;
  final Logger _logger = Logger('ElevenLabsProvider');

  ElevenLabsProvider(this.config) : _dio = _createDio(config);

  static Dio _createDio(ElevenLabsConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeout ?? const Duration(seconds: 30),
        receiveTimeout: config.timeout ?? const Duration(seconds: 30),
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

  /// Convert text to speech using ElevenLabs TTS
  Future<ElevenLabsTTSResponse> textToSpeech(
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

  /// Convert speech to text using ElevenLabs STT
  Future<ElevenLabsSTTResponse> speechToText(
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

  /// Convert speech file to text using ElevenLabs STT
  Future<ElevenLabsSTTResponse> speechToTextFromFile(
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

  /// Get available voices
  Future<List<Map<String, dynamic>>> getVoices() async {
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
