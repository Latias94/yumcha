import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 全屏图片查看器
///
/// 支持功能：
/// - 🔍 双指缩放 (pinch to zoom)
/// - 📱 双击缩放 (double tap to zoom)
/// - 🖱️ 鼠标滚轮缩放 (desktop)
/// - 👆 拖拽平移 (pan)
/// - 🔄 旋转 (optional)
/// - 📱 全屏沉浸式体验
class FullscreenImageViewer extends StatefulWidget {
  const FullscreenImageViewer({
    super.key,
    required this.imageData,
    required this.fileName,
    this.heroTag,
    this.backgroundColor,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.enableRotation = false,
  });

  /// 图片数据
  final Uint8List imageData;

  /// 文件名
  final String fileName;

  /// Hero动画标签
  final String? heroTag;

  /// 背景颜色
  final Color? backgroundColor;

  /// 最小缩放比例
  final double minScale;

  /// 最大缩放比例
  final double maxScale;

  /// 是否启用旋转
  final bool enableRotation;

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late AnimationController _overlayController;

  bool _isOverlayVisible = true;
  double _rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: DesignConstants.animationNormal,
      vsync: this,
    );
    _overlayController = AnimationController(
      duration: DesignConstants.animationFast,
      vsync: this,
      value: 1.0,
    );

    // 设置全屏模式
    _setFullscreenMode();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    _overlayController.dispose();
    _restoreSystemUI();
    super.dispose();
  }

  /// 设置全屏沉浸式模式
  void _setFullscreenMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  /// 恢复系统UI
  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  /// 切换覆盖层显示状态
  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });

    if (_isOverlayVisible) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
  }

  /// 重置变换
  void _resetTransform() {
    _animationController.reset();
    final animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignConstants.curveStandard,
    ));

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _animationController.forward();
  }

  /// 双击缩放
  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = currentScale > 1.0 ? 1.0 : 2.0;

    _animationController.reset();
    final animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(targetScale),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignConstants.curveEmphasized,
    ));

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _animationController.forward();
  }

  /// 旋转图片
  void _rotateImage() {
    if (!widget.enableRotation) return;

    setState(() {
      _rotation += 90;
      if (_rotation >= 360) _rotation = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black,
      body: Stack(
        children: [
          // 图片查看器主体
          _buildImageViewer(),

          // 顶部覆盖层
          _buildTopOverlay(theme),

          // 底部覆盖层
          _buildBottomOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    Widget imageWidget = Image.memory(
      widget.imageData,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );

    // 添加Hero动画
    if (widget.heroTag != null) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    // 添加旋转
    if (widget.enableRotation && _rotation != 0) {
      imageWidget = Transform.rotate(
        angle: _rotation * (3.14159 / 180),
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: _toggleOverlay,
      onDoubleTap: _handleDoubleTap,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          alignment: Alignment.center,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildTopOverlay(ThemeData theme) {
    return AnimatedBuilder(
      animation: _overlayController,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, -60 * (1 - _overlayController.value)),
            child: Opacity(
              opacity: _overlayController.value,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      DesignConstants.spaceS,
                  left: DesignConstants.spaceM,
                  right: DesignConstants.spaceM,
                  bottom: DesignConstants.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withValues(alpha: DesignConstants.opacityHigh),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // 返回按钮
                    _buildOverlayButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: '返回',
                    ),

                    SizedBox(width: DesignConstants.spaceM),

                    // 文件名
                    Expanded(
                      child: Text(
                        widget.fileName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 更多操作按钮
                    _buildOverlayButton(
                      icon: Icons.more_vert,
                      onPressed: _showMoreOptions,
                      tooltip: '更多选项',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomOverlay(ThemeData theme) {
    return AnimatedBuilder(
      animation: _overlayController,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, 60 * (1 - _overlayController.value)),
            child: Opacity(
              opacity: _overlayController.value,
              child: Container(
                padding: EdgeInsets.only(
                  top: DesignConstants.spaceM,
                  left: DesignConstants.spaceM,
                  right: DesignConstants.spaceM,
                  bottom: MediaQuery.of(context).padding.bottom +
                      DesignConstants.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black
                          .withValues(alpha: DesignConstants.opacityHigh),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 重置缩放
                    _buildOverlayButton(
                      icon: Icons.fit_screen,
                      onPressed: _resetTransform,
                      tooltip: '重置缩放',
                    ),

                    // 旋转（如果启用）
                    if (widget.enableRotation)
                      _buildOverlayButton(
                        icon: Icons.rotate_right,
                        onPressed: _rotateImage,
                        tooltip: '旋转',
                      ),

                    // 分享
                    _buildOverlayButton(
                      icon: Icons.share,
                      onPressed: _shareImage,
                      tooltip: '分享',
                    ),

                    // 保存
                    _buildOverlayButton(
                      icon: Icons.download,
                      onPressed: _saveImage,
                      tooltip: '保存',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: DesignConstants.opacityMedium),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.white.withValues(alpha: DesignConstants.opacityHigh),
        ),
        SizedBox(height: DesignConstants.spaceM),
        Text(
          '图片加载失败',
          style: TextStyle(
            color: Colors.white.withValues(alpha: DesignConstants.opacityHigh),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions() {
    // TODO: 实现更多选项菜单
    // 可以包括：复制、删除、编辑等
  }

  void _shareImage() {
    // TODO: 实现图片分享功能
    // 可以使用 share_plus 包
  }

  void _saveImage() {
    // TODO: 实现图片保存功能
    // 可以使用 image_gallery_saver 包
  }
}
