// 🤖 助手管理区域组件
//
// AI设置界面中的助手管理区域，基于新的统一AI管理架构。
// 提供助手的快速管理和配置功能。
//
// 🎯 **主要功能**:
// - 📋 **助手列表**: 显示已配置的AI助手
// - ➕ **快速添加**: 提供快速添加助手的入口
// - ⚙️ **状态管理**: 显示助手的启用状态
// - 🔧 **快速操作**: 提供启用/禁用、编辑等快速操作
// - 📱 **响应式设计**: 适配不同屏幕尺寸
//
// 🎨 **设计特点**:
// - 卡片式布局，清晰展示助手信息
// - 表情符号图标，个性化展示
// - 快速操作按钮，提升用户体验
// - 空状态提示，引导用户添加助手

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';
import '../screens/assistants_screen.dart';
import '../screens/assistant_edit_screen.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../domain/entities/ai_provider.dart';

class AssistantsManagementSection extends ConsumerWidget {
  const AssistantsManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);
    
    final assistants = ref.watch(aiAssistantsProvider);
    final enabledAssistants = ref.watch(enabledAiAssistantsProvider);
    final providers = ref.watch(aiProvidersProvider);

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
            _buildHeader(context, theme, ref, providers),
            
            SizedBox(height: DesignConstants.spaceL),
            
            // 助手列表或空状态
            if (assistants.isEmpty)
              _buildEmptyState(context, theme, ref, providers)
            else
              _buildAssistantsList(
                context,
                theme,
                deviceType,
                assistants,
                enabledAssistants,
                ref,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref, List<AiProvider> providers) {
    return Row(
      children: [
        Icon(
          Icons.smart_toy_outlined,
          size: DesignConstants.iconSizeL,
          color: theme.colorScheme.secondary,
        ),
        SizedBox(width: DesignConstants.spaceM),
        Expanded(
          child: Text(
            'AI助手',
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
                builder: (context) => const AssistantsScreen(),
              ),
            );
          },
          icon: Icon(Icons.arrow_forward, size: DesignConstants.iconSizeS),
          label: const Text('查看全部'),
        ),
        SizedBox(width: DesignConstants.spaceS),
        // 添加按钮
        FilledButton.icon(
          onPressed: providers.isEmpty ? null : () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AssistantEditScreen(providers: providers),
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

  Widget _buildEmptyState(BuildContext context, ThemeData theme, WidgetRef ref, List<AiProvider> providers) {
    return Container(
      width: double.infinity,
      padding: DesignConstants.paddingXL,
      child: Column(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: DesignConstants.iconSizeXXL,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: DesignConstants.spaceL),
          Text(
            '暂无AI助手',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DesignConstants.spaceS),
          Text(
            providers.isEmpty 
                ? '请先添加AI提供商，然后创建助手'
                : '创建AI助手来个性化您的聊天体验',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignConstants.spaceL),
          FilledButton.icon(
            onPressed: providers.isEmpty ? null : () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AssistantEditScreen(providers: providers),
                ),
              );
              if (result == true) {
                ref.invalidate(unifiedAiManagementProvider);
              }
            },
            icon: Icon(Icons.add, size: DesignConstants.iconSizeS),
            label: const Text('创建第一个助手'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantsList(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    List<AiAssistant> assistants,
    List<AiAssistant> enabledAssistants,
    WidgetRef ref,
  ) {
    // 显示前3个助手
    final displayAssistants = assistants.take(3).toList();
    
    return Column(
      children: [
        ...displayAssistants.map((assistant) => _buildAssistantItem(
          context,
          theme,
          assistant,
          enabledAssistants.contains(assistant),
          ref,
        )),
        
        if (assistants.length > 3) ...[
          SizedBox(height: DesignConstants.spaceM),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssistantsScreen(),
                ),
              );
            },
            child: Text('查看全部 ${assistants.length} 个助手'),
          ),
        ],
      ],
    );
  }

  Widget _buildAssistantItem(
    BuildContext context,
    ThemeData theme,
    AiAssistant assistant,
    bool isEnabled,
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
          // 助手头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignConstants.radiusSValue),
            ),
            child: Center(
              child: Text(
                assistant.avatar.isNotEmpty ? assistant.avatar : '🤖',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          SizedBox(width: DesignConstants.spaceM),
          
          // 助手信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assistant.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: DesignConstants.spaceXS),
                Text(
                  assistant.description.isNotEmpty 
                      ? assistant.description
                      : '暂无描述',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 状态指示器
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceS,
              vertical: DesignConstants.spaceXS,
            ),
            decoration: BoxDecoration(
              color: isEnabled
                  ? theme.colorScheme.secondary.withOpacity(0.1)
                  : theme.colorScheme.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignConstants.radiusSValue),
            ),
            child: Text(
              isEnabled ? '已启用' : '已禁用',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isEnabled
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          SizedBox(width: DesignConstants.spaceS),
          
          // 快速操作按钮
          IconButton(
            onPressed: () async {
              await ref
                  .read(aiManagementActionsProvider)
                  .toggleAssistantEnabled(assistant.id);
            },
            icon: Icon(
              isEnabled ? Icons.toggle_on : Icons.toggle_off,
              color: isEnabled
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.outline,
            ),
            tooltip: isEnabled ? '禁用' : '启用',
          ),
        ],
      ),
    );
  }
}
