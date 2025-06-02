import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_provider.dart';
import '../models/ai_model.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../providers/ai_provider_notifier.dart';
import '../components/model_list_manager.dart';

class ProviderEditScreen extends ConsumerStatefulWidget {
  final AiProvider? provider;

  const ProviderEditScreen({super.key, this.provider});

  @override
  ConsumerState<ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends ConsumerState<ProviderEditScreen> {
  late final ProviderRepository _repository;
  final _formKey = GlobalKey<FormState>();

  final _uuid = Uuid();
  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelsController;

  late ProviderType _selectedType;
  late List<AiModel> _models;
  bool _isEnabled = true;
  bool _isLoading = false;

  bool get _isEditing => widget.provider != null;

  @override
  void initState() {
    super.initState();
    _repository = ProviderRepository(DatabaseService.instance.database);

    final provider = widget.provider;
    _nameController = TextEditingController(text: provider?.name ?? '');
    _apiKeyController = TextEditingController(text: provider?.apiKey ?? '');
    _baseUrlController = TextEditingController(text: provider?.baseUrl ?? '');
    _modelsController = TextEditingController();

    _selectedType = provider?.type ?? ProviderType.openai;
    _isEnabled = provider?.isEnabled ?? true;

    // 初始化模型列表
    _models = provider?.models.isNotEmpty == true
        ? List.from(provider!.models)
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelsController.dispose();
    super.dispose();
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      final provider = AiProvider(
        id: widget.provider?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim().isEmpty
            ? null
            : _baseUrlController.text.trim(),
        models: _models,
        customHeaders: widget.provider?.customHeaders ?? {},
        isEnabled: _isEnabled,
        createdAt: widget.provider?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _repository.updateProvider(provider);
      } else {
        await _repository.insertProvider(provider);
      }

      // 刷新Riverpod状态
      ref.refresh(aiProviderNotifierProvider);

      if (mounted) {
        Navigator.pop(context, true);
        NotificationService().showSuccess(_isEditing ? '提供商已更新' : '提供商已添加');
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('保存失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  List<String> _getDefaultModels(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return ['gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'];
      case ProviderType.anthropic:
        return ['claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'];
      case ProviderType.google:
        return ['gemini-pro', 'gemini-pro-vision'];
      case ProviderType.ollama:
        return ['llama2', 'codellama', 'mistral'];
      case ProviderType.custom:
        return [];
    }
  }

  void _onTypeChanged(ProviderType? type) {
    if (type == null) return;

    setState(() {
      _selectedType = type;

      // 如果是新建模式，自动填充默认值
      if (!_isEditing) {
        final defaultBaseUrl = _getDefaultBaseUrl(type);
        if (defaultBaseUrl != null) {
          _baseUrlController.text = defaultBaseUrl;
        }

        final defaultModels = _getDefaultModels(type);
        if (defaultModels.isNotEmpty) {
          _modelsController.text = defaultModels.join(', ');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑提供商' : '添加提供商'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: _saveProvider,
                icon: const Icon(Icons.save),
                tooltip: _isEditing ? '更新' : '保存',
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // 基本信息
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Text(
                '基本信息',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ), //保持原有Column的padding逻辑，但只在底部
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '名称',
                      hintText: '输入提供商名称',
                      border: OutlineInputBorder(),
                      helperText: '为此提供商配置设置一个易于识别的名称',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入提供商名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 类型
                  DropdownButtonFormField<ProviderType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: '类型',
                      border: OutlineInputBorder(),
                      helperText: '选择AI提供商类型，不同类型支持不同的功能和模型',
                    ),
                    items: ProviderType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getProviderTypeDisplayName(type)),
                      );
                    }).toList(),
                    onChanged: _onTypeChanged,
                  ),
                  const SizedBox(height: 16),

                  // 启用状态
                  SwitchListTile(
                    title: const Text('启用'),
                    subtitle: const Text('禁用后此提供商将不会出现在聊天时的提供商选择列表中'),
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() => _isEnabled = value);
                    },
                    contentPadding:
                        EdgeInsets.zero, // 移除SwitchListTile的默认padding
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // API 配置
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // 调整间距
              child: Text(
                'API 配置',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Key
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      hintText: '输入 API 密钥',
                      border: OutlineInputBorder(),
                      helperText: '从AI提供商官网获取的API密钥，用于身份验证和计费',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入 API Key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Base URL
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                      labelText: 'Base URL',
                      hintText: '输入 API 基础地址',
                      border: const OutlineInputBorder(),
                      helperText:
                          _selectedType == ProviderType.openai ||
                              _selectedType == ProviderType.ollama
                          ? '可自定义API服务器地址，支持代理服务器或本地部署'
                          : '此提供商类型使用固定的官方API地址',
                    ),
                    enabled:
                        _selectedType == ProviderType.openai ||
                        _selectedType == ProviderType.ollama,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // 模型配置
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // 调整间距
              child: Text(
                '模型配置',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ModelListManager(
                models: _models,
                onModelsChanged: (models) {
                  setState(() {
                    _models = models;
                  });
                },
                provider: AiProvider(
                  id: widget.provider?.id ?? 'temp',
                  name: _nameController.text.trim(),
                  type: _selectedType,
                  apiKey: _apiKeyController.text.trim(),
                  baseUrl: _baseUrlController.text.trim().isEmpty
                      ? null
                      : _baseUrlController.text.trim(),
                  models: _models,
                  createdAt: widget.provider?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
