import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_provider.dart' as models;
import '../../models/ai_assistant.dart';
import '../../models/message.dart';
import '../../models/ai_model.dart';
import 'core/ai_service_base.dart';
import 'core/ai_response_models.dart';
import 'chat/chat_service.dart';
import 'capabilities/model_service.dart';
import 'capabilities/embedding_service.dart';
import 'capabilities/speech_service.dart';
import '../logger_service.dart';

/// AI服务管理器 - 统一管理所有AI相关服务
class AiServiceManager {
  static final AiServiceManager _instance = AiServiceManager._internal();
  factory AiServiceManager() => _instance;
  AiServiceManager._internal();

  final LoggerService _logger = LoggerService();
  final Map<String, AiServiceBase> _services = {};
  bool _isInitialized = false;

  /// 获取聊天服务
  ChatService get chatService => _getService<ChatService>('chat');

  /// 获取模型服务
  ModelService get modelService => _getService<ModelService>('model');

  /// 获取嵌入服务
  EmbeddingService get embeddingService =>
      _getService<EmbeddingService>('embedding');

  /// 获取语音服务
  SpeechService get speechService => _getService<SpeechService>('speech');

  /// 初始化所有AI服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('初始化AI服务管理器');

    try {
      // 注册核心服务
      _registerService('chat', ChatService());
      _registerService('model', ModelService());
      _registerService('embedding', EmbeddingService());
      _registerService('speech', SpeechService());

      // 初始化所有服务
      for (final service in _services.values) {
        await service.initialize();
      }

      _isInitialized = true;
      _logger.info('AI服务管理器初始化完成', {'services': _services.keys.toList()});
    } catch (e) {
      _logger.error('AI服务管理器初始化失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 清理所有服务资源
  Future<void> dispose() async {
    _logger.info('清理AI服务管理器资源');

    for (final service in _services.values) {
      try {
        await service.dispose();
      } catch (e) {
        _logger.error('服务清理失败', {
          'service': service.serviceName,
          'error': e.toString(),
        });
      }
    }

    _services.clear();
    _isInitialized = false;
    _logger.info('AI服务管理器资源清理完成');
  }

  /// 发送聊天消息
  Future<AiResponse> sendMessage({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    await _ensureInitialized();

    return await chatService.sendMessage(
      provider: provider,
      assistant: assistant,
      modelName: modelName,
      chatHistory: chatHistory,
      userMessage: userMessage,
    );
  }

  /// 发送流式聊天消息
  Stream<AiStreamEvent> sendMessageStream({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    await _ensureInitialized();

    yield* chatService.sendMessageStream(
      provider: provider,
      assistant: assistant,
      modelName: modelName,
      chatHistory: chatHistory,
      userMessage: userMessage,
    );
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required models.AiProvider provider,
    String? modelName,
  }) async {
    await _ensureInitialized();

    return await chatService.testProvider(
      provider: provider,
      modelName: modelName,
    );
  }

  /// 获取提供商的模型列表
  Future<List<AiModel>> getModelsFromProvider(
    models.AiProvider provider, {
    bool useCache = true,
  }) async {
    await _ensureInitialized();

    return await modelService.getModelsFromProvider(
      provider,
      useCache: useCache,
    );
  }

  /// 检测模型能力
  Set<String> detectModelCapabilities({
    required models.AiProvider provider,
    required String modelName,
  }) {
    return modelService.detectModelCapabilities(
      provider: provider,
      modelName: modelName,
    );
  }

  /// 获取服务统计信息
  Map<String, dynamic> getServiceStats() {
    final stats = <String, dynamic>{};

    for (final entry in _services.entries) {
      final serviceName = entry.key;
      final service = entry.value;

      stats[serviceName] = {
        'name': service.serviceName,
        'capabilities': service.supportedCapabilities
            .map((c) => c.name)
            .toList(),
        'initialized': _isInitialized,
      };

      // 添加特定服务的统计信息
      if (service is ChatService) {
        // 可以添加聊天服务特定的统计信息
      } else if (service is ModelService) {
        stats[serviceName]['cache'] = service.getCacheStats();
      }
    }

    return stats;
  }

  /// 清除所有缓存
  void clearAllCaches() {
    _logger.info('清除所有AI服务缓存');
    modelService.clearCache();
  }

  /// 清除特定提供商的缓存
  void clearProviderCache(String providerId) {
    _logger.info('清除提供商缓存', {'providerId': providerId});
    modelService.clearCache(providerId);
  }

  /// 检查服务健康状态
  Future<Map<String, bool>> checkServiceHealth() async {
    final health = <String, bool>{};

    for (final entry in _services.entries) {
      final serviceName = entry.key;
      try {
        // 这里可以添加具体的健康检查逻辑
        health[serviceName] = _isInitialized;
      } catch (e) {
        _logger.error('服务健康检查失败', {
          'service': serviceName,
          'error': e.toString(),
        });
        health[serviceName] = false;
      }
    }

    return health;
  }

  /// 获取支持的AI能力列表
  Set<AiCapability> getSupportedCapabilities() {
    final allCapabilities = <AiCapability>{};

    for (final service in _services.values) {
      allCapabilities.addAll(service.supportedCapabilities);
    }

    return allCapabilities;
  }

  /// 检查是否支持特定能力
  bool supportsCapability(AiCapability capability) {
    return _services.values.any(
      (service) => service.supportsCapability(capability),
    );
  }

  /// 注册服务
  void _registerService(String name, AiServiceBase service) {
    _services[name] = service;
    _logger.debug('注册AI服务', {
      'name': name,
      'service': service.serviceName,
      'capabilities': service.supportedCapabilities.map((c) => c.name).toList(),
    });
  }

  /// 获取服务
  T _getService<T extends AiServiceBase>(String name) {
    final service = _services[name];
    if (service == null) {
      throw StateError('Service not found: $name');
    }
    if (service is! T) {
      throw StateError('Service $name is not of type $T');
    }
    return service;
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}

/// AI服务管理器的Riverpod Provider
final aiServiceManagerProvider = Provider<AiServiceManager>((ref) {
  return AiServiceManager();
});

/// 初始化AI服务管理器的Provider
final initializeAiServicesProvider = FutureProvider<void>((ref) async {
  final manager = ref.read(aiServiceManagerProvider);
  await manager.initialize();
});

/// AI服务健康状态Provider
final aiServiceHealthProvider = FutureProvider<Map<String, bool>>((ref) async {
  final manager = ref.read(aiServiceManagerProvider);
  return await manager.checkServiceHealth();
});

/// AI服务统计信息Provider
final aiServiceStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final manager = ref.read(aiServiceManagerProvider);
  return manager.getServiceStats();
});

/// 支持的AI能力Provider
final supportedAiCapabilitiesProvider = Provider<Set<AiCapability>>((ref) {
  final manager = ref.read(aiServiceManagerProvider);
  return manager.getSupportedCapabilities();
});

/// 检查AI能力支持的Provider
final aiCapabilitySupportProvider = Provider.family<bool, AiCapability>((
  ref,
  capability,
) {
  final manager = ref.read(aiServiceManagerProvider);
  return manager.supportsCapability(capability);
});
