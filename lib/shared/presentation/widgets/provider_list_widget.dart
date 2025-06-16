import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';
import '../design_system/design_constants.dart';

/// AI提供商列表Widget
/// 演示如何使用Riverpod管理状态
class ProviderListWidget extends ConsumerWidget {
  const ProviderListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(aiProvidersProvider);

    return _buildProviderList(context, ref, providers);
  }

  Widget _buildProviderList(
    BuildContext context,
    WidgetRef ref,
    List<AiProvider> providers,
  ) {
    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy,
                size: DesignConstants.iconSizeXXL * 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            SizedBox(height: DesignConstants.spaceL),
            const Text('暂无AI提供商'),
            Text('请添加一个AI提供商开始使用',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unifiedAiManagementProvider);
      },
      child: ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          return _buildProviderTile(context, ref, provider);
        },
      ),
    );
  }

  Widget _buildProviderTile(
    BuildContext context,
    WidgetRef ref,
    AiProvider provider,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceL, vertical: DesignConstants.spaceS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: provider.isEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          child: Icon(_getProviderIcon(provider.type),
              color: Theme.of(context).colorScheme.onPrimary),
        ),
        title: Text(provider.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${_getProviderTypeName(provider.type)}'),
            Text('模型数量: ${provider.models.length}'),
            if (provider.baseUrl != null) Text('端点: ${provider.baseUrl}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 启用/禁用开关
            Switch(
              value: provider.isEnabled,
              onChanged: (value) async {
                await ref
                    .read(aiManagementActionsProvider)
                    .toggleProviderEnabled(provider.id);
              },
            ),
            // 更多操作菜单
            PopupMenuButton<String>(
              onSelected: (action) =>
                  _handleProviderAction(context, ref, provider, action),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit), title: Text('编辑')),
                ),
                const PopupMenuItem(
                  value: 'test',
                  child: ListTile(
                    leading: Icon(Icons.wifi_tethering),
                    title: Text('测试连接'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                    title: Text('删除',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return Icons.psychology;
      case ProviderType.anthropic:
        return Icons.auto_awesome;
      case ProviderType.google:
        return Icons.diamond;
      case ProviderType.deepseek:
        return Icons.psychology_alt;
      case ProviderType.groq:
        return Icons.speed;
      case ProviderType.ollama:
        return Icons.computer;
    }
  }

  String _getProviderTypeName(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Claude';
      case ProviderType.google:
        return 'Gemini';
      case ProviderType.deepseek:
        return 'DeepSeek';
      case ProviderType.groq:
        return 'Groq';
      case ProviderType.ollama:
        return 'Ollama';
    }
  }

  void _handleProviderAction(
    BuildContext context,
    WidgetRef ref,
    AiProvider provider,
    String action,
  ) {
    switch (action) {
      case 'edit':
        // TODO: 导航到编辑页面
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('编辑 ${provider.name}')));
        break;
      case 'test':
        // TODO: 测试提供商连接
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('测试 ${provider.name} 连接')));
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, provider);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    AiProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除提供商 "${provider.name}" 吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(aiManagementActionsProvider)
                    .deleteProvider(provider.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已删除 ${provider.name}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('删除失败: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
