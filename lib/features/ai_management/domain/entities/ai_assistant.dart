/// AI 助手数据模型
///
/// 表示用户创建的个性化 AI 助手。每个助手都有独特的系统提示词、
/// AI 参数配置和功能设置，不绑定特定的提供商或模型。
///
/// 核心特性：
/// - 🎭 **个性化配置**: 独特的系统提示词和 AI 参数
/// - 🔧 **灵活参数**: 温度、Top-P、最大 token 等可调节参数
/// - 🛠️ **功能开关**: 代码执行、图像生成、工具调用等功能控制
/// - 🎯 **独立性**: 不绑定特定提供商或模型，可灵活切换
/// - ✅ **参数验证**: 内置参数范围验证功能
///
/// 业务逻辑：
/// - 用户可以创建多个助手，每个助手代表不同的聊天角色
/// - 助手配置包括基本信息、AI 参数、功能设置等
/// - 在聊天时选择助手，然后可以切换不同的提供商模型组合
/// - 助手的参数会影响 AI 的回复风格和行为
///
/// 使用场景：
/// - 创建专门的编程助手、写作助手、翻译助手等
/// - 为不同场景配置不同的 AI 参数
/// - 管理多个个性化的 AI 角色
class AiAssistant {
  /// 助手唯一标识符
  final String id;

  /// 助手名称
  final String name;

  /// 助手描述
  final String description;

  /// 头像 emoji 或图片路径
  final String avatar;

  /// 系统提示词 - 定义助手的角色和行为
  final String systemPrompt;

  // ========== AI 参数配置 ==========

  /// 温度参数 (0.0-2.0) - 控制回复的随机性和创造性
  /// 0.0: 最确定性的回复
  /// 1.0: 平衡的创造性
  /// 2.0: 最大的随机性和创造性
  final double temperature;

  /// Top-P 参数 (0.0-1.0) - 核心采样，控制词汇选择的多样性
  final double topP;

  /// 最大输出 token 数 - 限制 AI 回复的长度
  final int maxTokens;

  /// 上下文长度（消息数量）- 0 表示无限制，其他值表示保留的历史消息数
  final int contextLength;

  /// 是否启用流式输出 - 实时显示 AI 回复过程
  final bool streamOutput;

  /// 频率惩罚 (-2.0-2.0) - 减少重复词汇的使用
  final double? frequencyPenalty;

  /// 存在惩罚 (-2.0-2.0) - 鼓励谈论新话题
  final double? presencePenalty;

  // ========== 自定义配置 ==========

  /// 自定义 HTTP 请求头
  final Map<String, String> customHeaders;

  /// 自定义请求体参数
  final Map<String, dynamic> customBody;

  /// 停止序列 - AI 遇到这些序列时停止生成
  final List<String> stopSequences;

  // ========== 功能开关 ==========

  /// 是否启用代码执行功能
  final bool enableCodeExecution;

  /// 是否启用图像生成功能
  final bool enableImageGeneration;

  /// 是否支持工具调用/函数调用
  final bool enableTools;

  /// 是否支持推理增强（如 OpenAI o1 系列）
  final bool enableReasoning;

  /// 是否支持视觉理解（图像输入）
  final bool enableVision;

  /// 是否支持向量嵌入
  final bool enableEmbedding;

  // ========== MCP 配置 ==========

  /// 关联的 MCP 服务器 ID 列表
  /// 助手可以使用这些 MCP 服务器提供的工具
  final List<String> mcpServerIds;

  // ========== 元数据 ==========

  /// 是否启用此助手
  final bool isEnabled;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  const AiAssistant({
    required this.id,
    required this.name,
    required this.description,
    this.avatar = '🤖',
    required this.systemPrompt,
    this.temperature = 0.7,
    this.topP = 1.0,
    this.maxTokens = 2048,
    this.contextLength = 10,
    this.streamOutput = true,
    this.frequencyPenalty,
    this.presencePenalty,
    this.customHeaders = const {},
    this.customBody = const {},
    this.stopSequences = const [],
    this.enableCodeExecution = false,
    this.enableImageGeneration = false,
    this.enableTools = false,
    this.enableReasoning = false,
    this.enableVision = false,
    this.enableEmbedding = false,
    this.mcpServerIds = const [],
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  AiAssistant copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    String? systemPrompt,
    double? temperature,
    double? topP,
    int? maxTokens,
    int? contextLength,
    bool? streamOutput,
    double? frequencyPenalty,
    double? presencePenalty,
    Map<String, String>? customHeaders,
    Map<String, dynamic>? customBody,
    List<String>? stopSequences,
    bool? enableCodeExecution,
    bool? enableImageGeneration,
    bool? enableTools,
    bool? enableReasoning,
    bool? enableVision,
    bool? enableEmbedding,
    List<String>? mcpServerIds,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiAssistant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      contextLength: contextLength ?? this.contextLength,
      streamOutput: streamOutput ?? this.streamOutput,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      customHeaders: customHeaders ?? this.customHeaders,
      customBody: customBody ?? this.customBody,
      stopSequences: stopSequences ?? this.stopSequences,
      enableCodeExecution: enableCodeExecution ?? this.enableCodeExecution,
      enableImageGeneration:
          enableImageGeneration ?? this.enableImageGeneration,
      enableTools: enableTools ?? this.enableTools,
      enableReasoning: enableReasoning ?? this.enableReasoning,
      enableVision: enableVision ?? this.enableVision,
      enableEmbedding: enableEmbedding ?? this.enableEmbedding,
      mcpServerIds: mcpServerIds ?? this.mcpServerIds,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ========== 参数验证方法 ==========

  /// 验证温度参数是否在有效范围内 (0.0-2.0)
  bool get isTemperatureValid => temperature >= 0.0 && temperature <= 2.0;

  /// 验证 Top-P 参数是否在有效范围内 (0.0-1.0)
  bool get isTopPValid => topP >= 0.0 && topP <= 1.0;

  /// 验证最大 token 数是否在有效范围内 (1-8192)
  bool get isMaxTokensValid => maxTokens > 0 && maxTokens <= 8192;

  /// 验证上下文长度是否有效
  /// 0 表示无限制，1-256 表示具体的消息数量
  bool get isContextLengthValid =>
      contextLength == 0 || // 0表示无限制
      (contextLength >= 1 && contextLength <= 256); // 1-256表示具体数量

  /// 验证频率惩罚参数是否在有效范围内 (-2.0-2.0)
  bool get isFrequencyPenaltyValid =>
      frequencyPenalty == null ||
      (frequencyPenalty! >= -2.0 && frequencyPenalty! <= 2.0);

  /// 验证存在惩罚参数是否在有效范围内 (-2.0-2.0)
  bool get isPresencePenaltyValid =>
      presencePenalty == null ||
      (presencePenalty! >= -2.0 && presencePenalty! <= 2.0);

  /// 检查所有参数是否都在有效范围内
  bool get isValid =>
      isTemperatureValid &&
      isTopPValid &&
      isMaxTokensValid &&
      isContextLengthValid &&
      isFrequencyPenaltyValid &&
      isPresencePenaltyValid;

  /// 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'systemPrompt': systemPrompt,
      'temperature': temperature,
      'topP': topP,
      'maxTokens': maxTokens,
      'contextLength': contextLength,
      'streamOutput': streamOutput,
      'frequencyPenalty': frequencyPenalty,
      'presencePenalty': presencePenalty,
      'customHeaders': customHeaders,
      'customBody': customBody,
      'stopSequences': stopSequences,
      'enableCodeExecution': enableCodeExecution,
      'enableImageGeneration': enableImageGeneration,
      'enableTools': enableTools,
      'enableReasoning': enableReasoning,
      'enableVision': enableVision,
      'enableEmbedding': enableEmbedding,
      'mcpServerIds': mcpServerIds,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON反序列化
  factory AiAssistant.fromJson(Map<String, dynamic> json) {
    return AiAssistant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      avatar: json['avatar'] as String? ?? '🤖',
      systemPrompt: json['systemPrompt'] as String,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble() ?? 1.0,
      maxTokens: json['maxTokens'] as int? ?? 2048,
      contextLength: json['contextLength'] as int? ?? 10,
      streamOutput: json['streamOutput'] as bool? ?? true,
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble(),
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble(),
      customHeaders:
          Map<String, String>.from(json['customHeaders'] as Map? ?? {}),
      customBody: Map<String, dynamic>.from(json['customBody'] as Map? ?? {}),
      stopSequences: List<String>.from(json['stopSequences'] as List? ?? []),
      enableCodeExecution: json['enableCodeExecution'] as bool? ?? false,
      enableImageGeneration: json['enableImageGeneration'] as bool? ?? false,
      enableTools: json['enableTools'] as bool? ?? false,
      enableReasoning: json['enableReasoning'] as bool? ?? false,
      enableVision: json['enableVision'] as bool? ?? false,
      enableEmbedding: json['enableEmbedding'] as bool? ?? false,
      mcpServerIds: List<String>.from(json['mcpServerIds'] as List? ?? []),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
