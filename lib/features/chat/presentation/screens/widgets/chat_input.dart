import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/message.dart';
import '../../../../ai_management/data/repositories/assistant_repository.dart';
import '../../../../../shared/infrastructure/services/database_service.dart';
import '../../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../../shared/infrastructure/services/preference_service.dart';
import '../../../../ai_management/domain/entities/ai_assistant.dart';
import '../../providers/chat_configuration_notifier.dart';
import 'model_selector.dart';
import 'attachment_panel.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

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
  });

  /// 初始消息（用于编辑）
  final Message? initialMessage;

  /// 是否自动聚焦
  final bool autofocus;

  /// 发送消息回调
  final void Function(String message)? onSendMessage;

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

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showAttachmentPanel = false;
  bool _isComposing = false;
  bool _isWebSearchEnabled = false;

  // 移除本地助手状态，使用 ChatConfigurationNotifier

  late AnimationController _animationController;

  // 数据仓库
  late final AssistantRepository _assistantRepository;
  late final PreferenceService _preferenceService;

  @override
  void initState() {
    super.initState();
    _assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    _preferenceService = PreferenceService();

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
      // 1. 优先使用传入的初始值
      if (widget.initialAssistantId != null &&
          widget.initialAssistantId!.isNotEmpty) {
        final assistant = await _assistantRepository.getAssistant(
          widget.initialAssistantId!,
        );
        if (assistant != null) {
          // 使用 ChatConfigurationNotifier 选择助手
          ref
              .read(chatConfigurationProvider.notifier)
              .selectAssistant(assistant);
          return;
        }
      }

      // 2. 尝试获取最后使用的助手ID
      final lastUsedAssistantId =
          await _preferenceService.getLastUsedAssistantId();
      if (lastUsedAssistantId != null) {
        final assistant = await _assistantRepository.getAssistant(
          lastUsedAssistantId,
        );
        if (assistant != null && assistant.isEnabled) {
          // 选择助手
          ref
              .read(chatConfigurationProvider.notifier)
              .selectAssistant(assistant);
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
      final assistants = await _assistantRepository.getEnabledAssistants();

      if (assistants.isNotEmpty) {
        // 选择助手
        ref
            .read(chatConfigurationProvider.notifier)
            .selectAssistant(assistants.first);
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
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showAttachmentPanel = false;
      });
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.onSendMessage != null) {
      widget.onSendMessage!(text);
      if (widget.initialMessage == null) {
        // 只有在非编辑模式下才清空输入框
        _textController.clear();
        setState(() {
          _isComposing = false;
        });
      }
    }
  }

  bool _canSend() {
    return _textController.text.trim().isNotEmpty && !widget.isLoading;
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

    await showModelSelector(
      context: context,
      preferenceService: _preferenceService,
      selectedProviderId: chatConfig.selectedProvider?.id,
      selectedModelName: chatConfig.selectedModel?.name,
      onModelSelected: (selection) {
        // 使用 ChatConfigurationNotifier 来选择模型
        ref.read(chatConfigurationProvider.notifier).selectModel(selection);

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

  void _handleCameraPressed() {
    setState(() {
      _showAttachmentPanel = false;
    });
    // TODO: 实现拍照功能
  }

  void _handlePhotoPressed() {
    setState(() {
      _showAttachmentPanel = false;
    });
    // TODO: 实现照片选择功能
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
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onChanged: (text) {
            setState(() {
              _isComposing = text.isNotEmpty;
            });
          },
          onSubmitted: _canSend() ? (_) => _handleSend() : null,
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
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isEditing) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceS,
        vertical: DesignConstants.spaceXS,
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
