import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import '../services/ai_service.dart';
import '../services/logger_service.dart';

/// 模型管理服务 - 负责从提供商获取和管理模型列表
class ModelManagementService {
  static final ModelManagementService _instance = ModelManagementService._internal();
  factory ModelManagementService() => _instance;
  ModelManagementService._internal();

  final LoggerService _logger = LoggerService();

  /// 检查提供商是否支持获取模型列表
  bool providerSupportsListModels(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
      case ProviderType.custom:
        return true; // OpenAI兼容接口支持列出模型
      case ProviderType.anthropic:
      case ProviderType.google:
      case ProviderType.ollama:
        return false; // 这些提供商暂不支持动态获取模型列表
    }
  }

  /// 从提供商API获取模型列表
  Future<ModelFetchResult> fetchModelsFromProvider(AiProvider provider) async {
    // 添加调试日志
    _logger.info('开始获取模型列表', {
      'providerName': provider.name,
      'providerType': provider.type.toString(),
      'apiKey': provider.apiKey.isNotEmpty
          ? '${provider.apiKey.substring(0, 8)}...'
          : '空',
      'baseUrl': provider.baseUrl ?? '默认',
    });

    // 检查 API Key 是否已填写
    if (provider.apiKey.isEmpty) {
      return ModelFetchResult.error('请先填写 API Key');
    }

    // 检查提供商是否支持列出模型
    if (!providerSupportsListModels(provider.type)) {
      return ModelFetchResult.error(
        '${provider.name} 不支持动态获取模型列表，请手动添加模型',
      );
    }

    // 创建一个不包含现有模型的临时副本用于测试
    final testProvider = AiProvider(
      id: provider.id,
      name: provider.name,
      type: provider.type,
      apiKey: provider.apiKey,
      baseUrl: provider.baseUrl,
      models: [], // 使用空的模型列表，避免使用旧模型进行测试
      customHeaders: provider.customHeaders,
      isEnabled: provider.isEnabled,
      createdAt: provider.createdAt,
      updatedAt: provider.updatedAt,
    );

    try {
      List<AiModel> availableModels = [];

      // 首先尝试从提供商API获取模型列表
      try {
        final aiService = AiService();
        availableModels = await aiService.fetchModelsFromProvider(testProvider);

        if (availableModels.isNotEmpty) {
          // 成功从API获取模型
          _logger.info('从API成功获取模型', {'count': availableModels.length});
          return ModelFetchResult.success(
            availableModels,
            '从API成功获取 ${availableModels.length} 个模型',
          );
        }
      } catch (e) {
        // API获取失败，记录错误并显示具体错误信息
        _logger.warning('从API获取模型失败', {'error': e.toString()});
        
        // 检查是否是认证错误
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('auth') || 
            errorMessage.contains('api key') || 
            errorMessage.contains('unauthorized')) {
          return ModelFetchResult.error('API密钥无效或已过期，请检查API密钥是否正确');
        } else if (errorMessage.contains('network') || 
                   errorMessage.contains('connection')) {
          return ModelFetchResult.error('网络连接失败，请检查网络连接和Base URL设置');
        } else {
          return ModelFetchResult.error('获取模型列表失败: ${e.toString()}');
        }
      }

      // 使用通用模型作为回退
      final commonModels = _getCommonModelsForProvider(provider.type);

      if (commonModels.isNotEmpty) {
        _logger.info('使用预设模型列表', {'count': commonModels.length});
        return ModelFetchResult.success(
          commonModels,
          '使用预设模型列表 (${commonModels.length} 个模型)',
        );
      } else {
        return ModelFetchResult.error('该提供商暂无预设模型，请手动添加');
      }
    } catch (e) {
      _logger.error('获取模型列表异常', {'error': e.toString()});
      return ModelFetchResult.error('获取模型列表失败: $e');
    }
  }

  /// 获取提供商的常用模型列表
  List<AiModel> _getCommonModelsForProvider(ProviderType type) {
    final now = DateTime.now();
    final models = <AiModel>[];

    switch (type) {
      case ProviderType.openai:
        models.addAll([
          AiModel(
            id: 'gpt-4o',
            name: 'gpt-4o',
            displayName: 'GPT-4o',
            capabilities: [
              ModelCapability.reasoning,
              ModelCapability.vision,
              ModelCapability.tools,
            ],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-4o-mini',
            name: 'gpt-4o-mini',
            displayName: 'GPT-4o Mini',
            capabilities: [
              ModelCapability.reasoning,
              ModelCapability.vision,
              ModelCapability.tools,
            ],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-4-turbo',
            name: 'gpt-4-turbo',
            displayName: 'GPT-4 Turbo',
            capabilities: [
              ModelCapability.reasoning,
              ModelCapability.vision,
              ModelCapability.tools,
            ],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-3.5-turbo',
            name: 'gpt-3.5-turbo',
            displayName: 'GPT-3.5 Turbo',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {'contextLength': 16385},
            createdAt: now,
            updatedAt: now,
          ),
        ]);
        break;
      case ProviderType.custom:
        // 对于自定义提供商，提供一些通用的OpenAI兼容模型
        models.addAll([
          AiModel(
            id: 'deepseek-chat',
            name: 'deepseek-chat',
            displayName: 'DeepSeek Chat',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {'contextLength': 32768},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'deepseek-coder',
            name: 'deepseek-coder',
            displayName: 'DeepSeek Coder',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {'contextLength': 16384},
            createdAt: now,
            updatedAt: now,
          ),
        ]);
        break;
      case ProviderType.anthropic:
      case ProviderType.google:
      case ProviderType.ollama:
        // 这些提供商暂不支持动态获取，返回空列表
        break;
    }

    return models;
  }
}

/// 模型获取结果
class ModelFetchResult {
  final bool isSuccess;
  final List<AiModel>? models;
  final String message;

  const ModelFetchResult._({
    required this.isSuccess,
    this.models,
    required this.message,
  });

  factory ModelFetchResult.success(List<AiModel> models, String message) {
    return ModelFetchResult._(
      isSuccess: true,
      models: models,
      message: message,
    );
  }

  factory ModelFetchResult.error(String message) {
    return ModelFetchResult._(
      isSuccess: false,
      models: null,
      message: message,
    );
  }
}
