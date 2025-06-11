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
              const SizedBox(height: 60),
              
              // 加载进度区域
              _buildLoadingSection(),
              const SizedBox(height: 40),
              
              // 初始化状态详情
              _buildInitializationDetails(),
              
              // 底部版本信息
              const Spacer(),
              _buildVersionInfo(),
              const SizedBox(height: 32),
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
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        
        // 应用名称
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: const Text(
                'Yumcha',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        
        // 副标题
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 2000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: const Text(
                'AI 聊天助手',
                style: TextStyle(
                  fontSize: 16,
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
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.withValues(alpha: 0.8),
            ),
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 20),
        
        // 当前步骤
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            initState.currentStep,
            key: ValueKey(initState.currentStep),
            style: const TextStyle(
              fontSize: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildStatusItem('数据初始化', initState.isDataInitialized),
          const SizedBox(height: 12),
          _buildStatusItem('AI服务初始化', initState.isAiServicesInitialized),
          const SizedBox(height: 12),
          _buildStatusItem('MCP服务初始化', initState.isMcpInitialized),
        ],
      ),
    );
  }

  /// 构建状态项
  Widget _buildStatusItem(String title, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted ? Colors.green : Colors.white70,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(isCompleted),
              color: isCompleted ? Colors.green : Colors.grey,
              size: 18,
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
        SizedBox(height: 4),
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
