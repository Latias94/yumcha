enum ModelCapability {
  chat('聊天', 'chat'),
  embedding('嵌入', 'embedding'),
  imageGeneration('图片生成', 'image_generation'),
  imageAnalysis('图片分析', 'image_analysis'),
  audioTranscription('音频转录', 'audio_transcription'),
  audioGeneration('音频生成', 'audio_generation');

  const ModelCapability(this.displayName, this.id);
  final String displayName;
  final String id;
}

class AiModel {
  final String id;
  final String name;
  final String displayName;
  final List<ModelCapability> capabilities;
  final Map<String, dynamic> metadata; // 额外的模型信息，如上下文长度等
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiModel({
    required this.id,
    required this.name,
    this.displayName = '',
    this.capabilities = const [ModelCapability.chat],
    this.metadata = const {},
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

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
      capabilities:
          (json['capabilities'] as List<dynamic>?)
              ?.map(
                (c) => ModelCapability.values.firstWhere(
                  (cap) => cap.id == c,
                  orElse: () => ModelCapability.chat,
                ),
              )
              .toList() ??
          [ModelCapability.chat],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
