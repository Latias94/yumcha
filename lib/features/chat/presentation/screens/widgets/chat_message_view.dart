import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/chat_bubble_style.dart';
import '../../providers/chat_style_provider.dart';
import 'thinking_process_widget.dart';
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

class _ChatMessageViewState extends ConsumerState<ChatMessageView> {
  bool _isCopied = false;

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
                _formatTimestamp(widget.message.timestamp),
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
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: DesignConstants.borderWidthThin,
              ),
              // 添加轻微阴影增强层次感
              boxShadow: DesignConstants.shadowXS(theme),
            ),
            child: _buildMarkdownContent(
              context,
              theme,
              theme.colorScheme.onSurface,
              content: thinkingResult.actualContent,
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
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: DesignConstants.borderWidthThin,
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
                          _formatTimestamp(widget.message.timestamp),
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
              _buildMarkdownContent(
                context,
                theme,
                theme.colorScheme.onSurface,
                content: thinkingResult.actualContent,
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
                _formatTimestamp(widget.message.timestamp),
                style: TextStyle(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],

          // 使用自定义的markdown支持气泡组件（显示处理后的实际内容）
          _buildMarkdownBubble(
            context,
            theme,
            content: thinkingResult.actualContent,
            maxWidth: maxWidth,
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
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
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
}
