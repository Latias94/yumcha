// ✏️ AI 助手编辑屏幕
//
// 用于创建和编辑 AI 助手的详细配置界面。
// 提供完整的助手参数设置，包括基础信息、AI 参数、系统提示词等。
//
// 🎯 **主要功能**:
// - ➕ **创建助手**: 创建新的 AI 助手配置
// - ✏️ **编辑助手**: 修改现有助手的配置
// - 🎭 **头像选择**: 从丰富的 emoji 中选择助手头像
// - 🔧 **参数调节**: 精确调节温度、Top-P、上下文长度等 AI 参数
// - 📝 **提示词编辑**: 编写和修改系统提示词
// - ✅ **参数验证**: 实时验证参数的有效性
// - 💾 **保存配置**: 保存助手配置到数据库
//
// 📱 **界面组织**:
// - 使用 TabBar 分为"基础设置"和"提示词"两个标签页
// - 基础设置：名称、头像、AI 参数配置
// - 提示词：系统提示词的编辑和预览
// - 提供参数说明和实时反馈
//
// 🔧 **AI 参数说明**:
// - 温度 (0.0-2.0): 控制回复的随机性和创造性
// - Top-P (0.0-1.0): 核采样参数，控制词汇选择范围
// - 上下文长度: 保留的历史消息数量（0=无限制）
// - 流式输出: 是否启用实时流式回复

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../domain/entities/ai_provider.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../providers/ai_assistant_notifier.dart';
import '../../../settings/domain/entities/mcp_server_config.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../../settings/presentation/providers/mcp_service_provider.dart';

class AssistantEditScreen extends ConsumerStatefulWidget {
  final AiAssistant? assistant;
  final List<AiProvider> providers;

  const AssistantEditScreen({
    super.key,
    this.assistant,
    required this.providers,
  });

  @override
  ConsumerState<AssistantEditScreen> createState() =>
      _AssistantEditScreenState();
}

class _AssistantEditScreenState extends ConsumerState<AssistantEditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _uuid = Uuid();
  // 基本信息控制器
  late final TextEditingController _nameController;
  late final TextEditingController _systemPromptController;

  // 选择的值
  late String _selectedAvatar;
  bool _isEnabled = true;

  // AI参数
  late double _temperature;
  late double _topP;
  late double _contextLength; // 改为double以支持滑动条
  bool _streamOutput = true;
  bool _injectTimestamp = false; // 注入消息时间

  // 功能开关
  bool _enableTools = false;

  // MCP配置
  List<String> _selectedMcpServerIds = [];

  bool _isLoading = false;
  bool get _isEditing => widget.assistant != null;

  // Emoji选项 - 更多AI相关的emoji
  final List<String> _emojiOptions = [
    '🤖',
    '👨‍💻',
    '👩‍💻',
    '🎨',
    '📊',
    '🌍',
    '👨‍🏫',
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
    '💰',
    '🏃‍♂️',
    '🏃‍♀️',
    '🎭',
    '🎪',
    '🎨',
    '🎬',
    '📝',
    '📖',
    '📰',
    '📺',
    '📻',
    '📢',
    '📣',
    '📯',
    '🔍',
    '🔎',
    '💻',
    '⌚',
    '📱',
    '💾',
    '💿',
    '📀',
    '🖥️',
    '🖨️',
    '⌨️',
    '🖱️',
    '🖲️',
    '💡',
    '🔋',
    '🔌',
    '💵',
    '💴',
    '💶',
    '💷',
    '💸',
    '💳',
    '💎',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 只有两个tab

    final assistant = widget.assistant;
    _nameController = TextEditingController(text: assistant?.name ?? '');
    _systemPromptController = TextEditingController(
      text: assistant?.systemPrompt ?? '',
    );

    _selectedAvatar = assistant?.avatar ?? '🤖';
    _isEnabled = assistant?.isEnabled ?? true;

    // AI参数
    _temperature = assistant?.temperature ?? 0.7;
    _topP = assistant?.topP ?? 1.0;
    // 处理上下文长度：0表示无限制，显示为257；其他值需要确保在1-256范围内
    final contextLength = assistant?.contextLength ?? 32;
    if (contextLength == 0) {
      _contextLength = 257.0; // 无限制
    } else if (contextLength < 1) {
      _contextLength = 1.0; // 最小值
    } else if (contextLength > 256) {
      _contextLength = 256.0; // 最大值
    } else {
      _contextLength = contextLength.toDouble();
    }
    _streamOutput = assistant?.streamOutput ?? true;
    _injectTimestamp = false; // 新参数，默认false

    // 功能开关
    _enableTools = assistant?.enableTools ?? false;

    // MCP配置
    _selectedMcpServerIds = List.from(assistant?.mcpServerIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _systemPromptController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择头像'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            itemCount: _emojiOptions.length,
            itemBuilder: (context, index) {
              final emoji = _emojiOptions[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAvatar = emoji;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(DesignConstants.spaceXS / 2),
                  decoration: BoxDecoration(
                    color: _selectedAvatar == emoji
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    borderRadius: DesignConstants.radiusS,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  String _getTemperatureLabel(double temperature) {
    if (temperature <= 0.3) {
      return '严谨';
    } else if (temperature <= 0.7) {
      return '平衡';
    } else if (temperature <= 1.0) {
      return '创造';
    } else {
      return '混乱';
    }
  }

  Future<void> _saveAssistant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      // 处理上下文长度：257表示无限制，存储为0
      final contextLength = _contextLength == 257 ? 0 : _contextLength.toInt();
      final assistantName = _nameController.text.trim().isEmpty
          ? '默认助手'
          : _nameController.text.trim();

      final assistant = AiAssistant(
        id: widget.assistant?.id ?? _uuid.v4(),
        name: assistantName,
        description: '', // 移除描述字段
        avatar: _selectedAvatar,
        systemPrompt: _systemPromptController.text.trim(),
        temperature: _temperature,
        topP: _topP,
        maxTokens: 4096, // 固定值，不再让用户设置
        contextLength: contextLength,
        streamOutput: _streamOutput,
        customHeaders: widget.assistant?.customHeaders ?? {},
        customBody: widget.assistant?.customBody ?? {},
        stopSequences: widget.assistant?.stopSequences ?? [],
        enableCodeExecution: false,
        enableImageGeneration: false,
        enableTools: _enableTools,
        enableReasoning: false,
        enableVision: false,
        enableEmbedding: false,
        mcpServerIds: _selectedMcpServerIds,
        isEnabled: _isEnabled,
        createdAt: widget.assistant?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await ref
            .read(aiAssistantNotifierProvider.notifier)
            .updateAssistant(assistant);
      } else {
        await ref
            .read(aiAssistantNotifierProvider.notifier)
            .addAssistant(assistant);
      }

      if (mounted) {
        Navigator.pop(context, true);
        NotificationService().showSuccess(_isEditing ? '助手已更新' : '助手已添加');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑助手' : '创建助手'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAssistant,
            child: _isLoading
                ? SizedBox(
                    width: DesignConstants.iconSizeS,
                    height: DesignConstants.iconSizeS,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Tab栏
            Container(
              margin: DesignConstants.paddingL,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: DesignConstants.radiusM,
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: DesignConstants.radiusM,
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: '基础设置'),
                  Tab(text: '提示词'),
                ],
              ),
            ),

            // Tab内容 - 使用Expanded让内容可滚动
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBasicSettingsTab(), _buildPromptTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSettingsTab() {
    return SingleChildScrollView(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 助手名称和头像
          Padding(
            padding: EdgeInsets.only(bottom: DesignConstants.spaceXXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '助手名称与头像', // 修改标题以更准确描述内容
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        // 使用 titleLarge
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                SizedBox(height: DesignConstants.spaceL),
                Row(
                  children: [
                    // 头像选择器
                    InkWell(
                      onTap: _showEmojiPicker,
                      borderRadius: DesignConstants.radiusS,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: DesignConstants.radiusS,
                        ),
                        child: Center(
                          child: Text(
                            _selectedAvatar,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceL),
                    // 名称输入框
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '输入助手名称',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入助手名称';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AI参数设置
          Column(
            // 移除 Card，直接使用 Column
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI参数',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      // 使用 titleLarge
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              SizedBox(height: DesignConstants.spaceL),
              // 温度设置
              _buildParameterItem(
                context: context,
                title: '温度',
                description: '''控制AI回复的随机性和创造性。
- 0.0-0.3 (严谨): 更可预测和事实性的回答。
- 0.4-0.7 (平衡): 兼顾准确性和创造性。
- 0.8-1.0 (创造): 更具想象力和多样性的回答。
- 1.1-2.0 (混乱): 非常规和实验性的回答，可能不连贯。''',
                control: Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(year2023: false),
                        child: Slider(
                          value: _temperature,
                          min: 0.0,
                          max: 2.0,
                          divisions: 20,
                          onChanged: (value) {
                            setState(() {
                              _temperature = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceM),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignConstants.spaceS,
                        vertical: DesignConstants.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: DesignConstants.radiusS,
                      ),
                      child: Text(
                        _temperature.toStringAsFixed(1),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceS),
                    Chip(
                      label: Text(
                        _getTemperatureLabel(_temperature),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignConstants.spaceS,
                        vertical: 0,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignConstants.spaceXXL),
              // Top P设置
              _buildParameterItem(
                context: context,
                title: 'Top P',
                description: '核采样参数，控制词汇选择范围。建议保持1.0，除非你了解其作用',
                control: Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(year2023: false),
                        child: Slider(
                          value: _topP,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          onChanged: (value) {
                            setState(() {
                              _topP = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceM),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignConstants.spaceS,
                        vertical: DesignConstants.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: DesignConstants.radiusS,
                      ),
                      child: Text(
                        _topP.toStringAsFixed(2),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignConstants.spaceXXL),
              // 上下文消息数量
              _buildParameterItem(
                context: context,
                title: '上下文消息数量',
                description:
                    '控制多少条历史消息会被发送给模型，超过此数量的消息会被忽略，只有最近的N条消息会被保留，可以节省token。范围：1-256条消息或无限制',
                additionalInfo:
                    '当前设置: ${_contextLength == 257 ? "无限制" : _contextLength.toInt().toString()}',
                control: Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(year2023: false),
                        child: Slider(
                          value: _contextLength,
                          min: 1,
                          max: 257, // 1-256=具体数量, 257=无限制
                          divisions: 32,
                          onChanged: (value) {
                            setState(() {
                              _contextLength = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceM),
                    Container(
                      width: 60, // 设置固定宽度
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignConstants.spaceS,
                        vertical: DesignConstants.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: DesignConstants.radiusS,
                      ),
                      child: Center(
                        child: Text(
                          _contextLength == 257
                              ? '无限制'
                              : _contextLength.toInt().toString(),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DesignConstants.spaceXXXL),

              // MCP 配置
              _buildMcpConfigSection(),

              SizedBox(height: DesignConstants.spaceXXL),
              // 流式输出
              SwitchListTile(
                title: Text(
                  '流式输出',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text('启用后AI回复会逐字显示，提供更好的交互体验，但可能会增加网络请求频率'),
                value: _streamOutput,
                onChanged: (value) {
                  setState(() {
                    _streamOutput = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              SizedBox(height: DesignConstants.spaceL),

              // 注入消息时间
              SwitchListTile(
                title: Text(
                  '注入消息时间',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text(
                  '是否把每条消息的发送时间注入到上下文中，以便模型理解消息发送时间，注意开启会消耗更多token',
                ),
                value: _injectTimestamp,
                onChanged: (value) {
                  setState(() {
                    _injectTimestamp = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 辅助方法用于构建每个AI参数项，以减少重复代码
  Widget _buildParameterItem({
    required BuildContext context,
    required String title,
    required String description,
    String? additionalInfo,
    required Widget control,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium, // M3 推荐使用 titleMedium
        ),
        SizedBox(height: DesignConstants.spaceXS),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        if (additionalInfo != null) ...[
          SizedBox(height: DesignConstants.spaceXS),
          Text(
            additionalInfo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        SizedBox(height: DesignConstants.spaceS),
        control,
      ],
    );
  }

  Widget _buildPromptTab() {
    return SingleChildScrollView(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 移除 Card，直接使用 Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '系统提示词',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      // 使用 titleLarge
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              SizedBox(height: DesignConstants.spaceL),
              TextFormField(
                controller: _systemPromptController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入系统提示词...',
                  alignLabelWithHint: true, // 改善多行输入框标签对齐
                ),
              ),
              SizedBox(height: DesignConstants.spaceL),
              Container(
                padding: DesignConstants.paddingM,
                decoration: BoxDecoration(
                  // 使用 surfaceContainerHighest 或类似颜色作为背景，而不是半透明的tertiaryContainer
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: DesignConstants.radiusM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '可用变量：',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall // 使用 titleSmall
                          ?.copyWith(
                            // fontWeight: FontWeight.w600, // titleSmall 默认有合适的weight
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant, // 使用 onSurfaceVariant 强调
                          ),
                    ),
                    SizedBox(height: DesignConstants.spaceS),
                    Text(
                      '日期: {cur_date}, 时间: {cur_time}, 日期和时间: {cur_datetime}, 模型ID: {model_id}, 模型名称: {model_name}, 语言环境: {locale}, 时区: {timezone}, 系统版本: {system_version}, 设备信息: {device_info}, 电池电量: {battery_level}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant, // 保持 onSurfaceVariant
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建MCP配置部分
  Widget _buildMcpConfigSection() {
    return Consumer(
      builder: (context, ref, child) {
        final mcpState = ref.watch(mcpServiceProvider);
        final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
        final mcpServers = settingsNotifier.getMcpServers();

        if (!mcpState.isEnabled || mcpServers.servers.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 工具启用开关
              Row(
                children: [
                  Text(
                    'MCP 工具',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _enableTools,
                    onChanged: (value) {
                      setState(() {
                        _enableTools = value;
                        if (!value) {
                          // 禁用工具时清空选择的服务器
                          _selectedMcpServerIds.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: DesignConstants.spaceL),
              Container(
                padding: DesignConstants.paddingL,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: DesignConstants.radiusM,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: DesignConstants.spaceM),
                    Text(
                      mcpState.isEnabled ? '暂无可用的 MCP 服务器' : 'MCP 服务未启用',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: DesignConstants.spaceS),
                    Text(
                      mcpState.isEnabled
                          ? '请先在设置中添加 MCP 服务器配置'
                          : '请在设置中启用 MCP 服务并配置服务器',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 工具启用开关
            Row(
              children: [
                Text(
                  'MCP 工具',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Spacer(),
                Switch(
                  value: _enableTools,
                  onChanged: (value) {
                    setState(() {
                      _enableTools = value;
                      if (!value) {
                        // 禁用工具时清空选择的服务器
                        _selectedMcpServerIds.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceS),
            Text(
              _enableTools
                  ? '选择此助手可以使用的 MCP 服务器。MCP 服务器提供外部工具和功能扩展。'
                  : '启用工具功能后，助手可以调用 MCP 服务器提供的外部工具。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: DesignConstants.spaceL),
            if (_enableTools)
              ...mcpServers.servers
                  .map((server) => _buildMcpServerItem(server)),
          ],
        );
      },
    );
  }

  /// 构建单个MCP服务器选择项
  Widget _buildMcpServerItem(McpServerConfig server) {
    final isSelected = _selectedMcpServerIds.contains(server.id);

    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: server.isEnabled
            ? (value) {
                setState(() {
                  if (value == true) {
                    _selectedMcpServerIds.add(server.id);
                  } else {
                    _selectedMcpServerIds.remove(server.id);
                  }
                });
              }
            : null,
        title: Text(
          server.name,
          style: TextStyle(
            color: server.isEnabled
                ? null
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (server.description.isNotEmpty)
              Text(
                server.description,
                style: TextStyle(
                  color: server.isEnabled
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.6),
                ),
              ),
            SizedBox(height: DesignConstants.spaceXS),
            Row(
              children: [
                Chip(
                  label: Text(
                    server.type.displayName,
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                SizedBox(width: DesignConstants.spaceS),
                if (!server.isEnabled)
                  Chip(
                    label: const Text(
                      '已禁用',
                      style: TextStyle(fontSize: 11),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
              ],
            ),
          ],
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: DesignConstants.spaceS),
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusS,
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        tileColor: isSelected
            ? Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3)
            : null,
      ),
    );
  }
}
