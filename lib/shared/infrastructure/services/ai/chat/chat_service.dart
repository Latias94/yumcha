import 'dart:async';
import 'dart:convert';
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/chat/domain/entities/message.dart';

import '../core/ai_response_models.dart';
import '../core/ai_service_base.dart';
import '../../mcp/mcp_service_manager.dart';
import 'package:llm_dart/llm_dart.dart';

/// 聊天服务 - AI对话功能的核心实现
///
/// ChatService是整个AI聊天系统的核心服务，负责处理所有与AI对话相关的功能：
///
/// ## 🎯 核心功能
///
/// ### 1. 单次聊天对话
/// - 发送消息并等待完整响应
/// - 支持文本、图像等多模态输入
/// - 自动处理上下文和历史消息
///
/// ### 2. 流式聊天对话
/// - 实时接收AI响应流
/// - 支持思考过程展示
/// - 支持工具调用进度显示
///
/// ### 3. 提供商管理
/// - 统一不同AI提供商的接口
/// - 自动适配提供商特性
/// - 提供商连接测试和验证
///
/// ### 4. 性能监控
/// - 请求响应时间统计
/// - 成功率和错误率跟踪
/// - 详细的日志记录
///
/// ## 🏗️ 架构设计
///
/// ```
/// ChatService
/// ├── AiProviderAdapter    # 提供商适配层
/// │   ├── OpenAI Adapter
/// │   ├── Anthropic Adapter
/// │   └── Other Adapters
/// ├── Statistics Tracker   # 统计信息收集
/// └── Request Context      # 请求上下文管理
/// ```
///
/// ## 🔧 支持的AI能力
/// - ✅ **chat**: 基础聊天对话
/// - ✅ **streaming**: 流式响应
/// - ✅ **toolCalling**: 工具调用
/// - ✅ **reasoning**: 推理思考
/// - ✅ **vision**: 视觉理解
///
/// ## 📊 性能特性
/// - **适配器缓存**: 复用提供商适配器实例
/// - **请求统计**: 实时收集性能数据
/// - **错误恢复**: 自动重试和错误处理
/// - **资源管理**: 自动清理连接和缓存
///
/// ## 🚀 使用示例
///
/// ### 单次聊天
/// ```dart
/// final response = await chatService.sendMessage(
///   provider: openaiProvider,
///   assistant: chatAssistant,
///   modelName: 'gpt-4',
///   chatHistory: previousMessages,
///   userMessage: 'Hello!',
/// );
/// ```
///
/// ### 流式聊天
/// ```dart
/// await for (final event in chatService.sendMessageStream(...)) {
///   if (event.isContent) {
///     updateUI(event.contentDelta);
///   }
/// }
/// ```
///
/// ### 提供商测试
/// ```dart
/// final isWorking = await chatService.testProvider(
///   provider: provider,
///   modelName: 'gpt-3.5-turbo',
/// );
/// ```
class ChatService extends AiServiceBase {
  // 单例模式实现 - 确保全局唯一的聊天服务实例
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  /// 提供商适配器缓存
  ///
  /// 缓存已创建的适配器实例以提升性能。缓存键格式：
  /// `{providerId}_{assistantId}_{modelName}`
  ///
  /// 这样可以：
  /// - 🚀 **提升性能**：避免重复创建适配器
  /// - 💾 **节省内存**：复用相同配置的适配器
  /// - 🔄 **保持状态**：维护适配器的内部状态
  final Map<String, AiProviderAdapter> _adapters = {};

  /// 服务统计信息缓存
  ///
  /// 按提供商ID存储统计信息，包括：
  /// - 📊 **请求统计**：总请求数、成功数、失败数
  /// - ⏱️ **性能数据**：平均响应时间、最长/最短耗时
  /// - 🕒 **时间信息**：最后请求时间、服务启动时间
  final Map<String, AiServiceStats> _stats = {};

  /// 服务初始化状态标记
  bool _isInitialized = false;

  @override
  String get serviceName => 'ChatService';

  @override
  Set<AiCapability> get supportedCapabilities => {
        AiCapability.chat, // 基础聊天对话
        AiCapability.streaming, // 流式响应
        AiCapability.toolCalling, // 工具调用
        AiCapability.reasoning, // 推理思考
        AiCapability.vision, // 视觉理解
      };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化聊天服务');
    _isInitialized = true;
    logger.info('聊天服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理聊天服务资源');
    _adapters.clear();
    _stats.clear();
    _isInitialized = false;
  }

  /// 发送聊天消息
  Future<AiResponse> sendMessage({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final context = AiRequestContext(
      requestId: requestId,
      config: AiServiceConfig(
        providerId: provider.id,
        modelName: modelName,
        enableStreaming: false,
      ),
    );

    logger.info('开始聊天请求', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'assistant': assistant.name,
    });

    try {
      // 获取或创建适配器
      final adapter = await _getOrCreateAdapter(provider, assistant, modelName);

      // 创建提供商实例
      final chatProvider = await adapter.createProvider(enableStreaming: false);

      // 构建消息列表
      final messages = _buildMessageList(adapter, chatHistory, userMessage);

      // 获取MCP工具（如果助手启用了工具功能）
      final tools = assistant.enableTools
          ? await _getMcpTools(assistant.mcpServerIds)
          : <Tool>[];

      // 发送请求并处理工具调用
      var conversation = List<ChatMessage>.from(messages);
      var finalResponse = tools.isNotEmpty
          ? await chatProvider.chatWithTools(conversation, tools)
          : await chatProvider.chat(conversation);

      // 处理工具调用（如果有）
      if (finalResponse.toolCalls != null &&
          finalResponse.toolCalls!.isNotEmpty) {
        finalResponse = await _handleToolCalls(
          chatProvider,
          conversation,
          finalResponse,
          assistant.mcpServerIds,
        );
      }

      final duration = context.elapsed;

      // 更新统计信息
      _updateStats(provider.id, true, duration);

      // 调试：检查非流式响应内容
      final responseText = finalResponse.text ?? '';
      logger.debug('ChatService: 非流式响应内容', {
        'content': responseText,
        'contentLength': responseText.length,
        'contentBytes': responseText.codeUnits,
      });

      logger.info('聊天请求完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'hasThinking': finalResponse.thinking != null,
        'usage': finalResponse.usage?.totalTokens,
        'hadToolCalls': finalResponse.toolCalls?.isNotEmpty == true,
      });

      return AiResponse.success(
        content: responseText,
        thinking: finalResponse.thinking,
        usage: finalResponse.usage,
        duration: duration,
        toolCalls: finalResponse.toolCalls,
      );
    } catch (e) {
      final duration = context.elapsed;
      _updateStats(provider.id, false, duration);

      logger.error('聊天请求失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return AiResponse.error(error: '聊天请求失败: $e', duration: duration);
    }
  }

  /// 发送流式聊天消息
  Stream<AiStreamEvent> sendMessageStream({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    await initialize();

    final requestId = _generateRequestId();
    final context = AiRequestContext(
      requestId: requestId,
      config: AiServiceConfig(
        providerId: provider.id,
        modelName: modelName,
        enableStreaming: true,
      ),
    );

    logger.info('开始流式聊天请求', {
      'requestId': requestId,
      'provider': provider.name,
      'model': modelName,
      'assistant': assistant.name,
    });

    try {
      // 获取或创建适配器
      final adapter = await _getOrCreateAdapter(provider, assistant, modelName);

      // 创建流式提供商实例
      final chatProvider = await adapter.createProvider(enableStreaming: true);

      // 构建消息列表
      final messages = _buildMessageList(adapter, chatHistory, userMessage);

      // 获取MCP工具（如果助手启用了工具功能）
      final tools = assistant.enableTools
          ? await _getMcpTools(assistant.mcpServerIds)
          : <Tool>[];

      // 发送流式请求 - 支持工具调用
      final stream = tools.isNotEmpty
          ? chatProvider.chatStream(messages, tools: tools)
          : chatProvider.chatStream(messages);

      String? finalThinking;
      List<ToolCall>? allToolCalls;

      await for (final event in stream) {
        switch (event) {
          case TextDeltaEvent(delta: final delta):
            // 调试：检查从llm_dart接收到的内容
            logger.debug('ChatService: 接收到TextDeltaEvent', {
              'delta': delta,
              'deltaLength': delta.length,
              'deltaBytes': delta.codeUnits,
            });
            yield AiStreamEvent.contentDelta(delta);
            break;
          case ThinkingDeltaEvent(delta: final delta):
            yield AiStreamEvent.thinkingDelta(delta);
            break;
          case ToolCallDeltaEvent(toolCall: final toolCall):
            yield AiStreamEvent.toolCall(toolCall);
            allToolCalls ??= [];
            allToolCalls.add(toolCall);
            break;
          case CompletionEvent(response: final response):
            finalThinking = response.thinking;
            final duration = context.elapsed;

            _updateStats(provider.id, true, duration);

            logger.info('流式聊天请求完成', {
              'requestId': requestId,
              'duration': '${duration.inMilliseconds}ms',
              'hasThinking': finalThinking != null,
              'usage': response.usage?.totalTokens,
            });

            yield AiStreamEvent.completed(
              finalThinking: finalThinking,
              usage: response.usage,
              duration: duration,
              allToolCalls: allToolCalls,
            );
            break;
          case ErrorEvent(error: final error):
            final duration = context.elapsed;
            _updateStats(provider.id, false, duration);

            logger.error('流式聊天请求出错', {
              'requestId': requestId,
              'error': error.toString(),
              'duration': '${duration.inMilliseconds}ms',
            });

            yield AiStreamEvent.error(error.toString());
            break;
        }
      }
    } catch (e) {
      final duration = context.elapsed;
      _updateStats(provider.id, false, duration);

      logger.error('流式聊天请求失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      yield AiStreamEvent.error('流式聊天请求失败: $e');
    }
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required models.AiProvider provider,
    String? modelName,
  }) async {
    await initialize();

    try {
      // 创建测试助手
      final testAssistant = _createTestAssistant();
      final testModel = modelName ?? _getDefaultModel(provider);

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: testAssistant,
        modelName: testModel,
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 发送测试消息
      final testMessages = [ChatMessage.user('Hello')];
      final response = await chatProvider.chat(testMessages);

      logger.info('提供商测试成功', {
        'provider': provider.name,
        'model': testModel,
        'responseLength': response.text?.length ?? 0,
      });

      return response.text?.isNotEmpty == true;
    } catch (e) {
      logger.error('提供商测试失败', {
        'provider': provider.name,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 获取服务统计信息
  AiServiceStats getStats(String providerId) {
    return _stats[providerId] ?? AiServiceStats();
  }

  /// 获取或创建适配器
  Future<AiProviderAdapter> _getOrCreateAdapter(
    models.AiProvider provider,
    AiAssistant assistant,
    String modelName,
  ) async {
    final key = '${provider.id}_${assistant.id}_$modelName';

    if (!_adapters.containsKey(key)) {
      _adapters[key] = DefaultAiProviderAdapter(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
      );
    }

    return _adapters[key]!;
  }

  /// 构建消息列表
  List<ChatMessage> _buildMessageList(
    AiProviderAdapter adapter,
    List<Message> chatHistory,
    String userMessage,
  ) {
    final messages = <ChatMessage>[];

    // 添加系统消息
    messages.addAll(adapter.buildSystemMessages());

    // 添加聊天历史
    messages.addAll(adapter.convertMessages(chatHistory));

    // 添加用户消息
    messages.add(ChatMessage.user(userMessage));

    return messages;
  }

  /// 创建测试助手
  AiAssistant _createTestAssistant() {
    return AiAssistant(
      id: 'test-assistant',
      name: 'Test Assistant',
      avatar: '🤖',
      systemPrompt: '',
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 10,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Test assistant for provider validation',
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

  /// 获取提供商的第一个可用模型作为默认模型
  String _getDefaultModel(models.AiProvider provider) {
    // 如果提供商有配置的模型，使用第一个
    if (provider.models.isNotEmpty) {
      return provider.models.first.name;
    }

    // 否则根据提供商类型返回常见的模型名
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return 'gpt-4o-mini';
      case 'anthropic':
        return 'claude-3-5-haiku-20241022';
      case 'google':
        return 'gemini-1.5-flash';
      case 'deepseek':
        return 'deepseek-chat'; // 或 deepseek-reasoner 用于推理
      case 'ollama':
        return 'llama3.2';
      case 'xai':
        return 'grok-2-latest';
      case 'groq':
        return 'llama-3.1-8b-instant';
      case 'mistral':
        return 'mistral-large-latest';
      case 'cohere':
        return 'command-r-plus';
      case 'perplexity':
        return 'llama-3.1-sonar-small-128k-online';
      default:
        return 'default-model';
    }
  }

  /// 更新统计信息
  void _updateStats(String providerId, bool success, Duration duration) {
    final currentStats = _stats[providerId] ?? AiServiceStats();

    _stats[providerId] = currentStats.copyWith(
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
    return 'chat_${DateTime.now().millisecondsSinceEpoch}_${_stats.length}';
  }

  /// 获取MCP工具列表
  ///
  /// @param mcpServerIds 助手配置的MCP服务器ID列表
  /// @returns 可用的MCP工具列表，转换为llm_dart的Tool格式
  Future<List<Tool>> _getMcpTools(List<String> mcpServerIds) async {
    if (mcpServerIds.isEmpty) {
      return [];
    }

    try {
      // 获取MCP服务管理器
      final mcpManager = McpServiceManager();

      // 获取可用的MCP工具
      final mcpTools = await mcpManager.getAvailableTools(mcpServerIds);

      if (mcpTools.isEmpty) {
        logger.info('未找到可用的MCP工具', {
          'serverIds': mcpServerIds,
        });
        return [];
      }

      // 转换为llm_dart的Tool格式
      final tools = mcpTools.map((mcpTool) {
        return Tool.function(
          name: mcpTool.name,
          description: mcpTool.description ?? '无描述',
          parameters: _convertMcpSchemaToParametersSchema(mcpTool.inputSchema),
        );
      }).toList();

      logger.info('MCP工具集成成功', {
        'serverIds': mcpServerIds,
        'toolCount': tools.length,
        'tools': mcpTools.map((t) => t.name).toList(),
      });

      return tools;
    } catch (e) {
      logger.error('MCP工具集成失败', {
        'serverIds': mcpServerIds,
        'error': e.toString(),
      });
      return [];
    }
  }

  /// 处理工具调用
  Future<ChatResponse> _handleToolCalls(
    ChatCapability chatProvider,
    List<ChatMessage> conversation,
    ChatResponse response,
    List<String> mcpServerIds,
  ) async {
    // 添加AI的工具调用消息
    conversation.add(ChatMessage.toolUse(
      toolCalls: response.toolCalls!,
      content: response.text ?? '',
    ));

    // 执行所有工具调用
    for (final toolCall in response.toolCalls!) {
      try {
        final result = await _executeToolCall(toolCall, mcpServerIds);

        // 添加工具结果到对话
        conversation.add(ChatMessage.toolResult(
          results: [toolCall],
          content: result,
        ));

        logger.info('工具调用成功', {
          'toolName': toolCall.function.name,
          'resultLength': result.length,
        });
      } catch (e) {
        // 工具调用失败，添加错误信息
        final errorMessage = '工具调用失败: $e';
        conversation.add(ChatMessage.toolResult(
          results: [toolCall],
          content: errorMessage,
        ));

        logger.error('工具调用失败', {
          'toolName': toolCall.function.name,
          'error': e.toString(),
        });
      }
    }

    // 获取最终响应
    return await chatProvider.chat(conversation);
  }

  /// 执行单个工具调用
  Future<String> _executeToolCall(
      ToolCall toolCall, List<String> mcpServerIds) async {
    try {
      // 解析工具参数
      final arguments =
          jsonDecode(toolCall.function.arguments) as Map<String, dynamic>;

      // 通过MCP服务管理器调用工具
      final mcpManager = McpServiceManager();
      final result =
          await mcpManager.callTool(toolCall.function.name, arguments);

      // 处理结果
      if (result['error'] != null) {
        return '错误: ${result['error']}';
      }

      if (result['text'] != null) {
        return result['text'] as String;
      }

      // 如果有其他类型的内容，转换为字符串
      return result.toString();
    } catch (e) {
      logger.error('执行工具调用时出错', {
        'toolName': toolCall.function.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 将MCP输入模式转换为llm_dart参数模式
  ParametersSchema _convertMcpSchemaToParametersSchema(
      Map<String, dynamic>? inputSchema) {
    if (inputSchema == null) {
      return ParametersSchema(
        schemaType: 'object',
        properties: {},
        required: [],
      );
    }

    // 提取属性定义
    final properties = <String, ParameterProperty>{};
    final mcpProperties =
        inputSchema['properties'] as Map<String, dynamic>? ?? {};

    for (final entry in mcpProperties.entries) {
      final propName = entry.key;
      final propDef = entry.value as Map<String, dynamic>;

      properties[propName] = ParameterProperty(
        propertyType: propDef['type'] as String? ?? 'string',
        description: propDef['description'] as String? ?? '',
        enumList: (propDef['enum'] as List?)?.cast<String>(),
      );
    }

    // 提取必需参数
    final required = (inputSchema['required'] as List?)?.cast<String>() ?? [];

    return ParametersSchema(
      schemaType: inputSchema['type'] as String? ?? 'object',
      properties: properties,
      required: required,
    );
  }
}
