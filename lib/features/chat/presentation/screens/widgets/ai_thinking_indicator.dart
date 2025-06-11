import 'package:flutter/material.dart';

/// AI思考状态指示器
/// 用于显示AI正在处理请求时的视觉反馈
class AiThinkingIndicator extends StatefulWidget {
  const AiThinkingIndicator({
    super.key,
    this.isStreaming = false,
    this.message = 'AI正在思考中...',
  });

  /// 是否为流式响应
  final bool isStreaming;

  /// 显示的消息
  final String message;

  @override
  State<AiThinkingIndicator> createState() => _AiThinkingIndicatorState();
}

class _AiThinkingIndicatorState extends State<AiThinkingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 点点动画控制器
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _dotsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: Curves.easeInOut,
    ));

    // 启动动画
    _pulseController.repeat(reverse: true);
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32.0 : 20.0,
        vertical: 12.0,
      ),
      child: Row(
        children: [
          // AI图标和脉冲效果
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8 * _pulseAnimation.value,
                        spreadRadius: 2 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isStreaming ? Icons.auto_awesome : Icons.psychology,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // 思考消息和动态点点
          Expanded(
            child: Row(
              children: [
                Text(
                  widget.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4),
                // 动态点点效果
                AnimatedBuilder(
                  animation: _dotsAnimation,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final progress = (_dotsAnimation.value + delay) % 1.0;
                        final opacity = progress < 0.5 
                            ? progress * 2 
                            : (1.0 - progress) * 2;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Opacity(
                            opacity: opacity.clamp(0.3, 1.0),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),

          // 流式响应特有的波形指示器
          if (widget.isStreaming) ...[
            const SizedBox(width: 8),
            _buildWaveIndicator(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveIndicator(ThemeData theme) {
    return AnimatedBuilder(
      animation: _dotsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final delay = index * 0.2;
            final progress = (_dotsAnimation.value + delay) % 1.0;
            final height = 4 + (12 * (0.5 + 0.5 * (progress < 0.5 
                ? progress * 2 
                : (1.0 - progress) * 2)));
            
            return Container(
              width: 2,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }
}
