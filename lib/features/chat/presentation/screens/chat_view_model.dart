import 'package:flutter/foundation.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../domain/entities/message.dart';

/// 聊天视图模型 - 管理聊天状态和AI交互
@immutable
class ChatViewModel {
  /// 创建聊天视图模型实例
  const ChatViewModel({
    required this.assistantId,
    required this.selectedProviderId,
    required this.selectedModelName,
    required this.messages,
    this.currentAssistant,
    this.currentProvider,
    this.welcomeMessage,
    this.suggestions = const [],
    this.enableAttachments = false,
    this.enableVoiceNotes = false,
  });

  /// 当前选择的助手ID
  final String assistantId;

  /// 当前选择的提供商ID
  final String selectedProviderId;

  /// 当前选择的模型名称
  final String selectedModelName;

  /// 聊天消息列表
  final List<Message> messages;

  /// 当前助手（直接传递，避免查询）
  final AiAssistant? currentAssistant;

  /// 当前提供商（直接传递，避免查询）
  final AiProvider? currentProvider;

  /// 欢迎消息
  final String? welcomeMessage;

  /// 建议消息列表
  final List<String> suggestions;

  /// 是否启用附件功能
  final bool enableAttachments;

  /// 是否启用语音笔记功能
  final bool enableVoiceNotes;

  /// 复制并更新消息列表
  ChatViewModel copyWithMessages(List<Message> newMessages) {
    return ChatViewModel(
      assistantId: assistantId,
      selectedProviderId: selectedProviderId,
      selectedModelName: selectedModelName,
      messages: newMessages,
      currentAssistant: currentAssistant,
      currentProvider: currentProvider,
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
    AiProvider? newProvider,
  }) {
    return ChatViewModel(
      assistantId: assistantId,
      selectedProviderId: newProviderId ?? selectedProviderId,
      selectedModelName: newModelName ?? selectedModelName,
      messages: messages,
      currentAssistant: currentAssistant,
      currentProvider: newProvider ?? currentProvider,
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
          other.assistantId == assistantId &&
          other.selectedProviderId == selectedProviderId &&
          other.selectedModelName == selectedModelName &&
          listEquals(other.messages, messages) &&
          other.currentAssistant == currentAssistant &&
          other.currentProvider == currentProvider &&
          other.welcomeMessage == welcomeMessage &&
          listEquals(other.suggestions, suggestions) &&
          other.enableAttachments == enableAttachments &&
          other.enableVoiceNotes == enableVoiceNotes);

  @override
  int get hashCode => Object.hash(
        assistantId,
        selectedProviderId,
        selectedModelName,
        messages,
        currentAssistant,
        currentProvider,
        welcomeMessage,
        suggestions,
        enableAttachments,
        enableVoiceNotes,
      );
}
