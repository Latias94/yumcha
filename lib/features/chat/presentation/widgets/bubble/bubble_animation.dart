import 'package:flutter/material.dart';

/// 气泡动画类型枚举
enum BubbleAnimationType {
  /// 无动画
  none,

  /// 淡入
  fadeIn,

  /// 滑入
  slideIn,

  /// 缩放
  scale,

  /// 弹性
  bounce,

  /// 组合动画
  combined,
}

/// 气泡动画配置类
///
/// 管理气泡的出现、悬停、点击等动画效果
class BubbleAnimation {
  const BubbleAnimation({
    required this.type,
    required this.duration,
    required this.curve,
    this.delay = Duration.zero,
    this.enableHoverAnimation = true,
    this.enableTapAnimation = true,
  });

  /// 动画类型
  final BubbleAnimationType type;

  /// 动画持续时间
  final Duration duration;

  /// 动画曲线
  final Curve curve;

  /// 动画延迟
  final Duration delay;

  /// 是否启用悬停动画
  final bool enableHoverAnimation;

  /// 是否启用点击动画
  final bool enableTapAnimation;

  /// 创建标准动画
  factory BubbleAnimation.standard() {
    return const BubbleAnimation(
      type: BubbleAnimationType.fadeIn,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      delay: Duration(milliseconds: 50),
    );
  }

  /// 创建快速动画
  factory BubbleAnimation.fast() {
    return const BubbleAnimation(
      type: BubbleAnimationType.slideIn,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
      delay: Duration(milliseconds: 25),
    );
  }

  /// 创建慢速动画
  factory BubbleAnimation.slow() {
    return const BubbleAnimation(
      type: BubbleAnimationType.combined,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      delay: Duration(milliseconds: 100),
    );
  }

  /// 创建弹性动画
  factory BubbleAnimation.bouncy() {
    return const BubbleAnimation(
      type: BubbleAnimationType.bounce,
      duration: Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      delay: Duration(milliseconds: 75),
    );
  }

  /// 创建最小动画
  factory BubbleAnimation.minimal() {
    return const BubbleAnimation(
      type: BubbleAnimationType.fadeIn,
      duration: Duration(milliseconds: 150),
      curve: Curves.easeOut,
      delay: Duration.zero,
      enableHoverAnimation: false,
      enableTapAnimation: false,
    );
  }

  /// 创建无动画
  factory BubbleAnimation.none() {
    return const BubbleAnimation(
      type: BubbleAnimationType.none,
      duration: Duration.zero,
      curve: Curves.linear,
      delay: Duration.zero,
      enableHoverAnimation: false,
      enableTapAnimation: false,
    );
  }

  /// 复制并修改动画
  BubbleAnimation copyWith({
    BubbleAnimationType? type,
    Duration? duration,
    Curve? curve,
    Duration? delay,
    bool? enableHoverAnimation,
    bool? enableTapAnimation,
  }) {
    return BubbleAnimation(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      delay: delay ?? this.delay,
      enableHoverAnimation: enableHoverAnimation ?? this.enableHoverAnimation,
      enableTapAnimation: enableTapAnimation ?? this.enableTapAnimation,
    );
  }

  /// 是否有动画
  bool get hasAnimation =>
      type != BubbleAnimationType.none && duration > Duration.zero;

  /// 是否为淡入动画
  bool get isFadeIn => type == BubbleAnimationType.fadeIn;

  /// 是否为滑入动画
  bool get isSlideIn => type == BubbleAnimationType.slideIn;

  /// 是否为缩放动画
  bool get isScale => type == BubbleAnimationType.scale;

  /// 是否为弹性动画
  bool get isBounce => type == BubbleAnimationType.bounce;

  /// 是否为组合动画
  bool get isCombined => type == BubbleAnimationType.combined;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BubbleAnimation &&
        other.type == type &&
        other.duration == duration &&
        other.curve == curve &&
        other.delay == delay &&
        other.enableHoverAnimation == enableHoverAnimation &&
        other.enableTapAnimation == enableTapAnimation;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      duration,
      curve,
      delay,
      enableHoverAnimation,
      enableTapAnimation,
    );
  }

  @override
  String toString() {
    return 'BubbleAnimation(type: $type, duration: $duration, curve: $curve, ...)';
  }
}

/// 气泡动画包装器
///
/// 为气泡组件提供动画效果
class BubbleAnimationWrapper extends StatefulWidget {
  const BubbleAnimationWrapper({
    super.key,
    required this.child,
    required this.animation,
    this.isFromUser = false,
  });

  /// 子组件
  final Widget child;

  /// 动画配置
  final BubbleAnimation animation;

  /// 是否为用户消息
  final bool isFromUser;

  @override
  State<BubbleAnimationWrapper> createState() => _BubbleAnimationWrapperState();
}

class _BubbleAnimationWrapperState extends State<BubbleAnimationWrapper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animation.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animation.curve,
    ));

    final slideOffset =
        widget.isFromUser ? const Offset(0.3, 0.0) : const Offset(-0.3, 0.0);

    _slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animation.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animation.curve,
    ));
  }

  void _startAnimation() {
    if (widget.animation.hasAnimation) {
      Future.delayed(widget.animation.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animation.hasAnimation) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = widget.child;

        switch (widget.animation.type) {
          case BubbleAnimationType.none:
            break;
          case BubbleAnimationType.fadeIn:
            animatedChild = FadeTransition(
              opacity: _fadeAnimation,
              child: animatedChild,
            );
            break;
          case BubbleAnimationType.slideIn:
            animatedChild = SlideTransition(
              position: _slideAnimation,
              child: animatedChild,
            );
            break;
          case BubbleAnimationType.scale:
            animatedChild = ScaleTransition(
              scale: _scaleAnimation,
              child: animatedChild,
            );
            break;
          case BubbleAnimationType.bounce:
            animatedChild = ScaleTransition(
              scale: _scaleAnimation,
              child: animatedChild,
            );
            break;
          case BubbleAnimationType.combined:
            animatedChild = FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: animatedChild,
                ),
              ),
            );
            break;
        }

        return animatedChild;
      },
    );
  }
}
