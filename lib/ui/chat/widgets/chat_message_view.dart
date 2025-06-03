import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../../models/message.dart';
import '../../../models/chat_bubble_style.dart';
import '../../../services/preference_service.dart';

/// 聊天消息显示组件
class ChatMessageView extends StatefulWidget {
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
  State<ChatMessageView> createState() => _ChatMessageViewState();
}

class _ChatMessageViewState extends State<ChatMessageView> {
  late final PreferenceService _preferenceService;
  ChatBubbleStyle _bubbleStyle = ChatBubbleStyle.list;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _preferenceService = PreferenceService();
    _loadBubbleStyle();
  }

  Future<void> _loadBubbleStyle() async {
    try {
      final styleValue = await _preferenceService.getChatBubbleStyle();
      if (mounted) {
        setState(() {
          _bubbleStyle = ChatBubbleStyle.fromValue(styleValue);
        });
      }
    } catch (e) {
      // 使用默认样式
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_bubbleStyle == ChatBubbleStyle.list) {
      return _buildListLayout(context, theme);
    } else {
      return _buildBubbleLayout(context, theme);
    }
  }

  /// 构建列表布局（无头像）
  Widget _buildListLayout(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 角色标识
          Text(
            widget.message.isFromUser ? "用户" : "AI助手",
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // 消息内容
          _buildMarkdownContent(context, theme, theme.colorScheme.onSurface),
          const SizedBox(height: 4),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 构建气泡布局
  Widget _buildBubbleLayout(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: widget.message.isFromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // 使用自定义的markdown支持气泡组件
          _buildMarkdownBubble(context, theme),

          // 操作按钮显示在气泡下方
          const SizedBox(height: 4),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // 准备按钮列表
    final List<Widget> actionButtons = [];

    // 复制按钮 - 始终显示
    actionButtons.add(
      _buildActionButton(
        context,
        icon: _isCopied ? Icons.check : Icons.copy,
        onPressed: () => _copyToClipboard(context),
        tooltip: _isCopied ? '已复制' : '复制',
      ),
    );

    // 编辑按钮 - 仅用户消息显示
    if (widget.onEdit != null && widget.message.isFromUser) {
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.edit,
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
          icon: Icons.refresh,
          onPressed: widget.onRegenerate,
          tooltip: '重新生成',
        ),
      );
    }

    if (actionButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: widget.message.isFromUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: actionButtons.map((button) {
        final isLast = button == actionButtons.last;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [button, if (!isLast) const SizedBox(width: 4)],
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // 移除背景色，让按钮更简洁
          backgroundColor: Colors.transparent,
          hoverColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          splashFactory: InkRipple.splashFactory,
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
  Widget _buildMarkdownBubble(BuildContext context, ThemeData theme) {
    final isFromUser = widget.message.isFromUser;
    final bubbleColor = isFromUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isFromUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isFromUser
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomRight: isFromUser
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
        ),
        child: _buildMarkdownContent(context, theme, textColor),
      ),
    );
  }

  /// 构建markdown内容
  Widget _buildMarkdownContent(
    BuildContext context,
    ThemeData theme,
    Color textColor,
  ) {
    // 检查消息内容是否包含markdown语法
    final hasMarkdown = _hasMarkdownSyntax(widget.message.content);

    if (!hasMarkdown) {
      // 如果没有markdown语法，直接使用普通文本
      return Text(
        widget.message.content,
        style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
      );
    }

    try {
      // 只有在确实需要时才使用markdown渲染
      final config = MarkdownConfig(
        configs: [
          PConfig(
            textStyle: TextStyle(color: textColor, fontSize: 16, height: 1.4),
          ),
        ],
      );

      return MarkdownBlock(data: widget.message.content, config: config);
    } catch (e) {
      // 如果markdown渲染失败，回退到普通文本
      return Text(
        widget.message.content,
        style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
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
}
