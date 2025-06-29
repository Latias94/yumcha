import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/message_block_state.dart';
import '../services/deduplication_manager.dart';

/// Message block state notifier for managing message blocks
///
/// This notifier manages all message blocks using EntityAdapter pattern
/// similar to Cherry Studio's block management.
class MessageBlockStateNotifier extends StateNotifier<MessageBlockState> {
  final Ref _ref;
  final DeduplicationManager _deduplicationManager;

  MessageBlockStateNotifier(this._ref)
      : _deduplicationManager = DeduplicationManager.instance,
        super(const MessageBlockState());

  // === Block Management ===

  /// Add a new message block
  void addBlock(EnhancedMessageBlock block) {
    // Check for duplicate blocks
    if (state.hasBlock(block.id)) {
      return; // Block already exists
    }

    // Add block using EntityAdapter pattern
    final newBlocks = Map<String, EnhancedMessageBlock>.from(state.blocks);
    newBlocks[block.id] = block;

    // Update blocks by message
    final newBlocksByMessage =
        Map<String, List<String>>.from(state.blocksByMessage);
    final messageBlocks =
        List<String>.from(newBlocksByMessage[block.messageId] ?? []);
    if (!messageBlocks.contains(block.id)) {
      messageBlocks.add(block.id);
      messageBlocks.sort((a, b) {
        final blockA = newBlocks[a];
        final blockB = newBlocks[b];
        if (blockA == null || blockB == null) return 0;
        return blockA.order.compareTo(blockB.order);
      });
      newBlocksByMessage[block.messageId] = messageBlocks;
    }

    // Update blocks by type
    final newBlocksByType =
        Map<EnhancedMessageBlockType, List<String>>.from(state.blocksByType);
    final typeBlocks = List<String>.from(newBlocksByType[block.type] ?? []);
    if (!typeBlocks.contains(block.id)) {
      typeBlocks.add(block.id);
      newBlocksByType[block.type] = typeBlocks;
    }

    // Update block statuses
    final newBlockStatuses =
        Map<String, MessageBlockStatus>.from(state.blockStatuses);
    newBlockStatuses[block.id] = block.status;

    // Update processing/error sets
    final newProcessingBlocks = Set<String>.from(state.processingBlocks);
    final newErrorBlocks = Set<String>.from(state.errorBlocks);

    if (block.isProcessing) {
      newProcessingBlocks.add(block.id);
    }
    if (block.hasError) {
      newErrorBlocks.add(block.id);
    }

    // Update tool call mapping if it's a tool block
    final newToolCallToBlockMap =
        Map<String, String>.from(state.toolCallToBlockMap);
    if (block.isToolCall && block.toolCallInfo != null) {
      newToolCallToBlockMap[block.toolCallInfo!.callId] = block.id;
    }

    state = state.copyWith(
      blocks: newBlocks,
      blocksByMessage: newBlocksByMessage,
      blocksByType: newBlocksByType,
      blockStatuses: newBlockStatuses,
      processingBlocks: newProcessingBlocks,
      errorBlocks: newErrorBlocks,
      toolCallToBlockMap: newToolCallToBlockMap,
      totalBlocks: newBlocks.length,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update an existing message block
  void updateBlock(String blockId,
      EnhancedMessageBlock Function(EnhancedMessageBlock) updater) {
    final existingBlock = state.blocks[blockId];
    if (existingBlock == null) {
      return; // Block doesn't exist
    }

    final updatedBlock = updater(existingBlock);

    // Update blocks map
    final newBlocks = Map<String, EnhancedMessageBlock>.from(state.blocks);
    newBlocks[blockId] = updatedBlock;

    // Update block statuses
    final newBlockStatuses =
        Map<String, MessageBlockStatus>.from(state.blockStatuses);
    newBlockStatuses[blockId] = updatedBlock.status;

    // Update processing/error sets
    final newProcessingBlocks = Set<String>.from(state.processingBlocks);
    final newErrorBlocks = Set<String>.from(state.errorBlocks);

    if (updatedBlock.isProcessing) {
      newProcessingBlocks.add(blockId);
    } else {
      newProcessingBlocks.remove(blockId);
    }

    if (updatedBlock.hasError) {
      newErrorBlocks.add(blockId);
    } else {
      newErrorBlocks.remove(blockId);
    }

    state = state.copyWith(
      blocks: newBlocks,
      blockStatuses: newBlockStatuses,
      processingBlocks: newProcessingBlocks,
      errorBlocks: newErrorBlocks,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Remove a message block
  void removeBlock(String blockId) {
    final block = state.blocks[blockId];
    if (block == null) {
      return; // Block doesn't exist
    }

    // Remove from blocks map
    final newBlocks = Map<String, EnhancedMessageBlock>.from(state.blocks);
    newBlocks.remove(blockId);

    // Remove from blocks by message
    final newBlocksByMessage =
        Map<String, List<String>>.from(state.blocksByMessage);
    final messageBlocks =
        List<String>.from(newBlocksByMessage[block.messageId] ?? []);
    messageBlocks.remove(blockId);
    newBlocksByMessage[block.messageId] = messageBlocks;

    // Remove from blocks by type
    final newBlocksByType =
        Map<EnhancedMessageBlockType, List<String>>.from(state.blocksByType);
    final typeBlocks = List<String>.from(newBlocksByType[block.type] ?? []);
    typeBlocks.remove(blockId);
    newBlocksByType[block.type] = typeBlocks;

    // Remove from block statuses
    final newBlockStatuses =
        Map<String, MessageBlockStatus>.from(state.blockStatuses);
    newBlockStatuses.remove(blockId);

    // Remove from processing/error sets
    final newProcessingBlocks = Set<String>.from(state.processingBlocks);
    final newErrorBlocks = Set<String>.from(state.errorBlocks);
    newProcessingBlocks.remove(blockId);
    newErrorBlocks.remove(blockId);

    // Remove from tool call mapping
    final newToolCallToBlockMap =
        Map<String, String>.from(state.toolCallToBlockMap);
    if (block.isToolCall && block.toolCallInfo != null) {
      newToolCallToBlockMap.remove(block.toolCallInfo!.callId);
    }

    state = state.copyWith(
      blocks: newBlocks,
      blocksByMessage: newBlocksByMessage,
      blocksByType: newBlocksByType,
      blockStatuses: newBlockStatuses,
      processingBlocks: newProcessingBlocks,
      errorBlocks: newErrorBlocks,
      toolCallToBlockMap: newToolCallToBlockMap,
      totalBlocks: newBlocks.length,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Add multiple blocks (batch operation)
  void addBlocks(List<EnhancedMessageBlock> blocks) {
    for (final block in blocks) {
      addBlock(block);
    }
  }

  /// Remove all blocks for a message
  void removeBlocksForMessage(String messageId) {
    final blockIds = state.blocksByMessage[messageId] ?? [];
    for (final blockId in blockIds) {
      removeBlock(blockId);
    }
  }

  // === Block Status Management ===

  /// Update block status
  void updateBlockStatus(String blockId, MessageBlockStatus status) {
    updateBlock(
        blockId,
        (block) => block.copyWith(
              status: status,
              updatedAt: DateTime.now(),
            ));
  }

  /// Update block content
  void updateBlockContent(String blockId, String content) {
    updateBlock(
        blockId,
        (block) => block.copyWith(
              content: content,
              updatedAt: DateTime.now(),
            ));
  }

  /// Set block error
  void setBlockError(String blockId, String errorMessage) {
    updateBlock(
        blockId,
        (block) => block.copyWith(
              status: MessageBlockStatus.error,
              errorInfo: BlockErrorInfo(
                code: 'BLOCK_ERROR',
                message: errorMessage,
              ),
              updatedAt: DateTime.now(),
            ));
  }

  /// Clear block error
  void clearBlockError(String blockId) {
    updateBlock(
        blockId,
        (block) => block.copyWith(
              status: MessageBlockStatus.success,
              errorInfo: null,
              updatedAt: DateTime.now(),
            ));
  }

  // === Tool Call Management ===

  /// Update tool call info
  void updateToolCallInfo(String blockId, ToolCallInfo toolCallInfo) {
    updateBlock(
        blockId,
        (block) => block.copyWith(
              toolCallInfo: toolCallInfo,
              updatedAt: DateTime.now(),
            ));

    // Update tool call mapping
    final newToolCallToBlockMap =
        Map<String, String>.from(state.toolCallToBlockMap);
    newToolCallToBlockMap[toolCallInfo.callId] = blockId;

    state = state.copyWith(
      toolCallToBlockMap: newToolCallToBlockMap,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Add tool call result
  void addToolCallResult(String toolCallId, dynamic result) {
    final newToolCallResults = Map<String, dynamic>.from(state.toolCallResults);
    newToolCallResults[toolCallId] = result;

    state = state.copyWith(
      toolCallResults: newToolCallResults,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Loading State Management ===

  /// Set loading state
  void setLoadingState(MessageBlockLoadingState loadingState, {String? error}) {
    state = state.copyWith(
      loadingState: loadingState,
      error: error,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Utility Methods ===

  /// Get block by ID
  EnhancedMessageBlock? getBlock(String blockId) {
    return state.getBlock(blockId);
  }

  /// Get blocks for message
  List<EnhancedMessageBlock> getBlocksForMessage(String messageId) {
    return state.getBlocksForMessage(messageId);
  }

  /// Get blocks by type
  List<EnhancedMessageBlock> getBlocksByType(EnhancedMessageBlockType type) {
    return state.getBlocksByType(type);
  }

  /// Check if block exists
  bool hasBlock(String blockId) {
    return state.hasBlock(blockId);
  }

  /// Get processing blocks
  List<EnhancedMessageBlock> get processingBlocks => state.processingBlocksList;

  /// Get error blocks
  List<EnhancedMessageBlock> get errorBlocks => state.errorBlocksList;

  /// Get tool call blocks
  List<EnhancedMessageBlock> get toolCallBlocks => state.toolCallBlocks;

  /// Check if has processing blocks
  bool get hasProcessingBlocks => state.hasProcessingBlocks;

  /// Check if has error blocks
  bool get hasErrorBlocks => state.hasErrorBlocks;

  /// Get block by tool call ID
  EnhancedMessageBlock? getBlockByToolCallId(String toolCallId) {
    return state.getBlockByToolCallId(toolCallId);
  }

  // === Cleanup and Reset ===

  /// Clear all blocks
  void clearAll() {
    state = const MessageBlockState();
  }

  /// Clear blocks for specific message
  void clearMessage(String messageId) {
    removeBlocksForMessage(messageId);
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

/// Message block state provider
final messageBlockStateProvider =
    StateNotifierProvider<MessageBlockStateNotifier, MessageBlockState>((ref) {
  return MessageBlockStateNotifier(ref);
});

// === Convenience Providers ===

/// All blocks provider
final allBlocksProvider = Provider<List<EnhancedMessageBlock>>((ref) {
  return ref.watch(messageBlockStateProvider).allBlocks;
});

/// Processing blocks provider
final processingBlocksProvider = Provider<List<EnhancedMessageBlock>>((ref) {
  return ref.watch(messageBlockStateProvider).processingBlocksList;
});

/// Error blocks provider
final errorBlocksProvider = Provider<List<EnhancedMessageBlock>>((ref) {
  return ref.watch(messageBlockStateProvider).errorBlocksList;
});

/// Tool call blocks provider
final toolCallBlocksProvider = Provider<List<EnhancedMessageBlock>>((ref) {
  return ref.watch(messageBlockStateProvider).toolCallBlocks;
});

/// Has processing blocks provider
final hasProcessingBlocksProvider = Provider<bool>((ref) {
  return ref.watch(messageBlockStateProvider).hasProcessingBlocks;
});

/// Has error blocks provider
final hasErrorBlocksProvider = Provider<bool>((ref) {
  return ref.watch(messageBlockStateProvider).hasErrorBlocks;
});

/// Total blocks provider
final totalBlocksProvider = Provider<int>((ref) {
  return ref.watch(messageBlockStateProvider).totalBlocks;
});

/// Block loading state provider
final blockLoadingStateProvider = Provider<MessageBlockLoadingState>((ref) {
  return ref.watch(messageBlockStateProvider).loadingState;
});

/// Block error provider
final blockErrorProvider = Provider<String?>((ref) {
  return ref.watch(messageBlockStateProvider).error;
});

// === Selector Providers ===

/// Get block by ID provider
final blockByIdProvider =
    Provider.family<EnhancedMessageBlock?, String>((ref, blockId) {
  return ref.watch(messageBlockStateProvider).getBlock(blockId);
});

/// Get blocks for message provider
final blocksForMessageProvider =
    Provider.family<List<EnhancedMessageBlock>, String>((ref, messageId) {
  return ref.watch(messageBlockStateProvider).getBlocksForMessage(messageId);
});

/// Get blocks by type provider
final blocksByTypeProvider =
    Provider.family<List<EnhancedMessageBlock>, EnhancedMessageBlockType>(
        (ref, type) {
  return ref.watch(messageBlockStateProvider).getBlocksByType(type);
});

/// Get block by tool call ID provider
final blockByToolCallIdProvider =
    Provider.family<EnhancedMessageBlock?, String>((ref, toolCallId) {
  return ref.watch(messageBlockStateProvider).getBlockByToolCallId(toolCallId);
});

/// Block content provider
final blockContentProvider = Provider.family<String, String>((ref, blockId) {
  final block = ref.watch(blockByIdProvider(blockId));
  return block?.content ?? '';
});

/// Block status provider
final blockStatusProvider =
    Provider.family<MessageBlockStatus?, String>((ref, blockId) {
  final block = ref.watch(blockByIdProvider(blockId));
  return block?.status;
});

/// Block is processing provider
final blockIsProcessingProvider = Provider.family<bool, String>((ref, blockId) {
  final block = ref.watch(blockByIdProvider(blockId));
  return block?.isProcessing ?? false;
});

/// Block has error provider
final blockHasErrorProvider = Provider.family<bool, String>((ref, blockId) {
  final block = ref.watch(blockByIdProvider(blockId));
  return block?.hasError ?? false;
});
