import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../../../../shared/presentation/design_system/design_constants.dart';
import '../../providers/chat_configuration_notifier.dart';

/// 增强聊天输入组件
/// 
/// 支持：
/// - 文本输入和发送
/// - 图片选择和拍照
/// - 多媒体功能开关
/// - 提供商能力检测
class EnhancedChatInputWidget extends ConsumerStatefulWidget {
  const EnhancedChatInputWidget({
    super.key,
    required this.provider,
    required this.assistant,
    required this.modelName,
    this.onSendMessage,
  });

  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final VoidCallback? onSendMessage;

  @override
  ConsumerState<EnhancedChatInputWidget> createState() => _EnhancedChatInputWidgetState();
}

class _EnhancedChatInputWidgetState extends ConsumerState<EnhancedChatInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatConfig = ref.watch(chatConfigurationProvider);
    // TODO: 实现Provider能力检测
    // final capabilities = ref.watch(providerMultimediaCapabilitiesProvider(widget.provider));

    final isLoading = false; // TODO: 实现加载状态

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: DesignConstants.borderWidthThin,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 多媒体功能开关
          // TODO: 实现多媒体功能控制
          // if (capabilities.hasAnyCapability) ...[
          //   _buildMultimediaControls(theme, capabilities),
          //   SizedBox(height: DesignConstants.spaceM),
          // ],

          // 主输入区域
          Row(
            children: [
              // 图片按钮
              // TODO: 实现图片功能
              // if (capabilities.supportsImageAnalysis) ...[
              //   _buildImageButton(theme, isLoading),
              //   SizedBox(width: DesignConstants.spaceS),
              // ],

              // 文本输入框
              Expanded(
                child: _buildTextInput(theme, isLoading),
              ),

              SizedBox(width: DesignConstants.spaceS),

              // 发送按钮
              _buildSendButton(theme, isLoading),
            ],
          ),

          // 错误提示
          // TODO: 实现错误状态
          // if (chatState.error != null) ...[
          //   SizedBox(height: DesignConstants.spaceS),
          //   _buildErrorMessage(theme, chatState.error!),
          // ],
        ],
      ),
    );
  }

  Widget _buildMultimediaControls(ThemeData theme, dynamic capabilities) {
    // TODO: 实现聊天状态
    // final chatState = ref.watch(enhancedChatNotifierProvider);

    return Container(
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: DesignConstants.spaceS),
          
          Text(
            '智能功能:',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          SizedBox(width: DesignConstants.spaceM),

          // TODO: 实现功能开关
          Text(
            '多媒体功能开发中...',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          // 自动图片生成开关
          // if (capabilities.supportsImageGeneration) ...[
          //   _buildToggleChip(
          //     theme: theme,
          //     label: '图片生成',
          //     icon: Icons.image_rounded,
          //     isEnabled: chatState.autoImageGeneration,
          //     onToggle: () => ref.read(enhancedChatNotifierProvider.notifier).toggleAutoImageGeneration(),
          //   ),
          //   SizedBox(width: DesignConstants.spaceS),
          // ],

          // 自动TTS开关
          // if (capabilities.supportsTts) ...[
          //   _buildToggleChip(
          //     theme: theme,
          //     label: 'TTS',
          //     icon: Icons.record_voice_over_rounded,
          //     isEnabled: chatState.autoTtsGeneration,
          //     onToggle: () => ref.read(enhancedChatNotifierProvider.notifier).toggleAutoTtsGeneration(),
          //   ),
          //   SizedBox(width: DesignConstants.spaceS),
          // ],

          // 图片分析开关
          // if (capabilities.supportsImageAnalysis) ...[
          //   _buildToggleChip(
          //     theme: theme,
          //     label: '图片分析',
          //     icon: Icons.image_search_rounded,
          //     isEnabled: chatState.imageAnalysisEnabled,
          //     onToggle: () => ref.read(enhancedChatNotifierProvider.notifier).toggleImageAnalysis(),
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceS,
          vertical: DesignConstants.spaceXS,
        ),
        decoration: BoxDecoration(
          color: isEnabled 
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: DesignConstants.radiusS,
          border: Border.all(
            color: isEnabled
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: DesignConstants.borderWidthThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isEnabled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: DesignConstants.spaceXS),
            Text(
              label,
              style: TextStyle(
                color: isEnabled
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton(ThemeData theme, bool isLoading) {
    return PopupMenuButton<String>(
      enabled: !isLoading,
      icon: Icon(
        Icons.image_rounded,
        color: isLoading 
            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
            : theme.colorScheme.primary,
      ),
      tooltip: '添加图片',
      onSelected: (value) {
        // TODO: 实现图片功能
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('图片功能开发中...'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        // switch (value) {
        //   case 'gallery':
        //     ref.read(enhancedChatNotifierProvider.notifier).pickAndSendImage(
        //       provider: widget.provider,
        //       assistant: widget.assistant,
        //       modelName: widget.modelName,
        //     );
        //     break;
        //   case 'camera':
        //     ref.read(enhancedChatNotifierProvider.notifier).takePhotoAndSend(
        //       provider: widget.provider,
        //       assistant: widget.assistant,
        //       modelName: widget.modelName,
        //     );
        //     break;
        // }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library_rounded),
              SizedBox(width: 8),
              Text('从相册选择'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt_rounded),
              SizedBox(width: 8),
              Text('拍照'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(ThemeData theme, bool isLoading) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: !isLoading,
      maxLines: null,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: isLoading ? '正在处理...' : '输入消息...',
        border: OutlineInputBorder(
          borderRadius: DesignConstants.radiusL,
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignConstants.radiusL,
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignConstants.radiusL,
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: DesignConstants.paddingM,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      onChanged: (text) {
        setState(() {
          _isComposing = text.trim().isNotEmpty;
        });
      },
      onSubmitted: (text) {
        if (_isComposing && !isLoading) {
          _sendMessage();
        }
      },
    );
  }

  Widget _buildSendButton(ThemeData theme, bool isLoading) {
    final canSend = _isComposing && !isLoading;

    return IconButton(
      onPressed: canSend ? _sendMessage : null,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            )
          : Icon(
              Icons.send_rounded,
              color: canSend
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
      style: IconButton.styleFrom(
        backgroundColor: canSend
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        foregroundColor: canSend
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusL,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(ThemeData theme, String error) {
    return Container(
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: theme.colorScheme.error,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // 清除错误（这里需要在notifier中添加清除错误的方法）
            },
            icon: Icon(
              Icons.close_rounded,
              size: 16,
              color: theme.colorScheme.error,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // TODO: 实现发送消息功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('发送功能开发中...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
    // ref.read(enhancedChatNotifierProvider.notifier).sendTextMessage(
    //   provider: widget.provider,
    //   assistant: widget.assistant,
    //   modelName: widget.modelName,
    //   userMessage: text,
    //   useStreaming: true,
    // );

    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    widget.onSendMessage?.call();
  }
}
