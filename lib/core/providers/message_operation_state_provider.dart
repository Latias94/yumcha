import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../state/message_operation_state.dart';
import '../services/message_operation_service.dart';

/// Message operation state notifier
///
/// Manages all message operations including editing, deleting, copying, regenerating, etc.
/// Provides a unified interface for message operations similar to Cherry Studio's useMessageOperations.
class MessageOperationStateNotifier
    extends StateNotifier<MessageOperationState> {
  final Ref _ref;
  final _uuid = const Uuid();

  MessageOperationStateNotifier(this._ref)
      : super(const MessageOperationState());

  // === Core Operation Management ===

  /// Start a message operation
  Future<void> startOperation(
    String messageId,
    MessageOperationType type, {
    Map<String, dynamic>? options,
  }) async {
    final operationId = _uuid.v4();
    final startTime = DateTime.now();

    // Add to active operations
    state = state.copyWith(
      activeOperations: {
        ...state.activeOperations,
        messageId: type,
      },
      operationProgress: {
        ...state.operationProgress,
        messageId: 0.0,
      },
      lastOperationTime: startTime,
    );

    try {
      // Execute the operation based on type
      await _executeOperation(messageId, type, options ?? {});

      // Mark operation as complete
      await _completeOperation(messageId, type, operationId, startTime);
    } catch (error) {
      // Handle operation error
      await _handleOperationError(messageId, type, error.toString());
    }
  }

  /// Update operation progress
  void updateOperationProgress(String messageId, double progress) {
    state = state.copyWith(
      operationProgress: {
        ...state.operationProgress,
        messageId: progress.clamp(0.0, 1.0),
      },
    );
  }

  /// Complete an operation
  Future<void> _completeOperation(
    String messageId,
    MessageOperationType type,
    String operationId,
    DateTime startTime,
  ) async {
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inMilliseconds;

    // Remove from active operations
    final newActiveOperations =
        Map<String, MessageOperationType>.from(state.activeOperations);
    final newOperationProgress =
        Map<String, double>.from(state.operationProgress);
    final newOperationErrors = Map<String, String>.from(state.operationErrors);

    newActiveOperations.remove(messageId);
    newOperationProgress.remove(messageId);
    newOperationErrors.remove(messageId);

    // Add to operation history
    final historyEntry = OperationHistoryEntry(
      id: operationId,
      type: type,
      messageId: messageId,
      timestamp: startTime,
      durationMs: duration,
      wasSuccessful: true,
    );

    final newHistory = List<OperationHistoryEntry>.from(state.operationHistory);
    newHistory.add(historyEntry);

    // Keep only the last maxHistoryEntries
    if (newHistory.length > state.maxHistoryEntries) {
      newHistory.removeRange(0, newHistory.length - state.maxHistoryEntries);
    }

    // Update performance metrics
    final newTotalOperations = state.totalOperations + 1;
    final newAverageDuration =
        (state.averageOperationDuration * state.totalOperations + duration) /
            newTotalOperations;

    state = state.copyWith(
      activeOperations: newActiveOperations,
      operationProgress: newOperationProgress,
      operationErrors: newOperationErrors,
      operationHistory: newHistory,
      totalOperations: newTotalOperations,
      averageOperationDuration: newAverageDuration,
      lastOperationTime: endTime,
    );
  }

  /// Handle operation error
  Future<void> _handleOperationError(
    String messageId,
    MessageOperationType type,
    String error,
  ) async {
    // Remove from active operations and add error
    final newActiveOperations =
        Map<String, MessageOperationType>.from(state.activeOperations);
    final newOperationProgress =
        Map<String, double>.from(state.operationProgress);

    newActiveOperations.remove(messageId);
    newOperationProgress.remove(messageId);

    state = state.copyWith(
      activeOperations: newActiveOperations,
      operationProgress: newOperationProgress,
      operationErrors: {
        ...state.operationErrors,
        messageId: error,
      },
    );
  }

  /// Execute operation based on type
  Future<void> _executeOperation(
    String messageId,
    MessageOperationType type,
    Map<String, dynamic> options,
  ) async {
    final service = _ref.read(messageOperationServiceProvider);

    switch (type) {
      case MessageOperationType.editing:
        await service.editMessage(messageId, options);
        break;
      case MessageOperationType.deleting:
        await service.deleteMessage(messageId, options);
        break;
      case MessageOperationType.copying:
        await service.copyMessage(messageId, options);
        break;
      case MessageOperationType.regenerating:
        await service.regenerateMessage(messageId, options);
        break;
      case MessageOperationType.translating:
        await service.translateMessage(messageId, options);
        break;
      case MessageOperationType.branching:
        await service.createMessageBranch(messageId, options);
        break;
      case MessageOperationType.exporting:
        await service.exportMessage(messageId, options);
        break;
      case MessageOperationType.resending:
        await service.resendMessage(messageId, options);
        break;
      case MessageOperationType.pausing:
        await service.pauseMessage(messageId, options);
        break;
      case MessageOperationType.resuming:
        await service.resumeMessage(messageId, options);
        break;
    }
  }

  // === Specific Operation Methods ===

  /// Edit a message
  Future<void> editMessage(String messageId, String newContent) async {
    await startOperation(messageId, MessageOperationType.editing, {
      'newContent': newContent,
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await startOperation(messageId, MessageOperationType.deleting);
  }

  /// Copy a message
  Future<void> copyMessage(String messageId) async {
    await startOperation(messageId, MessageOperationType.copying);
  }

  /// Regenerate a message
  Future<void> regenerateMessage(
    String messageId, {
    String? modelId,
    String? assistantId,
    Map<String, dynamic>? options,
  }) async {
    await startOperation(messageId, MessageOperationType.regenerating, {
      'modelId': modelId,
      'assistantId': assistantId,
      ...?options,
    });
  }

  /// Translate a message
  Future<void> translateMessage(
    String messageId,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    await startOperation(messageId, MessageOperationType.translating, {
      'targetLanguage': targetLanguage,
      'sourceLanguage': sourceLanguage,
    });
  }

  /// Create a message branch
  Future<void> createMessageBranch(String messageId) async {
    await startOperation(messageId, MessageOperationType.branching);
  }

  /// Export a message
  Future<void> exportMessage(String messageId, String format) async {
    await startOperation(messageId, MessageOperationType.exporting, {
      'format': format,
    });
  }

  /// Resend a message
  Future<void> resendMessage(String messageId) async {
    await startOperation(messageId, MessageOperationType.resending);
  }

  // === Batch Operations ===

  /// Toggle batch mode
  void toggleBatchMode() {
    state = state.copyWith(
      isBatchMode: !state.isBatchMode,
      batchSelectedMessages: {},
      currentBatchOperation: null,
      batchProgress: 0.0,
    );
  }

  /// Toggle message selection in batch mode
  void toggleBatchSelection(String messageId) {
    if (!state.isBatchMode) return;

    final newSelection = Set<String>.from(state.batchSelectedMessages);
    if (newSelection.contains(messageId)) {
      newSelection.remove(messageId);
    } else {
      newSelection.add(messageId);
    }

    state = state.copyWith(batchSelectedMessages: newSelection);
  }

  /// Execute batch operation
  Future<void> executeBatchOperation(BatchOperationType operationType) async {
    if (!state.isBatchMode || state.batchSelectedMessages.isEmpty) return;

    state = state.copyWith(
      currentBatchOperation: operationType,
      batchProgress: 0.0,
    );

    final messageIds = state.batchSelectedMessages.toList();
    final service = _ref.read(messageOperationServiceProvider);

    try {
      for (int i = 0; i < messageIds.length; i++) {
        final messageId = messageIds[i];
        final progress = (i + 1) / messageIds.length;

        // Update batch progress
        state = state.copyWith(batchProgress: progress);

        // Execute operation based on type
        switch (operationType) {
          case BatchOperationType.delete:
            await service.deleteMessage(messageId, {});
            break;
          case BatchOperationType.copy:
            await service.copyMessage(messageId, {});
            break;
          case BatchOperationType.export:
            await service.exportMessage(messageId, {});
            break;
          case BatchOperationType.translate:
            await service.translateMessage(messageId, {});
            break;
          case BatchOperationType.mark:
            // TODO: Implement mark functionality
            break;
        }
      }

      // Clear batch selection after successful operation
      state = state.copyWith(
        batchSelectedMessages: {},
        currentBatchOperation: null,
        batchProgress: 0.0,
      );
    } catch (error) {
      // Handle batch operation error
      state = state.copyWith(
        currentBatchOperation: null,
        batchProgress: 0.0,
      );
      rethrow;
    }
  }

  // === Utility Methods ===

  /// Clear operation error for a message
  void clearOperationError(String messageId) {
    final newErrors = Map<String, String>.from(state.operationErrors);
    newErrors.remove(messageId);
    state = state.copyWith(operationErrors: newErrors);
  }

  /// Clear all operation errors
  void clearAllOperationErrors() {
    state = state.copyWith(operationErrors: {});
  }

  /// Cancel an active operation
  Future<void> cancelOperation(String messageId) async {
    if (!state.activeOperations.containsKey(messageId)) return;

    final service = _ref.read(messageOperationServiceProvider);
    await service.cancelOperation(messageId);

    // Remove from active operations
    final newActiveOperations =
        Map<String, MessageOperationType>.from(state.activeOperations);
    final newOperationProgress =
        Map<String, double>.from(state.operationProgress);

    newActiveOperations.remove(messageId);
    newOperationProgress.remove(messageId);

    state = state.copyWith(
      activeOperations: newActiveOperations,
      operationProgress: newOperationProgress,
    );
  }
}

/// Message operation state provider
final messageOperationStateProvider =
    StateNotifierProvider<MessageOperationStateNotifier, MessageOperationState>(
  (ref) => MessageOperationStateNotifier(ref),
);

// === Convenience Providers ===

/// Whether any operations are currently active
final hasActiveOperationsProvider = Provider<bool>((ref) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.hasActiveOperations));
});

/// Active operations count
final activeOperationsCountProvider = Provider<int>((ref) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.activeOperationCount));
});

/// Whether batch mode is active
final isBatchModeProvider = Provider<bool>((ref) {
  return ref.watch(
      messageOperationStateProvider.select((state) => state.isBatchMode));
});

/// Batch selection count
final batchSelectionCountProvider = Provider<int>((ref) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.batchSelectionCount));
});

/// Whether a specific message is being processed
final messageBeingProcessedProvider =
    Provider.family<bool, String>((ref, messageId) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.isMessageBeingProcessed(messageId)));
});

/// Operation type for a specific message
final messageOperationTypeProvider =
    Provider.family<MessageOperationType?, String>((ref, messageId) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.getOperationForMessage(messageId)));
});

/// Operation progress for a specific message
final messageOperationProgressProvider =
    Provider.family<double, String>((ref, messageId) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.getProgressForMessage(messageId)));
});

/// Operation error for a specific message
final messageOperationErrorProvider =
    Provider.family<String?, String>((ref, messageId) {
  return ref.watch(messageOperationStateProvider
      .select((state) => state.getErrorForMessage(messageId)));
});
