import 'dart:async';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../core/ai_service_base.dart';
import 'http_configuration_service.dart' as http_config;
import 'package:llm_dart/llm_dart.dart';

/// 增强的聊天配置服务 - 集成高级功能的聊天配置管理
///
/// 这个服务专门处理聊天配置的高级功能，参考llm_dart示例：
/// - 🌐 **HTTP代理配置**：支持企业代理环境
/// - 🔍 **Web搜索集成**：自动启用搜索功能
/// - 🎨 **图像生成集成**：支持图像生成能力
/// - 🎵 **语音功能集成**：TTS/STT功能配置
/// - ⏱️ **超时和重试配置**：网络优化设置
/// - 📊 **日志和监控配置**：调试和性能监控
///
/// ## 参考llm_dart示例的配置方式
///
/// ### 基础聊天配置
/// ```dart
/// final provider = await ai()
///     .openai()
///     .apiKey(apiKey)
///     .model('gpt-4o-mini')
///     .build();
/// ```
///
/// ### 带Web搜索的配置
/// ```dart
/// final provider = await ai()
///     .xai()
///     .apiKey(apiKey)
///     .model('grok-3')
///     .enableWebSearch()
///     .build();
/// ```
///
/// ### 综合高级配置
/// ```dart
/// final provider = await ai()
///     .openai()
///     .apiKey(apiKey)
///     .model('gpt-4o-mini')
///     .http((http) => http
///         .proxy('http://proxy.company.com:8080')
///         .headers({'X-Custom-Header': 'value'})
///         .connectionTimeout(Duration(seconds: 30))
///         .enableLogging(true))
///     .temperature(0.7)
///     .maxTokens(1000)
///     .build();
/// ```
class EnhancedChatConfigurationService extends AiServiceBase {
  // 单例模式实现
  static final EnhancedChatConfigurationService _instance = 
      EnhancedChatConfigurationService._internal();
  factory EnhancedChatConfigurationService() => _instance;
  EnhancedChatConfigurationService._internal();

  /// HTTP配置服务
  final http_config.HttpConfigurationService _httpConfigService = http_config.HttpConfigurationService();

  /// 配置缓存
  final Map<String, EnhancedChatConfig> _configCache = {};

  /// 服务初始化状态
  bool _isInitialized = false;

  @override
  String get serviceName => 'EnhancedChatConfigurationService';

  @override
  Set<AiCapability> get supportedCapabilities => {
        AiCapability.chat,
        AiCapability.webSearch,
        AiCapability.imageGeneration,
        AiCapability.textToSpeech,
        AiCapability.speechToText,
        AiCapability.httpConfiguration,
      };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化增强聊天配置服务');
    await _httpConfigService.initialize();
    _isInitialized = true;
    logger.info('增强聊天配置服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理增强聊天配置服务资源');
    _configCache.clear();
    await _httpConfigService.dispose();
    _isInitialized = false;
  }

  /// 创建增强聊天配置
  ///
  /// 根据提供商、助手和高级选项创建完整的聊天配置
  Future<EnhancedChatConfig> createEnhancedConfig({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    
    // HTTP配置选项
    String? proxyUrl,
    Duration? connectionTimeout,
    Duration? receiveTimeout,
    Map<String, String>? customHeaders,
    bool enableHttpLogging = false,
    
    // 功能配置选项
    bool enableWebSearch = false,
    bool enableImageGeneration = false,
    bool enableTTS = false,
    bool enableSTT = false,
    
    // Web搜索配置
    int? maxSearchResults,
    List<String>? allowedDomains,
    String? searchLanguage,
    
    // 图像生成配置
    String? imageSize,
    String? imageQuality,
    
    // 语音配置
    String? ttsVoice,
    String? sttLanguage,
  }) async {
    await initialize();

    final configId = _generateConfigId(provider.id, assistant.id, modelName);

    logger.info('创建增强聊天配置', {
      'configId': configId,
      'provider': provider.name,
      'assistant': assistant.name,
      'model': modelName,
      'enableWebSearch': enableWebSearch,
      'enableImageGeneration': enableImageGeneration,
      'hasProxy': proxyUrl != null,
    });

    // 创建HTTP配置
    final httpConfig = _httpConfigService.createHttpConfig(
      provider: provider,
      proxyUrl: proxyUrl,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      customHeaders: customHeaders,
      enableLogging: enableHttpLogging,
    );

    // 创建增强配置
    final enhancedConfig = EnhancedChatConfig(
      id: configId,
      provider: provider,
      assistant: assistant,
      modelName: modelName,
      httpConfig: httpConfig,
      
      // 功能开关
      enableWebSearch: enableWebSearch,
      enableImageGeneration: enableImageGeneration,
      enableTTS: enableTTS,
      enableSTT: enableSTT,
      
      // Web搜索配置
      webSearchConfig: enableWebSearch ? WebSearchConfig(
        maxResults: maxSearchResults ?? 5,
        allowedDomains: allowedDomains,
        language: searchLanguage,
      ) : null,
      
      // 图像生成配置
      imageGenerationConfig: enableImageGeneration ? ImageGenerationConfig(
        size: imageSize ?? '1024x1024',
        quality: imageQuality ?? 'standard',
      ) : null,
      
      // 语音配置
      speechConfig: (enableTTS || enableSTT) ? SpeechConfig(
        ttsVoice: ttsVoice,
        sttLanguage: sttLanguage,
      ) : null,
      
      createdAt: DateTime.now(),
    );

    // 缓存配置
    _configCache[configId] = enhancedConfig;

    return enhancedConfig;
  }

  /// 获取增强聊天配置
  EnhancedChatConfig? getEnhancedConfig(String configId) {
    return _configCache[configId];
  }

  /// 更新增强聊天配置
  void updateEnhancedConfig(String configId, EnhancedChatConfig config) {
    _configCache[configId] = config;
    
    logger.info('更新增强聊天配置', {
      'configId': configId,
      'enableWebSearch': config.enableWebSearch,
      'enableImageGeneration': config.enableImageGeneration,
    });
  }

  /// 应用增强配置到LLM配置
  ///
  /// 将增强配置转换为LLM Dart可用的配置
  LLMConfig applyEnhancedConfigToLLMConfig(
    LLMConfig baseConfig,
    EnhancedChatConfig enhancedConfig,
  ) {
    // 应用HTTP配置
    var config = _httpConfigService.applyHttpConfigToLLMConfig(
      baseConfig,
      enhancedConfig.httpConfig,
    );

    final extensions = Map<String, dynamic>.from(config.extensions ?? {});

    // 应用Web搜索配置
    if (enhancedConfig.enableWebSearch && enhancedConfig.webSearchConfig != null) {
      extensions['enableWebSearch'] = true;
      extensions['webSearchMaxResults'] = enhancedConfig.webSearchConfig!.maxResults;
      if (enhancedConfig.webSearchConfig!.allowedDomains != null) {
        extensions['webSearchAllowedDomains'] = enhancedConfig.webSearchConfig!.allowedDomains;
      }
      if (enhancedConfig.webSearchConfig!.language != null) {
        extensions['webSearchLanguage'] = enhancedConfig.webSearchConfig!.language;
      }
    }

    // 应用图像生成配置
    if (enhancedConfig.enableImageGeneration && enhancedConfig.imageGenerationConfig != null) {
      extensions['enableImageGeneration'] = true;
      extensions['imageSize'] = enhancedConfig.imageGenerationConfig!.size;
      extensions['imageQuality'] = enhancedConfig.imageGenerationConfig!.quality;
    }

    // 应用语音配置
    if (enhancedConfig.speechConfig != null) {
      if (enhancedConfig.enableTTS) {
        extensions['enableTTS'] = true;
        if (enhancedConfig.speechConfig!.ttsVoice != null) {
          extensions['ttsVoice'] = enhancedConfig.speechConfig!.ttsVoice;
        }
      }
      if (enhancedConfig.enableSTT) {
        extensions['enableSTT'] = true;
        if (enhancedConfig.speechConfig!.sttLanguage != null) {
          extensions['sttLanguage'] = enhancedConfig.speechConfig!.sttLanguage;
        }
      }
    }

    return config.withExtensions(extensions);
  }

  /// 验证增强配置
  bool validateEnhancedConfig(EnhancedChatConfig config) {
    try {
      // 验证HTTP配置
      if (!_httpConfigService.validateHttpConfig(config.httpConfig)) {
        return false;
      }

      // 验证Web搜索配置
      if (config.enableWebSearch && config.webSearchConfig != null) {
        if (config.webSearchConfig!.maxResults <= 0) {
          logger.warning('无效的Web搜索结果数量', {
            'maxResults': config.webSearchConfig!.maxResults,
          });
          return false;
        }
      }

      // 验证图像生成配置
      if (config.enableImageGeneration && config.imageGenerationConfig != null) {
        final validSizes = ['256x256', '512x512', '1024x1024', '1792x1024', '1024x1792'];
        if (!validSizes.contains(config.imageGenerationConfig!.size)) {
          logger.warning('无效的图像尺寸', {
            'size': config.imageGenerationConfig!.size,
            'validSizes': validSizes,
          });
          return false;
        }
      }

      logger.debug('增强配置验证通过', {'configId': config.id});
      return true;
    } catch (e) {
      logger.error('增强配置验证失败', {
        'configId': config.id,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 生成配置ID
  String _generateConfigId(String providerId, String assistantId, String modelName) {
    return '${providerId}_${assistantId}_${modelName}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取所有增强配置
  Map<String, EnhancedChatConfig> getAllEnhancedConfigs() => Map.from(_configCache);

  /// 清除配置缓存
  void clearConfigCache([String? configId]) {
    if (configId != null) {
      _configCache.remove(configId);
      logger.debug('清除增强配置', {'configId': configId});
    } else {
      _configCache.clear();
      logger.debug('清除所有增强配置');
    }
  }

  /// 获取配置统计信息
  Map<String, dynamic> getConfigStats() {
    final stats = <String, dynamic>{};
    
    stats['totalConfigs'] = _configCache.length;
    stats['configsWithWebSearch'] = _configCache.values
        .where((config) => config.enableWebSearch)
        .length;
    stats['configsWithImageGeneration'] = _configCache.values
        .where((config) => config.enableImageGeneration)
        .length;
    stats['configsWithTTS'] = _configCache.values
        .where((config) => config.enableTTS)
        .length;
    stats['configsWithSTT'] = _configCache.values
        .where((config) => config.enableSTT)
        .length;

    return stats;
  }
}

/// 增强聊天配置类
class EnhancedChatConfig {
  final String id;
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final http_config.HttpConfig httpConfig;

  // 功能开关
  final bool enableWebSearch;
  final bool enableImageGeneration;
  final bool enableTTS;
  final bool enableSTT;

  // 功能配置
  final WebSearchConfig? webSearchConfig;
  final ImageGenerationConfig? imageGenerationConfig;
  final SpeechConfig? speechConfig;

  final DateTime createdAt;

  const EnhancedChatConfig({
    required this.id,
    required this.provider,
    required this.assistant,
    required this.modelName,
    required this.httpConfig,
    required this.enableWebSearch,
    required this.enableImageGeneration,
    required this.enableTTS,
    required this.enableSTT,
    this.webSearchConfig,
    this.imageGenerationConfig,
    this.speechConfig,
    required this.createdAt,
  });

  EnhancedChatConfig copyWith({
    String? id,
    models.AiProvider? provider,
    AiAssistant? assistant,
    String? modelName,
    http_config.HttpConfig? httpConfig,
    bool? enableWebSearch,
    bool? enableImageGeneration,
    bool? enableTTS,
    bool? enableSTT,
    WebSearchConfig? webSearchConfig,
    ImageGenerationConfig? imageGenerationConfig,
    SpeechConfig? speechConfig,
    DateTime? createdAt,
  }) {
    return EnhancedChatConfig(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      assistant: assistant ?? this.assistant,
      modelName: modelName ?? this.modelName,
      httpConfig: httpConfig ?? this.httpConfig,
      enableWebSearch: enableWebSearch ?? this.enableWebSearch,
      enableImageGeneration: enableImageGeneration ?? this.enableImageGeneration,
      enableTTS: enableTTS ?? this.enableTTS,
      enableSTT: enableSTT ?? this.enableSTT,
      webSearchConfig: webSearchConfig ?? this.webSearchConfig,
      imageGenerationConfig: imageGenerationConfig ?? this.imageGenerationConfig,
      speechConfig: speechConfig ?? this.speechConfig,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Web搜索配置类
class WebSearchConfig {
  final int maxResults;
  final List<String>? allowedDomains;
  final String? language;

  const WebSearchConfig({
    required this.maxResults,
    this.allowedDomains,
    this.language,
  });
}

/// 图像生成配置类
class ImageGenerationConfig {
  final String size;
  final String quality;

  const ImageGenerationConfig({
    required this.size,
    required this.quality,
  });
}

/// 语音配置类
class SpeechConfig {
  final String? ttsVoice;
  final String? sttLanguage;

  const SpeechConfig({
    this.ttsVoice,
    this.sttLanguage,
  });
}
