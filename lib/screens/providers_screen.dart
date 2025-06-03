import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_provider.dart';
import '../services/notification_service.dart';
import '../providers/ai_provider_notifier.dart';
import 'provider_edit_screen.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  Future<void> _deleteProvider(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(aiProviderNotifierProvider.notifier).deleteProvider(id);
      NotificationService().showSuccess('提供商已删除');
    } catch (e) {
      NotificationService().showError('删除失败: $e');
    }
  }

  Future<void> _toggleProvider(WidgetRef ref, String id) async {
    try {
      await ref
          .read(aiProviderNotifierProvider.notifier)
          .toggleProviderEnabled(id);
    } catch (e) {
      NotificationService().showError('切换状态失败: $e');
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    AiProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除提供商 "${provider.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProvider(context, ref, provider.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _getProviderTypeDisplayName(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.google:
        return 'Google';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.custom:
        return '自定义';
    }
  }

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return Icons.flash_on_outlined;
      case ProviderType.anthropic:
        return Icons.ac_unit_outlined;
      case ProviderType.google:
        return Icons.g_mobiledata_outlined;
      case ProviderType.ollama:
        return Icons.memory_outlined;
      case ProviderType.custom:
        return Icons.settings_input_component_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(aiProviderNotifierProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('提供商'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderEditScreen(),
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(aiProviderNotifierProvider);
                  }
                },
              ),
            ],
          ),
          // 使用providersAsync来渲染内容
          providersAsync.when(
            data: (providers) {
              if (providers.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无提供商',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击右上角的 + 按钮添加一个',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final provider = providers[index];
                  final colorScheme = Theme.of(context).colorScheme;

                  return Card(
                    elevation: 1,
                    color: colorScheme.surfaceContainerHighest,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getProviderIcon(provider.type),
                                size: 32,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '类型: ${_getProviderTypeDisplayName(provider.type)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      '模型: ${provider.supportedModels.length} 个',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: provider.isEnabled,
                                onChanged: (_) =>
                                    _toggleProvider(ref, provider.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('编辑'),
                                onPressed: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProviderEditScreen(
                                        provider: provider,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    ref.invalidate(aiProviderNotifierProvider);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                ),
                                label: Text(
                                  '删除',
                                  style: TextStyle(color: colorScheme.error),
                                ),
                                onPressed: () =>
                                    _showDeleteDialog(context, ref, provider),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: providers.length),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(height: 16),
                      Text('加载失败: $error'),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(aiProviderNotifierProvider),
                        child: Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
