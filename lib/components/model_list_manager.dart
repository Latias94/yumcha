import 'package:flutter/material.dart';
import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import 'model_edit_dialog.dart';

class ModelListManager extends StatefulWidget {
  final List<AiModel> models;
  final Function(List<AiModel>) onModelsChanged;
  final AiProvider? provider; // 用于获取模型列表

  const ModelListManager({
    super.key,
    required this.models,
    required this.onModelsChanged,
    this.provider,
  });

  @override
  State<ModelListManager> createState() => _ModelListManagerState();
}

class _ModelListManagerState extends State<ModelListManager> {
  late List<AiModel> _models;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _models = List.from(widget.models);
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchModelsFromProvider() async {
    if (widget.provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先保存提供商配置')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: 实现从提供商API获取模型列表的逻辑
      // 这里先模拟一些常见模型
      final fetchedModels = _getDefaultModelsForProvider(widget.provider!.type);
      
      // 显示选择对话框
      if (mounted) {
        _showModelSelectionDialog(fetchedModels);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取模型列表失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AiModel> _getDefaultModelsForProvider(ProviderType type) {
    final now = DateTime.now();
    switch (type) {
      case ProviderType.openai:
        return [
          AiModel(
            id: 'gpt-4',
            name: 'gpt-4',
            displayName: 'GPT-4',
            capabilities: [ModelCapability.chat, ModelCapability.imageAnalysis],
            metadata: {'contextLength': 8192},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-4-turbo',
            name: 'gpt-4-turbo',
            displayName: 'GPT-4 Turbo',
            capabilities: [ModelCapability.chat, ModelCapability.imageAnalysis],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-3.5-turbo',
            name: 'gpt-3.5-turbo',
            displayName: 'GPT-3.5 Turbo',
            capabilities: [ModelCapability.chat],
            metadata: {'contextLength': 16385},
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case ProviderType.anthropic:
        return [
          AiModel(
            id: 'claude-3-opus',
            name: 'claude-3-opus-20240229',
            displayName: 'Claude 3 Opus',
            capabilities: [ModelCapability.chat, ModelCapability.imageAnalysis],
            metadata: {'contextLength': 200000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'claude-3-sonnet',
            name: 'claude-3-sonnet-20240229',
            displayName: 'Claude 3 Sonnet',
            capabilities: [ModelCapability.chat, ModelCapability.imageAnalysis],
            metadata: {'contextLength': 200000},
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case ProviderType.google:
        return [
          AiModel(
            id: 'gemini-pro',
            name: 'gemini-pro',
            displayName: 'Gemini Pro',
            capabilities: [ModelCapability.chat],
            metadata: {'contextLength': 32768},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gemini-pro-vision',
            name: 'gemini-pro-vision',
            displayName: 'Gemini Pro Vision',
            capabilities: [ModelCapability.chat, ModelCapability.imageAnalysis],
            metadata: {'contextLength': 16384},
            createdAt: now,
            updatedAt: now,
          ),
        ];
      default:
        return [];
    }
  }

  void _showModelSelectionDialog(List<AiModel> availableModels) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择要添加的模型'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: availableModels.length,
            itemBuilder: (context, index) {
              final model = availableModels[index];
              final isAlreadyAdded = _models.any((m) => m.name == model.name);
              
              return ListTile(
                title: Text(model.effectiveDisplayName),
                subtitle: Text(model.name),
                trailing: isAlreadyAdded
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: isAlreadyAdded
                    ? null
                    : () {
                        setState(() {
                          _models.add(model);
                        });
                        widget.onModelsChanged(_models);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
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
            child: const Center(
              child: Text(
                '暂无模型\n点击"添加"按钮或"获取模型"来添加模型',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
                        const Icon(Icons.visibility_off, color: Colors.grey),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editModel(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
