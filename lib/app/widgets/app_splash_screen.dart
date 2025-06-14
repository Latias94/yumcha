/// 🚀 应用启动页面
///
/// 美观的启动页面，显示应用初始化进度。
///
/// ## 特性
/// - 🎨 渐变背景和动画效果，跟随主题变化
/// - 📊 实时初始化进度显示
/// - 🔄 平滑的状态转换动画
/// - 📱 响应式设计
/// - 🌙 支持浅色/深色主题自动适配
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/presentation/providers/app_initialization_provider.dart';
import '../../shared/presentation/design_system/design_constants.dart';

/// 应用启动页面组件
class AppSplashScreen extends ConsumerWidget {
  const AppSplashScreen({
    super.key,
    required this.initState,
  });

  final AppInitializationState initState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // 根据主题获取背景颜色
    final backgroundColor = colorScheme.surface;
    final gradientColors = isDark
        ? [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.8),
          ]
        : [
            colorScheme.surface,
            colorScheme.surfaceContainerLowest,
          ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 应用Logo区域
                    _buildLogoSection(context, colorScheme),
                    SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceXXXL * 2)),

                    // 加载进度区域
                    _buildLoadingSection(context, colorScheme),
                    SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceXXL)),

                    // 初始化状态详情
                    _buildInitializationDetails(context, colorScheme),

                    // 底部版本信息
                    const Spacer(),
                    _buildVersionInfo(context, colorScheme),
                    SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceXXL)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  /// 构建Logo区域
  Widget _buildLogoSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Logo动画容器
        TweenAnimationBuilder<double>(
          duration:
              DesignConstants.animationVerySlow * 3.33, // 2秒 = 600ms * 3.33
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  width: DesignConstants.iconSizeXXL * 2.5, // 100px
                  height: DesignConstants.iconSizeXXL * 2.5, // 100px
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(
                        alpha: DesignConstants.opacityMedium * 0.17), // 0.1
                    borderRadius: DesignConstants.radiusXL,
                    border: Border.all(
                      color: colorScheme.primary.withValues(
                          alpha: DesignConstants.opacityMedium * 0.5), // 0.3
                      width: DesignConstants.borderWidthThick,
                    ),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: DesignConstants.iconSizeXXL +
                        DesignConstants.iconSizeM, // 50px
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceXXL)),

        // 应用名称
        TweenAnimationBuilder<double>(
          duration:
              DesignConstants.animationVerySlow * 2.5, // 1500ms = 600ms * 2.5
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                'Yumcha',
                style: TextStyle(
                  fontSize: DesignConstants.getResponsiveFontSize(context,
                      mobile: 28.0, tablet: 32.0, desktop: 36.0), // 小屏减小字体
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: 2.0,
                ),
              ),
            );
          },
        ),
        SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceS)),

        // 副标题
        TweenAnimationBuilder<double>(
          duration:
              DesignConstants.animationVerySlow * 3.33, // 2000ms = 600ms * 3.33
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                'AI 聊天助手',
                style: TextStyle(
                  fontSize: DesignConstants.getResponsiveFontSize(context,
                      mobile: 12.0, tablet: 14.0, desktop: 16.0), // 小屏减小字体
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建加载区域
  Widget _buildLoadingSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // 自定义进度指示器
        SizedBox(
          width: DesignConstants.iconSizeXXL,
          height: DesignConstants.iconSizeXXL,
          child: CircularProgressIndicator(
            strokeWidth: DesignConstants.borderWidthMedium + 1, // 3px
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.primary
                  .withValues(alpha: DesignConstants.opacityHigh),
            ),
            backgroundColor: colorScheme.surfaceContainerHighest
                .withValues(alpha: DesignConstants.opacityMedium * 0.33), // 0.2
          ),
        ),
        SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceXL)),

        // 当前步骤
        AnimatedSwitcher(
          duration: DesignConstants.animationNormal +
              const Duration(milliseconds: 50), // 300ms
          child: Text(
            initState.currentStep,
            key: ValueKey(initState.currentStep),
            style: TextStyle(
              fontSize: DesignConstants.getResponsiveFontSize(context,
                  mobile: 14.0, tablet: 15.0, desktop: 16.0), // 响应式字体
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// 构建初始化详情
  Widget _buildInitializationDetails(
      BuildContext context, ColorScheme colorScheme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getAdaptiveSpacing(context, DesignConstants.spaceXXL * 2),
      ),
      child: Column(
        children: [
          _buildStatusItem('数据初始化', initState.isDataInitialized, colorScheme),

          // 在小屏设备上隐藏详细的子状态，节省空间
          if (!isSmallScreen) ...[
            SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceS)),
            // 详细的数据加载状态
            Padding(
              padding: EdgeInsets.only(left: DesignConstants.spaceL),
              child: Column(
                children: [
                  _buildSubStatusItem('提供商数据', initState.isProvidersLoaded, colorScheme),
                  SizedBox(height: DesignConstants.spaceXS),
                  _buildSubStatusItem('助手数据', initState.isAssistantsLoaded, colorScheme),
                  SizedBox(height: DesignConstants.spaceXS),
                  _buildSubStatusItem('设置数据', initState.isSettingsLoaded, colorScheme),
                  SizedBox(height: DesignConstants.spaceXS),
                  _buildSubStatusItem('收藏模型', initState.isFavoriteModelsLoaded, colorScheme),
                ],
              ),
            ),
          ],

          SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceM)),
          _buildStatusItem(
              'AI服务初始化', initState.isAiServicesInitialized, colorScheme),
          SizedBox(height: _getAdaptiveSpacing(context, DesignConstants.spaceM)),
          _buildStatusItem('MCP服务初始化', initState.isMcpInitialized, colorScheme),
        ],
      ),
    );
  }

  /// 构建状态项
  Widget _buildStatusItem(
      String title, bool isCompleted, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: DesignConstants.animationNormal +
          const Duration(milliseconds: 50), // 300ms
      padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceL, vertical: DesignConstants.spaceS),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.primaryContainer
                .withValues(alpha: DesignConstants.opacityMedium * 0.17) // 0.1
            : colorScheme.surfaceContainerHighest.withValues(
                alpha: DesignConstants.opacityMedium * 0.08), // 0.05
        borderRadius: DesignConstants.radiusS,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14, // 保持固定字体大小
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          AnimatedSwitcher(
            duration: DesignConstants.animationFast +
                const Duration(milliseconds: 50), // 200ms
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(isCompleted),
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: DesignConstants.iconSizeS + 2, // 18px
            ),
          ),
        ],
      ),
    );
  }

  /// 构建子状态项（更小的状态指示器）
  Widget _buildSubStatusItem(
      String title, bool isCompleted, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: DesignConstants.animationNormal +
          const Duration(milliseconds: 50), // 300ms
      padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceM, vertical: DesignConstants.spaceXS),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.primaryContainer
                .withValues(alpha: DesignConstants.opacityMedium * 0.1) // 0.06
            : colorScheme.surfaceContainerHighest.withValues(
                alpha: DesignConstants.opacityMedium * 0.05), // 0.03
        borderRadius: DesignConstants.radiusXS,
        border: Border.all(
          color: isCompleted
              ? colorScheme.primary
                  .withValues(alpha: DesignConstants.opacityMedium * 0.3) // 0.18
              : colorScheme.outline.withValues(
                  alpha: DesignConstants.opacityMedium * 0.2), // 0.12
          width: DesignConstants.borderWidthThin * 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12, // 更小的字体
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          AnimatedSwitcher(
            duration: DesignConstants.animationFast +
                const Duration(milliseconds: 50), // 200ms
            child: Icon(
              isCompleted ? Icons.check : Icons.circle_outlined,
              key: ValueKey(isCompleted),
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: DesignConstants.iconSizeS, // 更小的图标
            ),
          ),
        ],
      ),
    );
  }

  /// 构建版本信息
  Widget _buildVersionInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'Version 1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DesignConstants.spaceXS),
        Text(
          'Powered by Flutter & Riverpod',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
