import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../app/theme/theme_color_schemes.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 主题快速操作组件
/// 提供快速切换主题和设置自定义颜色的功能
class ThemeQuickActions extends ConsumerWidget {
  const ThemeQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Card(
      margin: DesignConstants.paddingM,
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题快速设置',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 预设主题快速选择
            Text(
              '预设主题',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildPresetThemes(themeSettings, themeNotifier),
            const SizedBox(height: 16),

            // 自定义主题快速设置
            if (themeSettings.themeScheme == AppThemeScheme.custom) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '自定义颜色',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomColorQuickSet(themeNotifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetThemes(
      ThemeSettings themeSettings, ThemeNotifier themeNotifier) {
    final presetThemes = [
      AppThemeScheme.ocean,
      AppThemeScheme.monochrome,
      AppThemeScheme.forest,
      AppThemeScheme.warmOrange,
      AppThemeScheme.custom,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetThemes.map((scheme) {
        final isSelected = themeSettings.themeScheme == scheme;
        final displayName = _getThemeDisplayName(scheme);
        final primaryColor = _getThemePrimaryColor(scheme);

        return GestureDetector(
          onTap: () => themeNotifier.setThemeScheme(scheme),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : null,
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: DesignConstants.radiusM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? primaryColor : null,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: primaryColor,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomColorQuickSet(ThemeNotifier themeNotifier) {
    // 预定义的快速颜色选项
    final quickColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速选择颜色',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: quickColors.length,
          itemBuilder: (context, index) {
            final color = quickColors[index];

            return GestureDetector(
              onTap: () => _selectCustomColor(themeNotifier, color),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const SizedBox(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // 随机颜色按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _generateRandomColor(themeNotifier),
            icon: const Icon(Icons.shuffle),
            label: const Text('随机生成颜色'),
          ),
        ),
      ],
    );
  }

  void _selectCustomColor(ThemeNotifier themeNotifier, Color color) {
    // 启用自定义颜色并设置颜色
    themeNotifier.setUseCustomColors(true);
    themeNotifier.setCustomPrimaryColor(color);
  }

  void _generateRandomColor(ThemeNotifier themeNotifier) {
    // 生成随机颜色
    final random = DateTime.now().millisecondsSinceEpoch;
    final hue = (random % 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();

    _selectCustomColor(themeNotifier, color);
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
      case AppThemeScheme.custom:
        return '自定义';
    }
  }

  Color _getThemePrimaryColor(AppThemeScheme scheme) {
    switch (scheme) {
      case AppThemeScheme.ocean:
        return const Color(0xFF006782);
      case AppThemeScheme.monochrome:
        return const Color(0xFF2B2C2D);
      case AppThemeScheme.forest:
        return const Color(0xFF2E7D32);
      case AppThemeScheme.warmOrange:
        return const Color(0xFFBF360C);
      case AppThemeScheme.custom:
        return Colors.blue; // 默认颜色
    }
  }
}
