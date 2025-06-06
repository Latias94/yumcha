import '../../../models/ai_provider.dart' as models;
import '../../../models/ai_assistant.dart';
import '../../../models/ai_model.dart';
import '../../../models/message.dart';
import '../../logger_service.dart';
import 'package:ai_dart/ai_dart.dart';

/// AI服务能力枚举
///
/// 定义了AI服务系统支持的所有能力类型。这个枚举用于：
/// - 🏷️ **能力标识**：标识每个服务支持的具体能力
/// - 🔍 **能力检测**：动态检测模型和提供商的能力
/// - 🎛️ **功能控制**：根据能力启用或禁用UI功能
/// - 📊 **统计分析**：统计各种能力的使用情况
///
/// ## 能力分类
///
/// ### 🗣️ 核心对话能力
/// - `chat`: 基础聊天对话
/// - `streaming`: 实时流式响应
///
/// ### 🧠 高级AI能力
/// - `reasoning`: 推理思考（如OpenAI o1系列）
/// - `vision`: 视觉理解（多模态输入）
/// - `toolCalling`: 工具调用和函数执行
///
/// ### 📊 数据处理能力
/// - `embedding`: 文本向量化
/// - `models`: 模型列表获取
///
/// ### 🎵 多媒体能力
/// - `speechToText`: 语音转文字 (STT)
/// - `textToSpeech`: 文字转语音 (TTS)
/// - `imageGeneration`: 图像生成
///
/// ## 使用示例
/// ```dart
/// // 检查服务是否支持特定能力
/// if (service.supportsCapability(AiCapability.vision)) {
///   // 启用图像上传功能
/// }
///
/// // 获取服务支持的所有能力
/// final capabilities = service.supportedCapabilities;
/// print('支持的能力: ${capabilities.map((c) => c.name).join(', ')}');
/// ```
enum AiCapability {
  /// 聊天对话 - 基础的文本对话能力
  chat,

  /// 流式聊天 - 实时响应流式输出
  streaming,

  /// 模型列表 - 获取可用模型列表的能力
  models,

  /// 向量嵌入 - 文本向量化和语义搜索
  embedding,

  /// 语音转文字 - 音频转录能力
  speechToText,

  /// 文字转语音 - 语音合成能力
  textToSpeech,

  /// 图像生成 - AI图像创作能力
  imageGeneration,

  /// 工具调用 - 函数调用和外部工具集成
  toolCalling,

  /// 推理思考 - 深度推理和思考过程展示
  reasoning,

  /// 视觉理解 - 图像识别和多模态理解
  vision,
}

/// AI服务基类 - 定义所有AI服务的通用接口和行为
///
/// 这是整个AI服务架构的基础抽象类，为所有具体的AI服务提供：
/// - 🏗️ **统一接口**：标准化的服务生命周期管理
/// - 🏷️ **能力声明**：明确声明每个服务支持的AI能力
/// - 📝 **日志记录**：统一的日志记录机制
/// - 🔄 **生命周期**：标准化的初始化和清理流程
///
/// ## 设计原则
///
/// ### 1. 单一职责
/// 每个继承的服务类只负责一个特定的AI功能领域：
/// - `ChatService`: 专注聊天对话
/// - `ModelService`: 专注模型管理
/// - `EmbeddingService`: 专注向量嵌入
/// - `SpeechService`: 专注语音处理
///
/// ### 2. 能力驱动
/// 通过 `supportedCapabilities` 明确声明服务能力，支持：
/// - 动态功能检测
/// - UI功能启用/禁用
/// - 服务路由选择
///
/// ### 3. 生命周期管理
/// 标准化的初始化和清理流程：
/// - `initialize()`: 服务启动和资源准备
/// - `dispose()`: 资源清理和连接关闭
///
/// ## 实现指南
///
/// 继承此类时需要实现：
/// ```dart
/// class MyAiService extends AiServiceBase {
///   @override
///   String get serviceName => 'MyAiService';
///
///   @override
///   Set<AiCapability> get supportedCapabilities => {
///     AiCapability.chat,
///     AiCapability.streaming,
///   };
///
///   @override
///   Future<void> initialize() async {
///     // 初始化逻辑
///   }
///
///   @override
///   Future<void> dispose() async {
///     // 清理逻辑
///   }
/// }
/// ```
///
/// ## 使用示例
/// ```dart
/// final service = ChatService();
///
/// // 检查能力支持
/// if (service.supportsCapability(AiCapability.streaming)) {
///   // 使用流式功能
/// }
///
/// // 生命周期管理
/// await service.initialize();
/// // ... 使用服务
/// await service.dispose();
/// ```
abstract class AiServiceBase {
  /// 统一的日志记录器
  ///
  /// 所有继承的服务都使用这个日志记录器，确保：
  /// - 统一的日志格式
  /// - 一致的日志级别
  /// - 集中的日志管理
  final LoggerService logger = LoggerService();

  /// 服务名称
  ///
  /// 用于标识服务的唯一名称，应该：
  /// - 简洁明了（如 'ChatService'）
  /// - 反映服务功能
  /// - 在整个系统中唯一
  String get serviceName;

  /// 支持的能力列表
  ///
  /// 声明此服务支持的所有AI能力。用于：
  /// - 🔍 **能力检测**：系统自动检测可用功能
  /// - 🎛️ **UI控制**：根据能力显示/隐藏功能
  /// - 📊 **统计分析**：统计各能力的使用情况
  /// - 🔀 **服务路由**：将请求路由到合适的服务
  Set<AiCapability> get supportedCapabilities;

  /// 检查是否支持指定能力
  ///
  /// 便捷方法，用于检查服务是否支持特定的AI能力。
  ///
  /// @param capability 要检查的AI能力
  /// @returns 如果支持返回true，否则返回false
  ///
  /// ## 使用示例
  /// ```dart
  /// if (service.supportsCapability(AiCapability.vision)) {
  ///   // 启用图像上传功能
  ///   showImageUploadButton();
  /// }
  /// ```
  bool supportsCapability(AiCapability capability) {
    return supportedCapabilities.contains(capability);
  }

  /// 初始化服务
  ///
  /// 服务启动时的初始化逻辑，应该包括：
  /// - 🔧 **资源准备**：初始化必要的资源和连接
  /// - ⚙️ **配置加载**：加载服务相关的配置
  /// - 🔍 **依赖检查**：验证依赖服务是否可用
  /// - 📝 **状态设置**：设置服务的初始状态
  ///
  /// ## 实现要求
  /// - 必须是幂等的（多次调用应该安全）
  /// - 应该有适当的错误处理
  /// - 失败时应该抛出有意义的异常
  ///
  /// @throws Exception 如果初始化失败
  Future<void> initialize();

  /// 清理资源
  ///
  /// 服务关闭时的清理逻辑，应该包括：
  /// - 🔌 **连接关闭**：关闭网络连接和数据库连接
  /// - 💾 **缓存清理**：清理内存缓存和临时数据
  /// - 🧹 **资源释放**：释放文件句柄、线程等资源
  /// - 📝 **状态重置**：重置服务状态为未初始化
  ///
  /// ## 实现要求
  /// - 必须是幂等的（多次调用应该安全）
  /// - 不应该抛出异常（静默处理错误）
  /// - 应该尽力清理所有资源
  Future<void> dispose();
}

/// AI提供商适配器基类 - 统一不同AI提供商的接口差异
///
/// 这个适配器类解决了不同AI提供商之间的接口差异问题，提供：
/// - 🔌 **统一接口**：将不同提供商的API统一为标准接口
/// - 🔄 **参数转换**：将应用内的参数转换为提供商特定格式
/// - 🏷️ **能力映射**：将提供商能力映射为标准能力枚举
/// - 📝 **消息转换**：将应用消息格式转换为AI Dart格式
///
/// ## 设计模式
///
/// 使用适配器模式（Adapter Pattern）来解决：
/// - **接口不兼容**：不同提供商有不同的API接口
/// - **参数差异**：相同功能但参数名称和格式不同
/// - **能力差异**：不同提供商支持的功能集合不同
///
/// ## 架构层次
/// ```
/// Application Layer
///       ↓
/// AiProviderAdapter (统一接口)
///       ↓
/// AI Dart Library (具体实现)
///       ↓
/// Provider APIs (OpenAI, Anthropic, etc.)
/// ```
///
/// ## 核心职责
///
/// ### 1. 提供商实例创建
/// 根据配置创建对应的AI Dart提供商实例：
/// ```dart
/// final chatProvider = await adapter.createProvider();
/// ```
///
/// ### 2. 能力检测
/// 自动检测提供商和模型支持的能力：
/// ```dart
/// final capabilities = adapter.detectCapabilities(chatProvider);
/// ```
///
/// ### 3. 消息格式转换
/// 将应用内消息转换为AI Dart格式：
/// ```dart
/// final aiMessages = adapter.convertMessages(appMessages);
/// ```
///
/// ### 4. 系统提示构建
/// 根据助手配置构建系统提示：
/// ```dart
/// final systemMessages = adapter.buildSystemMessages();
/// ```
///
/// ## 使用示例
/// ```dart
/// final adapter = DefaultAiProviderAdapter(
///   provider: openaiProvider,
///   assistant: chatAssistant,
///   modelName: 'gpt-4',
/// );
///
/// final chatProvider = await adapter.createProvider();
/// final messages = adapter.convertMessages(chatHistory);
/// final response = await chatProvider.chat(messages);
/// ```
abstract class AiProviderAdapter {
  /// AI提供商配置
  /// 包含API密钥、基础URL、支持的模型等信息
  final models.AiProvider provider;

  /// AI助手配置
  /// 包含系统提示、温度参数、上下文长度等AI参数
  final AiAssistant assistant;

  /// 要使用的模型名称
  /// 必须是提供商支持的有效模型名称
  final String modelName;

  /// 内部日志记录器
  final LoggerService _logger = LoggerService();

  /// 构造函数
  ///
  /// @param provider AI提供商配置
  /// @param assistant AI助手配置
  /// @param modelName 模型名称
  AiProviderAdapter({
    required this.provider,
    required this.assistant,
    required this.modelName,
  });

  /// 创建AI Dart提供商实例
  ///
  /// 根据配置创建对应的AI提供商实例。这是适配器的核心方法，负责：
  /// - 🔧 **参数映射**：将应用配置转换为AI Dart参数
  /// - 🔑 **认证设置**：配置API密钥和认证信息
  /// - 🌐 **网络配置**：设置基础URL和自定义头部
  /// - ⚙️ **模型参数**：配置温度、top-p、最大token等参数
  ///
  /// @param enableStreaming 是否启用流式响应
  /// @returns 配置好的ChatProvider实例
  /// @throws Exception 如果创建失败
  ///
  /// ## 实现要求
  /// - 必须根据provider.type创建对应的提供商实例
  /// - 必须正确设置所有必要的参数
  /// - 必须处理认证和网络配置
  /// - 失败时必须抛出有意义的异常
  Future<ChatProvider> createProvider({bool enableStreaming = false});

  /// 检测提供商支持的能力
  ///
  /// 通过分析ChatProvider实例和模型配置来检测支持的AI能力。
  /// 检测逻辑分为两个层次：
  ///
  /// ### 1. 接口检测（动态检测）
  /// 通过检查ChatProvider实现的接口来判断能力：
  /// - `StreamingChatProvider`: 支持流式聊天
  /// - `ModelProvider`: 支持模型列表获取
  /// - `EmbeddingProvider`: 支持向量嵌入
  /// - `SpeechToTextProvider`: 支持语音转文字
  /// - `TextToSpeechProvider`: 支持文字转语音
  ///
  /// ### 2. 配置推断（静态检测）
  /// 根据模型配置中的能力信息进行推断：
  /// - `ModelCapability.reasoning` → `AiCapability.reasoning`
  /// - `ModelCapability.vision` → `AiCapability.vision`
  /// - `ModelCapability.tools` → `AiCapability.toolCalling`
  /// - `ModelCapability.embedding` → `AiCapability.embedding`
  ///
  /// @param chatProvider 已创建的ChatProvider实例
  /// @returns 检测到的能力集合
  ///
  /// ## 使用示例
  /// ```dart
  /// final chatProvider = await adapter.createProvider();
  /// final capabilities = adapter.detectCapabilities(chatProvider);
  ///
  /// if (capabilities.contains(AiCapability.vision)) {
  ///   print('✅ 支持视觉理解');
  /// }
  /// ```
  Set<AiCapability> detectCapabilities(ChatProvider chatProvider) {
    final capabilities = <AiCapability>{};

    // 基础聊天能力 - 所有提供商都支持
    capabilities.add(AiCapability.chat);

    // 检测流式能力 - 通过接口类型判断
    if (chatProvider is StreamingChatProvider) {
      capabilities.add(AiCapability.streaming);
    }

    // 检测模型列表能力 - 通过接口类型判断
    if (chatProvider is ModelProvider) {
      capabilities.add(AiCapability.models);
    }

    // 检测嵌入能力 - 通过接口类型判断
    if (chatProvider is EmbeddingProvider) {
      capabilities.add(AiCapability.embedding);
    }

    // 检测语音转文字能力 - 通过接口类型判断
    if (chatProvider is SpeechToTextProvider) {
      capabilities.add(AiCapability.speechToText);
    }

    // 检测文字转语音能力 - 通过接口类型判断
    if (chatProvider is TextToSpeechProvider) {
      capabilities.add(AiCapability.textToSpeech);
    }

    // 根据模型配置推断其他高级能力
    _inferAdditionalCapabilities(capabilities);

    return capabilities;
  }

  /// 根据模型配置推断额外能力
  void _inferAdditionalCapabilities(Set<AiCapability> capabilities) {
    // 查找当前模型的配置
    final model = provider.models.where((m) => m.name == modelName).firstOrNull;

    if (model != null) {
      // 根据模型的能力配置添加对应的AI能力
      for (final capability in model.capabilities) {
        switch (capability) {
          case ModelCapability.reasoning:
            capabilities.add(AiCapability.reasoning);
            break;
          case ModelCapability.vision:
            capabilities.add(AiCapability.vision);
            break;
          case ModelCapability.tools:
            capabilities.add(AiCapability.toolCalling);
            break;
          case ModelCapability.embedding:
            capabilities.add(AiCapability.embedding);
            break;
        }
      }
    }
    // 如果没有找到模型配置，不添加任何额外能力
  }

  /// 将应用消息转换为AI Dart消息格式
  ///
  /// 将应用内部的Message对象转换为AI Dart库要求的ChatMessage格式。
  /// 这个转换过程包括：
  /// - 🔄 **角色映射**：将isFromUser标志转换为角色类型
  /// - 📝 **内容提取**：提取消息的文本内容
  /// - 🖼️ **多媒体处理**：处理图像、音频等多媒体内容（未来扩展）
  ///
  /// ## 转换规则
  /// - `isFromUser = true` → `ChatMessage.user(content)`
  /// - `isFromUser = false` → `ChatMessage.assistant(content)`
  ///
  /// ## 未来扩展
  /// 计划支持的消息类型：
  /// - 图像消息：包含图片的多模态消息
  /// - 音频消息：语音输入消息
  /// - 工具消息：工具调用结果消息
  ///
  /// @param messages 应用内部的消息列表
  /// @returns 转换后的AI Dart消息列表
  ///
  /// ## 使用示例
  /// ```dart
  /// final appMessages = [
  ///   Message(content: 'Hello', isFromUser: true),
  ///   Message(content: 'Hi there!', isFromUser: false),
  /// ];
  ///
  /// final aiMessages = adapter.convertMessages(appMessages);
  /// // 结果: [ChatMessage.user('Hello'), ChatMessage.assistant('Hi there!')]
  /// ```
  List<ChatMessage> convertMessages(List<Message> messages) {
    return messages.map((msg) {
      if (msg.isFromUser) {
        return ChatMessage.user(msg.content);
      } else {
        return ChatMessage.assistant(msg.content);
      }
    }).toList();
  }

  /// 构建系统提示消息
  ///
  /// 根据AI助手配置构建系统级别的提示消息。系统提示用于：
  /// - 🎭 **角色定义**：定义AI助手的角色和性格
  /// - 📋 **行为指导**：指导AI的回答风格和行为模式
  /// - 🔧 **功能配置**：启用或禁用特定功能
  /// - 🌐 **上下文设置**：提供背景信息和约束条件
  ///
  /// ## 系统提示的重要性
  /// 系统提示是影响AI行为的关键因素：
  /// - **优先级最高**：系统提示的指令优先级高于用户消息
  /// - **全局影响**：影响整个对话过程中的AI行为
  /// - **角色一致性**：确保AI在整个对话中保持角色一致
  ///
  /// ## 构建逻辑
  /// 1. 检查助手是否配置了系统提示
  /// 2. 如果有系统提示，创建系统消息
  /// 3. 返回系统消息列表（可能为空）
  ///
  /// @returns 系统提示消息列表
  ///
  /// ## 使用示例
  /// ```dart
  /// final assistant = AiAssistant(
  ///   systemPrompt: 'You are a helpful coding assistant...',
  ///   // ... 其他配置
  /// );
  ///
  /// final adapter = DefaultAiProviderAdapter(
  ///   assistant: assistant,
  ///   // ... 其他参数
  /// );
  ///
  /// final systemMessages = adapter.buildSystemMessages();
  /// // 如果有系统提示，返回 [ChatMessage.system('You are a helpful...')]
  /// // 如果没有系统提示，返回 []
  /// ```
  List<ChatMessage> buildSystemMessages() {
    final messages = <ChatMessage>[];

    // 只有当系统提示不为空时才添加系统消息
    if (assistant.systemPrompt.isNotEmpty) {
      messages.add(ChatMessage.system(assistant.systemPrompt));
    }

    return messages;
  }
}

/// 默认AI提供商适配器实现
class DefaultAiProviderAdapter extends AiProviderAdapter {
  DefaultAiProviderAdapter({
    required super.provider,
    required super.assistant,
    required super.modelName,
  });

  @override
  Future<ChatProvider> createProvider({bool enableStreaming = false}) async {
    try {
      final backend = _mapProviderType(provider.type.name);

      final builder = LLMBuilder()
          .backend(backend)
          .model(modelName)
          .temperature(assistant.temperature)
          .topP(assistant.topP)
          .maxTokens(assistant.maxTokens)
          .systemPrompt(assistant.systemPrompt)
          .stream(enableStreaming);

      // 设置API密钥
      if (provider.apiKey.isNotEmpty) {
        builder.apiKey(provider.apiKey);
      }

      // 设置基础URL
      if (provider.baseUrl?.isNotEmpty == true) {
        builder.baseUrl(provider.baseUrl!);
      }

      // 设置推理参数（针对支持的模型）
      if (assistant.enableReasoning && _supportsReasoning()) {
        builder.reasoningEffort('medium');
      }

      return await builder.build();
    } catch (e) {
      _logger.error('创建AI提供商失败', {
        'provider': provider.name,
        'model': modelName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 映射提供商类型到AI Dart后端
  LLMBackend _mapProviderType(String type) {
    switch (type.toLowerCase()) {
      case 'openai':
        return LLMBackend.openai;
      case 'anthropic':
        return LLMBackend.anthropic;
      case 'google':
        return LLMBackend.google;
      case 'deepseek':
        return LLMBackend.deepseek;
      case 'ollama':
        return LLMBackend.ollama;
      case 'xai':
        return LLMBackend.xai;
      case 'phind':
        return LLMBackend.phind;
      case 'groq':
        return LLMBackend.groq;
      case 'elevenlabs':
        return LLMBackend.elevenlabs;
      default:
        throw ArgumentError('不支持的提供商类型: $type');
    }
  }

  /// 检查是否支持推理功能
  /// 现在基于模型能力而不是提供商类型来判断
  bool _supportsReasoning() {
    // 检查当前模型是否支持推理功能
    final model = provider.models.where((m) => m.name == modelName).firstOrNull;

    if (model != null) {
      return model.capabilities.contains(ModelCapability.reasoning);
    }

    // 如果找不到模型配置，默认不支持推理
    return false;
  }
}
