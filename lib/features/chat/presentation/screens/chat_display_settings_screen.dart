// 🎨 聊天样式设置屏幕
//
// 用于配置聊天消息的显示样式，提供不同的消息展示方式选择。
// 用户可以根据个人偏好选择最适合的聊天界面样式。
//
// 🎯 **主要功能**:
// - 🎨 **样式选择**: 在三种消息显示样式之间切换
// - 🧩 **块化模式**: 启用/禁用新的块化消息架构
// - 👀 **实时预览**: 提供样式效果的实时预览
// - 💾 **偏好保存**: 自动保存用户的样式偏好设置
// - 📱 **响应式设计**: 适配不同屏幕尺寸的显示效果
// - ✅ **即时反馈**: 切换样式时提供操作成功提示
//
// 🎨 **支持的样式**:
// - **列表样式**: 无背景色，占满宽度，适合长文本阅读
// - **现代卡片**: 带阴影和边框，适合桌面端使用
// - **聊天气泡**: 传统聊天气泡，有背景色和圆角，类似微信、QQ
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 单选按钮组织样式选择
// - 实时预览区域展示效果
// - 清晰的样式说明和图标指示
//
// 💡 **设计理念**:
// - 提供个性化的聊天体验
// - 满足不同用户的阅读习惯
// - 简化样式切换流程
// - 直观的效果预览

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_bubble_style.dart';
import '../providers/chat_style_provider.dart';
import '../providers/chat_providers.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  Future<void> _saveStyle(WidgetRef ref, ChatBubbleStyle style) async {
    try {
      await ref.read(chatStyleProvider.notifier).updateStyle(style);
      // NotificationService().showSuccess('已切换到${style.displayName}样式');
    } catch (e) {
      NotificationService().showError('保存设置失败');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStyleState = ref.watch(chatStyleProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("显示设置"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (chatStyleState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _buildSectionHeader(context, "消息显示模式"),
                _buildBlockViewToggle(context, ref),
                const SizedBox(height: 16),

                _buildSectionHeader(context, "消息显示样式"),
                _buildStyleOption(context, ref, ChatBubbleStyle.list),
                _buildStyleOption(context, ref, ChatBubbleStyle.card),
                _buildStyleOption(context, ref, ChatBubbleStyle.bubble),
                const SizedBox(height: 24),

                _buildSectionHeader(context, "高级设置"),
                _buildAdvancedSettings(context, ref),
                const SizedBox(height: 24),

                _buildSectionHeader(context, "样式预览"),
                _buildPreviewSection(context, ref),
                const SizedBox(height: 32),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildBlockViewToggle(BuildContext context, WidgetRef ref) {
    final chatSettings = ref.watch(chatSettingsProvider);

    return SwitchListTile(
      title: const Text("启用块化消息显示"),
      subtitle: const Text("使用新的块化消息架构，支持更丰富的内容类型和更好的性能"),
      value: chatSettings.enableBlockView,
      onChanged: (value) {
        ref.read(chatSettingsProvider.notifier).toggleBlockView();
        NotificationService().showSuccess(
          value ? '已启用块化消息显示' : '已禁用块化消息显示'
        );
      },
      secondary: Icon(
        chatSettings.enableBlockView
          ? Icons.view_module_rounded
          : Icons.view_list_rounded,
        color: chatSettings.enableBlockView
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildAdvancedSettings(BuildContext context, WidgetRef ref) {
    final chatSettings = ref.watch(chatSettingsProvider);

    return Column(
      children: [
        SwitchListTile(
          title: const Text("显示思考过程"),
          subtitle: const Text("显示AI的思考过程内容（如果有）"),
          value: chatSettings.showThinkingProcess,
          onChanged: (value) {
            ref.read(chatSettingsProvider.notifier).toggleThinkingProcess();
          },
          secondary: Icon(
            Icons.psychology_rounded,
            color: chatSettings.showThinkingProcess
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        if (chatSettings.enableBlockView) ...[
          SwitchListTile(
            title: const Text("显示块类型标签"),
            subtitle: const Text("在消息块上显示类型标识（调试用）"),
            value: chatSettings.showBlockTypeLabels,
            onChanged: (value) {
              ref.read(chatSettingsProvider.notifier).toggleBlockTypeLabels();
            },
            secondary: Icon(
              Icons.label_rounded,
              color: chatSettings.showBlockTypeLabels
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          SwitchListTile(
            title: const Text("启用块编辑功能"),
            subtitle: const Text("允许编辑和操作单个消息块（实验性功能）"),
            value: chatSettings.enableBlockEditing,
            onChanged: (value) {
              ref.read(chatSettingsProvider.notifier).toggleBlockEditing();
            },
            secondary: Icon(
              Icons.edit_rounded,
              color: chatSettings.enableBlockEditing
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStyleOption(
      BuildContext context, WidgetRef ref, ChatBubbleStyle style) {
    final currentStyle = ref.watch(currentChatStyleProvider);
    final isSelected = currentStyle == style;

    String subtitle;
    switch (style) {
      case ChatBubbleStyle.bubble:
        subtitle = "传统聊天气泡样式，有背景色和圆角";
        break;
      case ChatBubbleStyle.list:
        subtitle = "列表样式，无背景色，适合长文本阅读";
        break;
      case ChatBubbleStyle.card:
        subtitle = "现代卡片样式，带阴影和边框，适合桌面端";
        break;
    }

    return RadioListTile<ChatBubbleStyle>(
      title: Text(style.displayName),
      subtitle: Text(subtitle),
      value: style,
      groupValue: currentStyle,
      onChanged: (value) {
        if (value != null) {
          _saveStyle(ref, value);
        }
      },
      secondary: Icon(
        switch (style) {
          ChatBubbleStyle.bubble => Icons.chat_bubble_outline,
          ChatBubbleStyle.list => Icons.list,
          ChatBubbleStyle.card => Icons.credit_card_rounded,
        },
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, WidgetRef ref) {
    final chatSettings = ref.watch(chatSettingsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "预览效果",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chatSettings.enableBlockView
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chatSettings.enableBlockView ? "块化模式" : "传统模式",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: chatSettings.enableBlockView
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 用户消息预览
          _buildPreviewMessage(context, ref, "这是一条用户消息的预览效果", isFromUser: true),

          const SizedBox(height: 8),

          // AI消息预览 - 根据是否启用块化显示不同内容
          if (chatSettings.enableBlockView) ...[
            _buildBlockPreviewMessage(context, ref),
          ] else ...[
            _buildPreviewMessage(
              context,
              ref,
              "这是一条AI回复消息的预览效果，可能会比较长一些，用来展示不同样式下的显示效果。",
              isFromUser: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewMessage(
      BuildContext context, WidgetRef ref, String content,
      {required bool isFromUser}) {
    final theme = Theme.of(context);
    final currentStyle = ref.watch(currentChatStyleProvider);

    switch (currentStyle) {
      case ChatBubbleStyle.bubble:
        // 气泡样式预览
        final bubbleColor = isFromUser
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest;
        final textColor = isFromUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface;

        return Align(
          alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isFromUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isFromUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
            ),
            child: Text(
              content,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        );

      case ChatBubbleStyle.card:
        // 卡片样式预览
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isFromUser
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isFromUser
                              ? Icons.person_rounded
                              : Icons.smart_toy_rounded,
                          color: isFromUser
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSecondaryContainer,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFromUser ? "用户" : "AI助手",
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case ChatBubbleStyle.list:
        // 列表样式预览 - 匹配实际的列表样式
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 角色标识和时间戳
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isFromUser
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3)
                          : theme.colorScheme.secondaryContainer
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFromUser ? "用户" : "AI助手",
                      style: TextStyle(
                        color: isFromUser
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "刚刚",
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 消息内容容器
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getListStyleBackgroundColor(theme),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.02),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  content,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  /// 构建块化消息预览
  Widget _buildBlockPreviewMessage(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chatSettings = ref.watch(chatSettingsProvider);
    final currentStyle = ref.watch(currentChatStyleProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 消息头部（根据样式调整）
          if (currentStyle == ChatBubbleStyle.list) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "AI助手",
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "刚刚",
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // 消息块容器
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: _getMessageContainerDecoration(theme, currentStyle),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 思考过程块（如果启用）
                if (chatSettings.showThinkingProcess) ...[
                  _buildPreviewBlock(
                    context,
                    "思考过程",
                    "让我分析一下这个问题...",
                    Icons.psychology_rounded,
                    theme.colorScheme.primary,
                    showLabel: chatSettings.showBlockTypeLabels,
                  ),
                  const SizedBox(height: 8),
                ],

                // 主文本块
                _buildPreviewBlock(
                  context,
                  "主要内容",
                  "这是一条**块化消息**的预览效果，支持多种内容类型：",
                  Icons.text_fields_rounded,
                  theme.colorScheme.onSurface,
                  showLabel: chatSettings.showBlockTypeLabels,
                ),

                const SizedBox(height: 8),

                // 代码块
                _buildPreviewBlock(
                  context,
                  "代码块",
                  "print('Hello, Block Message!')",
                  Icons.code_rounded,
                  theme.colorScheme.primary,
                  isCode: true,
                  showLabel: chatSettings.showBlockTypeLabels,
                ),

                const SizedBox(height: 8),

                // 工具调用块
                _buildPreviewBlock(
                  context,
                  "工具调用",
                  "调用了搜索工具，返回了相关结果",
                  Icons.build_rounded,
                  theme.colorScheme.primary,
                  showLabel: chatSettings.showBlockTypeLabels,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建预览消息块
  Widget _buildPreviewBlock(
    BuildContext context,
    String label,
    String content,
    IconData icon,
    Color color, {
    bool isCode = false,
    bool showLabel = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCode
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            content,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface,
              fontFamily: isCode ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取消息容器装饰
  BoxDecoration _getMessageContainerDecoration(ThemeData theme, ChatBubbleStyle style) {
    switch (style) {
      case ChatBubbleStyle.list:
        return BoxDecoration(
          color: _getListStyleBackgroundColor(theme),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        );
      case ChatBubbleStyle.card:
        return BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ChatBubbleStyle.bubble:
        return BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        );
    }
  }

  /// 获取列表样式的背景色 - 智能主题适配
  Color _getListStyleBackgroundColor(ThemeData theme) {
    final brightness = theme.brightness;
    final colorScheme = theme.colorScheme;

    // 根据亮暗模式和主题特性智能选择背景色
    if (brightness == Brightness.light) {
      // 浅色模式：使用最浅的表面容器色，确保良好的对比度
      return colorScheme.surfaceContainerLowest;
    } else {
      // 深色模式：使用稍微亮一点的表面容器色，避免过于暗淡
      return colorScheme.surfaceContainerLow;
    }
  }
}
