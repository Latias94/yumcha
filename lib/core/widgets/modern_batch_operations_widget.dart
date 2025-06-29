import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/message_operation_state_provider.dart';
import '../state/message_operation_state.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../shared/presentation/design_system/design_constants.dart';

/// Modern batch operations widget
///
/// Provides batch operation functionality for messages using the new state management.
/// Inspired by the existing BatchOperationsPanel but modernized and integrated with the new architecture.
class ModernBatchOperationsWidget extends ConsumerStatefulWidget {
  const ModernBatchOperationsWidget({
    super.key,
    required this.messages,
    this.onClose,
  });

  /// Available messages for batch operations
  final List<Message> messages;

  /// Callback when batch mode is closed
  final VoidCallback? onClose;

  @override
  ConsumerState<ModernBatchOperationsWidget> createState() =>
      _ModernBatchOperationsWidgetState();
}

class _ModernBatchOperationsWidgetState
    extends ConsumerState<ModernBatchOperationsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignConstants.animationMedium,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBatchMode = ref.watch(isBatchModeProvider);
    final selectionCount = ref.watch(batchSelectionCountProvider);
    final operationState = ref.watch(messageOperationStateProvider);

    if (!isBatchMode) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: DesignConstants.shadowL(theme),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(theme, selectionCount),

                // Selection controls
                _buildSelectionControls(theme),

                // Operation buttons
                if (selectionCount > 0) _buildOperationButtons(theme),

                // Batch progress
                if (operationState.currentBatchOperation != null)
                  _buildBatchProgress(theme, operationState),

                // Selected messages preview
                if (selectionCount > 0 && selectionCount <= 5)
                  _buildSelectedMessagesPreview(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build header with title and close button
  Widget _buildHeader(ThemeData theme, int selectionCount) {
    return Container(
      padding: DesignConstants.paddingL,
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            color: theme.colorScheme.primary,
            size: DesignConstants.iconSizeM,
          ),
          SizedBox(width: DesignConstants.spaceM),
          Expanded(
            child: Text(
              'Batch Operations',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (selectionCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: DesignConstants.radiusS,
              ),
              child: Text(
                '$selectionCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: DesignConstants.spaceM),
          ],
          IconButton(
            onPressed: _closeBatchMode,
            icon: const Icon(Icons.close),
            tooltip: 'Exit batch mode',
          ),
        ],
      ),
    );
  }

  /// Build selection controls
  Widget _buildSelectionControls(ThemeData theme) {
    final operationState = ref.watch(messageOperationStateProvider);
    final allSelected =
        operationState.batchSelectedMessages.length == widget.messages.length;
    final someSelected = operationState.batchSelectedMessages.isNotEmpty;

    return Container(
      padding: DesignConstants.paddingL.copyWith(top: 0),
      child: Row(
        children: [
          Checkbox(
            value: allSelected ? true : (someSelected ? null : false),
            tristate: true,
            onChanged: _toggleSelectAll,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Text(
            allSelected ? 'Deselect All' : 'Select All',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          if (someSelected)
            TextButton(
              onPressed: _clearSelection,
              child: const Text('Clear Selection'),
            ),
        ],
      ),
    );
  }

  /// Build operation buttons
  Widget _buildOperationButtons(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingL,
      child: Wrap(
        spacing: DesignConstants.spaceM,
        runSpacing: DesignConstants.spaceS,
        children: [
          _buildOperationButton(
            icon: Icons.copy,
            label: 'Copy',
            onPressed: () => _executeBatchOperation(BatchOperationType.copy),
          ),
          _buildOperationButton(
            icon: Icons.download,
            label: 'Export',
            onPressed: () => _executeBatchOperation(BatchOperationType.export),
          ),
          _buildOperationButton(
            icon: Icons.translate,
            label: 'Translate',
            onPressed: () =>
                _executeBatchOperation(BatchOperationType.translate),
          ),
          _buildOperationButton(
            icon: Icons.delete,
            label: 'Delete',
            onPressed: () => _showDeleteConfirmation(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Build individual operation button
  Widget _buildOperationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
        foregroundColor: isDestructive
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusM,
        ),
      ),
    );
  }

  /// Build batch progress indicator
  Widget _buildBatchProgress(
      ThemeData theme, MessageOperationState operationState) {
    final progress = operationState.batchProgress;
    final operationType = operationState.currentBatchOperation;

    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: DesignConstants.spaceM),
              Text(
                _getBatchOperationDisplayName(operationType!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  /// Build selected messages preview
  Widget _buildSelectedMessagesPreview(ThemeData theme) {
    final operationState = ref.watch(messageOperationStateProvider);
    final selectedIds = operationState.batchSelectedMessages;
    final selectedMessages = widget.messages
        .where((m) => selectedIds.contains(m.id))
        .take(3)
        .toList();

    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Messages',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DesignConstants.spaceS),
          ...selectedMessages
              .map((message) => _buildMessagePreview(theme, message)),
          if (selectedIds.length > 3)
            Padding(
              padding: EdgeInsets.only(top: DesignConstants.spaceS),
              child: Text(
                'and ${selectedIds.length - 3} more...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build individual message preview
  Widget _buildMessagePreview(ThemeData theme, Message message) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            message.isFromUser ? Icons.person : Icons.smart_toy,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Expanded(
            child: Text(
              message.content.length > 50
                  ? '${message.content.substring(0, 50)}...'
                  : message.content,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _toggleMessageSelection(message.id),
            icon: const Icon(Icons.close, size: 16),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // === Event Handlers ===

  void _closeBatchMode() {
    ref.read(messageOperationStateProvider.notifier).toggleBatchMode();
    widget.onClose?.call();
  }

  void _toggleSelectAll(bool? value) {
    final notifier = ref.read(messageOperationStateProvider.notifier);
    if (value == true) {
      // Select all messages
      for (final message in widget.messages) {
        notifier.toggleBatchSelection(message.id);
      }
    } else {
      // Clear all selections
      _clearSelection();
    }
  }

  void _clearSelection() {
    final operationState = ref.read(messageOperationStateProvider);
    final notifier = ref.read(messageOperationStateProvider.notifier);

    for (final messageId in operationState.batchSelectedMessages) {
      notifier.toggleBatchSelection(messageId);
    }
  }

  void _toggleMessageSelection(String messageId) {
    ref
        .read(messageOperationStateProvider.notifier)
        .toggleBatchSelection(messageId);
  }

  void _executeBatchOperation(BatchOperationType operationType) {
    ref
        .read(messageOperationStateProvider.notifier)
        .executeBatchOperation(operationType);
  }

  void _showDeleteConfirmation() {
    final selectionCount = ref.read(batchSelectionCountProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Batch Delete'),
        content: Text(
            'Are you sure you want to delete $selectionCount selected messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _executeBatchOperation(BatchOperationType.delete);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getBatchOperationDisplayName(BatchOperationType type) {
    switch (type) {
      case BatchOperationType.delete:
        return 'Deleting messages...';
      case BatchOperationType.copy:
        return 'Copying messages...';
      case BatchOperationType.export:
        return 'Exporting messages...';
      case BatchOperationType.translate:
        return 'Translating messages...';
      case BatchOperationType.mark:
        return 'Marking messages...';
    }
  }
}
