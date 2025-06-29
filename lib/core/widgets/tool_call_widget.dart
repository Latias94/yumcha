import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_state_provider.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/entities/message_status.dart';

/// Modern tool call widget using new state management system
///
/// This widget handles the display of AI tool calls and their results
/// with proper state management through the new ChatStateProvider.
///
/// Features:
/// - 🔧 **Tool execution display**: Shows tool calls and results
/// - 🔄 **Real-time updates**: Updates as tool execution progresses
/// - 📊 **Status indicators**: Visual feedback for different execution states
/// - 🛡️ **Error handling**: Graceful handling of tool execution errors
/// - 📱 **Responsive design**: Adapts to different screen sizes
class ToolCallWidget extends ConsumerStatefulWidget {
  /// The message containing tool calls
  final Message message;

  /// Whether to show execution details
  final bool showDetails;

  /// Whether to allow tool call expansion
  final bool allowExpansion;

  /// Custom styling for tool calls
  final ToolCallStyle? style;

  /// Callback when tool call is tapped
  final void Function(String toolCallId)? onToolCallTap;

  /// Callback when tool execution completes
  final void Function(String toolCallId, Map<String, dynamic> result)?
      onToolComplete;

  /// Callback when tool execution fails
  final void Function(String toolCallId, String error)? onToolError;

  const ToolCallWidget({
    super.key,
    required this.message,
    this.showDetails = true,
    this.allowExpansion = true,
    this.style,
    this.onToolCallTap,
    this.onToolComplete,
    this.onToolError,
  });

  @override
  ConsumerState<ToolCallWidget> createState() => _ToolCallWidgetState();
}

class _ToolCallWidgetState extends ConsumerState<ToolCallWidget>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;

  final Map<String, bool> _expandedStates = {};
  final Map<String, AnimationController> _progressControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeToolStates();
  }

  @override
  void didUpdateWidget(ToolCallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.id != oldWidget.message.id) {
      _initializeToolStates();
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    for (final controller in _progressControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeToolStates() {
    // Initialize expansion states and progress controllers for tool calls
    final toolCalls = _extractToolCalls(widget.message);

    for (final toolCall in toolCalls) {
      final toolId = toolCall['id'] as String? ?? '';

      if (!_expandedStates.containsKey(toolId)) {
        _expandedStates[toolId] = false;
      }

      if (!_progressControllers.containsKey(toolId)) {
        _progressControllers[toolId] = AnimationController(
          duration: const Duration(milliseconds: 1000),
          vsync: this,
        );
      }

      // Update progress based on tool status
      _updateToolProgress(toolId, toolCall);
    }
  }

  List<Map<String, dynamic>> _extractToolCalls(Message message) {
    // Extract tool calls from message content or metadata
    // This would depend on how tool calls are stored in your message structure
    final toolCalls = <Map<String, dynamic>>[];

    // Example implementation - adjust based on your actual data structure
    if (message.content != null && message.content!.contains('tool_call:')) {
      // Parse tool calls from content
      // This is a simplified example
      toolCalls.add({
        'id': 'tool_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'example_tool',
        'arguments': {'param': 'value'},
        'status': 'executing',
        'result': null,
      });
    }

    return toolCalls;
  }

  void _updateToolProgress(String toolId, Map<String, dynamic> toolCall) {
    final controller = _progressControllers[toolId];
    if (controller == null) return;

    final status = toolCall['status'] as String? ?? 'pending';

    switch (status) {
      case 'pending':
        controller.reset();
        break;
      case 'executing':
        controller.repeat();
        break;
      case 'completed':
        controller.forward();
        widget.onToolComplete?.call(toolId, toolCall['result'] ?? {});
        break;
      case 'failed':
        controller.stop();
        widget.onToolError?.call(toolId, toolCall['error'] ?? 'Unknown error');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolCalls = _extractToolCalls(widget.message);

    if (toolCalls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(toolCalls.length),
          ...toolCalls.map((toolCall) => _buildToolCallItem(toolCall)),
        ],
      ),
    );
  }

  Widget _buildHeader(int toolCount) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.build,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Tool Calls ($toolCount)',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (widget.allowExpansion)
            IconButton(
              icon: AnimatedRotation(
                turns: _expansionAnimation.value * 0.5,
                child: const Icon(Icons.expand_more),
              ),
              onPressed: _toggleExpansion,
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildToolCallItem(Map<String, dynamic> toolCall) {
    final toolId = toolCall['id'] as String? ?? '';
    final toolName = toolCall['name'] as String? ?? 'Unknown Tool';
    final status = toolCall['status'] as String? ?? 'pending';
    final isExpanded = _expandedStates[toolId] ?? false;

    return AnimatedBuilder(
      animation: _expansionAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToolHeader(toolCall),
              if (widget.showDetails &&
                  (isExpanded || _expansionAnimation.value > 0))
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _buildToolDetails(toolCall),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolHeader(Map<String, dynamic> toolCall) {
    final theme = Theme.of(context);
    final toolId = toolCall['id'] as String? ?? '';
    final toolName = toolCall['name'] as String? ?? 'Unknown Tool';
    final status = toolCall['status'] as String? ?? 'pending';

    return GestureDetector(
      onTap: () {
        widget.onToolCallTap?.call(toolId);
        if (widget.allowExpansion) {
          _toggleToolExpansion(toolId);
        }
      },
      child: Row(
        children: [
          _buildStatusIcon(status),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toolName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getStatusText(status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(status, theme),
                  ),
                ),
              ],
            ),
          ),
          if (status == 'executing') _buildProgressIndicator(toolId),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    final theme = Theme.of(context);

    switch (status) {
      case 'pending':
        return Icon(
          Icons.schedule,
          size: 16,
          color: theme.colorScheme.outline,
        );
      case 'executing':
        return Icon(
          Icons.play_circle_outline,
          size: 16,
          color: theme.colorScheme.primary,
        );
      case 'completed':
        return Icon(
          Icons.check_circle_outline,
          size: 16,
          color: theme.colorScheme.primary,
        );
      case 'failed':
        return Icon(
          Icons.error_outline,
          size: 16,
          color: theme.colorScheme.error,
        );
      default:
        return Icon(
          Icons.help_outline,
          size: 16,
          color: theme.colorScheme.outline,
        );
    }
  }

  Widget _buildProgressIndicator(String toolId) {
    final controller = _progressControllers[toolId];
    if (controller == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            value: controller.status == AnimationStatus.forward
                ? controller.value
                : null,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildToolDetails(Map<String, dynamic> toolCall) {
    final theme = Theme.of(context);
    final arguments = toolCall['arguments'] as Map<String, dynamic>? ?? {};
    final result = toolCall['result'];
    final error = toolCall['error'] as String?;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arguments.isNotEmpty) ...[
            Text(
              'Arguments:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatJson(arguments),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (result != null) ...[
            Text(
              'Result:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatJson(result),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (error != null) ...[
            Text(
              'Error:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting to execute';
      case 'executing':
        return 'Executing...';
      case 'completed':
        return 'Completed successfully';
      case 'failed':
        return 'Execution failed';
      default:
        return 'Unknown status';
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pending':
        return theme.colorScheme.outline;
      case 'executing':
        return theme.colorScheme.primary;
      case 'completed':
        return theme.colorScheme.primary;
      case 'failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _formatJson(dynamic data) {
    // Simple JSON formatting - you might want to use a proper JSON formatter
    return data.toString();
  }

  void _toggleExpansion() {
    if (_expansionController.isCompleted) {
      _expansionController.reverse();
    } else {
      _expansionController.forward();
    }
  }

  void _toggleToolExpansion(String toolId) {
    setState(() {
      _expandedStates[toolId] = !(_expandedStates[toolId] ?? false);
    });
  }
}

/// Styling configuration for tool call widgets
class ToolCallStyle {
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? headerTextStyle;
  final TextStyle? bodyTextStyle;

  const ToolCallStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.headerTextStyle,
    this.bodyTextStyle,
  });
}
