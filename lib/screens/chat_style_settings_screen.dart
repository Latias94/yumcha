import 'package:flutter/material.dart';
import '../models/chat_bubble_style.dart';
import '../services/preference_service.dart';
import '../services/notification_service.dart';

/// 显示设置页面
class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  late final PreferenceService _preferenceService;
  ChatBubbleStyle _currentStyle = ChatBubbleStyle.list;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preferenceService = PreferenceService();
    _loadCurrentStyle();
  }

  Future<void> _loadCurrentStyle() async {
    try {
      final styleValue = await _preferenceService.getChatBubbleStyle();
      setState(() {
        _currentStyle = ChatBubbleStyle.fromValue(styleValue);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveStyle(ChatBubbleStyle style) async {
    try {
      await _preferenceService.saveChatBubbleStyle(style.value);
      setState(() {
        _currentStyle = style;
      });

      if (mounted) {
        NotificationService().showSuccess('已切换到${style.displayName}样式');
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('保存设置失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _buildSectionHeader("消息显示样式"),
                _buildStyleOption(ChatBubbleStyle.list),
                _buildStyleOption(ChatBubbleStyle.bubble),

                const SizedBox(height: 24),

                _buildSectionHeader("样式预览"),
                _buildPreviewSection(),

                const SizedBox(height: 32),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildStyleOption(ChatBubbleStyle style) {
    final isSelected = _currentStyle == style;

    String subtitle;
    switch (style) {
      case ChatBubbleStyle.bubble:
        subtitle = "传统聊天气泡样式，有背景色和圆角";
        break;
      case ChatBubbleStyle.list:
        subtitle = "列表样式，无背景色，适合长文本阅读";
        break;
    }

    return RadioListTile<ChatBubbleStyle>(
      title: Text(style.displayName),
      subtitle: Text(subtitle),
      value: style,
      groupValue: _currentStyle,
      onChanged: (value) {
        if (value != null) {
          _saveStyle(value);
        }
      },
      secondary: Icon(
        style == ChatBubbleStyle.bubble
            ? Icons.chat_bubble_outline
            : Icons.list,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPreviewSection() {
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
          _buildPreviewMessage("这是一条用户消息的预览效果", isFromUser: true),

          const SizedBox(height: 8),

          // AI消息预览
          _buildPreviewMessage(
            "这是一条AI回复消息的预览效果，可能会比较长一些，用来展示不同样式下的显示效果。",
            isFromUser: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewMessage(String content, {required bool isFromUser}) {
    final theme = Theme.of(context);

    if (_currentStyle == ChatBubbleStyle.bubble) {
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
    } else {
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
