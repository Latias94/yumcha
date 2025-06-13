import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../widgets/enhanced_theme_selector.dart';

/// 主题设置屏幕
///
/// 提供详细的主题配置选项，包括：
/// - 主题方案选择
/// - 对比度级别设置
/// - 颜色模式选择
/// - 动态颜色配置
/// - 自定义颜色设置
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("主题设置"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: DesignConstants.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主题预览卡片
                  _buildThemePreviewCard(context),
                  SizedBox(height: DesignConstants.spaceXXL),

                  // 增强的主题选择器
                  const EnhancedThemeSelector(),
                  SizedBox(height: DesignConstants.spaceXXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: DesignConstants.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '主题预览',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 颜色样本展示
            _buildColorSamples(context),
            SizedBox(height: DesignConstants.spaceL),

            // 组件预览
            _buildComponentPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSamples(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '颜色样本',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: DesignConstants.spaceM),

        // 主要颜色
        Row(
          children: [
            _buildColorSample(context, '主色', colorScheme.primary),
            SizedBox(width: DesignConstants.spaceM),
            _buildColorSample(context, '次色', colorScheme.secondary),
            SizedBox(width: DesignConstants.spaceM),
            _buildColorSample(context, '第三色', colorScheme.tertiary),
          ],
        ),
        SizedBox(height: DesignConstants.spaceS),

        // 表面颜色
        Row(
          children: [
            _buildColorSample(context, '表面', colorScheme.surface),
            SizedBox(width: DesignConstants.spaceM),
            _buildColorSample(context, '背景', colorScheme.surface),
            SizedBox(width: DesignConstants.spaceM),
            _buildColorSample(context, '轮廓', colorScheme.outline),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSample(BuildContext context, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: DesignConstants.radiusS,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
          SizedBox(height: DesignConstants.spaceXS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComponentPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '组件预览',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: DesignConstants.spaceM),

        // 按钮预览
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('填充按钮'),
              ),
            ),
            SizedBox(width: DesignConstants.spaceS),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('轮廓按钮'),
              ),
            ),
          ],
        ),
        SizedBox(height: DesignConstants.spaceM),

        // 卡片和芯片预览
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: DesignConstants.paddingM,
                  child: Text(
                    '示例卡片',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(width: DesignConstants.spaceS),
            Chip(
              label: const Text('芯片'),
              avatar: Icon(
                Icons.star,
                size: DesignConstants.iconSizeS,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
