// 📊 AI管理统计信息卡片
//
// 显示AI管理模块的统计信息，包括提供商、助手、配置状态等关键指标。
// 基于新的统一AI管理架构，提供实时的状态展示。
//
// 🎯 **主要功能**:
// - 📈 **统计展示**: 显示提供商和助手的数量统计
// - 🔗 **连接状态**: 显示已连接的提供商数量
// - ⚙️ **配置状态**: 显示配置完整性和备份状态
// - 🎨 **视觉设计**: 使用卡片布局和图标展示
// - 📱 **响应式**: 适配不同屏幕尺寸
//
// 📊 **统计指标**:
// - 提供商总数/已启用数/已连接数
// - 助手总数/已启用数/自定义数
// - 配置完整性状态
// - 备份需求提醒

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';

class AiManagementStatsCard extends ConsumerWidget {
  const AiManagementStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    // 获取统计数据
    final providerStats = ref.watch(providerStatsProvider);
    final assistantStats = ref.watch(assistantStatsProvider);
    final hasCompleteConfig = ref.watch(hasCompleteConfigurationProvider);
    final needsBackup = ref.watch(needsConfigBackupProvider);
    final isLoading = ref.watch(isAiManagementLoadingProvider);
    final hasError = ref.watch(hasAiManagementErrorProvider);

    if (isLoading) {
      return _buildLoadingCard(context, theme);
    }

    if (hasError) {
      return _buildErrorCard(context, theme);
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(DesignConstants.spaceL),
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.dashboard_outlined,
                  size: DesignConstants.iconSizeL,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  'AI管理概览',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: DesignConstants.spaceL),

            // 统计信息网格
            _buildStatsGrid(
              context,
              theme,
              deviceType,
              providerStats,
              assistantStats,
              hasCompleteConfig,
              needsBackup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(DesignConstants.spaceL),
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: DesignConstants.spaceM),
            Text(
              '加载统计信息...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(DesignConstants.spaceL),
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: DesignConstants.iconSizeXL,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: DesignConstants.spaceM),
            Text(
              '加载统计信息失败',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    ({int total, int enabled, int connected}) providerStats,
    ({int total, int enabled, int custom}) assistantStats,
    bool hasCompleteConfig,
    bool needsBackup,
  ) {
    final crossAxisCount = deviceType == DeviceType.mobile ? 2 : 4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: DesignConstants.spaceM,
      crossAxisSpacing: DesignConstants.spaceM,
      childAspectRatio: deviceType == DeviceType.mobile ? 1.2 : 1.5,
      children: [
        // 提供商统计
        _buildStatItem(
          context,
          theme,
          icon: Icons.cloud_outlined,
          title: '提供商',
          value: '${providerStats.enabled}/${providerStats.total}',
          subtitle: '${providerStats.connected} 已连接',
          color: theme.colorScheme.primary,
        ),

        // 助手统计
        _buildStatItem(
          context,
          theme,
          icon: Icons.smart_toy_outlined,
          title: '助手',
          value: '${assistantStats.enabled}/${assistantStats.total}',
          subtitle: '${assistantStats.custom} 自定义',
          color: theme.colorScheme.secondary,
        ),

        // 配置状态
        _buildStatItem(
          context,
          theme,
          icon: hasCompleteConfig
              ? Icons.check_circle_outline
              : Icons.warning_outlined,
          title: '配置',
          value: hasCompleteConfig ? '完整' : '不完整',
          subtitle: hasCompleteConfig ? '配置正常' : '需要配置',
          color: hasCompleteConfig
              ? theme.colorScheme.tertiary
              : theme.colorScheme.error,
        ),

        // 备份状态
        _buildStatItem(
          context,
          theme,
          icon: needsBackup ? Icons.backup_outlined : Icons.cloud_done_outlined,
          title: '备份',
          value: needsBackup ? '需要' : '最新',
          subtitle: needsBackup ? '建议备份' : '已同步',
          color: needsBackup
              ? theme.colorScheme.error
              : theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusMValue),
        border: Border.all(
          color: color.withOpacity(0.2),
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
            color: color,
          ),
          SizedBox(height: DesignConstants.spaceS),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignConstants.spaceXS),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignConstants.spaceXS),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
