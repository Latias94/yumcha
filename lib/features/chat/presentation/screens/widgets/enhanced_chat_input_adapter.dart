import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';
import '../../../../../features/settings/presentation/providers/multimedia_settings_notifier.dart';
import '../../providers/unified_chat_notifier.dart';

/// 增强聊天输入适配器
/// 
/// 这个组件可以替换现有的聊天输入框，提供多媒体功能的开关，
/// 同时保持与现有聊天系统的完全兼容性。
/// 
/// ## 使用方式
/// 
/// ```dart
/// // 在现有的聊天界面中，将原来的输入框替换为：
/// EnhancedChatInputAdapter(
///   conversationId: widget.conversationId,
///   onSendMessage: (content) {
///     // 现有的发送逻辑
///   },
/// )
/// ```
class EnhancedChatInputAdapter extends ConsumerStatefulWidget {
  const EnhancedChatInputAdapter({
    super.key,
    required this.conversationId,
    this.onSendMessage,
    this.enabled = true,
  });

  final String conversationId;
  final Function(String content)? onSendMessage;
  final bool enabled;

  @override
  ConsumerState<EnhancedChatInputAdapter> createState() => _EnhancedChatInputAdapterState();
}

class _EnhancedChatInputAdapterState extends ConsumerState<EnhancedChatInputAdapter> {
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
    final multimediaEnabled = ref.watch(isMultimediaEnabledProvider);

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
          // 多媒体功能控制面板
          if (multimediaEnabled) ...[
            _buildMultimediaControls(theme),
            SizedBox(height: DesignConstants.spaceM),
          ],

          // 主输入区域
          Row(
            children: [
              // 多媒体开关按钮
              _buildMultimediaToggle(theme),
              SizedBox(width: DesignConstants.spaceS),

              // 文本输入框
              Expanded(
                child: _buildTextInput(theme),
              ),

              SizedBox(width: DesignConstants.spaceS),

              // 发送按钮
              _buildSendButton(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultimediaControls(ThemeData theme) {
    final autoDetect = ref.watch(multimediaSettingsProvider).autoDetectEnabled;

    return Container(
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
            '🎨 多媒体功能已启用',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),

          // 自动检测开关
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '智能检测',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 11,
                ),
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Switch(
                value: autoDetect,
                onChanged: (value) {
                  ref.read(multimediaSettingsProvider.notifier).setAutoDetectEnabled(value);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultimediaToggle(ThemeData theme) {
    final multimediaEnabled = ref.watch(isMultimediaEnabledProvider);

    return IconButton(
      onPressed: () {
        ref.read(multimediaSettingsProvider.notifier).setMultimediaEnabled(!multimediaEnabled);
        
        // 显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              multimediaEnabled ? '多媒体功能已关闭' : '多媒体功能已开启',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(
        multimediaEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
        color: multimediaEnabled 
            ? theme.colorScheme.primary 
            : theme.colorScheme.onSurfaceVariant,
      ),
      tooltip: multimediaEnabled ? '关闭多媒体功能' : '开启多媒体功能',
      style: IconButton.styleFrom(
        backgroundColor: multimediaEnabled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
      ),
    );
  }

  Widget _buildTextInput(ThemeData theme) {
    final multimediaEnabled = ref.watch(isMultimediaEnabledProvider);
    final autoDetect = ref.watch(multimediaSettingsProvider).autoDetectEnabled;

    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: widget.enabled,
      maxLines: null,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: multimediaEnabled 
            ? (autoDetect ? '输入消息，支持智能图片生成...' : '输入消息，多媒体功能已启用...')
            : '输入消息...',
        border: OutlineInputBorder(
          borderRadius: DesignConstants.radiusL,
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignConstants.radiusL,
          borderSide: BorderSide(
            color: multimediaEnabled
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
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
        fillColor: multimediaEnabled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      onChanged: (text) {
        setState(() {
          _isComposing = text.trim().isNotEmpty;
        });
      },
      onSubmitted: (text) {
        if (_isComposing && widget.enabled) {
          _sendMessage();
        }
      },
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    final canSend = _isComposing && widget.enabled;
    final multimediaEnabled = ref.watch(isMultimediaEnabledProvider);

    return IconButton(
      onPressed: canSend ? _sendMessage : null,
      icon: Icon(
        Icons.send_rounded,
        color: canSend
            ? (multimediaEnabled ? theme.colorScheme.primary : theme.colorScheme.primary)
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      style: IconButton.styleFrom(
        backgroundColor: canSend
            ? (multimediaEnabled 
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.primaryContainer)
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

  void _sendMessage() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    final multimediaEnabled = ref.read(isMultimediaEnabledProvider);
    final autoDetect = ref.read(multimediaSettingsProvider).autoDetectEnabled;
    final chatConfig = ref.read(chatConfigurationProvider);

    // 检查是否应该使用增强功能
    bool useEnhanced = false;
    
    if (multimediaEnabled) {
      if (autoDetect) {
        // 智能检测是否需要多媒体功能
        useEnhanced = _shouldUseEnhancedFeatures(content);
      } else {
        // 强制使用增强功能
        useEnhanced = true;
      }
    }

    // 清空输入框
    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    if (useEnhanced &&
        chatConfig.selectedProvider != null &&
        chatConfig.selectedAssistant != null &&
        chatConfig.selectedModel != null) {
      // 使用增强聊天功能
      _sendEnhancedMessage(content);
    } else {
      // 使用现有的聊天功能
      widget.onSendMessage?.call(content);
    }
  }

  /// 简单的智能检测逻辑
  bool _shouldUseEnhancedFeatures(String content) {
    // 检测图片生成关键词
    final imageKeywords = ['画', '绘制', '生成图片', '创建图像', '制作图片', 'draw', 'paint', 'create image'];
    final hasImageKeywords = imageKeywords.any((keyword) =>
        content.toLowerCase().contains(keyword.toLowerCase()));

    // 检测语音相关关键词
    final voiceKeywords = ['读出来', '朗读', '语音播放', 'read aloud', 'speak', 'voice'];
    final hasVoiceKeywords = voiceKeywords.any((keyword) =>
        content.toLowerCase().contains(keyword.toLowerCase()));

    // 检测长文本（可能需要TTS）
    final isLongText = content.length > 100;

    return hasImageKeywords || hasVoiceKeywords || isLongText;
  }

  void _sendEnhancedMessage(String content) async {
    try {
      final chatNotifier = ref.read(unifiedChatProvider.notifier);
      final chatConfig = ref.read(chatConfigurationProvider);

      // 检查配置是否完整
      if (chatConfig.selectedProvider == null ||
          chatConfig.selectedAssistant == null ||
          chatConfig.selectedModel == null) {
        _showError('聊天配置不完整，请检查AI提供商、助手和模型设置');
        return;
      }

      // 显示多媒体功能启用提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('🎨 使用多媒体增强功能发送消息'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 使用统一聊天系统发送消息，启用流式传输
      await chatNotifier.sendMessage(
        content,
        useStreaming: true, // 启用流式传输以获得更好的体验
      );

    } catch (e) {
      _showError('发送增强消息失败: $e');
      // 降级到普通聊天
      widget.onSendMessage?.call(content);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
