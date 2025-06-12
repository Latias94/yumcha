/// 🚀 应用启动页面
///
/// 美观的启动页面，显示应用初始化进度。
///
/// ## 特性
/// - 🎨 渐变背景和动画效果
/// - 📊 实时初始化进度显示
/// - 🔄 平滑的状态转换动画
/// - 📱 响应式设计

import 'package:flutter/material.dart';
import '../../shared/presentation/providers/app_initialization_provider.dart';
import '../../shared/presentation/design_system/design_constants.dart';

/// 应用启动页面组件
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({
    super.key,
    required this.initState,
  });

  final AppInitializationState initState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // 深色背景
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF2D2D2D),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用Logo区域
              _buildLogoSection(),
              SizedBox(height: DesignConstants.spaceXXXL * 2),

              // 加载进度区域
              _buildLoadingSection(),
              SizedBox(height: DesignConstants.spaceXXL),

              // 初始化状态详情
              _buildInitializationDetails(),

              // 底部版本信息
              const Spacer(),
              _buildVersionInfo(),
              SizedBox(height: DesignConstants.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Logo区域
  Widget _buildLogoSection() {
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
                    color: Colors.blue.withValues(
                        alpha: DesignConstants.opacityMedium * 0.17), // 0.1
                    borderRadius: DesignConstants.radiusXL,
                    border: Border.all(
                      color: Colors.blue.withValues(
                          alpha: DesignConstants.opacityMedium * 0.5), // 0.3
                      width: DesignConstants.borderWidthThick,
                    ),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: DesignConstants.iconSizeXXL +
                        DesignConstants.iconSizeM, // 50px
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: DesignConstants.spaceXXL),

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
                      mobile: 32.0, tablet: 36.0, desktop: 40.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            );
          },
        ),
        SizedBox(height: DesignConstants.spaceS),

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
                  fontSize: DesignConstants.getResponsiveFontSize(context),
                  color: Colors.grey,
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
  Widget _buildLoadingSection() {
    return Column(
      children: [
        // 自定义进度指示器
        SizedBox(
          width: DesignConstants.iconSizeXXL,
          height: DesignConstants.iconSizeXXL,
          child: CircularProgressIndicator(
            strokeWidth: DesignConstants.borderWidthMedium + 1, // 3px
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.withValues(alpha: DesignConstants.opacityHigh),
            ),
            backgroundColor: Colors.grey
                .withValues(alpha: DesignConstants.opacityMedium * 0.33), // 0.2
          ),
        ),
        SizedBox(height: DesignConstants.spaceXL),

        // 当前步骤
        AnimatedSwitcher(
          duration: DesignConstants.animationNormal +
              const Duration(milliseconds: 50), // 300ms
          child: Text(
            initState.currentStep,
            key: ValueKey(initState.currentStep),
            style: const TextStyle(
              fontSize: 16, // 保持固定字体大小
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// 构建初始化详情
  Widget _buildInitializationDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignConstants.spaceXXL * 2),
      child: Column(
        children: [
          _buildStatusItem('数据初始化', initState.isDataInitialized),
          SizedBox(height: DesignConstants.spaceM),
          _buildStatusItem('AI服务初始化', initState.isAiServicesInitialized),
          SizedBox(height: DesignConstants.spaceM),
          _buildStatusItem('MCP服务初始化', initState.isMcpInitialized),
        ],
      ),
    );
  }

  /// 构建状态项
  Widget _buildStatusItem(String title, bool isCompleted) {
    return AnimatedContainer(
      duration: DesignConstants.animationNormal +
          const Duration(milliseconds: 50), // 300ms
      padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceL, vertical: DesignConstants.spaceS),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green
                .withValues(alpha: DesignConstants.opacityMedium * 0.17) // 0.1
            : Colors.grey.withValues(
                alpha: DesignConstants.opacityMedium * 0.08), // 0.05
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: isCompleted
              ? Colors.green
                  .withValues(alpha: DesignConstants.opacityMedium * 0.5) // 0.3
              : Colors.grey.withValues(
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
              color: isCompleted ? Colors.green : Colors.white70,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          AnimatedSwitcher(
            duration: DesignConstants.animationFast +
                const Duration(milliseconds: 50), // 200ms
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(isCompleted),
              color: isCompleted ? Colors.green : Colors.grey,
              size: DesignConstants.iconSizeS + 2, // 18px
            ),
          ),
        ],
      ),
    );
  }

  /// 构建版本信息
  Widget _buildVersionInfo() {
    return const Column(
      children: [
        Text(
          'Version 1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: DesignConstants.spaceXS),
        Text(
          'Powered by Flutter & Riverpod',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
