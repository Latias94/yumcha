import 'package:flutter/material.dart';
import '../services/provider_repository.dart';
import '../services/favorite_model_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/ai_provider.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  final VoidCallback? onStopGeneration;
  final bool canStop;
  final Function(String providerId, String modelName)? onProviderChanged;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.onStopGeneration,
    this.canStop = false,
    this.onProviderChanged,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _isWebSearchEnabled = false;
  bool _showAttachmentPanel = false;
  String _selectedProvider = "gemini";
  String _selectedModel = "gemini-1.5-pro";
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

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
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
    _textController.addListener(() {
      setState(() {
        _isComposing = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) {
      print('❌ 文本为空，取消发送');
      return;
    }

    _textController.clear();

    setState(() {
      _isComposing = false;
    });

    widget.onSendMessage(text);
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
                          ).colorScheme.outline.withOpacity(0.3),
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
          color: Theme.of(context).colorScheme.primary,
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.smart_toy,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
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
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () async {
              // 直接更新收藏状态，无需重新打开sheet
              await _favoriteModelRepository.toggleFavoriteModel(
                providerId,
                modelName,
              );

              // 如果有setSheetState，则刷新sheet内容
              if (setSheetState != null) {
                setSheetState(() {});
              }
            },
          ),
          // 选择指示器
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
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
        if (widget.onProviderChanged != null) {
          widget.onProviderChanged!(providerId, modelName);
        }

        Navigator.pop(context);
        NotificationService().showSuccess('已切换到 $modelName');
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

  IconData _getProviderIcon(ProviderType providerType) {
    switch (providerType) {
      case ProviderType.openai:
        return Icons.chat;
      case ProviderType.google:
        return Icons.auto_awesome;
      case ProviderType.anthropic:
        return Icons.cloud;
      case ProviderType.ollama:
        return Icons.computer;
      case ProviderType.custom:
        return Icons.settings;
    }
  }

  void _stopGeneration() {
    if (widget.onStopGeneration != null && widget.canStop) {
      widget.onStopGeneration!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 输入框区域
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                  onSubmitted: (text) {
                    _handleSubmitted(text);
                  },
                  decoration: InputDecoration(
                    hintText: widget.isLoading
                        ? (widget.canStop ? 'AI正在思考中...' : '发送中...')
                        : '输入消息...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  // 添加按钮
                  Container(
                    decoration: BoxDecoration(
                      color: _showAttachmentPanel
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _showAttachmentPanel ? Icons.close : Icons.add,
                        color: _showAttachmentPanel
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
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
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isWebSearchEnabled
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isWebSearchEnabled
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.1),
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
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          if (_isWebSearchEnabled) ...[
                            const SizedBox(width: 4),
                            Text(
                              "网络搜索",
                              style: Theme.of(context).textTheme.bodySmall
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
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          final RenderBox button =
                              context.findRenderObject() as RenderBox;
                          final RenderBox overlay =
                              Overlay.of(context).context.findRenderObject()
                                  as RenderBox;
                          final Offset buttonPosition = button.localToGlobal(
                            Offset.zero,
                            ancestor: overlay,
                          );

                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              buttonPosition.dx,
                              buttonPosition.dy - 150,
                              buttonPosition.dx + button.size.width,
                              buttonPosition.dy,
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
                                onTap: () {},
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.refresh, size: 20),
                                    SizedBox(width: 12),
                                    Text("重新生成"),
                                  ],
                                ),
                                onTap: () {},
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.copy, size: 20),
                                    SizedBox(width: 12),
                                    Text("复制对话"),
                                  ],
                                ),
                                onTap: () {},
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 根据状态显示不同的按钮
                  if (widget.canStop && widget.isLoading) ...[
                    // 停止按钮
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _stopGeneration,
                        icon: Icon(
                          Icons.stop,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        tooltip: '停止生成',
                      ),
                    ),
                  ] else if (widget.isLoading) ...[
                    // 加载指示器
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 发送按钮
                    Container(
                      decoration: BoxDecoration(
                        color: _isComposing
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isComposing
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: _isComposing
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _isComposing
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                        tooltip: '发送消息',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 附件面板
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
}
