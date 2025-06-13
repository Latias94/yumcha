import 'package:flutter/material.dart';

/// 自定义主题颜色定义
/// 基于用户设置的种子颜色生成完整的 Material 3 颜色方案
class CustomTheme {
  /// 获取自定义主题的颜色方案
  ///
  /// [seedColor] 种子颜色，用于生成整个颜色方案
  /// [brightness] 亮度模式（浅色/深色）
  /// [contrastLevel] 对比度级别（标准/中等/高）
  static ColorScheme getColorScheme(
    Color seedColor,
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    // 使用 Material 3 的 ColorScheme.fromSeed 方法生成基础颜色方案
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    // 根据对比度级别调整颜色方案
    switch (contrastLevel) {
      case 'medium':
        return _adjustForMediumContrast(baseColorScheme, brightness);
      case 'high':
        return _adjustForHighContrast(baseColorScheme, brightness);
      default:
        return baseColorScheme;
    }
  }

  /// 调整为中等对比度
  static ColorScheme _adjustForMediumContrast(
    ColorScheme baseScheme,
    Brightness brightness,
  ) {
    if (brightness == Brightness.light) {
      return baseScheme.copyWith(
        // 增强主色调对比度
        primary: _darkenColor(baseScheme.primary, 0.1),
        onPrimary: Colors.white,
        // 增强次要色调对比度
        secondary: _darkenColor(baseScheme.secondary, 0.1),
        onSecondary: Colors.white,
        // 增强表面对比度
        onSurface: _darkenColor(baseScheme.onSurface, 0.1),
        onSurfaceVariant: _darkenColor(baseScheme.onSurfaceVariant, 0.1),
      );
    } else {
      return baseScheme.copyWith(
        // 增强主色调对比度
        primary: _lightenColor(baseScheme.primary, 0.1),
        onPrimary: Colors.black,
        // 增强次要色调对比度
        secondary: _lightenColor(baseScheme.secondary, 0.1),
        onSecondary: Colors.black,
        // 增强表面对比度
        onSurface: _lightenColor(baseScheme.onSurface, 0.1),
        onSurfaceVariant: _lightenColor(baseScheme.onSurfaceVariant, 0.1),
      );
    }
  }

  /// 调整为高对比度
  static ColorScheme _adjustForHighContrast(
    ColorScheme baseScheme,
    Brightness brightness,
  ) {
    if (brightness == Brightness.light) {
      return baseScheme.copyWith(
        // 最大化主色调对比度
        primary: _darkenColor(baseScheme.primary, 0.2),
        onPrimary: Colors.white,
        // 最大化次要色调对比度
        secondary: _darkenColor(baseScheme.secondary, 0.2),
        onSecondary: Colors.white,
        // 最大化表面对比度
        onSurface: Colors.black,
        onSurfaceVariant: Colors.black,
        outline: Colors.black,
      );
    } else {
      return baseScheme.copyWith(
        // 最大化主色调对比度
        primary: _lightenColor(baseScheme.primary, 0.2),
        onPrimary: Colors.black,
        // 最大化次要色调对比度
        secondary: _lightenColor(baseScheme.secondary, 0.2),
        onSecondary: Colors.black,
        // 最大化表面对比度
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white,
        outline: Colors.white,
      );
    }
  }

  /// 加深颜色
  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  /// 变浅颜色
  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightened =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  /// 获取自定义主题的预览颜色
  /// 用于主题选择器中的预览
  static Color getPreviewColor(Color seedColor) {
    return seedColor;
  }

  /// 验证种子颜色是否适合作为主题色
  /// 返回建议的调整后颜色，如果原色合适则返回原色
  static Color validateAndAdjustSeedColor(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);

    // 确保饱和度不会太低（至少 0.3）
    double adjustedSaturation = hsl.saturation;
    if (adjustedSaturation < 0.3) {
      adjustedSaturation = 0.3;
    }

    // 确保亮度在合适范围内（0.2 - 0.8）
    double adjustedLightness = hsl.lightness;
    if (adjustedLightness < 0.2) {
      adjustedLightness = 0.2;
    } else if (adjustedLightness > 0.8) {
      adjustedLightness = 0.8;
    }

    // 如果需要调整，返回调整后的颜色
    if (adjustedSaturation != hsl.saturation ||
        adjustedLightness != hsl.lightness) {
      return hsl
          .withSaturation(adjustedSaturation)
          .withLightness(adjustedLightness)
          .toColor();
    }

    return seedColor;
  }

  /// 生成推荐的配色方案
  /// 基于种子颜色生成一组和谐的颜色建议
  static List<Color> generateRecommendedColors(Color seedColor) {
    final hsl = HSLColor.fromColor(seedColor);

    return [
      seedColor, // 原色
      hsl.withHue((hsl.hue + 30) % 360).toColor(), // 类似色 +30°
      hsl.withHue((hsl.hue - 30) % 360).toColor(), // 类似色 -30°
      hsl.withHue((hsl.hue + 120) % 360).toColor(), // 三角色 +120°
      hsl.withHue((hsl.hue + 180) % 360).toColor(), // 互补色 +180°
      hsl
          .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0))
          .toColor(), // 降低饱和度
      hsl
          .withLightness((hsl.lightness * 0.8).clamp(0.0, 1.0))
          .toColor(), // 降低亮度
      hsl
          .withLightness((hsl.lightness * 1.2).clamp(0.0, 1.0))
          .toColor(), // 提高亮度
    ];
  }

  /// 获取颜色的显示名称
  /// 基于颜色的 HSL 值生成描述性名称
  static String getColorDisplayName(Color color) {
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;
    final saturation = hsl.saturation;
    final lightness = hsl.lightness;

    // 基于色相确定基础颜色名称
    String baseName;
    if (hue >= 0 && hue < 30) {
      baseName = '红色';
    } else if (hue >= 30 && hue < 60) {
      baseName = '橙色';
    } else if (hue >= 60 && hue < 120) {
      baseName = '黄色';
    } else if (hue >= 120 && hue < 180) {
      baseName = '绿色';
    } else if (hue >= 180 && hue < 240) {
      baseName = '青色';
    } else if (hue >= 240 && hue < 300) {
      baseName = '蓝色';
    } else {
      baseName = '紫色';
    }

    // 基于饱和度和亮度添加修饰词
    String modifier = '';
    if (saturation < 0.3) {
      modifier = '灰';
    } else if (lightness < 0.3) {
      modifier = '深';
    } else if (lightness > 0.7) {
      modifier = '浅';
    }

    return '$modifier$baseName';
  }
}
