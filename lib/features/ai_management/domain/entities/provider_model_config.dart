// 提供商标准模型配置系统
//
// 用于定义知名 AI 提供商的标准模型能力和参数配置。
// 这与用户的 AiModel 配置是分离的，仅用于提供标准的模型信息和能力定义。
//
// 核心特性：
// - 📋 **标准配置**: 提供 OpenAI 等知名提供商的标准模型配置
// - 🧠 **能力定义**: 详细定义模型支持的各种 AI 能力
// - 💰 **定价信息**: 包含模型的标准定价和成本信息
// - 🔧 **参数配置**: 定义模型的技术参数和限制
// - 🏷️ **分类管理**: 按类型和能力对模型进行分类
//
// 重要说明：
// - 这些配置不能直接应用到用户的 AiModel
// - 用户可能使用 OpenAI 兼容的第三方服务器
// - 不同提供商对同名模型的实现可能不同
// - 需要根据实际提供商来判断是否适用

/// 模型能力枚举
///
/// 定义 AI 模型支持的各种高级能力，用于标识模型的功能特性。
enum ModelAbility {
  /// 函数调用/工具调用
  functionCall('functionCall', '工具调用'),

  /// 推理能力
  reasoning('reasoning', '推理'),

  /// 视觉理解
  vision('vision', '视觉'),

  /// 网络搜索
  search('search', '搜索'),

  /// 嵌入向量
  embedding('embedding', '嵌入');

  const ModelAbility(this.id, this.displayName);

  final String id;
  final String displayName;
}

/// 模型类型枚举
enum ModelType {
  /// 聊天模型
  chat('chat', '聊天'),

  /// 嵌入模型
  embedding('embedding', '嵌入'),

  /// 语音转文字
  stt('stt', '语音转文字'),

  /// 文字转语音
  tts('tts', '文字转语音'),

  /// 图像生成
  image('image', '图像生成'),

  /// 实时对话
  realtime('realtime', '实时对话');

  const ModelType(this.id, this.displayName);

  final String id;
  final String displayName;
}

/// 定价信息
class ModelPricing {
  /// 输入价格 (每百万token的美元价格)
  final double? input;

  /// 输出价格 (每百万token的美元价格)
  final double? output;

  /// 缓存输入价格 (每百万token的美元价格)
  final double? cachedInput;

  /// 音频输入价格 (每百万token的美元价格)
  final double? audioInput;

  /// 音频输出价格 (每百万token的美元价格)
  final double? audioOutput;

  /// 缓存音频输入价格 (每百万token的美元价格)
  final double? cachedAudioInput;

  /// 标准质量价格 (用于图像生成)
  final double? standard;

  /// 高清质量价格 (用于图像生成)
  final double? hd;

  /// 货币单位
  final String currency;

  const ModelPricing({
    this.input,
    this.output,
    this.cachedInput,
    this.audioInput,
    this.audioOutput,
    this.cachedAudioInput,
    this.standard,
    this.hd,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() {
    return {
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (cachedInput != null) 'cachedInput': cachedInput,
      if (audioInput != null) 'audioInput': audioInput,
      if (audioOutput != null) 'audioOutput': audioOutput,
      if (cachedAudioInput != null) 'cachedAudioInput': cachedAudioInput,
      if (standard != null) 'standard': standard,
      if (hd != null) 'hd': hd,
      'currency': currency,
    };
  }

  factory ModelPricing.fromJson(Map<String, dynamic> json) {
    return ModelPricing(
      input: json['input']?.toDouble(),
      output: json['output']?.toDouble(),
      cachedInput: json['cachedInput']?.toDouble(),
      audioInput: json['audioInput']?.toDouble(),
      audioOutput: json['audioOutput']?.toDouble(),
      cachedAudioInput: json['cachedAudioInput']?.toDouble(),
      standard: json['standard']?.toDouble(),
      hd: json['hd']?.toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }
}

/// 模型设置
class ModelSettings {
  /// 扩展参数列表
  final List<String> extendParams;

  /// 搜索实现方式
  final String? searchImpl;

  /// 支持的分辨率列表 (用于图像生成)
  final List<String> resolutions;

  /// 最大维度 (用于嵌入模型)
  final int? maxDimension;

  const ModelSettings({
    this.extendParams = const [],
    this.searchImpl,
    this.resolutions = const [],
    this.maxDimension,
  });

  Map<String, dynamic> toJson() {
    return {
      'extendParams': extendParams,
      if (searchImpl != null) 'searchImpl': searchImpl,
      'resolutions': resolutions,
      if (maxDimension != null) 'maxDimension': maxDimension,
    };
  }

  factory ModelSettings.fromJson(Map<String, dynamic> json) {
    return ModelSettings(
      extendParams: List<String>.from(json['extendParams'] ?? []),
      searchImpl: json['searchImpl'],
      resolutions: List<String>.from(json['resolutions'] ?? []),
      maxDimension: json['maxDimension'],
    );
  }
}

/// 提供商模型配置
class ProviderModelConfig {
  /// 模型ID
  final String id;

  /// 显示名称
  final String displayName;

  /// 模型描述
  final String description;

  /// 模型类型
  final ModelType type;

  /// 模型能力列表
  final Set<ModelAbility> abilities;

  /// 上下文窗口大小 (token数量)
  final int? contextWindowTokens;

  /// 最大输出token数量
  final int? maxOutput;

  /// 定价信息
  final ModelPricing? pricing;

  /// 发布日期
  final String? releasedAt;

  /// 是否启用
  final bool enabled;

  /// 是否为遗留模型
  final bool legacy;

  /// 模型设置
  final ModelSettings? settings;

  const ProviderModelConfig({
    required this.id,
    required this.displayName,
    required this.description,
    required this.type,
    this.abilities = const {},
    this.contextWindowTokens,
    this.maxOutput,
    this.pricing,
    this.releasedAt,
    this.enabled = true,
    this.legacy = false,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'description': description,
      'type': type.id,
      'abilities': abilities.map((a) => a.id).toList(),
      if (contextWindowTokens != null)
        'contextWindowTokens': contextWindowTokens,
      if (maxOutput != null) 'maxOutput': maxOutput,
      if (pricing != null) 'pricing': pricing!.toJson(),
      if (releasedAt != null) 'releasedAt': releasedAt,
      'enabled': enabled,
      'legacy': legacy,
      if (settings != null) 'settings': settings!.toJson(),
    };
  }

  factory ProviderModelConfig.fromJson(Map<String, dynamic> json) {
    return ProviderModelConfig(
      id: json['id'],
      displayName: json['displayName'],
      description: json['description'],
      type: ModelType.values.firstWhere((t) => t.id == json['type']),
      abilities:
          (json['abilities'] as List<dynamic>?)
              ?.map(
                (a) => ModelAbility.values.firstWhere(
                  (ability) => ability.id == a,
                ),
              )
              .toSet() ??
          {},
      contextWindowTokens: json['contextWindowTokens'],
      maxOutput: json['maxOutput'],
      pricing: json['pricing'] != null
          ? ModelPricing.fromJson(json['pricing'])
          : null,
      releasedAt: json['releasedAt'],
      enabled: json['enabled'] ?? true,
      legacy: json['legacy'] ?? false,
      settings: json['settings'] != null
          ? ModelSettings.fromJson(json['settings'])
          : null,
    );
  }
}

/// 提供商配置
class ProviderConfig {
  /// 提供商名称
  final String name;

  /// 提供商ID
  final String id;

  /// 提供商描述
  final String description;

  /// 默认基础URL
  final String? defaultBaseUrl;

  /// 支持的模型列表
  final List<ProviderModelConfig> models;

  const ProviderConfig({
    required this.name,
    required this.id,
    required this.description,
    this.defaultBaseUrl,
    this.models = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'description': description,
      if (defaultBaseUrl != null) 'defaultBaseUrl': defaultBaseUrl,
      'models': models.map((m) => m.toJson()).toList(),
    };
  }

  factory ProviderConfig.fromJson(Map<String, dynamic> json) {
    return ProviderConfig(
      name: json['name'],
      id: json['id'],
      description: json['description'],
      defaultBaseUrl: json['defaultBaseUrl'],
      models:
          (json['models'] as List<dynamic>?)
              ?.map((m) => ProviderModelConfig.fromJson(m))
              .toList() ??
          [],
    );
  }
}
