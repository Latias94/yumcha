import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../design_system/design_constants.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../providers/providers.dart';
import '../../../features/chat/data/repositories/conversation_repository.dart';
import '../../infrastructure/services/database_service.dart';
import '../../infrastructure/services/notification_service.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import 'package:yumcha/features/search/presentation/screens/chat_search_screen.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final String selectedMenu;
  final Function(String) onChatClicked;
  final Function(String) onProfileClicked;

  const AppDrawer({
    super.key,
    required this.selectedMenu,
    required this.onChatClicked,
    required this.onProfileClicked,
  });

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _assistantSearchController =
      TextEditingController();
  late final ConversationRepository _conversationRepository;
  final LoggerService _logger = LoggerService();

  String _selectedAssistant = "ai";
  String _searchQuery = "";
  String _assistantSearchQuery = "";
  bool _isAssistantDropdownExpanded = false;

  // 搜索防抖Timer
  Timer? _searchDebounce;

  // 用于控制清除按钮显示的ValueNotifier
  final ValueNotifier<bool> _showClearButton = ValueNotifier<bool>(false);

  // 用于控制搜索状态显示的ValueNotifier
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>("");

  // 用于控制搜索加载状态的ValueNotifier
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);

  // 使用 infinite_scroll_pagination 5.0.0 正确的 API
  static const int _pageSize = 20;
  late final PagingController<int, ConversationUiState> _pagingController;

  @override
  void initState() {
    super.initState();
    _conversationRepository = ConversationRepository(
      DatabaseService.instance.database,
    );

    // 初始化分页控制器 - 使用 5.0.0 正确的 API
    _pagingController = PagingController<int, ConversationUiState>(
      getNextPageKey: (state) {
        if (state.pages?.isNotEmpty == true) {
          final lastPage = state.pages!.last;
          if (lastPage.isEmpty || lastPage.length < _pageSize) {
            return null; // 没有更多数据
          }
          return (state.keys?.last ?? 0) + _pageSize;
        }
        return 0; // 第一页
      },
      fetchPage: (pageKey) => _fetchPage(pageKey),
    );

    // 监听助手状态变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedAssistant();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _assistantSearchController.dispose();
    _pagingController.dispose();
    _searchDebounce?.cancel();
    _showClearButton.dispose();
    _searchQueryNotifier.dispose();
    _isSearching.dispose();
    super.dispose();
  }

  // 初始化选中的助手
  void _initializeSelectedAssistant() {
    final assistantsAsync = ref.read(enabledAiAssistantsProvider);
    if (assistantsAsync.isNotEmpty) {
      // 如果当前选择的是默认值或无效值，选择第一个可用助手
      if (_selectedAssistant == "ai" || _selectedAssistant.isEmpty) {
        setState(() {
          _selectedAssistant = assistantsAsync.first.id;
        });
        _refreshConversations();
      } else {
        // 验证当前选择的助手是否仍然有效
        final isValidAssistant = assistantsAsync.any(
          (a) => a.id == _selectedAssistant,
        );
        if (!isValidAssistant) {
          setState(() {
            _selectedAssistant = assistantsAsync.first.id;
          });
          _refreshConversations();
        }
      }
    }
  }

  // 获取分页数据 - 返回 Future<List<ConversationUiState>>
  Future<List<ConversationUiState>> _fetchPage(int pageKey) async {
    _logger.debug(
      '开始获取分页数据: pageKey=$pageKey, searchQuery="$_searchQuery", assistant=$_selectedAssistant',
    );

    // 确保有有效的助手选择
    if (_selectedAssistant == "ai" || _selectedAssistant.isEmpty) {
      // 尝试重新初始化助手选择
      final assistantsAsync = ref.read(enabledAiAssistantsProvider);
      if (assistantsAsync.isNotEmpty) {
        _selectedAssistant = assistantsAsync.first.id;
        _logger.debug('重新初始化助手选择: $_selectedAssistant');
      } else {
        _logger.warning('没有可用助手');
        return []; // 没有可用助手时返回空列表
      }
    }

    try {
      List<ConversationUiState> results;

      // 如果有搜索查询，使用综合搜索方法
      if (_searchQuery.trim().isNotEmpty) {
        _logger.debug(
          '执行综合搜索: query="$_searchQuery", assistantId=$_selectedAssistant',
        );
        results = await _performComprehensiveSearch(
          _searchQuery,
          _selectedAssistant,
          limit: _pageSize,
          offset: pageKey,
        );
        _logger.debug('搜索结果数量: ${results.length}');
      } else {
        // 否则使用正常的分页获取
        _logger.debug('获取正常对话列表: assistantId=$_selectedAssistant');
        results = await _conversationRepository
            .getConversationsByAssistantWithPagination(
          _selectedAssistant,
          limit: _pageSize,
          offset: pageKey,
          includeMessages: true, // 需要消息来获取时间戳
        );
        _logger.debug('对话列表数量: ${results.length}');
      }

      return results;
    } catch (e, stackTrace) {
      _logger.error('获取对话列表失败', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'pageKey': pageKey,
        'searchQuery': _searchQuery,
        'selectedAssistant': _selectedAssistant,
      });
      return []; // 出错时返回空列表而不是抛出异常
    }
  }

  // 删除对话
  Future<void> _deleteConversation(String conversationId) async {
    try {
      // 检查删除的对话是否是当前正在显示的对话
      final currentConversationState = ref.read(currentConversationProvider);
      final isCurrentConversation =
          currentConversationState.conversation?.id == conversationId;

      _logger.info('删除对话: $conversationId, 是否为当前对话: $isCurrentConversation');

      await _conversationRepository.deleteConversation(conversationId);

      // 如果删除的是当前对话，创建新对话
      if (isCurrentConversation) {
        _logger.info('删除的是当前对话，创建新对话');
        final conversationNotifier = ref.read(
          currentConversationProvider.notifier,
        );
        await conversationNotifier.createNewConversation();
      }

      // 刷新分页列表
      _pagingController.refresh();
      if (mounted) {
        NotificationService().showSuccess('对话已删除');
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('删除失败: $e');
      }
    }
  }

  // 重新生成标题
  Future<void> _regenerateTitle(ConversationUiState conversation) async {
    try {
      _logger.info('开始重新生成标题', {
        'conversationId': conversation.id,
        'currentTitle': conversation.channelName,
      });

      // 检查是否有足够的消息
      if (conversation.messages.length < 2) {
        NotificationService().showWarning('消息数量不足，无法生成标题');
        return;
      }

      // 显示加载提示
      NotificationService().showInfo('正在重新生成标题...');

      // 通过 Riverpod 调用重新生成标题
      final conversationNotifier = ref.read(
        currentConversationProvider.notifier,
      );
      await conversationNotifier.regenerateTitle(conversation.id);

      NotificationService().showSuccess('标题重新生成成功');
    } catch (e) {
      _logger.error('重新生成标题失败', {
        'conversationId': conversation.id,
        'error': e.toString(),
      });
      NotificationService().showError('重新生成标题失败: $e');
    }
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(ConversationUiState conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除对话'),
        content: Text('确定要删除对话 "${conversation.channelName}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteConversation(conversation.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 刷新对话列表
  void _refreshConversations() {
    _pagingController.refresh();
  }

  // 带动画的刷新对话列表
  void _refreshConversationsWithAnimation() {
    // 延迟一小段时间以确保搜索状态更新
    Future.delayed(const Duration(milliseconds: 50), () {
      _isSearching.value = false;
      _pagingController.refresh();
    });
  }

  // 性能优化：防抖搜索
  void _onSearchChanged(String value) {
    // 取消之前的防抖Timer
    _searchDebounce?.cancel();

    // 更新内部搜索查询状态（不触发UI重建）
    _searchQuery = value;

    // 更新UI状态通知器
    _showClearButton.value = value.isNotEmpty;
    _searchQueryNotifier.value = value;

    // 如果搜索查询为空，立即刷新
    if (value.trim().isEmpty) {
      _isSearching.value = false;
      _refreshConversations();
      return;
    }

    // 显示搜索状态
    _isSearching.value = true;

    // 设置防抖Timer，300ms后执行搜索（减少延迟）
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _logger.debug('执行搜索: $_searchQuery');
      _refreshConversationsWithAnimation();
    });
  }

  // 执行综合搜索（搜索对话标题和消息内容）
  Future<List<ConversationUiState>> _performComprehensiveSearch(
    String query,
    String assistantId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    try {
      // 1. 搜索对话标题
      final conversationResults = await _conversationRepository
          .searchConversationsByTitle(
        trimmedQuery,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );

      // 2. 搜索消息内容
      final messageResults = await _conversationRepository.searchMessages(
        trimmedQuery,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );

      // 3. 合并结果，去重（优先显示标题匹配的对话）
      final Map<String, ConversationUiState> uniqueConversations = {};

      // 先添加标题匹配的对话
      for (final conversation in conversationResults) {
        uniqueConversations[conversation.id] = conversation;
      }

      // 再添加消息匹配的对话（如果不存在的话）
      for (final messageResult in messageResults) {
        final conversationId = messageResult.conversationId;
        if (!uniqueConversations.containsKey(conversationId)) {
          // 获取完整的对话信息
          final conversation = await _conversationRepository
              .getConversation(conversationId);
          if (conversation != null) {
            uniqueConversations[conversationId] = conversation;
          }
        }
      }

      // 4. 按最后消息时间排序
      final sortedResults = uniqueConversations.values.toList();
      sortedResults.sort((a, b) {
        final aTime = a.messages.isNotEmpty
            ? a.messages.last.timestamp
            : DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.messages.isNotEmpty
            ? b.messages.last.timestamp
            : DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // 降序排列
      });

      _logger.debug(
        '综合搜索完成: 标题匹配=${conversationResults.length}, 消息匹配=${messageResults.length}, 去重后=${sortedResults.length}',
      );

      return sortedResults;
    } catch (e, stackTrace) {
      _logger.error('综合搜索失败', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'query': trimmedQuery,
        'assistantId': assistantId,
      });
      return [];
    }
  }

  // 获取日期分组标题
  String _getDateGroupTitle(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '本周';
    } else if (difference < 30) {
      return '本月';
    } else {
      return '更早';
    }
  }

  // 获取分组图标
  IconData _getGroupIcon(String groupKey) {
    switch (groupKey) {
      case '今天':
        return Icons.today;
      case '昨天':
        return Icons.schedule;
      case '本周':
        return Icons.date_range;
      case '本月':
        return Icons.calendar_month;
      case '更早':
        return Icons.history;
      default:
        return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // 监听对话列表刷新通知
        ref.listen<int>(conversationListRefreshProvider, (previous, next) {
          // 当刷新通知发生变化时，刷新对话列表
          if (mounted && previous != next) {
            _logger.debug('收到对话列表刷新通知，刷新分页控制器');
            _refreshConversations();
          }
        });

        final theme = Theme.of(context);
        final deviceType = DesignConstants.getDeviceType(context);

        return Drawer(
          width: deviceType == DeviceType.desktop
              ? 320
              : deviceType == DeviceType.tablet
                  ? 300
                  : null, // 使用默认宽度
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: DesignConstants.shadowL(theme),
            ),
            child: Column(
              children: [
                // 搜索框
                _buildSearchHeader(),

                // 聊天记录列表
                Expanded(child: _buildChatHistoryList()),

                // 助手选择下拉框
                _buildAssistantSelector(),

                // 底部按钮
                _buildBottomButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader() {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignConstants.spaceL,
        DesignConstants.spaceL,
        DesignConstants.spaceL,
        DesignConstants.spaceS,
      ),
      child: Column(
        children: [
          // 顶部空间，避免与状态栏重叠
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 搜索框
          ValueListenableBuilder<bool>(
            valueListenable: _showClearButton,
            builder: (context, showClear, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: DesignConstants.radiusXXL,
                  boxShadow: DesignConstants.shadowS(theme),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: deviceType == DeviceType.desktop
                        ? "搜索对话标题和内容..."
                        : "搜索对话...",
                    hintStyle: TextStyle(
                      fontSize: DesignConstants.getResponsiveFontSize(
                        context,
                        mobile: 14.0,
                        tablet: 15.0,
                        desktop: 16.0,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: deviceType == DeviceType.mobile
                          ? DesignConstants.iconSizeM
                          : DesignConstants.iconSizeL,
                    ),
                    suffixIcon: AnimatedSwitcher(
                      duration: DesignConstants.animationFast,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child:
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: showClear
                          ? IconButton(
                              key: const ValueKey('clear_button'),
                              icon: const Icon(Icons.clear),
                              iconSize: deviceType == DeviceType.mobile
                                  ? DesignConstants.iconSizeM
                                  : DesignConstants.iconSizeL,
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged("");
                              },
                              tooltip: '清除搜索',
                            )
                          : const SizedBox.shrink(key: ValueKey('empty_space')),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: DesignConstants.radiusXXL,
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: deviceType == DeviceType.mobile
                          ? DesignConstants.spaceM
                          : DesignConstants.spaceL,
                      horizontal: DesignConstants.spaceS,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: DesignConstants.getResponsiveFontSize(context),
                  ),
                  onChanged: _onSearchChanged,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshConversations();
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isSearching,
        builder: (context, isSearching, child) {
          return Stack(
            children: [
              PagingListener<int, ConversationUiState>(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) {
                  return _buildGroupedPagedListView(state, fetchNextPage);
                },
              ),
              // 搜索加载指示器
              if (isSearching)
                Positioned(
                  top: DesignConstants.spaceS,
                  left: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: DesignConstants.animationFast,
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: DesignConstants.curveStandard,
                        )),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Center(
                      key: const ValueKey('search_indicator'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignConstants.spaceL,
                          vertical: DesignConstants.spaceS,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: DesignConstants.radiusXL,
                          boxShadow:
                              DesignConstants.shadowM(Theme.of(context)),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                            width: DesignConstants.borderWidthThin,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: DesignConstants.iconSizeS,
                              height: DesignConstants.iconSizeS,
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    DesignConstants.borderWidthMedium,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: DesignConstants.spaceS),
                            Text(
                              '搜索中...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontSize: DesignConstants
                                        .getResponsiveFontSize(
                                      context,
                                      mobile: 12.0,
                                      tablet: 13.0,
                                      desktop: 14.0,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupedPagedListView(
    PagingState<int, ConversationUiState> state,
    VoidCallback fetchNextPage,
  ) {
    // 将所有对话按日期分组
    final allItems = state.pages?.expand((page) => page).toList() ?? [];
    final groups = _groupConversationsByDate(allItems);

    return PagedListView<int, ConversationUiState>.separated(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate<ConversationUiState>(
        itemBuilder: (context, conversation, globalIndex) {
          final conversationWidget = _buildConversationItemWithGroup(
            conversation,
            globalIndex,
            allItems,
            groups,
          );

          // 只在搜索时显示动画
          if (_searchQuery.trim().isNotEmpty) {
            return AnimationConfiguration.staggeredList(
              position: globalIndex,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: conversationWidget),
              ),
            );
          } else {
            // 正常加载时不显示动画
            return conversationWidget;
          }
        },
        firstPageErrorIndicatorBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              SizedBox(height: DesignConstants.spaceL),
              const Text('加载失败'),
              SizedBox(height: DesignConstants.spaceS),
              ElevatedButton(
                onPressed: () => _pagingController.refresh(),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        firstPageProgressIndicatorBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (context) => Padding(
          padding: DesignConstants.paddingL,
          child: const Center(child: CircularProgressIndicator()),
        ),
        noItemsFoundIndicatorBuilder: (context) =>
            ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchQuery, child) {
            final isEmpty = searchQuery.trim().isEmpty;
            final theme = Theme.of(context);
            final deviceType = DesignConstants.getDeviceType(context);

            return Center(
              child: Padding(
                padding: EdgeInsets.all(DesignConstants.spaceXXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 动画图标容器
                    TweenAnimationBuilder<double>(
                      duration: DesignConstants.animationSlow,
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: DesignConstants.curveEmphasized,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Container(
                            width: deviceType == DeviceType.mobile ? 80 : 100,
                            height: deviceType == DeviceType.mobile ? 80 : 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isEmpty
                                    ? [
                                        theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.8),
                                        theme.colorScheme.secondaryContainer
                                            .withValues(alpha: 0.6),
                                      ]
                                    : [
                                        theme.colorScheme.errorContainer
                                            .withValues(alpha: 0.8),
                                        theme.colorScheme.onErrorContainer
                                            .withValues(alpha: 0.1),
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: DesignConstants.shadowM(theme),
                            ),
                            child: Icon(
                              isEmpty ? Icons.chat : Icons.search_off,
                              size: deviceType == DeviceType.mobile ? 40 : 48,
                              color: isEmpty
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: DesignConstants.spaceXXL),

                    // 主标题
                    Text(
                      isEmpty ? "无聊天记录" : "未找到相关对话",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: DesignConstants.getResponsiveFontSize(
                          context,
                          mobile: 18.0,
                          tablet: 20.0,
                          desktop: 22.0,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (!isEmpty) ...[
                      SizedBox(height: DesignConstants.spaceM),

                      // 搜索无结果的副标题
                      Text(
                        "未找到包含 \"$searchQuery\" 的对话\n尝试使用不同的关键词",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: DesignConstants.getResponsiveFontSize(
                            context,
                            mobile: 14.0,
                            tablet: 15.0,
                            desktop: 16.0,
                          ),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      separatorBuilder: (context, index) =>
          SizedBox(height: DesignConstants.spaceXS),
    );
  }

  // 按日期分组对话
  Map<String, List<ConversationUiState>> _groupConversationsByDate(
    List<ConversationUiState> conversations,
  ) {
    final groups = <String, List<ConversationUiState>>{};

    for (final conversation in conversations) {
      final timestamp = conversation.messages.isNotEmpty
          ? conversation.messages.first.timestamp
          : DateTime.now();

      final groupKey = _getDateGroupTitle(timestamp);
      groups.putIfAbsent(groupKey, () => []).add(conversation);
    }

    return groups;
  }

  Widget _buildConversationItemWithGroup(
    ConversationUiState conversation,
    int globalIndex,
    List<ConversationUiState> allItems,
    Map<String, List<ConversationUiState>> groups,
  ) {
    final timestamp = conversation.messages.isNotEmpty
        ? conversation.messages.first.timestamp
        : DateTime.now();
    final groupKey = _getDateGroupTitle(timestamp);

    // 检查是否是组内的第一个项目
    bool isFirstInGroup = false;
    if (globalIndex == 0) {
      isFirstInGroup = true;
    } else {
      final prevConversation = allItems[globalIndex - 1];
      final prevTimestamp = prevConversation.messages.isNotEmpty
          ? prevConversation.messages.first.timestamp
          : DateTime.now();
      final prevGroupKey = _getDateGroupTitle(prevTimestamp);
      isFirstInGroup = groupKey != prevGroupKey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 如果是组内第一个项目，显示组标题
        if (isFirstInGroup)
          Container(
            margin: EdgeInsets.fromLTRB(
              DesignConstants.spaceL,
              DesignConstants.spaceL,
              DesignConstants.spaceL,
              DesignConstants.spaceS,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceM,
              vertical: DesignConstants.spaceXS,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: DesignConstants.radiusS,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                width: DesignConstants.borderWidthThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getGroupIcon(groupKey),
                  size: DesignConstants.iconSizeS,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceXS),
                Text(
                  groupKey,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: DesignConstants.getResponsiveFontSize(
                          context,
                          mobile: 12.0,
                          tablet: 13.0,
                          desktop: 14.0,
                        ),
                      ),
                ),
              ],
            ),
          ),
        // 聊天项目
        _buildChatHistoryItem(conversation),
      ],
    );
  }

  Widget _buildChatHistoryItem(ConversationUiState conversation) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceS,
        vertical: DesignConstants.spaceXS / 2,
      ),
      child: Material(
        borderRadius: DesignConstants.radiusM,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: DesignConstants.radiusM,
          onTap: () {
            // 打开特定的聊天记录
            _logger.debug(
              '点击对话: ${conversation.id}, 标题: ${conversation.channelName}',
            );
            widget.onChatClicked(conversation.id);
          },
          child: AnimatedContainer(
            duration: DesignConstants.animationFast,
            curve: DesignConstants.curveStandard,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceL,
              vertical:
                  isDesktop ? DesignConstants.spaceM : DesignConstants.spaceS,
            ),
            decoration: BoxDecoration(
              borderRadius: DesignConstants.radiusM,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: DesignConstants.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                // 对话图标（桌面端显示）
                if (isDesktop) ...[
                  Container(
                    width: DesignConstants.iconSizeL,
                    height: DesignConstants.iconSizeL,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: DesignConstants.radiusS,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: DesignConstants.iconSizeM,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceM),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.channelName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: DesignConstants.getResponsiveFontSize(
                            context,
                            mobile: 14.0,
                            tablet: 15.0,
                            desktop: 16.0,
                          ),
                        ),
                        maxLines: isDesktop ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 桌面端显示最后消息时间
                      if (isDesktop && conversation.messages.isNotEmpty) ...[
                        SizedBox(height: DesignConstants.spaceXS),
                        Text(
                          _getRelativeTime(
                              conversation.messages.first.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 消息数量指示器
                if (conversation.messages.isNotEmpty) ...[
                  Container(
                    margin: EdgeInsets.only(left: DesignConstants.spaceS),
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignConstants.spaceS,
                      vertical: DesignConstants.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.6),
                      borderRadius: DesignConstants.radiusS,
                    ),
                    child: Text(
                      conversation.messages.length.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: DesignConstants.getResponsiveFontSize(
                          context,
                          mobile: 10.0,
                          tablet: 11.0,
                          desktop: 12.0,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceXS),
                ],

                // 更多选项按钮
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: deviceType == DeviceType.mobile
                        ? DesignConstants.iconSizeM
                        : DesignConstants.iconSizeL,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: '更多选项',
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'regenerate_title',
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: DesignConstants.iconSizeM,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: DesignConstants.spaceM),
                          const Text('重新生成标题'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                            size: DesignConstants.iconSizeM,
                          ),
                          SizedBox(width: DesignConstants.spaceM),
                          const Text('删除对话'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'regenerate_title') {
                      _regenerateTitle(conversation);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(conversation);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 获取相对时间显示
  String _getRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  Widget _buildAssistantSelector() {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    return Consumer(
      builder: (context, ref, _) {
        final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
        final selectedAssistant = ref.watch(
          aiAssistantProvider(_selectedAssistant),
        );

        return assistantsAsync.when(
          data: (assistants) => Container(
            margin: EdgeInsets.all(DesignConstants.spaceL),
            decoration: BoxDecoration(
              borderRadius: DesignConstants.radiusL,
              boxShadow: DesignConstants.shadowS(theme),
            ),
            child: Material(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: DesignConstants.radiusL,
              child: InkWell(
                borderRadius: DesignConstants.radiusL,
                onTap: () {
                  setState(() {
                    _isAssistantDropdownExpanded =
                        !_isAssistantDropdownExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: DesignConstants.animationNormal,
                  curve: DesignConstants.curveStandard,
                  padding: EdgeInsets.all(
                    deviceType == DeviceType.mobile
                        ? DesignConstants.spaceL
                        : DesignConstants.spaceXL,
                  ),
                  child: Column(
                    children: [
                      // 当前选中的助手
                      Row(
                        children: [
                          // 助手头像
                          Container(
                            width: deviceType == DeviceType.mobile ? 40 : 48,
                            height: deviceType == DeviceType.mobile ? 40 : 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: DesignConstants.radiusM,
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                width: DesignConstants.borderWidthThin,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                selectedAssistant?.avatar ?? '🤖',
                                style: TextStyle(
                                  fontSize:
                                      deviceType == DeviceType.mobile ? 20 : 24,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: DesignConstants.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAssistant?.name ?? 'AI助手',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        DesignConstants.getResponsiveFontSize(
                                      context,
                                      mobile: 15.0,
                                      tablet: 16.0,
                                      desktop: 17.0,
                                    ),
                                  ),
                                ),
                                if (selectedAssistant != null) ...[
                                  SizedBox(height: DesignConstants.spaceXS),
                                  Text(
                                    selectedAssistant.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize:
                                          DesignConstants.getResponsiveFontSize(
                                        context,
                                        mobile: 12.0,
                                        tablet: 13.0,
                                        desktop: 14.0,
                                      ),
                                    ),
                                    maxLines: deviceType == DeviceType.desktop
                                        ? 2
                                        : 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isAssistantDropdownExpanded ? 0.5 : 0,
                            duration: DesignConstants.animationFast,
                            curve: DesignConstants.curveStandard,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: deviceType == DeviceType.mobile
                                  ? DesignConstants.iconSizeM
                                  : DesignConstants.iconSizeL,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      // 展开的助手列表
                      if (_isAssistantDropdownExpanded) ...[
                        SizedBox(height: DesignConstants.spaceM),
                        const Divider(height: 1),
                        SizedBox(height: DesignConstants.spaceS),

                        // 助手列表
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                assistants.length > 10 ? 200 : double.infinity,
                          ),
                          child: assistants.isEmpty
                              ? Padding(
                                  padding: DesignConstants.paddingL,
                                  child: Text(
                                    _assistantSearchQuery.isNotEmpty
                                        ? '未找到匹配的助手'
                                        : '暂无可用助手',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: assistants.length,
                                  itemBuilder: (context, index) {
                                    final assistant = assistants[index];
                                    if (assistant.id == _selectedAssistant) {
                                      return const SizedBox.shrink();
                                    }

                                    return InkWell(
                                      borderRadius: DesignConstants.radiusS,
                                      onTap: () {
                                        setState(() {
                                          _selectedAssistant = assistant.id;
                                          _isAssistantDropdownExpanded = false;
                                          _assistantSearchController.clear();
                                          _assistantSearchQuery = "";
                                        });
                                        // 切换助手后重新加载对话
                                        _refreshConversations();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: DesignConstants.spaceS,
                                          horizontal: DesignConstants.spaceS,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              assistant.avatar,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(
                                                width: DesignConstants.spaceM),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    assistant.name,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                  Text(
                                                    assistant.description,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          loading: () => Container(
            margin: DesignConstants.paddingL,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            margin: DesignConstants.paddingL,
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  SizedBox(height: DesignConstants.spaceS),
                  Text('加载助手失败: $error'),
                  SizedBox(height: DesignConstants.spaceS),
                  ElevatedButton(
                    onPressed: () => ref.refresh(aiAssistantNotifierProvider),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Container(
      padding: EdgeInsets.all(DesignConstants.spaceL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: DesignConstants.borderWidthThin,
          ),
        ),
      ),
      child: Column(
        children: [
          // 智能布局：桌面端优先使用水平布局，空间不足时切换到垂直布局
          if (isDesktop)
            _buildDesktopButtonLayout(theme, deviceType)
          else
            // 移动端和平板端水平布局
            Row(
              children: [
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.search,
                    label: "聊天历史",
                    onTap: _openChatSearchScreen,
                    theme: theme,
                    deviceType: deviceType,
                  ),
                ),
                SizedBox(width: DesignConstants.spaceM),
                Expanded(
                  child: _buildBottomButton(
                    icon: Icons.settings,
                    label: "设置",
                    onTap: _showSettingsDialog,
                    theme: theme,
                    deviceType: deviceType,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 桌面端智能按钮布局
  /// 优先使用水平布局，当空间不足时自动切换到垂直布局
  Widget _buildDesktopButtonLayout(ThemeData theme, DeviceType deviceType) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算按钮所需的最小宽度
        // 考虑图标、文字、内边距和间距
        const double iconWidth = 20; // DesignConstants.iconSizeM
        const double spacing = 8; // DesignConstants.spaceS
        const double horizontalPadding = 24; // DesignConstants.spaceM * 2
        const double buttonSpacing = 12; // DesignConstants.spaceM

        // 估算文字宽度（基于字符数和字体大小）
        final fontSize = DesignConstants.getResponsiveFontSize(
          context,
          mobile: 14.0,
          tablet: 15.0,
          desktop: 15.0, // 降低桌面端字体大小以节省空间
        );
        const double avgCharWidth = 0.6; // 中文字符平均宽度系数
        final double searchTextWidth = "聊天历史".length * fontSize * avgCharWidth;
        final double settingsTextWidth = "设置".length * fontSize * avgCharWidth;

        final double minButtonWidth = iconWidth + spacing +
            math.max(searchTextWidth, settingsTextWidth) + horizontalPadding;
        final double totalHorizontalWidth = minButtonWidth * 2 + buttonSpacing;

        // 如果可用宽度足够，使用水平布局；否则使用垂直布局
        if (constraints.maxWidth >= totalHorizontalWidth) {
          return _buildHorizontalButtonLayout(theme, deviceType);
        } else {
          return _buildVerticalButtonLayout(theme, deviceType);
        }
      },
    );
  }

  /// 水平按钮布局（桌面端优化版）
  Widget _buildHorizontalButtonLayout(ThemeData theme, DeviceType deviceType) {
    return Row(
      children: [
        Expanded(
          child: _buildBottomButton(
            icon: Icons.search,
            label: "聊天历史",
            onTap: _openChatSearchScreen,
            theme: theme,
            deviceType: deviceType,
            isCompact: true, // 紧凑模式
          ),
        ),
        SizedBox(width: DesignConstants.spaceM),
        Expanded(
          child: _buildBottomButton(
            icon: Icons.settings,
            label: "设置",
            onTap: _showSettingsDialog,
            theme: theme,
            deviceType: deviceType,
            isCompact: true, // 紧凑模式
          ),
        ),
      ],
    );
  }

  /// 垂直按钮布局（桌面端备选方案）
  Widget _buildVerticalButtonLayout(ThemeData theme, DeviceType deviceType) {
    return Column(
      children: [
        _buildBottomButton(
          icon: Icons.search,
          label: "聊天历史",
          onTap: _openChatSearchScreen,
          theme: theme,
          deviceType: deviceType,
        ),
        SizedBox(height: DesignConstants.spaceM),
        _buildBottomButton(
          icon: Icons.settings,
          label: "设置",
          onTap: _showSettingsDialog,
          theme: theme,
          deviceType: deviceType,
        ),
      ],
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    required DeviceType deviceType,
    bool isCompact = false,
  }) {
    final isDesktop = deviceType == DeviceType.desktop;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: DesignConstants.radiusM,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isCompact
                ? DesignConstants.spaceM
                : (isDesktop ? DesignConstants.spaceL : DesignConstants.spaceM),
            horizontal: isCompact
                ? DesignConstants.spaceS
                : DesignConstants.spaceM,
          ),
          child: Row(
            mainAxisAlignment: isCompact
                ? MainAxisAlignment.center
                : (isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center),
            mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(
                icon,
                size: isCompact ? DesignConstants.iconSizeS : DesignConstants.iconSizeM,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              SizedBox(width: DesignConstants.spaceS),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 14.0,
                      tablet: 15.0,
                      desktop: isCompact ? 14.0 : 15.0, // 紧凑模式使用更小字体
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    Navigator.of(context).pop(); // 关闭侧边栏
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _openChatSearchScreen() async {
    Navigator.of(context).pop(); // 关闭侧边栏

    // 直接打开搜索页面，搜索页面会自己处理导航
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChatSearchScreen()));
  }
}
