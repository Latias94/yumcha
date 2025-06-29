import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy/fuzzy.dart';
import '../../../../ai_management/data/repositories/favorite_model_repository.dart';
import '../../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../../shared/infrastructure/services/preference_service.dart';
import '../../../../ai_management/domain/entities/ai_model.dart';
import '../../../../ai_management/domain/entities/ai_provider.dart';
import '../../../domain/entities/chat_configuration.dart';

import '../../../../ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../../../shared/presentation/providers/favorite_model_notifier.dart';

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
    required this.preferenceService,
    required this.selectedProviderId,
    required this.selectedModelName,
    required this.onModelSelected,
  });

  final PreferenceService preferenceService;
  final String? selectedProviderId;
  final String? selectedModelName;
  final Function(ModelSelection selection) onModelSelected;

  @override
  ConsumerState<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends ConsumerState<ModelSelector> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(aiProvidersProvider);

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
              // 搜索框
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索模型...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // 主要内容
              Expanded(
                child: FutureBuilder<ModelSelectorData>(
                  future: _loadData(providers),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error,
                                color: Theme.of(context).colorScheme.error),
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
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 48,
                              color: Theme.of(context).colorScheme.tertiary,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.invalidate(unifiedAiManagementProvider),
                              child: const Text('重新加载'),
                            ),
                          ],
                        ),
                      );
                    }

                    // 监听收藏模型状态变化
                    final favoriteModelsAsync = ref.watch(
                      favoriteModelNotifierProvider,
                    );
                    final currentFavorites = favoriteModelsAsync.when(
                      data: (models) => models,
                      loading: () => data.favoriteModels,
                      error: (error, stackTrace) => data.favoriteModels,
                    );

                    return ListView(
                      controller: scrollController,
                      children: [
                        ..._buildModelSections(
                          _filterModelItems(data.modelItems),
                          currentFavorites,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ProviderModelItem> _filterModelItems(
    List<ProviderModelItem> modelItems,
  ) {
    if (_searchQuery.isEmpty) {
      return modelItems;
    }

    // 使用 fuzzy 搜索
    final fuzzy = Fuzzy<ProviderModelItem>(
      modelItems,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: 'modelName',
            getter: (item) => item.model.name,
            weight: 1.0,
          ),
          WeightedKey(
            name: 'displayName',
            getter: (item) => item.model.effectiveDisplayName,
            weight: 0.9,
          ),
          WeightedKey(
            name: 'providerName',
            getter: (item) => item.provider.name,
            weight: 0.7,
          ),
          WeightedKey(
            name: 'combinedName',
            getter: (item) => item.displayName,
            weight: 0.8,
          ),
        ],
        threshold: 0.3, // 降低阈值以获得更多结果
        distance: 100,
        isCaseSensitive: false,
        shouldSort: true,
        shouldNormalize: true,
      ),
    );

    final results = fuzzy.search(_searchQuery);
    return results.map((result) => result.item).toList();
  }

  Future<ModelSelectorData> _loadData(List<AiProvider> providers) async {
    try {
      // 通过Riverpod获取收藏模型
      final favoriteModelsAsync = ref.read(favoriteModelNotifierProvider);
      final favoriteModels = favoriteModelsAsync.when(
        data: (models) => models,
        loading: () => <FavoriteModel>[],
        error: (error, stackTrace) => <FavoriteModel>[],
      );

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
      sections.addAll(_buildModelTiles(favoriteItems, favoriteModels));
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
        sections.addAll(_buildModelTiles(entry.value, favoriteModels));
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
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  List<Widget> _buildModelTiles(
    List<ProviderModelItem> modelItems,
    List<FavoriteModel> favoriteModels,
  ) {
    return modelItems.map((item) {
      final isFavorite = favoriteModels.any(
        (fav) =>
            fav.providerId == item.provider.id &&
            fav.modelName == item.model.name,
      );

      final isSelected = widget.selectedProviderId == item.provider.id &&
          widget.selectedModelName == item.model.name;

      return _buildModelTile(
        item: item,
        isSelected: isSelected,
        isFavorite: isFavorite,
        onTap: () => _selectModel(item),
      );
    }).toList();
  }

  Widget _buildModelTile({
    required ProviderModelItem item,
    required bool isSelected,
    required bool isFavorite,
    required VoidCallback onTap,
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
            color: isFavorite
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: () async {
            try {
              final favoriteNotifier = ref.read(
                favoriteModelNotifierProvider.notifier,
              );

              if (isFavorite) {
                await favoriteNotifier.removeFavoriteModel(
                  item.provider.id,
                  item.model.name,
                );
                NotificationService().showSuccess(
                  '已取消收藏 ${item.model.effectiveDisplayName}',
                );
              } else {
                await favoriteNotifier.addFavoriteModel(
                  item.provider.id,
                  item.model.name,
                );
                NotificationService().showSuccess(
                  '已收藏 ${item.model.effectiveDisplayName}',
                );
              }
            } catch (e) {
              NotificationService().showError('操作失败: $e');
            }
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

    // 创建模型选择结果
    final selection = ModelSelection(
      provider: item.provider,
      model: item.model,
    );

    // 通知父组件
    widget.onModelSelected(selection);

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
  required PreferenceService preferenceService,
  required String? selectedProviderId,
  required String? selectedModelName,
  required Function(ModelSelection selection) onModelSelected,
}) async {
  try {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModelSelector(
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
