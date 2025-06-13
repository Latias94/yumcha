import 'dart:async';
import 'dart:typed_data';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../core/ai_service_base.dart';
import '../core/ai_response_models.dart';
import 'package:llm_dart/llm_dart.dart';

/// 图像生成服务 - 处理AI图像创作功能
///
/// 这个服务专门处理AI图像生成功能，包括：
/// - 🎨 **文本到图像**：根据文本描述生成图像
/// - 🖼️ **图像编辑**：修改现有图像
/// - 🎭 **风格转换**：改变图像风格
/// - 📐 **尺寸控制**：生成不同尺寸的图像
///
/// ## 支持的提供商
/// - **OpenAI DALL-E**：高质量图像生成
/// - **Stability AI**：开源图像生成
/// - **Midjourney**：艺术风格图像
///
/// ## 使用示例
/// ```dart
/// final imageService = ImageGenerationService();
/// await imageService.initialize();
///
/// final result = await imageService.generateImage(
///   provider: provider,
///   prompt: 'A beautiful sunset over mountains',
///   size: '1024x1024',
///   quality: 'hd',
/// );
/// ```
class ImageGenerationService extends AiServiceBase {
  // 单例模式实现
  static final ImageGenerationService _instance = ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  /// 图像生成统计信息
  final Map<String, ImageGenerationStats> _stats = {};

  /// 服务初始化状态
  bool _isInitialized = false;

  @override
  String get serviceName => 'ImageGenerationService';

  @override
  Set<AiCapability> get supportedCapabilities => {
        AiCapability.imageGeneration,
      };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化图像生成服务');
    _isInitialized = true;
    logger.info('图像生成服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理图像生成服务资源');
    _stats.clear();
    _isInitialized = false;
  }

  /// 生成图像
  ///
  /// 根据文本提示生成图像
  Future<ImageGenerationResponse> generateImage({
    required models.AiProvider provider,
    required String prompt,
    String? size = '1024x1024',
    String? quality = 'standard',
    String? style = 'natural',
    int count = 1,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    logger.info('开始图像生成', {
      'requestId': requestId,
      'provider': provider.name,
      'prompt': prompt,
      'size': size,
      'quality': quality,
      'count': count,
    });

    try {
      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: _createDefaultAssistant(),
        modelName: _getImageModel(provider),
      );

      final chatProvider = await adapter.createProvider();

      // 检查是否支持图像生成
      if (chatProvider is! ImageGenerationCapability) {
        throw UnsupportedError('提供商 ${provider.name} 不支持图像生成功能');
      }

      // 执行图像生成
      final request = ImageGenerationRequest(
        prompt: prompt,
        size: size ?? '1024x1024',
        count: count,
        quality: quality,
        style: style,
      );

      final result = await (chatProvider as ImageGenerationCapability).generateImages(request);
      final duration = DateTime.now().difference(startTime);

      // 更新统计信息
      _updateStats(provider.id, true, duration, result.images.length);

      logger.info('图像生成完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'imageCount': result.images.length,
      });

      return ImageGenerationResponse(
        images: result.images.map((img) => GeneratedImage(
          url: img.url,
          base64: img.base64,
          revisedPrompt: img.revisedPrompt,
        )).toList(),
        duration: duration,
        isSuccess: true,
        usage: result.usage,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, false, duration, 0);

      logger.error('图像生成失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return ImageGenerationResponse(
        images: [],
        duration: duration,
        isSuccess: false,
        error: '图像生成失败: $e',
      );
    }
  }

  /// 检查提供商是否支持图像生成
  bool supportsImageGeneration(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
      case 'stability':
      case 'midjourney':
        return true;
      default:
        return false;
    }
  }

  /// 获取支持的图像尺寸
  List<String> getSupportedSizes(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return ['256x256', '512x512', '1024x1024', '1792x1024', '1024x1792'];
      case 'stability':
        return ['512x512', '768x768', '1024x1024', '1536x1536'];
      default:
        return ['1024x1024'];
    }
  }

  /// 获取支持的图像质量选项
  List<String> getSupportedQualities(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return ['standard', 'hd'];
      default:
        return ['standard'];
    }
  }

  /// 创建默认助手配置
  AiAssistant _createDefaultAssistant() {
    return AiAssistant(
      id: 'image-generation-assistant',
      name: 'Image Generation Assistant',
      avatar: '🎨',
      systemPrompt: '',
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 1000,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Assistant for image generation tasks',
      customHeaders: {},
      customBody: {},
      stopSequences: [],
      frequencyPenalty: 0.0,
      presencePenalty: 0.0,
      enableCodeExecution: false,
      enableImageGeneration: true,
      enableTools: false,
      enableReasoning: false,
      enableVision: false,
      enableEmbedding: false,
    );
  }

  /// 获取图像生成模型
  String _getImageModel(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return 'dall-e-3';
      case 'stability':
        return 'stable-diffusion-xl';
      default:
        return 'default-image-model';
    }
  }

  /// 更新统计信息
  void _updateStats(String providerId, bool success, Duration duration, int imageCount) {
    final currentStats = _stats[providerId] ?? ImageGenerationStats();

    _stats[providerId] = ImageGenerationStats(
      totalRequests: currentStats.totalRequests + 1,
      successfulRequests: success
          ? currentStats.successfulRequests + 1
          : currentStats.successfulRequests,
      failedRequests: success
          ? currentStats.failedRequests
          : currentStats.failedRequests + 1,
      totalDuration: currentStats.totalDuration + duration,
      totalImagesGenerated: currentStats.totalImagesGenerated + imageCount,
      lastRequestTime: DateTime.now(),
    );
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'image_gen_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取图像生成统计信息
  Map<String, ImageGenerationStats> getImageGenerationStats() => Map.from(_stats);

  /// 清除统计信息
  void clearStats([String? providerId]) {
    if (providerId != null) {
      _stats.remove(providerId);
    } else {
      _stats.clear();
    }
  }
}

/// 图像生成响应
class ImageGenerationResponse {
  final List<GeneratedImage> images;
  final Duration duration;
  final bool isSuccess;
  final String? error;
  final UsageInfo? usage;

  const ImageGenerationResponse({
    required this.images,
    required this.duration,
    required this.isSuccess,
    this.error,
    this.usage,
  });
}

/// 生成的图像
class GeneratedImage {
  final String? url;
  final String? base64;
  final String? revisedPrompt;

  const GeneratedImage({
    this.url,
    this.base64,
    this.revisedPrompt,
  });
}

/// 图像生成统计信息
class ImageGenerationStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final Duration totalDuration;
  final int totalImagesGenerated;
  final DateTime? lastRequestTime;

  const ImageGenerationStats({
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.totalDuration = Duration.zero,
    this.totalImagesGenerated = 0,
    this.lastRequestTime,
  });

  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;
  Duration get averageDuration => totalRequests > 0
      ? Duration(microseconds: totalDuration.inMicroseconds ~/ totalRequests)
      : Duration.zero;
  double get averageImagesPerRequest => totalRequests > 0
      ? totalImagesGenerated / totalRequests
      : 0.0;
}
