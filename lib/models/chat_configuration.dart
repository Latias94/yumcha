import 'ai_assistant.dart';
import 'ai_provider.dart';
import 'ai_model.dart';

/// 聊天配置类
/// 包含助手配置和模型选择，用于聊天时的完整配置
class ChatConfiguration {
  final AiAssistant assistant;
  final AiProvider provider;
  final AiModel model;

  const ChatConfiguration({
    required this.assistant,
    required this.provider,
    required this.model,
  });

  ChatConfiguration copyWith({
    AiAssistant? assistant,
    AiProvider? provider,
    AiModel? model,
  }) {
    return ChatConfiguration(
      assistant: assistant ?? this.assistant,
      provider: provider ?? this.provider,
      model: model ?? this.model,
    );
  }

  /// 获取有效的显示名称
  String get displayName => '${assistant.name} - ${model.effectiveDisplayName}';

  /// 获取配置描述
  String get description => '${provider.name} / ${model.effectiveDisplayName}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConfiguration &&
          runtimeType == other.runtimeType &&
          assistant.id == other.assistant.id &&
          provider.id == other.provider.id &&
          model.id == other.model.id;

  @override
  int get hashCode => assistant.id.hashCode ^ provider.id.hashCode ^ model.id.hashCode;

  @override
  String toString() {
    return 'ChatConfiguration(assistant: ${assistant.name}, provider: ${provider.name}, model: ${model.name})';
  }
}

/// 简化的模型选择结果
/// 用于模型选择器返回的结果
class ModelSelection {
  final AiProvider provider;
  final AiModel model;

  const ModelSelection({
    required this.provider,
    required this.model,
  });

  ModelSelection copyWith({
    AiProvider? provider,
    AiModel? model,
  }) {
    return ModelSelection(
      provider: provider ?? this.provider,
      model: model ?? this.model,
    );
  }

  /// 获取显示名称
  String get displayName => model.effectiveDisplayName;

  /// 获取提供商和模型的组合描述
  String get description => '${provider.name} / ${model.effectiveDisplayName}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelSelection &&
          runtimeType == other.runtimeType &&
          provider.id == other.provider.id &&
          model.id == other.model.id;

  @override
  int get hashCode => provider.id.hashCode ^ model.id.hashCode;

  @override
  String toString() {
    return 'ModelSelection(provider: ${provider.name}, model: ${model.name})';
  }
}
