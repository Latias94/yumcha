// ⚙️ 配置管理区域组件
//
// AI设置界面中的配置管理区域，基于新的统一AI管理架构。
// 提供配置的快速管理和操作功能。
//
// 🎯 **主要功能**:
// - 🔧 **配置状态**: 显示当前配置的完整性状态
// - 💾 **备份管理**: 提供配置备份和恢复功能
// - 📤 **导入导出**: 支持配置的导入和导出
// - 🎯 **配置向导**: 提供配置向导入口
// - 📱 **响应式设计**: 适配不同屏幕尺寸
//
// 🎨 **设计特点**:
// - 功能卡片布局，清晰分类
// - 状态指示器，直观显示配置状态
// - 快速操作按钮，提升用户体验
// - 引导性提示，帮助用户完成配置

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';
import '../screens/configuration_wizard_screen.dart';

class ConfigurationManagementSection extends ConsumerWidget {
  const ConfigurationManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);
    
    final hasCompleteConfig = ref.watch(hasCompleteConfigurationProvider);
    final needsBackup = ref.watch(needsConfigBackupProvider);
    final providerStats = ref.watch(providerStatsProvider);
    final assistantStats = ref.watch(assistantStatsProvider);

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,
        vertical: DesignConstants.spaceM,
      ),
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            _buildHeader(context, theme),
            
            SizedBox(height: DesignConstants.spaceL),
            
            // 配置状态卡片
            _buildConfigurationStatus(
              context,
              theme,
              hasCompleteConfig,
              providerStats,
              assistantStats,
            ),
            
            SizedBox(height: DesignConstants.spaceL),
            
            // 操作按钮网格
            _buildActionGrid(
              context,
              theme,
              deviceType,
              hasCompleteConfig,
              needsBackup,
              ref,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.settings_outlined,
          size: DesignConstants.iconSizeL,
          color: theme.colorScheme.tertiary,
        ),
        SizedBox(width: DesignConstants.spaceM),
        Text(
          '配置管理',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationStatus(
    BuildContext context,
    ThemeData theme,
    bool hasCompleteConfig,
    ({int total, int enabled, int connected}) providerStats,
    ({int total, int enabled, int custom}) assistantStats,
  ) {
    final statusColor = hasCompleteConfig 
        ? theme.colorScheme.tertiary 
        : theme.colorScheme.error;
    final statusIcon = hasCompleteConfig 
        ? Icons.check_circle_outline 
        : Icons.warning_outlined;
    final statusText = hasCompleteConfig 
        ? '配置完整' 
        : '配置不完整';
    
    return Container(
      width: double.infinity,
      padding: DesignConstants.paddingL,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusMValue),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: DesignConstants.iconSizeL,
              ),
              SizedBox(width: DesignConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: DesignConstants.spaceXS),
                    Text(
                      _getConfigurationDescription(
                        hasCompleteConfig,
                        providerStats,
                        assistantStats,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (!hasCompleteConfig) ...[
            SizedBox(height: DesignConstants.spaceL),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: 启动配置向导
                  _showConfigurationWizard(context);
                },
                icon: Icon(Icons.auto_fix_high, size: DesignConstants.iconSizeS),
                label: const Text('启动配置向导'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    bool hasCompleteConfig,
    bool needsBackup,
    WidgetRef ref,
  ) {
    final crossAxisCount = deviceType == DeviceType.mobile ? 2 : 4;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: DesignConstants.spaceM,
      crossAxisSpacing: DesignConstants.spaceM,
      childAspectRatio: deviceType == DeviceType.mobile ? 1.5 : 2.0,
      children: [
        // 配置向导
        _buildActionCard(
          context,
          theme,
          icon: Icons.auto_fix_high_outlined,
          title: '配置向导',
          subtitle: '快速配置',
          onTap: () => _showConfigurationWizard(context),
        ),
        
        // 备份配置
        _buildActionCard(
          context,
          theme,
          icon: needsBackup ? Icons.backup_outlined : Icons.cloud_done_outlined,
          title: '备份配置',
          subtitle: needsBackup ? '需要备份' : '已备份',
          color: needsBackup ? theme.colorScheme.error : null,
          onTap: hasCompleteConfig ? () => _showBackupDialog(context, ref) : null,
        ),
        
        // 导出配置
        _buildActionCard(
          context,
          theme,
          icon: Icons.file_download_outlined,
          title: '导出配置',
          subtitle: '保存到文件',
          onTap: hasCompleteConfig ? () => _exportConfiguration(context, ref) : null,
        ),
        
        // 导入配置
        _buildActionCard(
          context,
          theme,
          icon: Icons.file_upload_outlined,
          title: '导入配置',
          subtitle: '从文件恢复',
          onTap: () => _importConfiguration(context, ref),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    VoidCallback? onTap,
  }) {
    final cardColor = color ?? theme.colorScheme.primary;
    final isEnabled = onTap != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignConstants.radiusMValue),
        child: Container(
          decoration: BoxDecoration(
            color: isEnabled
                ? cardColor.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(DesignConstants.radiusMValue),
            border: Border.all(
              color: isEnabled
                  ? cardColor.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          padding: DesignConstants.paddingM,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: DesignConstants.iconSizeL,
                color: isEnabled 
                    ? cardColor
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              SizedBox(height: DesignConstants.spaceS),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isEnabled 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignConstants.spaceXS),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isEnabled 
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getConfigurationDescription(
    bool hasCompleteConfig,
    ({int total, int enabled, int connected}) providerStats,
    ({int total, int enabled, int custom}) assistantStats,
  ) {
    if (hasCompleteConfig) {
      return '您已配置 ${providerStats.enabled} 个提供商和 ${assistantStats.enabled} 个助手';
    } else {
      final issues = <String>[];
      if (providerStats.enabled == 0) issues.add('缺少AI提供商');
      if (assistantStats.enabled == 0) issues.add('缺少AI助手');
      return '${issues.join('、')}，请完成配置';
    }
  }

  void _showConfigurationWizard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfigurationWizardScreen(),
      ),
    );
  }

  void _showBackupDialog(BuildContext context, WidgetRef ref) {
    // TODO: 实现备份对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('备份功能即将推出')),
    );
  }

  void _exportConfiguration(BuildContext context, WidgetRef ref) {
    // TODO: 实现配置导出
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能即将推出')),
    );
  }

  void _importConfiguration(BuildContext context, WidgetRef ref) {
    // TODO: 实现配置导入
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能即将推出')),
    );
  }
}
