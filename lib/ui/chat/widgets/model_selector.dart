import 'package:flutter/material.dart';
import '../../../services/favorite_model_repository.dart';
import '../../../services/assistant_repository.dart';
import '../../../services/notification_service.dart';
import '../../../services/preference_service.dart';
import '../../../models/ai_assistant.dart';
import 'model_tile.dart';

/// 模型选择器组件
class ModelSelector extends StatefulWidget {
  const ModelSelector({
    super.key,
    required this.assistantRepository,
    required this.favoriteModelRepository,
    required this.preferenceService,
    required this.selectedAssistantId,
    required this.onAssistantSelected,
  });

  final AssistantRepository assistantRepository;
  final FavoriteModelRepository favoriteModelRepository;
  final PreferenceService preferenceService;
  final String selectedAssistantId;
  final Function(AiAssistant assistant) onAssistantSelected;

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  @override
  Widget build(BuildContext context) {
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
                child: FutureBuilder<AssistantSelectorData>(
                  future: _loadData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                                ..._buildAssistantSections(
                                  data.assistants,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<AssistantSelectorData> _loadData() async {
    try {
      final assistants = await widget.assistantRepository
          .getEnabledAssistants();
      final favoriteModels = await widget.favoriteModelRepository
          .getAllFavoriteModels();

      return AssistantSelectorData(
        assistants: assistants,
        favoriteModels: favoriteModels,
      );
    } catch (e) {
      throw Exception('加载助手失败: $e');
    }
  }

  List<Widget> _buildAssistantSections(
    List<AiAssistant> assistants,
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    final List<Widget> sections = [];

    // 收藏部分
    final favoriteAssistants = assistants.where((assistant) {
      return favoriteModels.any(
        (fav) =>
            fav.providerId == assistant.providerId &&
            fav.modelName == assistant.modelName,
      );
    }).toList();

    if (favoriteAssistants.isNotEmpty) {
      sections.add(_buildSectionHeader("收藏夹"));
      sections.addAll(
        _buildAssistantModels(
          favoriteAssistants,
          favoriteModels,
          setSheetState,
        ),
      );
      sections.add(const SizedBox(height: 16));
    }

    // 按提供商分组显示其他助手
    final nonFavoriteAssistants = assistants.where((assistant) {
      return !favoriteModels.any(
        (fav) =>
            fav.providerId == assistant.providerId &&
            fav.modelName == assistant.modelName,
      );
    }).toList();

    final groupedAssistants = <String, List<AiAssistant>>{};
    for (final assistant in nonFavoriteAssistants) {
      groupedAssistants
          .putIfAbsent(assistant.providerId, () => [])
          .add(assistant);
    }

    for (final entry in groupedAssistants.entries) {
      if (entry.value.isNotEmpty) {
        sections.add(_buildSectionHeader("${entry.value.first.providerId} 助手"));
        sections.addAll(
          _buildAssistantModels(entry.value, favoriteModels, setSheetState),
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

  List<Widget> _buildAssistantModels(
    List<AiAssistant> assistants,
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    return assistants.map((assistant) {
      final isFavorite = favoriteModels.any(
        (fav) =>
            fav.providerId == assistant.providerId &&
            fav.modelName == assistant.modelName,
      );
      return ModelTile(
        assistant: assistant,
        isSelected: widget.selectedAssistantId == assistant.id,
        isFavorite: isFavorite,
        favoriteModelRepository: widget.favoriteModelRepository,
        onTap: () => _selectAssistant(assistant),
        onFavoriteChanged: () => setSheetState(() {}),
      );
    }).toList();
  }

  void _selectAssistant(AiAssistant assistant) {
    // 保存最后使用的模型到偏好设置
    widget.preferenceService.saveLastUsedModel(
      assistant.providerId,
      assistant.modelName,
    );

    // 通知父组件
    widget.onAssistantSelected(assistant);

    // 关闭底部表单
    Navigator.pop(context);
  }
}

/// 助手选择器数据类
class AssistantSelectorData {
  final List<AiAssistant> assistants;
  final List<FavoriteModel> favoriteModels;

  AssistantSelectorData({
    required this.assistants,
    required this.favoriteModels,
  });
}

/// 显示助手选择器
Future<void> showAssistantSelector({
  required BuildContext context,
  required AssistantRepository assistantRepository,
  required FavoriteModelRepository favoriteModelRepository,
  required PreferenceService preferenceService,
  required String selectedAssistantId,
  required Function(AiAssistant assistant) onAssistantSelected,
}) async {
  try {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ModelSelector(
        assistantRepository: assistantRepository,
        favoriteModelRepository: favoriteModelRepository,
        preferenceService: preferenceService,
        selectedAssistantId: selectedAssistantId,
        onAssistantSelected: onAssistantSelected,
      ),
    );
  } catch (e) {
    NotificationService().showError('加载助手失败: $e');
  }
}
