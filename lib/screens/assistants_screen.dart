import 'package:flutter/material.dart';
import '../models/ai_assistant.dart';
import '../models/ai_provider.dart';
import '../services/assistant_repository.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';
import 'assistant_edit_screen.dart';

class AssistantsScreen extends StatefulWidget {
  const AssistantsScreen({super.key});

  @override
  State<AssistantsScreen> createState() => _AssistantsScreenState();
}

class _AssistantsScreenState extends State<AssistantsScreen> {
  late final AssistantRepository _assistantRepository;
  late final ProviderRepository _providerRepository;
  List<AiAssistant> _assistants = [];
  List<AiProvider> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final database = DatabaseService.instance.database;
    _assistantRepository = AssistantRepository(database);
    _providerRepository = ProviderRepository(database);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final assistants = await _assistantRepository.getAllAssistants();
      final providers = await _providerRepository.getAllProviders();
      setState(() {
        _assistants = assistants;
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载助手失败: $e')));
      }
    }
  }

  Future<void> _deleteAssistant(String id) async {
    try {
      await _assistantRepository.deleteAssistant(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('助手已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  Future<void> _toggleAssistant(String id) async {
    try {
      await _assistantRepository.toggleAssistantEnabled(id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('切换状态失败: $e')));
      }
    }
  }

  void _showDeleteDialog(AiAssistant assistant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除助手 "${assistant.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAssistant(assistant.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _getProviderName(String providerId) {
    final provider = _providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () => AiProvider(
        id: '',
        name: '未知提供商',
        type: ProviderType.custom,
        apiKey: '',
        supportedModels: [],
        customHeaders: {},
        isEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return provider.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AssistantEditScreen(providers: _providers),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assistants.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '暂无助手',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('点击右上角的 + 按钮添加助手', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _assistants.length,
                itemBuilder: (context, index) {
                  final assistant = _assistants[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: assistant.isEnabled
                            ? Colors.blue
                            : Colors.grey,
                        child: Text(
                          assistant.avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        assistant.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: assistant.isEnabled ? null : Colors.grey,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assistant.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: assistant.isEnabled
                                  ? Colors.grey[600]
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.cloud,
                                size: 14,
                                color: assistant.isEnabled
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getProviderName(assistant.providerId),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: assistant.isEnabled
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.memory,
                                size: 14,
                                color: assistant.isEnabled
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                assistant.modelName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: assistant.isEnabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: assistant.isEnabled,
                            onChanged: (_) => _toggleAssistant(assistant.id),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssistantEditScreen(
                                        assistant: assistant,
                                        providers: _providers,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      _loadData();
                                    }
                                  });
                                  break;
                                case 'delete':
                                  _showDeleteDialog(assistant);
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
                            builder: (context) => AssistantEditScreen(
                              assistant: assistant,
                              providers: _providers,
                            ),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _loadData();
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
