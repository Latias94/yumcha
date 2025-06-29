import 'package:flutter/material.dart';
import 'themes/ocean_theme.dart';
import 'themes/monochrome_theme.dart';
import 'themes/forest_theme.dart';
import 'themes/warm_orange_theme.dart';
import 'themes/custom_theme.dart';

/// 主题颜色方案管理器
/// 统一管理四个AI聊天优化主题：海洋、极简灰、森林绿、暖橙
class ThemeColorSchemes {
  /// 获取指定主题的颜色方案
  static ColorScheme? getColorSchemeForTheme(
    String themeScheme,
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    switch (themeScheme) {
      case 'ocean':
        return OceanTheme.getColorScheme(brightness, contrastLevel);
      case 'monochrome':
        return MonochromeTheme.getColorScheme(brightness, contrastLevel);
      case 'forest':
        return ForestTheme.getColorScheme(brightness, contrastLevel);
      case 'warmOrange':
        return WarmOrangeTheme.getColorScheme(brightness, contrastLevel);
      case 'custom':
        return null; // 自定义主题返回 null，由主题提供者处理
      default:
        return null; // 使用 FlexColorScheme 或其他方案
    }
  }

  /// 获取主题的主色调
  static Color getPrimaryColorForTheme(String themeScheme) {
    switch (themeScheme) {
      case 'ocean':
        return const Color(0xFF006782); // 海洋蓝主色调
      case 'monochrome':
        return const Color(0xFF2B2C2D); // 极简灰主色调
      case 'forest':
        return const Color(0xFF2E7D32); // 森林绿主色调
      case 'warmOrange':
        return const Color(0xFFBF360C); // 暖橙主色调
      case 'custom':
        return Colors.blue; // 自定义主题的默认颜色，实际使用时会被覆盖
      default:
        return Colors.blue; // 默认颜色
    }
  }

  /// 检查主题是否有自定义颜色方案
  static bool hasCustomColorScheme(String themeScheme) {
    return ['ocean', 'monochrome', 'forest', 'warmOrange']
        .contains(themeScheme);
  }

  /// 获取所有可用主题的列表
  static List<String> getAvailableThemes() {
    return ['ocean', 'monochrome', 'forest', 'warmOrange', 'custom'];
  }

  /// 获取主题的显示名称
  static String getThemeDisplayName(String themeScheme) {
    switch (themeScheme) {
      case 'ocean':
        return '海洋蓝';
      case 'monochrome':
        return '极简灰';
      case 'forest':
        return '森林绿';
      case 'warmOrange':
        return '暖橙';
      case 'custom':
        return '自定义';
      default:
        return '未知主题';
    }
  }

  /// 获取主题的描述
  static String getThemeDescription(String themeScheme) {
    switch (themeScheme) {
      case 'ocean':
        return '深邃宁静，专业沉稳';
      case 'monochrome':
        return '经典永恒，简约优雅';
      case 'forest':
        return '专注护眼，自然清新';
      case 'warmOrange':
        return '温暖友好，舒适亲切';
      case 'custom':
        return '个性化配色，展现独特品味';
      default:
        return '';
    }
  }

  // 为了向后兼容，保留一些旧的方法名
  static ColorScheme getOceanColorScheme(
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    return OceanTheme.getColorScheme(brightness, contrastLevel);
  }

  static ColorScheme getMonochromeColorScheme(
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    return MonochromeTheme.getColorScheme(brightness, contrastLevel);
  }

  static ColorScheme getForestColorScheme(
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    return ForestTheme.getColorScheme(brightness, contrastLevel);
  }

  static ColorScheme getWarmOrangeColorScheme(
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    return WarmOrangeTheme.getColorScheme(brightness, contrastLevel);
  }

  /// 获取自定义主题的颜色方案
  static ColorScheme getCustomColorScheme(
    Color seedColor,
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    return CustomTheme.getColorScheme(seedColor, brightness, contrastLevel);
  }

  /// 验证和调整种子颜色
  static Color validateAndAdjustSeedColor(Color seedColor) {
    return CustomTheme.validateAndAdjustSeedColor(seedColor);
  }

  /// 生成推荐的配色方案
  static List<Color> generateRecommendedColors(Color seedColor) {
    return CustomTheme.generateRecommendedColors(seedColor);
  }

  /// 获取颜色的显示名称
  static String getColorDisplayName(Color color) {
    return CustomTheme.getColorDisplayName(color);
  }
}
