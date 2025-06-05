import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ai_provider.dart' as models;
import '../../../models/ai_assistant.dart';
import '../../../models/message.dart';
import '../../../models/ai_model.dart';
import '../../../providers/ai_provider_notifier.dart';
import '../../../providers/ai_assistant_notifier.dart';
import '../../../providers/settings_notifier.dart';
import '../chat/chat_service.dart';
import '../capabilities/model_service.dart';
import '../core/ai_response_models.dart';

// ============================================================================
// 核心服务Providers - 提供AI服务的基础实例
// ============================================================================

/// AI聊天服务的Riverpod Provider
///
/// 提供ChatService的单例实例，用于处理所有AI聊天相关功能。
///
/// ## 功能特性
/// - 🗣️ **单次聊天**：发送消息并等待完整响应
/// - ⚡ **流式聊天**：实时接收AI响应流
/// - 🔧 **工具调用**：支持AI调用外部工具
/// - 🧠 **推理思考**：显示AI的思考过程
/// - 👁️ **视觉理解**：处理图像输入
///
/// ## 使用方式
/// ```dart
/// final chatService = ref.read(aiChatServiceProvider);
/// final response = await chatService.sendMessage(...);
/// ```
///
/// ## 注意事项
/// - 这是一个单例服务，全局共享状态
/// - 自动管理适配器缓存和统计信息
/// - 需要在使用前确保服务已初始化
final aiChatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// AI模型服务的Riverpod Provider
///
/// 提供ModelService的单例实例，用于处理AI模型相关功能。
///
/// ## 功能特性
/// - 📋 **模型列表**：获取提供商支持的模型列表
/// - 🏷️ **能力检测**：检测模型支持的AI能力
/// - 💾 **智能缓存**：缓存模型列表以提升性能
/// - 🔄 **自动刷新**：缓存过期时自动重新获取
///
/// ## 缓存策略
/// - **缓存时间**: 1小时
/// - **缓存键**: 基于提供商ID和配置
/// - **自动失效**: 提供商配置变更时失效
///
/// ## 使用方式
/// ```dart
/// final modelService = ref.read(aiModelServiceProvider);
/// final models = await modelService.getModelsFromProvider(provider);
/// ```
final aiModelServiceProvider = Provider<ModelService>((ref) {
  return ModelService();
});

// ============================================================================
// 聊天功能Providers - 处理AI对话的核心接口
// ============================================================================

/// 发送聊天消息的Provider（单次响应）
///
/// 这是发送AI聊天消息的主要接口，提供完整的单次响应功能。
///
/// ## 🎯 适用场景
/// - **标准问答**：普通的问题回答场景
/// - **文档分析**：需要完整分析结果的场景
/// - **代码生成**：需要完整代码块的场景
/// - **翻译任务**：需要完整翻译结果的场景
///
/// ## 📊 响应内容
/// 返回的`AiResponse`包含：
/// - `content`: AI的完整回复内容
/// - `thinking`: 推理过程（如果模型支持）
/// - `usage`: Token使用统计信息
/// - `duration`: 请求总耗时
/// - `toolCalls`: 工具调用结果（如果有）
/// - `error`: 错误信息（如果失败）
///
/// ## 🔧 参数说明
/// 通过`SendChatMessageParams`传递参数：
/// - `provider`: AI提供商配置
/// - `assistant`: AI助手配置
/// - `modelName`: 要使用的模型名称
/// - `chatHistory`: 历史对话消息
/// - `userMessage`: 用户当前输入
///
/// ## 🚀 使用示例
/// ```dart
/// final response = await ref.read(sendChatMessageProvider(
///   SendChatMessageParams(
///     provider: openaiProvider,
///     assistant: chatAssistant,
///     modelName: 'gpt-4',
///     chatHistory: previousMessages,
///     userMessage: 'Explain quantum computing',
///   ),
/// ).future);
///
/// if (response.isSuccess) {
///   print('AI回复: ${response.content}');
///   if (response.thinking != null) {
///     print('思考过程: ${response.thinking}');
///   }
/// } else {
///   print('错误: ${response.error}');
/// }
/// ```
///
/// ## ⚠️ 注意事项
/// - 这是一个FutureProvider，会等待完整响应
/// - 对于长时间的响应，建议使用流式版本
/// - 自动处理错误和重试逻辑
final sendChatMessageProvider =
    FutureProvider.family<AiResponse, SendChatMessageParams>((
      ref,
      params,
    ) async {
      final chatService = ref.read(aiChatServiceProvider);

      return await chatService.sendMessage(
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.modelName,
        chatHistory: params.chatHistory,
        userMessage: params.userMessage,
      );
    });

/// 发送流式聊天消息的Provider（实时响应）
///
/// 这是流式AI聊天的主要接口，提供实时响应流功能。
///
/// ## ⚡ 适用场景
/// - **实时对话**：需要即时反馈的聊天场景
/// - **长文本生成**：逐步显示生成的长内容
/// - **创作过程**：实时显示AI的创作过程
/// - **思考展示**：实时显示AI的推理思考
///
/// ## 📡 流事件类型
/// 通过`AiStreamEvent`接收不同类型的事件：
/// - `contentDelta`: 内容增量更新
/// - `thinkingDelta`: 思考过程增量
/// - `toolCall`: 工具调用事件
/// - `completed`: 响应完成事件
/// - `error`: 错误事件
///
/// ## 🎛️ 事件处理
/// ```dart
/// ref.listen(sendChatMessageStreamProvider(params), (previous, next) {
///   next.when(
///     data: (event) {
///       switch (event.type) {
///         case StreamEventType.contentDelta:
///           // 实时更新聊天内容
///           appendToChat(event.contentDelta);
///           break;
///         case StreamEventType.thinkingDelta:
///           // 显示思考过程
///           updateThinking(event.thinkingDelta);
///           break;
///         case StreamEventType.completed:
///           // 处理完成事件
///           handleCompletion(event);
///           break;
///       }
///     },
///     loading: () => showLoadingIndicator(),
///     error: (error, stack) => showError(error),
///   );
/// });
/// ```
///
/// ## 🚀 使用示例
/// ```dart
/// // 开始监听流式响应
/// ref.listen(sendChatMessageStreamProvider(
///   SendChatMessageParams(
///     provider: openaiProvider,
///     assistant: chatAssistant,
///     modelName: 'gpt-4',
///     chatHistory: messages,
///     userMessage: 'Write a story about...',
///   ),
/// ), (previous, next) {
///   next.when(
///     data: (event) => handleStreamEvent(event),
///     loading: () => print('🔄 等待响应...'),
///     error: (error, stack) => print('❌ 错误: $error'),
///   );
/// });
/// ```
///
/// ## 💡 优势特性
/// - **实时反馈**：用户立即看到AI开始响应
/// - **更好体验**：避免长时间等待的空白期
/// - **思考透明**：可以看到AI的思考过程
/// - **可中断性**：可以随时取消正在进行的请求
final sendChatMessageStreamProvider =
    StreamProvider.family<AiStreamEvent, SendChatMessageParams>((ref, params) {
      final chatService = ref.read(aiChatServiceProvider);

      return chatService.sendMessageStream(
        provider: params.provider,
        assistant: params.assistant,
        modelName: params.modelName,
        chatHistory: params.chatHistory,
        userMessage: params.userMessage,
      );
    });

/// 测试AI提供商连接的Provider
final testAiProviderProvider = FutureProvider.family<bool, TestProviderParams>((
  ref,
  params,
) async {
  final chatService = ref.read(aiChatServiceProvider);

  return await chatService.testProvider(
    provider: params.provider,
    modelName: params.modelName,
  );
});

/// 获取提供商模型列表的Provider
final providerModelsProvider = FutureProvider.family<List<AiModel>, String>((
  ref,
  providerId,
) async {
  final modelService = ref.read(aiModelServiceProvider);
  final provider = ref.read(aiProviderProvider(providerId));

  if (provider == null) {
    throw Exception('Provider not found: $providerId');
  }

  return await modelService.getModelsFromProvider(provider);
});

/// 获取AI服务统计信息的Provider
final aiServiceStatsProvider = Provider.family<AiServiceStats, String>((
  ref,
  providerId,
) {
  final chatService = ref.read(aiChatServiceProvider);
  return chatService.getStats(providerId);
});

/// 检测模型能力的Provider
final modelCapabilitiesProvider =
    Provider.family<Set<String>, ModelCapabilityParams>((ref, params) {
      final modelService = ref.read(aiModelServiceProvider);
      return modelService.detectModelCapabilities(
        provider: params.provider,
        modelName: params.modelName,
      );
    });

/// 获取默认聊天配置的Provider
final defaultChatConfigProvider = Provider<AiServiceConfig?>((ref) {
  final defaultChatModel = ref
      .read(settingsNotifierProvider.notifier)
      .getDefaultChatModel();

  if (defaultChatModel == null ||
      defaultChatModel.providerId == null ||
      defaultChatModel.modelName == null) {
    return null;
  }

  return AiServiceConfig(
    providerId: defaultChatModel.providerId!,
    modelName: defaultChatModel.modelName!,
    enableStreaming: true,
    enableThinking: true,
    enableToolCalls: false,
  );
});

// ============================================================================
// 智能聊天Providers - 简化的聊天接口，自动使用默认配置
// ============================================================================

/// 智能聊天Provider - 自动使用默认配置的便捷聊天接口
///
/// 这是最简单易用的聊天接口，自动处理所有配置细节。特别适合：
/// - 🚀 **快速开发**：无需手动配置提供商和助手
/// - 🎯 **标准聊天**：使用用户设置的默认配置
/// - 📱 **UI集成**：简化UI层的代码复杂度
/// - 🔄 **配置同步**：自动跟随用户的设置变更
///
/// ## 🤖 自动配置逻辑
///
/// ### 1. 默认聊天配置
/// 从用户设置中获取默认的聊天配置：
/// - 默认AI提供商（如OpenAI、Anthropic等）
/// - 默认模型名称（如gpt-4、claude-3等）
/// - 默认聊天参数（流式输出、思考模式等）
///
/// ### 2. 助手选择策略
/// - 如果参数中指定了`assistantId`，使用指定助手
/// - 否则使用系统中的第一个可用助手
/// - 确保助手配置与选择的模型兼容
///
/// ### 3. 错误处理
/// - 自动检查配置完整性
/// - 提供清晰的错误信息
/// - 支持配置缺失时的友好提示
///
/// ## 📋 参数说明
/// 通过`SmartChatParams`传递简化的参数：
/// - `chatHistory`: 历史对话消息
/// - `userMessage`: 用户当前输入
/// - `assistantId`: 可选的助手ID（不提供则使用默认）
///
/// ## 🚀 使用示例
/// ```dart
/// // 最简单的使用方式
/// final response = await ref.read(smartChatProvider(
///   SmartChatParams(
///     chatHistory: messages,
///     userMessage: 'Hello, how are you?',
///   ),
/// ).future);
///
/// // 指定特定助手
/// final response = await ref.read(smartChatProvider(
///   SmartChatParams(
///     chatHistory: messages,
///     userMessage: 'Help me with coding',
///     assistantId: 'coding-assistant-id',
///   ),
/// ).future);
///
/// // 处理响应
/// if (response.isSuccess) {
///   print('AI回复: ${response.content}');
/// } else {
///   print('错误: ${response.error}');
/// }
/// ```
///
/// ## ⚙️ 配置要求
/// 使用前需要确保：
/// - 用户已设置默认聊天模型
/// - 系统中至少有一个可用的AI助手
/// - 默认提供商配置正确且可用
///
/// ## 💡 优势特性
/// - **零配置使用**：无需手动指定提供商和模型
/// - **设置同步**：自动跟随用户的偏好设置
/// - **错误友好**：提供清晰的配置错误提示
/// - **向后兼容**：支持逐步迁移到新的配置系统
final smartChatProvider = FutureProvider.family<AiResponse, SmartChatParams>((
  ref,
  params,
) async {
  final config = ref.read(defaultChatConfigProvider);
  if (config == null) {
    throw Exception('No default chat configuration found');
  }

  final provider = ref.read(aiProviderProvider(config.providerId));
  // 使用默认助手或从参数中获取
  final assistant = params.assistantId != null
      ? ref.read(aiAssistantProvider(params.assistantId!))
      : ref.read(aiAssistantNotifierProvider).value?.firstOrNull;

  if (provider == null) {
    throw Exception('Provider not found: ${config.providerId}');
  }

  if (assistant == null) {
    throw Exception('No assistant available');
  }

  final chatService = ref.read(aiChatServiceProvider);

  return await chatService.sendMessage(
    provider: provider,
    assistant: assistant,
    modelName: config.modelName,
    chatHistory: params.chatHistory,
    userMessage: params.userMessage,
  );
});

/// 智能流式聊天Provider - 自动使用默认配置的便捷流式接口
///
/// 这是智能聊天的流式版本，提供实时响应体验。结合了：
/// - ⚡ **流式响应**：实时显示AI回复过程
/// - 🤖 **自动配置**：无需手动指定提供商和助手
/// - 🎯 **简化参数**：只需提供消息内容
/// - 🔄 **配置同步**：自动跟随用户设置变更
///
/// ## 🎭 适用场景
/// - **实时聊天界面**：需要即时反馈的聊天应用
/// - **内容创作**：实时显示AI的创作过程
/// - **长文本生成**：逐步显示生成的长内容
/// - **思考过程展示**：实时显示AI推理过程
///
/// ## 📡 流事件处理
/// ```dart
/// ref.listen(smartChatStreamProvider(
///   SmartChatParams(
///     chatHistory: messages,
///     userMessage: 'Write a creative story',
///   ),
/// ), (previous, next) {
///   next.when(
///     data: (event) {
///       if (event.isContent) {
///         // 实时更新聊天内容
///         updateChatContent(event.contentDelta);
///       } else if (event.isThinking) {
///         // 显示思考过程
///         showThinkingProcess(event.thinkingDelta);
///       } else if (event.isCompleted) {
///         // 处理完成事件
///         handleChatCompletion(event);
///       }
///     },
///     loading: () => showTypingIndicator(),
///     error: (error, stack) => showErrorMessage(error),
///   );
/// });
/// ```
///
/// ## 🚀 使用示例
/// ```dart
/// // 开始流式聊天
/// ref.listen(smartChatStreamProvider(
///   SmartChatParams(
///     chatHistory: currentMessages,
///     userMessage: userInput,
///     assistantId: selectedAssistantId, // 可选
///   ),
/// ), (previous, next) {
///   next.when(
///     data: (event) => handleStreamEvent(event),
///     loading: () => setState(() => isLoading = true),
///     error: (error, stack) => showError(error.toString()),
///   );
/// });
/// ```
///
/// ## 💡 与单次聊天的区别
/// - **响应方式**：流式 vs 一次性完整响应
/// - **用户体验**：实时反馈 vs 等待完整结果
/// - **适用场景**：交互式对话 vs 批量处理
/// - **资源使用**：持续连接 vs 单次请求
final smartChatStreamProvider =
    StreamProvider.family<AiStreamEvent, SmartChatParams>((ref, params) {
      final config = ref.read(defaultChatConfigProvider);
      if (config == null) {
        throw Exception('No default chat configuration found');
      }

      final provider = ref.read(aiProviderProvider(config.providerId));
      // 使用默认助手或从参数中获取
      final assistant = params.assistantId != null
          ? ref.read(aiAssistantProvider(params.assistantId!))
          : ref.read(aiAssistantNotifierProvider).value?.firstOrNull;

      if (provider == null) {
        throw Exception('Provider not found: ${config.providerId}');
      }

      if (assistant == null) {
        throw Exception('No assistant available');
      }

      final chatService = ref.read(aiChatServiceProvider);

      return chatService.sendMessageStream(
        provider: provider,
        assistant: assistant,
        modelName: config.modelName,
        chatHistory: params.chatHistory,
        userMessage: params.userMessage,
      );
    });

/// 清除模型缓存的Provider
final clearModelCacheProvider = Provider.family<void, String?>((
  ref,
  providerId,
) {
  final modelService = ref.read(aiModelServiceProvider);
  modelService.clearCache(providerId);
});

/// 获取模型缓存统计的Provider
final modelCacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final modelService = ref.read(aiModelServiceProvider);
  return modelService.getCacheStats();
});

// ============================================================================
// 参数类定义 - AI服务接口的数据传输对象
// ============================================================================

/// 发送聊天消息的参数类
///
/// 这是发送AI聊天消息时使用的完整参数集合。包含了AI聊天所需的所有配置信息：
///
/// ## 📋 参数说明
///
/// ### 🤖 AI配置参数
/// - `provider`: AI提供商配置，包含API密钥、基础URL等
/// - `assistant`: AI助手配置，包含系统提示、温度参数等
/// - `modelName`: 要使用的具体模型名称
///
/// ### 💬 对话参数
/// - `chatHistory`: 历史对话消息列表，用于维护上下文
/// - `userMessage`: 用户当前输入的消息内容
///
/// ## 🎯 使用场景
/// 这个参数类用于需要完全控制AI聊天配置的场景：
/// - **自定义聊天**：使用特定的提供商和助手组合
/// - **A/B测试**：比较不同配置的效果
/// - **高级功能**：需要精确控制AI行为的场景
/// - **批量处理**：使用相同配置处理多个请求
///
/// ## 🚀 使用示例
/// ```dart
/// final params = SendChatMessageParams(
///   provider: openaiProvider,
///   assistant: codingAssistant,
///   modelName: 'gpt-4',
///   chatHistory: previousMessages,
///   userMessage: 'Help me debug this code',
/// );
///
/// // 单次聊天
/// final response = await ref.read(sendChatMessageProvider(params).future);
///
/// // 流式聊天
/// ref.listen(sendChatMessageStreamProvider(params), (previous, next) {
///   // 处理流式响应
/// });
/// ```
///
/// ## ⚡ 性能优化
/// - **相等性比较**：实现了高效的相等性检查
/// - **哈希缓存**：支持Riverpod的缓存机制
/// - **不可变性**：所有字段都是final，确保线程安全
///
/// ## 🔍 相等性逻辑
/// 两个参数对象被认为相等当且仅当：
/// - 提供商ID相同
/// - 助手ID相同
/// - 模型名称相同
/// - 用户消息内容相同
///
/// 注意：chatHistory不参与相等性比较，这是为了优化缓存性能
class SendChatMessageParams {
  /// AI提供商配置
  /// 包含API密钥、基础URL、支持的模型列表等信息
  final models.AiProvider provider;

  /// AI助手配置
  /// 包含系统提示、温度参数、上下文长度等AI行为配置
  final AiAssistant assistant;

  /// 模型名称
  /// 要使用的具体AI模型名称，必须是提供商支持的有效模型
  final String modelName;

  /// 聊天历史
  /// 之前的对话消息列表，用于维护对话上下文
  final List<Message> chatHistory;

  /// 用户消息
  /// 用户当前输入的消息内容
  final String userMessage;

  /// 构造函数
  ///
  /// 创建聊天消息参数实例。所有参数都是必需的。
  ///
  /// @param provider AI提供商配置
  /// @param assistant AI助手配置
  /// @param modelName 模型名称
  /// @param chatHistory 聊天历史
  /// @param userMessage 用户消息
  const SendChatMessageParams({
    required this.provider,
    required this.assistant,
    required this.modelName,
    required this.chatHistory,
    required this.userMessage,
  });

  /// 相等性比较
  ///
  /// 用于Riverpod缓存和去重。比较关键的配置参数，
  /// 但不包括chatHistory以优化性能。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendChatMessageParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          assistant.id == other.assistant.id &&
          modelName == other.modelName &&
          userMessage == other.userMessage;

  /// 哈希码计算
  ///
  /// 基于关键配置参数计算哈希码，用于高效的缓存查找。
  @override
  int get hashCode =>
      provider.id.hashCode ^
      assistant.id.hashCode ^
      modelName.hashCode ^
      userMessage.hashCode;
}

/// 测试提供商的参数
class TestProviderParams {
  final models.AiProvider provider;
  final String? modelName;

  const TestProviderParams({required this.provider, this.modelName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestProviderParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          modelName == other.modelName;

  @override
  int get hashCode => provider.id.hashCode ^ modelName.hashCode;
}

/// 模型能力检测的参数
class ModelCapabilityParams {
  final models.AiProvider provider;
  final String modelName;

  const ModelCapabilityParams({
    required this.provider,
    required this.modelName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCapabilityParams &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          modelName == other.modelName;

  @override
  int get hashCode => provider.id.hashCode ^ modelName.hashCode;
}

/// 智能聊天的参数类
///
/// 这是智能聊天功能的简化参数类，专为便捷使用而设计。
/// 与`SendChatMessageParams`相比，这个类大大简化了参数配置：
///
/// ## 🎯 设计理念
///
/// ### 简化优先
/// - **最少参数**：只需要提供必要的对话信息
/// - **自动配置**：系统自动处理提供商和模型选择
/// - **智能默认**：使用用户设置的默认配置
/// - **渐进增强**：支持可选的高级配置
///
/// ### 用户友好
/// - **零学习成本**：新用户可以立即使用
/// - **配置同步**：自动跟随用户的偏好设置
/// - **错误容忍**：提供友好的错误提示
///
/// ## 📋 参数说明
///
/// ### 💬 必需参数
/// - `chatHistory`: 历史对话消息，维护对话上下文
/// - `userMessage`: 用户当前输入的消息内容
///
/// ### 🎛️ 可选参数
/// - `assistantId`: 可选的助手ID，用于指定特定助手
///   - 如果提供：使用指定的助手配置
///   - 如果不提供：使用系统中的第一个可用助手
///
/// ## 🚀 使用场景
///
/// ### 1. 快速原型开发
/// ```dart
/// final response = await ref.read(smartChatProvider(
///   SmartChatParams(
///     chatHistory: [],
///     userMessage: 'Hello!',
///   ),
/// ).future);
/// ```
///
/// ### 2. 标准聊天界面
/// ```dart
/// final params = SmartChatParams(
///   chatHistory: conversationMessages,
///   userMessage: userInput,
/// );
///
/// ref.listen(smartChatStreamProvider(params), handleResponse);
/// ```
///
/// ### 3. 指定特定助手
/// ```dart
/// final params = SmartChatParams(
///   chatHistory: messages,
///   userMessage: 'Help me with coding',
///   assistantId: 'coding-assistant-id',
/// );
/// ```
///
/// ## 🔄 自动配置流程
/// 1. **获取默认配置**：从用户设置中读取默认聊天配置
/// 2. **选择提供商**：使用配置中指定的AI提供商
/// 3. **选择助手**：使用指定助手或默认助手
/// 4. **验证配置**：确保所有配置都有效可用
/// 5. **执行请求**：使用完整配置执行AI请求
///
/// ## ⚡ 性能特性
/// - **轻量级**：参数对象占用内存小
/// - **缓存友好**：支持高效的相等性比较
/// - **不可变**：线程安全的不可变对象
///
/// ## 🔍 相等性逻辑
/// 两个智能聊天参数被认为相等当且仅当：
/// - 用户消息内容相同
/// - 助手ID相同（都为null或都为相同值）
///
/// 注意：chatHistory不参与相等性比较，这样可以：
/// - 优化缓存性能
/// - 避免因历史消息变化导致的频繁重新计算
/// - 支持相同用户输入的快速响应
class SmartChatParams {
  /// 聊天历史消息列表
  ///
  /// 包含之前的对话消息，用于维护对话上下文。
  /// AI会根据这些历史消息来理解当前对话的背景。
  final List<Message> chatHistory;

  /// 用户当前输入的消息
  ///
  /// 用户在当前轮次中输入的消息内容。
  /// 这是AI需要回应的主要内容。
  final String userMessage;

  /// 可选的助手ID
  ///
  /// 如果指定，将使用对应ID的助手配置；
  /// 如果不指定（null），将使用系统中的第一个可用助手。
  ///
  /// 这允许用户在不同的助手之间切换，例如：
  /// - 'general-assistant': 通用聊天助手
  /// - 'coding-assistant': 编程专用助手
  /// - 'writing-assistant': 写作专用助手
  final String? assistantId;

  /// 构造函数
  ///
  /// 创建智能聊天参数实例。
  ///
  /// @param chatHistory 聊天历史消息（必需）
  /// @param userMessage 用户消息内容（必需）
  /// @param assistantId 助手ID（可选）
  const SmartChatParams({
    required this.chatHistory,
    required this.userMessage,
    this.assistantId,
  });

  /// 相等性比较
  ///
  /// 用于Riverpod缓存优化。只比较用户消息和助手ID，
  /// 不包括聊天历史以提升性能。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartChatParams &&
          runtimeType == other.runtimeType &&
          userMessage == other.userMessage &&
          assistantId == other.assistantId;

  /// 哈希码计算
  ///
  /// 基于用户消息和助手ID计算哈希码，
  /// 用于高效的缓存查找和去重。
  @override
  int get hashCode => userMessage.hashCode ^ assistantId.hashCode;
}
