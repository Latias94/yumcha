import 'dart:async';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../core/ai_service_base.dart';
import 'package:llm_dart/llm_dart.dart';

/// HTTP配置服务 - 处理AI提供商的HTTP配置
///
/// 这个服务专门处理AI提供商的HTTP配置，包括：
/// - 🌐 **代理配置**：HTTP/HTTPS代理设置
/// - ⏱️ **超时配置**：连接、接收、发送超时
/// - 🔒 **SSL配置**：证书验证、自定义证书
/// - 📋 **请求头配置**：自定义HTTP头
/// - 📊 **日志配置**：HTTP请求/响应日志
///
/// ## 参考llm_dart示例的配置方式
/// 
/// ### 基础配置
/// ```dart
/// final provider = await ai()
///     .openai()
///     .apiKey(apiKey)
///     .model('gpt-4o-mini')
///     .timeout(Duration(seconds: 30))
///     .build();
/// ```
///
/// ### 代理配置
/// ```dart
/// final provider = await ai()
///     .openai()
///     .apiKey(apiKey)
///     .http((http) => http.proxy('http://proxy.company.com:8080'))
///     .build();
/// ```
///
/// ### 综合配置
/// ```dart
/// final provider = await ai()
///     .openai()
///     .apiKey(apiKey)
///     .http((http) => http
///         .headers({'X-Custom-Header': 'value'})
///         .connectionTimeout(Duration(seconds: 30))
///         .enableLogging(true))
///     .build();
/// ```
class HttpConfigurationService extends AiServiceBase {
  // 单例模式实现
  static final HttpConfigurationService _instance = HttpConfigurationService._internal();
  factory HttpConfigurationService() => _instance;
  HttpConfigurationService._internal();

  /// HTTP配置缓存
  final Map<String, HttpConfig> _configCache = {};

  /// 服务初始化状态
  bool _isInitialized = false;

  @override
  String get serviceName => 'HttpConfigurationService';

  @override
  Set<AiCapability> get supportedCapabilities => {
        AiCapability.httpConfiguration,
      };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化HTTP配置服务');
    _isInitialized = true;
    logger.info('HTTP配置服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理HTTP配置服务资源');
    _configCache.clear();
    _isInitialized = false;
  }

  /// 创建HTTP配置
  ///
  /// 根据提供商和配置参数创建HTTP配置
  HttpConfig createHttpConfig({
    required models.AiProvider provider,
    String? proxyUrl,
    Duration? connectionTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? customHeaders,
    bool enableLogging = false,
    bool bypassSSLVerification = false,
    String? sslCertificatePath,
  }) {
    final config = HttpConfig(
      providerId: provider.id,
      baseUrl: provider.baseUrl,
      proxyUrl: proxyUrl,
      connectionTimeout: connectionTimeout ?? Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? Duration(minutes: 2),
      sendTimeout: sendTimeout ?? Duration(minutes: 2),
      customHeaders: customHeaders ?? {},
      enableLogging: enableLogging,
      bypassSSLVerification: bypassSSLVerification,
      sslCertificatePath: sslCertificatePath,
    );

    // 缓存配置
    _configCache[provider.id] = config;

    logger.info('创建HTTP配置', {
      'providerId': provider.id,
      'hasProxy': proxyUrl != null,
      'connectionTimeout': connectionTimeout?.inSeconds,
      'enableLogging': enableLogging,
    });

    return config;
  }

  /// 获取提供商的HTTP配置
  HttpConfig? getHttpConfig(String providerId) {
    return _configCache[providerId];
  }

  /// 更新HTTP配置
  void updateHttpConfig(String providerId, HttpConfig config) {
    _configCache[providerId] = config;
    
    logger.info('更新HTTP配置', {
      'providerId': providerId,
      'hasProxy': config.proxyUrl != null,
      'enableLogging': config.enableLogging,
    });
  }

  /// 清除HTTP配置
  void clearHttpConfig([String? providerId]) {
    if (providerId != null) {
      _configCache.remove(providerId);
      logger.debug('清除提供商HTTP配置', {'providerId': providerId});
    } else {
      _configCache.clear();
      logger.debug('清除所有HTTP配置');
    }
  }

  /// 验证HTTP配置
  ///
  /// 参考llm_dart的HttpConfigUtils.validateHttpConfig
  bool validateHttpConfig(HttpConfig config) {
    try {
      // 验证代理URL格式
      if (config.proxyUrl != null) {
        final uri = Uri.tryParse(config.proxyUrl!);
        if (uri == null || (!uri.scheme.startsWith('http'))) {
          logger.warning('无效的代理URL格式', {'proxyUrl': config.proxyUrl});
          return false;
        }
      }

      // 验证超时设置
      if (config.connectionTimeout.inSeconds <= 0 ||
          config.receiveTimeout.inSeconds <= 0 ||
          config.sendTimeout.inSeconds <= 0) {
        logger.warning('无效的超时设置', {
          'connectionTimeout': config.connectionTimeout.inSeconds,
          'receiveTimeout': config.receiveTimeout.inSeconds,
          'sendTimeout': config.sendTimeout.inSeconds,
        });
        return false;
      }

      // SSL验证警告
      if (config.bypassSSLVerification) {
        logger.warning('SSL验证已禁用 - 仅用于开发环境', {
          'providerId': config.providerId,
        });
      }

      logger.debug('HTTP配置验证通过', {'providerId': config.providerId});
      return true;
    } catch (e) {
      logger.error('HTTP配置验证失败', {
        'providerId': config.providerId,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 应用HTTP配置到LLM配置
  ///
  /// 将HTTP配置应用到LLMConfig中，参考llm_dart的配置方式
  LLMConfig applyHttpConfigToLLMConfig(
    LLMConfig baseConfig,
    HttpConfig httpConfig,
  ) {
    final extensions = <String, dynamic>{};

    // 添加代理配置
    if (httpConfig.proxyUrl != null) {
      extensions['httpProxy'] = httpConfig.proxyUrl;
    }

    // 添加超时配置
    extensions['connectionTimeout'] = httpConfig.connectionTimeout;
    extensions['receiveTimeout'] = httpConfig.receiveTimeout;
    extensions['sendTimeout'] = httpConfig.sendTimeout;

    // 添加自定义头
    if (httpConfig.customHeaders.isNotEmpty) {
      extensions['customHeaders'] = httpConfig.customHeaders;
    }

    // 添加日志配置
    extensions['enableLogging'] = httpConfig.enableLogging;

    // 添加SSL配置
    if (httpConfig.bypassSSLVerification) {
      extensions['bypassSSLVerification'] = true;
    }

    if (httpConfig.sslCertificatePath != null) {
      extensions['sslCertificate'] = httpConfig.sslCertificatePath;
    }

    return baseConfig.withExtensions(extensions);
  }

  /// 获取所有HTTP配置
  Map<String, HttpConfig> getAllHttpConfigs() => Map.from(_configCache);

  /// 获取HTTP配置统计信息
  Map<String, dynamic> getHttpConfigStats() {
    final stats = <String, dynamic>{};
    
    stats['totalConfigs'] = _configCache.length;
    stats['configsWithProxy'] = _configCache.values
        .where((config) => config.proxyUrl != null)
        .length;
    stats['configsWithLogging'] = _configCache.values
        .where((config) => config.enableLogging)
        .length;
    stats['configsWithSSLBypass'] = _configCache.values
        .where((config) => config.bypassSSLVerification)
        .length;

    return stats;
  }
}

/// HTTP配置类
class HttpConfig {
  final String providerId;
  final String baseUrl;
  final String? proxyUrl;
  final Duration connectionTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, String> customHeaders;
  final bool enableLogging;
  final bool bypassSSLVerification;
  final String? sslCertificatePath;

  const HttpConfig({
    required this.providerId,
    required this.baseUrl,
    this.proxyUrl,
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.customHeaders,
    required this.enableLogging,
    required this.bypassSSLVerification,
    this.sslCertificatePath,
  });

  HttpConfig copyWith({
    String? providerId,
    String? baseUrl,
    String? proxyUrl,
    Duration? connectionTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? customHeaders,
    bool? enableLogging,
    bool? bypassSSLVerification,
    String? sslCertificatePath,
  }) {
    return HttpConfig(
      providerId: providerId ?? this.providerId,
      baseUrl: baseUrl ?? this.baseUrl,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      customHeaders: customHeaders ?? this.customHeaders,
      enableLogging: enableLogging ?? this.enableLogging,
      bypassSSLVerification: bypassSSLVerification ?? this.bypassSSLVerification,
      sslCertificatePath: sslCertificatePath ?? this.sslCertificatePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpConfig &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          baseUrl == other.baseUrl &&
          proxyUrl == other.proxyUrl &&
          connectionTimeout == other.connectionTimeout &&
          receiveTimeout == other.receiveTimeout &&
          sendTimeout == other.sendTimeout &&
          enableLogging == other.enableLogging &&
          bypassSSLVerification == other.bypassSSLVerification &&
          sslCertificatePath == other.sslCertificatePath;

  @override
  int get hashCode =>
      providerId.hashCode ^
      baseUrl.hashCode ^
      proxyUrl.hashCode ^
      connectionTimeout.hashCode ^
      receiveTimeout.hashCode ^
      sendTimeout.hashCode ^
      enableLogging.hashCode ^
      bypassSSLVerification.hashCode ^
      sslCertificatePath.hashCode;
}
