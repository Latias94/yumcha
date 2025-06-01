import 'package:flutter/material.dart';
import '../models/ai_assistant.dart';
import '../models/ai_provider.dart';
import '../services/assistant_repository.dart';
import '../services/database_service.dart';

class AssistantEditScreen extends StatefulWidget {
  final AiAssistant? assistant;
  final List<AiProvider> providers;

  const AssistantEditScreen({
    super.key,
    this.assistant,
    required this.providers,
  });

  @override
  State<AssistantEditScreen> createState() => _AssistantEditScreenState();
}

class _AssistantEditScreenState extends State<AssistantEditScreen>
    with SingleTickerProviderStateMixin {
  late final AssistantRepository _repository;
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // 基本信息控制器
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _systemPromptController;

  // 选择的值
  late String _selectedAvatar;
  late String _selectedProviderId;
  late String _selectedModelName;
  bool _isEnabled = true;

  // AI参数
  late double _temperature;
  late double _topP;
  late int _maxTokens;
  late int _contextLength;
  bool _streamOutput = true;
  double? _frequencyPenalty;
  double? _presencePenalty;

  // 功能设置
  bool _enableWebSearch = false;
  bool _enableCodeExecution = false;
  bool _enableImageGeneration = false;

  bool _isLoading = false;
  bool get _isEditing => widget.assistant != null;

  // 头像选项
  final List<String> _avatarOptions = [
    '🤖',
    '👨‍💻',
    '🎨',
    '📊',
    '🌍',
    '👩‍🏫',
    '🔬',
    '💡',
    '🎯',
    '🚀',
    '📚',
    '🎵',
    '🏥',
    '⚖️',
    '🍳',
    '🎮',
    '📸',
    '✈️',
    '🌱',
    '🔧',
  ];

  @override
  void initState() {
    super.initState();
    _repository = AssistantRepository(DatabaseService.instance.database);
    _tabController = TabController(length: 4, vsync: this);

    final assistant = widget.assistant;
    _nameController = TextEditingController(text: assistant?.name ?? '');
    _descriptionController = TextEditingController(
      text: assistant?.description ?? '',
    );
    _systemPromptController = TextEditingController(
      text: assistant?.systemPrompt ?? '',
    );

    _selectedAvatar = assistant?.avatar ?? '🤖';
    _selectedProviderId =
        assistant?.providerId ??
        (widget.providers.isNotEmpty ? widget.providers.first.id : '');
    _selectedModelName = assistant?.modelName ?? '';
    _isEnabled = assistant?.isEnabled ?? true;

    // AI参数
    _temperature = assistant?.temperature ?? 0.7;
    _topP = assistant?.topP ?? 1.0;
    _maxTokens = assistant?.maxTokens ?? 2048;
    _contextLength = assistant?.contextLength ?? 10;
    _streamOutput = assistant?.streamOutput ?? true;
    _frequencyPenalty = assistant?.frequencyPenalty;
    _presencePenalty = assistant?.presencePenalty;

    // 功能设置
    _enableWebSearch = assistant?.enableWebSearch ?? false;
    _enableCodeExecution = assistant?.enableCodeExecution ?? false;
    _enableImageGeneration = assistant?.enableImageGeneration ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<String> _getAvailableModels() {
    if (_selectedProviderId.isEmpty) return [];
    final provider = widget.providers.firstWhere(
      (p) => p.id == _selectedProviderId,
      orElse: () => widget.providers.first,
    );
    return provider.supportedModels;
  }

  Future<void> _saveAssistant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      final assistant = AiAssistant(
        id:
            widget.assistant?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        avatar: _selectedAvatar,
        systemPrompt: _systemPromptController.text.trim(),
        providerId: _selectedProviderId,
        modelName: _selectedModelName,
        temperature: _temperature,
        topP: _topP,
        maxTokens: _maxTokens,
        contextLength: _contextLength,
        streamOutput: _streamOutput,
        frequencyPenalty: _frequencyPenalty,
        presencePenalty: _presencePenalty,
        customHeaders: widget.assistant?.customHeaders ?? {},
        customBody: widget.assistant?.customBody ?? {},
        stopSequences: widget.assistant?.stopSequences ?? [],
        enableWebSearch: _enableWebSearch,
        enableCodeExecution: _enableCodeExecution,
        enableImageGeneration: _enableImageGeneration,
        isEnabled: _isEnabled,
        createdAt: widget.assistant?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await _repository.updateAssistant(assistant);
      } else {
        await _repository.insertAssistant(assistant);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_isEditing ? '助手已更新' : '助手已添加')));
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

  void _loadPresetAssistant(AssistantType type) {
    setState(() {
      _nameController.text = type.displayName;
      _descriptionController.text = type.defaultPrompt;
      _systemPromptController.text = type.defaultPrompt;
      _selectedAvatar = type.avatar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑助手' : '添加助手'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '基本信息'),
            Tab(text: 'AI参数'),
            Tab(text: '功能设置'),
            Tab(text: '预设模板'),
          ],
        ),
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
              onPressed: _saveAssistant,
              child: Text(
                _isEditing ? '更新' : '保存',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildAiParametersTab(),
            _buildFeaturesTab(),
            _buildPresetsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 头像选择
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '头像',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _avatarOptions.map((avatar) {
                    final isSelected = avatar == _selectedAvatar;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = avatar),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            avatar,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 基本信息
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '基本信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: '输入助手名称',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入助手名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    hintText: '输入助手描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入助手描述';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('启用'),
                  subtitle: const Text('是否启用此助手'),
                  value: _isEnabled,
                  onChanged: (value) => setState(() => _isEnabled = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 提供商和模型
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '提供商和模型',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedProviderId.isEmpty
                      ? null
                      : _selectedProviderId,
                  decoration: const InputDecoration(
                    labelText: '提供商',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.providers.map((provider) {
                    return DropdownMenuItem(
                      value: provider.id,
                      child: Text(provider.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedProviderId = value;
                        _selectedModelName = '';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请选择提供商';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedModelName.isEmpty ? null : _selectedModelName,
                  decoration: const InputDecoration(
                    labelText: '模型',
                    border: OutlineInputBorder(),
                  ),
                  items: _getAvailableModels().map((model) {
                    return DropdownMenuItem(value: model, child: Text(model));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedModelName = value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请选择模型';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 系统提示词
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '系统提示词',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _systemPromptController,
                  decoration: const InputDecoration(
                    labelText: '系统提示词',
                    hintText: '输入系统提示词，定义助手的行为和角色',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入系统提示词';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiParametersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 参数配置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 温度
                Text('温度: ${_temperature.toStringAsFixed(1)}'),
                Slider(
                  value: _temperature,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  onChanged: (value) => setState(() => _temperature = value),
                ),
                const Text(
                  '控制输出的随机性。较低的值使输出更确定，较高的值使输出更随机。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Top P
                Text('Top P: ${_topP.toStringAsFixed(1)}'),
                Slider(
                  value: _topP,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) => setState(() => _topP = value),
                ),
                const Text(
                  '控制词汇选择的多样性。较低的值使输出更集中，较高的值使输出更多样。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // 最大Token数
                TextFormField(
                  initialValue: _maxTokens.toString(),
                  decoration: const InputDecoration(
                    labelText: '最大Token数',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final tokens = int.tryParse(value);
                    if (tokens != null && tokens > 0) {
                      _maxTokens = tokens;
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 上下文长度
                TextFormField(
                  initialValue: _contextLength.toString(),
                  decoration: const InputDecoration(
                    labelText: '上下文长度（消息数量）',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final length = int.tryParse(value);
                    if (length != null && length > 0) {
                      _contextLength = length;
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 流式输出
                SwitchListTile(
                  title: const Text('流式输出'),
                  subtitle: const Text('是否启用流式输出'),
                  value: _streamOutput,
                  onChanged: (value) => setState(() => _streamOutput = value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '功能设置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text('网络搜索'),
                  subtitle: const Text('允许助手进行网络搜索'),
                  value: _enableWebSearch,
                  onChanged: (value) =>
                      setState(() => _enableWebSearch = value),
                ),

                SwitchListTile(
                  title: const Text('代码执行'),
                  subtitle: const Text('允许助手执行代码'),
                  value: _enableCodeExecution,
                  onChanged: (value) =>
                      setState(() => _enableCodeExecution = value),
                ),

                SwitchListTile(
                  title: const Text('图像生成'),
                  subtitle: const Text('允许助手生成图像'),
                  value: _enableImageGeneration,
                  onChanged: (value) =>
                      setState(() => _enableImageGeneration = value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '选择预设模板',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...AssistantType.values.map((type) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(type.avatar, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(type.displayName),
              subtitle: Text(
                type.defaultPrompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _loadPresetAssistant(type),
            ),
          );
        }).toList(),
      ],
    );
  }
}
