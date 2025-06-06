import 'ai_assistant.dart';
import 'ai_provider.dart';
import 'ai_model.dart';

/// 聊天配置数据模型
///
/// 包含聊天所需的完整配置：AI 助手、提供商、模型的组合。
/// 这是聊天功能的核心配置模型，确保聊天有完整的配置信息。
///
/// 核心特性：
/// - 🤖 **助手配置**: 包含 AI 助手的个性化设置
/// - 🔌 **提供商配置**: 包含 AI 服务提供商的连接信息
/// - 🧠 **模型配置**: 包含具体的 AI 模型信息
/// - 📝 **配置描述**: 提供人性化的配置描述信息
/// - ✅ **完整性保证**: 确保聊天配置的完整性
///
/// 业务逻辑：
/// - 用户首先选择 AI 助手（定义角色和参数）
/// - 然后选择提供商和模型的组合（定义 AI 服务）
/// - 三者组合形成完整的聊天配置
/// - 在聊天过程中可以切换不同的提供商模型组合
///
/// 使用场景：
/// - 聊天界面的配置管理
/// - 配置选择器的结果传递
/// - 聊天请求的参数组装
class ChatConfiguration {
  /// AI 助手配置 - 定义聊天的角色和参数
  final AiAssistant assistant;

  /// AI 提供商配置 - 定义 AI 服务的来源
  final AiProvider provider;

  /// AI 模型配置 - 定义具体使用的模型
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
  int get hashCode =>
      assistant.id.hashCode ^ provider.id.hashCode ^ model.id.hashCode;

  @override
  String toString() {
    return 'ChatConfiguration(assistant: ${assistant.name}, provider: ${provider.name}, model: ${model.name})';
  }
}

/// 模型选择结果数据模型
///
/// 用于模型选择器返回的结果，包含提供商和模型的组合。
/// 这是一个简化的配置模型，不包含助手信息。
///
/// 核心特性：
/// - 🔌 **提供商信息**: 包含选择的 AI 提供商
/// - 🧠 **模型信息**: 包含选择的具体模型
/// - 📝 **描述信息**: 提供组合的描述信息
/// - 🎯 **轻量级**: 相比 ChatConfiguration 更轻量
///
/// 使用场景：
/// - 模型选择器的返回结果
/// - 模型切换时的参数传递
/// - 配置更新时的部分信息传递
class ModelSelection {
  /// 选择的 AI 提供商
  final AiProvider provider;

  /// 选择的 AI 模型
  final AiModel model;

  const ModelSelection({required this.provider, required this.model});

  ModelSelection copyWith({AiProvider? provider, AiModel? model}) {
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
