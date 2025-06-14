// 🔌 AI 提供商管理屏幕
//
// 用于管理 AI 服务提供商的配置，支持多种主流 AI 服务商。
// 用户可以在此配置不同的提供商，设置 API 密钥和模型列表。
//
// 🎯 **主要功能**:
// - 📋 **提供商列表**: 显示所有已配置的 AI 提供商
// - ➕ **添加提供商**: 配置新的 AI 服务提供商
// - ✏️ **编辑提供商**: 修改提供商的配置和模型
// - 🗑️ **删除提供商**: 删除不需要的提供商
// - 🔄 **启用/禁用**: 切换提供商的启用状态
// - 🏷️ **类型标识**: 显示提供商类型和图标
// - 📊 **模型统计**: 显示每个提供商配置的模型数量
//
// 🔌 **支持的提供商类型**:
// - OpenAI: GPT 系列模型
// - Anthropic: Claude 系列模型
// - Google: Gemini 系列模型
// - Ollama: 本地部署的开源模型
// - Custom: 用户自定义的 API 接口
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 卡片式布局展示提供商信息
// - 支持空状态提示
// - 提供编辑和删除操作按钮
// - 不同提供商类型使用不同图标

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_provider.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

import '../providers/unified_ai_management_providers.dart';
import 'provider_edit_screen.dart';
import 'assistants_screen.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  Future<void> _deleteProvider(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(aiManagementActionsProvider).deleteProvider(id);
      NotificationService().showSuccess('提供商已删除');
    } catch (e) {
      NotificationService().showError('删除失败: $e');
    }
  }

  Future<void> _toggleProvider(WidgetRef ref, String id) async {
    try {
      await ref
          .read(aiManagementActionsProvider)
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
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
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
    final providers = ref.watch(aiProvidersProvider);
    final isLoading = ref.watch(aiManagementLoadingProvider);
    final isInitialized = ref.watch(aiManagementInitializedProvider);


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
              // 跳转到助手页面
              IconButton(
                icon: const Icon(Icons.smart_toy_outlined),
                tooltip: '助手',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AssistantsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: '添加提供商',
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderEditScreen(),
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(unifiedAiManagementProvider);
                  }
                },
              ),
            ],
          ),
          // 根据状态渲染内容
          if (isLoading || !isInitialized)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (providers.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: DesignConstants.iconSizeXXL * 1.6,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: DesignConstants.spaceL),
                      Text(
                        '暂无提供商',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: DesignConstants.spaceS),
                      Text(
                        '点击右上角的 + 按钮添加一个',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
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
            ),
        if (isInitialized && !isLoading && providers.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final provider = providers[index];
                  final colorScheme = Theme.of(context).colorScheme;

                  return Card(
                    elevation: 1,
                    color: colorScheme.surfaceContainerHighest,
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
                            children: [
                              Icon(
                                _getProviderIcon(provider.type),
                                size: DesignConstants.iconSizeXL,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: DesignConstants.spaceL),
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
                          SizedBox(height: DesignConstants.spaceS),
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
                                    ref.invalidate(unifiedAiManagementProvider);
                                  }
                                },
                              ),
                              SizedBox(width: DesignConstants.spaceS),
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
            ),
        ],
      ),
    );
  }
}
