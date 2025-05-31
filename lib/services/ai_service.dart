import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain/langchain.dart';
import 'dart:async';
import '../models/ai_provider.dart';
import '../models/ai_assistant.dart';
import '../models/message.dart';
import 'notification_service.dart';
import 'logger_service.dart';

// 调试信息类
class DebugInfo {
  final String assistantId;
  final String providerId;
  final String modelName;
  final Map<String, dynamic> requestBody;
  final int? statusCode;
  final String? response;
  final String? error;
  final DateTime timestamp;
  final Duration? duration;
  final bool wasStopped;

  DebugInfo({
    required this.assistantId,
    required this.providerId,
    required this.modelName,
    required this.requestBody,
    this.statusCode,
    this.response,
    this.error,
    required this.timestamp,
    this.duration,
    this.wasStopped = false,
  });
}

// AI错误类型
enum AiErrorType {
  invalidApiKey,
  networkError,
  modelNotFound,
  rateLimitExceeded,
  insufficientQuota,
  serverError,
  configError,
  timeout,
  cancelled,
  unknown,
}

// AI错误信息
class AiError {
  final AiErrorType type;
  final String message;
  final String? technicalDetails;
  final String? suggestion;

  const AiError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.suggestion,
  });

  static AiError fromException(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // 检查取消错误
    if (errorMessage.contains('cancelled') ||
        errorMessage.contains('operation cancelled')) {
      return AiError(
        type: AiErrorType.cancelled,
        message: '请求已被取消',
        technicalDetails: error.toString(),
        suggestion: '用户主动停止了生成',
      );
    }

    // 检查超时错误
    if (errorMessage.contains('timeout') ||
        errorMessage.contains('timed out')) {
      return AiError(
        type: AiErrorType.timeout,
        message: '请求超时',
        technicalDetails: error.toString(),
        suggestion: '网络可能较慢，请检查网络连接或稍后重试',
      );
    }

    if (errorMessage.contains('unauthorized') ||
        errorMessage.contains('invalid api key') ||
        errorMessage.contains('incorrect api key')) {
      return AiError(
        type: AiErrorType.invalidApiKey,
        message: 'API密钥无效',
        technicalDetails: error.toString(),
        suggestion: '请检查API密钥是否正确，或前往设置页面重新配置',
      );
    }

    if (errorMessage.contains('rate limit') ||
        errorMessage.contains('too many requests')) {
      return AiError(
        type: AiErrorType.rateLimitExceeded,
        message: '请求过于频繁',
        technicalDetails: error.toString(),
        suggestion: '请稍等片刻后再试',
      );
    }

    if (errorMessage.contains('insufficient_quota') ||
        errorMessage.contains('quota exceeded')) {
      return AiError(
        type: AiErrorType.insufficientQuota,
        message: '账户余额不足',
        technicalDetails: error.toString(),
        suggestion: '请检查账户余额或升级订阅计划',
      );
    }

    if (errorMessage.contains('model') && errorMessage.contains('not found')) {
      return AiError(
        type: AiErrorType.modelNotFound,
        message: '模型不存在',
        technicalDetails: error.toString(),
        suggestion: '请检查模型名称是否正确，或选择其他可用模型',
      );
    }

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('socket')) {
      return AiError(
        type: AiErrorType.networkError,
        message: '网络连接失败',
        technicalDetails: error.toString(),
        suggestion: '请检查网络连接是否正常',
      );
    }

    if (errorMessage.contains('server error') ||
        errorMessage.contains('internal error') ||
        errorMessage.contains('500')) {
      return AiError(
        type: AiErrorType.serverError,
        message: '服务器内部错误',
        technicalDetails: error.toString(),
        suggestion: '服务器临时不可用，请稍后重试',
      );
    }

    return AiError(
      type: AiErrorType.unknown,
      message: '未知错误',
      technicalDetails: error.toString(),
      suggestion: '请尝试重新发送消息，或联系技术支持',
    );
  }
}

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // Logger实例
  final LoggerService _logger = LoggerService();

  // 内存存储
  final Map<String, AiProvider> _providers = {};
  final Map<String, AiAssistant> _assistants = {};
  final Map<String, ChatOpenAI> _clients = {}; // 缓存客户端

  // 流式请求控制器映射
  final Map<String, StreamController<String>> _streamControllers = {};
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  // 调试信息存储
  final List<DebugInfo> _debugLogs = [];
  bool _debugMode = true; // 默认开启调试模式

  // 获取调试日志
  List<DebugInfo> get debugLogs => List.unmodifiable(_debugLogs);
  bool get debugMode => _debugMode;

  void setDebugMode(bool enabled) {
    _debugMode = enabled;
    _logger.info('调试模式${enabled ? '开启' : '关闭'}');
  }

  void clearDebugLogs() {
    _debugLogs.clear();
    _logger.info('调试日志已清空');
  }

  // 检查是否正在生成
  bool isGenerating(String requestId) {
    return _streamControllers.containsKey(requestId);
  }

  // 停止生成
  void stopGeneration(String requestId) {
    final controller = _streamControllers[requestId];
    final subscription = _streamSubscriptions[requestId];

    if (controller != null || subscription != null) {
      _logger.warning('停止AI生成', requestId);

      subscription?.cancel();
      controller?.close();

      _streamControllers.remove(requestId);
      _streamSubscriptions.remove(requestId);

      NotificationService().showInfo('已停止生成');
    }
  }

  // 添加调试日志
  void _addDebugLog(DebugInfo debug) {
    if (_debugMode) {
      _debugLogs.add(debug);
      // 保持最近100条记录
      if (_debugLogs.length > 100) {
        _debugLogs.removeAt(0);
      }
    }
  }

  // 初始化默认数据
  void initialize() {
    _logger.info('初始化AI服务');
    _loadDefaultProviders();
    _loadDefaultAssistants();
  }

  // === 提供商管理 ===

  List<AiProvider> get providers => _providers.values.toList();

  AiProvider? getProvider(String id) => _providers[id];

  void addProvider(AiProvider provider) {
    _providers[provider.id] = provider;
    // 清除相关客户端缓存
    _clients.remove(provider.id);
    _logger.info('添加AI提供商: ${provider.name} (${provider.type.name})');
  }

  void updateProvider(AiProvider provider) {
    _providers[provider.id] = provider;
    // 清除相关客户端缓存
    _clients.remove(provider.id);
    _logger.info('更新AI提供商: ${provider.name}');
  }

  void removeProvider(String id) {
    final provider = _providers[id];
    _providers.remove(id);
    _clients.remove(id);
    // 移除相关助手
    _assistants.removeWhere((_, assistant) => assistant.providerId == id);
    _logger.info('删除AI提供商: ${provider?.name ?? id}');
  }

  // === 助手管理 ===

  List<AiAssistant> get assistants => _assistants.values.toList();

  AiAssistant? getAssistant(String id) => _assistants[id];

  void addAssistant(AiAssistant assistant) {
    _assistants[assistant.id] = assistant;
    _logger.info('添加AI助手: ${assistant.name}');
  }

  void updateAssistant(AiAssistant assistant) {
    _assistants[assistant.id] = assistant;
    _logger.info('更新AI助手: ${assistant.name}');
  }

  void removeAssistant(String id) {
    final assistant = _assistants[id];
    _assistants.remove(id);
    _logger.info('删除AI助手: ${assistant?.name ?? id}');
  }

  // 根据提供商获取助手
  List<AiAssistant> getAssistantsByProvider(String providerId) {
    return _assistants.values
        .where((assistant) => assistant.providerId == providerId)
        .toList();
  }

  // === 聊天功能 ===

  // 获取或创建ChatOpenAI客户端
  ChatOpenAI? _getClient(String providerId) {
    if (_clients.containsKey(providerId)) {
      return _clients[providerId];
    }

    final provider = _providers[providerId];
    if (provider == null || !provider.isEnabled) {
      _logger.warning('提供商不可用: $providerId');
      return null;
    }

    // 验证API密钥格式
    if (!_isValidApiKey(provider)) {
      _logger.error('API密钥格式无效: ${provider.name}');
      NotificationService().showError(
        'API密钥格式无效',
        actionLabel: '查看要求',
        onActionPressed: () {
          NotificationService().showInfo(_getApiKeyRequirement(provider.type));
        },
      );
      return null;
    }

    ChatOpenAI client;

    try {
      switch (provider.type) {
        case ProviderType.openai:
        case ProviderType.custom:
          client = ChatOpenAI(
            apiKey: provider.apiKey,
            baseUrl: provider.baseUrl ?? 'https://api.openai.com/v1',
            defaultOptions: ChatOpenAIOptions(
              model: 'gpt-3.5-turbo', // 默认模型，会被请求时覆盖
              temperature: 0.7,
            ),
          );
          break;

        case ProviderType.ollama:
          client = ChatOpenAI(
            apiKey: 'ollama', // Ollama不需要真实的API key
            baseUrl: provider.effectiveBaseUrl,
            defaultOptions: ChatOpenAIOptions(
              model: 'llama2', // 默认模型
              temperature: 0.7,
            ),
          );
          break;

        default:
          // 其他提供商暂不支持，后续可扩展
          _logger.warning('不支持的提供商类型: ${provider.type}');
          return null;
      }

      _clients[providerId] = client;
      _logger.info('创建AI客户端: ${provider.name} -> ${provider.effectiveBaseUrl}');
      return client;
    } catch (e) {
      _logger.error('创建客户端失败', e);
      return null;
    }
  }

  // 验证API密钥格式
  bool _isValidApiKey(AiProvider provider) {
    switch (provider.type) {
      case ProviderType.openai:
      case ProviderType.custom:
        // OpenAI API密钥应该以sk-开头
        return provider.apiKey.isNotEmpty &&
            (provider.apiKey.startsWith('sk-') ||
                provider.apiKey == 'sk-test-example-key'); // 允许示例密钥
      case ProviderType.ollama:
        // Ollama不需要真实的API密钥
        return true;
      default:
        return provider.apiKey.isNotEmpty;
    }
  }

  // 获取API密钥要求说明
  String _getApiKeyRequirement(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI API密钥应该以"sk-"开头，例如：sk-xxxxxxxxxxxxxxxx...';
      case ProviderType.anthropic:
        return 'Anthropic API密钥应该以"sk-ant-"开头';
      case ProviderType.google:
        return 'Google AI API密钥格式请参考官方文档';
      case ProviderType.ollama:
        return 'Ollama运行在本地，不需要API密钥';
      case ProviderType.custom:
        return '请根据具体API提供商的要求输入正确格式的API密钥';
    }
  }

  // 获取消息角色（用于调试）
  String _getMessageRole(ChatMessage message) {
    if (message is SystemChatMessage) return 'system';
    if (message is HumanChatMessage) return 'user';
    if (message is AIChatMessage) return 'assistant';
    return 'unknown';
  }

  // 获取消息内容（用于调试）
  String _getMessageContent(ChatMessage message) {
    // 简化处理，直接转换为字符串用于调试
    return message.toString();
  }

  // 发送聊天消息
  Future<String?> sendMessage({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    final startTime = DateTime.now();
    final requestId = '${assistantId}_${startTime.millisecondsSinceEpoch}';

    _logger.info('开始发送AI消息', {
      'assistantId': assistantId,
      'requestId': requestId,
    });

    final assistant = _assistants[assistantId];
    if (assistant == null) {
      const error = '找不到指定的助手配置';
      _logger.error('助手不存在', {'assistantId': assistantId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: 'unknown',
          modelName: 'unknown',
          requestBody: {'error': 'assistant_not_found'},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      return null;
    }

    final provider = _providers[assistant.providerId];
    if (provider == null) {
      const error = '找不到指定的AI提供商配置';
      _logger.error('提供商不存在', {'providerId': assistant.providerId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {'error': 'provider_not_found'},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      return null;
    }

    if (!provider.isEnabled) {
      const error = 'AI提供商未启用，请先在设置中配置';
      _logger.warning('提供商未启用', {'providerId': assistant.providerId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {'error': 'provider_disabled'},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      return null;
    }

    final client = _getClient(assistant.providerId);
    if (client == null) {
      const error = '无法创建AI客户端，请检查配置';
      _logger.error('客户端创建失败', {'providerId': assistant.providerId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {'error': 'client_creation_failed'},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      return null;
    }

    try {
      // 构建消息列表
      final messages = _buildChatMessages(assistant, chatHistory, userMessage);

      // 构建请求体用于调试
      final requestBody = {
        'model': assistant.modelName,
        'messages': messages
            .map(
              (m) => {
                'role': _getMessageRole(m),
                'content': _getMessageContent(m),
              },
            )
            .toList(),
        'temperature': assistant.temperature,
        'max_tokens': assistant.maxTokens,
      };

      _logger.aiRequest(assistantId, assistant.modelName, requestBody);

      // 设置模型参数并发送请求
      final modelClient = client.bind(
        ChatOpenAIOptions(
          model: assistant.modelName,
          temperature: assistant.temperature,
          maxTokens: assistant.maxTokens,
        ),
      );

      // 添加超时处理
      final response = await modelClient
          .invoke(PromptValue.chat(messages))
          .timeout(const Duration(seconds: 15)); // 15秒超时

      final duration = DateTime.now().difference(startTime);
      final responseContent = response.output.content;

      _logger.aiResponse(assistantId, responseContent, duration);

      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: requestBody,
          statusCode: 200,
          response: responseContent,
          timestamp: startTime,
          duration: duration,
        ),
      );

      return responseContent;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      final aiError = AiError.fromException(e);

      _logger.aiError(
        assistantId,
        aiError.technicalDetails ?? 'unknown error',
        duration,
      );

      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {
            'model': assistant.modelName,
            'temperature': assistant.temperature,
            'user_message': userMessage,
          },
          error: aiError.technicalDetails,
          timestamp: startTime,
          duration: duration,
        ),
      );

      // 显示用户友好的错误通知
      NotificationService().showError(
        aiError.message,
        actionLabel: aiError.suggestion != null ? '查看建议' : null,
        onActionPressed: aiError.suggestion != null
            ? () {
                NotificationService().showInfo(aiError.suggestion!);
              }
            : null,
      );

      // 返回错误信息，供聊天界面显示在气泡中
      return '[错误] ${aiError.message}${aiError.suggestion != null ? "\n💡 ${aiError.suggestion}" : ""}';
    }
  }

  // 发送流式聊天消息
  Stream<String> sendMessageStream({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    final startTime = DateTime.now();
    final requestId = '${assistantId}_${startTime.millisecondsSinceEpoch}';

    _logger.info('开始发送AI流式消息', {
      'assistantId': assistantId,
      'requestId': requestId,
    });

    final assistant = _assistants[assistantId];
    if (assistant == null) {
      const error = '找不到指定的助手配置';
      _logger.error('助手不存在', {'assistantId': assistantId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: 'unknown',
          modelName: 'unknown',
          requestBody: {'error': 'assistant_not_found', 'stream': true},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      yield '[错误] $error';
      return;
    }

    final provider = _providers[assistant.providerId];
    if (provider == null) {
      const error = '找不到指定的AI提供商配置';
      _logger.error('提供商不存在', {'providerId': assistant.providerId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {'error': 'provider_not_found', 'stream': true},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      yield '[错误] $error';
      return;
    }

    if (!provider.isEnabled) {
      const error = 'AI提供商未启用，请先在设置中配置';
      _logger.warning('提供商未启用', {'providerId': assistant.providerId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {'error': 'provider_disabled', 'stream': true},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      yield '[错误] $error';
      return;
    }

    final client = _getClient(assistant.providerId);
    if (client == null) {
      const error = '无法创建AI客户端，请检查配置';
      _logger.error('客户端创建失败', {'providerId': assistant.providerId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {'error': 'client_creation_failed', 'stream': true},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      yield '[错误] $error';
      return;
    }

    // 创建流控制器
    final controller = StreamController<String>();
    _streamControllers[requestId] = controller;

    try {
      // 构建消息列表
      final messages = _buildChatMessages(assistant, chatHistory, userMessage);

      // 构建请求体用于调试
      final requestBody = {
        'model': assistant.modelName,
        'messages': messages
            .map(
              (m) => {
                'role': _getMessageRole(m),
                'content': _getMessageContent(m),
              },
            )
            .toList(),
        'temperature': assistant.temperature,
        'max_tokens': assistant.maxTokens,
        'stream': true,
      };

      _logger.aiStreamStart(assistantId, assistant.modelName);

      // 设置模型参数
      final modelClient = client.bind(
        ChatOpenAIOptions(
          model: assistant.modelName,
          temperature: assistant.temperature,
          maxTokens: assistant.maxTokens,
        ),
      );

      // 发送流式请求并添加超时
      final stream = modelClient
          .stream(PromptValue.chat(messages))
          .timeout(const Duration(seconds: 20)); // 流式请求稍微长一点的超时

      var fullResponse = '';
      var chunkCount = 0;
      bool wasStoppedByUser = false;

      // 监听流数据
      final subscription = stream.listen(
        (chunk) {
          // 检查是否已被停止
          if (!_streamControllers.containsKey(requestId)) {
            wasStoppedByUser = true;
            return;
          }

          final content = chunk.output.content;
          if (content.isNotEmpty && !controller.isClosed) {
            fullResponse += content;
            chunkCount++;
            _logger.aiStreamChunk(assistantId, chunkCount, fullResponse.length);
            controller.add(content);
          }
        },
        onError: (error) {
          if (!controller.isClosed &&
              _streamControllers.containsKey(requestId)) {
            final aiError = AiError.fromException(error);
            _logger.aiError(
              assistantId,
              aiError.technicalDetails ?? 'stream error',
              DateTime.now().difference(startTime),
            );

            controller.add('[错误] ${aiError.message}');
            if (aiError.suggestion != null) {
              controller.add('\n💡 ${aiError.suggestion}');
            }
          }
          controller.close();
          _cleanup(requestId);
        },
        onDone: () {
          final duration = DateTime.now().difference(startTime);

          if (wasStoppedByUser) {
            _logger.aiStreamStopped(assistantId, chunkCount, duration);
          } else {
            _logger.aiStreamComplete(assistantId, chunkCount, duration);
          }

          _addDebugLog(
            DebugInfo(
              assistantId: assistantId,
              providerId: assistant.providerId,
              modelName: assistant.modelName,
              requestBody: requestBody,
              statusCode: 200,
              response: fullResponse,
              timestamp: startTime,
              duration: duration,
              wasStopped: wasStoppedByUser,
            ),
          );

          controller.close();
          _cleanup(requestId);
        },
      );

      _streamSubscriptions[requestId] = subscription;

      // 返回controller的stream
      yield* controller.stream;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      final aiError = AiError.fromException(e);

      _logger.aiError(
        assistantId,
        aiError.technicalDetails ?? 'stream setup error',
        duration,
      );

      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: assistant.providerId,
          modelName: assistant.modelName,
          requestBody: {
            'model': assistant.modelName,
            'temperature': assistant.temperature,
            'user_message': userMessage,
            'stream': true,
          },
          error: aiError.technicalDetails,
          timestamp: startTime,
          duration: duration,
        ),
      );

      // 显示用户友好的错误通知
      NotificationService().showError(
        aiError.message,
        actionLabel: aiError.suggestion != null ? '查看建议' : null,
        onActionPressed: aiError.suggestion != null
            ? () {
                NotificationService().showInfo(aiError.suggestion!);
              }
            : null,
      );

      // 返回错误信息，供聊天界面显示在气泡中
      yield '[错误] ${aiError.message}';
      if (aiError.suggestion != null) {
        yield '\n💡 ${aiError.suggestion}';
      }

      _cleanup(requestId);
    }
  }

  // 清理资源
  void _cleanup(String requestId) {
    _streamControllers.remove(requestId);
    _streamSubscriptions.remove(requestId);
  }

  // 构建聊天消息列表
  List<ChatMessage> _buildChatMessages(
    AiAssistant assistant,
    List<Message> chatHistory,
    String userMessage,
  ) {
    final messages = <ChatMessage>[];

    // 添加系统提示
    if (assistant.systemPrompt.isNotEmpty) {
      messages.add(ChatMessage.system(assistant.systemPrompt));
    }

    // 添加上下文历史（限制数量）
    final contextHistory = chatHistory.take(assistant.contextLength).toList();
    for (final message in contextHistory.reversed) {
      if (message.isFromUser) {
        messages.add(ChatMessage.humanText(message.content));
      } else {
        messages.add(ChatMessage.ai(message.content));
      }
    }

    // 添加当前用户消息
    messages.add(ChatMessage.humanText(userMessage));

    return messages;
  }

  // === 初始化默认数据 ===

  void _loadDefaultProviders() {
    final now = DateTime.now();

    // 创建一个示例OpenAI提供商（带有示例API key用于测试）
    final openaiProvider = AiProvider(
      id: 'openai-default',
      name: 'OpenAI (示例)',
      type: ProviderType.openai,
      apiKey: 'sk-test-example-key', // 示例key，用户需要替换为真实key
      supportedModels: AiProvider.getDefaultModels(ProviderType.openai),
      createdAt: now,
      updatedAt: now,
      isEnabled: true, // 启用以便测试（用户需要替换真实API key）
    );

    _providers[openaiProvider.id] = openaiProvider;

    // 创建一个示例Ollama提供商
    final ollamaProvider = AiProvider(
      id: 'ollama-default',
      name: 'Ollama 本地',
      type: ProviderType.ollama,
      apiKey: 'ollama',
      baseUrl: 'http://localhost:11434/v1',
      supportedModels: AiProvider.getDefaultModels(ProviderType.ollama),
      createdAt: now,
      updatedAt: now,
      isEnabled: false, // 默认禁用，需要用户启动Ollama服务
    );

    _providers[ollamaProvider.id] = ollamaProvider;
  }

  void _loadDefaultAssistants() {
    final now = DateTime.now();

    // 创建默认助手（如果有可用的提供商）
    if (_providers.isNotEmpty) {
      final defaultProvider = _providers.values.first;
      final defaultModel = defaultProvider.supportedModels.isNotEmpty
          ? defaultProvider.supportedModels.first
          : 'gpt-3.5-turbo';

      for (final type in AssistantType.values) {
        final assistant = AiAssistant(
          id: 'assistant-${type.name}',
          name: type.displayName,
          description: '预设的${type.displayName}',
          avatar: type.avatar,
          systemPrompt: type.defaultPrompt,
          providerId: defaultProvider.id,
          modelName: defaultModel,
          createdAt: now,
          updatedAt: now,
          isEnabled: true, // 启用默认助手
          temperature: 0.7,
          topP: 1.0,
          maxTokens: 2048,
          contextLength: 10,
          streamOutput: true,
        );

        _assistants[assistant.id] = assistant;
      }
    }
  }

  // === 验证和测试 ===

  // 测试提供商连接
  Future<bool> testProvider(String providerId) async {
    final client = _getClient(providerId);
    if (client == null) return false;

    try {
      // 发送一个简单的测试请求
      final response = await client
          .invoke(PromptValue.chat([ChatMessage.humanText('Hello')]))
          .timeout(const Duration(seconds: 10));

      return response.output.content.isNotEmpty;
    } catch (e) {
      _logger.error('测试提供商失败', e);
      return false;
    }
  }

  // 获取可用的模型列表（返回默认模型列表）
  Future<List<String>> getAvailableModels(String providerId) async {
    try {
      // langchain暂时没有直接的模型列表API，返回默认模型列表
      final provider = _providers[providerId];
      return provider?.supportedModels ?? [];
    } catch (e) {
      _logger.error('获取模型列表失败', e);
      // 返回默认模型列表
      final provider = _providers[providerId];
      return provider?.supportedModels ?? [];
    }
  }
}
