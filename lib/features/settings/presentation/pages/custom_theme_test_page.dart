import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_provider.dart';
import '../widgets/custom_theme_settings.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 自定义主题测试页面
/// 用于测试和演示自定义主题功能
class CustomThemeTestPage extends ConsumerWidget {
  const CustomThemeTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeSettings = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义主题测试'),
        actions: [
          // 主题切换按钮
          PopupMenuButton<AppThemeScheme>(
            icon: const Icon(Icons.palette),
            onSelected: (scheme) {
              ref.read(themeProvider.notifier).setThemeScheme(scheme);
            },
            itemBuilder: (context) => AppThemeScheme.values.map((scheme) {
              return PopupMenuItem(
                value: scheme,
                child: Row(
                  children: [
                    Icon(
                      themeSettings.themeScheme == scheme
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    const SizedBox(width: 8),
                    Text(_getThemeDisplayName(scheme)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前主题信息
            _buildCurrentThemeInfo(theme, themeSettings),
            const SizedBox(height: 24),

            // 自定义主题设置
            const CustomThemeSettings(),
            const SizedBox(height: 24),

            // 主题预览组件
            _buildThemePreview(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentThemeInfo(ThemeData theme, ThemeSettings themeSettings) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前主题信息',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('主题方案', themeSettings.themeSchemeDisplayName),
            _buildInfoRow('颜色模式', themeSettings.colorModeDisplayName),
            _buildInfoRow('对比度', themeSettings.contrastLevelDisplayName),
            _buildInfoRow(
                '动态颜色', themeSettings.dynamicColorEnabled ? '已启用' : '已禁用'),
            if (themeSettings.themeScheme == AppThemeScheme.custom) ...[
              const Divider(),
              _buildColorRow('主色调', theme.colorScheme.primary),
              _buildColorRow('次要色', theme.colorScheme.secondary),
              _buildColorRow('表面色', theme.colorScheme.surface),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview(ThemeData theme) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题预览',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 按钮预览
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated Button'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled Button'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined Button'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 输入框预览
            const TextField(
              decoration: InputDecoration(
                labelText: '输入框示例',
                hintText: '请输入内容',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 卡片预览
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                title: const Text('列表项标题'),
                subtitle: const Text('这是一个列表项的副标题'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 芯片预览
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('标签芯片'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                ActionChip(
                  label: const Text('操作芯片'),
                  onPressed: () {},
                ),
                FilterChip(
                  label: const Text('过滤芯片'),
                  selected: true,
                  onSelected: (selected) {},
                ),
              ],
            ),
          ],
        ),
      ),
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
}
