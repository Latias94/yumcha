/// Audio-related models for Text-to-Speech (TTS) and Speech-to-Text (STT) functionality
library;

import '../core/chat_provider.dart' show UsageInfo;

/// Text-to-Speech request configuration
class TTSRequest {
  /// Text to convert to speech
  final String text;

  /// Voice ID or name
  final String? voice;

  /// Model to use for TTS
  final String? model;

  /// Audio format (mp3, wav, ogg, etc.)
  final String? format;

  /// Audio quality/bitrate
  final String? quality;

  /// Sample rate (e.g., 44100, 22050)
  final int? sampleRate;

  /// Voice stability (0.0-1.0, provider-specific)
  final double? stability;

  /// Similarity boost (0.0-1.0, provider-specific)
  final double? similarityBoost;

  /// Style parameter (0.0-1.0, provider-specific)
  final double? style;

  /// Use speaker boost (provider-specific)
  final bool? useSpeakerBoost;

  /// Speed/rate of speech (provider-specific)
  final double? speed;

  const TTSRequest({
    required this.text,
    this.voice,
    this.model,
    this.format,
    this.quality,
    this.sampleRate,
    this.stability,
    this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
    this.speed,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        if (voice != null) 'voice': voice,
        if (model != null) 'model': model,
        if (format != null) 'format': format,
        if (quality != null) 'quality': quality,
        if (sampleRate != null) 'sample_rate': sampleRate,
        if (stability != null) 'stability': stability,
        if (similarityBoost != null) 'similarity_boost': similarityBoost,
        if (style != null) 'style': style,
        if (useSpeakerBoost != null) 'use_speaker_boost': useSpeakerBoost,
        if (speed != null) 'speed': speed,
      };

  factory TTSRequest.fromJson(Map<String, dynamic> json) => TTSRequest(
        text: json['text'] as String,
        voice: json['voice'] as String?,
        model: json['model'] as String?,
        format: json['format'] as String?,
        quality: json['quality'] as String?,
        sampleRate: json['sample_rate'] as int?,
        stability: json['stability'] as double?,
        similarityBoost: json['similarity_boost'] as double?,
        style: json['style'] as double?,
        useSpeakerBoost: json['use_speaker_boost'] as bool?,
        speed: json['speed'] as double?,
      );
}

/// Text-to-Speech response with metadata
class TTSResponse {
  /// Audio data as bytes
  final List<int> audioData;

  /// Content type (e.g., 'audio/mpeg')
  final String? contentType;

  /// Audio duration in seconds
  final double? duration;

  /// Sample rate
  final int? sampleRate;

  /// Voice used for generation
  final String? voice;

  /// Model used for generation
  final String? model;

  /// Usage information if available
  final UsageInfo? usage;

  const TTSResponse({
    required this.audioData,
    this.contentType,
    this.duration,
    this.sampleRate,
    this.voice,
    this.model,
    this.usage,
  });

  Map<String, dynamic> toJson() => {
        'audio_data': audioData,
        if (contentType != null) 'content_type': contentType,
        if (duration != null) 'duration': duration,
        if (sampleRate != null) 'sample_rate': sampleRate,
        if (voice != null) 'voice': voice,
        if (model != null) 'model': model,
        if (usage != null) 'usage': usage!.toJson(),
      };

  factory TTSResponse.fromJson(Map<String, dynamic> json) => TTSResponse(
        audioData: List<int>.from(json['audio_data'] as List),
        contentType: json['content_type'] as String?,
        duration: json['duration'] as double?,
        sampleRate: json['sample_rate'] as int?,
        voice: json['voice'] as String?,
        model: json['model'] as String?,
        usage: json['usage'] != null
            ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
            : null,
      );
}

/// Speech-to-Text request configuration
class STTRequest {
  /// Audio data as bytes (for direct audio input)
  final List<int>? audioData;

  /// File path (for file input)
  final String? filePath;

  /// Model to use for STT
  final String? model;

  /// Language code (e.g., 'en-US')
  final String? language;

  /// Audio format hint
  final String? format;

  /// Whether to include word-level timing
  final bool includeWordTiming;

  /// Whether to include confidence scores
  final bool includeConfidence;

  /// Temperature for transcription (provider-specific)
  final double? temperature;

  const STTRequest({
    this.audioData,
    this.filePath,
    this.model,
    this.language,
    this.format,
    this.includeWordTiming = false,
    this.includeConfidence = false,
    this.temperature,
  });

  /// Create STT request from audio data
  factory STTRequest.fromAudio(
    List<int> audioData, {
    String? model,
    String? language,
    String? format,
    bool includeWordTiming = false,
    bool includeConfidence = false,
    double? temperature,
  }) =>
      STTRequest(
        audioData: audioData,
        model: model,
        language: language,
        format: format,
        includeWordTiming: includeWordTiming,
        includeConfidence: includeConfidence,
        temperature: temperature,
      );

  /// Create STT request from file
  factory STTRequest.fromFile(
    String filePath, {
    String? model,
    String? language,
    String? format,
    bool includeWordTiming = false,
    bool includeConfidence = false,
    double? temperature,
  }) =>
      STTRequest(
        filePath: filePath,
        model: model,
        language: language,
        format: format,
        includeWordTiming: includeWordTiming,
        includeConfidence: includeConfidence,
        temperature: temperature,
      );

  Map<String, dynamic> toJson() => {
        if (audioData != null) 'audio_data': audioData,
        if (filePath != null) 'file_path': filePath,
        if (model != null) 'model': model,
        if (language != null) 'language': language,
        if (format != null) 'format': format,
        'include_word_timing': includeWordTiming,
        'include_confidence': includeConfidence,
        if (temperature != null) 'temperature': temperature,
      };

  factory STTRequest.fromJson(Map<String, dynamic> json) => STTRequest(
        audioData: json['audio_data'] != null
            ? List<int>.from(json['audio_data'] as List)
            : null,
        filePath: json['file_path'] as String?,
        model: json['model'] as String?,
        language: json['language'] as String?,
        format: json['format'] as String?,
        includeWordTiming: json['include_word_timing'] as bool? ?? false,
        includeConfidence: json['include_confidence'] as bool? ?? false,
        temperature: json['temperature'] as double?,
      );
}

/// Speech-to-Text response with metadata
class STTResponse {
  /// Transcribed text
  final String text;

  /// Language code detected
  final String? language;

  /// Overall confidence score (0.0-1.0)
  final double? confidence;

  /// Word-level timing and confidence information
  final List<WordTiming>? words;

  /// Model used for transcription
  final String? model;

  /// Audio duration in seconds
  final double? duration;

  /// Usage information if available
  final UsageInfo? usage;

  const STTResponse({
    required this.text,
    this.language,
    this.confidence,
    this.words,
    this.model,
    this.duration,
    this.usage,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        if (language != null) 'language': language,
        if (confidence != null) 'confidence': confidence,
        if (words != null) 'words': words!.map((w) => w.toJson()).toList(),
        if (model != null) 'model': model,
        if (duration != null) 'duration': duration,
        if (usage != null) 'usage': usage!.toJson(),
      };

  factory STTResponse.fromJson(Map<String, dynamic> json) => STTResponse(
        text: json['text'] as String,
        language: json['language'] as String?,
        confidence: json['confidence'] as double?,
        words: json['words'] != null
            ? (json['words'] as List)
                .map((w) => WordTiming.fromJson(w as Map<String, dynamic>))
                .toList()
            : null,
        model: json['model'] as String?,
        duration: json['duration'] as double?,
        usage: json['usage'] != null
            ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
            : null,
      );
}

/// Word timing information for STT
class WordTiming {
  /// The word text
  final String word;

  /// Start time in seconds
  final double start;

  /// End time in seconds
  final double end;

  /// Confidence score for this word (0.0-1.0)
  final double? confidence;

  const WordTiming({
    required this.word,
    required this.start,
    required this.end,
    this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'start': start,
        'end': end,
        if (confidence != null) 'confidence': confidence,
      };

  factory WordTiming.fromJson(Map<String, dynamic> json) => WordTiming(
        word: json['word'] as String,
        start: (json['start'] as num).toDouble(),
        end: (json['end'] as num).toDouble(),
        confidence: json['confidence'] as double?,
      );
}

/// Voice information
class VoiceInfo {
  /// Voice ID
  final String id;

  /// Voice name
  final String name;

  /// Voice description
  final String? description;

  /// Voice category (e.g., 'premade', 'cloned')
  final String? category;

  /// Voice gender
  final String? gender;

  /// Voice accent/language
  final String? accent;

  /// Preview URL if available
  final String? previewUrl;

  const VoiceInfo({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.gender,
    this.accent,
    this.previewUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (gender != null) 'gender': gender,
        if (accent != null) 'accent': accent,
        if (previewUrl != null) 'preview_url': previewUrl,
      };

  factory VoiceInfo.fromJson(Map<String, dynamic> json) => VoiceInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        gender: json['gender'] as String?,
        accent: json['accent'] as String?,
        previewUrl: json['preview_url'] as String?,
      );
}

/// Language information for STT
class LanguageInfo {
  /// Language code (e.g., 'en-US')
  final String code;

  /// Language name
  final String name;

  /// Whether this language is supported for real-time STT
  final bool supportsRealtime;

  const LanguageInfo({
    required this.code,
    required this.name,
    this.supportsRealtime = false,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'supports_realtime': supportsRealtime,
      };

  factory LanguageInfo.fromJson(Map<String, dynamic> json) => LanguageInfo(
        code: json['code'] as String,
        name: json['name'] as String,
        supportsRealtime: json['supports_realtime'] as bool? ?? false,
      );
}

// UsageInfo is imported from chat_models.dart
