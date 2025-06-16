import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/chat_message_content.dart';
import '../../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../../ai_management/domain/entities/ai_assistant.dart';
import '../../providers/unified_chat_notifier.dart';
import '../../widgets/chat_configuration_status.dart';
import 'model_selector.dart';
import 'attachment_panel.dart';
import 'attachment_manager.dart';
import 'attachment_chips.dart';
import 'attachment_preview_dialog.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';
import '../../../../../shared/infrastructure/services/image_service.dart';

/// 发送消息的 Intent
class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

/// 换行的 Intent
class NewLineIntent extends Intent {
  const NewLineIntent();
}

/// 聊天输入组件 - 重构版
class ChatInput extends ConsumerStatefulWidget {
  const ChatInput({
    super.key,
    this.initialMessage,
    this.autofocus = false,
    this.onSendMessage,
    this.onCancelMessage,
    this.onCancelEdit,
    this.isLoading = false,
    this.onAssistantChanged,
    this.initialAssistantId,
    this.onStartTyping,
  });

  /// 初始消息（用于编辑）
  final Message? initialMessage;

  /// 是否自动聚焦
  final bool autofocus;

  /// 发送消息回调（支持多种消息类型）
  final void Function(ChatMessageRequest request)? onSendMessage;

  /// 取消消息回调
  final VoidCallback? onCancelMessage;

  /// 取消编辑回调
  final VoidCallback? onCancelEdit;

  /// 是否正在加载
  final bool isLoading;

  /// 助手变化回调
  final void Function(AiAssistant assistant)? onAssistantChanged;

  /// 初始助手ID
  final String? initialAssistantId;

  /// 开始输入回调（用于清除错误状态）
  final VoidCallback? onStartTyping;

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showAttachmentPanel = false;
  AttachmentManagerState _attachmentState = const AttachmentManagerState();
  bool _isComposing = false;
  bool _isWebSearchEnabled = false;

  // 移除本地助手状态，使用 ChatConfigurationNotifier

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    // 如果有初始消息，设置文本内容
    if (widget.initialMessage != null) {
      _textController.text = widget.initialMessage!.content;
      _isComposing = _textController.text.trim().isNotEmpty;
    }

    // 初始化默认助手选择
    _initializeDefaultAssistant();
  }

  /// 初始化默认助手选择
  Future<void> _initializeDefaultAssistant() async {
    try {
      final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);
      final assistantRepository = ref.read(assistantRepositoryProvider);
      final preferenceService = ref.read(preferenceServiceProvider);

      // 1. 优先使用传入的初始值
      if (widget.initialAssistantId != null &&
          widget.initialAssistantId!.isNotEmpty) {
        final assistant = await assistantRepository.getAssistant(
          widget.initialAssistantId!,
        );
        if (assistant != null) {
          // 使用统一聊天状态管理选择助手
          await unifiedChatNotifier.selectAssistant(assistant);
          return;
        }
      }

      // 2. 尝试获取最后使用的助手ID
      final lastUsedAssistantId =
          await preferenceService.getLastUsedAssistantId();
      if (lastUsedAssistantId != null) {
        final assistant = await assistantRepository.getAssistant(
          lastUsedAssistantId,
        );
        if (assistant != null && assistant.isEnabled) {
          // 选择助手
          await unifiedChatNotifier.selectAssistant(assistant);
          return;
        }
      }

      // 3. 选择第一个可用的助手
      final success = await _selectFirstAvailableAssistant();
      if (!success) {
        // 如果没有可用的助手，通知用户
        if (mounted) {
          NotificationService().showError('没有可用的AI助手配置，请先在设置中配置助手');
        }
      }
    } catch (e) {
      // 初始化失败时通知用户
      if (mounted) {
        NotificationService().showError('助手初始化失败: $e');
      }
    }
  }

  /// 选择第一个可用的助手
  Future<bool> _selectFirstAvailableAssistant() async {
    try {
      final assistantRepository = ref.read(assistantRepositoryProvider);
      final assistants = await assistantRepository.getEnabledAssistants();

      if (assistants.isNotEmpty) {
        // 使用统一聊天状态管理选择助手
        final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);
        await unifiedChatNotifier.selectAssistant(assistants.first);
        return true;
      }
      return false;
    } catch (e) {
      // 静默处理错误
      return false;
    }
  }

  // 移除了旧的模型配置加载方法，现在使用 ChatConfigurationNotifier

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当初始消息改变时更新文本内容
    if (widget.initialMessage != oldWidget.initialMessage) {
      if (widget.initialMessage != null) {
        _textController.text = widget.initialMessage!.content;
      } else {
        _textController.clear();
      }
      _isComposing = _textController.text.trim().isNotEmpty;
    }

    // 当传入的助手改变时更新选择
    if (widget.initialAssistantId != oldWidget.initialAssistantId) {
      if (widget.initialAssistantId != null &&
          widget.initialAssistantId!.isNotEmpty) {
        _initializeDefaultAssistant();
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    final newIsComposing = text.isNotEmpty;

    if (newIsComposing != _isComposing) {
      setState(() {
        _isComposing = newIsComposing;
      });

      // 当用户开始输入时，清除错误状态
      if (newIsComposing && widget.onStartTyping != null) {
        widget.onStartTyping!();
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showAttachmentPanel = false;
      });
    }
  }

  /// 处理换行
  void _handleNewLine() {
    final currentText = _textController.text;
    final selection = _textController.selection;

    // 在当前光标位置插入换行符
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      '\n',
    );

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + 1,
      ),
    );
  }

  void _handleSend() {
    final text = _textController.text.trim();
    final hasText = text.isNotEmpty;
    final hasAttachments = _attachmentState.hasAttachments;

    if ((hasText || hasAttachments) && widget.onSendMessage != null) {
      // 检查配置状态
      final chatConfig = ref.read(chatConfigurationProvider);
      if (!chatConfig.isComplete) {
        // 显示配置问题对话框
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('无法发送消息'),
            content: const Text('聊天配置不完整，请检查助手和模型设置'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 导航到设置页面
                  Navigator.of(context).pushNamed('/settings');
                },
                child: const Text('去设置'),
              ),
            ],
          ),
        );
        return;
      }
      ChatMessageRequest request;

      if (hasAttachments && hasText) {
        // 混合消息：文本 + 附件
        final attachmentContents = _attachmentState.attachments.map((item) {
          if (item.isImage) {
            return ImageContent(
              data: item.data,
              mimeType: item.mimeType,
              fileName: item.fileName,
            );
          } else {
            return FileContent(
              data: item.data,
              fileName: item.fileName,
              mimeType: item.mimeType ?? 'application/octet-stream',
            );
          }
        }).toList();

        request = ChatMessageRequest.mixed(
          text: text,
          attachments: attachmentContents,
          strategy: MessageProcessingStrategy.multimodal,
        );
      } else if (hasAttachments) {
        // 仅附件
        if (_attachmentState.attachments.length == 1) {
          final item = _attachmentState.attachments.first;
          if (item.isImage) {
            request = ChatMessageRequest.image(
              item.data,
              mimeType: item.mimeType,
              fileName: item.fileName,
              strategy: MessageProcessingStrategy.multimodal,
            );
          } else {
            request = ChatMessageRequest.file(
              item.data,
              fileName: item.fileName,
              mimeType: item.mimeType ?? 'application/octet-stream',
              strategy: MessageProcessingStrategy.cloudUpload,
            );
          }
        } else {
          // 多个附件
          final attachmentContents = _attachmentState.attachments.map((item) {
            if (item.isImage) {
              return ImageContent(
                data: item.data,
                mimeType: item.mimeType,
                fileName: item.fileName,
              );
            } else {
              return FileContent(
                data: item.data,
                fileName: item.fileName,
                mimeType: item.mimeType ?? 'application/octet-stream',
              );
            }
          }).toList();

          request = ChatMessageRequest.mixed(
            attachments: attachmentContents,
            strategy: MessageProcessingStrategy.multimodal,
          );
        }
      } else {
        // 仅文本
        request = ChatMessageRequest.text(text);
      }

      widget.onSendMessage!(request);

      if (widget.initialMessage == null) {
        // 只有在非编辑模式下才清空输入框和附件
        _textController.clear();
        setState(() {
          _isComposing = false;
          _attachmentState = _attachmentState.clear();
        });
      }
    }
  }

  bool _canSend() {
    final hasText = _textController.text.trim().isNotEmpty;
    final hasAttachments = _attachmentState.hasAttachments;
    return (hasText || hasAttachments) && !widget.isLoading;
  }

  String _getInputHintText(bool isEditing) {
    if (widget.isLoading) {
      return 'AI正在思考中...';
    } else if (isEditing) {
      return '编辑消息...';
    } else {
      return '输入消息...';
    }
  }

  void _showModelSelector() async {
    final chatConfig = ref.read(chatConfigurationProvider);
    final preferenceService = ref.read(preferenceServiceProvider);

    await showModelSelector(
      context: context,
      preferenceService: preferenceService,
      selectedProviderId: chatConfig.selectedProvider?.id,
      selectedModelName: chatConfig.selectedModel?.name,
      onModelSelected: (selection) {
        // 使用统一聊天状态管理来选择模型
        // TODO: 实现模型选择功能
        // final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);
        // unifiedChatNotifier.selectModel(selection.provider, selection.model);

        // 通知父组件模型已改变
        final chatConfig = ref.read(chatConfigurationProvider);
        if (chatConfig.selectedAssistant != null) {
          widget.onAssistantChanged?.call(chatConfig.selectedAssistant!);
        }
      },
    );
  }

  void _handleAttachmentPanelToggle() {
    setState(() {
      _showAttachmentPanel = !_showAttachmentPanel;
    });
  }

  void _handleCameraPressed() async {
    setState(() {
      _showAttachmentPanel = false;
    });

    try {
      final result = await ImageService.pickFromCamera(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (result != null && mounted) {
        _handleImageSelected(result);
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('拍照失败: $e');
      }
    }
  }

  void _handlePhotoPressed() async {
    setState(() {
      _showAttachmentPanel = false;
    });

    try {
      final result = await ImageService.pickFromGallery(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (result != null && mounted) {
        _handleImageSelected(result);
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('选择照片失败: $e');
      }
    }
  }

  /// 处理选择的图片
  void _handleImageSelected(ImageResult imageResult) {
    // 添加到附件管理器
    final attachmentItem = AttachmentItem.fromImageResult(imageResult);
    setState(() {
      _attachmentState = _attachmentState.addAttachment(attachmentItem);
    });

    NotificationService().showSuccess('图片已添加到附件列表');
  }

  /// 移除附件
  void _handleRemoveAttachment(String attachmentId) {
    setState(() {
      _attachmentState = _attachmentState.removeAttachment(attachmentId);
    });
  }

  /// 切换附件面板展开状态
  void _handleToggleAttachmentExpanded() {
    setState(() {
      _attachmentState = _attachmentState.toggleExpanded();
    });
  }

  /// 预览附件
  void _handlePreviewAttachment(AttachmentItem attachment) {
    showDialog(
      context: context,
      builder: (context) => AttachmentPreviewDialog(
        attachment: attachment,
        onRemove: () => _handleRemoveAttachment(attachment.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialMessage != null;

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 编辑指示器
            if (isEditing) _buildEditingIndicator(context, theme),

            // 配置状态指示器（仅在非编辑模式显示）
            if (!isEditing) _buildConfigurationStatusIndicator(context, theme),

            // 附件标签（仅在非编辑模式且有附件时显示）
            if (!isEditing && _attachmentState.hasAttachments)
              AttachmentChips(
                state: _attachmentState,
                onToggleExpanded: _handleToggleAttachmentExpanded,
                onRemoveAttachment: _handleRemoveAttachment,
                onPreviewAttachment: _handlePreviewAttachment,
              ),

            // 输入框区域
            _buildInputField(theme, isEditing),

            // 功能按钮栏
            _buildActionButtons(theme, isEditing),

            // 附件面板（仅在非编辑模式显示）
            if (!isEditing) _buildAttachmentPanelContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingIndicator(BuildContext context, ThemeData theme) {
    return Container(
      margin: DesignConstants.responsiveHorizontalPadding(context).copyWith(
        top: DesignConstants.spaceS,
        bottom: 0,
      ),
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: DesignConstants.radiusS,
        boxShadow: DesignConstants.shadowS(theme),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: DesignConstants.iconSizeS,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Expanded(
            child: Text(
              '正在编辑消息',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationStatusIndicator(
      BuildContext context, ThemeData theme) {
    final chatConfig = ref.watch(chatConfigurationProvider);

    // 只在配置不完整时显示
    if (chatConfig.isComplete) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: DesignConstants.responsiveHorizontalPadding(context).copyWith(
        top: DesignConstants.spaceS,
        bottom: 0,
      ),
      child: ChatConfigurationStatus(
        compact: true,
        showDetails: false,
        onFixRequested: () {
          // 显示配置问题详情
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('配置问题'),
              content: const Text('聊天配置不完整，请检查助手和模型设置'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('知道了'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 导航到设置页面
                    Navigator.of(context).pushNamed('/settings');
                  },
                  child: const Text('去设置'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(ThemeData theme, bool isEditing) {
    return Padding(
      padding: DesignConstants.responsiveHorizontalPadding(context).copyWith(
        top: DesignConstants.spaceS,
        bottom: 0,
      ),
      child: Container(
        decoration: _focusNode.hasFocus
            ? theme.inputFocusDecoration
            : theme.inputDecoration,
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): const SendMessageIntent(),
            LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter): const NewLineIntent(),
          },
          child: Actions(
            actions: {
              SendMessageIntent: CallbackAction<SendMessageIntent>(
                onInvoke: (intent) {
                  if (_canSend()) {
                    _handleSend();
                  }
                  return null;
                },
              ),
              NewLineIntent: CallbackAction<NewLineIntent>(
                onInvoke: (intent) {
                  _handleNewLine();
                  return null;
                },
              ),
            },
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              // 移除 onSubmitted，因为我们现在使用快捷键处理
              onSubmitted: null,
              decoration: InputDecoration(
            hintText: _getInputHintText(isEditing),
            hintStyle: TextStyle(
              color: widget.isLoading
                  ? theme.colorScheme.primary.withValues(alpha: 0.7)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 15,
              fontStyle: widget.isLoading ? FontStyle.italic : FontStyle.normal,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceXL,
              vertical: DesignConstants.spaceM + 2,
            ),
            // 添加前缀图标来指示状态
            prefixIcon: widget.isLoading
                ? Padding(
                    padding: EdgeInsets.only(
                      left: DesignConstants.spaceM,
                      right: DesignConstants.spaceS,
                    ),
                    child: SizedBox(
                      width: DesignConstants.iconSizeS,
                      height: DesignConstants.iconSizeS,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 16,
            ),
              ),
              maxLines: DesignConstants.isDesktop(context) ? 5 : 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isEditing) {
    return Padding(
      padding: DesignConstants.responsiveHorizontalPadding(context).copyWith(
        top: DesignConstants.spaceXS,
        bottom: DesignConstants.spaceXS,
      ),
      child: Row(
        children: [
          // 添加按钮（仅在非编辑模式显示）
          if (!isEditing) ...[
            _buildAttachmentButton(theme),
            SizedBox(width: DesignConstants.spaceS),
            _buildModelSelectorButton(theme),
            SizedBox(width: DesignConstants.spaceS),
            _buildWebSearchButton(theme),
            SizedBox(width: DesignConstants.spaceS),
          ],

          // 编辑模式下的取消按钮
          if (isEditing && widget.onCancelEdit != null) ...[
            _buildCancelEditButton(theme),
            SizedBox(width: DesignConstants.spaceS),
          ],

          const Spacer(),

          // 根据状态显示不同的按钮
          if (widget.isLoading) ...[
            _buildStopButton(theme),
          ] else ...[
            _buildSendButton(theme, isEditing),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(ThemeData theme) {
    return SizedBox(
      width: DesignConstants.buttonHeightM,
      height: DesignConstants.buttonHeightM,
      child: IconButton(
        icon: Icon(
          _showAttachmentPanel ? Icons.close : Icons.add,
          size: DesignConstants.iconSizeM,
          color: _showAttachmentPanel
              ? theme.colorScheme.primary.withValues(alpha: 0.8)
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        onPressed: _handleAttachmentPanelToggle,
        tooltip: _showAttachmentPanel ? '关闭附件面板' : '打开附件面板',
      ),
    );
  }

  Widget _buildModelSelectorButton(ThemeData theme) {
    return SizedBox(
      width: DesignConstants.buttonHeightM,
      height: DesignConstants.buttonHeightM,
      child: IconButton(
        icon: Icon(
          Icons.auto_awesome,
          size: DesignConstants.iconSizeM,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        onPressed: _showModelSelector,
        tooltip: '选择AI模型',
      ),
    );
  }

  Widget _buildWebSearchButton(ThemeData theme) {
    return AnimatedContainer(
      duration: DesignConstants.animationNormal,
      curve: Curves.easeInOut,
      height: DesignConstants.buttonHeightS,
      constraints: BoxConstraints(
        minWidth: DesignConstants.buttonHeightM,
        maxWidth: _isWebSearchEnabled ? 130 : DesignConstants.buttonHeightM,
      ),
      decoration: BoxDecoration(
        color: _isWebSearchEnabled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.8)
            : Colors.transparent,
        borderRadius: DesignConstants.radiusL,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: DesignConstants.radiusL,
        child: InkWell(
          borderRadius: DesignConstants.radiusL,
          onTap: () {
            setState(() {
              _isWebSearchEnabled = !_isWebSearchEnabled;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceXS + 2,
              vertical: DesignConstants.spaceXS / 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.travel_explore,
                  size: DesignConstants.iconSizeM,
                  color: _isWebSearchEnabled
                      ? theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        )
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                ),
                if (_isWebSearchEnabled) ...[
                  SizedBox(width: DesignConstants.spaceXS + 2),
                  Flexible(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isWebSearchEnabled ? 1.0 : 0.0,
                      child: Text(
                        '使用网络搜索',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelEditButton(ThemeData theme) {
    return Container(
      width: DesignConstants.buttonHeightM,
      height: DesignConstants.buttonHeightM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: DesignConstants.shadowS(theme),
      ),
      child: IconButton(
        icon: Icon(
          Icons.close,
          size: DesignConstants.iconSizeM,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        onPressed: widget.onCancelEdit,
        tooltip: '取消编辑',
      ),
    );
  }

  Widget _buildStopButton(ThemeData theme) {
    return Container(
      width: DesignConstants.buttonHeightM,
      height: DesignConstants.buttonHeightM,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: DesignConstants.shadowS(theme),
      ),
      child: IconButton(
        onPressed: widget.onCancelMessage,
        icon: Icon(
          Icons.stop,
          size: DesignConstants.iconSizeM,
          color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.8),
        ),
        tooltip: '停止生成',
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme, bool isEditing) {
    return Container(
      width: DesignConstants.buttonHeightM,
      height: DesignConstants.buttonHeightM,
      decoration: BoxDecoration(
        color: _canSend()
            ? theme.colorScheme.primary.withValues(alpha: 0.9)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: _canSend()
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: _canSend()
            ? DesignConstants.shadowButton(theme)
            : DesignConstants.shadowNone,
      ),
      child: IconButton(
        icon: Icon(
          isEditing ? Icons.check : Icons.arrow_upward,
          size: DesignConstants.iconSizeM,
          color: _canSend()
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.9)
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        onPressed: _canSend() ? _handleSend : null,
        tooltip: isEditing ? '确认编辑' : '发送消息',
      ),
    );
  }

  Widget _buildAttachmentPanelContainer() {
    return AnimatedSize(
      duration: DesignConstants.animationNormal,
      curve: Curves.easeOutCubic,
      child: _showAttachmentPanel
          ? AttachmentPanel(
              onCameraPressed: _handleCameraPressed,
              onPhotoPressed: _handlePhotoPressed,
            )
          : const SizedBox.shrink(),
    );
  }
}

/// 图片预览对话框
class _ImagePreviewDialog extends StatefulWidget {
  const _ImagePreviewDialog({
    required this.imageResult,
    required this.onSend,
  });

  final ImageResult imageResult;
  final void Function(String prompt) onSend;

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              DesignConstants.isDesktop(context) ? 500 : screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: DesignConstants.paddingM,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  Expanded(
                    child: Text(
                      '图片预览',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 图片预览
            Flexible(
              child: Container(
                padding: DesignConstants.paddingM,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 图片
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height * 0.4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: DesignConstants.radiusM,
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: DesignConstants.radiusM,
                        child: Image.memory(
                          widget.imageResult.bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: DesignConstants.spaceM),

                    // 图片信息
                    Container(
                      padding: DesignConstants.paddingS,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: DesignConstants.radiusS,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: DesignConstants.iconSizeS,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: DesignConstants.spaceXS),
                          Expanded(
                            child: Text(
                              '${widget.imageResult.name} • ${widget.imageResult.formattedSize}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: DesignConstants.spaceM),

                    // 提示词输入
                    TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: '描述你想让AI分析的内容（可选）',
                        border: OutlineInputBorder(
                          borderRadius: DesignConstants.radiusM,
                        ),
                        contentPadding: DesignConstants.paddingM,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ],
                ),
              ),
            ),

            // 操作按钮
            Container(
              padding: DesignConstants.paddingM,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onSend(_promptController.text.trim());
                      },
                      child: const Text('发送'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
