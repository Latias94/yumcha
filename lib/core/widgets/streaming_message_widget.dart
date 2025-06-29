import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_state_provider.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/entities/message_status.dart';

/// Modern streaming message widget using new state management system
///
/// This widget handles the display of streaming messages with proper animations
/// and state management through the new ChatStateProvider.
///
/// Features:
/// - 🔄 **Real-time updates**: Shows streaming content as it arrives
/// - ✨ **Smooth animations**: Typewriter effect and cursor blinking
/// - 🎯 **Status indicators**: Visual feedback for different message states
/// - 🛡️ **Error handling**: Graceful handling of streaming errors
/// - ⚡ **Performance**: Optimized for frequent updates
class StreamingMessageWidget extends ConsumerStatefulWidget {
  /// The message to display
  final Message message;

  /// Whether to show typing animation
  final bool showTypingAnimation;

  /// Whether to show cursor
  final bool showCursor;

  /// Animation duration for typewriter effect
  final Duration animationDuration;

  /// Cursor blink duration
  final Duration cursorBlinkDuration;

  /// Custom text style
  final TextStyle? textStyle;

  /// Callback when streaming completes
  final VoidCallback? onStreamingComplete;

  /// Callback when streaming fails
  final void Function(String error)? onStreamingError;

  const StreamingMessageWidget({
    super.key,
    required this.message,
    this.showTypingAnimation = true,
    this.showCursor = true,
    this.animationDuration = const Duration(milliseconds: 50),
    this.cursorBlinkDuration = const Duration(milliseconds: 500),
    this.textStyle,
    this.onStreamingComplete,
    this.onStreamingError,
  });

  @override
  ConsumerState<StreamingMessageWidget> createState() =>
      _StreamingMessageWidgetState();
}

class _StreamingMessageWidgetState extends ConsumerState<StreamingMessageWidget>
    with TickerProviderStateMixin {
  late AnimationController _typewriterController;
  late AnimationController _cursorController;
  late Animation<double> _typewriterAnimation;
  late Animation<double> _cursorAnimation;

  String _displayedContent = '';
  String _fullContent = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateContent();
  }

  @override
  void didUpdateWidget(StreamingMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.content != oldWidget.message.content ||
        widget.message.status != oldWidget.message.status) {
      _updateContent();
    }
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _typewriterController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _cursorController = AnimationController(
      duration: widget.cursorBlinkDuration,
      vsync: this,
    );

    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeOut,
    ));

    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    ));

    // Start cursor blinking
    _cursorController.repeat(reverse: true);
  }

  void _updateContent() {
    final newContent = widget.message.content ?? '';
    final isCurrentlyStreaming = _isMessageStreaming(widget.message.status);

    if (newContent != _fullContent) {
      _fullContent = newContent;

      if (isCurrentlyStreaming && widget.showTypingAnimation) {
        _animateToNewContent();
      } else {
        _displayedContent = _fullContent;
        if (mounted) {
          setState(() {});
        }
      }
    }

    if (_isStreaming != isCurrentlyStreaming) {
      _isStreaming = isCurrentlyStreaming;

      if (!_isStreaming) {
        // Streaming completed
        _displayedContent = _fullContent;
        _typewriterController.stop();
        _cursorController.stop();
        widget.onStreamingComplete?.call();
      } else {
        // Streaming started
        _cursorController.repeat(reverse: true);
      }

      if (mounted) {
        setState(() {});
      }
    }

    // Handle streaming errors
    if (widget.message.status == MessageStatus.error) {
      widget.onStreamingError
          ?.call(widget.message.content ?? 'Streaming error');
    }
  }

  void _animateToNewContent() {
    if (_fullContent.length > _displayedContent.length) {
      // Content is growing, animate the new part
      final targetLength = _fullContent.length;
      final currentLength = _displayedContent.length;

      _typewriterController.reset();
      _typewriterController.forward().then((_) {
        if (mounted) {
          _displayedContent = _fullContent;
          setState(() {});
        }
      });
    } else {
      // Content changed completely, update immediately
      _displayedContent = _fullContent;
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool _isMessageStreaming(MessageStatus? status) {
    return status == MessageStatus.streaming ||
        status == MessageStatus.aiStreaming ||
        status == MessageStatus.thinking;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_typewriterAnimation, _cursorAnimation]),
      builder: (context, child) {
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = widget.textStyle ?? theme.textTheme.bodyMedium;

    String displayText = _displayedContent;

    // Apply typewriter effect if streaming and animation enabled
    if (_isStreaming &&
        widget.showTypingAnimation &&
        _typewriterController.isAnimating) {
      final progress = _typewriterAnimation.value;
      final targetLength = _fullContent.length;
      final currentLength = _displayedContent.length;
      final animatedLength =
          currentLength + ((targetLength - currentLength) * progress).round();

      displayText = _fullContent.substring(
          0, animatedLength.clamp(0, _fullContent.length));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            displayText,
            style: effectiveTextStyle,
          ),
        ),

        // Cursor
        if (_isStreaming && widget.showCursor)
          AnimatedOpacity(
            opacity: _cursorAnimation.value,
            duration: const Duration(milliseconds: 100),
            child: Text(
              '|',
              style: effectiveTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

        // Status indicator
        if (widget.message.status != null)
          _buildStatusIndicator(context, widget.message.status!),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context, MessageStatus status) {
    final theme = Theme.of(context);

    switch (status) {
      case MessageStatus.streaming:
      case MessageStatus.aiStreaming:
        return Container(
          margin: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        );

      case MessageStatus.thinking:
        return Container(
          margin: const EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.psychology,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        );

      case MessageStatus.error:
        return Container(
          margin: const EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
        );

      case MessageStatus.success:
      case MessageStatus.userSuccess:
      case MessageStatus.aiSuccess:
        return Container(
          margin: const EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Provider for streaming message configuration
final streamingMessageConfigProvider = Provider<StreamingMessageConfig>((ref) {
  final chatState = ref.watch(chatStateProvider);
  return StreamingMessageConfig(
    enableAnimations: chatState.config.useStreaming,
    animationSpeed: chatState.config.streamingConfig?.animationSpeed ?? 50,
    showCursor: true,
  );
});

/// Configuration for streaming message behavior
class StreamingMessageConfig {
  final bool enableAnimations;
  final int animationSpeed;
  final bool showCursor;

  const StreamingMessageConfig({
    required this.enableAnimations,
    required this.animationSpeed,
    required this.showCursor,
  });
}
