// 🔌 提供商管理区域组件
//
// AI设置界面中的提供商管理区域，基于新的统一AI管理架构。
// 提供提供商的快速管理和配置功能。
//
// 🎯 **主要功能**:
// - 📋 **提供商列表**: 显示已配置的AI提供商
// - ➕ **快速添加**: 提供快速添加提供商的入口
// - ⚙️ **状态管理**: 显示提供商的启用/连接状态
// - 🔧 **快速操作**: 提供启用/禁用、编辑等快速操作
// - 📱 **响应式设计**: 适配不同屏幕尺寸
//
// 🎨 **设计特点**:
// - 卡片式布局，清晰展示提供商信息
// - 状态指示器，直观显示连接状态
// - 快速操作按钮，提升用户体验
// - 空状态提示，引导用户添加提供商

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';
import '../screens/providers_screen.dart';
import '../screens/provider_edit_screen.dart';
import '../../domain/entities/ai_provider.dart';

class ProvidersManagementSection extends ConsumerWidget {
  const ProvidersManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);
    
    final providers = ref.watch(aiProvidersProvider);
    final enabledProviders = ref.watch(enabledAiProvidersProvider);
    final connectedProviders = ref.watch(connectedAiProvidersProvider);

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
            // 标题和操作按钮
            _buildHeader(context, theme, ref),
            
            SizedBox(height: DesignConstants.spaceL),
            
            // 提供商列表或空状态
            if (providers.isEmpty)
              _buildEmptyState(context, theme, ref)
            else
              _buildProvidersList(
                context,
                theme,
                deviceType,
                providers,
                enabledProviders,
                connectedProviders,
                ref,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Row(
      children: [
        Icon(
          Icons.cloud_outlined,
          size: DesignConstants.iconSizeL,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: DesignConstants.spaceM),
        Expanded(
          child: Text(
            'AI提供商',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 查看全部按钮
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProvidersScreen(),
              ),
            );
          },
          icon: Icon(Icons.arrow_forward, size: DesignConstants.iconSizeS),
          label: const Text('查看全部'),
        ),
        SizedBox(width: DesignConstants.spaceS),
        // 添加按钮
        FilledButton.icon(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => const ProviderEditScreen(),
              ),
            );
            if (result == true) {
              ref.invalidate(unifiedAiManagementProvider);
            }
          },
          icon: Icon(Icons.add, size: DesignConstants.iconSizeS),
          label: const Text('添加'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: DesignConstants.paddingXL,
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: DesignConstants.iconSizeXXL,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: DesignConstants.spaceL),
          Text(
            '暂无AI提供商',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DesignConstants.spaceS),
          Text(
            '添加AI提供商来开始使用AI功能',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignConstants.spaceL),
          FilledButton.icon(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderEditScreen(),
                ),
              );
              if (result == true) {
                ref.invalidate(unifiedAiManagementProvider);
              }
            },
            icon: Icon(Icons.add, size: DesignConstants.iconSizeS),
            label: const Text('添加第一个提供商'),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    List<AiProvider> providers,
    List<AiProvider> enabledProviders,
    List<AiProvider> connectedProviders,
    WidgetRef ref,
  ) {
    // 显示前3个提供商
    final displayProviders = providers.take(3).toList();
    
    return Column(
      children: [
        ...displayProviders.map((provider) => _buildProviderItem(
          context,
          theme,
          provider,
          enabledProviders.contains(provider),
          connectedProviders.contains(provider),
          ref,
        )),
        
        if (providers.length > 3) ...[
          SizedBox(height: DesignConstants.spaceM),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProvidersScreen(),
                ),
              );
            },
            child: Text('查看全部 ${providers.length} 个提供商'),
          ),
        ],
      ],
    );
  }

  Widget _buildProviderItem(
    BuildContext context,
    ThemeData theme,
    AiProvider provider,
    bool isEnabled,
    bool isConnected,
    WidgetRef ref,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceM),
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(DesignConstants.radiusMValue),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 提供商图标和状态
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignConstants.radiusSValue),
                ),
                child: Icon(
                  _getProviderIcon(provider.type.name),
                  color: theme.colorScheme.primary,
                ),
              ),
              // 状态指示器
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? theme.colorScheme.tertiary
                        : isEnabled
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(width: DesignConstants.spaceM),
          
          // 提供商信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: DesignConstants.spaceXS),
                Text(
                  '${provider.models.length} 个模型 • ${_getStatusText(isEnabled, isConnected)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // 快速操作按钮
          IconButton(
            onPressed: () async {
              await ref
                  .read(aiManagementActionsProvider)
                  .toggleProviderEnabled(provider.id);
            },
            icon: Icon(
              isEnabled ? Icons.toggle_on : Icons.toggle_off,
              color: isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            tooltip: isEnabled ? '禁用' : '启用',
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'openai':
        return Icons.psychology_outlined;
      case 'anthropic':
        return Icons.smart_toy_outlined;
      case 'google':
        return Icons.auto_awesome_outlined;
      case 'ollama':
        return Icons.computer_outlined;
      case 'deepseek':
        return Icons.explore_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  String _getStatusText(bool isEnabled, bool isConnected) {
    if (isConnected) return '已连接';
    if (isEnabled) return '已启用';
    return '已禁用';
  }
}
