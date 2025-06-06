import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import '../services/logger_service.dart';

/// 模型管理服务（已废弃）
///
/// @deprecated 此服务已废弃，请使用新的AI架构
///
/// 推荐替代方案：
/// - 使用 providerModelsProvider 获取模型列表
/// - 使用 testAiProviderProvider 测试提供商连接
/// - 参考 lib/services/ai/MIGRATION_GUIDE.md
///
/// 新架构优势：
/// - 🔍 **更好的模型发现**: 通过新的ModelService获取模型
/// - 🛡️ **更强的错误处理**: 统一的错误处理机制
/// - 📊 **Riverpod集成**: 完全集成状态管理
/// - 🔄 **智能缓存**: 自动缓存和失效机制
///
/// 迁移指南：
/// - 替换为 ref.read(providerModelsProvider(providerId).future)
/// - 使用新的错误处理机制
@Deprecated('此服务已废弃，请使用 providerModelsProvider 和相关的新AI架构')
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

    // 直接返回错误，引导用户使用新架构
    _logger.warning('使用了废弃的ModelManagementService', {
      'provider': provider.name,
      'recommendation': '使用 providerModelsProvider',
    });

    return ModelFetchResult.error(
      '此服务已废弃，请使用新的AI架构获取模型列表。\n'
      '推荐使用: ref.read(providerModelsProvider("${provider.id}").future)\n'
      '参考: lib/services/ai/MIGRATION_GUIDE.md',
    );
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
