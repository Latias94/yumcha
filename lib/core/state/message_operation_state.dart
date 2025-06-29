import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_operation_state.freezed.dart';

/// Message operation state management
///
/// Manages all message operations like editing, deleting, copying, regenerating, etc.
/// Inspired by Cherry Studio's useMessageOperations hook but adapted for Riverpod state management.
@freezed
class MessageOperationState with _$MessageOperationState {
  const factory MessageOperationState({
    // === Active Operations ===
    /// Map of message ID to operation type currently being performed
    @Default({}) Map<String, MessageOperationType> activeOperations,

    /// Map of message ID to operation progress (0.0 to 1.0)
    @Default({}) Map<String, double> operationProgress,

    /// Map of message ID to operation error messages
    @Default({}) Map<String, String> operationErrors,

    // === Branch Management ===
    /// Map of message ID to list of branch IDs
    @Default({}) Map<String, List<String>> messageBranches,

    /// Currently active branch ID
    @Default(null) String? activeBranchId,

    /// Messages that have branches
    @Default({}) Set<String> messagesWithBranches,

    // === Pause/Resume State ===
    /// Messages that are currently paused
    @Default({}) Set<String> pausedMessageIds,

    /// Messages that can be resumed
    @Default({}) Set<String> resumableMessageIds,

    // === Copy/Export State ===
    /// Messages currently being copied
    @Default({}) Set<String> copyingMessageIds,

    /// Messages currently being exported
    @Default({}) Set<String> exportingMessageIds,

    /// Last copied content for clipboard management
    @Default(null) String? lastCopiedContent,

    // === Translation State ===
    /// Messages currently being translated
    @Default({}) Map<String, TranslationOperation> translatingMessages,

    /// Available translation languages
    @Default([]) List<String> availableLanguages,

    // === Regeneration State ===
    /// Messages currently being regenerated
    @Default({}) Map<String, RegenerationOperation> regeneratingMessages,

    /// Regeneration options/settings
    @Default(RegenerationOptions()) RegenerationOptions regenerationOptions,

    // === Batch Operations ===
    /// Whether batch operation mode is active
    @Default(false) bool isBatchMode,

    /// Selected messages for batch operations
    @Default({}) Set<String> batchSelectedMessages,

    /// Current batch operation type
    @Default(null) BatchOperationType? currentBatchOperation,

    /// Batch operation progress
    @Default(0.0) double batchProgress,

    // === Operation History ===
    /// Recent operations for undo functionality
    @Default([]) List<OperationHistoryEntry> operationHistory,

    /// Maximum history entries to keep
    @Default(50) int maxHistoryEntries,

    // === Performance Metrics ===
    /// Total operations performed
    @Default(0) int totalOperations,

    /// Average operation duration in milliseconds
    @Default(0.0) double averageOperationDuration,

    /// Last operation timestamp
    @Default(null) DateTime? lastOperationTime,
  }) = _MessageOperationState;

  const MessageOperationState._();

  // === Computed Properties ===

  /// Whether any operations are currently active
  bool get hasActiveOperations => activeOperations.isNotEmpty;

  /// Number of active operations
  int get activeOperationCount => activeOperations.length;

  /// Whether a specific message has an active operation
  bool isMessageBeingProcessed(String messageId) =>
      activeOperations.containsKey(messageId);

  /// Get operation type for a specific message
  MessageOperationType? getOperationForMessage(String messageId) =>
      activeOperations[messageId];

  /// Get operation progress for a specific message
  double getProgressForMessage(String messageId) =>
      operationProgress[messageId] ?? 0.0;

  /// Get operation error for a specific message
  String? getErrorForMessage(String messageId) => operationErrors[messageId];

  /// Whether a message has branches
  bool messageHasBranches(String messageId) =>
      messagesWithBranches.contains(messageId);

  /// Get branches for a specific message
  List<String> getBranchesForMessage(String messageId) =>
      messageBranches[messageId] ?? [];

  /// Whether a message is paused
  bool isMessagePaused(String messageId) =>
      pausedMessageIds.contains(messageId);

  /// Whether a message can be resumed
  bool canResumeMessage(String messageId) =>
      resumableMessageIds.contains(messageId);

  /// Whether batch mode is active with selections
  bool get hasBatchSelections =>
      isBatchMode && batchSelectedMessages.isNotEmpty;

  /// Number of selected messages in batch mode
  int get batchSelectionCount => batchSelectedMessages.length;

  /// Whether a message is selected in batch mode
  bool isMessageSelectedInBatch(String messageId) =>
      batchSelectedMessages.contains(messageId);

  /// Whether operation history is available for undo
  bool get canUndo => operationHistory.isNotEmpty;

  /// Get the last operation for undo
  OperationHistoryEntry? get lastOperation =>
      operationHistory.isNotEmpty ? operationHistory.last : null;
}

/// Types of message operations
enum MessageOperationType {
  /// Editing message content
  editing,

  /// Deleting message
  deleting,

  /// Resending/retrying message
  resending,

  /// Regenerating AI response
  regenerating,

  /// Translating message content
  translating,

  /// Creating message branch
  branching,

  /// Copying message content
  copying,

  /// Exporting message content
  exporting,

  /// Pausing message generation
  pausing,

  /// Resuming message generation
  resuming,
}

/// Types of batch operations
enum BatchOperationType {
  /// Batch delete messages
  delete,

  /// Batch copy messages
  copy,

  /// Batch export messages
  export,

  /// Batch translate messages
  translate,

  /// Batch mark messages
  mark,
}

/// Translation operation details
@freezed
class TranslationOperation with _$TranslationOperation {
  const factory TranslationOperation({
    /// Source language
    required String sourceLanguage,

    /// Target language
    required String targetLanguage,

    /// Translation progress (0.0 to 1.0)
    @Default(0.0) double progress,

    /// Translation start time
    required DateTime startTime,

    /// Translation options
    @Default({}) Map<String, dynamic> options,
  }) = _TranslationOperation;
}

/// Regeneration operation details
@freezed
class RegenerationOperation with _$RegenerationOperation {
  const factory RegenerationOperation({
    /// Regeneration start time
    required DateTime startTime,

    /// Regeneration progress (0.0 to 1.0)
    @Default(0.0) double progress,

    /// Model used for regeneration
    @Default(null) String? modelId,

    /// Assistant used for regeneration
    @Default(null) String? assistantId,

    /// Regeneration options
    @Default({}) Map<String, dynamic> options,
  }) = _RegenerationOperation;
}

/// Regeneration options/settings
@freezed
class RegenerationOptions with _$RegenerationOptions {
  const factory RegenerationOptions({
    /// Whether to use streaming for regeneration
    @Default(true) bool useStreaming,

    /// Whether to preserve message history
    @Default(true) bool preserveHistory,

    /// Maximum regeneration attempts
    @Default(3) int maxAttempts,

    /// Timeout in seconds
    @Default(60) int timeoutSeconds,

    /// Custom regeneration prompt
    @Default(null) String? customPrompt,
  }) = _RegenerationOptions;
}

/// Operation history entry for undo functionality
@freezed
class OperationHistoryEntry with _$OperationHistoryEntry {
  const factory OperationHistoryEntry({
    /// Operation ID
    required String id,

    /// Operation type
    required MessageOperationType type,

    /// Message ID that was operated on
    required String messageId,

    /// Operation timestamp
    required DateTime timestamp,

    /// Operation duration in milliseconds
    @Default(0) int durationMs,

    /// Previous state for undo
    @Default({}) Map<String, dynamic> previousState,

    /// Operation result
    @Default({}) Map<String, dynamic> result,

    /// Whether operation was successful
    @Default(true) bool wasSuccessful,

    /// Error message if operation failed
    @Default(null) String? errorMessage,
  }) = _OperationHistoryEntry;
}
