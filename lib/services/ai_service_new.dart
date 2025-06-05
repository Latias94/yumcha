import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_provider.dart' as models;
import '../models/ai_assistant.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../providers/ai_provider_notifier.dart';
import '../providers/ai_assistant_notifier.dart';
import '../providers/settings_notifier.dart';
import 'ai/ai_service_manager.dart';
import 'ai/core/ai_response_models.dart';
import 'logger_service.dart';

/// 新的AI服务 - 基于模块化架构的统一接口
/// 
/// 这个类作为应用与AI服务管理器之间的桥梁，
/// 提供向后兼容的API，同时使用新的模块化架构
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final LoggerService _logger = LoggerService();
  final AiServiceManager _serviceManager = AiServiceManager();
  bool _isInitialized = false;

  /// 初始化AI服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('初始化AI服务');
    
    try {
      await _serviceManager.initialize();
      _isInitialized = true;
      _logger.info('AI服务初始化完成');
    } catch (e) {
      _logger.error('AI服务初始化失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    _logger.info('清理AI服务资源');
    await _serviceManager.dispose();
    _isInitialized = false;
  }

  /// 发送聊天消息 - 向后兼容的API
  Future<AiResponse> sendMessage({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async {
    await _ensureInitialized();

    _logger.info('发送聊天消息', {
      'assistantId': assistantId,
      'providerId': selectedProviderId,
      'modelName': selectedModelName,
      'messageLength': userMessage.length,
    });

    try {
      // 这里需要通过Riverpod获取provider和assistant
      // 由于这是一个服务类，我们需要传入WidgetRef或使用其他方式
      // 暂时抛出异常，提示使用新的API
      throw UnimplementedError(
        '请使用 AiServiceManager 或相应的 Riverpod Provider 来发送消息。'
        '新的API提供更好的状态管理和错误处理。'
      );
    } catch (e) {
      _logger.error('发送聊天消息失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 发送流式聊天消息 - 向后兼容的API
  Stream<AiStreamEvent> sendMessageStream({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async* {
    await _ensureInitialized();

    _logger.info('发送流式聊天消息', {
      'assistantId': assistantId,
      'providerId': selectedProviderId,
      'modelName': selectedModelName,
      'messageLength': userMessage.length,
    });

    // 同样，这里需要Riverpod上下文
    throw UnimplementedError(
      '请使用 AiServiceManager 或相应的 Riverpod Provider 来发送流式消息。'
      '新的API提供更好的状态管理和错误处理。'
    );
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required String providerId,
    String? modelName,
  }) async {
    await _ensureInitialized();

    _logger.info('测试提供商连接', {
      'providerId': providerId,
      'modelName': modelName,
    });

    // 这里也需要通过某种方式获取provider实例
    throw UnimplementedError(
      '请使用 AiServiceManager.testProvider 或相应的 Riverpod Provider。'
    );
  }

  /// 获取提供商模型列表
  Future<List<AiModel>> getModelsFromProvider(
    String providerId, {
    bool useCache = true,
  }) async {
    await _ensureInitialized();

    _logger.info('获取提供商模型列表', {
      'providerId': providerId,
      'useCache': useCache,
    });

    // 同样需要provider实例
    throw UnimplementedError(
      '请使用 AiServiceManager.getModelsFromProvider 或相应的 Riverpod Provider。'
    );
  }

  /// 获取服务统计信息
  Map<String, dynamic> getServiceStats() {
    return _serviceManager.getServiceStats();
  }

  /// 检查服务健康状态
  Future<Map<String, bool>> checkServiceHealth() async {
    await _ensureInitialized();
    return await _serviceManager.checkServiceHealth();
  }

  /// 清除所有缓存
  void clearAllCaches() {
    _serviceManager.clearAllCaches();
  }

  /// 清除特定提供商的缓存
  void clearProviderCache(String providerId) {
    _serviceManager.clearProviderCache(providerId);
  }

  /// 获取支持的AI能力
  Set<String> getSupportedCapabilities() {
    return _serviceManager.getSupportedCapabilities()
        .map((capability) => capability.name)
        .toSet();
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}

/// AI服务的Riverpod Provider
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// 初始化AI服务的Provider
final initializeAiServiceProvider = FutureProvider<void>((ref) async {
  final aiService = ref.read(aiServiceProvider);
  await aiService.initialize();
});

/// 使用Riverpod的聊天服务辅助类
class RiverpodAiService {
  final Ref ref;
  
  RiverpodAiService(this.ref);

  /// 发送聊天消息（使用Riverpod状态管理）
  Future<AiResponse> sendMessage({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async {
    // 获取provider和assistant
    final provider = ref.read(aiProviderProvider(selectedProviderId));
    final assistant = ref.read(aiAssistantProvider(assistantId));

    if (provider == null) {
      throw Exception('Provider not found: $selectedProviderId');
    }

    if (assistant == null) {
      throw Exception('Assistant not found: $assistantId');
    }

    // 使用服务管理器发送消息
    final serviceManager = ref.read(aiServiceManagerProvider);
    
    return await serviceManager.sendMessage(
      provider: provider,
      assistant: assistant,
      modelName: selectedModelName,
      chatHistory: chatHistory,
      userMessage: userMessage,
    );
  }

  /// 发送流式聊天消息（使用Riverpod状态管理）
  Stream<AiStreamEvent> sendMessageStream({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async* {
    // 获取provider和assistant
    final provider = ref.read(aiProviderProvider(selectedProviderId));
    final assistant = ref.read(aiAssistantProvider(assistantId));

    if (provider == null) {
      throw Exception('Provider not found: $selectedProviderId');
    }

    if (assistant == null) {
      throw Exception('Assistant not found: $assistantId');
    }

    // 使用服务管理器发送流式消息
    final serviceManager = ref.read(aiServiceManagerProvider);
    
    yield* serviceManager.sendMessageStream(
      provider: provider,
      assistant: assistant,
      modelName: selectedModelName,
      chatHistory: chatHistory,
      userMessage: userMessage,
    );
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required String providerId,
    String? modelName,
  }) async {
    final provider = ref.read(aiProviderProvider(providerId));

    if (provider == null) {
      throw Exception('Provider not found: $providerId');
    }

    final serviceManager = ref.read(aiServiceManagerProvider);
    
    return await serviceManager.testProvider(
      provider: provider,
      modelName: modelName,
    );
  }

  /// 获取提供商模型列表
  Future<List<AiModel>> getModelsFromProvider(
    String providerId, {
    bool useCache = true,
  }) async {
    final provider = ref.read(aiProviderProvider(providerId));

    if (provider == null) {
      throw Exception('Provider not found: $providerId');
    }

    final serviceManager = ref.read(aiServiceManagerProvider);
    
    return await serviceManager.getModelsFromProvider(
      provider,
      useCache: useCache,
    );
  }
}

/// Riverpod AI服务的Provider
final riverpodAiServiceProvider = Provider<RiverpodAiService>((ref) {
  return RiverpodAiService(ref);
});
