import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';
import '../../infrastructure/services/ai/providers/ai_service_provider.dart';
import '../../infrastructure/services/notification_service.dart';
import 'model_edit_dialog.dart';
import 'model_selection_dialog.dart';

/// 模型列表 UI 组件 - 使用 Riverpod 进行状态管理
class ModelListWidget extends ConsumerStatefulWidget {
  final List<AiModel> models;
  final Function(List<AiModel>) onModelsChanged;
  final AiProvider? provider; // 用于获取模型列表

  const ModelListWidget({
    super.key,
    required this.models,
    required this.onModelsChanged,
    this.provider,
  });

  @override
  ConsumerState<ModelListWidget> createState() => _ModelListWidgetState();
}

class _ModelListWidgetState extends ConsumerState<ModelListWidget> {
  late List<AiModel> _models;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _models = List.from(widget.models);
  }

  @override
  void didUpdateWidget(ModelListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当模型列表发生变化时更新本地状态
    if (widget.models != oldWidget.models) {
      _models = List.from(widget.models);
    }
  }

  void _addModel() {
    showDialog(
      context: context,
      builder: (context) => ModelEditDialog(
        onSave: (model) {
          setState(() {
            _models.add(model);
          });
          widget.onModelsChanged(_models);
        },
      ),
    );
  }

  void _editModel(int index) {
    showDialog(
      context: context,
      builder: (context) => ModelEditDialog(
        model: _models[index],
        onSave: (model) {
          setState(() {
            _models[index] = model;
          });
          widget.onModelsChanged(_models);
        },
      ),
    );
  }

  void _deleteModel(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模型 "${_models[index].effectiveDisplayName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _models.removeAt(index);
              });
              widget.onModelsChanged(_models);
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchModelsFromProvider() async {
    if (widget.provider == null) {
      NotificationService().showWarning('请先填写提供商配置信息');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 使用 AI Service Provider 获取模型列表
      final models = await ref.read(
        providerModelsProvider(widget.provider!.id).future,
      );

      if (mounted) {
        _showModelSelectionDialog(models);
        NotificationService().showSuccess('成功获取 ${models.length} 个模型');
      }
    } catch (error) {
      if (mounted) {
        NotificationService().showError('获取模型列表失败: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showModelSelectionDialog(List<AiModel> availableModels) {
    showDialog(
      context: context,
      builder: (context) => ModelSelectionDialog(
        availableModels: availableModels,
        currentModels: _models,
        onConfirm: (selectedModels) {
          setState(() {
            _models = selectedModels;
          });
          widget.onModelsChanged(_models);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和操作按钮
        Row(
          children: [
            const Text(
              '支持的模型',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (widget.provider != null)
              TextButton.icon(
                onPressed: _isLoading ? null : _fetchModelsFromProvider,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_download),
                label: const Text('获取模型'),
              ),
            TextButton.icon(
              onPressed: _addModel,
              icon: const Icon(Icons.add),
              label: const Text('添加'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 模型列表
        if (_models.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                '暂无模型\n点击"添加"按钮或"获取模型"来添加模型',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _models.length,
            itemBuilder: (context, index) {
              final model = _models[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(model.effectiveDisplayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('模型ID: ${model.name}'),
                      if (model.capabilities.isNotEmpty)
                        Text(
                          '功能: ${model.capabilities.map((c) => c.displayName).join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!model.isEnabled)
                        Icon(Icons.visibility_off,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editModel(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () => _deleteModel(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
