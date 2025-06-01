import 'message.dart';

class ConversationUiState {
  final String id;
  final String channelName;
  final int channelMembers;
  final List<Message> messages;
  final String? assistantId;
  final String selectedProviderId;
  final String? selectedModelId;

  const ConversationUiState({
    required this.id,
    required this.channelName,
    required this.channelMembers,
    this.messages = const [],
    this.assistantId,
    required this.selectedProviderId,
    this.selectedModelId,
  });

  ConversationUiState copyWith({
    String? id,
    String? channelName,
    int? channelMembers,
    List<Message>? messages,
    String? assistantId,
    String? selectedProviderId,
    String? selectedModelId,
  }) {
    return ConversationUiState(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      channelMembers: channelMembers ?? this.channelMembers,
      messages: messages ?? this.messages,
      assistantId: assistantId ?? this.assistantId,
      selectedProviderId: selectedProviderId ?? this.selectedProviderId,
      selectedModelId: selectedModelId ?? this.selectedModelId,
    );
  }

  ConversationUiState addMessage(Message message) {
    return copyWith(messages: [message, ...messages]);
  }

  ConversationUiState clearMessages() {
    return copyWith(messages: []);
  }
}
