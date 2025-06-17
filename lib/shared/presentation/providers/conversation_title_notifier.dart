import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/chat/domain/entities/message.dart';
import '../../infrastructure/services/logger_service.dart';
import 'dependency_providers.dart';

import '../../infrastructure/services/ai/providers/ai_service_provider.dart';
import '../../../features/settings/presentation/providers/settings_notifier.dart';
import '../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';

/// 对话标题管理器 - 专门负责对话标题的生成和管理
///
/// 从ConversationNotifier中提取出来，专注于标题相关的业务逻辑：
/// - 🏷️ 自动标题生成
/// - 🔄 手动标题重生成
/// - ✅ 标题生成条件检查
/// - 🎯 标题生成策略管理
class ConversationTitleNotifier extends StateNotifier<Map<String, String>> {
  ConversationTitleNotifier(this._ref) : super({});

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  // 标题生成相关
  final Set<String> _titleGenerationInProgress = {};
  static const String _defaultTitle = "新对话";

  /// 当AI消息添加后，检查是否需要生成标题
  Future<void> onAiMessageAdded(
    String conversationId,
    List<Message> messages,
  ) async {
    if (!_shouldGenerateTitle(conversationId, messages)) {
      return;
    }

    // 异步生成标题，不阻塞主流程
    _generateTitleAsync(conversationId, messages);
  }

  /// 手动重新生成标题
  Future<void> regenerateTitle(
    String conversationId,
    List<Message> messages,
  ) async {
    _logger.info('手动重新生成标题', {'conversationId': conversationId});

    if (_titleGenerationInProgress.contains(conversationId)) {
      _logger.debug('标题生成已在进行中，跳过重复请求');
      return;
    }

    if (messages.length < 2) {
      _logger.warning('消息数量不足，无法生成标题');
      return;
    }

    await _generateTitleForConversation(
      conversationId,
      messages,
      forceRegenerate: true,
    );
  }

  /// 检查是否应该生成标题
  bool _shouldGenerateTitle(String conversationId, List<Message> messages) {
    // 1. 消息至少有2条
    if (messages.length < 2) return false;

    // 2. 当前标题仍是默认标题
    final currentTitle = state[conversationId];
    if (currentTitle != null && currentTitle != _defaultTitle) return false;

    // 3. 确保有用户消息和AI回复
    final hasUserMessage = messages.any((m) => m.isFromUser);
    final hasAiMessage = messages.any((m) => !m.isFromUser);
    if (!hasUserMessage || !hasAiMessage) return false;

    // 4. 检查是否已经在生成标题
    if (_titleGenerationInProgress.contains(conversationId)) return false;

    return true;
  }

  /// 异步生成标题
  Future<void> _generateTitleAsync(
    String conversationId,
    List<Message> messages,
  ) async {
    await _generateTitleForConversation(
      conversationId,
      messages,
      forceRegenerate: false,
    );
  }

  /// 为指定对话生成标题
  Future<void> _generateTitleForConversation(
    String conversationId,
    List<Message> messages, {
    bool forceRegenerate = false,
  }) async {
    // 标记为正在生成
    _titleGenerationInProgress.add(conversationId);

    try {
      _logger.info('为对话生成标题', {
        'conversationId': conversationId,
        'forceRegenerate': forceRegenerate,
      });

      final generatedTitle = await _generateTitleWithSimpleChat(messages);

      if (generatedTitle != null && generatedTitle.isNotEmpty) {
        // 更新标题状态
        state = {...state, conversationId: generatedTitle};

        // 保存到数据库
        await _saveTitle(conversationId, generatedTitle);

        _logger.info('标题生成成功', {
          'conversationId': conversationId,
          'title': generatedTitle,
        });
      } else {
        _logger.warning('标题生成失败或返回空标题');
      }
    } catch (e) {
      _logger.error('标题生成异常', {
        'conversationId': conversationId,
        'error': e.toString(),
      });
    } finally {
      // 移除生成中标记
      _titleGenerationInProgress.remove(conversationId);
    }
  }

  /// 使用简单的AI服务生成标题（不使用工具调用）
  Future<String?> _generateTitleWithSimpleChat(List<Message> messages) async {
    if (messages.isEmpty) return null;

    // 构建标题生成提示
    final titlePrompt = _buildTitleGenerationPrompt(messages);

    // 按优先级选择模型配置
    final modelConfig = _selectModelForTitleGeneration();
    if (modelConfig == null) {
      _logger.warning('无法找到有效的模型配置用于标题生成');
      return null;
    }

    try {
      final response = await _ref.read(
        sendChatMessageProvider(
          SendChatMessageParams(
            provider: modelConfig.provider,
            assistant: modelConfig.assistant,
            modelName: modelConfig.model.name,
            chatHistory: [], // 标题生成不需要历史消息
            userMessage: titlePrompt,
          ),
        ).future,
      );

      if (response.isSuccess && response.content.isNotEmpty) {
        return _cleanTitle(response.content);
      }
    } catch (e) {
      _logger.warning('生成标题失败', {
        'providerId': modelConfig.provider.id,
        'modelName': modelConfig.model.name,
        'error': e.toString(),
      });
    }

    return null;
  }

  /// 按优先级选择标题生成的模型配置
  ///
  /// 优先级：
  /// 1. 用户设置的专门标题生成模型
  /// 2. 任何可用的有效模型（避免循环依赖，不使用当前聊天配置）
  ({
    AiProvider provider,
    AiModel model,
    AiAssistant assistant,
  })? _selectModelForTitleGeneration() {
    // 1. 优先使用专门的标题生成模型设置
    final titleModelConfig = _ref.read(defaultTitleModelProvider);
    if (titleModelConfig?.isConfigured == true) {
      final providers = _ref.read(aiProvidersProvider);
      final assistants = _ref.read(aiAssistantsProvider);

      final provider = providers
          .where((p) => p.id == titleModelConfig!.providerId && p.isEnabled)
          .firstOrNull;
      final model = provider?.models
          .where((m) => m.name == titleModelConfig!.modelName)
          .firstOrNull;
      final assistant = assistants.where((a) => a.isEnabled).firstOrNull;

      if (provider != null && model != null && assistant != null) {
        _logger.info('使用专门的标题生成模型', {
          'providerId': provider.id,
          'modelName': model.name,
        });
        return (provider: provider, model: model, assistant: assistant);
      }
    }

    // 2. 兜底：使用任何可用的有效模型
    // 注意：不使用 currentChatConfigurationProvider 以避免循环依赖
    // currentChatConfigurationProvider 来自 unifiedChatProvider，
    // 而 unifiedChatProvider 监听了 conversationTitleNotifierProvider
    final providers = _ref.read(aiProvidersProvider);
    final assistants = _ref.read(aiAssistantsProvider);

    for (final provider in providers) {
      if (provider.isEnabled && provider.models.isNotEmpty) {
        final assistant = assistants.where((a) => a.isEnabled).firstOrNull;
        if (assistant != null) {
          _logger.info('使用兜底模型配置', {
            'providerId': provider.id,
            'modelName': provider.models.first.name,
          });
          return (
            provider: provider,
            model: provider.models.first,
            assistant: assistant,
          );
        }
      }
    }

    return null;
  }

  /// 构建标题生成提示
  String _buildTitleGenerationPrompt(List<Message> messages) {
    final recentMessages = messages.take(6).toList();
    final conversationSummary = recentMessages.map((msg) {
      final author = msg.isFromUser ? '用户' : 'AI';
      return '$author: ${msg.content}';
    }).join('\n');

    return '''请为以下对话生成一个简洁的标题（不超过20个字符）：

$conversationSummary

要求：
1. 标题要简洁明了，能概括对话主题
2. 不要包含引号或特殊符号
3. 直接返回标题，不要其他解释
4. 标题长度控制在20个字符以内''';
  }

  /// 清理标题文本
  String _cleanTitle(String title) {
    String cleaned = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 移除引号
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }

    // 限制长度
    if (cleaned.length > 20) {
      cleaned = '${cleaned.substring(0, 17)}...';
    }

    return cleaned;
  }

  /// 保存标题到数据库
  Future<void> _saveTitle(String conversationId, String title) async {
    try {
      final repository = _ref.read(conversationRepositoryProvider);

      // 获取当前对话
      final conversation = await repository.getConversation(conversationId);
      if (conversation != null) {
        // 更新标题
        final updatedConversation = conversation.copyWith(channelName: title);
        await repository.saveConversation(updatedConversation);

        // ✅ 符合最佳实践：不直接调用其他模块，让UnifiedChatNotifier通过监听响应
        // UnifiedChatNotifier会监听conversationTitleNotifierProvider的变化
        // 当标题更新后，会自动触发相应的状态更新

        _logger.info('标题保存成功', {
          'conversationId': conversationId,
          'title': title,
        });
      } else {
        _logger.warning('对话不存在，无法保存标题', {'conversationId': conversationId});
      }
    } catch (e) {
      _logger.error('保存标题失败', {
        'conversationId': conversationId,
        'title': title,
        'error': e.toString(),
      });
    }
  }

  /// 获取对话标题
  String? getTitle(String conversationId) {
    return state[conversationId];
  }

  /// 设置对话标题
  void setTitle(String conversationId, String title) {
    state = {...state, conversationId: title};
  }
}

/// 对话标题管理Provider
final conversationTitleNotifierProvider =
    StateNotifierProvider<ConversationTitleNotifier, Map<String, String>>(
  (ref) => ConversationTitleNotifier(ref),
);

/// 获取特定对话标题的Provider
final conversationTitleProvider =
    Provider.family<String?, String>((ref, conversationId) {
  final titles = ref.watch(conversationTitleNotifierProvider);
  return titles[conversationId];
});
