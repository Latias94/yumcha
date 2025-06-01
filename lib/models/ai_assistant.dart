class AiAssistant {
  final String id;
  final String name;
  final String description;
  final String avatar; // 头像emoji或图片路径
  final String systemPrompt;
  final String providerId; // 关联的提供商ID
  final String modelName; // 使用的模型名称

  // AI参数
  final double temperature; // 温度 0.0-2.0
  final double topP; // Top-P 0.0-1.0
  final int maxTokens; // 最大输出token数
  final int contextLength; // 上下文长度（消息数量）
  final bool streamOutput; // 是否流式输出
  final double? frequencyPenalty; // 频率惩罚 -2.0-2.0
  final double? presencePenalty; // 存在惩罚 -2.0-2.0

  // 自定义配置
  final Map<String, String> customHeaders;
  final Map<String, dynamic> customBody;
  final List<String> stopSequences; // 停止序列

  // 功能设置
  final bool enableWebSearch; // 是否启用网络搜索
  final bool enableCodeExecution; // 是否启用代码执行
  final bool enableImageGeneration; // 是否启用图像生成

  // 元数据
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiAssistant({
    required this.id,
    required this.name,
    required this.description,
    this.avatar = '🤖',
    required this.systemPrompt,
    required this.providerId,
    required this.modelName,
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
    this.enableWebSearch = false,
    this.enableCodeExecution = false,
    this.enableImageGeneration = false,
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
    String? providerId,
    String? modelName,
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
    bool? enableWebSearch,
    bool? enableCodeExecution,
    bool? enableImageGeneration,
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
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
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
      enableWebSearch: enableWebSearch ?? this.enableWebSearch,
      enableCodeExecution: enableCodeExecution ?? this.enableCodeExecution,
      enableImageGeneration:
          enableImageGeneration ?? this.enableImageGeneration,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 验证参数范围
  bool get isTemperatureValid => temperature >= 0.0 && temperature <= 2.0;
  bool get isTopPValid => topP >= 0.0 && topP <= 1.0;
  bool get isMaxTokensValid => maxTokens > 0 && maxTokens <= 8192;
  bool get isContextLengthValid =>
      contextLength == 0 || // 0表示无限制
      (contextLength >= 1 && contextLength <= 256); // 1-256表示具体数量

  bool get isFrequencyPenaltyValid =>
      frequencyPenalty == null ||
      (frequencyPenalty! >= -2.0 && frequencyPenalty! <= 2.0);

  bool get isPresencePenaltyValid =>
      presencePenalty == null ||
      (presencePenalty! >= -2.0 && presencePenalty! <= 2.0);

  // 获取所有参数是否有效
  bool get isValid =>
      isTemperatureValid &&
      isTopPValid &&
      isMaxTokensValid &&
      isContextLengthValid &&
      isFrequencyPenaltyValid &&
      isPresencePenaltyValid;
}
