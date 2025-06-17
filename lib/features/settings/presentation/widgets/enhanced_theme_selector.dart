import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
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
        SizedBox(height: DesignConstants.spaceXXL),

        // 自定义主题设置（仅在选择自定义主题时显示）
        if (themeSettings.themeScheme == AppThemeScheme.custom) ...[
          _buildCustomThemeSection(context, themeSettings, themeNotifier),
          SizedBox(height: DesignConstants.spaceXXL),
        ],

        // 对比度级别选择
        _buildContrastLevelSection(context, themeSettings, themeNotifier),
        SizedBox(height: DesignConstants.spaceXXL),

        // 颜色模式选择
        _buildColorModeSection(context, themeSettings, themeNotifier),
        SizedBox(height: DesignConstants.spaceXXL),

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
        SizedBox(height: DesignConstants.spaceM),
        Text(
          '选择您喜欢的颜色主题',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: DesignConstants.spaceL),

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
                  themeNotifier,
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
    ThemeNotifier themeNotifier,
    VoidCallback onTap,
  ) {
    // 获取主题预览颜色
    Color primaryColor;
    if (scheme == AppThemeScheme.custom) {
      // 对于自定义主题，尝试获取用户设置的颜色
      final customColor = themeNotifier.getCustomPrimaryColor();
      primaryColor = customColor ?? Colors.blue;
    } else if (ThemeColorSchemes.hasCustomColorScheme(scheme.name)) {
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
        case AppThemeScheme.custom:
          primaryColor = Colors.blue; // 备用默认颜色
          break;
      }
    }

    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignConstants.radiusM,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignConstants.spaceM,
            vertical: DesignConstants.spaceS + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: DesignConstants.radiusM,
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
                width: DesignConstants.iconSizeM,
                height: DesignConstants.iconSizeM,
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
              SizedBox(width: DesignConstants.spaceS + 2),

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
        SizedBox(height: DesignConstants.spaceM),
        Text(
          themeSettings.contrastLevelDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: DesignConstants.spaceL),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppContrastLevel>(
            segments: AppContrastLevel.values.map((level) {
              return ButtonSegment<AppContrastLevel>(
                value: level,
                label: SizedBox(
                  width: 60,
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
        SizedBox(height: DesignConstants.spaceM),
        Text(
          themeSettings.colorModeDisplayName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: DesignConstants.spaceL),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppColorMode>(
            segments: AppColorMode.values.map((mode) {
              return ButtonSegment<AppColorMode>(
                value: mode,
                label: SizedBox(
                  width: 70,
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
      case AppThemeScheme.custom:
        return '自定义';
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

  Widget _buildCustomThemeSection(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return _CustomThemeSettings(themeNotifier: themeNotifier);
  }
}

/// 自定义主题设置组件（集成到主题选择器中）
class _CustomThemeSettings extends ConsumerStatefulWidget {
  final ThemeNotifier themeNotifier;

  const _CustomThemeSettings({required this.themeNotifier});

  @override
  ConsumerState<_CustomThemeSettings> createState() =>
      _CustomThemeSettingsState();
}

class _CustomThemeSettingsState extends ConsumerState<_CustomThemeSettings> {
  Color? _selectedColor;
  bool _useCustomColors = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void didUpdateWidget(_CustomThemeSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当组件更新时重新加载设置
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final newUseCustomColors = widget.themeNotifier.getUseCustomColors();
    final newSelectedColor = widget.themeNotifier.getCustomPrimaryColor();

    if (mounted &&
        (newUseCustomColors != _useCustomColors ||
            newSelectedColor != _selectedColor)) {
      setState(() {
        _useCustomColors = newUseCustomColors;
        _selectedColor = newSelectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 监听主题状态变化，确保UI同步
    ref.listen<ThemeSettings>(themeProvider, (previous, next) {
      // 当主题状态变化时，重新加载当前设置
      if (previous?.themeScheme == AppThemeScheme.custom &&
          next.themeScheme == AppThemeScheme.custom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadCurrentSettings();
        });
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义主题设置',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignConstants.spaceM),
        Text(
          '配置您的个性化主题颜色',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DesignConstants.spaceL),

        // 启用自定义颜色开关
        SwitchListTile(
          title: const Text('使用自定义颜色'),
          subtitle: const Text('启用后可以自定义主题的主色调'),
          value: _useCustomColors,
          onChanged: _onUseCustomColorsChanged,
          contentPadding: EdgeInsets.zero,
        ),

        if (_useCustomColors) ...[
          SizedBox(height: DesignConstants.spaceL),

          // 当前选择的颜色
          if (_selectedColor != null) ...[
            _buildCurrentColorDisplay(),
            SizedBox(height: DesignConstants.spaceL),
          ],

          // 快速颜色选择
          _buildQuickColorSelection(),
        ],
      ],
    );
  }

  Widget _buildCurrentColorDisplay() {
    if (_selectedColor == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: DesignConstants.radiusM,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: DesignConstants.radiusS,
              border: Border.all(color: theme.colorScheme.outline),
            ),
          ),
          SizedBox(width: DesignConstants.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前主色调',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _getColorDisplayName(_selectedColor!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickColorSelection() {
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
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速选择颜色',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: DesignConstants.spaceS),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: quickColors.length,
          itemBuilder: (context, index) {
            final color = quickColors[index];
            final isSelected = _selectedColor == color;

            return GestureDetector(
              onTap: () async => await _selectColor(color),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: DesignConstants.radiusS,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _getContrastColor(color),
                        size: 16,
                      )
                    : null,
              ),
            );
          },
        ),
        SizedBox(height: DesignConstants.spaceM),

        // 随机颜色按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generateRandomColor,
            icon: const Icon(Icons.shuffle, size: 18),
            label: const Text('随机生成颜色'),
          ),
        ),
      ],
    );
  }

  void _onUseCustomColorsChanged(bool value) async {
    setState(() {
      _useCustomColors = value;
    });

    // 异步保存设置
    await widget.themeNotifier.setUseCustomColors(value);

    // 如果启用自定义颜色但没有选择颜色，设置默认颜色
    if (value && _selectedColor == null) {
      await _selectColor(Colors.blue);
    }
  }

  Future<void> _selectColor(Color color) async {
    setState(() {
      _selectedColor = color;
    });

    // 异步保存自定义颜色
    await widget.themeNotifier.setCustomPrimaryColor(color);
  }

  void _generateRandomColor() {
    // 生成随机颜色
    final random = DateTime.now().millisecondsSinceEpoch;
    final hue = (random % 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();

    _selectColor(color);
  }

  Color _getContrastColor(Color color) {
    // 计算颜色的亮度，选择合适的对比色
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  String _getColorDisplayName(Color color) {
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;

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

    return baseName;
  }
}
