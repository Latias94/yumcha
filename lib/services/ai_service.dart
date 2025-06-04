import 'dart:async';
import '../models/ai_provider.dart';
import '../models/ai_assistant.dart';
import '../models/ai_model.dart';
import '../models/message.dart';
import 'notification_service.dart';
import 'logger_service.dart';
import 'provider_repository.dart';
import 'assistant_repository.dart';
import '../data/repositories/setting_repository.dart';
import 'database_service.dart';
import 'ai_request_service.dart';
import 'ai_dart_service.dart';
import '../ai_dart/core/chat_provider.dart';

/// AI 响应结果，包含完整的响应信息
class AiResponse {
  final String content;
  final String? thinking;
  final UsageInfo? usage;
  final Duration? duration;
  final String? error;

  const AiResponse({
    required this.content,
    this.thinking,
    this.usage,
    this.duration,
    this.error,
  });

  bool get isSuccess => error == null;
  bool get hasThinking => thinking?.isNotEmpty == true;
}

/// AI 流式响应事件
class AiStreamResponse {
  final String? contentDelta;
  final String? thinkingDelta;
  final String? finalThinking;
  final bool isDone;
  final String? error;
  final UsageInfo? usage;
  final Duration? duration;

  const AiStreamResponse({
    this.contentDelta,
    this.thinkingDelta,
    this.finalThinking,
    this.isDone = false,
    this.error,
    this.usage,
    this.duration,
  });

  bool get isContent => contentDelta != null;
  bool get isThinking => thinkingDelta != null;
  bool get isError => error != null;
  bool get isSuccess => error == null;
}

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

/// AI 服务主类 - 负责聊天功能和调试
/// 注意：提供商和助手的状态管理现在由 Riverpod 处理
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // Logger实例
  final LoggerService _logger = LoggerService();
  final AiRequestService _requestService = AiRequestService();

  // 调试信息存储
  final List<DebugInfo> _debugLogs = [];
  bool _debugMode = true; // 默认开启调试模式

  // 初始化状态
  bool _isInitialized = false;

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
  Future<void> initialize() async {
    // 防止重复初始化
    if (_isInitialized) {
      _logger.debug('AI服务已经初始化，跳过重复初始化');
      return;
    }

    final providerRepository = ProviderRepository(
      DatabaseService.instance.database,
    );
    final assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    _logger.info('初始化AI服务');

    // 处理默认提供商
    final allDbProviders = await providerRepository.getAllProviders();

    const defaultProviderId = 'openai-default';
    bool hasDefaultProvider = allDbProviders.any(
      (p) => p.id == defaultProviderId,
    );

    if (!hasDefaultProvider) {
      final defaultOpenAiProvider = AiProvider(
        id: defaultProviderId,
        name: 'OpenAI (默认)',
        type: ProviderType.openai,
        apiKey: 'sk-', // 用户需要替换
        baseUrl: 'https://api.openai.com/v1',
        models: [
          AiModel(
            id: 'gpt-3.5-turbo',
            name: 'gpt-3.5-turbo',
            displayName: 'GPT-3.5 Turbo',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEnabled: true,
      );
      await providerRepository.insertProvider(defaultOpenAiProvider);
      _logger.info('已创建并保存默认OpenAI提供商: ${defaultOpenAiProvider.name}');
    }

    // 处理默认助手
    final allDbAssistants = await assistantRepository.getAllAssistants();

    const defaultAssistantId = 'default-assistant';
    bool hasDefaultAssistant = allDbAssistants.any(
      (a) => a.id == defaultAssistantId,
    );

    if (!hasDefaultAssistant) {
      final defaultAssistant = AiAssistant(
        id: defaultAssistantId,
        name: '默认助手',
        avatar: '🤖',
        systemPrompt: '你是一个乐于助人的AI助手。',
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 4096,
        contextLength: 32,
        streamOutput: true,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '',
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
      await assistantRepository.insertAssistant(defaultAssistant);
      _logger.info('已创建并保存默认助手: ${defaultAssistant.name}');
    }

    // 标记为已初始化
    _isInitialized = true;
    _logger.info('AI服务初始化完成');
  }

  // === 聊天功能 ===

  // 发送聊天消息
  Future<AiResponse> sendMessage({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async {
    final startTime = DateTime.now();
    final requestId = '${assistantId}_${startTime.millisecondsSinceEpoch}';

    if (selectedModelName == "") {
      const error = '模型名称不能为空';
      _logger.error(error);
      NotificationService().showError(error);
      return AiResponse(content: '', error: error);
    }

    if (selectedProviderId == "") {
      const error = '提供商ID不能为空';
      _logger.error(error);
      NotificationService().showError(error);
      return AiResponse(content: '', error: error);
    }

    if (assistantId == "") {
      const error = '助手ID不能为空';
      _logger.error(error);
      NotificationService().showError(error);
      return AiResponse(content: '', error: error);
    }

    _logger.info('开始发送AI消息', {
      'assistantId': assistantId,
      'selectedProviderId': selectedProviderId,
      'selectedModelName': selectedModelName,
      'requestId': requestId,
    });

    // 通过 repository 获取数据而不是内存缓存
    final assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    final providerRepository = ProviderRepository(
      DatabaseService.instance.database,
    );

    final assistant = await assistantRepository.getAssistant(assistantId);
    if (assistant == null) {
      const error = '找不到指定的助手配置';
      _logger.error('助手不存在', {'assistantId': assistantId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: selectedProviderId,
          modelName: selectedModelName,
          requestBody: {'error': 'assistant_not_found'},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      return AiResponse(content: '', error: error);
    }

    final provider = await providerRepository.getProvider(selectedProviderId);
    if (provider == null) {
      const error = '找不到指定的AI提供商配置';
      _logger.error('提供商不存在', {'providerId': selectedProviderId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: selectedProviderId,
          modelName: selectedModelName,
          requestBody: {'error': 'provider_not_found'},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      return AiResponse(content: '', error: error);
    }

    try {
      // 使用新的请求服务发送消息
      final result = await _requestService.sendChatRequest(
        provider: provider,
        assistant: assistant,
        modelName: selectedModelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      );

      final duration = DateTime.now().difference(startTime);

      if (result.isSuccess) {
        _logger.info('AI聊天请求成功', {
          'duration': '${duration.inMilliseconds}ms',
          'usage': result.usage?.totalTokens,
        });

        _addDebugLog(
          DebugInfo(
            assistantId: assistantId,
            providerId: selectedProviderId,
            modelName: selectedModelName,
            requestBody: {
              'model': selectedModelName,
              'temperature': assistant.temperature,
              'top_p': assistant.topP,
              'max_tokens': assistant.maxTokens,
              'user_message': userMessage,
            },
            statusCode: 200,
            response: result.content,
            timestamp: startTime,
            duration: duration,
          ),
        );

        return AiResponse(
          content: result.content ?? '',
          thinking: result.thinking,
          usage: result.usage,
          duration: duration,
        );
      } else {
        _logger.error('AI聊天请求失败', {
          'error': result.error,
          'duration': '${duration.inMilliseconds}ms',
        });

        _addDebugLog(
          DebugInfo(
            assistantId: assistantId,
            providerId: selectedProviderId,
            modelName: selectedModelName,
            requestBody: {
              'model': selectedModelName,
              'user_message': userMessage,
            },
            error: result.error,
            timestamp: startTime,
            duration: duration,
          ),
        );

        NotificationService().showError(result.error ?? '未知错误');
        return AiResponse(
          content: '',
          error: result.error ?? '未知错误',
          duration: duration,
        );
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logger.error('AI聊天请求异常', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: selectedProviderId,
          modelName: selectedModelName,
          requestBody: {
            'model': selectedModelName,
            'user_message': userMessage,
          },
          error: e.toString(),
          timestamp: startTime,
          duration: duration,
        ),
      );

      NotificationService().showError('请求失败: $e');
      return AiResponse(content: '', error: '请求失败: $e', duration: duration);
    }
  }

  // 发送流式聊天消息
  Stream<AiStreamResponse> sendMessageStream({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async* {
    final startTime = DateTime.now();
    final requestId = '${assistantId}_${startTime.millisecondsSinceEpoch}';

    if (selectedModelName == "") {
      const error = '模型名称不能为空';
      _logger.error(error);
      NotificationService().showError(error);
      yield AiStreamResponse(error: error);
      return;
    }

    if (selectedProviderId == "") {
      const error = '提供商ID不能为空';
      _logger.error(error);
      NotificationService().showError(error);
      yield AiStreamResponse(error: error);
      return;
    }

    if (assistantId == "") {
      const error = '助手ID不能为空';
      _logger.error(error);
      NotificationService().showError(error);
      yield AiStreamResponse(error: error);
      return;
    }

    _logger.info('开始发送AI流式消息', {
      'assistantId': assistantId,
      'selectedProviderId': selectedProviderId,
      'selectedModelName': selectedModelName,
      'requestId': requestId,
    });

    // 通过 repository 获取数据
    final assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    final providerRepository = ProviderRepository(
      DatabaseService.instance.database,
    );

    final assistant = await assistantRepository.getAssistant(assistantId);
    if (assistant == null) {
      const error = '找不到指定的助手配置';
      _logger.error('助手不存在', {'assistantId': assistantId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: selectedProviderId,
          modelName: selectedModelName,
          requestBody: {'error': 'assistant_not_found', 'stream': true},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      yield AiStreamResponse(error: error);
      return;
    }

    final provider = await providerRepository.getProvider(selectedProviderId);
    if (provider == null) {
      const error = '找不到指定的AI提供商配置';
      _logger.error('提供商不存在', {'providerId': selectedProviderId});
      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: selectedProviderId,
          modelName: selectedModelName,
          requestBody: {'error': 'provider_not_found', 'stream': true},
          error: error,
          timestamp: startTime,
        ),
      );
      NotificationService().showError(error);
      yield AiStreamResponse(error: error);
      return;
    }

    try {
      _logger.info('开始流式聊天请求', {
        'provider': provider.name,
        'model': selectedModelName,
        'assistant': assistant.name,
        'baseUrl': provider.baseUrl ?? '默认端点',
      });

      // 使用AiRequestService的流式方法
      final streamEvents = _requestService.sendChatStreamRequest(
        provider: provider,
        assistant: assistant,
        modelName: selectedModelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      );

      var fullResponse = '';
      var fullThinking = '';
      var chunkCount = 0;
      bool hasError = false;

      await for (final event in streamEvents) {
        if (event.content != null) {
          fullResponse += event.content!;
          chunkCount++;
          _logger.debug('收到流式内容块', {
            'chunk': chunkCount,
            'content': event.content!,
            'totalLength': fullResponse.length,
          });

          yield AiStreamResponse(contentDelta: event.content!);
        } else if (event.thinkingDelta != null) {
          fullThinking += event.thinkingDelta!;
          _logger.debug('收到思考内容块', {
            'thinkingDelta': event.thinkingDelta!,
            'totalThinkingLength': fullThinking.length,
          });

          yield AiStreamResponse(thinkingDelta: event.thinkingDelta!);
        } else if (event.error != null) {
          hasError = true;
          _logger.error('流式聊天错误', {'error': event.error});
          yield AiStreamResponse(error: event.error!);
        } else if (event.isDone) {
          final duration = DateTime.now().difference(startTime);

          _logger.info('流式聊天完成', {
            'chunks': chunkCount,
            'duration': duration,
            'totalLength': fullResponse.length,
            'thinkingLength': fullThinking.length,
            'usage': event.usage?.totalTokens,
          });

          _addDebugLog(
            DebugInfo(
              assistantId: assistantId,
              providerId: selectedProviderId,
              modelName: selectedModelName,
              requestBody: {
                'model': selectedModelName,
                'temperature': assistant.temperature,
                'top_p': assistant.topP,
                'max_tokens': assistant.maxTokens,
                'user_message': userMessage,
                'stream': true,
              },
              statusCode: hasError ? null : 200,
              response: fullResponse,
              timestamp: startTime,
              duration: duration,
              error: hasError ? '流式响应中出现错误' : null,
            ),
          );

          yield AiStreamResponse(
            isDone: true,
            finalThinking: event.finalThinking ?? fullThinking,
            usage: event.usage,
            duration: duration,
          );
          break;
        }
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logger.error('流式聊天设置失败', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      _addDebugLog(
        DebugInfo(
          assistantId: assistantId,
          providerId: selectedProviderId,
          modelName: selectedModelName,
          requestBody: {
            'model': selectedModelName,
            'user_message': userMessage,
            'stream': true,
          },
          error: e.toString(),
          timestamp: startTime,
          duration: duration,
        ),
      );

      NotificationService().showError('流式聊天失败: $e');
      yield AiStreamResponse(error: '流式聊天失败: $e');
    }
  }

  // === 验证和测试 ===

  // 测试提供商连接
  Future<bool> testProvider(String providerId, [String? modelName]) async {
    final providerRepository = ProviderRepository(
      DatabaseService.instance.database,
    );
    final provider = await providerRepository.getProvider(providerId);
    if (provider == null) {
      _logger.error('测试提供商失败：提供商不存在', {'providerId': providerId});
      return false;
    }

    try {
      _logger.info('开始测试提供商', {'provider': provider.name, 'model': modelName});

      final result = await _requestService.testProvider(
        provider: provider,
        modelName: modelName,
      );

      _logger.info('提供商测试${result ? '成功' : '失败'}', {'provider': provider.name});
      return result;
    } catch (e) {
      _logger.error('测试提供商异常', {
        'provider': provider.name,
        'error': e.toString(),
      });
      return false;
    }
  }

  // 获取可用的模型列表（返回提供商配置的模型列表）
  Future<List<String>> getAvailableModels(String providerId) async {
    try {
      final providerRepository = ProviderRepository(
        DatabaseService.instance.database,
      );
      final provider = await providerRepository.getProvider(providerId);
      if (provider == null) {
        _logger.warning('获取模型列表失败：提供商不存在', {'providerId': providerId});
        return [];
      }

      // 返回提供商配置的模型列表
      final models = provider.models.map((model) => model.name).toList();
      _logger.info('获取模型列表', {
        'provider': provider.name,
        'count': models.length,
      });
      return models;
    } catch (e) {
      _logger.error('获取模型列表失败', {
        'providerId': providerId,
        'error': e.toString(),
      });
      return [];
    }
  }

  /// 从提供商API获取模型列表（使用AI Dart库）
  Future<List<AiModel>> fetchModelsFromProvider(AiProvider provider) async {
    final startTime = DateTime.now();

    try {
      _logger.info('开始从提供商API获取模型列表', {
        'provider': provider.name,
        'type': provider.type.toString(),
        'baseUrl': provider.baseUrl ?? '默认端点',
        'apiKey': provider.apiKey.isNotEmpty
            ? '${provider.apiKey.substring(0, 8)}...'
            : '空',
        'hasApiKey': provider.apiKey.isNotEmpty,
        'hasBaseUrl': provider.baseUrl?.isNotEmpty == true,
      });

      // 检查提供商是否支持模型列表功能
      if (!_providerSupportsModelListing(provider.type)) {
        _logger.warning('提供商不支持模型列表功能', {'provider': provider.name});
        return [];
      }

      // 创建一个临时的助手配置用于获取模型
      final tempAssistant = AiAssistant(
        id: 'temp-model-fetcher',
        name: 'Model Fetcher',
        avatar: '📋',
        systemPrompt: '',
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 100,
        contextLength: 1,
        streamOutput: false,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: '临时模型获取助手',
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

      // 使用AI Dart服务创建提供商实例
      final aiDartService = AiDartService();
      final chatProvider = await aiDartService.createProvider(
        provider,
        tempAssistant,
        'gpt-3.5-turbo', // 使用默认模型名称
      );

      // 检查是否支持模型列表功能
      if (chatProvider is! ModelProvider) {
        _logger.warning('提供商不支持ModelProvider接口', {'provider': provider.name});
        return [];
      }

      final modelProvider = chatProvider as ModelProvider;
      final aiModels = await modelProvider.models();

      final duration = DateTime.now().difference(startTime);

      // 转换AI Dart模型到应用模型格式
      final appModels = aiModels.map((aiModel) {
        return AiModel(
          id: aiModel.id,
          name: aiModel.id,
          displayName: aiModel.description?.isNotEmpty == true
              ? aiModel.description!
              : aiModel.id,
          capabilities: _inferModelCapabilities(aiModel.id),
          metadata: {
            'source': 'api',
            'ownedBy': aiModel.ownedBy ?? 'unknown',
            'object': aiModel.object,
          },
          isEnabled: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      _logger.info('成功从API获取模型列表', {
        'provider': provider.name,
        'count': appModels.length,
        'duration': '${duration.inMilliseconds}ms',
      });

      return appModels;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logger.error('从API获取模型列表失败', {
        'provider': provider.name,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });
      return [];
    }
  }

  /// 检查提供商是否支持模型列表功能
  bool _providerSupportsModelListing(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
      case ProviderType.custom: // OpenAI兼容接口
        return true;
      case ProviderType.anthropic:
      case ProviderType.google:
      case ProviderType.ollama:
        return false; // 这些提供商暂不支持或不需要动态获取
    }
  }

  /// 根据模型名称推断模型能力
  List<ModelCapability> _inferModelCapabilities(String modelId) {
    final capabilities = <ModelCapability>[ModelCapability.reasoning];

    final lowerModelId = modelId.toLowerCase();

    // 视觉能力
    if (lowerModelId.contains('vision') ||
        lowerModelId.contains('gpt-4') ||
        lowerModelId.contains('claude-3')) {
      capabilities.add(ModelCapability.vision);
    }

    // 工具调用能力
    if (lowerModelId.contains('gpt-') ||
        lowerModelId.contains('claude-') ||
        lowerModelId.contains('gemini')) {
      capabilities.add(ModelCapability.tools);
    }

    // 嵌入能力
    if (lowerModelId.contains('embedding') || lowerModelId.contains('embed')) {
      capabilities.add(ModelCapability.embedding);
    }

    return capabilities;
  }

  // === 标题生成功能 ===

  /// 检查是否配置了默认标题生成模型
  Future<bool> hasDefaultTitleModel() async {
    try {
      // 获取设置仓库
      final settingRepository = SettingRepository(
        DatabaseService.instance.database,
      );

      // 获取默认标题生成模型配置
      final defaultConfig = await settingRepository.getDefaultTitleModel();

      if (defaultConfig?.isConfigured != true) {
        return false;
      }

      // 获取提供商信息
      final providerRepository = ProviderRepository(
        DatabaseService.instance.database,
      );
      final provider = await providerRepository.getProvider(
        defaultConfig!.providerId!,
      );

      if (provider == null) {
        return false;
      }

      if (!provider.isEnabled) {
        return false;
      }

      return true;
    } catch (e) {
      _logger.error('检查默认标题生成模型配置失败', {'error': e.toString()});
      return false;
    }
  }

  /// 使用默认模型生成聊天标题
  Future<String?> generateChatTitleWithDefaults({
    required List<Message> messages,
    String? customPrompt,
  }) async {
    try {
      // 获取设置仓库
      final settingRepository = SettingRepository(
        DatabaseService.instance.database,
      );

      // 获取默认标题生成模型配置
      final defaultConfig = await settingRepository.getDefaultTitleModel();

      if (defaultConfig?.isConfigured != true) {
        return null;
      }

      // 获取提供商信息
      final providerRepository = ProviderRepository(
        DatabaseService.instance.database,
      );
      final provider = await providerRepository.getProvider(
        defaultConfig!.providerId!,
      );

      if (provider == null) {
        _logger.error('默认标题生成模型的提供商不存在', {
          'providerId': defaultConfig.providerId,
        });
        return null;
      }

      if (!provider.isEnabled) {
        _logger.warning('默认标题生成模型的提供商已禁用', {
          'providerId': defaultConfig.providerId,
        });
        return null;
      }

      // 使用默认配置生成标题
      return await generateChatTitle(
        provider: provider,
        modelName: defaultConfig.modelName!,
        messages: messages,
        customPrompt: customPrompt,
      );
    } catch (e) {
      _logger.error('使用默认模型生成标题失败', {'error': e.toString()});
      return null;
    }
  }

  /// 生成聊天标题（使用 ai_dart 库）
  Future<String?> generateChatTitle({
    required AiProvider provider,
    required String modelName,
    required List<Message> messages,
    String? customPrompt,
  }) async {
    final startTime = DateTime.now();

    if (messages.isEmpty) {
      _logger.warning('无法生成标题：消息列表为空');
      return null;
    }

    _logger.info('开始生成聊天标题', {
      'providerId': provider.id,
      'providerName': provider.name,
      'modelName': modelName,
      'messageCount': messages.length,
    });

    try {
      // 创建专门用于标题生成的助手配置
      final titleAssistant = AiAssistant(
        id: 'title-generator',
        name: 'Title Generator',
        avatar: '📝',
        systemPrompt: customPrompt ?? _getDefaultTitlePrompt(),
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 100, // 限制token数量，标题不需要太长
        contextLength: 5, // 只使用最近5条消息
        streamOutput: false,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: 'AI标题生成助手',
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

      // 取最近5条消息作为上下文
      final recentMessages = messages.length > 5
          ? messages.sublist(messages.length - 5)
          : messages;

      // 构建标题生成的用户消息
      final conversationSummary = _buildConversationSummary(recentMessages);

      // 使用 AiRequestService 发送标题生成请求
      final result = await _requestService.sendChatRequest(
        provider: provider,
        assistant: titleAssistant,
        modelName: modelName,
        chatHistory: [], // 不需要历史记录
        userMessage: conversationSummary,
      );

      final duration = DateTime.now().difference(startTime);

      if (result.isSuccess && result.content != null) {
        // 清理标题：移除换行符、引号等，限制长度
        final cleanTitle = _cleanTitle(result.content!);

        _logger.info('标题生成成功', {
          'title': cleanTitle,
          'duration': '${duration.inMilliseconds}ms',
        });

        return cleanTitle;
      } else {
        _logger.error('标题生成失败', {
          'error': result.error,
          'duration': '${duration.inMilliseconds}ms',
        });
        return null;
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logger.error('标题生成异常', {
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });
      return null;
    }
  }

  /// 获取默认的标题生成提示词
  String _getDefaultTitlePrompt() {
    return '''你是一个专业的对话标题生成助手。请根据用户提供的对话内容，生成一个简洁、准确的标题。

要求：
1. 标题长度不超过20个字符
2. 使用与对话相同的语言
3. 准确概括对话的主要内容
4. 不要使用引号、标点符号或特殊字符
5. 直接输出标题，不要添加任何解释

请为以下对话生成标题：''';
  }

  /// 构建对话摘要用于标题生成
  String _buildConversationSummary(List<Message> messages) {
    final summary = StringBuffer();

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final rolePrefix = message.isFromUser ? '用户' : '助手';
      summary.writeln('$rolePrefix: ${message.content}');

      // 限制总长度，避免超出模型上下文
      if (summary.length > 1000) {
        summary.writeln('...(对话继续)');
        break;
      }
    }

    return summary.toString();
  }

  /// 清理标题文本
  String _cleanTitle(String title) {
    // 移除换行符和多余空格
    String cleaned = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 移除开头和结尾的引号
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }

    // 移除常见的标题前缀
    if (cleaned.toLowerCase().startsWith('标题:') ||
        cleaned.toLowerCase().startsWith('标题：')) {
      cleaned = cleaned.substring(3).trim();
    }
    if (cleaned.toLowerCase().startsWith('title:')) {
      cleaned = cleaned.substring(6).trim();
    }

    // 限制长度为30个字符
    if (cleaned.length > 30) {
      cleaned = cleaned.substring(0, 30);
    }

    // 如果标题为空或太短，返回默认标题
    if (cleaned.isEmpty || cleaned.length < 2) {
      return '新对话';
    }

    return cleaned;
  }
}
