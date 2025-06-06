import 'dart:async';
import 'dart:typed_data';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../core/ai_service_base.dart';
import 'package:ai_dart/ai_dart.dart';

/// 语音服务，负责处理TTS和STT功能
class SpeechService extends AiServiceBase {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final Map<String, Uint8List> _ttsCache = {};
  final Map<String, String> _sttCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 1);
  bool _isInitialized = false;

  @override
  String get serviceName => 'SpeechService';

  @override
  Set<AiCapability> get supportedCapabilities => {
    AiCapability.textToSpeech,
    AiCapability.speechToText,
  };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化语音服务');
    _isInitialized = true;
    logger.info('语音服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理语音服务资源');
    _ttsCache.clear();
    _sttCache.clear();
    _cacheTimestamps.clear();
    _isInitialized = false;
  }

  /// 文字转语音
  Future<Uint8List> textToSpeech({
    required models.AiProvider provider,
    required String text,
    String? voice,
    bool useCache = true,
  }) async {
    await initialize();

    final cacheKey = _generateTtsCacheKey(provider.id, text, voice);

    // 检查缓存
    if (useCache && _isTtsCacheValid(cacheKey)) {
      logger.debug('从缓存获取TTS音频', {
        'provider': provider.name,
        'textLength': text.length,
        'voice': voice,
      });
      return _ttsCache[cacheKey]!;
    }

    logger.info('生成TTS音频', {
      'provider': provider.name,
      'textLength': text.length,
      'voice': voice,
    });

    try {
      // 创建临时助手
      final tempAssistant = _createTempAssistant();

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: tempAssistant,
        modelName: _getTtsModel(provider),
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 检查是否支持TTS功能
      if (chatProvider is! TextToSpeechCapability) {
        throw Exception('提供商不支持TTS功能: ${provider.name}');
      }

      final ttsProvider = chatProvider as TextToSpeechCapability;
      final audioBytes = await ttsProvider.speech(text);
      final audioData = Uint8List.fromList(audioBytes);

      // 更新缓存
      _ttsCache[cacheKey] = audioData;
      _cacheTimestamps[cacheKey] = DateTime.now();

      logger.info('TTS音频生成完成', {
        'provider': provider.name,
        'textLength': text.length,
        'audioSize': audioData.length,
      });

      return audioData;
    } catch (e) {
      logger.error('TTS音频生成失败', {
        'provider': provider.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 语音转文字
  Future<String> speechToText({
    required models.AiProvider provider,
    required Uint8List audioData,
    bool useCache = true,
  }) async {
    await initialize();

    final cacheKey = _generateSttCacheKey(provider.id, audioData);

    // 检查缓存
    if (useCache && _isSttCacheValid(cacheKey)) {
      logger.debug('从缓存获取STT文本', {
        'provider': provider.name,
        'audioSize': audioData.length,
      });
      return _sttCache[cacheKey]!;
    }

    logger.info('转换语音为文字', {
      'provider': provider.name,
      'audioSize': audioData.length,
    });

    try {
      // 创建临时助手
      final tempAssistant = _createTempAssistant();

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: tempAssistant,
        modelName: _getSttModel(provider),
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 检查是否支持STT功能
      if (chatProvider is! SpeechToTextCapability) {
        throw Exception('提供商不支持STT功能: ${provider.name}');
      }

      final sttProvider = chatProvider as SpeechToTextCapability;
      final transcription = await sttProvider.transcribe(audioData);

      // 更新缓存
      _sttCache[cacheKey] = transcription;
      _cacheTimestamps[cacheKey] = DateTime.now();

      logger.info('STT转换完成', {
        'provider': provider.name,
        'audioSize': audioData.length,
        'textLength': transcription.length,
      });

      return transcription;
    } catch (e) {
      logger.error('STT转换失败', {
        'provider': provider.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 从文件路径进行语音转文字
  Future<String> speechToTextFromFile({
    required models.AiProvider provider,
    required String filePath,
    bool useCache = true,
  }) async {
    await initialize();

    logger.info('从文件转换语音为文字', {
      'provider': provider.name,
      'filePath': filePath,
    });

    try {
      // 创建临时助手
      final tempAssistant = _createTempAssistant();

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: tempAssistant,
        modelName: _getSttModel(provider),
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 检查是否支持STT功能
      if (chatProvider is! SpeechToTextCapability) {
        throw Exception('提供商不支持STT功能: ${provider.name}');
      }

      final sttProvider = chatProvider as SpeechToTextCapability;
      final transcription = await sttProvider.transcribeFile(filePath);

      logger.info('文件STT转换完成', {
        'provider': provider.name,
        'filePath': filePath,
        'textLength': transcription.length,
      });

      return transcription;
    } catch (e) {
      logger.error('文件STT转换失败', {
        'provider': provider.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 检查提供商是否支持TTS
  bool supportsTts(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
      case 'elevenlabs':
        return true;
      default:
        return false;
    }
  }

  /// 检查提供商是否支持STT
  bool supportsStt(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return true;
      default:
        return false;
    }
  }

  /// 获取支持的语音列表
  List<String> getSupportedVoices(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];
      case 'elevenlabs':
        return [
          'rachel',
          'domi',
          'bella',
          'antoni',
          'elli',
          'josh',
          'arnold',
          'adam',
          'sam',
        ];
      default:
        return [];
    }
  }

  /// 清除语音缓存
  void clearCache([String? providerId]) {
    if (providerId != null) {
      final keysToRemove = [
        ..._ttsCache.keys.where((key) => key.startsWith('tts_${providerId}_')),
        ..._sttCache.keys.where((key) => key.startsWith('stt_${providerId}_')),
      ];

      for (final key in keysToRemove) {
        _ttsCache.remove(key);
        _sttCache.remove(key);
        _cacheTimestamps.remove(key);
      }

      logger.debug('清除提供商语音缓存', {'provider': providerId});
    } else {
      _ttsCache.clear();
      _sttCache.clear();
      _cacheTimestamps.clear();
      logger.debug('清除所有语音缓存');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'ttsCache': _ttsCache.length,
      'sttCache': _sttCache.length,
      'totalAudioSize': _ttsCache.values.fold<int>(
        0,
        (sum, audio) => sum + audio.length,
      ),
      'cacheTimestamps': _cacheTimestamps.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// 检查TTS缓存是否有效
  bool _isTtsCacheValid(String cacheKey) {
    return _ttsCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < _cacheExpiry;
  }

  /// 检查STT缓存是否有效
  bool _isSttCacheValid(String cacheKey) {
    return _sttCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < _cacheExpiry;
  }

  /// 生成TTS缓存键
  String _generateTtsCacheKey(String providerId, String text, String? voice) {
    final textHash = text.hashCode.toString();
    final voiceHash = voice?.hashCode.toString() ?? 'default';
    return 'tts_${providerId}_${textHash}_$voiceHash';
  }

  /// 生成STT缓存键
  String _generateSttCacheKey(String providerId, Uint8List audioData) {
    final audioHash = audioData.hashCode.toString();
    return 'stt_${providerId}_$audioHash';
  }

  /// 创建临时助手
  AiAssistant _createTempAssistant() {
    return AiAssistant(
      id: 'temp-speech-assistant',
      name: 'Speech Assistant',
      avatar: '🎤',
      systemPrompt: '',
      temperature: 0.0,
      topP: 1.0,
      maxTokens: 1,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: '临时语音助手',
      customHeaders: {},
      customBody: {},
      stopSequences: [],
      frequencyPenalty: 0.0,
      presencePenalty: 0.0,
      enableCodeExecution: false,
      enableImageGeneration: false,
      enableTools: false,
      enableReasoning: false,
      enableVision: false,
      enableEmbedding: false,
    );
  }

  /// 获取TTS模型
  String _getTtsModel(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return 'tts-1';
      case 'elevenlabs':
        return 'eleven_multilingual_v2';
      default:
        return 'default-tts-model';
    }
  }

  /// 获取STT模型
  String _getSttModel(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return 'whisper-1';
      default:
        return 'default-stt-model';
    }
  }
}
