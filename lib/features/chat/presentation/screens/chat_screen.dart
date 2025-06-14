// 💬 聊天屏幕
//
// YumCha 应用的主要聊天界面，提供与 AI 助手的对话功能。
// 这是应用的核心屏幕，用户在此与 AI 进行交互。
//
// 🎯 **主要功能**:
// - 💬 **AI 对话**: 与选定的 AI 助手进行实时对话
// - 🤖 **助手切换**: 在对话中切换不同的 AI 助手
// - 🔌 **模型切换**: 动态切换 AI 提供商和模型
// - 📝 **消息管理**: 显示、发送、管理聊天消息
// - ⚙️ **配置管理**: 自动确保有效的助手和模型配置
// - 🧹 **对话清空**: 支持清空当前对话记录
//
// 🏗️ **架构特点**:
// - 使用 Riverpod 进行状态管理
// - 基于 ChatView 组件构建聊天界面
// - 支持配置变化的回调通知
// - 自动处理配置的有效性验证
//
// 📱 **界面组成**:
// - AppBar: 显示助手信息和操作按钮
// - ChatView: 主要的聊天交互区域
// - 助手设置面板: 底部弹出的助手选择界面
//
// 🔄 **状态管理**:
// - 接收外部传入的对话状态
// - 自动同步配置变化到父组件
// - 处理助手、提供商、模型的选择逻辑

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation_ui_state.dart';
import '../../domain/entities/message.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/providers/providers.dart';
import '../providers/unified_chat_notifier.dart';
import '../widgets/chat_configuration_status.dart';
import 'chat_view.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationState,
    this.showAppBar = true,
    this.onAssistantConfigChanged,
    this.onConversationUpdated,
    this.initialMessageId,
  });

  /// 对话状态
  final ConversationUiState conversationState;

  /// 是否显示应用栏
  final bool showAppBar;

  /// 助手配置变化回调
  final Function(String assistantId, String providerId, String modelName)?
      onAssistantConfigChanged;

  /// 对话更新回调
  final Function(ConversationUiState conversation)? onConversationUpdated;

  /// 初始要定位的消息ID
  final String? initialMessageId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late ConversationUiState _conversationState;

  @override
  void initState() {
    super.initState();
    _conversationState = widget.conversationState;

    // 使用统一聊天状态管理初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUnifiedChatState();
    });
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传入新的对话状态时，更新本地状态
    if (oldWidget.conversationState != widget.conversationState) {
      setState(() {
        _conversationState = widget.conversationState;
      });
      // 只有在关键配置发生变化时才同步状态，避免无限循环
      if (_shouldSyncConfiguration(oldWidget.conversationState, widget.conversationState)) {
        Future(() => _syncToUnifiedChatState());
      }
    }
  }

  /// 初始化统一聊天状态
  void _initializeUnifiedChatState() {
    final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);

    // 加载当前对话
    if (_conversationState.id.isNotEmpty) {
      unifiedChatNotifier.loadConversation(_conversationState.id);
    }

    // 设置配置
    if (_conversationState.assistantId != null) {
      _syncConfigurationToUnifiedState();
    }
  }

  /// 检查是否需要同步配置
  bool _shouldSyncConfiguration(ConversationUiState? oldState, ConversationUiState? newState) {
    if (oldState == null && newState == null) return false;
    if (oldState == null || newState == null) return true;

    // 检查关键配置是否发生变化
    return oldState.assistantId != newState.assistantId ||
           oldState.selectedProviderId != newState.selectedProviderId ||
           oldState.selectedModelId != newState.selectedModelId ||
           oldState.id != newState.id;
  }

  /// 同步到统一聊天状态
  void _syncToUnifiedChatState() {
    final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);

    // 加载对话
    if (_conversationState.id.isNotEmpty) {
      unifiedChatNotifier.loadConversation(_conversationState.id);
    }

    // 同步配置
    _syncConfigurationToUnifiedState();
  }

  /// 同步配置到统一状态
  void _syncConfigurationToUnifiedState() {
    try {
      // 使用新的统一AI管理Provider
      final assistants = ref.read(aiAssistantsProvider);
      final providers = ref.read(aiProvidersProvider);
      final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);
      final currentConfig = ref.read(chatConfigurationProvider);

      final assistant = assistants
          .where((a) => a.id == _conversationState.assistantId)
          .firstOrNull;
      final provider = providers
          .where((p) => p.id == _conversationState.selectedProviderId)
          .firstOrNull;

      if (assistant != null && provider != null) {
        final model = provider.models
            .where((m) => m.name == _conversationState.selectedModelId)
            .firstOrNull;

        if (model != null) {
          // 只有在配置真正发生变化时才更新
          bool needsUpdate = false;

          if (currentConfig.selectedAssistant?.id != assistant.id) {
            unifiedChatNotifier.selectAssistant(assistant);
            needsUpdate = true;
          }

          if (currentConfig.selectedProvider?.id != provider.id ||
              currentConfig.selectedModel?.name != model.name) {
            unifiedChatNotifier.selectModel(provider, model);
            needsUpdate = true;
          }

          if (needsUpdate) {
            debugPrint('配置已同步到统一状态: ${assistant.name}, ${provider.name}, ${model.name}');
          }
        }
      }
    } catch (e) {
      // 静默处理错误，避免影响界面显示
      debugPrint('同步配置到统一状态失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      // 使用新的统一AI管理Provider
      final assistants = ref.watch(aiAssistantsProvider);

      final assistant = _conversationState.assistantId != null
          ? assistants
              .where((a) => a.id == _conversationState.assistantId!)
              .firstOrNull
          : null;

      return Scaffold(
        appBar: widget.showAppBar ? _buildAppBar(context, assistant) : null,
        body: Column(
          children: [
            // 配置状态显示
            _buildConfigurationStatusBar(context),
            // 聊天界面
            Expanded(
              child: ChatView(
                conversationId: _conversationState.id,
                assistantId: _conversationState.assistantId ?? '',
                selectedProviderId: _conversationState.selectedProviderId,
                selectedModelName: _conversationState.selectedModelId ?? '',
                messages: _conversationState.messages,
                welcomeMessage: null, // 不显示欢迎消息，让界面开始时为空
                suggestions: _getDefaultSuggestions(),
                onMessagesChanged: _onMessagesChanged,
                onProviderModelChanged: _onProviderModelChanged,
                initialMessageId: widget.initialMessageId,
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(unifiedAiManagementProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
  }

  List<String> _getDefaultSuggestions() {
    // return ['你好', '帮我写代码', '解答问题', '创意建议'];
    return [];
  }

  /// 构建配置状态栏
  /// 只在配置有问题时显示，正常状态下不显示任何内容
  Widget _buildConfigurationStatusBar(BuildContext context) {
    return ChatConfigurationStatus(
      compact: true,
      showDetails: false,
      onFixRequested: () => _showConfigurationFixDialog(context),
    );
  }

  /// 显示配置修复对话框
  void _showConfigurationFixDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('配置问题'),
          ],
        ),
        content: const ChatConfigurationStatus(
          compact: false,
          showDetails: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 导航到设置页面
              Navigator.of(context).pushNamed('/settings');
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AiAssistant? assistant) {
    final theme = Theme.of(context);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主标题 - 应用名称
          Text(
            'YumCha',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          // 副标题 - 当前助手信息
          if (assistant != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                // 助手emoji图标
                Text(
                  assistant.avatar,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                // 助手名称
                Flexible(
                  child: Text(
                    assistant.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 模型信息指示器
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _conversationState.selectedProviderId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 2),
            Text(
              '选择助手开始聊天',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_conversationState.assistantId != null)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showAssistantSettings(context),
            tooltip: '助手设置',
          ),
        IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: () => _clearConversation(),
          tooltip: '清空对话',
        ),
      ],
    );
  }

  void _onMessagesChanged(List<Message> messages) {
    setState(() {
      _conversationState = _conversationState.copyWith(messages: messages);
    });
    widget.onConversationUpdated?.call(_conversationState);
  }

  void _onProviderModelChanged(String providerId, String modelName) {
    setState(() {
      _conversationState = _conversationState.copyWith(
        selectedProviderId: providerId,
        selectedModelId: modelName,
      );
    });

    if (_conversationState.assistantId != null) {
      widget.onAssistantConfigChanged?.call(
        _conversationState.assistantId!,
        providerId,
        modelName,
      );
    }
    widget.onConversationUpdated?.call(_conversationState);
  }

  void _showAssistantSettings(BuildContext context) {
    // 显示助手选择和配置
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAssistantSettingsSheet(context),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }

  /// 选择助手并配置相应的提供商和模型
  Future<void> _selectAssistantWithConfiguration(AiAssistant assistant) async {
    try {
      // 使用统一聊天状态管理选择助手
      final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);
      await unifiedChatNotifier.selectAssistant(assistant);

      // 获取更新后的配置
      final chatConfig = ref.read(chatConfigurationProvider);

      // 更新本地对话状态
      setState(() {
        _conversationState = _conversationState.copyWith(
          assistantId: assistant.id,
          selectedProviderId: chatConfig.selectedProvider?.id ?? '',
          selectedModelId: chatConfig.selectedModel?.name ?? '',
        );
      });

      // 通知父组件
      widget.onConversationUpdated?.call(_conversationState);
      if (chatConfig.isComplete) {
        widget.onAssistantConfigChanged?.call(
          assistant.id,
          chatConfig.selectedProvider!.id,
          chatConfig.selectedModel!.name,
        );
      }
    } catch (e) {
      // 错误处理
      if (mounted) {
        NotificationService().showError('选择助手失败: $e');
      }
    }
  }

  Widget _buildAssistantSettingsSheet(BuildContext context) {
    final theme = Theme.of(context);

    try {
      // 使用新的统一AI管理Provider
      final assistants = ref.watch(aiAssistantsProvider);

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('助手设置', style: theme.textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 当前助手信息
            if (_conversationState.assistantId != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('当前助手', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final assistant = assistants
                              .where(
                                (a) => a.id == _conversationState.assistantId!,
                              )
                              .firstOrNull;
                          return Text(assistant?.name ?? '未知');
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '提供商: ${_conversationState.selectedProviderId}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '模型: ${_conversationState.selectedModelId}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 助手选择
            Text('选择助手', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Column(
              children: assistants.map((assistant) {
                final isSelected =
                    assistant.id == _conversationState.assistantId;
                return Card(
                  color: isSelected ? theme.colorScheme.primaryContainer : null,
                  child: ListTile(
                    leading: Text(
                      assistant.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(assistant.name),
                    subtitle: Text(
                      assistant.description.isNotEmpty
                          ? assistant.description
                          : '助手配置', // 临时修复：不再显示提供商和模型信息
                    ),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () async {
                      // 保存context引用
                      final navigator = Navigator.of(context);

                      // 使用ChatConfigurationNotifier来处理助手选择
                      await _selectAssistantWithConfiguration(assistant);

                      if (mounted) {
                        navigator.pop();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    } catch (error) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载助手失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(unifiedAiManagementProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空当前对话记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _conversationState = _conversationState.copyWith(messages: []);
              });
              widget.onConversationUpdated?.call(_conversationState);
              NotificationService().showSuccess('对话已清空');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
