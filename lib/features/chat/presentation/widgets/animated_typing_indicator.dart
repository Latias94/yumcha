import 'package:flutter/material.dart';

/// 动画化的打字指示器组件
/// 
/// 用于显示AI正在输入的动画效果，提供更好的用户体验
class AnimatedTypingIndicator extends StatefulWidget {
  const AnimatedTypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 4.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.dotSpacing = 4.0,
  });

  /// 圆点颜色
  final Color? dotColor;

  /// 圆点大小
  final double dotSize;

  /// 动画持续时间
  final Duration animationDuration;

  /// 圆点间距
  final double dotSpacing;

  @override
  State<AnimatedTypingIndicator> createState() => _AnimatedTypingIndicatorState();
}

class _AnimatedTypingIndicatorState extends State<AnimatedTypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // 启动交错动画
    _startStaggeredAnimation();
  }

  void _startStaggeredAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) break;
        
        _controllers[i].forward();
        await Future.delayed(Duration(milliseconds: 200));
      }
      
      // 等待所有动画完成
      await Future.delayed(Duration(milliseconds: 400));
      
      // 重置所有动画
      for (var controller in _controllers) {
        if (mounted) {
          controller.reset();
        }
      }
      
      // 短暂暂停后重新开始
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.dotColor ?? theme.colorScheme.primary;

    return SizedBox(
      width: (widget.dotSize * 3) + (widget.dotSpacing * 2),
      height: widget.dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(
                      alpha: _animations[index].value * 0.8 + 0.2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 简化版的打字指示器
/// 
/// 用于空间受限的场景
class SimpleTypingIndicator extends StatefulWidget {
  const SimpleTypingIndicator({
    super.key,
    this.color,
    this.size = 12.0,
  });

  final Color? color;
  final double size;

  @override
  State<SimpleTypingIndicator> createState() => _SimpleTypingIndicatorState();
}

class _SimpleTypingIndicatorState extends State<SimpleTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
    final effectiveColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: List.generate(3, (index) {
              final delay = index * 0.33;
              final progress = (_animation.value + delay) % 1.0;
              
              return Positioned.fill(
                child: Opacity(
                  opacity: (1.0 - progress) * 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: effectiveColor,
                        width: 1.0,
                      ),
                    ),
                    transform: Matrix4.identity()
                      ..scale(progress * 2.0),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// 脉冲式打字指示器
/// 
/// 提供更现代的脉冲动画效果
class PulseTypingIndicator extends StatefulWidget {
  const PulseTypingIndicator({
    super.key,
    this.color,
    this.size = 16.0,
  });

  final Color? color;
  final double size;

  @override
  State<PulseTypingIndicator> createState() => _PulseTypingIndicatorState();
}

class _PulseTypingIndicatorState extends State<PulseTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: _animation.value * 0.8),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
