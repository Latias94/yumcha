import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../app/theme/theme_color_schemes.dart';

/// 增强的主题选择器
///
/// 提供更丰富的主题选择和预览功能，包括：
/// - 多种预设主题方案
/// - 对比度级别选择
/// - 实时主题预览
/// - 自定义颜色支持
class EnhancedThemeSelector extends ConsumerWidget {
  const EnhancedThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主题方案选择
        _buildThemeSchemeSection(context, themeSettings, themeNotifier),
        const SizedBox(height: 24),

        // 对比度级别选择
        _buildContrastLevelSection(context, themeSettings, themeNotifier),
        const SizedBox(height: 24),

        // 颜色模式选择
        _buildColorModeSection(context, themeSettings, themeNotifier),
        const SizedBox(height: 24),

        // 动态颜色设置
        if (themeSettings.isDynamicColorAvailable)
          _buildDynamicColorSection(context, themeSettings, themeNotifier),
      ],
    );
  }

  Widget _buildThemeSchemeSection(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主题方案',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          '选择您喜欢的颜色主题',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),

        // 主题方案网格 - 响应式布局
        LayoutBuilder(
          builder: (context, constraints) {
            // 根据屏幕宽度动态调整列数和宽高比
            int crossAxisCount;
            double childAspectRatio;

            if (constraints.maxWidth < 400) {
              // 小屏幕：1列
              crossAxisCount = 1;
              childAspectRatio = 5.0;
            } else if (constraints.maxWidth < 600) {
              // 中等屏幕：2列
              crossAxisCount = 2;
              childAspectRatio = 3.2;
            } else {
              // 大屏幕：3列
              crossAxisCount = 3;
              childAspectRatio = 2.8;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: AppThemeScheme.values.length,
              itemBuilder: (context, index) {
                final scheme = AppThemeScheme.values[index];
                final isSelected = themeSettings.themeScheme == scheme;

                return _buildThemeSchemeCard(
                  context,
                  scheme,
                  isSelected,
                  () => themeNotifier.setThemeScheme(scheme),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeSchemeCard(
    BuildContext context,
    AppThemeScheme scheme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    // 获取主题预览颜色
    Color primaryColor;
    if (ThemeColorSchemes.hasCustomColorScheme(scheme.name)) {
      primaryColor = ThemeColorSchemes.getPrimaryColorForTheme(scheme.name);
    } else {
      // 使用默认颜色
      switch (scheme) {
        case AppThemeScheme.ocean:
          primaryColor = const Color(0xFF006782);
          break;
        case AppThemeScheme.monochrome:
          primaryColor = const Color(0xFF2B2C2D);
          break;
        case AppThemeScheme.forest:
          primaryColor = const Color(0xFF2E7D32);
          break;
        case AppThemeScheme.warmOrange:
          primaryColor = const Color(0xFFBF360C);
          break;
      }
    }

    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // 颜色预览圆圈
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 主题信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getThemeDisplayName(scheme),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 选中指示器
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContrastLevelSection(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '对比度级别',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          themeSettings.contrastLevelDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppContrastLevel>(
            segments: AppContrastLevel.values.map((level) {
              return ButtonSegment<AppContrastLevel>(
                value: level,
                label: SizedBox(
                  width: 60, // 固定宽度
                  child: Text(
                    _getContrastLevelDisplayName(level),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
            selected: {themeSettings.contrastLevel},
            onSelectionChanged: (Set<AppContrastLevel> selection) {
              if (selection.isNotEmpty) {
                themeNotifier.setContrastLevel(selection.first);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorModeSection(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '颜色模式',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          themeSettings.colorModeDisplayName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppColorMode>(
            segments: AppColorMode.values.map((mode) {
              return ButtonSegment<AppColorMode>(
                value: mode,
                label: SizedBox(
                  width: 70, // 固定宽度
                  child: Text(
                    _getColorModeDisplayName(mode),
                    textAlign: TextAlign.center,
                  ),
                ),
                icon: Icon(_getColorModeIcon(mode), size: 18),
              );
            }).toList(),
            selected: {themeSettings.colorMode},
            onSelectionChanged: (Set<AppColorMode> selection) {
              if (selection.isNotEmpty) {
                themeNotifier.setColorMode(selection.first);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicColorSection(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return SwitchListTile(
      title: const Text('动态颜色'),
      subtitle: const Text('使用系统壁纸颜色'),
      value: themeSettings.dynamicColorEnabled,
      onChanged: (value) {
        themeNotifier.setDynamicColor(value);
      },
    );
  }

  String _getThemeDisplayName(AppThemeScheme scheme) {
    switch (scheme) {
      case AppThemeScheme.ocean:
        return '海洋蓝';
      case AppThemeScheme.monochrome:
        return '极简灰';
      case AppThemeScheme.forest:
        return '森林绿';
      case AppThemeScheme.warmOrange:
        return '暖橙';
    }
  }

  String _getContrastLevelDisplayName(AppContrastLevel level) {
    switch (level) {
      case AppContrastLevel.standard:
        return '标准';
      case AppContrastLevel.medium:
        return '中对比';
      case AppContrastLevel.high:
        return '高对比';
    }
  }

  String _getColorModeDisplayName(AppColorMode mode) {
    switch (mode) {
      case AppColorMode.system:
        return '跟随系统';
      case AppColorMode.light:
        return '浅色';
      case AppColorMode.dark:
        return '深色';
    }
  }

  IconData _getColorModeIcon(AppColorMode mode) {
    switch (mode) {
      case AppColorMode.system:
        return Icons.brightness_auto;
      case AppColorMode.light:
        return Icons.brightness_7;
      case AppColorMode.dark:
        return Icons.brightness_2;
    }
  }
}
