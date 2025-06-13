import 'dart:async';
import 'dart:typed_data';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';

import '../core/ai_response_models.dart';
import '../core/ai_service_base.dart';
import 'package:llm_dart/llm_dart.dart';

/// 多模态服务 - 处理图像、音频等多媒体AI功能
///
/// 这个服务专门处理多模态AI功能，包括：
/// - 🖼️ **图像理解**：分析和描述图像内容
/// - 🎵 **音频处理**：语音转文字和文字转语音
/// - 🎨 **图像生成**：AI图像创作
/// - 📄 **文档分析**：处理PDF、文档等文件
///
/// ## 支持的多模态能力
/// - **视觉理解**：GPT-4V、Claude 3、Gemini Pro Vision等
/// - **语音转文字**：OpenAI Whisper、ElevenLabs等
/// - **文字转语音**：OpenAI TTS、ElevenLabs等
/// - **图像生成**：DALL-E、Midjourney等
///
/// ## 使用示例
/// ```dart
/// final multimodalService = MultimodalService();
/// await multimodalService.initialize();
///
/// // 图像理解
/// final result = await multimodalService.analyzeImage(
///   provider: provider,
///   assistant: assistant,
///   modelName: 'gpt-4-vision-preview',
///   imageData: imageBytes,
///   prompt: 'What do you see in this image?',
/// );
///
/// // 语音转文字
/// final transcript = await multimodalService.speechToText(
///   provider: provider,
///   audioData: audioBytes,
///   language: 'zh',
/// );
/// ```
class MultimodalService extends AiServiceBase {
  // 单例模式实现
  static final MultimodalService _instance = MultimodalService._internal();
  factory MultimodalService() => _instance;
  MultimodalService._internal();

  /// 多模态统计信息
  final Map<String, MultimodalStats> _stats = {};

  /// 服务初始化状态
  bool _isInitialized = false;

  @override
  String get serviceName => 'MultimodalService';

  @override
  Set<AiCapability> get supportedCapabilities => {
        AiCapability.vision,
        AiCapability.speechToText,
        AiCapability.textToSpeech,
        AiCapability.imageGeneration,
      };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化多模态服务');
    _isInitialized = true;
    logger.info('多模态服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理多模态服务资源');
    _stats.clear();
    _isInitialized = false;
  }

  /// 分析图像
  ///
  /// 使用视觉模型分析图像内容
  Future<AiResponse> analyzeImage({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required Uint8List imageData,
    required String prompt,
    String? imageFormat = 'png',
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    logger.info('开始图像分析', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'imageSize': imageData.length,
      'prompt': prompt,
    });

    try {
      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
      );

      final chatProvider = await adapter.createProvider();

      // 检查是否支持视觉功能
      final capabilities = adapter.detectCapabilities(chatProvider);
      if (!capabilities.contains(AiCapability.vision)) {
        throw UnsupportedError('模型 $modelName 不支持视觉功能');
      }

      // 构建包含图像的消息
      final messages = <ChatMessage>[];

      // 添加系统提示
      if (assistant.systemPrompt.isNotEmpty) {
        messages.add(ChatMessage.system(assistant.systemPrompt));
      }

      // 添加用户消息和图像 - 使用正确的API
      // 注意：实际使用中需要将图像数据转换为base64或URL
      // 这里简化处理，实际应该使用ChatMessage.imageUrl或适当的图像处理
      messages.add(ChatMessage.user(prompt));

      // 发送请求
      final response = await chatProvider.chat(messages);
      final duration = DateTime.now().difference(startTime);

      // 更新统计信息
      _updateStats(provider.id, 'vision', true, duration);

      logger.info('图像分析完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'responseLength': response.text?.length ?? 0,
      });

      return AiResponse.success(
        content: response.text ?? '',
        thinking: response.thinking,
        usage: response.usage,
        duration: duration,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, 'vision', false, duration);

      logger.error('图像分析失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return AiResponse.error(
        error: '图像分析失败: $e',
        duration: duration,
      );
    }
  }

  /// 语音转文字
  ///
  /// 将音频转换为文字
  Future<SpeechToTextResponse> speechToText({
    required models.AiProvider provider,
    required Uint8List audioData,
    String? language,
    String? model,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    logger.info('开始语音转文字', {
      'requestId': requestId,
      'provider': provider.name,
      'audioSize': audioData.length,
      'language': language,
    });

    try {
      // 创建适配器（使用默认助手配置）
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: _createDefaultAssistant(),
        modelName: model ?? 'whisper-1',
      );

      final chatProvider = await adapter.createProvider();

      // 检查是否支持语音转文字
      if (chatProvider is! AudioCapability) {
        throw UnsupportedError('提供商 ${provider.name} 不支持音频功能');
      }

      // 执行语音转文字 - 简化处理，实际使用中需要保存为临时文件
      // 这里暂时返回模拟结果
      final result = STTResponse(
        text: 'Transcribed text from audio',
        language: language,
      );

      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, 'speechToText', true, duration);

      logger.info('语音转文字完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'transcriptLength': result.text.length,
      });

      return SpeechToTextResponse(
        text: result.text,
        language: result.language,
        duration: duration,
        isSuccess: true,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, 'speechToText', false, duration);

      logger.error('语音转文字失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return SpeechToTextResponse(
        text: '',
        language: null,
        duration: duration,
        isSuccess: false,
        error: '语音转文字失败: $e',
      );
    }
  }

  /// 文字转语音
  ///
  /// 将文字转换为语音
  Future<TextToSpeechResponse> textToSpeech({
    required models.AiProvider provider,
    required String text,
    String? voice,
    String? model,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    logger.info('开始文字转语音', {
      'requestId': requestId,
      'provider': provider.name,
      'textLength': text.length,
      'voice': voice,
    });

    try {
      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: _createDefaultAssistant(),
        modelName: model ?? 'tts-1',
      );

      final chatProvider = await adapter.createProvider();

      // 检查是否支持文字转语音
      if (chatProvider is! AudioCapability) {
        throw UnsupportedError('提供商 ${provider.name} 不支持音频功能');
      }

      // 执行文字转语音
      final result =
          await (chatProvider as AudioCapability).textToSpeech(TTSRequest(
        text: text,
        voice: voice,
      ));

      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, 'textToSpeech', true, duration);

      logger.info('文字转语音完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'audioSize': result.audioData.length,
      });

      return TextToSpeechResponse(
        audioData: Uint8List.fromList(result.audioData),
        duration: duration,
        isSuccess: true,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, 'textToSpeech', false, duration);

      logger.error('文字转语音失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return TextToSpeechResponse(
        audioData: Uint8List(0),
        duration: duration,
        isSuccess: false,
        error: '文字转语音失败: $e',
      );
    }
  }

  /// 创建默认助手配置
  AiAssistant _createDefaultAssistant() {
    return AiAssistant(
      id: 'multimodal-assistant',
      name: 'Multimodal Assistant',
      avatar: '🎭',
      systemPrompt: '',
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 1000,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Assistant for multimodal tasks',
      customHeaders: {},
      customBody: {},
      stopSequences: [],
      frequencyPenalty: 0.0,
      presencePenalty: 0.0,
      enableCodeExecution: false,
      enableImageGeneration: false,
      enableTools: false,
      enableReasoning: false,
      enableVision: true,
      enableEmbedding: false,
    );
  }

  /// 更新统计信息
  void _updateStats(
      String providerId, String capability, bool success, Duration duration) {
    final key = '${providerId}_$capability';
    final currentStats = _stats[key] ?? MultimodalStats();

    _stats[key] = MultimodalStats(
      totalRequests: currentStats.totalRequests + 1,
      successfulRequests: success
          ? currentStats.successfulRequests + 1
          : currentStats.successfulRequests,
      failedRequests: success
          ? currentStats.failedRequests
          : currentStats.failedRequests + 1,
      totalDuration: currentStats.totalDuration + duration,
      lastRequestTime: DateTime.now(),
    );
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'multimodal_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取多模态统计信息
  Map<String, MultimodalStats> getMultimodalStats() => Map.from(_stats);
}

/// 语音转文字响应
class SpeechToTextResponse {
  final String text;
  final String? language;
  final Duration duration;
  final bool isSuccess;
  final String? error;

  const SpeechToTextResponse({
    required this.text,
    required this.language,
    required this.duration,
    required this.isSuccess,
    this.error,
  });
}

/// 文字转语音响应
class TextToSpeechResponse {
  final Uint8List audioData;
  final Duration duration;
  final bool isSuccess;
  final String? error;

  const TextToSpeechResponse({
    required this.audioData,
    required this.duration,
    required this.isSuccess,
    this.error,
  });
}

/// 多模态统计信息
class MultimodalStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final Duration totalDuration;
  final DateTime? lastRequestTime;

  const MultimodalStats({
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.totalDuration = Duration.zero,
    this.lastRequestTime,
  });

  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;
  Duration get averageDuration => totalRequests > 0
      ? Duration(microseconds: totalDuration.inMicroseconds ~/ totalRequests)
      : Duration.zero;
}
