// 🎨 聊天样式设置屏幕
//
// 用于配置聊天消息的显示样式，提供不同的消息展示方式选择。
// 用户可以根据个人偏好选择最适合的聊天界面样式。
//
// 🎯 **主要功能**:
// - 🎨 **样式选择**: 在气泡样式和列表样式之间切换
// - 👀 **实时预览**: 提供样式效果的实时预览
// - 💾 **偏好保存**: 自动保存用户的样式偏好设置
// - 📱 **响应式设计**: 适配不同屏幕尺寸的显示效果
// - ✅ **即时反馈**: 切换样式时提供操作成功提示
//
// 🎨 **支持的样式**:
// - **气泡样式**: 传统聊天气泡，有背景色和圆角，类似微信、QQ
// - **列表样式**: 无背景色，占满宽度，适合长文本阅读
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
import '../../../../shared/infrastructure/services/notification_service.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  Future<void> _saveStyle(WidgetRef ref, ChatBubbleStyle style) async {
    try {
      await ref.read(chatStyleProvider.notifier).updateStyle(style);
      NotificationService().showSuccess('已切换到${style.displayName}样式');
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
                _buildSectionHeader(context, "消息显示样式"),
                _buildStyleOption(context, ref, ChatBubbleStyle.list),
                _buildStyleOption(context, ref, ChatBubbleStyle.card),
                _buildStyleOption(context, ref, ChatBubbleStyle.bubble),
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
          Text(
            "预览效果",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 用户消息预览
          _buildPreviewMessage(context, ref, "这是一条用户消息的预览效果", isFromUser: true),

          const SizedBox(height: 8),

          // AI消息预览
          _buildPreviewMessage(
            context,
            ref,
            "这是一条AI回复消息的预览效果，可能会比较长一些，用来展示不同样式下的显示效果。",
            isFromUser: false,
          ),
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
        // 列表样式预览
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFromUser ? "用户" : "AI助手",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
    }
  }
}
