import 'ai_model.dart';

enum ProviderType {
  openai('OpenAI', 'openai'),
  anthropic('Anthropic (Claude)', 'anthropic'),
  google('Google (Gemini)', 'google'),
  ollama('Ollama', 'ollama'),
  custom('自定义', 'custom');

  const ProviderType(this.displayName, this.id);
  final String displayName;
  final String id;
}

class AiProvider {
  final String id;
  final String name;
  final ProviderType type;
  final String apiKey;
  final String? baseUrl; // 只有OpenAI和Ollama支持自定义URL
  final List<AiModel> models; // 模型列表
  final Map<String, String> customHeaders;
  final bool isEnabled;
  final DateTime createdAt;
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

  // 检查是否支持自定义URL
  bool get supportsCustomUrl =>
      type == ProviderType.openai || type == ProviderType.ollama;

  // 获取模型名称列表（向后兼容）
  List<String> get supportedModels =>
      models.map((model) => model.name).toList();

  // 获取有效的基础URL
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
        return 'https://generativelanguage.googleapis.com/v1';
      case ProviderType.ollama:
        return 'http://localhost:11434/v1';
      case ProviderType.custom:
        return baseUrl ?? '';
    }
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
