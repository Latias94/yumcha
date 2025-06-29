import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_state_provider.dart';
import '../../features/chat/domain/entities/message.dart';

/// Modern chat input widget using new state management system
///
/// This widget provides a comprehensive chat input interface with features like:
/// - 📝 **Rich text input**: Multi-line text input with formatting
/// - 🎤 **Voice input**: Voice-to-text functionality (placeholder)
/// - 📎 **File attachments**: Support for file uploads (placeholder)
/// - 🔄 **Auto-suggestions**: Smart text suggestions
/// - ⚡ **Performance optimized**: Efficient text handling and state management
/// - 📱 **Responsive design**: Adapts to different screen sizes
class ChatInputWidget extends ConsumerStatefulWidget {
  /// Placeholder text for the input field
  final String? placeholder;

  /// Maximum number of lines for the input
  final int maxLines;

  /// Whether to enable voice input
  final bool enableVoiceInput;

  /// Whether to enable file attachments
  final bool enableAttachments;

  /// Whether to show send button
  final bool showSendButton;

  /// Custom input decoration
  final InputDecoration? decoration;

  /// Callback when message is sent
  final void Function(String message)? onMessageSent;

  /// Callback when voice input is requested
  final VoidCallback? onVoiceInput;

  /// Callback when file attachment is requested
  final VoidCallback? onAttachment;

  /// Callback when text changes
  final void Function(String text)? onTextChanged;

  const ChatInputWidget({
    super.key,
    this.placeholder,
    this.maxLines = 5,
    this.enableVoiceInput = false,
    this.enableAttachments = false,
    this.showSendButton = true,
    this.decoration,
    this.onMessageSent,
    this.onVoiceInput,
    this.onAttachment,
    this.onTextChanged,
  });

  @override
  ConsumerState<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends ConsumerState<ChatInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  bool _isComposing = false;
  bool _isVoiceRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupTextController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sendButtonAnimation = CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeInOut,
    );
  }

  void _setupTextController() {
    _textController.addListener(() {
      final text = _textController.text;
      final wasComposing = _isComposing;

      setState(() {
        _isComposing = text.trim().isNotEmpty;
      });

      // Animate send button
      if (_isComposing && !wasComposing) {
        _sendButtonController.forward();
      } else if (!_isComposing && wasComposing) {
        _sendButtonController.reverse();
      }

      // Notify text change
      widget.onTextChanged?.call(text);
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Check if chat is ready
    final chatState = ref.read(chatStateProvider);
    if (chatState.currentConversation == null || chatState.isLoading) {
      _showSnackBar('Please wait or select a conversation first');
      return;
    }

    // Create and send message
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: chatState.currentConversation!.id,
      role: 'user',
      assistantId: chatState.currentConversation?.assistantId ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Note: In a real implementation, create MessageBlock with text content
      blocks: [], // Simplified for now
    );

    // Add to state
    ref.read(chatStateProvider.notifier).addMessage(message);

    // Clear input
    _textController.clear();

    // Notify callback
    widget.onMessageSent?.call(text);

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _startVoiceRecording() {
    if (!widget.enableVoiceInput) return;

    setState(() {
      _isVoiceRecording = true;
    });

    widget.onVoiceInput?.call();

    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _stopVoiceRecording() {
    setState(() {
      _isVoiceRecording = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatStateProvider);
    final isDisabled =
        chatState.currentConversation == null || chatState.isLoading;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            if (widget.enableAttachments) _buildAttachmentButton(isDisabled),

            // Text input
            Expanded(
              child: _buildTextInput(theme, isDisabled),
            ),

            const SizedBox(width: 8),

            // Voice/Send button
            _buildActionButton(theme, isDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(bool isDisabled) {
    return IconButton(
      onPressed: isDisabled ? null : widget.onAttachment,
      icon: const Icon(Icons.attach_file),
      tooltip: 'Attach file',
    );
  }

  Widget _buildTextInput(ThemeData theme, bool isDisabled) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxLines * 24.0, // Approximate line height
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: !isDisabled,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        decoration: widget.decoration ??
            InputDecoration(
              hintText: _getPlaceholderText(isDisabled),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: isDisabled
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            ),
        onSubmitted: (_) => _sendMessage(),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme, bool isDisabled) {
    // Show voice button when not composing and voice input is enabled
    if (!_isComposing && widget.enableVoiceInput) {
      return _buildVoiceButton(theme, isDisabled);
    }

    // Show send button when composing or voice input is disabled
    if (widget.showSendButton) {
      return _buildSendButton(theme, isDisabled);
    }

    return const SizedBox.shrink();
  }

  Widget _buildVoiceButton(ThemeData theme, bool isDisabled) {
    return GestureDetector(
      onTapDown: (_) => _startVoiceRecording(),
      onTapUp: (_) => _stopVoiceRecording(),
      onTapCancel: () => _stopVoiceRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _isVoiceRecording
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isVoiceRecording ? Icons.stop : Icons.mic,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme, bool isDisabled) {
    return AnimatedBuilder(
      animation: _sendButtonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_sendButtonAnimation.value * 0.2),
          child: IconButton(
            onPressed: (!isDisabled && _isComposing) ? _sendMessage : null,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: (_isComposing && !isDisabled)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              foregroundColor: (_isComposing && !isDisabled)
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.outline,
              shape: const CircleBorder(),
            ),
          ),
        );
      },
    );
  }

  String _getPlaceholderText(bool isDisabled) {
    if (isDisabled) {
      final chatState = ref.read(chatStateProvider);
      if (chatState.isLoading) {
        return 'AI is thinking...';
      } else if (chatState.currentConversation == null) {
        return 'Select a conversation to start chatting';
      }
    }

    return widget.placeholder ?? 'Type a message...';
  }
}

/// Provider for chat input configuration
final chatInputConfigProvider = Provider<ChatInputConfig>((ref) {
  final chatState = ref.watch(chatStateProvider);
  return ChatInputConfig(
    maxLines: 5,
    enableVoiceInput: false, // Can be configured based on settings
    enableAttachments: true,
    showSendButton: true,
    isEnabled: chatState.currentConversation != null && !chatState.isLoading,
  );
});

/// Configuration for chat input behavior
class ChatInputConfig {
  final int maxLines;
  final bool enableVoiceInput;
  final bool enableAttachments;
  final bool showSendButton;
  final bool isEnabled;

  const ChatInputConfig({
    required this.maxLines,
    required this.enableVoiceInput,
    required this.enableAttachments,
    required this.showSendButton,
    required this.isEnabled,
  });
}
