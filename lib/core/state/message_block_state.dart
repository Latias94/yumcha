import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/chat/domain/entities/message_block.dart';
import '../../features/chat/domain/entities/message_block_type.dart';

part 'message_block_state.freezed.dart';

/// Message block loading state
enum MessageBlockLoadingState {
  /// No operations in progress
  idle,

  /// Loading blocks
  loading,

  /// Load operation succeeded
  succeeded,

  /// Load operation failed
  failed,
}

/// Message block status for individual blocks
///
/// Extended from current MessageBlockStatus to match Cherry Studio's capabilities
enum MessageBlockStatus {
  /// Block is being processed
  processing,

  /// Block is streaming content
  streaming,

  /// Block completed successfully
  success,

  /// Block encountered an error
  error,

  /// Block is pending (waiting to be processed)
  pending,

  /// Block was cancelled
  cancelled,
}

/// Enhanced message block types to match Cherry Studio
///
/// This extends the current MessageBlockType to include all types
/// supported by Cherry Studio for complete feature parity
enum EnhancedMessageBlockType {
  /// Main text content - primary message content
  mainText,

  /// Thinking process - AI reasoning steps
  thinking,

  /// Image content - images, charts, diagrams
  image,

  /// Code content - code blocks with syntax highlighting
  code,

  /// Tool call - function/tool invocation and results
  tool,

  /// File content - file attachments and references
  file,

  /// Error content - error messages and diagnostics
  error,

  /// Citation content - references and sources
  citation,

  /// Translation content - translated text
  translation,

  /// Unknown/placeholder - for blocks being processed
  unknown,
}

/// Individual message block with enhanced metadata
///
/// This represents a single block within a message, similar to Cherry Studio's
/// MessageBlock but adapted for Riverpod state management
@freezed
class EnhancedMessageBlock with _$EnhancedMessageBlock {
  const factory EnhancedMessageBlock({
    /// Unique block ID
    required String id,

    /// Message this block belongs to
    required String messageId,

    /// Block type
    required EnhancedMessageBlockType type,

    /// Block content
    @Default('') String content,

    /// Block status
    @Default(MessageBlockStatus.pending) MessageBlockStatus status,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    @Default(null) DateTime? updatedAt,

    /// Block metadata (tool responses, citations, etc.)
    @Default({}) Map<String, dynamic> metadata,

    /// Block order within the message
    @Default(0) int order,

    /// Whether this block should be persisted
    @Default(true) bool shouldPersist,

    /// Citation references (for blocks that reference other blocks)
    @Default([]) List<String> citationReferences,

    /// Tool call information (for tool blocks)
    @Default(null) ToolCallInfo? toolCallInfo,

    /// Thinking duration in milliseconds (for thinking blocks)
    @Default(null) int? thinkingMilliseconds,

    /// Error details (for error blocks)
    @Default(null) BlockErrorInfo? errorInfo,
  }) = _EnhancedMessageBlock;

  const EnhancedMessageBlock._();

  // === Computed Properties ===

  /// Whether this block is currently being processed
  bool get isProcessing =>
      status == MessageBlockStatus.processing ||
      status == MessageBlockStatus.streaming;

  /// Whether this block has completed successfully
  bool get isComplete => status == MessageBlockStatus.success;

  /// Whether this block has an error
  bool get hasError => status == MessageBlockStatus.error;

  /// Whether this block has content
  bool get hasContent => content.isNotEmpty;

  /// Whether this block is a tool call
  bool get isToolCall => type == EnhancedMessageBlockType.tool;

  /// Whether this block is thinking content
  bool get isThinking => type == EnhancedMessageBlockType.thinking;

  /// Whether this block is main text
  bool get isMainText => type == EnhancedMessageBlockType.mainText;

  /// Get display title for this block type
  String get typeDisplayName {
    switch (type) {
      case EnhancedMessageBlockType.mainText:
        return 'Text';
      case EnhancedMessageBlockType.thinking:
        return 'Thinking';
      case EnhancedMessageBlockType.image:
        return 'Image';
      case EnhancedMessageBlockType.code:
        return 'Code';
      case EnhancedMessageBlockType.tool:
        return 'Tool Call';
      case EnhancedMessageBlockType.file:
        return 'File';
      case EnhancedMessageBlockType.error:
        return 'Error';
      case EnhancedMessageBlockType.citation:
        return 'Citation';
      case EnhancedMessageBlockType.translation:
        return 'Translation';
      case EnhancedMessageBlockType.unknown:
        return 'Processing...';
    }
  }
}

/// Tool call information for tool blocks
@freezed
class ToolCallInfo with _$ToolCallInfo {
  const factory ToolCallInfo({
    /// Tool call ID
    required String callId,

    /// Tool name
    required String toolName,

    /// Tool arguments
    @Default({}) Map<String, dynamic> arguments,

    /// Tool response
    @Default(null) String? response,

    /// Tool call status
    @Default(ToolCallStatus.pending) ToolCallStatus status,

    /// Error message if tool call failed
    @Default(null) String? errorMessage,

    /// Tool execution duration in milliseconds
    @Default(null) int? executionTimeMs,
  }) = _ToolCallInfo;
}

/// Tool call status
enum ToolCallStatus {
  /// Tool call is pending
  pending,

  /// Tool call is being executed
  executing,

  /// Tool call completed successfully
  completed,

  /// Tool call failed
  failed,

  /// Tool call was cancelled
  cancelled,
}

/// Block error information
@freezed
class BlockErrorInfo with _$BlockErrorInfo {
  const factory BlockErrorInfo({
    /// Error code
    required String code,

    /// Error message
    required String message,

    /// Error details
    @Default({}) Map<String, dynamic> details,

    /// Whether this error is recoverable
    @Default(false) bool isRecoverable,

    /// Suggested recovery action
    @Default(null) String? recoveryAction,
  }) = _BlockErrorInfo;
}

/// Core message block state management
///
/// Manages all message blocks using EntityAdapter pattern similar to Cherry Studio.
/// This provides O(1) lookups and efficient updates for large numbers of blocks.
@freezed
class MessageBlockState with _$MessageBlockState {
  const factory MessageBlockState({
    // === Block Storage (EntityAdapter pattern) ===
    /// All blocks indexed by ID (blockId -> EnhancedMessageBlock)
    @Default({}) Map<String, EnhancedMessageBlock> blocks,

    /// Blocks grouped by message (messageId -> List<blockId>)
    /// Similar to Cherry Studio's message-to-blocks relationship
    @Default({}) Map<String, List<String>> blocksByMessage,

    /// Blocks grouped by type for efficient filtering
    @Default({}) Map<EnhancedMessageBlockType, List<String>> blocksByType,

    // === Loading State ===
    /// Overall loading state
    @Default(MessageBlockLoadingState.idle)
    MessageBlockLoadingState loadingState,

    /// Error message if loading failed
    @Default(null) String? error,

    // === Block Status Tracking ===
    /// Status of individual blocks (blockId -> MessageBlockStatus)
    @Default({}) Map<String, MessageBlockStatus> blockStatuses,

    /// Blocks currently being processed
    @Default({}) Set<String> processingBlocks,

    /// Blocks with errors
    @Default({}) Set<String> errorBlocks,

    // === Performance Metrics ===
    /// Total number of blocks
    @Default(0) int totalBlocks,

    /// Last update timestamp
    @Default(null) DateTime? lastUpdateTime,

    // === Tool Call Tracking ===
    /// Active tool calls (toolCallId -> blockId)
    /// Similar to Cherry Studio's toolCallIdToBlockIdMap
    @Default({}) Map<String, String> toolCallToBlockMap,

    /// Tool call results cache
    @Default({}) Map<String, dynamic> toolCallResults,
  }) = _MessageBlockState;

  const MessageBlockState._();

  // === Computed Properties ===

  /// Get all blocks as a list
  List<EnhancedMessageBlock> get allBlocks => blocks.values.toList();

  /// Get blocks for a specific message, ordered by their order field
  List<EnhancedMessageBlock> getBlocksForMessage(String messageId) {
    final blockIds = blocksByMessage[messageId] ?? [];
    final messageBlocks = blockIds
        .map((id) => blocks[id])
        .whereType<EnhancedMessageBlock>()
        .toList();

    // Sort by order field
    messageBlocks.sort((a, b) => a.order.compareTo(b.order));
    return messageBlocks;
  }

  /// Get blocks by type
  List<EnhancedMessageBlock> getBlocksByType(EnhancedMessageBlockType type) {
    final blockIds = blocksByType[type] ?? [];
    return blockIds
        .map((id) => blocks[id])
        .whereType<EnhancedMessageBlock>()
        .toList();
  }

  /// Get block by ID
  EnhancedMessageBlock? getBlock(String blockId) => blocks[blockId];

  /// Check if block exists
  bool hasBlock(String blockId) => blocks.containsKey(blockId);

  /// Get processing blocks
  List<EnhancedMessageBlock> get processingBlocksList {
    return processingBlocks
        .map((id) => blocks[id])
        .whereType<EnhancedMessageBlock>()
        .toList();
  }

  /// Get error blocks
  List<EnhancedMessageBlock> get errorBlocksList {
    return errorBlocks
        .map((id) => blocks[id])
        .whereType<EnhancedMessageBlock>()
        .toList();
  }

  /// Get tool call blocks
  List<EnhancedMessageBlock> get toolCallBlocks {
    return getBlocksByType(EnhancedMessageBlockType.tool);
  }

  /// Check if there are any processing blocks
  bool get hasProcessingBlocks => processingBlocks.isNotEmpty;

  /// Check if there are any error blocks
  bool get hasErrorBlocks => errorBlocks.isNotEmpty;

  /// Get block by tool call ID
  EnhancedMessageBlock? getBlockByToolCallId(String toolCallId) {
    final blockId = toolCallToBlockMap[toolCallId];
    return blockId != null ? blocks[blockId] : null;
  }
}
