import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_state_provider.dart';
import '../providers/streaming_state_provider.dart';
import '../../shared/infrastructure/services/notification_service.dart';

/// Message operation service
///
/// Handles the actual execution of message operations like editing, deleting, copying, etc.
/// This service is called by the MessageOperationStateNotifier to perform the actual work.
class MessageOperationService {
  final Ref _ref;

  MessageOperationService(this._ref);

  // === Core Operations ===

  /// Edit a message
  Future<void> editMessage(
      String messageId, Map<String, dynamic> options) async {
    final newContent = options['newContent'] as String?;
    if (newContent == null) {
      throw ArgumentError('newContent is required for editing');
    }

    try {
      // Get the current message
      final chatState = _ref.read(chatStateProvider);
      final message = chatState.messageMap[messageId];

      if (message == null) {
        throw StateError('Message not found: $messageId');
      }

      // Update the message content through blocks
      final updatedMessage = message.copyWith(
        updatedAt: DateTime.now(),
      );

      // Update the chat state
      _ref
          .read(chatStateProvider.notifier)
          .updateMessage(messageId, (message) => updatedMessage);

      // Show success notification
      NotificationService().showSuccess('Message updated successfully');
    } catch (error) {
      NotificationService().showError('Failed to edit message: $error');
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // Remove the message from chat state
      _ref.read(chatStateProvider.notifier).removeMessage(messageId);

      // Show success notification
      NotificationService().showSuccess('Message deleted successfully');
    } catch (error) {
      NotificationService().showError('Failed to delete message: $error');
      rethrow;
    }
  }

  /// Copy a message to clipboard
  Future<void> copyMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // Get the message content
      final chatState = _ref.read(chatStateProvider);
      final message = chatState.messageMap[messageId];

      if (message == null) {
        throw StateError('Message not found: $messageId');
      }

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: message.content));

      // Show success notification
      NotificationService().showSuccess('Message copied to clipboard');
    } catch (error) {
      NotificationService().showError('Failed to copy message: $error');
      rethrow;
    }
  }

  /// Regenerate a message (for AI responses)
  Future<void> regenerateMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // Get the message
      final chatState = _ref.read(chatStateProvider);
      final message = chatState.messageMap[messageId];

      if (message == null) {
        throw StateError('Message not found: $messageId');
      }

      if (message.isFromUser) {
        throw StateError('Cannot regenerate user messages');
      }

      // Find the previous user message to regenerate from
      final messages = chatState.messages;
      final messageIndex = messages.indexWhere((m) => m.id == messageId);

      if (messageIndex <= 0) {
        throw StateError('No previous user message found');
      }

      final previousUserMessage = messages[messageIndex - 1];
      if (!previousUserMessage.isFromUser) {
        throw StateError('Previous message is not from user');
      }

      // Delete the current AI message
      _ref.read(chatStateProvider.notifier).removeMessage(messageId);

      // TODO: Implement message regeneration through proper service
      // For now, just remove the message
      NotificationService()
          .showInfo('Message regeneration not yet implemented');

      // Show success notification
      NotificationService().showSuccess('Regenerating message...');
    } catch (error) {
      NotificationService().showError('Failed to regenerate message: $error');
      rethrow;
    }
  }

  /// Translate a message
  Future<void> translateMessage(
      String messageId, Map<String, dynamic> options) async {
    final targetLanguage = options['targetLanguage'] as String?;
    if (targetLanguage == null) {
      throw ArgumentError('targetLanguage is required for translation');
    }

    try {
      // Get the message
      final chatState = _ref.read(chatStateProvider);
      final message = chatState.messageMap[messageId];

      if (message == null) {
        throw StateError('Message not found: $messageId');
      }

      // TODO: Implement actual translation logic
      // For now, just show a placeholder
      NotificationService().showInfo('Translation feature coming soon');

      // Simulate translation delay
      await Future.delayed(const Duration(seconds: 2));
    } catch (error) {
      NotificationService().showError('Failed to translate message: $error');
      rethrow;
    }
  }

  /// Create a message branch
  Future<void> createMessageBranch(
      String messageId, Map<String, dynamic> options) async {
    try {
      // TODO: Implement message branching logic
      // For now, just show a placeholder
      NotificationService().showInfo('Message branching feature coming soon');

      // Simulate branch creation delay
      await Future.delayed(const Duration(seconds: 1));
    } catch (error) {
      NotificationService()
          .showError('Failed to create message branch: $error');
      rethrow;
    }
  }

  /// Export a message
  Future<void> exportMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // Get the message
      final chatState = _ref.read(chatStateProvider);
      final message = chatState.messageMap[messageId];

      if (message == null) {
        throw StateError('Message not found: $messageId');
      }

      // TODO: Implement actual export logic
      // For now, just copy to clipboard as a simple export
      await Clipboard.setData(ClipboardData(text: message.content));

      NotificationService().showSuccess('Message exported to clipboard');
    } catch (error) {
      NotificationService().showError('Failed to export message: $error');
      rethrow;
    }
  }

  /// Resend a message
  Future<void> resendMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // Get the message
      final chatState = _ref.read(chatStateProvider);
      final message = chatState.messageMap[messageId];

      if (message == null) {
        throw StateError('Message not found: $messageId');
      }

      if (!message.isFromUser) {
        throw StateError('Can only resend user messages');
      }

      // TODO: Implement message resending through proper service
      NotificationService().showInfo('Message resending not yet implemented');

      NotificationService().showSuccess('Message resent');
    } catch (error) {
      NotificationService().showError('Failed to resend message: $error');
      rethrow;
    }
  }

  /// Pause a message (for streaming messages)
  Future<void> pauseMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // Check if message is currently streaming
      final streamingState = _ref.read(streamingStateProvider);
      final streamingMessage = streamingState.activeStreams[messageId];

      if (streamingMessage == null) {
        throw StateError('Message is not currently streaming: $messageId');
      }

      // TODO: Implement stream pausing
      NotificationService().showInfo('Stream pausing not yet implemented');

      NotificationService().showSuccess('Message paused');
    } catch (error) {
      NotificationService().showError('Failed to pause message: $error');
      rethrow;
    }
  }

  /// Resume a message (for paused streaming messages)
  Future<void> resumeMessage(
      String messageId, Map<String, dynamic> options) async {
    try {
      // TODO: Implement stream resuming
      NotificationService().showInfo('Stream resuming not yet implemented');

      NotificationService().showSuccess('Message resumed');
    } catch (error) {
      NotificationService().showError('Failed to resume message: $error');
      rethrow;
    }
  }

  /// Cancel an operation
  Future<void> cancelOperation(String messageId) async {
    try {
      // If it's a streaming message, stop the stream
      final streamingState = _ref.read(streamingStateProvider);
      if (streamingState.activeStreams.containsKey(messageId)) {
        _ref
            .read(streamingStateProvider.notifier)
            .errorStream(messageId, 'Operation cancelled by user');
      }

      NotificationService().showInfo('Operation cancelled');
    } catch (error) {
      NotificationService().showError('Failed to cancel operation: $error');
      rethrow;
    }
  }

  // === Batch Operations ===

  /// Execute batch delete
  Future<void> batchDelete(List<String> messageIds) async {
    for (final messageId in messageIds) {
      await deleteMessage(messageId, {});
    }
  }

  /// Execute batch copy
  Future<void> batchCopy(List<String> messageIds) async {
    final chatState = _ref.read(chatStateProvider);
    final contents = <String>[];

    for (final messageId in messageIds) {
      final message = chatState.messageMap[messageId];
      if (message != null) {
        contents.add(message.content);
      }
    }

    if (contents.isNotEmpty) {
      final combinedContent = contents.join('\n\n---\n\n');
      await Clipboard.setData(ClipboardData(text: combinedContent));
      NotificationService()
          .showSuccess('${messageIds.length} messages copied to clipboard');
    }
  }

  /// Execute batch export
  Future<void> batchExport(List<String> messageIds) async {
    // For now, use batch copy as simple export
    await batchCopy(messageIds);
  }
}

/// Message operation service provider
final messageOperationServiceProvider =
    Provider<MessageOperationService>((ref) {
  return MessageOperationService(ref);
});
