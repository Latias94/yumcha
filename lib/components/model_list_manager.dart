import 'package:flutter/material.dart';
import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import '../services/notification_service.dart';
import '../src/rust/api/ai_chat.dart' as genai;
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

  /// 将本地提供商类型转换为 GenAI 提供商类型
  genai.AiProvider _convertToGenaiProvider(AiProvider provider) {
    switch (provider.type) {
      case ProviderType.openai:
        return const genai.AiProvider.openAi();
      case ProviderType.anthropic:
        return const genai.AiProvider.anthropic();
      case ProviderType.google:
        return const genai.AiProvider.gemini();
      case ProviderType.ollama:
        return const genai.AiProvider.ollama();
      case ProviderType.custom:
        return genai.AiProvider.custom(name: provider.name);
    }
  }

  /// 检查是否支持 OpenAI 兼容 API
  bool _supportsOpenAiCompatibleApi(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
      case ProviderType.custom:
        return true;
      case ProviderType.anthropic:
      case ProviderType.google:
      case ProviderType.ollama:
        return false;
    }
  }

  /// 获取默认的 Base URL
  String? _getDefaultBaseUrl(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com';
      case ProviderType.google:
        return 'https://generativelanguage.googleapis.com/v1';
      case ProviderType.ollama:
        return 'http://localhost:11434';
      case ProviderType.custom:
        return null;
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

    final genaiProvider = _convertToGenaiProvider(currentProvider);

    // 检查提供商是否支持列出模型
    if (!genai.checkProviderSupportsListModels(provider: genaiProvider)) {
      final capabilities = genai.getProviderCapabilitiesInfo(
        provider: genaiProvider,
      );
      NotificationService().showWarning(
        '${capabilities.description}\n不支持动态获取模型列表，请手动添加模型',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      late genai.ModelListResponse response;

      // 对于支持 OpenAI 兼容接口的提供商，直接调用 API
      if (_supportsOpenAiCompatibleApi(currentProvider.type)) {
        final baseUrl =
            currentProvider.baseUrl ??
            _getDefaultBaseUrl(currentProvider.type)!;

        response = await genai.fetchOpenaiCompatibleModels(
          apiKey: currentProvider.apiKey,
          baseUrl: baseUrl,
        );
      } else {
        // 使用 GenAI 后端获取模型列表
        response = await genai.getModelsFromProvider(
          provider: genaiProvider,
          apiKey: currentProvider.apiKey,
          baseUrl: currentProvider.baseUrl,
        );
      }

      if (!response.success) {
        throw Exception(response.errorMessage ?? '未知错误');
      }

      // 将字符串模型列表转换为 AiModel 对象
      final fetchedModels = response.models.map((modelName) {
        final now = DateTime.now();
        return AiModel(
          id: modelName,
          name: modelName,
          displayName: modelName, // 直接使用模型名称，不进行转换
          capabilities: _getCapabilities(modelName),
          metadata: _getMetadata(modelName),
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      // 显示选择对话框
      if (mounted) {
        _showModelSelectionDialog(fetchedModels);
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

  /// 获取模型能力
  List<ModelCapability> _getCapabilities(String modelId) {
    final lowerModelId = modelId.toLowerCase();
    final capabilities = <ModelCapability>[];

    // 默认所有模型都支持推理
    capabilities.add(ModelCapability.reasoning);

    // 检查是否支持视觉
    if (lowerModelId.contains('vision') ||
        lowerModelId.contains('gpt-4o') ||
        lowerModelId.contains('gpt-4-turbo') ||
        lowerModelId.contains('claude-3')) {
      capabilities.add(ModelCapability.vision);
    }

    // 检查是否支持工具
    if (lowerModelId.contains('gpt-4') ||
        lowerModelId.contains('claude') ||
        lowerModelId.contains('gemini')) {
      capabilities.add(ModelCapability.tools);
    }

    // 检查是否支持嵌入
    if (lowerModelId.contains('embedding') ||
        lowerModelId.contains('text-embedding')) {
      capabilities.add(ModelCapability.embedding);
    }

    return capabilities;
  }

  /// 获取模型元数据
  Map<String, dynamic> _getMetadata(String modelId) {
    final metadata = <String, dynamic>{};

    // 根据模型名称设置上下文长度
    metadata['contextLength'] = _getContextLength(modelId);

    return metadata;
  }

  /// 获取模型上下文长度
  int _getContextLength(String modelId) {
    final contextLengths = {
      'gpt-4o': 128000,
      'gpt-4o-mini': 128000,
      'gpt-4-turbo': 128000,
      'gpt-4': 8192,
      'gpt-3.5-turbo': 16385,
      'gpt-3.5-turbo-16k': 16385,
      'claude-3-opus': 200000,
      'claude-3-sonnet': 200000,
      'claude-3-haiku': 200000,
      'gemini-pro': 32768,
      'gemini-pro-vision': 16384,
      'deepseek-chat': 32768,
      'deepseek-coder': 16384,
    };

    return contextLengths[modelId] ?? 4096;
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
                  final genaiProvider = _convertToGenaiProvider(
                    widget.provider!,
                  );
                  final supportsListModels = genai
                      .checkProviderSupportsListModels(provider: genaiProvider);

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
