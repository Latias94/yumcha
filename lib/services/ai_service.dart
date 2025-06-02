import 'dart:async';
import '../models/ai_provider.dart';
import '../models/ai_assistant.dart';
import '../models/ai_model.dart';
import '../models/message.dart';
import 'notification_service.dart';
import 'logger_service.dart';
import 'provider_repository.dart';
import 'assistant_repository.dart';
import 'database_service.dart';
import 'ai_request_service.dart';

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

/// AI 服务主类 - 负责管理提供商、助手和聊天功能
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // Logger实例
  final LoggerService _logger = LoggerService();
  final AiRequestService _requestService = AiRequestService();

  // 内存存储
  final Map<String, AiProvider> _providers = {};
  final Map<String, AiAssistant> _assistants = {};

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
    final providerRepository = ProviderRepository(
      DatabaseService.instance.database,
    );
    final assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    _logger.info('初始化AI服务');

    // 处理默认提供商
    final allDbProviders = await providerRepository.getAllProviders();
    for (final p in allDbProviders) {
      _providers[p.id] = p;
    }

    const defaultProviderId = 'openai-default';
    if (!_providers.containsKey(defaultProviderId)) {
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
      _providers[defaultOpenAiProvider.id] = defaultOpenAiProvider;
      await providerRepository.insertProvider(defaultOpenAiProvider);
      _logger.info('已创建并保存默认OpenAI提供商: ${defaultOpenAiProvider.name}');
    }

    // 处理默认助手
    final allDbAssistants = await assistantRepository.getAllAssistants();
    for (final a in allDbAssistants) {
      _assistants[a.id] = a;
    }

    const defaultAssistantId = 'default-assistant';
    if (!_assistants.containsKey(defaultAssistantId)) {
      if (_providers.containsKey('openai-default')) {
        final defaultAssistant = AiAssistant(
          id: defaultAssistantId,
          name: '默认助手',
          avatar: '🤖',
          systemPrompt: '你是一个乐于助人的AI助手。',
          providerId: 'openai-default', // 关联默认提供商
          modelName: 'gpt-3.5-turbo', // 默认模型
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
          enableWebSearch: false,
          enableCodeExecution: false,
          enableImageGeneration: false,
        );
        _assistants[defaultAssistant.id] = defaultAssistant;
        await assistantRepository.insertAssistant(defaultAssistant);
        _logger.info('已创建并保存默认助手: ${defaultAssistant.name}');
      } else {
        _logger.warning('无法创建默认助手，因为默认OpenAI提供商不存在。');
      }
    }
  }

  // === 提供商管理 ===

  List<AiProvider> get providers => _providers.values.toList();

  AiProvider? getProvider(String id) => _providers[id];

  void addProvider(AiProvider provider) {
    _providers[provider.id] = provider;
    // 清除相关客户端缓存
    _requestService.clearClientCache(provider.id);
    _logger.info('添加AI提供商: ${provider.name} (${provider.type.name})');
  }

  void updateProvider(AiProvider provider) {
    _providers[provider.id] = provider;
    // 清除相关客户端缓存
    _requestService.clearClientCache(provider.id);
    _logger.info('更新AI提供商: ${provider.name}');
  }

  void removeProvider(String id) {
    final provider = _providers[id];
    _providers.remove(id);
    _requestService.clearClientCache(id);
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

  // 发送聊天消息
  Future<String?> sendMessage({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async {
    final startTime = DateTime.now();
    final requestId = '${assistantId}_${startTime.millisecondsSinceEpoch}';

    _logger.info('开始发送AI消息', {
      'assistantId': assistantId,
      'selectedProviderId': selectedProviderId,
      'selectedModelName': selectedModelName,
      'requestId': requestId,
    });

    final assistant = _assistants[assistantId];
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
      return null;
    }

    final provider = _providers[selectedProviderId];
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
      return null;
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

        return result.content;
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
        return '[错误] ${result.error}';
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
      return '[错误] 请求失败: $e';
    }
  }

  // 发送流式聊天消息
  Stream<String> sendMessageStream({
    required String assistantId,
    required List<Message> chatHistory,
    required String userMessage,
    required String selectedProviderId,
    required String selectedModelName,
  }) async* {
    final startTime = DateTime.now();
    final requestId = '${assistantId}_${startTime.millisecondsSinceEpoch}';

    _logger.info('开始发送AI流式消息', {
      'assistantId': assistantId,
      'selectedProviderId': selectedProviderId,
      'selectedModelName': selectedModelName,
      'requestId': requestId,
    });

    final assistant = _assistants[assistantId];
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
      yield '[错误] $error';
      return;
    }

    final provider = _providers[selectedProviderId];
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
      yield '[错误] $error';
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

          // 立即输出接收到的内容
          yield event.content!;
        } else if (event.error != null) {
          hasError = true;
          _logger.error('流式聊天错误', {'error': event.error});
          yield '[错误] ${event.error}';
        } else if (event.isDone) {
          final duration = DateTime.now().difference(startTime);

          _logger.info('流式聊天完成', {
            'chunks': chunkCount,
            'duration': duration,
            'totalLength': fullResponse.length,
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
      yield '[错误] 流式聊天失败: $e';
    }
  }

  // === 验证和测试 ===

  // 测试提供商连接
  Future<bool> testProvider(String providerId, [String? modelName]) async {
    final provider = _providers[providerId];
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
      final provider = _providers[providerId];
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
}
