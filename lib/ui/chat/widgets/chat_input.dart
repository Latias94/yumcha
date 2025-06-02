import 'package:flutter/material.dart';
import '../../../models/message.dart';
import '../../../services/provider_repository.dart';
import '../../../services/favorite_model_repository.dart';
import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';
import '../../../models/ai_provider.dart';

/// 聊天输入组件 - 增强版UI
class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    this.initialMessage,
    this.autofocus = false,
    this.onSendMessage,
    this.onCancelMessage,
    this.onCancelEdit,
    this.isLoading = false,
    this.onProviderModelChanged,
  });

  /// 初始消息（用于编辑）
  final Message? initialMessage;

  /// 是否自动聚焦
  final bool autofocus;

  /// 发送消息回调
  final void Function(String message)? onSendMessage;

  /// 取消消息回调
  final VoidCallback? onCancelMessage;

  /// 取消编辑回调
  final VoidCallback? onCancelEdit;

  /// 是否正在加载
  final bool isLoading;

  /// 提供商模型变化回调
  final void Function(String providerId, String modelName)?
  onProviderModelChanged;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showAttachmentPanel = false;
  bool _isComposing = false;
  bool _isWebSearchEnabled = false;

  String _selectedProvider = "gemini";
  String _selectedModel = "gemini-1.5-pro";

  late AnimationController _animationController;

  // 数据仓库
  late final ProviderRepository _providerRepository;
  late final FavoriteModelRepository _favoriteModelRepository;

  @override
  void initState() {
    super.initState();
    _providerRepository = ProviderRepository(DatabaseService.instance.database);
    _favoriteModelRepository = FavoriteModelRepository(
      DatabaseService.instance.database,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    // 如果有初始消息，设置文本内容
    if (widget.initialMessage != null) {
      _textController.text = widget.initialMessage!.content;
      _isComposing = _textController.text.trim().isNotEmpty;
    }
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当初始消息改变时更新文本内容
    if (widget.initialMessage != oldWidget.initialMessage) {
      if (widget.initialMessage != null) {
        _textController.text = widget.initialMessage!.content;
      } else {
        _textController.clear();
      }
      _isComposing = _textController.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    final newIsComposing = text.isNotEmpty;

    if (newIsComposing != _isComposing) {
      setState(() {
        _isComposing = newIsComposing;
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showAttachmentPanel = false;
      });
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.onSendMessage != null) {
      widget.onSendMessage!(text);
      if (widget.initialMessage == null) {
        // 只有在非编辑模式下才清空输入框
        _textController.clear();
        setState(() {
          _isComposing = false;
        });
      }
    }
  }

  bool _canSend() {
    return _textController.text.trim().isNotEmpty && !widget.isLoading;
  }

  void _showProviderSelector() async {
    try {
      // 获取所有提供商
      final providers = await _providerRepository.getAllProviders();
      final favoriteModels = await _favoriteModelRepository
          .getAllFavoriteModels();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 顶部拖拽指示器
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // 主要内容
                      Expanded(
                        child: FutureBuilder<List<FavoriteModel>>(
                          future: _favoriteModelRepository
                              .getAllFavoriteModels(),
                          builder: (context, snapshot) {
                            final currentFavorites =
                                snapshot.data ?? favoriteModels;
                            return ListView(
                              controller: scrollController,
                              children: [
                                ..._buildProviderSections(
                                  providers,
                                  currentFavorites,
                                  setSheetState,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        NotificationService().showError('加载模型失败: $e');
      }
    }
  }

  List<Widget> _buildProviderSections(
    List<AiProvider> providers,
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    final List<Widget> sections = [];

    // 收藏部分
    if (favoriteModels.isNotEmpty) {
      sections.add(_buildSectionHeader("收藏夹"));
      sections.addAll(_buildFavoriteModels(favoriteModels, setSheetState));
      sections.add(const SizedBox(height: 16));
    }

    // 按提供商分组
    for (final provider in providers.where((p) => p.isEnabled)) {
      final models = provider.models.isNotEmpty
          ? provider.models.map((model) => model.name).toList()
          : AiProvider.getDefaultModels(provider.type);

      if (models.isNotEmpty) {
        sections.add(_buildSectionHeader(provider.name));
        sections.addAll(
          _buildProviderModels(provider, models, favoriteModels, setSheetState),
        );
        sections.add(const SizedBox(height: 16));
      }
    }

    return sections;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildFavoriteModels(
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    return favoriteModels.map((favoriteModel) {
      return _buildModelTile(
        favoriteModel.providerId,
        favoriteModel.modelName,
        isFavorite: true,
        setSheetState: setSheetState,
      );
    }).toList();
  }

  List<Widget> _buildProviderModels(
    AiProvider provider,
    List<String> models,
    List<FavoriteModel> favoriteModels,
    StateSetter setSheetState,
  ) {
    return models.map((modelName) {
      final isFavorite = favoriteModels.any(
        (fav) => fav.providerId == provider.id && fav.modelName == modelName,
      );
      return _buildModelTile(
        provider.id,
        modelName,
        isFavorite: isFavorite,
        setSheetState: setSheetState,
      );
    }).toList();
  }

  Widget _buildModelTile(
    String providerId,
    String modelName, {
    bool isFavorite = false,
    StateSetter? setSheetState,
  }) {
    final isSelected =
        _selectedProvider == providerId && _selectedModel == modelName;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.8),
        child: Icon(
          Icons.smart_toy,
          color: Theme.of(
            context,
          ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
      title: Text(
        modelName,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _getModelDescription(modelName),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 收藏按钮
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: () async {
              await _favoriteModelRepository.toggleFavoriteModel(
                providerId,
                modelName,
              );

              if (setSheetState != null) {
                setSheetState(() {});
              }
            },
          ),
          // 选择指示器
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
              size: 20,
            ),
        ],
      ),
      onTap: () {
        setState(() {
          _selectedProvider = providerId;
          _selectedModel = modelName;
        });

        // 通知父组件配置已改变
        widget.onProviderModelChanged?.call(providerId, modelName);

        Navigator.pop(context);
      },
    );
  }

  String _getModelDescription(String modelName) {
    if (modelName.contains('gpt-4o')) return 'OpenAI最先进的多模态模型';
    if (modelName.contains('gpt-4')) return 'OpenAI强大的推理模型';
    if (modelName.contains('gpt-3.5')) return 'OpenAI快速高效模型';
    if (modelName.contains('claude-3.5')) return 'Anthropic最新一代模型';
    if (modelName.contains('claude-3')) return 'Anthropic高性能模型';
    if (modelName.contains('gemini-1.5-pro')) return 'Google最强大的AI模型';
    if (modelName.contains('gemini-1.5-flash')) return 'Google快速响应模型';
    if (modelName.contains('llama')) return 'Meta开源大语言模型';
    return '高质量AI模型';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialMessage != null;

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 编辑指示器
            if (isEditing) _buildEditingIndicator(context, theme),

            // 输入框区域
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                  onSubmitted: _canSend() ? (_) => _handleSend() : null,
                  decoration: InputDecoration(
                    hintText: widget.isLoading
                        ? 'AI正在思考中...'
                        : (isEditing ? '编辑消息...' : '输入消息...'),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
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
                  // 添加按钮（仅在非编辑模式显示）
                  if (!isEditing) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: _showAttachmentPanel
                            ? theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.8,
                              )
                            : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _showAttachmentPanel ? Icons.close : Icons.add,
                          color: _showAttachmentPanel
                              ? theme.colorScheme.onPrimaryContainer.withValues(
                                  alpha: 0.6,
                                )
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showAttachmentPanel = !_showAttachmentPanel;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 提供商选择按钮
                    InkWell(
                      onTap: _showProviderSelector,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.1,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.6,
                          ),
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
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isWebSearchEnabled
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.8,
                                )
                              : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isWebSearchEnabled
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  )
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.1,
                                  ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.travel_explore,
                              size: 16,
                              color: _isWebSearchEnabled
                                  ? theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                            ),
                            if (_isWebSearchEnabled) ...[
                              const SizedBox(width: 4),
                              Text(
                                "网络搜索",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // 编辑模式下的取消按钮
                  if (isEditing && widget.onCancelEdit != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        onPressed: widget.onCancelEdit,
                        tooltip: '取消编辑',
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Spacer(),

                  // 根据状态显示不同的按钮
                  if (widget.isLoading) ...[
                    // 停止按钮
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(
                          alpha: 0.8,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: widget.onCancelMessage,
                        icon: Icon(
                          Icons.stop,
                          color: theme.colorScheme.onErrorContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        tooltip: '停止生成',
                      ),
                    ),
                  ] else ...[
                    // 发送按钮
                    Container(
                      decoration: BoxDecoration(
                        color: _canSend()
                            ? theme.colorScheme.primary.withValues(alpha: 0.8)
                            : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _canSend()
                              ? theme.colorScheme.primary.withValues(alpha: 0.3)
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                          width: 1,
                        ),
                        boxShadow: _canSend()
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isEditing ? Icons.check : Icons.send,
                          color: _canSend()
                              ? theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.6,
                                )
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                        onPressed: _canSend() ? _handleSend : null,
                        tooltip: isEditing ? '确认编辑' : '发送消息',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 附件面板（仅在非编辑模式显示）
            if (!isEditing)
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

  Widget _buildEditingIndicator(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '正在编辑消息',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPanel() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
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
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
