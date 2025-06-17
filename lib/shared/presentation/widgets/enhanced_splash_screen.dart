/// 🎨 增强版启动页面组件
///
/// 提供更丰富的视觉效果和动画的启动页面。
/// 可以根据需要替换默认的启动页面。
///
/// ## 特性
/// - 🎭 丰富的动画效果
/// - 🎨 渐变背景和粒子效果
/// - 📊 实时进度显示
/// - 🔄 平滑的状态转换
/// - 📱 响应式设计
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_initialization_provider.dart';
import '../design_system/design_constants.dart';

class EnhancedSplashScreen extends ConsumerStatefulWidget {
  const EnhancedSplashScreen({
    super.key,
    required this.initState,
  });

  final AppInitializationState initState;

  @override
  ConsumerState<EnhancedSplashScreen> createState() =>
      _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends ConsumerState<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Logo动画控制器
    _logoController = AnimationController(
      duration:
          DesignConstants.animationVerySlow * 3.33, // 2000ms = 600ms * 3.33
      vsync: this,
    );

    // 进度动画控制器
    _progressController = AnimationController(
      duration:
          DesignConstants.animationVerySlow * 1.67, // 1000ms = 600ms * 1.67
      vsync: this,
    );

    // 粒子动画控制器
    _particleController = AnimationController(
      duration: DesignConstants.animationVerySlow * 5, // 3000ms = 600ms * 5
      vsync: this,
    );

    // Logo缩放动画
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: DesignConstants.curveBounce, // 使用设计系统的弹跳曲线
    ));

    // Logo透明度动画
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Interval(0.0, 0.6,
          curve: DesignConstants.curveAccelerated), // 使用设计系统的加速曲线
    ));

    // 进度值动画
    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: DesignConstants.curveStandard, // 使用设计系统的标准曲线
    ));
  }

  void _startAnimations() {
    _logoController.forward();
    _particleController.repeat();

    // 根据初始化状态更新进度
    _updateProgress();
  }

  void _updateProgress() {
    double progress = 0.0;
    if (widget.initState.isDataInitialized) progress += 0.33;
    if (widget.initState.isAiServicesInitialized) progress += 0.33;
    if (widget.initState.isMcpInitialized) progress += 0.34;

    _progressController.animateTo(progress);
  }

  @override
  void didUpdateWidget(EnhancedSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initState != widget.initState) {
      _updateProgress();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  /// 获取自适应间距
  /// 根据屏幕高度调整间距，避免小屏设备overflow
  double _getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 小屏设备 (高度 < 700px) - 减少50%间距
    if (screenHeight < 700) {
      return baseSpacing * 0.5;
    }
    // 中等屏幕 (高度 < 800px) - 减少25%间距
    else if (screenHeight < 800) {
      return baseSpacing * 0.75;
    }
    // 大屏设备 - 保持原间距
    return baseSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // 根据主题获取渐变颜色
    final gradientColors = isDark
        ? [
            colorScheme.surface,
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainerLowest,
          ]
        : [
            colorScheme.surface,
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerHighest,
          ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 背景粒子效果
              _buildParticleBackground(colorScheme),

              // 主要内容 - 添加滚动支持
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo区域
                        _buildAnimatedLogo(colorScheme),
                        SizedBox(
                            height: _getAdaptiveSpacing(
                                context, DesignConstants.spaceXXXL * 2)),

                        // 进度区域
                        _buildProgressSection(colorScheme),
                        SizedBox(
                            height: _getAdaptiveSpacing(
                                context,
                                DesignConstants.spaceXXXL +
                                    DesignConstants.spaceS)),

                        // 状态详情
                        _buildStatusDetails(colorScheme),

                        // 底部留白，为底部信息预留空间
                        SizedBox(height: DesignConstants.spaceXXXL * 3),
                      ],
                    ),
                  ),
                ),
              ),

              // 底部信息
              _buildBottomInfo(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticleBackground(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleController.value, colorScheme),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedLogo(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: DesignConstants.iconSizeXXL * 3, // 120px -> 120px
              height: DesignConstants.iconSizeXXL * 3, // 120px -> 120px
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(
                    alpha: DesignConstants.opacityMedium * 0.17), // 0.1
                borderRadius: BorderRadius.circular(
                    DesignConstants.radiusXXLValue + 6), // 30px
                border: Border.all(
                  color: colorScheme.primary.withValues(
                      alpha: DesignConstants.opacityMedium * 0.5), // 0.3
                  width: DesignConstants.borderWidthThick,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                        alpha: DesignConstants.opacityMedium * 0.33), // 0.2
                    blurRadius: DesignConstants.spaceL +
                        DesignConstants.spaceXS, // 20px
                    spreadRadius: DesignConstants.spaceXS + 1, // 5px
                  ),
                ],
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: DesignConstants.iconSizeXXL * 1.5, // 60px
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(ColorScheme colorScheme) {
    return Column(
      children: [
        // 应用名称
        Text(
          'Yumcha',
          style: TextStyle(
            fontSize: DesignConstants.getResponsiveFontSize(context,
                mobile: 38.0, tablet: 40.0, desktop: 42.0), // 响应式字体大小
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: 3.0,
          ),
        ),
        SizedBox(height: DesignConstants.spaceS),
        Text(
          'AI 聊天助手',
          style: TextStyle(
            fontSize: DesignConstants.getResponsiveFontSize(context), // 响应式字体大小
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(
            height: DesignConstants.spaceXXXL + DesignConstants.spaceS), // 40px

        // 进度条
        AnimatedBuilder(
          animation: _progressValue,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: DesignConstants.getResponsiveMaxWidth(context,
                      mobile: 180.0, tablet: 200.0, desktop: 220.0), // 响应式宽度
                  height: DesignConstants.spaceXS,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: DesignConstants.opacityMedium * 0.33), // 0.2
                    borderRadius:
                        BorderRadius.circular(DesignConstants.spaceXS / 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressValue.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        borderRadius:
                            BorderRadius.circular(DesignConstants.spaceXS / 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: DesignConstants.spaceL),
                Text(
                  '${(_progressValue.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: DesignConstants.getResponsiveFontSize(context,
                        mobile: 13.0, tablet: 14.0, desktop: 14.0),
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: DesignConstants.spaceXL),

        // 当前步骤
        AnimatedSwitcher(
          duration: DesignConstants.animationNormal,
          child: Text(
            widget.initState.currentStep,
            key: ValueKey(widget.initState.currentStep),
            style: TextStyle(
              fontSize: DesignConstants.getResponsiveFontSize(context),
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDetails(ColorScheme colorScheme) {
    final statuses = [
      ('数据初始化', widget.initState.isDataInitialized),
      ('AI服务初始化', widget.initState.isAiServicesInitialized),
      ('MCP服务初始化', widget.initState.isMcpInitialized),
    ];

    return Column(
      children: statuses.map((status) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: DesignConstants.spaceXS),
          child: _buildStatusItem(status.$1, status.$2, colorScheme),
        );
      }).toList(),
    );
  }

  Widget _buildStatusItem(
      String title, bool isCompleted, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: DesignConstants.animationSlow,
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceXL,
        vertical: DesignConstants.spaceM - 2, // 10px
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.primaryContainer
                .withValues(alpha: DesignConstants.opacityMedium * 0.17) // 0.1
            : Colors.transparent,
        borderRadius: DesignConstants.radiusXL,
        border: Border.all(
          color: isCompleted
              ? colorScheme.primary
                  .withValues(alpha: DesignConstants.opacityMedium * 0.5) // 0.3
              : colorScheme.outline.withValues(
                  alpha: DesignConstants.opacityMedium * 0.33), // 0.2
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: DesignConstants.animationNormal,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(isCompleted),
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: DesignConstants.iconSizeS,
            ),
          ),
          SizedBox(width: DesignConstants.spaceM),
          Text(
            title,
            style: TextStyle(
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 13.0, tablet: 14.0, desktop: 14.0),
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(ColorScheme colorScheme) {
    return Positioned(
      bottom: DesignConstants.spaceXXXL + DesignConstants.spaceS, // 40px
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 11.0, tablet: 12.0, desktop: 12.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DesignConstants.spaceXS),
          Text(
            'Powered by Flutter & Riverpod',
            style: TextStyle(
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 9.0, tablet: 10.0, desktop: 10.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 粒子效果绘制器
class ParticlePainter extends CustomPainter {
  final double animationValue;
  final ColorScheme colorScheme;

  ParticlePainter(this.animationValue, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.primary
          .withValues(alpha: DesignConstants.opacityMedium * 0.17) // 0.1
      ..style = PaintingStyle.fill;

    // 绘制简单的粒子效果
    const particleCount = 20;
    const baseSpeed = 50.0;
    const verticalSpeed = 30.0;

    for (int i = 0; i < particleCount; i++) {
      final x =
          (size.width * (i / particleCount) + animationValue * baseSpeed) %
              size.width;
      final y =
          (size.height * ((i * 0.7) % 1) + animationValue * verticalSpeed) %
              size.height;
      final radius = 1.0 + (i % 3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
