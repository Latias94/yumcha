import 'package:flutter/foundation.dart';
import 'message.dart';

class ConversationUiState {
  final String channelName;
  final int channelMembers;
  final List<Message> _messages;

  const ConversationUiState({
    required this.channelName,
    required this.channelMembers,
    required List<Message> initialMessages,
  }) : _messages = initialMessages;

  List<Message> get messages => List.unmodifiable(_messages);

  ConversationUiState addMessage(Message message) {
    final newMessages = [message, ..._messages];
    return ConversationUiState(
      channelName: channelName,
      channelMembers: channelMembers,
      initialMessages: newMessages,
    );
  }

  ConversationUiState copyWith({
    String? channelName,
    int? channelMembers,
    List<Message>? messages,
  }) {
    return ConversationUiState(
      channelName: channelName ?? this.channelName,
      channelMembers: channelMembers ?? this.channelMembers,
      initialMessages: messages ?? _messages,
    );
  }
}
