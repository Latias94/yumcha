import 'package:flutter/material.dart';
import '../models/ai_provider.dart';
import '../services/provider_repository.dart';
import '../services/database_service.dart';

class ProviderEditScreen extends StatefulWidget {
  final AiProvider? provider;

  const ProviderEditScreen({super.key, this.provider});

  @override
  State<ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends State<ProviderEditScreen> {
  late final ProviderRepository _repository;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelsController;

  late ProviderType _selectedType;
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
    _modelsController = TextEditingController(
      text: provider?.supportedModels.join(', ') ?? '',
    );

    _selectedType = provider?.type ?? ProviderType.openai;
    _isEnabled = provider?.isEnabled ?? true;
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
      final models = _modelsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final provider = AiProvider(
        id:
            widget.provider?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        apiKey: _apiKeyController.text.trim(),
        baseUrl: _baseUrlController.text.trim().isEmpty
            ? null
            : _baseUrlController.text.trim(),
        supportedModels: models,
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

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '提供商已更新' : '提供商已添加')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
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
            TextButton(
              onPressed: _saveProvider,
              child: Text(
                _isEditing ? '更新' : '保存',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '基本信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 名称
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '名称',
                        hintText: '输入提供商名称',
                        border: OutlineInputBorder(),
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
                      subtitle: const Text('是否启用此提供商'),
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() => _isEnabled = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // API 配置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API 配置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // API Key
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: '输入 API 密钥',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        hintText: '输入 API 基础地址',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 模型配置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '模型配置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 支持的模型
                    TextFormField(
                      controller: _modelsController,
                      decoration: const InputDecoration(
                        labelText: '支持的模型',
                        hintText: '输入模型名称，用逗号分隔',
                        border: OutlineInputBorder(),
                        helperText: '例如: gpt-4, gpt-3.5-turbo',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入至少一个模型名称';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
