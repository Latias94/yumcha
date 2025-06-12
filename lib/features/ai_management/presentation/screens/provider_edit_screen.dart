// 🔧 AI 提供商编辑屏幕
//
// 用于创建和编辑 AI 提供商配置的详细界面。
// 支持配置多种主流 AI 服务商，包括 API 密钥、模型列表等。
//
// 🎯 **主要功能**:
// - ➕ **添加提供商**: 创建新的 AI 服务提供商配置
// - ✏️ **编辑提供商**: 修改现有提供商的配置
// - 🔌 **类型选择**: 支持 OpenAI、Anthropic、Google、Ollama、自定义等类型
// - 🔑 **API 配置**: 配置 API 密钥和 Base URL
// - 🧠 **模型管理**: 添加、编辑、删除提供商的模型列表
// - 🌐 **自定义 URL**: 支持自定义 API 服务器地址
// - ✅ **配置验证**: 验证配置的完整性和有效性
// - 💾 **保存配置**: 保存提供商配置到数据库
//
// 📱 **界面组织**:
// - 基本信息：名称、类型、启用状态
// - API 配置：API 密钥、Base URL 设置
// - 模型配置：使用 ModelListWidget 管理模型列表
// - 提供详细的帮助文本和配置说明
//
// 🔌 **支持的提供商类型**:
// - OpenAI: GPT 系列模型，支持自定义 Base URL
// - Anthropic: Claude 系列模型
// - Google: Gemini 系列模型
// - Ollama: 本地部署的开源模型
// - Custom: 用户自定义的 API 接口
//
// 🛠️ **特殊功能**:
// - 自动填充默认 Base URL
// - 支持 API 密钥的安全输入（密码模式）
// - 集成模型管理组件
// - 实时配置验证和错误提示

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_model.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../providers/ai_provider_notifier.dart';
import '../../../../shared/presentation/widgets/model_list_widget.dart';

class ProviderEditScreen extends ConsumerStatefulWidget {
  final AiProvider? provider;

  const ProviderEditScreen({super.key, this.provider});

  @override
  ConsumerState<ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends ConsumerState<ProviderEditScreen> {
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

    final provider = widget.provider;
    _nameController = TextEditingController(text: provider?.name ?? '');
    _apiKeyController = TextEditingController(text: provider?.apiKey ?? '');
    _baseUrlController = TextEditingController(text: provider?.baseUrl ?? '');
    _modelsController = TextEditingController();

    _selectedType = provider?.type ?? ProviderType.openai;
    _isEnabled = provider?.isEnabled ?? true;

    // 初始化模型列表
    _models =
        provider?.models.isNotEmpty == true ? List.from(provider!.models) : [];
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
        await ref
            .read(aiProviderNotifierProvider.notifier)
            .updateProvider(provider);
      } else {
        await ref
            .read(aiProviderNotifierProvider.notifier)
            .addProvider(provider);
      }

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

  /// 获取提供商能力描述
  String _getProviderCapabilityDescription(ProviderType type) {
    // TODO
    return 'TODO';
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
        // 不再自动填充默认模型，让用户手动添加或从API获取
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
                    decoration: InputDecoration(
                      labelText: '类型',
                      border: const OutlineInputBorder(),
                      helperText: _getProviderCapabilityDescription(
                        _selectedType,
                      ),
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
                  Builder(
                    builder: (context) {
                      final supportsCustomBaseUrl = true;
                      return TextFormField(
                        controller: _baseUrlController,
                        decoration: InputDecoration(
                          labelText: 'Base URL',
                          hintText: '输入 API 基础地址',
                          border: const OutlineInputBorder(),
                          helperText: supportsCustomBaseUrl
                              ? '可自定义API服务器地址，支持代理服务器或本地部署'
                              : '此提供商类型使用固定的官方API地址',
                        ),
                        enabled: supportsCustomBaseUrl,
                      );
                    },
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
              child: ModelListWidget(
                models: _models,
                onModelsChanged: (models) {
                  setState(() {
                    _models = models;
                  });
                },
                // 使用 ValueListenableBuilder 来监听文本控制器的变化
                providerBuilder: () => AiProvider(
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
