import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/features/chat/domain/entities/conversation_ui_state.dart';
import 'package:yumcha/features/chat/domain/entities/message.dart';

void main() {
  group('ConversationUiState', () {
    test('addMessage should add new message to the end of the list', () {
      // Arrange
      final initialMessage = Message(
        author: 'User',
        content: 'First message',
        timestamp: DateTime(2024, 1, 1, 10, 0),
        isFromUser: true,
      );

      final conversation = ConversationUiState(
        id: 'test-conversation',
        channelName: 'Test Chat',
        channelMembers: 1,
        messages: [initialMessage],
        selectedProviderId: 'test-provider',
      );

      final newMessage = Message(
        author: 'AI',
        content: 'Second message',
        timestamp: DateTime(2024, 1, 1, 10, 1),
        isFromUser: false,
      );

      // Act
      final updatedConversation = conversation.addMessage(newMessage);

      // Assert
      expect(updatedConversation.messages.length, 2);
      expect(updatedConversation.messages.first, initialMessage);
      expect(updatedConversation.messages.last, newMessage);

      // Verify chronological order (older messages first)
      expect(
        updatedConversation.messages.first.timestamp.isBefore(
          updatedConversation.messages.last.timestamp,
        ),
        isTrue,
      );
    });

    test('addMessage should not persist error messages', () {
      // Arrange
      final conversation = ConversationUiState(
        id: 'test-conversation',
        channelName: 'Test Chat',
        channelMembers: 1,
        messages: [],
        selectedProviderId: 'test-provider',
      );

      final normalMessage = Message(
        author: 'User',
        content: 'Normal message',
        timestamp: DateTime(2024, 1, 1, 10, 0),
        isFromUser: true,
        status: MessageStatus.normal,
      );

      final errorMessage = Message.error(
        author: 'AI',
        errorMessage: 'API Error',
        originalContent: 'Failed response',
        errorInfo: 'Network timeout',
      );

      // Act
      final step1 = conversation.addMessage(normalMessage);
      final step2 = step1.addMessage(errorMessage);

      // Assert
      expect(step2.messages.length, 2);
      expect(step2.messages[0].shouldPersist, isTrue);
      expect(step2.messages[1].shouldPersist, isFalse);
      expect(step2.messages[1].isError, isTrue);
      expect(step2.messages[1].errorInfo, 'Network timeout');
    });

    test('addMessage should maintain chronological order', () {
      // Arrange
      final conversation = ConversationUiState(
        id: 'test-conversation',
        channelName: 'Test Chat',
        channelMembers: 1,
        messages: [],
        selectedProviderId: 'test-provider',
      );

      final message1 = Message(
        author: 'User',
        content: 'First message',
        timestamp: DateTime(2024, 1, 1, 10, 0),
        isFromUser: true,
      );

      final message2 = Message(
        author: 'AI',
        content: 'Second message',
        timestamp: DateTime(2024, 1, 1, 10, 1),
        isFromUser: false,
      );

      final message3 = Message(
        author: 'User',
        content: 'Third message',
        timestamp: DateTime(2024, 1, 1, 10, 2),
        isFromUser: true,
      );

      // Act
      final step1 = conversation.addMessage(message1);
      final step2 = step1.addMessage(message2);
      final step3 = step2.addMessage(message3);

      // Assert
      expect(step3.messages.length, 3);
      expect(step3.messages[0], message1);
      expect(step3.messages[1], message2);
      expect(step3.messages[2], message3);

      // Verify all messages are in chronological order
      for (int i = 0; i < step3.messages.length - 1; i++) {
        expect(
          step3.messages[i].timestamp.isBefore(
            step3.messages[i + 1].timestamp,
          ),
          isTrue,
          reason:
              'Message at index $i should be before message at index ${i + 1}',
        );
      }
    });
  });
}
