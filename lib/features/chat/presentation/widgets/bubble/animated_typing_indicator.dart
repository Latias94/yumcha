import 'package:flutter/material.dart';

/// 动画打字指示器
/// 
/// 用于显示AI正在输入的动画效果，提供多种样式选择
class AnimatedTypingIndicator extends StatefulWidget {
  const AnimatedTypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 4.0,
    this.dotSpacing = 4.0,
    this.animationDuration = const Duration(milliseconds: 1400),
    this.style = TypingIndicatorStyle.dots,
  });

  /// 点的颜色
  final Color? dotColor;
  
  /// 点的大小
  final double dotSize;
  
  /// 点之间的间距
  final double dotSpacing;
  
  /// 动画持续时间
  final Duration animationDuration;
  
  /// 指示器样式
  final TypingIndicatorStyle style;

  @override
  State<AnimatedTypingIndicator> createState() => _AnimatedTypingIndicatorState();
}

class _AnimatedTypingIndicatorState extends State<AnimatedTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            (index * 0.2) + 0.6,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.dotColor ?? theme.colorScheme.primary;

    switch (widget.style) {
      case TypingIndicatorStyle.dots:
        return _buildDotsIndicator(color);
      case TypingIndicatorStyle.wave:
        return _buildWaveIndicator(color);
      case TypingIndicatorStyle.pulse:
        return _buildPulseIndicator(color);
      case TypingIndicatorStyle.typing:
        return _buildTypingIndicator(color);
    }
  }

  /// 构建点状指示器
  Widget _buildDotsIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(
                right: index < 2 ? widget.dotSpacing : 0,
              ),
              child: Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.3 + (_animations[index].value * 0.7),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// 构建波浪指示器
  Widget _buildWaveIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(
                right: index < 2 ? widget.dotSpacing : 0,
              ),
              child: Transform.translate(
                offset: Offset(0, -_animations[index].value * 4),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// 构建脉冲指示器
  Widget _buildPulseIndicator(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.dotSize * 3,
          height: widget.dotSize * 3,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3 + (_controller.value * 0.4)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建打字机指示器
  Widget _buildTypingIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.only(
                  right: index < 2 ? widget.dotSpacing / 2 : widget.dotSpacing,
                ),
                child: Container(
                  width: widget.dotSize / 2,
                  height: widget.dotSize * 2,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.2 + (_animations[index].value * 0.8),
                    ),
                    borderRadius: BorderRadius.circular(widget.dotSize / 4),
                  ),
                ),
              );
            },
          );
        }),
        // 闪烁光标
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedOpacity(
              opacity: (_controller.value * 2) % 2 > 1 ? 1.0 : 0.3,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 1.5,
                height: widget.dotSize * 2,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(0.75),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 打字指示器样式枚举
enum TypingIndicatorStyle {
  /// 点状动画
  dots,
  /// 波浪动画
  wave,
  /// 脉冲动画
  pulse,
  /// 打字机动画
  typing,
}

/// 增强的状态指示器组件
class EnhancedStatusIndicator extends StatelessWidget {
  const EnhancedStatusIndicator({
    super.key,
    required this.status,
    this.message,
    this.showProgress = false,
    this.progress,
  });

  /// 消息状态
  final String status;
  
  /// 状态消息
  final String? message;
  
  /// 是否显示进度
  final bool showProgress;
  
  /// 进度值 (0.0 - 1.0)
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(theme),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message ?? _getStatusMessage(status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(theme),
                ),
              ),
              if (showProgress && progress != null) ...[
                const SizedBox(height: 4),
                _buildProgressBar(theme),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'thinking':
        return AnimatedTypingIndicator(
          style: TypingIndicatorStyle.pulse,
          dotColor: theme.colorScheme.primary,
          dotSize: 3.0,
        );
      case 'streaming':
        return AnimatedTypingIndicator(
          style: TypingIndicatorStyle.typing,
          dotColor: theme.colorScheme.primary,
          dotSize: 3.0,
        );
      case 'processing':
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.secondary,
            ),
          ),
        );
      default:
        return Icon(
          Icons.autorenew,
          size: 12,
          color: theme.colorScheme.primary,
        );
    }
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Container(
      width: 60,
      height: 2,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: _getStatusColor(theme),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'thinking':
        return '正在思考...';
      case 'streaming':
        return '正在输入...';
      case 'processing':
        return '正在处理...';
      case 'tool_calling':
        return '调用工具...';
      default:
        return '正在生成...';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'thinking':
        return theme.colorScheme.primary;
      case 'streaming':
        return theme.colorScheme.primary;
      case 'processing':
        return theme.colorScheme.secondary;
      case 'tool_calling':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }
}
