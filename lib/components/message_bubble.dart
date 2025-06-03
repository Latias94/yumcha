import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;
  final bool showAvatar;
  final bool showAuthor;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.showAvatar = false,
    this.showAuthor = false,
    this.showTime = false,
  });

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isErrorMessage = message.content.startsWith('[错误]');
    final isSystemMessage = message.author == "系统";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isErrorMessage || isSystemMessage
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                isErrorMessage || isSystemMessage
                    ? Icons.error_outline
                    : Icons.smart_toy,
                color: isErrorMessage || isSystemMessage
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isFromUser && showAuthor)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      message.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isErrorMessage || isSystemMessage
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: message.isFromUser
                        ? Theme.of(context).colorScheme.primary
                        : isErrorMessage || isSystemMessage
                        ? Theme.of(
                            context,
                          ).colorScheme.errorContainer.withValues(alpha: 0.8)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: isErrorMessage || isSystemMessage
                        ? Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: _buildMessageContent(
                              context,
                              isErrorMessage,
                              isSystemMessage,
                            ),
                          ),
                          // 如果是流式输出，显示光标
                          if (isStreaming &&
                              !message.isFromUser &&
                              !isErrorMessage)
                            Container(
                              margin: const EdgeInsets.only(left: 2),
                              child: BlinkingCursor(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                        ],
                      ),
                      // 仅在showTime为true时显示时间
                      if (showTime) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: message.isFromUser
                                    ? Theme.of(context).colorScheme.onPrimary
                                          .withValues(alpha: 0.7)
                                    : isErrorMessage || isSystemMessage
                                    ? Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer
                                          .withValues(alpha: 0.7)
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isFromUser && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                message.author.isNotEmpty ? message.author[0] : 'U',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 构建消息内容，支持markdown渲染
  Widget _buildMessageContent(
    BuildContext context,
    bool isErrorMessage,
    bool isSystemMessage,
  ) {
    final content = _cleanErrorMessage(message.content);
    final theme = Theme.of(context);

    // 确定文本颜色
    final textColor = message.isFromUser
        ? theme.colorScheme.onPrimary
        : isErrorMessage || isSystemMessage
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurface;

    // 创建markdown配置
    final config = MarkdownConfig(
      configs: [
        // 段落配置
        PConfig(
          textStyle:
              theme.textTheme.bodyMedium?.copyWith(color: textColor) ??
              TextStyle(color: textColor),
        ),
        // 代码块配置
        PreConfig(
          textStyle:
              theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontFamily: 'monospace',
              ) ??
              TextStyle(color: textColor, fontFamily: 'monospace'),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
        ),
        // 行内代码配置
        CodeConfig(
          style:
              theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontFamily: 'monospace',
                backgroundColor: textColor.withValues(alpha: 0.1),
              ) ??
              TextStyle(
                color: textColor,
                fontFamily: 'monospace',
                backgroundColor: textColor.withValues(alpha: 0.1),
              ),
        ),
        // 标题配置
        H1Config(
          style:
              theme.textTheme.headlineLarge?.copyWith(color: textColor) ??
              TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        H2Config(
          style:
              theme.textTheme.headlineMedium?.copyWith(color: textColor) ??
              TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        H3Config(
          style:
              theme.textTheme.headlineSmall?.copyWith(color: textColor) ??
              TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        // 强调文本配置 - 注意：markdown_widget没有单独的StrongConfig和EmConfig
        // 这些样式会通过PConfig中的textStyle自动处理
        // 链接配置
        LinkConfig(
          style:
              theme.textTheme.bodyMedium?.copyWith(
                color: message.isFromUser
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                    : theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ) ??
              TextStyle(
                color: message.isFromUser
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                    : theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
        ),
        // 列表配置
        ListConfig(
          marker: (isOrdered, depth, index) {
            if (isOrdered) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  '${index + 1}.',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: textColor) ??
                      TextStyle(color: textColor),
                ),
              );
            } else {
              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 8, top: 8),
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              );
            }
          },
        ),
      ],
    );

    return MarkdownWidget(data: content, config: config, shrinkWrap: true);
  }

  // 清理错误消息，移除[错误]前缀
  String _cleanErrorMessage(String content) {
    if (content.startsWith('[错误] ')) {
      return content.substring(4); // 移除"[错误] "前缀
    }
    return content;
  }
}

class BlinkingCursor extends StatefulWidget {
  final Color color;

  const BlinkingCursor({super.key, required this.color});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(width: 2, height: 16, color: widget.color),
        );
      },
    );
  }
}
