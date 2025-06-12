import '../../features/ai_management/domain/entities/ai_model.dart';
import '../../features/ai_management/domain/entities/ai_provider.dart';
import '../../features/ai_management/domain/entities/provider_model_config.dart';
import '../../features/ai_management/domain/usecases/configure_provider_usecase.dart';

/// 模型配置工具类
/// 用于基于提供商标准配置来推断和增强用户配置的模型信息
///
/// 主要功能：
/// 1. 根据提供商类型和模型名称推断模型能力
/// 2. 为用户的 AiModel 补充标准配置信息（如上下文长度、定价等）
/// 3. 检查模型是否为知名模型及其特性
///
/// 注意：只有当用户的提供商类型与标准配置匹配时才应用配置
class ModelConfigUtils {
  static final ConfigureProviderUseCase _configService =
      ConfigureProviderUseCase();

  /// 为模型应用提供商标准配置的能力和参数
  /// 只有当提供商确实是官方提供商时才应用标准配置
  static AiModel applyProviderConfig(AiModel model, AiProvider provider) {
    // 检查是否有对应提供商的标准配置
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return model; // 没有标准配置则返回原模型
    }

    // 只有当提供商是官方提供商时才应用标准配置
    // 对于自定义或第三方提供商，即使模型名相同也不应用
    if (!_isOfficialProvider(provider)) {
      return model;
    }

    final modelConfig = _configService.getModelConfig(
      provider.type.id,
      model.name,
    );
    if (modelConfig == null) {
      return model; // 没有找到模型配置则返回原模型
    }

    // 应用配置的能力（仅作为补充，不覆盖用户已配置的能力）
    final configuredCapabilities = _convertAbilitiesToCapabilities(
      modelConfig.abilities,
    );

    // 合并原有能力和配置的能力（去重）
    final mergedCapabilities = <ModelCapability>{
      ...model.capabilities,
      ...configuredCapabilities,
    }.toList();

    // 更新模型的元数据（保留用户原有的元数据）
    final updatedMetadata = <String, dynamic>{
      ...model.metadata,
      // 只有当用户没有配置时才使用标准配置
      if (!model.metadata.containsKey('description'))
        'description': modelConfig.description,
      if (!model.metadata.containsKey('contextWindowTokens') &&
          modelConfig.contextWindowTokens != null)
        'contextWindowTokens': modelConfig.contextWindowTokens!,
      if (!model.metadata.containsKey('maxOutput') &&
          modelConfig.maxOutput != null)
        'maxOutput': modelConfig.maxOutput!,
      if (!model.metadata.containsKey('releasedAt') &&
          modelConfig.releasedAt != null)
        'releasedAt': modelConfig.releasedAt!,
      // 标准配置信息（作为参考）
      'standardConfig': {
        'legacy': modelConfig.legacy,
        'enabled': modelConfig.enabled,
        if (modelConfig.pricing != null)
          'pricing': modelConfig.pricing!.toJson(),
        if (modelConfig.settings != null)
          'settings': modelConfig.settings!.toJson(),
      },
      'configSource': 'provider_standard_config',
      'configAppliedAt': DateTime.now().toIso8601String(),
    };

    return model.copyWith(
      displayName: model.displayName.isEmpty
          ? modelConfig.displayName
          : model.displayName,
      capabilities: mergedCapabilities,
      metadata: updatedMetadata,
    );
  }

  /// 检查是否为官方提供商
  static bool _isOfficialProvider(AiProvider provider) {
    // 检查基础URL是否为官方URL
    final baseUrl = provider.baseUrl?.toLowerCase() ?? '';

    switch (provider.type.id.toLowerCase()) {
      case 'openai':
        return baseUrl.contains('api.openai.com') || baseUrl.isEmpty;
      case 'anthropic':
        return baseUrl.contains('api.anthropic.com') || baseUrl.isEmpty;
      case 'google':
        return baseUrl.contains('generativelanguage.googleapis.com') ||
            baseUrl.isEmpty;
      default:
        return false;
    }
  }

  /// 将ModelAbility转换为ModelCapability
  static List<ModelCapability> _convertAbilitiesToCapabilities(
    Set<ModelAbility> abilities,
  ) {
    return abilities.map((ability) {
      switch (ability) {
        case ModelAbility.functionCall:
          return ModelCapability.tools;
        case ModelAbility.reasoning:
          return ModelCapability.reasoning;
        case ModelAbility.vision:
          return ModelCapability.vision;
        case ModelAbility.embedding:
          return ModelCapability.embedding;
        case ModelAbility.search:
          return ModelCapability.tools; // 搜索能力映射到工具调用
      }
    }).toList();
  }

  /// 为提供商的所有模型应用配置
  static List<AiModel> applyProviderConfigToModels(
    List<AiModel> models,
    AiProvider provider,
  ) {
    return models.map((model) => applyProviderConfig(model, provider)).toList();
  }

  /// 从提供商配置生成推荐的模型列表
  static List<AiModel> generateRecommendedModels(
    AiProvider provider, {
    ModelType? type,
  }) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return []; // 没有配置则返回空列表
    }

    final recommendedConfigs = _configService.getRecommendedModels(
      provider.type.id,
      type: type,
    );

    return recommendedConfigs
        .map((config) => _convertConfigToAiModel(config))
        .toList();
  }

  /// 将提供商模型配置转换为应用的AiModel
  static AiModel _convertConfigToAiModel(ProviderModelConfig config) {
    // 将ModelAbility转换为ModelCapability
    final capabilities = config.abilities.map((ability) {
      switch (ability) {
        case ModelAbility.functionCall:
          return ModelCapability.tools;
        case ModelAbility.reasoning:
          return ModelCapability.reasoning;
        case ModelAbility.vision:
          return ModelCapability.vision;
        case ModelAbility.embedding:
          return ModelCapability.embedding;
        case ModelAbility.search:
          // 搜索能力可以映射到工具调用
          return ModelCapability.tools;
      }
    }).toSet();

    return AiModel(
      id: config.id,
      name: config.id,
      displayName: config.displayName,
      capabilities: capabilities.toList(),
      metadata: {
        'description': config.description,
        'type': config.type.id,
        if (config.contextWindowTokens != null)
          'contextWindowTokens': config.contextWindowTokens!,
        if (config.maxOutput != null) 'maxOutput': config.maxOutput!,
        if (config.releasedAt != null) 'releasedAt': config.releasedAt!,
        'enabled': config.enabled,
        'legacy': config.legacy,
        if (config.pricing != null) 'pricing': config.pricing!.toJson(),
        if (config.settings != null) 'settings': config.settings!.toJson(),
        'source': 'provider_config',
      },
      isEnabled: config.enabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 检查模型是否支持特定能力（基于配置）
  static bool modelSupportsCapability(
    String modelName,
    AiProvider provider,
    ModelCapability capability,
  ) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return false;
    }

    final modelConfig = _configService.getModelConfig(
      provider.type.id,
      modelName,
    );
    if (modelConfig == null) return false;

    // 将ModelCapability转换为ModelAbility进行检查
    final ability = _convertCapabilityToAbility(capability);
    if (ability == null) return false;

    return modelConfig.abilities.contains(ability);
  }

  /// 将ModelCapability转换为ModelAbility
  static ModelAbility? _convertCapabilityToAbility(ModelCapability capability) {
    switch (capability) {
      case ModelCapability.tools:
        return ModelAbility.functionCall;
      case ModelCapability.reasoning:
        return ModelAbility.reasoning;
      case ModelCapability.vision:
        return ModelAbility.vision;
      case ModelCapability.embedding:
        return ModelAbility.embedding;
    }
  }

  /// 获取模型的推荐参数（基于配置）
  static Map<String, dynamic> getRecommendedParameters(
    String modelName,
    AiProvider provider,
  ) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return {};
    }

    final modelConfig = _configService.getModelConfig(
      provider.type.id,
      modelName,
    );
    if (modelConfig == null) return {};

    final parameters = <String, dynamic>{};

    // 添加上下文窗口信息
    if (modelConfig.contextWindowTokens != null) {
      parameters['contextWindowTokens'] = modelConfig.contextWindowTokens;
    }

    // 添加最大输出信息
    if (modelConfig.maxOutput != null) {
      parameters['maxOutput'] = modelConfig.maxOutput;
    }

    // 添加推理努力参数支持信息
    if (modelConfig.settings?.extendParams.contains('reasoningEffort') ==
        true) {
      parameters['supportsReasoningEffort'] = true;
    }

    // 添加定价信息
    if (modelConfig.pricing != null) {
      parameters['pricing'] = modelConfig.pricing!.toJson();
    }

    return parameters;
  }

  /// 获取模型的显示信息（包含配置的描述等）
  static Map<String, String> getModelDisplayInfo(
    String modelName,
    AiProvider provider,
  ) {
    final info = <String, String>{'name': modelName, 'displayName': modelName};

    if (!_configService.hasProviderConfig(provider.type.id)) {
      return info;
    }

    final modelConfig = _configService.getModelConfig(
      provider.type.id,
      modelName,
    );
    if (modelConfig == null) return info;

    info['displayName'] = modelConfig.displayName;
    info['description'] = modelConfig.description;

    if (modelConfig.releasedAt != null) {
      info['releasedAt'] = modelConfig.releasedAt!;
    }

    // 添加能力描述
    final abilities =
        modelConfig.abilities.map((a) => a.displayName).join(', ');
    if (abilities.isNotEmpty) {
      info['abilities'] = abilities;
    }

    return info;
  }

  /// 检查模型是否为推荐模型
  static bool isRecommendedModel(String modelName, AiProvider provider) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return false;
    }

    final modelConfig = _configService.getModelConfig(
      provider.type.id,
      modelName,
    );
    return modelConfig?.enabled == true && modelConfig?.legacy != true;
  }

  /// 检查模型是否为遗留模型
  static bool isLegacyModel(String modelName, AiProvider provider) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return false;
    }

    final modelConfig = _configService.getModelConfig(
      provider.type.id,
      modelName,
    );
    return modelConfig?.legacy == true;
  }

  /// 获取提供商的默认基础URL
  static String? getProviderDefaultBaseUrl(AiProvider provider) {
    return _configService.getProviderDefaultBaseUrl(provider.type.id);
  }

  /// 获取模型类型的显示名称
  static String getModelTypeDisplayName(ModelType type) {
    return type.displayName;
  }

  /// 获取模型能力的显示名称
  static String getModelAbilityDisplayName(ModelAbility ability) {
    return ability.displayName;
  }

  /// 检查提供商是否有配置支持
  static bool hasProviderConfigSupport(AiProvider provider) {
    return _configService.hasProviderConfig(provider.type.id);
  }

  /// 获取提供商支持的模型类型
  static Set<ModelType> getProviderSupportedTypes(AiProvider provider) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return {};
    }
    return _configService.getProviderSupportedTypes(provider.type.id);
  }

  /// 获取提供商的聊天模型配置
  static List<ProviderModelConfig> getChatModelConfigs(AiProvider provider) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return [];
    }
    return _configService.getChatModels(provider.type.id);
  }

  /// 获取提供商的最新模型
  static List<ProviderModelConfig> getLatestModels(
    AiProvider provider, {
    int limit = 5,
  }) {
    if (!_configService.hasProviderConfig(provider.type.id)) {
      return [];
    }
    return _configService.getLatestModels(
      provider.type.id,
      type: ModelType.chat,
      limit: limit,
    );
  }
}
