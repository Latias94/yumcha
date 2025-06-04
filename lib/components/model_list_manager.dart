import 'package:flutter/material.dart';
import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import '../services/notification_service.dart';
import '../services/ai_request_service.dart';
import '../services/ai_service.dart';
import '../services/logger_service.dart';
import 'model_edit_dialog.dart';
import 'model_selection_dialog.dart';

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
  final _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _models = List.from(widget.models);
  }

  @override
  void didUpdateWidget(ModelListManager oldWidget) {
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 检查提供商是否支持获取模型列表
  bool _providerSupportsListModels(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
      case ProviderType.custom:
        return true; // OpenAI兼容接口支持列出模型
      case ProviderType.anthropic:
      case ProviderType.google:
      case ProviderType.ollama:
        return false; // 这些提供商暂不支持动态获取模型列表
    }
  }

  Future<void> _fetchModelsFromProvider() async {
    if (widget.provider == null) {
      NotificationService().showWarning('请先填写提供商配置信息');
      return;
    }

    // 获取当前的 provider 信息
    final currentProvider = widget.provider!;

    // 检查 API Key 是否已填写
    if (currentProvider.apiKey.isEmpty) {
      NotificationService().showWarning('请先填写 API Key');
      return;
    }

    // 检查提供商是否支持列出模型
    if (!_providerSupportsListModels(currentProvider.type)) {
      NotificationService().showWarning(
        '${currentProvider.name} 不支持动态获取模型列表，请手动添加模型',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<AiModel> availableModels = [];

      // 首先尝试从提供商API获取模型列表
      try {
        final aiService = AiService();
        availableModels = await aiService.fetchModelsFromProvider(
          currentProvider,
        );

        if (availableModels.isNotEmpty) {
          // 成功从API获取模型
          if (mounted) {
            _showModelSelectionDialog(availableModels);
            NotificationService().showSuccess(
              '从API成功获取 ${availableModels.length} 个模型',
            );
          }
          return;
        }
      } catch (e) {
        // API获取失败，记录错误但继续使用通用模型
        _logger.warning('从API获取模型失败', {'error': e.toString()});
      }

      // 如果API获取失败或返回空列表，使用AI请求服务测试连接并使用通用模型
      final aiRequestService = AiRequestService();
      final isConnected = await aiRequestService.testProvider(
        provider: currentProvider,
      );

      if (!isConnected) {
        throw Exception('无法连接到提供商，请检查API密钥和网络连接');
      }

      // 使用通用模型作为回退
      final commonModels = _getCommonModelsForProvider(currentProvider.type);

      if (commonModels.isNotEmpty) {
        // 显示选择对话框
        if (mounted) {
          _showModelSelectionDialog(commonModels);
          NotificationService().showInfo(
            '使用预设模型列表 (${commonModels.length} 个模型)',
          );
        }
      } else {
        NotificationService().showWarning('该提供商暂无预设模型，请手动添加');
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('获取模型列表失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 获取提供商的常用模型列表
  List<AiModel> _getCommonModelsForProvider(ProviderType type) {
    final now = DateTime.now();
    final models = <AiModel>[];

    switch (type) {
      case ProviderType.openai:
        models.addAll([
          AiModel(
            id: 'gpt-4o',
            name: 'gpt-4o',
            displayName: 'GPT-4o',
            capabilities: [
              ModelCapability.reasoning,
              ModelCapability.vision,
              ModelCapability.tools,
            ],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-4o-mini',
            name: 'gpt-4o-mini',
            displayName: 'GPT-4o Mini',
            capabilities: [
              ModelCapability.reasoning,
              ModelCapability.vision,
              ModelCapability.tools,
            ],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-4-turbo',
            name: 'gpt-4-turbo',
            displayName: 'GPT-4 Turbo',
            capabilities: [
              ModelCapability.reasoning,
              ModelCapability.vision,
              ModelCapability.tools,
            ],
            metadata: {'contextLength': 128000},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-3.5-turbo',
            name: 'gpt-3.5-turbo',
            displayName: 'GPT-3.5 Turbo',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {'contextLength': 16385},
            createdAt: now,
            updatedAt: now,
          ),
        ]);
        break;
      case ProviderType.custom:
        // 对于自定义提供商，提供一些通用的OpenAI兼容模型
        models.addAll([
          AiModel(
            id: 'deepseek-chat',
            name: 'deepseek-chat',
            displayName: 'DeepSeek Chat',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {'contextLength': 32768},
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'deepseek-coder',
            name: 'deepseek-coder',
            displayName: 'DeepSeek Coder',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {'contextLength': 16384},
            createdAt: now,
            updatedAt: now,
          ),
        ]);
        break;
      case ProviderType.anthropic:
      case ProviderType.google:
      case ProviderType.ollama:
        // 这些提供商暂不支持动态获取，返回空列表
        break;
    }

    return models;
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
              Builder(
                builder: (context) {
                  final supportsListModels = _providerSupportsListModels(
                    widget.provider!.type,
                  );

                  return TextButton.icon(
                    onPressed: _isLoading ? null : _fetchModelsFromProvider,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            supportsListModels
                                ? Icons.cloud_download
                                : Icons.info_outline,
                          ),
                    label: Text(supportsListModels ? '获取模型' : '查看说明'),
                    style: supportsListModels
                        ? null
                        : TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                          ),
                  );
                },
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
