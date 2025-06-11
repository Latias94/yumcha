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

import 'package:flutter/material.dart';
import '../providers/app_initialization_provider.dart';

class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({
    super.key,
    required this.initState,
  });

  final AppInitializationState initState;

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 进度动画控制器
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 粒子动画控制器
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Logo缩放动画
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Logo透明度动画
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // 进度值动画
    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2D2D2D),
              Color(0xFF1E1E1E),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景粒子效果
            _buildParticleBackground(),
            
            // 主要内容
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo区域
                  _buildAnimatedLogo(),
                  const SizedBox(height: 60),
                  
                  // 进度区域
                  _buildProgressSection(),
                  const SizedBox(height: 40),
                  
                  // 状态详情
                  _buildStatusDetails(),
                ],
              ),
            ),
            
            // 底部信息
            _buildBottomInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // 应用名称
        const Text(
          'Yumcha',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI 聊天助手',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        
        // 进度条
        AnimatedBuilder(
          animation: _progressValue,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressValue.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progressValue.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        
        // 当前步骤
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.initState.currentStep,
            key: ValueKey(widget.initState.currentStep),
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

  Widget _buildStatusDetails() {
    final statuses = [
      ('数据初始化', widget.initState.isDataInitialized),
      ('AI服务初始化', widget.initState.isAiServicesInitialized),
      ('MCP服务初始化', widget.initState.isMcpInitialized),
    ];

    return Column(
      children: statuses.map((status) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _buildStatusItem(status.$1, status.$2),
        );
      }).toList(),
    );
  }

  Widget _buildStatusItem(String title, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(isCompleted),
              color: isCompleted ? Colors.green : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted ? Colors.green : Colors.white70,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return const Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
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
      ),
    );
  }
}

/// 粒子效果绘制器
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // 绘制简单的粒子效果
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20) + animationValue * 50) % size.width;
      final y = (size.height * ((i * 0.7) % 1) + animationValue * 30) % size.height;
      final radius = 1.0 + (i % 3);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
