import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_assistant.dart';
import '../models/ai_provider.dart';
import '../services/notification_service.dart';
import '../providers/ai_assistant_notifier.dart';
import '../providers/ai_provider_notifier.dart';
import 'assistant_edit_screen.dart';

class AssistantsScreen extends ConsumerWidget {
  const AssistantsScreen({super.key});

  Future<void> _deleteAssistant(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(aiAssistantNotifierProvider.notifier).deleteAssistant(id);
      NotificationService().showSuccess('助手已删除');
    } catch (e) {
      NotificationService().showError('删除失败: $e');
    }
  }

  Future<void> _toggleAssistant(WidgetRef ref, String id) async {
    try {
      await ref
          .read(aiAssistantNotifierProvider.notifier)
          .toggleAssistantEnabled(id);
    } catch (e) {
      NotificationService().showError('切换状态失败: $e');
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    AiAssistant assistant,
  ) {
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
              _deleteAssistant(context, ref, assistant.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
    final providersAsync = ref.watch(aiProviderNotifierProvider);

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
                  final providers = providersAsync.when(
                    data: (data) => data,
                    loading: () => <AiProvider>[],
                    error: (_, _) => <AiProvider>[],
                  );

                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AssistantEditScreen(providers: providers),
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(aiAssistantNotifierProvider);
                  }
                },
              ),
            ],
          ),
          // 使用assistantsAsync来渲染内容
          assistantsAsync.when(
            data: (assistants) {
              if (assistants.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
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
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final assistant = assistants[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Assistant Avatar
                              Container(
                                padding: const EdgeInsets.all(
                                  8,
                                ), // Optional padding for the avatar container
                                // decoration: BoxDecoration( // Optional background for avatar if not using CircleAvatar
                                //   color: Theme.of(context).colorScheme.primaryContainer,
                                //   shape: BoxShape.circle,
                                // ),
                                child: Text(
                                  assistant.avatar,
                                  style: const TextStyle(
                                    fontSize: 32,
                                  ), // Increased font size
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Assistant Name
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4.0,
                                  ), // Adjust top padding for alignment
                                  child: Text(
                                    assistant.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                              // Enable/Disable Switch
                              Switch(
                                value: assistant.isEnabled,
                                onChanged: (value) =>
                                    _toggleAssistant(ref, assistant.id),
                              ),
                            ],
                          ),
                          // System Prompt (Optional)
                          if (assistant.systemPrompt.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                assistant.systemPrompt,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          if (assistant.systemPrompt.isEmpty)
                            const SizedBox(
                              height: 8,
                            ), // Add space if prompt is empty before buttons
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('编辑'),
                                onPressed: () {
                                  final providers = providersAsync.when(
                                    data: (data) => data,
                                    loading: () => <AiProvider>[],
                                    error: (_, _) => <AiProvider>[],
                                  );

                                  Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssistantEditScreen(
                                        assistant: assistant,
                                        providers: providers,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      ref.invalidate(
                                        aiAssistantNotifierProvider,
                                      );
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                label: Text(
                                  '删除',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                onPressed: () => _showDeleteDialog(
                                  context,
                                  ref,
                                  assistant,
                                ), // Reusing existing delete dialog
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: assistants.length),
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
                            ref.refresh(aiAssistantNotifierProvider),
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
