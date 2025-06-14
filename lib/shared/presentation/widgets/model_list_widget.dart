import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';
import '../../infrastructure/services/ai/ai_service_manager.dart';
import '../../infrastructure/services/ai/capabilities/model_service.dart';
import '../../infrastructure/services/notification_service.dart';
import '../design_system/design_constants.dart';
import 'model_edit_dialog.dart';
import 'model_selection_dialog.dart';

/// 模型列表 UI 组件 - 使用 Riverpod 进行状态管理
class ModelListWidget extends ConsumerStatefulWidget {
  final List<AiModel> models;
  final Function(List<AiModel>) onModelsChanged;
  final AiProvider? provider; // 用于获取模型列表（静态）
  final AiProvider Function()? providerBuilder; // 用于动态获取最新配置

  const ModelListWidget({
    super.key,
    required this.models,
    required this.onModelsChanged,
    this.provider,
    this.providerBuilder,
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
    // 获取当前的 provider 配置（优先使用动态构建器）
    final currentProvider = widget.providerBuilder?.call() ?? widget.provider;

    if (currentProvider == null) {
      NotificationService().showWarning(
        '请先填写提供商配置信息',
        importance: NotificationImportance.high,
      );
      return;
    }

    // 验证必要的配置
    if (currentProvider.apiKey.trim().isEmpty &&
        currentProvider.type != ProviderType.ollama) {
      NotificationService().showError(
        '请先配置 API 密钥',
        importance: NotificationImportance.high,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 直接使用 AI Service Manager 获取模型列表，使用当前表单中的最新配置
      final aiServiceManager = ref.read(aiServiceManagerProvider);
      final models = await aiServiceManager.getModelsFromProvider(
        currentProvider,
        useCache: false, // 不使用缓存，确保使用最新配置
      );

      if (mounted) {
        _showModelSelectionDialog(models);
        NotificationService().showSuccess('成功获取 ${models.length} 个模型');
      }
    } catch (error) {
      if (mounted) {
        // 检查是否是包含缓存数据的异常
        if (error is ModelServiceException && error.cachedModels != null) {
          // 这是一个特殊情况：API失败但有缓存数据
          // 直接显示带有错误信息的模型选择对话框
          _showModelSelectionDialogWithError(
            error.cachedModels!,
            '${error.message}\n\n注意：显示的是缓存数据，可能不是最新的。',
          );
        } else {
          // 普通错误处理
          NotificationService().showError(
            error.toString(),
            importance: NotificationImportance.critical,
          );
        }
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

  void _showModelSelectionDialogWithError(List<AiModel> availableModels, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => ModelSelectionDialog(
        availableModels: availableModels,
        currentModels: _models,
        errorMessage: errorMessage,
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
            if (widget.provider != null || widget.providerBuilder != null)
              TextButton.icon(
                onPressed: _isLoading ? null : _fetchModelsFromProvider,
                icon: _isLoading
                    ? SizedBox(
                        width: DesignConstants.iconSizeS,
                        height: DesignConstants.iconSizeS,
                        child: const CircularProgressIndicator(strokeWidth: 2),
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
        SizedBox(height: DesignConstants.spaceS),

        // 模型列表
        if (_models.isEmpty)
          Container(
            padding: DesignConstants.paddingXXL,
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
                margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
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
