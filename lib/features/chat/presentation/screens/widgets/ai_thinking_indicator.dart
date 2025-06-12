import 'package:flutter/material.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

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
      duration: DesignConstants.animationVerySlow * 2.5, // 1500ms = 600ms * 2.5
      vsync: this,
    );

    // 点点动画控制器
    _dotsController = AnimationController(
      duration: DesignConstants.animationVerySlow * 2, // 1200ms = 600ms * 2
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: DesignConstants.curveStandard,
    ));

    _dotsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: DesignConstants.curveStandard,
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
        horizontal:
            isDesktop ? DesignConstants.spaceXXL : DesignConstants.spaceXL,
        vertical: DesignConstants.spaceM,
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
                  width: DesignConstants.iconSizeXL,
                  height: DesignConstants.iconSizeXL,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: DesignConstants.opacityHigh),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                            alpha: DesignConstants.opacityMedium * 0.5), // 0.3
                        blurRadius:
                            DesignConstants.spaceS * _pulseAnimation.value,
                        spreadRadius:
                            DesignConstants.spaceXS / 2 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isStreaming ? Icons.auto_awesome : Icons.psychology,
                    size: DesignConstants.iconSizeS + 2, // 18px
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              );
            },
          ),

          SizedBox(width: DesignConstants.spaceM),

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
                SizedBox(width: DesignConstants.spaceXS),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: DesignConstants.spaceXS / 4), // 1px
                          child: Opacity(
                            opacity: opacity.clamp(0.3, 1.0),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: DesignConstants.getResponsiveFontSize(
                                    context),
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
            SizedBox(width: DesignConstants.spaceS),
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
            final height = DesignConstants.spaceXS +
                (DesignConstants.spaceM *
                    (0.5 +
                        0.5 *
                            (progress < 0.5
                                ? progress * 2
                                : (1.0 - progress) * 2)));

            return Container(
              width: DesignConstants.spaceXS / 2, // 2px
              height: height,
              margin: EdgeInsets.symmetric(
                  horizontal: DesignConstants.spaceXS / 4), // 1px
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                    alpha: DesignConstants.opacityMedium + 0.1), // 0.7
                borderRadius:
                    BorderRadius.circular(DesignConstants.spaceXS / 4), // 1px
              ),
            );
          }),
        );
      },
    );
  }
}
