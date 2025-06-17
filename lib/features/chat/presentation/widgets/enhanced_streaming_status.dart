import 'package:flutter/material.dart';
import '../../domain/entities/message_status.dart';
import 'animated_typing_indicator.dart';

/// 增强的流式状态组件
///
/// 根据不同的消息状态显示相应的视觉指示器和文本
class EnhancedStreamingStatus extends StatelessWidget {
  const EnhancedStreamingStatus({
    super.key,
    required this.status,
    this.showText = true,
    this.compact = false,
    this.color,
  });

  /// 消息状态
  final MessageStatus status;

  /// 是否显示状态文本
  final bool showText;

  /// 是否使用紧凑模式
  final bool compact;

  /// 自定义颜色
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIndicator(context, effectiveColor),
          if (showText) ...[
            SizedBox(width: compact ? 6 : 8),
            _buildStatusText(context, effectiveColor),
          ],
        ],
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(BuildContext context, Color color) {
    final size = compact ? 12.0 : 16.0;

    switch (status) {
      case MessageStatus.aiPending:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: compact ? 1.5 : 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withValues(alpha: 0.7),
            ),
          ),
        );

      case MessageStatus.aiProcessing:
        return PulseTypingIndicator(
          color: color.withValues(alpha: 0.8),
          size: size,
        );

      case MessageStatus.aiStreaming:
        return AnimatedTypingIndicator(
          dotColor: color,
          dotSize: compact ? 3.0 : 4.0,
          dotSpacing: compact ? 2.0 : 3.0,
          animationDuration: const Duration(milliseconds: 500),
        );

      case MessageStatus.aiSuccess:
        return Icon(
          Icons.check_circle_outline,
          size: size,
          color: Theme.of(context).colorScheme.primary,
        );

      case MessageStatus.aiError:
        return Icon(
          Icons.error_outline,
          size: size,
          color: Theme.of(context).colorScheme.error,
        );

      case MessageStatus.aiPaused:
        return Icon(
          Icons.pause_circle_outline,
          size: size,
          color: Theme.of(context).colorScheme.secondary,
        );

      default:
        return SizedBox(width: size, height: size);
    }
  }

  /// 构建状态文本
  Widget _buildStatusText(BuildContext context, Color color) {
    final theme = Theme.of(context);
    final fontSize = compact ? 11.0 : 12.0;

    String text;
    Color textColor;

    switch (status) {
      case MessageStatus.aiPending:
        text = '准备中...';
        textColor = color;
        break;
      case MessageStatus.aiProcessing:
        text = '思考中...';
        textColor = color;
        break;
      case MessageStatus.aiStreaming:
        text = '输入中...';
        textColor = color;
        break;
      case MessageStatus.aiSuccess:
        text = '完成';
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case MessageStatus.aiError:
        text = '失败';
        textColor = theme.colorScheme.error;
        break;
      case MessageStatus.aiPaused:
        text = '暂停';
        textColor = theme.colorScheme.secondary;
        break;
      default:
        text = status.displayName;
        textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
      ),
    );
  }
}

/// 流式消息占位符组件
///
/// 在消息内容为空时显示的占位符，根据状态显示不同的内容
class StreamingMessagePlaceholder extends StatelessWidget {
  const StreamingMessagePlaceholder({
    super.key,
    required this.status,
    this.message,
    this.showProgress = false,
    this.progress,
  });

  /// 消息状态
  final MessageStatus status;

  /// 自定义消息文本
  final String? message;

  /// 是否显示进度
  final bool showProgress;

  /// 进度值 (0.0 - 1.0)
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              EnhancedStreamingStatus(
                status: status,
                compact: true,
              ),
              if (message != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message!,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (showProgress && progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 流式消息底部状态栏
///
/// 显示在消息底部的状态信息，包括耗时、字数等
class StreamingMessageFooter extends StatelessWidget {
  const StreamingMessageFooter({
    super.key,
    required this.status,
    this.duration,
    this.wordCount,
    this.showDetails = true,
  });

  /// 消息状态
  final MessageStatus status;

  /// 耗时
  final Duration? duration;

  /// 字数
  final int? wordCount;

  /// 是否显示详细信息
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!showDetails || !_shouldShowFooter()) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EnhancedStreamingStatus(
            status: status,
            showText: false,
            compact: true,
          ),
          const SizedBox(width: 6),
          ..._buildFooterInfo(context),
        ],
      ),
    );
  }

  bool _shouldShowFooter() {
    return status == MessageStatus.aiStreaming ||
        status == MessageStatus.aiSuccess ||
        duration != null ||
        wordCount != null;
  }

  List<Widget> _buildFooterInfo(BuildContext context) {
    final theme = Theme.of(context);
    final info = <Widget>[];

    if (duration != null) {
      info.add(Text(
        _formatDuration(duration!),
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ));
    }

    if (wordCount != null) {
      if (info.isNotEmpty) {
        info.add(Text(
          ' • ',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ));
      }
      info.add(Text(
        '$wordCount 字',
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ));
    }

    return info;
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }
}
