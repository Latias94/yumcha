import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const ChatInput({super.key, required this.onSendMessage});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _isWebSearchEnabled = false;
  bool _showAttachmentPanel = false;
  String _selectedProvider = "auto_awesome"; // 默认图标
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    widget.onSendMessage(text);
  }

  void _showProviderSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("选择提供商", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text("Gemini 2.5 Pro"),
              subtitle: const Text("Google AI"),
              onTap: () {
                setState(() {
                  _selectedProvider = "auto_awesome";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text("GPT-4o"),
              subtitle: const Text("OpenAI"),
              onTap: () {
                setState(() {
                  _selectedProvider = "chat";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text("Claude 3.5"),
              subtitle: const Text("Anthropic"),
              onTap: () {
                setState(() {
                  _selectedProvider = "cloud";
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用AnimatedBuilder包装输入区域，实现向上滑动动画
            _slideAnimation != null
                ? AnimatedBuilder(
                    animation: _slideAnimation!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -30 * _slideAnimation!.value),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 输入框区域
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              onChanged: (text) {
                                setState(() {
                                  _isComposing = text.isNotEmpty;
                                });
                              },
                              onSubmitted: _handleSubmitted,
                              decoration: const InputDecoration(
                                hintText: "输入消息与AI聊天",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),

                        // 功能按钮栏
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              // 添加按钮
                              IconButton(
                                icon: Icon(
                                  _showAttachmentPanel
                                      ? Icons.close
                                      : Icons.add,
                                  color: _showAttachmentPanel
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showAttachmentPanel =
                                        !_showAttachmentPanel;
                                  });

                                  if (_showAttachmentPanel) {
                                    _animationController?.forward();
                                  } else {
                                    _animationController?.reverse();
                                  }
                                },
                              ),

                              const SizedBox(width: 8),

                              // 提供商选择按钮（只显示图标）
                              InkWell(
                                onTap: _showProviderSelector,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    _getProviderIcon(_selectedProvider),
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 网络搜索按钮
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isWebSearchEnabled = !_isWebSearchEnabled;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isWebSearchEnabled
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.travel_explore,
                                        size: 16,
                                        color: _isWebSearchEnabled
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      ),
                                      if (_isWebSearchEnabled) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          "使用网络搜索",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 更多选项按钮
                              Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(Icons.more_horiz),
                                  onPressed: () {
                                    final RenderBox button =
                                        context.findRenderObject() as RenderBox;
                                    final RenderBox overlay =
                                        Overlay.of(
                                              context,
                                            ).context.findRenderObject()
                                            as RenderBox;
                                    final Offset buttonPosition = button
                                        .localToGlobal(
                                          Offset.zero,
                                          ancestor: overlay,
                                        );

                                    showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        buttonPosition.dx,
                                        buttonPosition.dy - 150, // 菜单显示在按钮上方
                                        buttonPosition.dx + button.size.width,
                                        buttonPosition.dy, // 菜单底部对齐按钮顶部
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.clear_all, size: 20),
                                              SizedBox(width: 12),
                                              Text("清空上下文"),
                                            ],
                                          ),
                                          onTap: () {
                                            // TODO: 实现清空上下文功能
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.refresh, size: 20),
                                              SizedBox(width: 12),
                                              Text("重新生成"),
                                            ],
                                          ),
                                          onTap: () {
                                            // TODO: 实现重新生成功能
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.copy, size: 20),
                                              SizedBox(width: 12),
                                              Text("复制对话"),
                                            ],
                                          ),
                                          onTap: () {
                                            // TODO: 实现复制对话功能
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              const Spacer(),

                              // 发送按钮
                              Container(
                                decoration: BoxDecoration(
                                  color: _isComposing
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isComposing
                                        ? Icons.send
                                        : Icons.keyboard_arrow_up,
                                    color: _isComposing
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                                  onPressed: _isComposing
                                      ? () => _handleSubmitted(
                                          _textController.text,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : // 如果动画还没初始化，显示静态版本
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 输入框区域
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            onChanged: (text) {
                              setState(() {
                                _isComposing = text.isNotEmpty;
                              });
                            },
                            onSubmitted: _handleSubmitted,
                            decoration: const InputDecoration(
                              hintText: "输入消息与AI聊天",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),

                      // 功能按钮栏
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // 添加按钮
                            IconButton(
                              icon: Icon(
                                _showAttachmentPanel ? Icons.close : Icons.add,
                                color: _showAttachmentPanel
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showAttachmentPanel = !_showAttachmentPanel;
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            // 提供商选择按钮（只显示图标）
                            InkWell(
                              onTap: _showProviderSelector,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  _getProviderIcon(_selectedProvider),
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 网络搜索按钮
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isWebSearchEnabled = !_isWebSearchEnabled;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _isWebSearchEnabled
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.travel_explore,
                                      size: 16,
                                      color: _isWebSearchEnabled
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    ),
                                    if (_isWebSearchEnabled) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        "使用网络搜索",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 更多选项按钮
                            Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {
                                  final RenderBox button =
                                      context.findRenderObject() as RenderBox;
                                  final RenderBox overlay =
                                      Overlay.of(
                                            context,
                                          ).context.findRenderObject()
                                          as RenderBox;
                                  final Offset buttonPosition = button
                                      .localToGlobal(
                                        Offset.zero,
                                        ancestor: overlay,
                                      );

                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      buttonPosition.dx,
                                      buttonPosition.dy - 150, // 菜单显示在按钮上方
                                      buttonPosition.dx + button.size.width,
                                      buttonPosition.dy, // 菜单底部对齐按钮顶部
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.clear_all, size: 20),
                                            SizedBox(width: 12),
                                            Text("清空上下文"),
                                          ],
                                        ),
                                        onTap: () {
                                          // TODO: 实现清空上下文功能
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.refresh, size: 20),
                                            SizedBox(width: 12),
                                            Text("重新生成"),
                                          ],
                                        ),
                                        onTap: () {
                                          // TODO: 实现重新生成功能
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.copy, size: 20),
                                            SizedBox(width: 12),
                                            Text("复制对话"),
                                          ],
                                        ),
                                        onTap: () {
                                          // TODO: 实现复制对话功能
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const Spacer(),

                            // 发送按钮
                            Container(
                              decoration: BoxDecoration(
                                color: _isComposing
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isComposing
                                      ? Icons.send
                                      : Icons.keyboard_arrow_up,
                                  color: _isComposing
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                onPressed: _isComposing
                                    ? () =>
                                          _handleSubmitted(_textController.text)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

            // 附件面板（使用AnimatedSize实现平滑展开收起）
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _showAttachmentPanel
                  ? _buildAttachmentPanel()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPanel() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAttachmentButton(
            icon: Icons.camera_alt,
            label: "拍照",
            onTap: () {
              setState(() {
                _showAttachmentPanel = false;
              });
              // TODO: 实现拍照功能
            },
          ),
          const SizedBox(width: 20),
          _buildAttachmentButton(
            icon: Icons.photo_library,
            label: "照片",
            onTap: () {
              setState(() {
                _showAttachmentPanel = false;
              });
              // TODO: 实现选择照片功能
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case "auto_awesome":
        return Icons.auto_awesome;
      case "chat":
        return Icons.chat;
      case "cloud":
        return Icons.cloud;
      default:
        return Icons.auto_awesome;
    }
  }
}
