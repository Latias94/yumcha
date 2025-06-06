import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';

/// AI提供商列表Widget
/// 演示如何使用Riverpod管理状态
class ProviderListWidget extends ConsumerWidget {
  const ProviderListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(aiProviderNotifierProvider);

    return providersAsync.when(
      data: (providers) => _buildProviderList(context, ref, providers),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(aiProviderNotifierProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderList(
    BuildContext context,
    WidgetRef ref,
    List<AiProvider> providers,
  ) {
    if (providers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无AI提供商'),
            Text('请添加一个AI提供商开始使用', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(aiProviderNotifierProvider);
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: provider.isEnabled ? Colors.green : Colors.grey,
          child: Icon(_getProviderIcon(provider.type), color: Colors.white),
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
                    .read(aiProviderNotifierProvider.notifier)
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
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('删除', style: TextStyle(color: Colors.red)),
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
      case ProviderType.ollama:
        return Icons.computer;
      case ProviderType.custom:
        return Icons.settings;
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
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.custom:
        return '自定义';
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
                    .read(aiProviderNotifierProvider.notifier)
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
