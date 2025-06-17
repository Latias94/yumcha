import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/chat/domain/entities/message.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';
import 'dependency_providers.dart';

import '../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';

/// 对话服务 - 封装对话相关的复杂业务逻辑
///
/// 这个服务类将原本在ConversationNotifier中的复杂依赖逻辑提取出来，
/// 使得ConversationNotifier只需要依赖这一个服务，简化依赖关系。
class ConversationService {
  ConversationService(this._ref);

  final Ref _ref;

  /// 获取默认配置
  Future<ConversationConfig> getDefaultConfiguration() async {
    // 使用新的统一AI管理Provider
    // 注意：不使用 currentChatConfigurationProvider 以避免循环依赖
    final providers = _ref.read(aiProvidersProvider);
    final assistants = _ref.read(aiAssistantsProvider);

    // 选择第一个可用的提供商和助手
    final enabledProviders = providers.where((p) => p.isEnabled).toList();
    final enabledAssistants = assistants.where((a) => a.isEnabled).toList();

    final provider = enabledProviders.isNotEmpty ? enabledProviders.first : null;
    final assistant = enabledAssistants.isNotEmpty ? enabledAssistants.first : null;
    final modelName = provider?.models.isNotEmpty == true ? provider!.models.first.name : null;

    return ConversationConfig(
      assistant: assistant,
      provider: provider,
      modelName: modelName,
    );
  }

  /// 生成对话标题
  Future<String?> generateTitle(List<Message> messages) async {
    // 标题生成逻辑
    if (messages.length < 2) return null;

    final config = await getDefaultConfiguration();
    if (config.provider == null || config.modelName == null) return null;

    // 调用AI服务生成标题
    // ... 标题生成逻辑
    return "生成的标题";
  }

  /// 保存对话
  Future<void> saveConversation(ConversationUiState conversation) async {
    final repository = _ref.read(conversationRepositoryProvider);
    await repository.saveConversation(conversation);
  }
}

/// 对话配置数据类
class ConversationConfig {
  final AiAssistant? assistant;
  final AiProvider? provider;
  final String? modelName;

  const ConversationConfig({
    this.assistant,
    this.provider,
    this.modelName,
  });
}

/// 对话服务Provider
final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService(ref);
});
