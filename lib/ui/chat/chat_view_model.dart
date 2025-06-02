import 'package:flutter/foundation.dart';
import '../../models/ai_assistant.dart';
import '../../models/ai_provider.dart';
import '../../models/message.dart';
import '../../services/ai_service.dart';

/// 聊天视图模型 - 管理聊天状态和AI交互
@immutable
class ChatViewModel {
  /// 创建聊天视图模型实例
  const ChatViewModel({
    required this.aiService,
    required this.assistantId,
    required this.selectedProviderId,
    required this.selectedModelName,
    required this.messages,
    this.welcomeMessage,
    this.suggestions = const [],
    this.enableAttachments = false,
    this.enableVoiceNotes = false,
  });

  /// AI服务实例
  final AiService aiService;

  /// 当前选择的助手ID
  final String assistantId;

  /// 当前选择的提供商ID
  final String selectedProviderId;

  /// 当前选择的模型名称
  final String selectedModelName;

  /// 聊天消息列表
  final List<Message> messages;

  /// 欢迎消息
  final String? welcomeMessage;

  /// 建议消息列表
  final List<String> suggestions;

  /// 是否启用附件功能
  final bool enableAttachments;

  /// 是否启用语音笔记功能
  final bool enableVoiceNotes;

  /// 获取当前助手
  AiAssistant? get currentAssistant => aiService.getAssistant(assistantId);

  /// 获取当前提供商
  AiProvider? get currentProvider => aiService.getProvider(selectedProviderId);

  /// 复制并更新消息列表
  ChatViewModel copyWithMessages(List<Message> newMessages) {
    return ChatViewModel(
      aiService: aiService,
      assistantId: assistantId,
      selectedProviderId: selectedProviderId,
      selectedModelName: selectedModelName,
      messages: newMessages,
      welcomeMessage: welcomeMessage,
      suggestions: suggestions,
      enableAttachments: enableAttachments,
      enableVoiceNotes: enableVoiceNotes,
    );
  }

  /// 复制并更新提供商和模型
  ChatViewModel copyWithProviderAndModel({
    String? newProviderId,
    String? newModelName,
  }) {
    return ChatViewModel(
      aiService: aiService,
      assistantId: assistantId,
      selectedProviderId: newProviderId ?? selectedProviderId,
      selectedModelName: newModelName ?? selectedModelName,
      messages: messages,
      welcomeMessage: welcomeMessage,
      suggestions: suggestions,
      enableAttachments: enableAttachments,
      enableVoiceNotes: enableVoiceNotes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatViewModel &&
          other.aiService == aiService &&
          other.assistantId == assistantId &&
          other.selectedProviderId == selectedProviderId &&
          other.selectedModelName == selectedModelName &&
          listEquals(other.messages, messages) &&
          other.welcomeMessage == welcomeMessage &&
          listEquals(other.suggestions, suggestions) &&
          other.enableAttachments == enableAttachments &&
          other.enableVoiceNotes == enableVoiceNotes);

  @override
  int get hashCode => Object.hash(
    aiService,
    assistantId,
    selectedProviderId,
    selectedModelName,
    messages,
    welcomeMessage,
    suggestions,
    enableAttachments,
    enableVoiceNotes,
  );
}
