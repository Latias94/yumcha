import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_provider.dart';
import '../widgets/enhanced_theme_selector.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 集成主题测试页面
/// 用于测试集成了自定义主题功能的主题选择器
class IntegratedThemeTestPage extends ConsumerWidget {
  const IntegratedThemeTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeSettings = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('集成主题设置测试'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前主题状态卡片
            _buildThemeStatusCard(theme, themeSettings),
            SizedBox(height: DesignConstants.spaceXXL),

            // 集成的主题选择器
            const EnhancedThemeSelector(),
            SizedBox(height: DesignConstants.spaceXXL),

            // 主题效果预览
            _buildThemePreview(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeStatusCard(ThemeData theme, ThemeSettings themeSettings) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '当前主题状态',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            _buildStatusRow('主题方案', themeSettings.themeSchemeDisplayName),
            _buildStatusRow('颜色模式', themeSettings.colorModeDisplayName),
            _buildStatusRow('对比度', themeSettings.contrastLevelDisplayName),
            _buildStatusRow(
                '动态颜色', themeSettings.dynamicColorEnabled ? '已启用' : '已禁用'),
            if (themeSettings.themeScheme == AppThemeScheme.custom) ...[
              const Divider(),
              SizedBox(height: DesignConstants.spaceS),
              _buildColorStatusRow('主色调', theme.colorScheme.primary),
              _buildColorStatusRow('次要色', theme.colorScheme.secondary),
              _buildColorStatusRow('表面色', theme.colorScheme.surface),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignConstants.spaceXS),
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

  Widget _buildColorStatusRow(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignConstants.spaceXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              SizedBox(width: DesignConstants.spaceS),
              Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
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
              '主题效果预览',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 按钮组预览
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text'),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 输入框预览
            TextField(
              decoration: InputDecoration(
                labelText: '输入框示例',
                hintText: '请输入内容',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 芯片预览
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('标签'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                ActionChip(
                  label: const Text('操作'),
                  onPressed: () {},
                ),
                FilterChip(
                  label: const Text('过滤'),
                  selected: true,
                  onSelected: (selected) {},
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 列表项预览
            ListTile(
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
                size: 16,
              ),
              tileColor: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: DesignConstants.radiusM,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
