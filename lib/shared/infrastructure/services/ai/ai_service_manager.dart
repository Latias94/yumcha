import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../features/chat/domain/entities/message.dart';
import '../../../../features/ai_management/domain/entities/ai_model.dart';
import '../../../../features/settings/domain/usecases/manage_mcp_server_usecase.dart';
import 'core/ai_service_base.dart';
import 'core/ai_response_models.dart';
import 'chat/chat_service.dart';
import 'capabilities/model_service.dart';
import 'capabilities/embedding_service.dart';
import 'capabilities/speech_service.dart';
import 'capabilities/enhanced_tool_service.dart';
import 'capabilities/multimodal_service.dart';
import '../logger_service.dart';

/// AI服务管理器 - 统一管理所有AI相关服务
///
/// 这是整个AI服务架构的核心管理器，负责：
/// - 🏗️ **服务注册与初始化**：管理所有AI服务的生命周期
/// - 🔄 **统一接口**：为上层提供统一的AI功能访问接口
/// - 📊 **监控统计**：收集和管理所有AI服务的统计信息
/// - 💾 **缓存管理**：统一管理各服务的缓存策略
/// - 🔧 **健康检查**：监控各服务的健康状态
///
/// ## 架构设计
///
/// ```
/// AiServiceManager (单例)
/// ├── ChatService      # 聊天对话服务
/// ├── ModelService     # 模型管理服务
/// ├── EmbeddingService # 向量嵌入服务
/// └── SpeechService    # 语音处理服务
/// ```
///
/// ## 使用方式
///
/// ### 1. 通过Riverpod Provider使用（推荐）
/// ```dart
/// final manager = ref.read(aiServiceManagerProvider);
/// await ref.read(initializeAiServicesProvider.future);
/// ```
///
/// ### 2. 直接使用服务
/// ```dart
/// final response = await manager.sendMessage(
///   provider: provider,
///   assistant: assistant,
///   modelName: 'gpt-4',
///   chatHistory: messages,
///   userMessage: 'Hello',
/// );
/// ```
///
/// ### 3. 访问特定服务
/// ```dart
/// final models = await manager.modelService.getModelsFromProvider(provider);
/// final embeddings = await manager.embeddingService.generateEmbeddings(...);
/// ```
///
/// ## 特性
/// - ✅ **单例模式**：确保全局唯一的服务管理器实例
/// - ✅ **懒加载**：服务按需初始化，提升启动性能
/// - ✅ **错误恢复**：单个服务失败不影响其他服务
/// - ✅ **资源管理**：自动管理服务资源的创建和释放
/// - ✅ **统计监控**：实时收集性能和使用统计数据
class AiServiceManager {
  // 单例模式实现
  static final AiServiceManager _instance = AiServiceManager._internal();
  factory AiServiceManager() => _instance;
  AiServiceManager._internal();

  // 核心依赖
  final LoggerService _logger = LoggerService();
  final Map<String, AiServiceBase> _services = {}; // 服务注册表
  final ManageMcpServerUseCase _mcpService = ManageMcpServerUseCase(); // MCP服务
  bool _isInitialized = false; // 初始化状态标记

  /// 获取聊天服务
  ///
  /// 提供AI聊天对话功能，支持：
  /// - 单次聊天请求
  /// - 流式聊天响应
  /// - 工具调用
  /// - 推理思考
  /// - 视觉理解
  ChatService get chatService => _getService<ChatService>('chat');

  /// 获取模型服务
  ///
  /// 提供AI模型管理功能，支持：
  /// - 获取提供商模型列表
  /// - 模型能力检测
  /// - 模型缓存管理
  /// - 模型兼容性检查
  ModelService get modelService => _getService<ModelService>('model');

  /// 获取嵌入服务
  ///
  /// 提供文本向量化功能，支持：
  /// - 文本嵌入生成
  /// - 相似度计算
  /// - 批量嵌入处理
  /// - 嵌入缓存优化
  EmbeddingService get embeddingService =>
      _getService<EmbeddingService>('embedding');

  /// 获取语音服务
  ///
  /// 提供语音处理功能，支持：
  /// - 语音转文字 (STT)
  /// - 文字转语音 (TTS)
  /// - 多种语音模型
  /// - 音频格式转换
  SpeechService get speechService => _getService<SpeechService>('speech');

  /// 获取增强工具服务
  ///
  /// 提供高级工具调用功能，支持：
  /// - 工具链执行
  /// - 工具结果处理
  /// - 错误恢复机制
  /// - 性能监控
  EnhancedToolService get enhancedToolService =>
      _getService<EnhancedToolService>('enhanced_tool');

  /// 获取多模态服务
  ///
  /// 提供多模态AI功能，支持：
  /// - 图像理解和分析
  /// - 语音转文字 (STT)
  /// - 文字转语音 (TTS)
  /// - 图像生成
  MultimodalService get multimodalService =>
      _getService<MultimodalService>('multimodal');

  /// 获取MCP服务
  ///
  /// 提供MCP (Model Context Protocol) 功能，支持：
  /// - 外部工具连接和调用
  /// - 多种连接类型 (STDIO、HTTP、SSE)
  /// - 平台适配和兼容性检查
  /// - 工具发现和管理
  ManageMcpServerUseCase get mcpService => _mcpService;

  /// 初始化所有AI服务
  ///
  /// 这是整个AI服务系统的启动入口，负责：
  /// 1. **服务注册**：注册所有核心AI服务到服务注册表
  /// 2. **依次初始化**：按顺序初始化每个服务，确保依赖关系正确
  /// 3. **错误处理**：如果任何服务初始化失败，整个初始化过程会回滚
  /// 4. **状态管理**：维护初始化状态，避免重复初始化
  ///
  /// ## 初始化顺序
  /// 1. ChatService - 聊天服务（核心服务）
  /// 2. ModelService - 模型服务（支持服务）
  /// 3. EmbeddingService - 嵌入服务（扩展服务）
  /// 4. SpeechService - 语音服务（扩展服务）
  ///
  /// ## 使用方式
  /// ```dart
  /// // 通过Riverpod Provider初始化（推荐）
  /// await ref.read(initializeAiServicesProvider.future);
  ///
  /// // 直接初始化
  /// final manager = AiServiceManager();
  /// await manager.initialize();
  /// ```
  ///
  /// @throws Exception 如果任何服务初始化失败
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('🚀 开始初始化AI服务管理器');

    try {
      // 注册核心服务 - 按依赖关系顺序注册
      _registerService('chat', ChatService());
      _registerService('model', ModelService());
      _registerService('embedding', EmbeddingService());
      _registerService('speech', SpeechService());
      _registerService('enhanced_tool', EnhancedToolService());
      _registerService('multimodal', MultimodalService());

      // 初始化所有服务 - 确保每个服务都正确启动
      for (final service in _services.values) {
        await service.initialize();
      }

      _isInitialized = true;
      _logger.info('✅ AI服务管理器初始化完成', {
        'services': _services.keys.toList(),
        'serviceCount': _services.length,
      });
    } catch (e) {
      _logger.error('❌ AI服务管理器初始化失败', {'error': e.toString()});
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

  /// 发送聊天消息（单次响应）
  ///
  /// 发送消息到AI提供商并等待完整响应。适用于：
  /// - 🔄 **标准聊天**：普通的问答对话
  /// - 🧠 **推理任务**：需要深度思考的复杂问题
  /// - 🔧 **工具调用**：需要调用外部工具的任务
  /// - 👁️ **视觉理解**：包含图像的多模态对话
  ///
  /// ## 参数说明
  /// - `provider`: AI服务提供商（OpenAI、Anthropic等）
  /// - `assistant`: AI助手配置（系统提示、参数等）
  /// - `modelName`: 要使用的具体模型名称
  /// - `chatHistory`: 历史对话消息列表
  /// - `userMessage`: 用户当前输入的消息
  ///
  /// ## 返回值
  /// 返回 `AiResponse` 对象，包含：
  /// - `content`: AI的回复内容
  /// - `thinking`: 推理过程（如果支持）
  /// - `usage`: Token使用统计
  /// - `duration`: 请求耗时
  /// - `toolCalls`: 工具调用结果
  ///
  /// ## 使用示例
  /// ```dart
  /// final response = await manager.sendMessage(
  ///   provider: openaiProvider,
  ///   assistant: chatAssistant,
  ///   modelName: 'gpt-4',
  ///   chatHistory: previousMessages,
  ///   userMessage: 'Hello, how are you?',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('AI回复: ${response.content}');
  /// }
  /// ```
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

  /// 发送流式聊天消息（实时响应）
  ///
  /// 发送消息到AI提供商并实时接收响应流。适用于：
  /// - ⚡ **实时对话**：需要即时反馈的聊天场景
  /// - 📝 **长文本生成**：逐步显示生成的长内容
  /// - 🧠 **思考过程**：实时显示AI的推理过程
  /// - 🔧 **工具调用**：实时显示工具执行进度
  ///
  /// ## 流事件类型
  /// - `AiStreamEvent.contentDelta`: 内容增量更新
  /// - `AiStreamEvent.thinkingDelta`: 思考过程增量
  /// - `AiStreamEvent.toolCall`: 工具调用事件
  /// - `AiStreamEvent.completed`: 响应完成事件
  /// - `AiStreamEvent.error`: 错误事件
  ///
  /// ## 使用示例
  /// ```dart
  /// await for (final event in manager.sendMessageStream(...)) {
  ///   switch (event.type) {
  ///     case StreamEventType.contentDelta:
  ///       // 更新UI显示新内容
  ///       updateChatContent(event.contentDelta);
  ///       break;
  ///     case StreamEventType.completed:
  ///       // 处理完成事件
  ///       handleCompletion(event);
  ///       break;
  ///   }
  /// }
  /// ```
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
  ///
  /// 验证AI提供商的连接和配置是否正确。用于：
  /// - 🔍 **配置验证**：检查API密钥、基础URL等配置
  /// - 🌐 **网络连通性**：测试与提供商服务器的连接
  /// - 🤖 **模型可用性**：验证指定模型是否可用
  /// - ⚡ **响应速度**：测试提供商的响应性能
  ///
  /// ## 测试流程
  /// 1. 创建测试用的临时助手配置
  /// 2. 使用最小参数发送测试消息
  /// 3. 验证是否收到有效响应
  /// 4. 记录测试结果和性能数据
  ///
  /// ## 参数说明
  /// - `provider`: 要测试的AI提供商
  /// - `modelName`: 可选的模型名称，不提供则使用默认模型
  ///
  /// @returns `true` 如果测试成功，`false` 如果测试失败
  ///
  /// ## 使用示例
  /// ```dart
  /// final isWorking = await manager.testProvider(
  ///   provider: openaiProvider,
  ///   modelName: 'gpt-3.5-turbo',
  /// );
  ///
  /// if (isWorking) {
  ///   print('✅ 提供商连接正常');
  /// } else {
  ///   print('❌ 提供商连接失败');
  /// }
  /// ```
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
  ///
  /// 从AI提供商获取可用的模型列表。支持：
  /// - 📋 **动态获取**：从提供商API实时获取最新模型列表
  /// - 💾 **智能缓存**：缓存模型列表以提升性能（默认1小时）
  /// - 🔄 **自动刷新**：缓存过期时自动重新获取
  /// - 🏷️ **能力标注**：自动检测和标注模型能力
  ///
  /// ## 支持的提供商
  /// - ✅ OpenAI: 通过 `/v1/models` API
  /// - ✅ Ollama: 通过本地API
  /// - ✅ 其他OpenAI兼容提供商
  /// - 📋 其他提供商: 使用配置的静态模型列表
  ///
  /// ## 缓存策略
  /// - **缓存时间**: 1小时
  /// - **缓存键**: 基于提供商ID和配置哈希
  /// - **失效条件**: 提供商配置变更时自动失效
  ///
  /// @param provider 要获取模型的提供商
  /// @param useCache 是否使用缓存，默认为true
  /// @returns 模型列表，包含名称、能力、参数等信息
  ///
  /// ## 使用示例
  /// ```dart
  /// // 使用缓存获取模型列表
  /// final models = await manager.getModelsFromProvider(provider);
  ///
  /// // 强制刷新模型列表
  /// final freshModels = await manager.getModelsFromProvider(
  ///   provider,
  ///   useCache: false,
  /// );
  ///
  /// for (final model in models) {
  ///   print('模型: ${model.name}, 能力: ${model.capabilities}');
  /// }
  /// ```
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
  ///
  /// 分析指定模型支持的AI能力。基于：
  /// - 📋 **模型配置**：从AiModel.capabilities获取能力信息
  /// - 🔍 **名称推断**：根据模型名称模式推断能力
  /// - 🏷️ **提供商特性**：结合提供商特性进行能力判断
  ///
  /// ## 支持的能力类型
  /// - 🧠 **reasoning**: 推理思考能力（如o1模型）
  /// - 👁️ **vision**: 视觉理解能力（如GPT-4V）
  /// - 🔧 **tools**: 工具调用能力
  /// - 📊 **embedding**: 向量嵌入能力
  ///
  /// ## 检测逻辑
  /// 1. 优先使用模型配置中的能力信息
  /// 2. 如果没有配置，根据模型名称推断
  /// 3. 结合提供商类型进行最终判断
  ///
  /// @param provider AI提供商
  /// @param modelName 模型名称
  /// @returns 能力集合，包含该模型支持的所有能力
  ///
  /// ## 使用示例
  /// ```dart
  /// final capabilities = manager.detectModelCapabilities(
  ///   provider: openaiProvider,
  ///   modelName: 'gpt-4-vision-preview',
  /// );
  ///
  /// if (capabilities.contains('vision')) {
  ///   print('✅ 支持视觉理解');
  /// }
  /// if (capabilities.contains('reasoning')) {
  ///   print('✅ 支持推理思考');
  /// }
  /// ```
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
        'capabilities':
            service.supportedCapabilities.map((c) => c.name).toList(),
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

// ============================================================================
// Riverpod Providers - AI服务的状态管理接口
// ============================================================================

/// AI服务管理器的Riverpod Provider
///
/// 提供全局唯一的AiServiceManager实例。这是访问所有AI服务的入口点。
///
/// ## 使用方式
/// ```dart
/// final manager = ref.read(aiServiceManagerProvider);
/// final response = await manager.sendMessage(...);
/// ```
final aiServiceManagerProvider = Provider<AiServiceManager>((ref) {
  return AiServiceManager();
});

/// 初始化AI服务管理器的Provider
///
/// 负责初始化整个AI服务系统。应该在应用启动时调用。
///
/// ## 特性
/// - ⚡ **异步初始化**：不阻塞UI线程
/// - 🔄 **自动重试**：初始化失败时可以重新尝试
/// - 📊 **状态跟踪**：通过Riverpod跟踪初始化状态
///
/// ## 使用方式
/// ```dart
/// // 在应用启动时
/// await ref.read(initializeAiServicesProvider.future);
///
/// // 监听初始化状态
/// ref.listen(initializeAiServicesProvider, (previous, next) {
///   next.when(
///     data: (_) => print('✅ AI服务初始化完成'),
///     loading: () => print('🔄 正在初始化AI服务...'),
///     error: (error, stack) => print('❌ 初始化失败: $error'),
///   );
/// });
/// ```
final initializeAiServicesProvider = FutureProvider<void>((ref) async {
  final manager = ref.read(aiServiceManagerProvider);
  await manager.initialize();
});

/// AI服务健康状态Provider
///
/// 实时监控所有AI服务的健康状态，用于：
/// - 🏥 **健康检查**：定期检查服务是否正常运行
/// - 🚨 **故障检测**：及时发现服务异常
/// - 📊 **状态展示**：在管理界面显示服务状态
///
/// ## 返回格式
/// ```dart
/// {
///   'chat': true,      // 聊天服务状态
///   'model': true,     // 模型服务状态
///   'embedding': false, // 嵌入服务状态
///   'speech': true,    // 语音服务状态
/// }
/// ```
///
/// ## 使用示例
/// ```dart
/// final health = await ref.read(aiServiceHealthProvider.future);
///
/// health.forEach((service, isHealthy) {
///   final status = isHealthy ? '✅ 正常' : '❌ 异常';
///   print('$service: $status');
/// });
/// ```
final aiServiceHealthProvider = FutureProvider<Map<String, bool>>((ref) async {
  final manager = ref.read(aiServiceManagerProvider);
  return await manager.checkServiceHealth();
});

/// AI服务统计信息Provider
///
/// 提供所有AI服务的详细统计信息，包括：
/// - 📊 **性能指标**：请求数量、成功率、平均耗时
/// - 🔧 **服务状态**：初始化状态、支持的能力
/// - 💾 **缓存统计**：缓存命中率、缓存大小
///
/// ## 数据结构
/// ```dart
/// {
///   'chat': {
///     'name': 'ChatService',
///     'capabilities': ['chat', 'streaming', 'tools'],
///     'initialized': true,
///   },
///   'model': {
///     'name': 'ModelService',
///     'capabilities': ['models'],
///     'initialized': true,
///     'cache': { 'hitRate': 0.85, 'size': 42 }
///   }
/// }
/// ```
///
/// ## 使用示例
/// ```dart
/// final stats = ref.watch(aiServiceStatsProvider);
///
/// stats.forEach((serviceName, serviceStats) {
///   print('服务: $serviceName');
///   print('能力: ${serviceStats['capabilities']}');
///   print('状态: ${serviceStats['initialized'] ? '已初始化' : '未初始化'}');
/// });
/// ```
final aiServiceStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final manager = ref.read(aiServiceManagerProvider);
  return manager.getServiceStats();
});

/// 支持的AI能力Provider
///
/// 获取当前AI服务系统支持的所有能力集合。
///
/// ## 能力类型
/// - 🗣️ **chat**: 基础聊天对话
/// - ⚡ **streaming**: 流式响应
/// - 📋 **models**: 模型列表获取
/// - 📊 **embedding**: 向量嵌入
/// - 🎤 **speechToText**: 语音转文字
/// - 🔊 **textToSpeech**: 文字转语音
/// - 🖼️ **imageGeneration**: 图像生成
/// - 🔧 **toolCalling**: 工具调用
/// - 🧠 **reasoning**: 推理思考
/// - 👁️ **vision**: 视觉理解
///
/// ## 使用示例
/// ```dart
/// final capabilities = ref.watch(supportedAiCapabilitiesProvider);
///
/// if (capabilities.contains(AiCapability.vision)) {
///   // 显示图像上传功能
/// }
/// if (capabilities.contains(AiCapability.streaming)) {
///   // 启用流式聊天
/// }
/// ```
final supportedAiCapabilitiesProvider = Provider<Set<AiCapability>>((ref) {
  final manager = ref.read(aiServiceManagerProvider);
  return manager.getSupportedCapabilities();
});

/// 检查AI能力支持的Provider
///
/// 检查系统是否支持特定的AI能力。这是一个family provider，
/// 可以针对不同的能力进行独立查询。
///
/// ## 参数
/// - `capability`: 要检查的AI能力类型
///
/// ## 使用示例
/// ```dart
/// // 检查是否支持视觉理解
/// final supportsVision = ref.watch(
///   aiCapabilitySupportProvider(AiCapability.vision)
/// );
///
/// // 检查是否支持工具调用
/// final supportsTools = ref.watch(
///   aiCapabilitySupportProvider(AiCapability.toolCalling)
/// );
///
/// // 根据能力支持情况显示不同的UI
/// if (supportsVision) {
///   return ImageUploadWidget();
/// } else {
///   return TextOnlyWidget();
/// }
/// ```
final aiCapabilitySupportProvider = Provider.family<bool, AiCapability>((
  ref,
  capability,
) {
  final manager = ref.read(aiServiceManagerProvider);
  return manager.supportsCapability(capability);
});
