import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_ui_state.dart';
import '../models/message.dart';
import '../models/ai_assistant.dart';
import '../models/ai_provider.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../providers/providers.dart';
import '../ui/chat/chat_view.dart';

/// 聊天屏幕 - 使用重构后的聊天组件
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationState,
    this.showAppBar = true,
    this.onAssistantConfigChanged,
    this.onConversationUpdated,
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

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final AiService _aiService = AiService();
  late ConversationUiState _conversationState;

  @override
  void initState() {
    super.initState();
    _conversationState = widget.conversationState;
    _aiService.initialize().then((_) {
      // 初始化后，确保有有效的助手配置
      _ensureValidConfiguration();
    });
  }

  void _ensureValidConfiguration() {
    final assistantsAsync = ref.read(aiAssistantNotifierProvider);
    final providersAsync = ref.read(aiProviderNotifierProvider);

    assistantsAsync.whenData((assistants) {
      providersAsync.whenData((providers) {
        // 确保有有效的助手和提供商配置
        bool needsUpdate = false;
        AiAssistant? selectedAssistant;
        AiProvider? selectedProvider;
        String? selectedModelId;

        // 1. 确保有选中的助手
        if (_conversationState.assistantId == null ||
            _conversationState.assistantId!.isEmpty) {
          // 优先选择默认助手
          selectedAssistant = assistants
              .where((a) => a.id == 'default-assistant' && a.isEnabled)
              .firstOrNull;
          // 如果没有默认助手，选择第一个启用的助手
          selectedAssistant ??= assistants
              .where((a) => a.isEnabled)
              .firstOrNull;
          // 如果没有启用的助手，选择第一个助手
          selectedAssistant ??= assistants.firstOrNull;

          if (selectedAssistant != null) {
            needsUpdate = true;
          }
        } else {
          selectedAssistant = assistants
              .where((a) => a.id == _conversationState.assistantId!)
              .firstOrNull;

          // 如果选中的助手不存在或已被禁用，重新选择
          if (selectedAssistant == null || !selectedAssistant.isEnabled) {
            selectedAssistant = assistants
                .where((a) => a.isEnabled)
                .firstOrNull;
            selectedAssistant ??= assistants.firstOrNull;
            if (selectedAssistant != null) {
              needsUpdate = true;
            }
          }
        }

        if (selectedAssistant != null) {
          // 2. 确保有选中的提供商
          if (_conversationState.selectedProviderId.isEmpty) {
            // 选择第一个可用的提供商
            selectedProvider = providers.where((p) => p.isEnabled).firstOrNull;
            selectedProvider ??= providers.firstOrNull;

            if (selectedProvider != null) {
              needsUpdate = true;
            }
          } else {
            selectedProvider = providers
                .where((p) => p.id == _conversationState.selectedProviderId)
                .firstOrNull;

            // 如果选中的提供商不存在或已被禁用，重新选择
            if (selectedProvider == null || !selectedProvider.isEnabled) {
              selectedProvider = providers
                  .where((p) => p.isEnabled)
                  .firstOrNull;
              selectedProvider ??= providers.firstOrNull;
              if (selectedProvider != null) {
                needsUpdate = true;
              }
            }
          }

          // 3. 确保有选中的模型
          if (selectedProvider != null) {
            if (_conversationState.selectedModelId == null ||
                _conversationState.selectedModelId!.isEmpty ||
                !selectedProvider.models.any(
                  (m) => m.name == _conversationState.selectedModelId,
                )) {
              // 使用提供商的第一个模型
              if (selectedProvider.models.isNotEmpty) {
                selectedModelId = selectedProvider.models.first.name;
                needsUpdate = true;
              }
            } else {
              selectedModelId = _conversationState.selectedModelId;
            }
          }
        }

        // 更新状态
        if (needsUpdate &&
            selectedAssistant != null &&
            selectedProvider != null &&
            selectedModelId != null) {
          setState(() {
            _conversationState = _conversationState.copyWith(
              assistantId: selectedAssistant!.id,
              selectedProviderId: selectedProvider!.id,
              selectedModelId: selectedModelId,
            );
          });

          // 通知上级组件配置已更新
          widget.onConversationUpdated?.call(_conversationState);
          widget.onAssistantConfigChanged?.call(
            selectedAssistant.id,
            selectedProvider.id,
            selectedModelId,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final assistantsAsync = ref.watch(aiAssistantNotifierProvider);

    return assistantsAsync.when(
      data: (assistants) {
        final assistant = _conversationState.assistantId != null
            ? assistants
                  .where((a) => a.id == _conversationState.assistantId!)
                  .firstOrNull
            : null;

        return Scaffold(
          appBar: widget.showAppBar ? _buildAppBar(context, assistant) : null,
          body: ChatView(
            assistantId: _conversationState.assistantId ?? '',
            selectedProviderId: _conversationState.selectedProviderId,
            selectedModelName: _conversationState.selectedModelId ?? '',
            messages: _conversationState.messages,
            welcomeMessage: null, // 不显示欢迎消息，让界面开始时为空
            suggestions: _getDefaultSuggestions(),
            onMessagesChanged: _onMessagesChanged,
            onProviderModelChanged: _onProviderModelChanged,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(aiAssistantNotifierProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getDefaultSuggestions() {
    // return ['你好', '帮我写代码', '解答问题', '创意建议'];
    return [];
  }

  AppBar _buildAppBar(BuildContext context, AiAssistant? assistant) {
    final theme = Theme.of(context);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(assistant?.name ?? '聊天'),
          if (assistant != null) ...[
            Text(
              '${_conversationState.selectedProviderId} - ${_conversationState.selectedModelId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildAssistantSettingsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
    final providersAsync = ref.watch(aiProviderNotifierProvider);

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
                    assistantsAsync.when(
                      data: (assistants) {
                        final assistant = assistants
                            .where(
                              (a) => a.id == _conversationState.assistantId!,
                            )
                            .firstOrNull;
                        return Text(assistant?.name ?? '未知');
                      },
                      loading: () => const Text('加载中...'),
                      error: (_, __) => const Text('加载失败'),
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
          assistantsAsync.when(
            data: (assistants) => Column(
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
                    onTap: () {
                      // 临时修复：选择助手时使用第一个可用的提供商和模型
                      providersAsync.whenData((providers) {
                        final provider = providers
                            .where((p) => p.isEnabled)
                            .firstOrNull;
                        if (provider != null && provider.models.isNotEmpty) {
                          Navigator.of(context).pop();
                          setState(() {
                            _conversationState = _conversationState.copyWith(
                              assistantId: assistant.id,
                              selectedProviderId: provider.id,
                              selectedModelId: provider.models.first.name,
                            );
                          });

                          widget.onConversationUpdated?.call(
                            _conversationState,
                          );
                          widget.onAssistantConfigChanged?.call(
                            assistant.id,
                            provider.id,
                            provider.models.first.name,
                          );
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('加载助手失败: $error'),
          ),
        ],
      ),
    );
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
