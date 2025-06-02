import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/favorite_model_repository.dart';
import '../../../services/notification_service.dart';
import '../../../services/preference_service.dart';
import '../../../services/assistant_repository.dart';
import '../../../models/ai_model.dart';
import '../../../models/ai_provider.dart';
import '../../../models/ai_assistant.dart';
import '../../../providers/ai_provider_notifier.dart';

/// 提供商-模型组合数据类
class ProviderModelItem {
  final AiProvider provider;
  final AiModel model;

  const ProviderModelItem({required this.provider, required this.model});

  String get id => '${provider.id}:${model.name}';
  String get displayName => '${provider.name} - ${model.effectiveDisplayName}';
}

/// 模型选择器组件
class ModelSelector extends ConsumerStatefulWidget {
  const ModelSelector({
    super.key,
    required this.favoriteModelRepository,
    required this.preferenceService,
    required this.selectedProviderId,
    required this.selectedModelName,
    required this.onModelSelected,
  });

  final FavoriteModelRepository favoriteModelRepository;
  final PreferenceService preferenceService;
  final String? selectedProviderId;
  final String? selectedModelName;
  final Function(AiAssistant assistant) onModelSelected;

  @override
  ConsumerState<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends ConsumerState<ModelSelector> {
  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(aiProviderNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 顶部拖拽指示器
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 主要内容
              Expanded(
                child: providersAsync.when(
                  data: (providers) {
                    return FutureBuilder<ModelSelectorData>(
                      future: _loadData(providers),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(height: 8),
                                Text('加载失败: ${snapshot.error}'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => setState(() {}),
                                  child: const Text('重试'),
                                ),
                              ],
                            ),
                          );
                        }

                        final data = snapshot.data!;

                        // 检查是否有可用的模型
                        if (data.modelItems.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 48,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '没有可用的AI模型',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '请检查提供商配置或重新加载',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => setState(() {}),
                                  child: const Text('重新加载'),
                                ),
                              ],
                            ),
                          );
                        }

                        return StatefulBuilder(
                          builder: (context, setSheetState) {
                            return FutureBuilder<List<FavoriteModel>>(
                              future: widget.favoriteModelRepository
                                  .getAllFavoriteModels(),
                              builder: (context, favSnapshot) {
                                final currentFavorites =
                                    favSnapshot.data ?? data.favoriteModels;
                                return ListView(
                                  controller: scrollController,
                                  children: [
                                    ..._buildModelSections(
                                      data.modelItems,
                                      currentFavorites,
                                      setSheetState,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('加载提供商失败: $error'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              ref.refresh(aiProviderNotifierProvider),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<ModelSelectorData> _loadData(List<AiProvider> providers) async {
    try {
      final favoriteModels = await widget.favoriteModelRepository
          .getAllFavoriteModels();

      // 获取所有启用提供商的启用模型
      final modelItems = <ProviderModelItem>[];

      for (final provider in providers) {
        if (provider.isEnabled) {
          for (final model in provider.models) {
            if (model.isEnabled) {
              modelItems.add(
                ProviderModelItem(provider: provider, model: model),
              );
            }
          }
        }
      }

      return ModelSelectorData(
        modelItems: modelItems,
        favoriteModels: favoriteModels,
      );
    } catch (e) {
      throw Exception('加载模型失败: $e');
    }
  }

  List<Widget> _buildModelSections(
    List<ProviderModelItem> modelItems,
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    final List<Widget> sections = [];

    // 收藏部分
    final favoriteItems = modelItems.where((item) {
      return favoriteModels.any(
        (fav) =>
            fav.providerId == item.provider.id &&
            fav.modelName == item.model.name,
      );
    }).toList();

    if (favoriteItems.isNotEmpty) {
      sections.add(_buildSectionHeader("收藏夹"));
      sections.addAll(
        _buildModelTiles(favoriteItems, favoriteModels, setSheetState),
      );
      sections.add(const SizedBox(height: 16));
    }

    // 按提供商分组显示其他模型
    final nonFavoriteItems = modelItems.where((item) {
      return !favoriteModels.any(
        (fav) =>
            fav.providerId == item.provider.id &&
            fav.modelName == item.model.name,
      );
    }).toList();

    final groupedItems = <String, List<ProviderModelItem>>{};
    for (final item in nonFavoriteItems) {
      groupedItems.putIfAbsent(item.provider.id, () => []).add(item);
    }

    for (final entry in groupedItems.entries) {
      if (entry.value.isNotEmpty) {
        final provider = entry.value.first.provider;
        sections.add(_buildSectionHeader(provider.name));
        sections.addAll(
          _buildModelTiles(entry.value, favoriteModels, setSheetState),
        );
        sections.add(const SizedBox(height: 16));
      }
    }

    return sections;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildModelTiles(
    List<ProviderModelItem> modelItems,
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    return modelItems.map((item) {
      final isFavorite = favoriteModels.any(
        (fav) =>
            fav.providerId == item.provider.id &&
            fav.modelName == item.model.name,
      );

      final isSelected =
          widget.selectedProviderId == item.provider.id &&
          widget.selectedModelName == item.model.name;

      return _buildModelTile(
        item: item,
        isSelected: isSelected,
        isFavorite: isFavorite,
        onTap: () => _selectModel(item),
        onFavoriteChanged: () => setSheetState(() {}),
      );
    }).toList();
  }

  Widget _buildModelTile({
    required ProviderModelItem item,
    required bool isSelected,
    required bool isFavorite,
    required VoidCallback onTap,
    required VoidCallback onFavoriteChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            item.provider.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.model.effectiveDisplayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.provider.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (item.model.capabilities.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: item.model.capabilities.map((capability) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      capability.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: () async {
            if (isFavorite) {
              await widget.favoriteModelRepository.removeFavoriteModel(
                item.provider.id,
                item.model.name,
              );
            } else {
              await widget.favoriteModelRepository.addFavoriteModel(
                item.provider.id,
                item.model.name,
              );
            }
            onFavoriteChanged();
          },
        ),
        onTap: onTap,
      ),
    );
  }

  void _selectModel(ProviderModelItem item) {
    // 保存最后使用的模型到偏好设置
    widget.preferenceService.saveLastUsedModel(
      item.provider.id,
      item.model.name,
    );

    // 创建基于选择模型的临时助手对象
    // 注意：这里我们创建一个临时助手，包含默认的AI参数
    // 在未来的重构中，应该将助手配置和模型选择分离
    final tempAssistant = AiAssistant(
      id: 'temp_${item.provider.id}_${item.model.name}',
      name: item.model.effectiveDisplayName,
      description:
          '基于 ${item.provider.name} 的 ${item.model.effectiveDisplayName} 模型',
      avatar: '🤖',
      systemPrompt: '你是一个乐于助人的AI助手。',
      providerId: item.provider.id,
      modelName: item.model.name,
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 4096,
      contextLength: 32,
      streamOutput: true,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 通知父组件
    widget.onModelSelected(tempAssistant);

    // 关闭底部表单
    Navigator.pop(context);
  }
}

/// 模型选择器数据类
class ModelSelectorData {
  final List<ProviderModelItem> modelItems;
  final List<FavoriteModel> favoriteModels;

  ModelSelectorData({required this.modelItems, required this.favoriteModels});
}

/// 显示模型选择器
Future<void> showModelSelector({
  required BuildContext context,
  required FavoriteModelRepository favoriteModelRepository,
  required PreferenceService preferenceService,
  required String? selectedProviderId,
  required String? selectedModelName,
  required Function(AiAssistant assistant) onModelSelected,
}) async {
  try {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModelSelector(
        favoriteModelRepository: favoriteModelRepository,
        preferenceService: preferenceService,
        selectedProviderId: selectedProviderId,
        selectedModelName: selectedModelName,
        onModelSelected: onModelSelected,
      ),
    );
  } catch (e) {
    NotificationService().showError('加载模型失败: $e');
  }
}
