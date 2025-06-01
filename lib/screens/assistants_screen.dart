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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('助手'),
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
          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _assistants.isEmpty
                ? const SizedBox(
                    height: 400,
                    child: Center(
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
                          Text(
                            '点击右上角的 + 按钮添加助手',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (!_isLoading && _assistants.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final assistant = _assistants[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Assistant Avatar
                            Container(
                              padding: const EdgeInsets.all(8), // Optional padding for the avatar container
                              // decoration: BoxDecoration( // Optional background for avatar if not using CircleAvatar
                              //   color: Theme.of(context).colorScheme.primaryContainer,
                              //   shape: BoxShape.circle,
                              // ),
                              child: Text(
                                assistant.avatar,
                                style: const TextStyle(fontSize: 32), // Increased font size
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Assistant Name
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0), // Adjust top padding for alignment
                                child: Text(
                                  assistant.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ),
                            // Enable/Disable Switch
                            Switch(
                              value: assistant.isEnabled,
                              onChanged: (value) => _toggleAssistant(assistant.id),
                            ),
                          ],
                        ),
                        // System Prompt (Optional)
                        if (assistant.systemPrompt.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              assistant.systemPrompt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        if (assistant.systemPrompt.isEmpty)
                          const SizedBox(height: 8), // Add space if prompt is empty before buttons
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('编辑'),
                              onPressed: () {
                                Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssistantEditScreen(
                                      assistant: assistant,
                                      providers: _providers, // Passing existing _providers
                                    ),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    _loadData();
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                              label: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              onPressed: () => _showDeleteDialog(assistant), // Reusing existing delete dialog
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _assistants.length),
            ),
        ],
      ),
    );
  }
}
