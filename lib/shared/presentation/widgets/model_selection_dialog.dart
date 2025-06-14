import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import '../design_system/design_constants.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';

class ModelSelectionDialog extends StatefulWidget {
  final List<AiModel> availableModels;
  final List<AiModel> currentModels;
  final Function(List<AiModel>) onConfirm;
  final String? errorMessage; // 可选的错误信息

  const ModelSelectionDialog({
    super.key,
    required this.availableModels,
    required this.currentModels,
    required this.onConfirm,
    this.errorMessage,
  });

  @override
  State<ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends State<ModelSelectionDialog> {
  late Set<String> _selectedModelIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 初始化已选择的模型ID集合
    _selectedModelIds = widget.currentModels.map((model) => model.name).toSet();
  }

  List<AiModel> get _filteredModels {
    if (_searchQuery.isEmpty) {
      return widget.availableModels;
    }

    // 使用 fuzzy 搜索
    final fuzzy = Fuzzy<AiModel>(
      widget.availableModels,
      options: FuzzyOptions(
        keys: [
          WeightedKey(name: 'name', getter: (model) => model.name, weight: 1.0),
          WeightedKey(
            name: 'displayName',
            getter: (model) => model.effectiveDisplayName,
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

  void _toggleModel(AiModel model) {
    setState(() {
      if (_selectedModelIds.contains(model.name)) {
        _selectedModelIds.remove(model.name);
      } else {
        _selectedModelIds.add(model.name);
      }
    });
  }

  void _onConfirm() {
    // 构建最终的模型列表
    final selectedModels = <AiModel>[];

    // 添加从API获取的已选择模型
    for (final model in widget.availableModels) {
      if (_selectedModelIds.contains(model.name)) {
        selectedModels.add(model);
      }
    }

    // 添加当前模型中不在API列表中的模型（用户手动添加的）
    for (final currentModel in widget.currentModels) {
      final isInAvailable = widget.availableModels.any(
        (model) => model.name == currentModel.name,
      );

      if (!isInAvailable && _selectedModelIds.contains(currentModel.name)) {
        selectedModels.add(currentModel);
      }
    }

    widget.onConfirm(selectedModels);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.model_training),
                SizedBox(width: DesignConstants.spaceS),
                Text('选择模型', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 错误信息（如果有）
            if (widget.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: DesignConstants.paddingM,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: DesignConstants.radiusM,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    SizedBox(width: DesignConstants.spaceS),
                    Expanded(
                      child: Text(
                        widget.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DesignConstants.spaceL),
            ],

            // 搜索框
            TextField(
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: DesignConstants.spaceM),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 统计信息
            Text(
              '找到 ${_filteredModels.length} 个模型，已选择 ${_selectedModelIds.length} 个',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 模型列表
            Expanded(
              child: _filteredModels.isEmpty
                  ? Center(
                      child: Text(
                        '没有找到匹配的模型',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredModels.length,
                      itemBuilder: (context, index) {
                        final model = _filteredModels[index];
                        final isSelected = _selectedModelIds.contains(
                          model.name,
                        );
                        final isFromCurrent = widget.currentModels.any(
                          (m) => m.name == model.name,
                        );

                        return Card(
                          margin:
                              EdgeInsets.only(bottom: DesignConstants.spaceS),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) => _toggleModel(model),
                            title: Row(
                              children: [
                                Expanded(child: Text(model.name)),
                                if (isFromCurrent)
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: DesignConstants.spaceS),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DesignConstants.spaceS,
                                      vertical: DesignConstants.spaceXS / 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: DesignConstants.radiusM,
                                    ),
                                    child: Text(
                                      '已添加',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: DesignConstants.spaceL),

            // 操作按钮
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedModelIds.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    tooltip: '全部取消',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedModelIds.addAll(
                          _filteredModels.map((model) => model.name),
                        );
                      });
                    },
                    icon: const Icon(Icons.select_all),
                    tooltip: '全部选择',
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: '取消',
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _onConfirm,
                    icon: const Icon(Icons.save),
                    label: const Text('保存'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
