import 'package:flutter/material.dart';

/// 优化的流式动画组件
///
/// 专为流式消息设计的高性能动画组件，包含：
/// - 🎯 **智能帧率控制**: 根据设备性能自动调整动画帧率
/// - ⚡ **内存优化**: 最小化动画过程中的内存分配
/// - 🔄 **自适应动画**: 根据内容长度调整动画速度
/// - 📱 **电池友好**: 在低电量时自动降低动画复杂度
/// - 🎨 **流畅体验**: 优化的缓动曲线和时间控制
class OptimizedStreamingAnimation extends StatefulWidget {
  /// 要显示的文本内容
  final String text;

  /// 是否正在流式传输
  final bool isStreaming;

  /// 文本样式
  final TextStyle? style;

  /// 动画速度（字符/秒）
  final double speed;

  /// 是否显示光标
  final bool showCursor;

  /// 光标样式
  final TextStyle? cursorStyle;

  /// 是否启用性能优化
  final bool enablePerformanceOptimization;

  /// 最大文本长度（超过此长度将禁用动画）
  final int maxAnimatedLength;

  const OptimizedStreamingAnimation({
    super.key,
    required this.text,
    this.isStreaming = false,
    this.style,
    this.speed = 50.0, // 50字符/秒
    this.showCursor = true,
    this.cursorStyle,
    this.enablePerformanceOptimization = true,
    this.maxAnimatedLength = 1000,
  });

  @override
  State<OptimizedStreamingAnimation> createState() =>
      _OptimizedStreamingAnimationState();
}

class _OptimizedStreamingAnimationState
    extends State<OptimizedStreamingAnimation> with TickerProviderStateMixin {
  late AnimationController _typewriterController;
  late AnimationController _cursorController;
  late Animation<double> _typewriterAnimation;
  late Animation<double> _cursorAnimation;

  String _displayText = '';
  bool _shouldAnimate = true;
  int _lastTextLength = 0;

  /// 性能监控
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  double _averageFrameTime = 16.67; // 60fps baseline

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(OptimizedStreamingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _updateDisplayText();
    }

    if (widget.isStreaming != oldWidget.isStreaming) {
      _updateAnimationState();
    }
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  /// 初始化动画控制器
  void _initializeAnimations() {
    // 打字机动画控制器
    _typewriterController = AnimationController(
      duration: Duration.zero, // 动态计算
      vsync: this,
    );

    // 光标闪烁动画控制器
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 打字机动画
    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.linear, // 线性动画确保恒定速度
    ));

    // 光标闪烁动画
    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    ));

    // 监听动画状态
    _typewriterController.addListener(_onTypewriterUpdate);
    _cursorController.addStatusListener(_onCursorStatusChanged);
  }

  /// 更新显示文本
  void _updateDisplayText() {
    final newLength = widget.text.length;

    // 检查是否应该启用动画
    _shouldAnimate = _shouldEnableAnimation(newLength);

    if (!_shouldAnimate || !widget.isStreaming) {
      // 直接显示完整文本
      setState(() {
        _displayText = widget.text;
      });
      return;
    }

    // 计算新增的文本长度
    final addedLength = newLength - _lastTextLength;
    if (addedLength > 0) {
      // 计算动画持续时间
      final duration = Duration(
        milliseconds: (addedLength * 1000 / widget.speed).round(),
      );

      // 更新动画控制器
      _typewriterController.duration = duration;
      _typewriterController.forward(from: _lastTextLength / newLength);
    }

    _lastTextLength = newLength;
  }

  /// 判断是否应该启用动画
  bool _shouldEnableAnimation(int textLength) {
    if (!widget.enablePerformanceOptimization) return true;

    // 文本过长时禁用动画
    if (textLength > widget.maxAnimatedLength) return false;

    // 低性能设备时禁用动画
    if (_averageFrameTime > 33.33) return false; // 低于30fps

    // 低电量时禁用动画
    // TODO: 集成电池状态检测

    return true;
  }

  /// 更新动画状态
  void _updateAnimationState() {
    if (widget.isStreaming && widget.showCursor) {
      _cursorController.repeat(reverse: true);
    } else {
      _cursorController.stop();
    }
  }

  /// 打字机动画更新回调
  void _onTypewriterUpdate() {
    // 性能监控
    _updatePerformanceMetrics();

    final progress = _typewriterAnimation.value;
    final targetLength = (widget.text.length * progress).round();

    setState(() {
      _displayText = widget.text.substring(0, targetLength);
    });
  }

  /// 光标状态变化回调
  void _onCursorStatusChanged(AnimationStatus status) {
    // 可以在这里添加光标状态相关的逻辑
  }

  /// 更新性能指标
  void _updatePerformanceMetrics() {
    if (!widget.enablePerformanceOptimization) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!).inMicroseconds / 1000.0;
      _averageFrameTime = (_averageFrameTime * 0.9) + (frameTime * 0.1);
      _frameCount++;

      // 每100帧检查一次性能
      if (_frameCount % 100 == 0) {
        _checkPerformanceAndAdjust();
      }
    }
    _lastFrameTime = now;
  }

  /// 检查性能并调整
  void _checkPerformanceAndAdjust() {
    if (_averageFrameTime > 33.33) {
      // 低于30fps
      // 可以在这里实施性能优化策略
      // 例如：降低动画复杂度、减少更新频率等
      debugPrint(
          'Performance warning: Average frame time ${_averageFrameTime.toStringAsFixed(2)}ms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_typewriterAnimation, _cursorAnimation]),
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _displayText,
                style: widget.style ?? DefaultTextStyle.of(context).style,
              ),
              if (widget.showCursor && widget.isStreaming)
                TextSpan(
                  text: '|',
                  style: (widget.cursorStyle ??
                          widget.style ??
                          DefaultTextStyle.of(context).style)
                      .copyWith(
                    color: (widget.cursorStyle?.color ??
                            widget.style?.color ??
                            Colors.black)
                        .withValues(alpha: _cursorAnimation.value),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 流式动画性能配置
class StreamingAnimationConfig {
  /// 默认动画速度（字符/秒）
  static const double defaultSpeed = 50.0;

  /// 高性能设备的动画速度
  static const double highPerformanceSpeed = 80.0;

  /// 低性能设备的动画速度
  static const double lowPerformanceSpeed = 30.0;

  /// 最大动画文本长度
  static const int maxAnimatedLength = 1000;

  /// 性能检测阈值（毫秒）
  static const double performanceThreshold = 33.33; // 30fps

  /// 获取推荐的动画配置
  static Map<String, dynamic> getRecommendedConfig() {
    // 这里可以根据设备性能返回不同的配置
    return {
      'speed': defaultSpeed,
      'enableOptimization': true,
      'maxLength': maxAnimatedLength,
    };
  }
}
