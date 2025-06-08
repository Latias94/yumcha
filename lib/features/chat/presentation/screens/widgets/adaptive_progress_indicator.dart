import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 自适应进度指示器 - 根据平台显示相应的进度指示器
class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 4.0,
  });

  /// 进度值 (0.0 - 1.0)，null表示无限进度
  final double? value;

  /// 背景颜色
  final Color? backgroundColor;

  /// 进度颜色
  final Color? color;

  /// 线条宽度
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    // 根据主题判断使用哪种进度指示器
    final isCupertino = Theme.of(context).platform == TargetPlatform.iOS;

    if (isCupertino) {
      return CupertinoActivityIndicator(color: color);
    } else {
      return CircularProgressIndicator(
        value: value,
        backgroundColor: backgroundColor,
        color: color,
        strokeWidth: strokeWidth,
      );
    }
  }
}
