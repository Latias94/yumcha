import '../entities/provider_model_config.dart';
import '../../data/models/openai_config.dart';

/// 提供商标准配置服务
///
/// 提供知名 AI 提供商的标准模型配置和能力信息。
/// 这是一个参考配置服务，不直接影响用户的实际配置。
///
/// 主要功能：
/// - 📋 **标准配置**: 提供 OpenAI 等知名提供商的标准模型配置
/// - 🧠 **能力识别**: 帮助识别模型支持的 AI 能力（视觉、推理、工具调用等）
/// - 💰 **定价信息**: 提供模型的标准定价和上下文窗口信息
/// - 🔍 **模型筛选**: 按类型、能力、发布时间等条件筛选模型
/// - 📊 **推荐算法**: 提供推荐模型和最新模型列表
///
/// 主要用途：
/// 1. 为应用提供模型能力识别的参考依据
/// 2. 帮助推断用户配置模型的可能能力
/// 3. 提供模型的标准参数和定价信息
/// 4. 辅助模型选择和配置验证
///
/// 重要说明：
/// - 这些配置不能直接应用到用户的 AiModel
/// - 用户可能使用 OpenAI 兼容的第三方服务器
/// - 不同提供商对同名模型的实现可能不同
/// - 需要根据实际提供商来判断是否适用
///
/// 使用场景：
/// - 模型能力检测和提示
/// - 配置建议和验证
/// - 模型选择界面的信息展示
class ConfigureProviderUseCase {
  static final ConfigureProviderUseCase _instance =
      ConfigureProviderUseCase._internal();
  factory ConfigureProviderUseCase() => _instance;
  ConfigureProviderUseCase._internal();

  /// 所有支持的提供商配置
  static const Map<String, ProviderConfig> _providerConfigs = {
    'openai': OpenAIConfig.config,
    // 未来可以添加其他提供商配置
    // 'anthropic': AnthropicConfig.config,
    // 'google': GoogleConfig.config,
  };

  /// 获取提供商配置
  ProviderConfig? getProviderConfig(String providerId) {
    return _providerConfigs[providerId.toLowerCase()];
  }

  /// 获取所有提供商配置
  Map<String, ProviderConfig> getAllProviderConfigs() {
    return Map.from(_providerConfigs);
  }

  /// 根据提供商ID和模型ID获取模型配置
  ProviderModelConfig? getModelConfig(String providerId, String modelId) {
    final providerConfig = getProviderConfig(providerId);
    if (providerConfig == null) return null;

    try {
      return providerConfig.models.firstWhere((model) => model.id == modelId);
    } catch (e) {
      return null;
    }
  }

  /// 获取提供商的所有模型配置
  List<ProviderModelConfig> getProviderModels(
    String providerId, {
    ModelType? type,
  }) {
    final providerConfig = getProviderConfig(providerId);
    if (providerConfig == null) return [];

    if (type != null) {
      return providerConfig.models
          .where((model) => model.type == type)
          .toList();
    }
    return providerConfig.models;
  }

  /// 获取提供商的聊天模型配置
  List<ProviderModelConfig> getChatModels(String providerId) {
    return getProviderModels(providerId, type: ModelType.chat);
  }

  /// 获取提供商的嵌入模型配置
  List<ProviderModelConfig> getEmbeddingModels(String providerId) {
    return getProviderModels(providerId, type: ModelType.embedding);
  }

  /// 检查模型是否支持特定能力
  bool modelSupportsAbility(
    String providerId,
    String modelId,
    ModelAbility ability,
  ) {
    final modelConfig = getModelConfig(providerId, modelId);
    return modelConfig?.abilities.contains(ability) ?? false;
  }

  /// 获取模型的能力列表
  Set<ModelAbility> getModelAbilities(String providerId, String modelId) {
    final modelConfig = getModelConfig(providerId, modelId);
    return modelConfig?.abilities ?? {};
  }

  /// 获取模型的定价信息
  ModelPricing? getModelPricing(String providerId, String modelId) {
    final modelConfig = getModelConfig(providerId, modelId);
    return modelConfig?.pricing;
  }

  /// 获取模型的上下文窗口大小
  int? getModelContextWindow(String providerId, String modelId) {
    final modelConfig = getModelConfig(providerId, modelId);
    return modelConfig?.contextWindowTokens;
  }

  /// 获取模型的最大输出token数
  int? getModelMaxOutput(String providerId, String modelId) {
    final modelConfig = getModelConfig(providerId, modelId);
    return modelConfig?.maxOutput;
  }

  /// 获取模型的设置信息
  ModelSettings? getModelSettings(String providerId, String modelId) {
    final modelConfig = getModelConfig(providerId, modelId);
    return modelConfig?.settings;
  }

  /// 检查模型是否支持推理努力参数
  bool modelSupportsReasoningEffort(String providerId, String modelId) {
    final settings = getModelSettings(providerId, modelId);
    return settings?.extendParams.contains('reasoningEffort') ?? false;
  }

  /// 获取提供商的默认基础URL
  String? getProviderDefaultBaseUrl(String providerId) {
    final providerConfig = getProviderConfig(providerId);
    return providerConfig?.defaultBaseUrl;
  }

  /// 获取提供商的描述
  String? getProviderDescription(String providerId) {
    final providerConfig = getProviderConfig(providerId);
    return providerConfig?.description;
  }

  /// 获取提供商支持的模型类型
  Set<ModelType> getProviderSupportedTypes(String providerId) {
    final models = getProviderModels(providerId);
    return models.map((model) => model.type).toSet();
  }

  /// 检查提供商是否支持特定模型类型
  bool providerSupportsType(String providerId, ModelType type) {
    return getProviderSupportedTypes(providerId).contains(type);
  }

  /// 获取提供商的推荐模型（启用且非遗留的模型）
  List<ProviderModelConfig> getRecommendedModels(
    String providerId, {
    ModelType? type,
  }) {
    final models = getProviderModels(providerId, type: type);
    return models.where((model) => model.enabled && !model.legacy).toList();
  }

  /// 获取提供商的最新模型（按发布日期排序）
  List<ProviderModelConfig> getLatestModels(
    String providerId, {
    ModelType? type,
    int limit = 5,
  }) {
    final models = getProviderModels(providerId, type: type);
    final sortedModels = models
        .where((model) => model.releasedAt != null)
        .toList()
      ..sort((a, b) => b.releasedAt!.compareTo(a.releasedAt!));

    return sortedModels.take(limit).toList();
  }

  /// 根据能力筛选模型
  List<ProviderModelConfig> getModelsByAbility(
    String providerId,
    ModelAbility ability,
  ) {
    final models = getProviderModels(providerId);
    return models.where((model) => model.abilities.contains(ability)).toList();
  }

  /// 获取支持推理的模型
  List<ProviderModelConfig> getReasoningModels(String providerId) {
    return getModelsByAbility(providerId, ModelAbility.reasoning);
  }

  /// 获取支持视觉的模型
  List<ProviderModelConfig> getVisionModels(String providerId) {
    return getModelsByAbility(providerId, ModelAbility.vision);
  }

  /// 获取支持函数调用的模型
  List<ProviderModelConfig> getFunctionCallModels(String providerId) {
    return getModelsByAbility(providerId, ModelAbility.functionCall);
  }

  /// 检查是否有提供商配置
  bool hasProviderConfig(String providerId) {
    return _providerConfigs.containsKey(providerId.toLowerCase());
  }

  /// 获取所有支持的提供商ID列表
  List<String> getSupportedProviderIds() {
    return _providerConfigs.keys.toList();
  }
}
