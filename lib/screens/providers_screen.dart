import 'package:flutter/material.dart';
import '../models/ai_provider.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载提供商失败: $e')));
      }
    }
  }

  Future<void> _deleteProvider(String id) async {
    try {
      await _repository.deleteProvider(id);
      _loadProviders();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('提供商已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  Future<void> _toggleProvider(String id) async {
    try {
      await _repository.toggleProviderEnabled(id);
      _loadProviders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('切换状态失败: $e')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提供商'),
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
                _loadProviders();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '暂无提供商',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击右上角的 + 按钮添加提供商',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProviders,
              child: ListView.builder(
                itemCount: _providers.length,
                itemBuilder: (context, index) {
                  final provider = _providers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: provider.isEnabled
                            ? Colors.green
                            : Colors.grey,
                        child: Text(
                          provider.name.isNotEmpty
                              ? provider.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        provider.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: provider.isEnabled ? null : Colors.grey,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getProviderTypeDisplayName(provider.type),
                            style: TextStyle(
                              color: provider.isEnabled
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                          if (provider.baseUrl != null)
                            Text(
                              provider.baseUrl!,
                              style: TextStyle(
                                fontSize: 12,
                                color: provider.isEnabled
                                    ? Colors.grey[600]
                                    : Colors.grey,
                              ),
                            ),
                          Text(
                            '支持 ${provider.supportedModels.length} 个模型',
                            style: TextStyle(
                              fontSize: 12,
                              color: provider.isEnabled
                                  ? Colors.grey[600]
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: provider.isEnabled,
                            onChanged: (_) => _toggleProvider(provider.id),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProviderEditScreen(
                                        provider: provider,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      _loadProviders();
                                    }
                                  });
                                  break;
                                case 'delete':
                                  _showDeleteDialog(provider);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('编辑'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      '删除',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProviderEditScreen(provider: provider),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _loadProviders();
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
