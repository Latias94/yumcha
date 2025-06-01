import 'package:flutter/material.dart';
import '../models/ai_provider.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'provider_edit_screen.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  late final ProviderRepository _repository;
  List<AiProvider> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = ProviderRepository(DatabaseService.instance.database);
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    try {
      final providers = await _repository.getAllProviders();
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationService().showError('加载提供商失败: $e');
      }
    }
  }

  Future<void> _deleteProvider(String id) async {
    try {
      await _repository.deleteProvider(id);
      _loadProviders();
      if (mounted) {
        NotificationService().showSuccess('提供商已删除');
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('删除失败: $e');
      }
    }
  }

  Future<void> _toggleProvider(String id) async {
    try {
      await _repository.toggleProviderEnabled(id);
      _loadProviders();
    } catch (e) {
      if (mounted) {
        NotificationService().showError('切换状态失败: $e');
      }
    }
  }

  void _showDeleteDialog(AiProvider provider) {
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
              _deleteProvider(provider.id);
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
      default:
        return Icons.settings_input_component_outlined;
    }
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true && mounted) {
      _loadProviders();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () =>
                    _navigateAndRefresh(const ProviderEditScreen()),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _providers.isEmpty
                ? SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.6, // Adjust height
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
                  )
                : const SizedBox.shrink(),
          ),
          if (!_isLoading && _providers.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final provider = _providers[index];
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: provider.isEnabled,
                              onChanged: (_) => _toggleProvider(provider.id),
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
                              onPressed: () => _navigateAndRefresh(
                                ProviderEditScreen(provider: provider),
                              ),
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
                              onPressed: () => _showDeleteDialog(provider),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _providers.length),
            ),
        ],
      ),
    );
  }
}
