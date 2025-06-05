import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import '../services/ai_service.dart';
import '../services/logger_service.dart';

/// 模型管理服务 - 负责从提供商获取和管理模型列表
class ModelManagementService {
  static final ModelManagementService _instance =
      ModelManagementService._internal();
  factory ModelManagementService() => _instance;
  ModelManagementService._internal();

  final LoggerService _logger = LoggerService();

  /// 检查提供商是否支持获取模型列表
  /// 注意：这个方法现在总是返回true，因为我们不再基于提供商类型做硬编码判断
  /// 具体是否支持应该通过实际API调用来确定
  bool providerSupportsListModels(ProviderType type) {
    // 移除硬编码的提供商类型判断，让用户自己尝试获取模型列表
    return true;
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
      return ModelFetchResult.error('${provider.name} 不支持动态获取模型列表，请手动添加模型');
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

      // 不再提供硬编码的回退模型，让用户手动添加
      return ModelFetchResult.error('无法从API获取模型列表，请手动添加模型');
    } catch (e) {
      _logger.error('获取模型列表异常', {'error': e.toString()});
      return ModelFetchResult.error('获取模型列表失败: $e');
    }
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
    return ModelFetchResult._(isSuccess: false, models: null, message: message);
  }
}
