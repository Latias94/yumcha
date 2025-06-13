import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../app/theme/theme_color_schemes.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 自定义主题设置组件
/// 允许用户配置自定义主题的颜色
class CustomThemeSettings extends ConsumerStatefulWidget {
  const CustomThemeSettings({super.key});

  @override
  ConsumerState<CustomThemeSettings> createState() =>
      _CustomThemeSettingsState();
}

class _CustomThemeSettingsState extends ConsumerState<CustomThemeSettings> {
  Color? _selectedColor;
  bool _useCustomColors = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final themeNotifier = ref.read(themeProvider.notifier);
    _useCustomColors = themeNotifier.getUseCustomColors();
    _selectedColor = themeNotifier.getCustomPrimaryColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSettings = ref.watch(themeProvider);

    // 只有在选择了自定义主题时才显示此设置
    if (themeSettings.themeScheme != AppThemeScheme.custom) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: DesignConstants.paddingM,
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '自定义主题设置',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 启用自定义颜色开关
            SwitchListTile(
              title: const Text('使用自定义颜色'),
              subtitle: const Text('启用后可以自定义主题的主色调'),
              value: _useCustomColors,
              onChanged: _onUseCustomColorsChanged,
            ),

            if (_useCustomColors) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // 主色调选择
              Text(
                '主色调',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '选择一个颜色作为主题的主色调，系统会自动生成配套的颜色方案',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // 当前选择的颜色
              if (_selectedColor != null) ...[
                _buildCurrentColorDisplay(),
                const SizedBox(height: 16),
              ],

              // 推荐颜色网格
              _buildRecommendedColors(),
              const SizedBox(height: 16),

              // 自定义颜色按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showColorPicker,
                  icon: const Icon(Icons.palette),
                  label: const Text('选择其他颜色'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentColorDisplay() {
    if (_selectedColor == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorName = ThemeColorSchemes.getColorDisplayName(_selectedColor!);

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: DesignConstants.radiusM,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: DesignConstants.radiusS,
              border: Border.all(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(width: 12),
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
                  colorName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _selectColor(_selectedColor!),
            icon: const Icon(Icons.edit),
            tooltip: '编辑颜色',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedColors() {
    final theme = Theme.of(context);

    // 生成推荐颜色
    final baseColor = _selectedColor ?? Colors.blue;
    final recommendedColors =
        ThemeColorSchemes.generateRecommendedColors(baseColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐颜色',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: recommendedColors.length,
          itemBuilder: (context, index) {
            final color = recommendedColors[index];
            final isSelected = _selectedColor == color;

            return GestureDetector(
              onTap: () => _selectColor(color),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: DesignConstants.radiusS,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _getContrastColor(color),
                        size: 20,
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // 计算颜色的亮度，选择合适的对比色
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _onUseCustomColorsChanged(bool value) {
    setState(() {
      _useCustomColors = value;
    });

    final themeNotifier = ref.read(themeProvider.notifier);
    themeNotifier.setUseCustomColors(value);

    // 如果启用自定义颜色但没有选择颜色，设置默认颜色
    if (value && _selectedColor == null) {
      _selectColor(Colors.blue);
    }
  }

  void _selectColor(Color color) {
    // 验证和调整颜色
    final adjustedColor = ThemeColorSchemes.validateAndAdjustSeedColor(color);

    setState(() {
      _selectedColor = adjustedColor;
    });

    final themeNotifier = ref.read(themeProvider.notifier);
    themeNotifier.setCustomPrimaryColor(adjustedColor);
  }

  void _showColorPicker() {
    // 这里可以集成一个颜色选择器
    // 暂时使用简单的对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: const Text('颜色选择器功能即将推出'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
