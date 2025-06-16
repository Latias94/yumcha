import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_status.dart';
import '../../../domain/entities/message_block.dart';
import '../../../domain/entities/message_block_type.dart';
import '../../../domain/entities/enhanced_message.dart';
import '../../../domain/entities/chat_bubble_style.dart';
import '../../providers/chat_style_provider.dart';
import 'thinking_process_widget.dart';
import 'media/media_content_widget.dart';
import 'media/image_display_widget.dart';
import '../../../../../shared/infrastructure/services/media/media_storage_service.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 聊天消息显示组件
class ChatMessageView extends ConsumerStatefulWidget {
  const ChatMessageView({
    super.key,
    required this.message,
    this.onEdit,
    this.onRegenerate,
    this.isWelcomeMessage = false,
  });

  /// 消息对象
  final Message message;

  /// 编辑消息回调
  final VoidCallback? onEdit;

  /// 重新生成消息回调
  final VoidCallback? onRegenerate;

  /// 是否为欢迎消息
  final bool isWelcomeMessage;

  @override
  ConsumerState<ChatMessageView> createState() => _ChatMessageViewState();
}

class _ChatMessageViewState extends ConsumerState<ChatMessageView>
    with TickerProviderStateMixin {
  bool _isCopied = false;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化闪烁动画控制器
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    // 如果是流式消息，启动闪烁动画
    if (widget.message.status == MessageStatus.aiProcessing) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ChatMessageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 监听消息状态变化
    if (widget.message.status == MessageStatus.aiProcessing &&
        oldWidget.message.status != MessageStatus.aiProcessing) {
      _blinkController.repeat(reverse: true);
    } else if (widget.message.status != MessageStatus.aiProcessing &&
        oldWidget.message.status == MessageStatus.aiProcessing) {
      _blinkController.stop();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatStyle = ref.watch(currentChatStyleProvider);

    switch (chatStyle) {
      case ChatBubbleStyle.list:
        return _buildListLayout(context, theme);
      case ChatBubbleStyle.card:
        return _buildCardLayout(context, theme);
      case ChatBubbleStyle.bubble:
        return _buildBubbleLayout(context, theme);
    }
  }

  /// 构建列表布局（无头像）
  Widget _buildListLayout(BuildContext context, ThemeData theme) {
    // 解析思考过程
    final thinkingResult = ThinkingProcessParser.parseMessage(
      widget.message.content,
    );

    return Container(
      margin: AdaptiveSpacing.getMessagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 角色标识和时间戳
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignConstants.spaceS,
                  vertical: DesignConstants.spaceXS / 2,
                ),
                decoration: BoxDecoration(
                  color: widget.message.isFromUser
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3)
                      : theme.colorScheme.secondaryContainer
                          .withValues(alpha: 0.3),
                  borderRadius: DesignConstants.radiusM,
                ),
                child: Text(
                  widget.message.isFromUser ? "用户" : "AI助手",
                  style: TextStyle(
                    color: widget.message.isFromUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: DesignConstants.spaceS),
              Text(
                _formatTimestamp(widget.message.createdAt),
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceM),

          // 思考过程（仅AI消息且包含思考过程时显示）
          if (!widget.message.isFromUser &&
              thinkingResult.hasThinkingProcess) ...[
            ThinkingProcessWidget(
              thinkingContent: thinkingResult.thinkingContent,
              duration: widget.message.thinkingDuration ??
                  widget.message.totalDuration,
            ),
            SizedBox(height: DesignConstants.spaceM),
          ],

          // 消息内容容器 - 智能主题适配
          Container(
            width: double.infinity,
            padding: AdaptiveSpacing.getCardPadding(context),
            decoration: BoxDecoration(
              // 根据主题智能选择背景色
              color: _getListStyleBackgroundColor(theme),
              borderRadius: DesignConstants.radiusM,
              border: Border.all(
                color: widget.message.isError
                    ? theme.colorScheme.error.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: widget.message.isError
                    ? DesignConstants.borderWidthThin * 2
                    : DesignConstants.borderWidthThin,
              ),
              // 添加轻微阴影增强层次感
              boxShadow: DesignConstants.shadowXS(theme),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarkdownContent(
                  context,
                  theme,
                  theme.colorScheme.onSurface,
                  content: thinkingResult.actualContent,
                ),

                // 错误信息显示
                if (widget.message.isError && widget.message.metadata?['errorInfo'] != null)
                  _buildErrorInfo(context, theme),

                // 流式状态指示器
                if (widget.message.status == MessageStatus.aiProcessing)
                  _buildStreamingIndicator(context, theme),
              ],
            ),
          ),
          SizedBox(height: DesignConstants.spaceS),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 构建现代卡片布局
  Widget _buildCardLayout(BuildContext context, ThemeData theme) {
    // 解析思考过程
    final thinkingResult = ThinkingProcessParser.parseMessage(
      widget.message.content,
    );

    final isDesktop = DesignConstants.isDesktop(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 0, // 移除水平margin，由父组件ChatHistoryView控制
        vertical: isDesktop ? DesignConstants.spaceL : DesignConstants.spaceM,
      ),
      child: Card(
        elevation: isDesktop ? 2 : 1,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusL,
          side: BorderSide(
            color: widget.message.isError
                ? theme.colorScheme.error.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: widget.message.isError
                ? DesignConstants.borderWidthThin * 2
                : DesignConstants.borderWidthThin,
          ),
        ),
        child: Padding(
          padding: isDesktop
              ? DesignConstants.paddingXXL
              : DesignConstants.paddingXL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息：角色、时间戳和操作按钮
              Row(
                children: [
                  // 角色头像
                  Container(
                    width: isDesktop
                        ? DesignConstants.iconSizeXXL
                        : DesignConstants.iconSizeXL,
                    height: isDesktop
                        ? DesignConstants.iconSizeXXL
                        : DesignConstants.iconSizeXL,
                    decoration: BoxDecoration(
                      color: widget.message.isFromUser
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: DesignConstants.radiusXL,
                    ),
                    child: Icon(
                      widget.message.isFromUser
                          ? Icons.person_rounded
                          : Icons.smart_toy_rounded,
                      color: widget.message.isFromUser
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSecondaryContainer,
                      size: isDesktop
                          ? DesignConstants.iconSizeM
                          : DesignConstants.iconSizeS + 2,
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceM),

                  // 角色名称和时间
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.isFromUser ? "用户" : "AI助手",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: DesignConstants.getResponsiveFontSize(
                                context,
                                mobile: 15,
                                desktop: 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTimestamp(widget.message.createdAt),
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                            fontSize: DesignConstants.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                desktop: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 操作按钮
                  _buildActionButtons(context),
                ],
              ),

              SizedBox(height: DesignConstants.spaceL),

              // 思考过程（仅AI消息且包含思考过程时显示）
              if (!widget.message.isFromUser &&
                  thinkingResult.hasThinkingProcess) ...[
                ThinkingProcessWidget(
                  thinkingContent: thinkingResult.thinkingContent,
                  duration: widget.message.thinkingDuration ??
                      widget.message.totalDuration,
                ),
                SizedBox(height: DesignConstants.spaceL),
              ],

              // 消息内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMarkdownContent(
                    context,
                    theme,
                    theme.colorScheme.onSurface,
                    content: thinkingResult.actualContent,
                  ),

                  // 多媒体内容显示（块化消息）
                  if (widget.message.hasImages) ...[
                    SizedBox(height: DesignConstants.spaceM),
                    _buildImageBlocks(context, theme, compact: false),
                  ],

                  // 文件内容显示（块化消息）
                  if (_hasFileBlocks()) ...[
                    SizedBox(height: DesignConstants.spaceM),
                    _buildFileBlocks(context, theme),
                  ],

                  // 兼容性：多媒体内容显示（EnhancedMessage）
                  if (widget.message is EnhancedMessage) ...[
                    SizedBox(height: DesignConstants.spaceM),
                    MediaContentWidget(
                      message: widget.message as EnhancedMessage,
                      compact: false,
                      onImageTap: _handleImageTap,
                      onAudioTap: _handleAudioTap,
                    ),
                  ],

                  // 错误信息显示
                  if (widget.message.isError && widget.message.metadata?['errorInfo'] != null)
                    _buildErrorInfo(context, theme),

                  // 流式状态指示器
                  if (widget.message.status == MessageStatus.aiProcessing)
                    _buildStreamingIndicator(context, theme),

                  // Token使用信息显示（仅AI消息）
                  if (!widget.message.isFromUser && widget.message.metadata?['tokenUsage'] != null)
                    _buildTokenInfo(context, theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建气泡布局
  Widget _buildBubbleLayout(BuildContext context, ThemeData theme) {
    // 解析思考过程
    final thinkingResult = ThinkingProcessParser.parseMessage(
      widget.message.content,
    );

    final isDesktop = DesignConstants.isDesktop(context);
    final maxWidth = DesignConstants.getResponsiveMaxWidth(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0, // 移除水平padding，由父组件ChatHistoryView控制
        vertical: DesignConstants.spaceXS + 2,
      ),
      child: Column(
        crossAxisAlignment: widget.message.isFromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // 思考过程（仅AI消息且包含思考过程时显示）
          if (!widget.message.isFromUser &&
              thinkingResult.hasThinkingProcess) ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * maxWidth,
              ),
              child: ThinkingProcessWidget(
                thinkingContent: thinkingResult.thinkingContent,
                duration: widget.message.thinkingDuration ??
                    widget.message.totalDuration,
              ),
            ),
            SizedBox(height: DesignConstants.spaceS),
          ],

          // 时间戳（在气泡上方）
          if (isDesktop) ...[
            Padding(
              padding: EdgeInsets.only(bottom: DesignConstants.spaceXS),
              child: Text(
                _formatTimestamp(widget.message.createdAt),
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],

          // 使用自定义的markdown支持气泡组件（显示处理后的实际内容）
          Column(
            crossAxisAlignment: widget.message.isFromUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _buildMarkdownBubble(
                context,
                theme,
                content: thinkingResult.actualContent,
                maxWidth: maxWidth,
              ),

              // 多媒体内容显示（在气泡下方）- 块化消息
              if (widget.message.hasImages) ...[
                SizedBox(height: DesignConstants.spaceS),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * maxWidth,
                  ),
                  child: _buildImageBlocks(context, theme, compact: true),
                ),
              ],

              // 文件内容显示（在气泡下方）- 块化消息
              if (_hasFileBlocks()) ...[
                SizedBox(height: DesignConstants.spaceS),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * maxWidth,
                  ),
                  child: _buildFileBlocks(context, theme),
                ),
              ],

              // 兼容性：多媒体内容显示（在气泡下方）- EnhancedMessage
              if (widget.message is EnhancedMessage) ...[
                SizedBox(height: DesignConstants.spaceS),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * maxWidth,
                  ),
                  child: MediaContentWidget(
                    message: widget.message as EnhancedMessage,
                    compact: true,
                    onImageTap: _handleImageTap,
                    onAudioTap: _handleAudioTap,
                  ),
                ),
              ],

              // 错误信息显示（在气泡下方）
              if (widget.message.isError && widget.message.metadata?['errorInfo'] != null)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * maxWidth,
                  ),
                  child: _buildErrorInfo(context, theme),
                ),

              // 流式状态指示器（在气泡内部）
              if (widget.message.status == MessageStatus.aiProcessing)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * maxWidth,
                  ),
                  child: _buildStreamingIndicator(context, theme),
                ),

              // Token使用信息显示（仅AI消息，在气泡内部）
              if (!widget.message.isFromUser && widget.message.metadata?['tokenUsage'] != null)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * maxWidth,
                  ),
                  child: _buildTokenInfo(context, theme),
                ),
            ],
          ),

          // 操作按钮显示在气泡下方
          SizedBox(height: DesignConstants.spaceXS + 2),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    // 准备按钮列表
    final List<Widget> actionButtons = [];

    // 复制按钮 - 始终显示
    actionButtons.add(
      _buildActionButton(
        context,
        icon: _isCopied ? Icons.check_rounded : Icons.copy_rounded,
        onPressed: () => _copyToClipboard(context),
        tooltip: _isCopied ? '已复制' : '复制',
        isSuccess: _isCopied,
      ),
    );

    // 编辑按钮 - 仅用户消息显示
    if (widget.onEdit != null && widget.message.isFromUser) {
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.edit_rounded,
          onPressed: widget.onEdit,
          tooltip: '编辑',
        ),
      );
    }

    // AI消息的额外按钮
    if (!widget.message.isFromUser && widget.onRegenerate != null) {
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.refresh_rounded,
          onPressed: widget.onRegenerate,
          tooltip: '重新生成',
        ),
      );
    }

    if (actionButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignConstants.spaceXS),
      child: Row(
        mainAxisAlignment: widget.message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceXS,
              vertical: DesignConstants.spaceXS / 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.8),
              borderRadius: DesignConstants.radiusXL,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: DesignConstants.borderWidthThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actionButtons.map((button) {
                final isLast = button == actionButtons.last;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    button,
                    if (!isLast)
                      Container(
                        width: DesignConstants.borderWidthThin,
                        height: DesignConstants.spaceL,
                        margin: EdgeInsets.symmetric(
                            horizontal: DesignConstants.spaceXS),
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isSuccess = false,
  }) {
    final theme = Theme.of(context);
    final isDesktop = DesignConstants.isDesktop(context);

    return SizedBox(
      width: isDesktop
          ? DesignConstants.buttonHeightS
          : DesignConstants.buttonHeightS - 4,
      height: isDesktop
          ? DesignConstants.buttonHeightS
          : DesignConstants.buttonHeightS - 4,
      child: IconButton(
        icon: Icon(
          icon,
          size: isDesktop
              ? DesignConstants.iconSizeS
              : DesignConstants.iconSizeS - 2,
          color: isSuccess
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Colors.transparent,
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          splashFactory: InkRipple.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: DesignConstants.radiusL,
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.message.content));

    // 显示复制成功状态
    setState(() {
      _isCopied = true;
    });

    // 1.5秒后恢复原状态
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  /// 处理图片点击事件
  void _handleImageTap(MediaMetadata metadata, int index) {
    // 可以在这里实现图片预览功能
    // 例如：打开全屏图片查看器
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 关闭按钮
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
              // 图片显示
              Flexible(
                child: ImageDisplayWidget(
                  mediaMetadata: metadata,
                  fit: BoxFit.contain,
                ),
              ),
              // 图片信息
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  metadata.fileName,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理音频点击事件
  void _handleAudioTap(MediaMetadata metadata) {
    // 可以在这里实现音频相关操作
    // 例如：显示音频详情、下载等
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('音频文件: ${metadata.fileName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 构建支持markdown的气泡组件
  Widget _buildMarkdownBubble(
    BuildContext context,
    ThemeData theme, {
    String? content,
    double maxWidth = 0.8,
  }) {
    final isFromUser = widget.message.isFromUser;
    final isDesktop = DesignConstants.isDesktop(context);

    // 改进的颜色方案
    final bubbleColor = isFromUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final textColor =
        isFromUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    // 添加阴影和更好的视觉效果
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * maxWidth,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal:
              isDesktop ? DesignConstants.spaceXL : DesignConstants.spaceL,
          vertical: isDesktop ? DesignConstants.spaceL : DesignConstants.spaceM,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: DesignConstants.radiusXL.topLeft,
            topRight: DesignConstants.radiusXL.topRight,
            bottomLeft: isFromUser
                ? DesignConstants.radiusXL.bottomLeft
                : DesignConstants.radiusXS.bottomLeft,
            bottomRight: isFromUser
                ? DesignConstants.radiusXS.bottomRight
                : DesignConstants.radiusXL.bottomRight,
          ),
          border: widget.message.isError
              ? Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                  width: DesignConstants.borderWidthThin * 2,
                )
              : null,
          boxShadow: DesignConstants.shadowXS(theme),
        ),
        child: _buildMarkdownContent(
          context,
          theme,
          textColor,
          content: content,
        ),
      ),
    );
  }

  /// 构建markdown内容
  Widget _buildMarkdownContent(
    BuildContext context,
    ThemeData theme,
    Color textColor, {
    String? content,
  }) {
    // 使用传入的内容或默认的消息内容
    final messageContent = content ?? widget.message.content;
    final isDesktop = DesignConstants.isDesktop(context);

    // 检查消息内容是否包含markdown语法
    final hasMarkdown = _hasMarkdownSyntax(messageContent);

    if (!hasMarkdown) {
      // 如果没有markdown语法，直接使用普通文本
      return SelectableText(
        messageContent,
        style: TextStyle(
          color: textColor,
          fontSize: DesignConstants.getResponsiveFontSize(context,
              mobile: 15, desktop: 16),
          height: DesignConstants.getResponsiveLineHeight(context),
          letterSpacing: 0.1,
        ),
      );
    }

    try {
      // 改进的markdown配置
      final config = MarkdownConfig(
        configs: [
          PConfig(
            textStyle: TextStyle(
              color: textColor,
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 15, desktop: 16),
              height: DesignConstants.getResponsiveLineHeight(context),
              letterSpacing: 0.1,
            ),
          ),
          H1Config(
            style: TextStyle(
              color: textColor,
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 22, desktop: 24),
              fontWeight: FontWeight.bold,
              height: DesignConstants.getResponsiveLineHeight(context,
                  mobile: 1.3, desktop: 1.3),
            ),
          ),
          H2Config(
            style: TextStyle(
              color: textColor,
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 18, desktop: 20),
              fontWeight: FontWeight.bold,
              height: DesignConstants.getResponsiveLineHeight(context,
                  mobile: 1.3, desktop: 1.3),
            ),
          ),
          H3Config(
            style: TextStyle(
              color: textColor,
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 16, desktop: 18),
              fontWeight: FontWeight.w600,
              height: DesignConstants.getResponsiveLineHeight(context,
                  mobile: 1.3, desktop: 1.3),
            ),
          ),
          CodeConfig(
            style: TextStyle(
              color: textColor,
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 13, desktop: 14),
              fontFamily: 'monospace',
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
            ),
          ),
          PreConfig(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: DesignConstants.radiusS,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            padding:
                isDesktop ? DesignConstants.paddingL : DesignConstants.paddingM,
            textStyle: TextStyle(
              color: textColor,
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 13, desktop: 14),
              fontFamily: 'monospace',
              height: DesignConstants.getResponsiveLineHeight(context,
                  mobile: 1.4, desktop: 1.4),
            ),
          ),
        ],
      );

      return MarkdownBlock(data: messageContent, config: config);
    } catch (e) {
      // 如果markdown渲染失败，回退到普通文本
      return SelectableText(
        messageContent,
        style: TextStyle(
          color: textColor,
          fontSize: DesignConstants.getResponsiveFontSize(context,
              mobile: 15, desktop: 16),
          height: DesignConstants.getResponsiveLineHeight(context),
          letterSpacing: 0.1,
        ),
      );
    }
  }

  /// 检查文本是否包含markdown语法
  bool _hasMarkdownSyntax(String text) {
    // 检查常见的markdown语法
    final markdownPatterns = [
      RegExp(r'#{1,6}\s'), // 标题
      RegExp(r'\*\*.*\*\*'), // 粗体
      RegExp(r'\*.*\*'), // 斜体
      RegExp(r'`.*`'), // 行内代码
      RegExp(r'```'), // 代码块
      RegExp(r'\[.*\]\(.*\)'), // 链接
      RegExp(r'^[-*+]\s', multiLine: true), // 无序列表
      RegExp(r'^\d+\.\s', multiLine: true), // 有序列表
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = now.year == timestamp.year &&
                   now.month == timestamp.month &&
                   now.day == timestamp.day;

    final isThisYear = now.year == timestamp.year;

    // 格式化时间部分
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
                   '${timestamp.minute.toString().padLeft(2, '0')}';

    if (isToday) {
      return timeStr;
    } else if (isThisYear) {
      return '${timestamp.month.toString().padLeft(2, '0')}/'
             '${timestamp.day.toString().padLeft(2, '0')} $timeStr';
    } else {
      return '${timestamp.year}/'
             '${timestamp.month.toString().padLeft(2, '0')}/'
             '${timestamp.day.toString().padLeft(2, '0')} $timeStr';
    }
  }

  /// 构建流式状态指示器
  Widget _buildStreamingIndicator(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: DesignConstants.spaceS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 流式动画指示器
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
          SizedBox(width: DesignConstants.spaceXS),

          // 状态文本
          Text(
            widget.message.status.displayName,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),

          // 可选：添加闪烁的光标效果
          SizedBox(width: DesignConstants.spaceXS / 2),
          _buildBlinkingCursor(theme),
        ],
      ),
    );
  }

  /// 构建闪烁光标效果
  Widget _buildBlinkingCursor(ThemeData theme) {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _blinkAnimation.value,
          child: Text(
            '|',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// 获取列表样式的背景色 - 智能主题适配
  Color _getListStyleBackgroundColor(ThemeData theme) {
    final brightness = theme.brightness;
    final colorScheme = theme.colorScheme;

    // 根据亮暗模式和主题特性智能选择背景色
    if (brightness == Brightness.light) {
      // 浅色模式：使用最浅的表面容器色，确保良好的对比度
      return colorScheme.surfaceContainerLowest;
    } else {
      // 深色模式：使用稍微亮一点的表面容器色，避免过于暗淡
      return colorScheme.surfaceContainerLow;
    }
  }

  /// 构建错误信息显示组件
  Widget _buildErrorInfo(BuildContext context, ThemeData theme) {
    final isDesktop = DesignConstants.isDesktop(context);

    return Container(
      margin: EdgeInsets.only(top: DesignConstants.spaceS),
      padding: EdgeInsets.all(
        isDesktop ? DesignConstants.spaceM : DesignConstants.spaceS,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 错误图标
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: isDesktop ? DesignConstants.iconSizeS : 14,
          ),
          SizedBox(width: DesignConstants.spaceXS),

          // 错误信息文本
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '发生错误',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      desktop: 13,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: DesignConstants.spaceXS / 2),
                Text(
                  widget.message.metadata?['errorInfo'] as String? ?? '未知错误',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 11,
                      desktop: 12,
                    ),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建Token使用信息显示
  Widget _buildTokenInfo(BuildContext context, ThemeData theme) {
    final tokenUsageData = widget.message.metadata?['tokenUsage'] as Map<String, dynamic>?;
    if (tokenUsageData == null) return const SizedBox.shrink();

    // 构建Token信息文本
    final List<String> tokenParts = [];

    // 总Token数
    final totalTokens = tokenUsageData['totalTokens'] as int?;
    if (totalTokens != null) {
      tokenParts.add('Tokens:$totalTokens');
    }

    // 输入Token数（用上箭头表示）
    final promptTokens = tokenUsageData['promptTokens'] as int?;
    if (promptTokens != null) {
      tokenParts.add('↑$promptTokens');
    }

    // 输出Token数（用下箭头表示）
    final completionTokens = tokenUsageData['completionTokens'] as int?;
    if (completionTokens != null) {
      tokenParts.add('↓$completionTokens');
    }

    // 推理Token数（如果有）
    final reasoningTokens = tokenUsageData['reasoningTokens'] as int?;
    if (reasoningTokens != null && reasoningTokens > 0) {
      tokenParts.add('🧠$reasoningTokens');
    }

    if (tokenParts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: DesignConstants.spaceS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          SizedBox(width: DesignConstants.spaceXS),
          Text(
            tokenParts.join(' '),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// 检查是否有文件块
  bool _hasFileBlocks() {
    return widget.message.blocks.any((block) => block.type == MessageBlockType.file);
  }

  /// 构建图片块
  Widget _buildImageBlocks(BuildContext context, ThemeData theme, {required bool compact}) {
    final imageBlocks = widget.message.imageBlocks;
    if (imageBlocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: imageBlocks.map((block) {
        return Container(
          margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
          child: _buildImageBlock(context, theme, block, compact: compact),
        );
      }).toList(),
    );
  }

  /// 构建单个图片块
  Widget _buildImageBlock(BuildContext context, ThemeData theme, MessageBlock block, {required bool compact}) {
    if (block.url == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = compact ? screenWidth * 0.5 : screenWidth * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: compact ? 150 : 200,
      ),
      child: ClipRRect(
        borderRadius: DesignConstants.radiusM,
        child: Image.network(
          block.url!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: DesignConstants.radiusM,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.onErrorContainer,
                      size: DesignConstants.iconSizeM,
                    ),
                    SizedBox(height: DesignConstants.spaceXS),
                    Text(
                      '图片加载失败',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建文件块
  Widget _buildFileBlocks(BuildContext context, ThemeData theme) {
    final fileBlocks = widget.message.blocks.where((block) => block.type == MessageBlockType.file).toList();
    if (fileBlocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fileBlocks.map((block) {
        return Container(
          margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
          child: _buildFileBlock(context, theme, block),
        );
      }).toList(),
    );
  }

  /// 构建单个文件块
  Widget _buildFileBlock(BuildContext context, ThemeData theme, MessageBlock block) {
    final fileName = block.metadata?['fileName'] as String? ?? '未知文件';
    final fileSize = block.metadata?['sizeBytes'] as int?;
    final mimeType = block.metadata?['mimeType'] as String?;

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(mimeType),
            color: theme.colorScheme.primary,
            size: DesignConstants.iconSizeM,
          ),
          SizedBox(width: DesignConstants.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null) ...[
                  SizedBox(height: DesignConstants.spaceXS),
                  Text(
                    _formatFileSize(fileSize),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (block.url != null)
            IconButton(
              onPressed: () => _handleFileTap(block),
              icon: Icon(
                Icons.download_rounded,
                color: theme.colorScheme.primary,
                size: DesignConstants.iconSizeS,
              ),
              tooltip: '下载文件',
            ),
        ],
      ),
    );
  }

  /// 获取文件图标
  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file_outlined;

    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.startsWith('audio/')) return Icons.audio_file_outlined;
    if (mimeType.startsWith('video/')) return Icons.video_file_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('text/')) return Icons.text_snippet_outlined;

    return Icons.insert_drive_file_outlined;
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 处理文件点击
  void _handleFileTap(MessageBlock block) {
    // TODO: 实现文件下载或打开逻辑
    if (block.url != null) {
      // 可以使用 url_launcher 打开文件
      debugPrint('打开文件: ${block.url}');
    }
  }
}
