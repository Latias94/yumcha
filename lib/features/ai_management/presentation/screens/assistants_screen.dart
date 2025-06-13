// 🤖 AI 助手管理屏幕
//
// 用于管理用户创建的 AI 助手列表，提供助手的查看、编辑、删除等功能。
// 用户可以在此创建个性化的 AI 助手，设置不同的角色和参数。
//
// 🎯 **主要功能**:
// - 📋 **助手列表**: 显示所有已创建的 AI 助手
// - ➕ **添加助手**: 创建新的 AI 助手
// - ✏️ **编辑助手**: 修改助手的配置和参数
// - 🗑️ **删除助手**: 删除不需要的助手
// - 🔄 **启用/禁用**: 切换助手的启用状态
// - 🎭 **助手预览**: 显示助手的头像、名称、系统提示词
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 卡片式布局展示助手信息
// - 支持空状态提示
// - 提供编辑和删除操作按钮
//
// 🔄 **状态管理**:
// - 使用 Riverpod 管理助手列表状态
// - 支持异步加载和错误处理
// - 自动刷新列表数据

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../domain/entities/ai_provider.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
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
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
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
                    error: (error, stackTrace) => <AiProvider>[],
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
                    height: DesignConstants.getResponsiveMaxWidth(context,
                        mobile: 350.0, tablet: 400.0, desktop: 450.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.smart_toy,
                              size: DesignConstants.iconSizeXXL * 1.6, // 64px
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          SizedBox(height: DesignConstants.spaceL),
                          Text(
                            '暂无助手',
                            style: TextStyle(
                                fontSize: DesignConstants.getResponsiveFontSize(
                                    context,
                                    mobile: 17.0,
                                    tablet: 18.0,
                                    desktop: 18.0),
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                          SizedBox(height: DesignConstants.spaceS),
                          Text(
                            '点击右上角的 + 按钮添加助手',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
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
                      borderRadius: DesignConstants.radiusM,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    margin: EdgeInsets.symmetric(
                      vertical: DesignConstants.spaceS,
                      horizontal: DesignConstants.spaceL,
                    ),
                    child: Padding(
                      padding: DesignConstants.paddingL,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Assistant Avatar
                              Container(
                                padding: DesignConstants.paddingS,
                                child: Text(
                                  assistant.avatar,
                                  style: TextStyle(
                                    fontSize:
                                        DesignConstants.iconSizeXL, // 32px
                                  ),
                                ),
                              ),
                              SizedBox(width: DesignConstants.spaceM),
                              // Assistant Name
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: DesignConstants.spaceXS,
                                  ),
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
                              padding: EdgeInsets.only(
                                top: DesignConstants.spaceS,
                                bottom: DesignConstants.spaceS,
                              ),
                              child: Text(
                                assistant.systemPrompt,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          if (assistant.systemPrompt.isEmpty)
                            SizedBox(
                              height: DesignConstants.spaceS,
                            ),
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
                                    error: (error, stackTrace) =>
                                        <AiProvider>[],
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
                              SizedBox(width: DesignConstants.spaceS),
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
                height: DesignConstants.getResponsiveMaxWidth(context,
                    mobile: 350.0, tablet: 400.0, desktop: 450.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: SizedBox(
                height: DesignConstants.getResponsiveMaxWidth(context,
                    mobile: 350.0, tablet: 400.0, desktop: 450.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error,
                          color: Theme.of(context).colorScheme.error),
                      SizedBox(height: DesignConstants.spaceL),
                      Text('加载失败: $error'),
                      SizedBox(height: DesignConstants.spaceS),
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
