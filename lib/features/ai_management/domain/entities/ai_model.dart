/// AI 模型能力枚举
///
/// 定义 AI 模型支持的各种能力，用于标识模型的功能特性
enum ModelCapability {
  /// 视觉理解能力 - 可以处理和理解图像内容
  vision('视觉', 'vision'),

  /// 向量嵌入能力 - 可以将文本转换为向量表示
  embedding('嵌入', 'embedding'),

  /// 推理能力 - 具备逻辑推理和思考能力（如 OpenAI o1 系列）
  reasoning('推理', 'reasoning'),

  /// 工具调用能力 - 支持函数调用和工具使用
  tools('工具', 'tools');

  const ModelCapability(this.displayName, this.id);

  /// 能力的显示名称
  final String displayName;

  /// 能力的唯一标识符
  final String id;
}

/// AI 模型数据模型
///
/// 表示用户在提供商中配置的具体 AI 模型。每个模型包含名称、能力、
/// 元数据等信息，属于特定的 AI 提供商。
///
/// 核心特性：
/// - 🏷️ **模型标识**: 唯一的 ID 和名称标识
/// - 🎯 **能力定义**: 明确标识模型支持的功能（视觉、推理、工具等）
/// - 📊 **元数据存储**: 灵活存储模型的额外信息（上下文长度、定价等）
/// - ⚙️ **启用控制**: 可以启用或禁用特定模型
/// - 🔄 **序列化支持**: 支持 JSON 序列化和反序列化
///
/// 业务逻辑：
/// - 每个 AI 提供商可以配置多个模型
/// - 模型的能力决定了它可以执行的任务类型
/// - 用户在聊天时可以选择不同的模型来获得不同的体验
/// - 模型的元数据可以存储上下文窗口、定价、版本等信息
///
/// 使用场景：
/// - 提供商配置界面的模型管理
/// - 聊天界面的模型选择
/// - 模型能力检测和功能启用
class AiModel {
  /// 模型唯一标识符
  final String id;

  /// 模型名称（通常是 API 中使用的名称）
  final String name;

  /// 模型显示名称（用户友好的名称）
  final String displayName;

  /// 模型支持的能力列表
  final List<ModelCapability> capabilities;

  /// 模型元数据 - 存储额外信息如上下文长度、定价、版本等
  final Map<String, dynamic> metadata;

  /// 是否启用此模型
  final bool isEnabled;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  const AiModel({
    required this.id,
    required this.name,
    this.displayName = '',
    this.capabilities = const [ModelCapability.reasoning],
    this.metadata = const {},
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 获取有效的显示名称
  /// 如果 displayName 为空，则使用 name 作为显示名称
  String get effectiveDisplayName => displayName.isEmpty ? name : displayName;

  AiModel copyWith({
    String? id,
    String? name,
    String? displayName,
    List<ModelCapability>? capabilities,
    Map<String, dynamic>? metadata,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      capabilities: capabilities ?? this.capabilities,
      metadata: metadata ?? this.metadata,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'capabilities': capabilities.map((c) => c.id).toList(),
      'metadata': metadata,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String? ?? '',
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map(
                (c) => ModelCapability.values.firstWhere(
                  (cap) => cap.id == c,
                  orElse: () => ModelCapability.reasoning,
                ),
              )
              .toList() ??
          [ModelCapability.reasoning],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          displayName == other.displayName &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ displayName.hashCode ^ isEnabled.hashCode;
}
