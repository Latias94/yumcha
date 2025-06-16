import 'ai_model.dart';

/// AI 提供商类型枚举
///
/// 定义支持的 AI 提供商类型，每种类型有不同的 API 接口和特性
enum ProviderType {
  /// OpenAI 提供商 - 支持 GPT 系列模型，也支持其他 OpenAI 兼容的提供商
  openai('OpenAI', 'openai'),

  /// Anthropic 提供商 - 支持 Claude 系列模型
  anthropic('Anthropic (Claude)', 'anthropic'),

  /// Google 提供商 - 支持 Gemini 系列模型
  google('Google (Gemini)', 'google'),

  /// DeepSeek 提供商 - 支持 DeepSeek 系列模型
  deepseek('DeepSeek', 'deepseek'),

  /// Groq 提供商 - 支持高速推理模型
  groq('Groq', 'groq'),

  /// Ollama 本地提供商 - 支持本地部署的开源模型
  ollama('Ollama', 'ollama');

  const ProviderType(this.displayName, this.id);

  /// 提供商的显示名称
  final String displayName;

  /// 提供商的唯一标识符
  final String id;
}

/// AI 提供商数据模型
///
/// 表示用户配置的 AI 服务提供商，如 OpenAI、Anthropic、Google 等。
/// 每个提供商包含连接配置、API 密钥、模型列表等信息。
///
/// 核心特性：
/// - 🔌 **多提供商支持**: 支持主流 AI 服务提供商
/// - 🔑 **安全配置**: 安全存储 API 密钥和连接信息
/// - 🧠 **模型管理**: 每个提供商可配置多个 AI 模型
/// - 🌐 **自定义 URL**: 支持自定义 Base URL（OpenAI 兼容接口）
/// - 📋 **自定义头部**: 支持自定义 HTTP 请求头
/// - ⚙️ **启用控制**: 可以启用或禁用特定提供商
///
/// 业务逻辑：
/// - 用户可以配置多个 AI 提供商，每个提供商有独立的配置
/// - 每个提供商可以配置多个模型，模型包含名称、能力、参数等信息
/// - 提供商可以被启用或禁用，只有启用的提供商才能用于聊天
/// - 在聊天过程中，用户可以切换不同提供商的不同模型
///
/// 使用场景：
/// - 提供商管理界面的配置
/// - 聊天界面的提供商和模型选择
/// - API 调用时的连接配置
class AiProvider {
  /// 提供商唯一标识符
  final String id;

  /// 提供商名称（用户自定义）
  final String name;

  /// 提供商类型
  final ProviderType type;

  /// API 密钥
  final String apiKey;

  /// 自定义 Base URL（OpenAI、DeepSeek、Groq 和 Ollama 支持）
  final String? baseUrl;

  /// 模型列表 - 此提供商配置的所有模型
  final List<AiModel> models;

  /// 自定义 HTTP 请求头
  final Map<String, String> customHeaders;

  /// 是否启用此提供商
  final bool isEnabled;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  const AiProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.apiKey,
    this.baseUrl,
    this.models = const [],
    this.customHeaders = const {},
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  AiProvider copyWith({
    String? id,
    String? name,
    ProviderType? type,
    String? apiKey,
    String? baseUrl,
    List<AiModel>? models,
    Map<String, String>? customHeaders,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      models: models ?? this.models,
      customHeaders: customHeaders ?? this.customHeaders,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 检查是否支持自定义 Base URL
  /// OpenAI、Anthropic、DeepSeek、Groq 和 Ollama 类型支持自定义 URL
  bool get supportsCustomUrl =>
      type == ProviderType.openai ||
      type == ProviderType.anthropic ||
      type == ProviderType.deepseek ||
      type == ProviderType.groq ||
      type == ProviderType.ollama;

  /// 获取模型名称列表（向后兼容）
  /// 返回此提供商配置的所有模型名称
  List<String> get supportedModels =>
      models.map((model) => model.name).toList();

  /// 获取有效的基础 URL
  /// 如果用户设置了自定义 URL 则使用自定义 URL，否则使用默认 URL
  String get effectiveBaseUrl {
    if (baseUrl != null && baseUrl!.isNotEmpty) {
      return baseUrl!;
    }

    switch (type) {
      case ProviderType.openai:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.google:
        return 'https://generativelanguage.googleapis.com/v1beta';
      case ProviderType.deepseek:
        return 'https://api.deepseek.com/v1';
      case ProviderType.groq:
        return 'https://api.groq.com/openai/v1';
      case ProviderType.ollama:
        return 'http://localhost:11434/v1';
    }
  }

  /// 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.id,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'models': models.map((model) => model.toJson()).toList(),
      'customHeaders': customHeaders,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON反序列化
  factory AiProvider.fromJson(Map<String, dynamic> json) {
    return AiProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ProviderType.values.firstWhere(
        (type) => type.id == json['type'],
        orElse: () => ProviderType.openai,
      ),
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String?,
      models: (json['models'] as List<dynamic>?)
          ?.map((modelJson) => AiModel.fromJson(modelJson as Map<String, dynamic>))
          .toList() ?? [],
      customHeaders: Map<String, String>.from(json['customHeaders'] as Map? ?? {}),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiProvider &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          apiKey == other.apiKey &&
          baseUrl == other.baseUrl &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      apiKey.hashCode ^
      baseUrl.hashCode ^
      isEnabled.hashCode;
}
