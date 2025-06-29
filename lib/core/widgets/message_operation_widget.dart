import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/message_operation_state_provider.dart';
import '../providers/runtime_state_provider.dart';
import '../state/message_operation_state.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../shared/presentation/design_system/design_constants.dart';

/// Modern message operation widget
///
/// Provides message operation buttons and menus similar to Cherry Studio's MessageMenubar
/// but using the new state management architecture.
class MessageOperationWidget extends ConsumerStatefulWidget {
  const MessageOperationWidget({
    super.key,
    required this.message,
    required this.isLastMessage,
    this.showOnHover = true,
    this.compactMode = false,
  });

  /// The message to show operations for
  final Message message;

  /// Whether this is the last message in the conversation
  final bool isLastMessage;

  /// Whether to show operations only on hover
  final bool showOnHover;

  /// Whether to use compact mode (fewer buttons)
  final bool compactMode;

  @override
  ConsumerState<MessageOperationWidget> createState() =>
      _MessageOperationWidgetState();
}

class _MessageOperationWidgetState extends ConsumerState<MessageOperationWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignConstants.animationFast,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBeingProcessed =
        ref.watch(messageBeingProcessedProvider(widget.message.id));
    final operationType =
        ref.watch(messageOperationTypeProvider(widget.message.id));
    final operationProgress =
        ref.watch(messageOperationProgressProvider(widget.message.id));
    final operationError =
        ref.watch(messageOperationErrorProvider(widget.message.id));
    final isBatchMode = ref.watch(isBatchModeProvider);

    // Show operations if it's the last message, on hover, or if there's an active operation
    final shouldShow = widget.isLastMessage ||
        _isHovered ||
        isBeingProcessed ||
        !widget.showOnHover;

    if (shouldShow && !_animationController.isCompleted) {
      _animationController.forward();
    } else if (!shouldShow && _animationController.isCompleted) {
      _animationController.reverse();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: widget.showOnHover ? _fadeAnimation.value : 1.0,
            child: Container(
              padding: DesignConstants.paddingS,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Operation progress indicator
                  if (isBeingProcessed)
                    _buildProgressIndicator(operationType!, operationProgress),

                  // Operation error
                  if (operationError != null)
                    _buildErrorIndicator(operationError),

                  // Operation buttons
                  if (!isBeingProcessed)
                    _buildOperationButtons(theme, isBatchMode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build progress indicator for active operations
  Widget _buildProgressIndicator(
      MessageOperationType operationType, double progress) {
    final theme = Theme.of(context);

    return Container(
      padding: DesignConstants.paddingS,
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: DesignConstants.radiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: DesignConstants.spaceS),
          Text(
            _getOperationDisplayName(operationType),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          if (progress > 0) ...[
            SizedBox(width: DesignConstants.spaceS),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error indicator
  Widget _buildErrorIndicator(String error) {
    final theme = Theme.of(context);

    return Container(
      padding: DesignConstants.paddingS,
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: DesignConstants.radiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.onErrorContainer,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Flexible(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: DesignConstants.spaceS),
          InkWell(
            onTap: () => ref
                .read(messageOperationStateProvider.notifier)
                .clearOperationError(widget.message.id),
            child: Icon(
              Icons.close,
              size: 14,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Build operation buttons
  Widget _buildOperationButtons(ThemeData theme, bool isBatchMode) {
    if (widget.compactMode) {
      return _buildCompactButtons(theme, isBatchMode);
    } else {
      return _buildFullButtons(theme, isBatchMode);
    }
  }

  /// Build compact operation buttons
  Widget _buildCompactButtons(ThemeData theme, bool isBatchMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy button
        _buildActionButton(
          icon: Icons.copy,
          tooltip: 'Copy',
          onPressed: () => _copyMessage(),
        ),

        // More options menu
        _buildMoreOptionsButton(theme, isBatchMode),
      ],
    );
  }

  /// Build full operation buttons
  Widget _buildFullButtons(ThemeData theme, bool isBatchMode) {
    final isUserMessage = widget.message.isFromUser;

    return Wrap(
      spacing: DesignConstants.spaceXS,
      children: [
        // Edit button (for user messages)
        if (isUserMessage)
          _buildActionButton(
            icon: Icons.edit,
            tooltip: 'Edit',
            onPressed: () => _editMessage(),
          ),

        // Regenerate button (for user messages)
        if (isUserMessage)
          _buildActionButton(
            icon: Icons.refresh,
            tooltip: 'Regenerate',
            onPressed: () => _resendMessage(),
          ),

        // Regenerate button (for AI messages)
        if (!isUserMessage)
          _buildActionButton(
            icon: Icons.refresh,
            tooltip: 'Regenerate',
            onPressed: () => _regenerateMessage(),
          ),

        // Copy button
        _buildActionButton(
          icon: Icons.copy,
          tooltip: 'Copy',
          onPressed: () => _copyMessage(),
        ),

        // Branch button
        _buildActionButton(
          icon: Icons.call_split,
          tooltip: 'Create Branch',
          onPressed: () => _createBranch(),
        ),

        // Delete button
        _buildActionButton(
          icon: Icons.delete,
          tooltip: 'Delete',
          onPressed: () => _deleteMessage(),
          isDestructive: true,
        ),

        // More options
        _buildMoreOptionsButton(theme, isBatchMode),
      ],
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: DesignConstants.radiusS,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: DesignConstants.radiusS,
            color: Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Build more options button with dropdown menu
  Widget _buildMoreOptionsButton(ThemeData theme, bool isBatchMode) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      tooltip: 'More options',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.download, size: 16),
              SizedBox(width: DesignConstants.spaceS),
              Text('Export'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'translate',
          child: Row(
            children: [
              Icon(Icons.translate, size: 16),
              SizedBox(width: DesignConstants.spaceS),
              Text('Translate'),
            ],
          ),
        ),
        if (!isBatchMode)
          PopupMenuItem(
            value: 'batch_select',
            child: Row(
              children: [
                Icon(Icons.checklist, size: 16),
                SizedBox(width: DesignConstants.spaceS),
                Text('Select for batch'),
              ],
            ),
          ),
      ],
      onSelected: (value) => _handleMoreOption(value),
    );
  }

  // === Operation Handlers ===

  void _editMessage() {
    ref.read(runtimeStateProvider.notifier).startEditing(
          widget.message.id,
          widget.message.content,
        );
  }

  void _copyMessage() {
    ref
        .read(messageOperationStateProvider.notifier)
        .copyMessage(widget.message.id);
  }

  void _deleteMessage() {
    _showDeleteConfirmation();
  }

  void _resendMessage() {
    ref
        .read(messageOperationStateProvider.notifier)
        .resendMessage(widget.message.id);
  }

  void _regenerateMessage() {
    ref
        .read(messageOperationStateProvider.notifier)
        .regenerateMessage(widget.message.id);
  }

  void _createBranch() {
    ref
        .read(messageOperationStateProvider.notifier)
        .createMessageBranch(widget.message.id);
  }

  void _handleMoreOption(String option) {
    switch (option) {
      case 'export':
        ref
            .read(messageOperationStateProvider.notifier)
            .exportMessage(widget.message.id, 'markdown');
        break;
      case 'translate':
        _showTranslateDialog();
        break;
      case 'batch_select':
        ref.read(messageOperationStateProvider.notifier).toggleBatchMode();
        ref
            .read(messageOperationStateProvider.notifier)
            .toggleBatchSelection(widget.message.id);
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(messageOperationStateProvider.notifier)
                  .deleteMessage(widget.message.id);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTranslateDialog() {
    // TODO: Implement translation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Translation feature coming soon')),
    );
  }

  String _getOperationDisplayName(MessageOperationType type) {
    switch (type) {
      case MessageOperationType.editing:
        return 'Editing...';
      case MessageOperationType.deleting:
        return 'Deleting...';
      case MessageOperationType.copying:
        return 'Copying...';
      case MessageOperationType.regenerating:
        return 'Regenerating...';
      case MessageOperationType.translating:
        return 'Translating...';
      case MessageOperationType.branching:
        return 'Creating branch...';
      case MessageOperationType.exporting:
        return 'Exporting...';
      case MessageOperationType.resending:
        return 'Resending...';
      case MessageOperationType.pausing:
        return 'Pausing...';
      case MessageOperationType.resuming:
        return 'Resuming...';
    }
  }
}
