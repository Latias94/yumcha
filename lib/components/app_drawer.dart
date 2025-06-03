import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/conversation_ui_state.dart';
import '../providers/providers.dart';
import '../services/conversation_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/logger_service.dart';
import '../screens/settings_screen.dart';
import '../screens/chat_search_screen.dart';

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
          if (lastPage.isEmpty) {
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

      // 如果有搜索查询，使用搜索方法
      if (_searchQuery.trim().isNotEmpty) {
        _logger.debug(
          '执行搜索: query="$_searchQuery", assistantId=$_selectedAssistant',
        );
        results = await _conversationRepository.searchConversationsByTitle(
          _searchQuery,
          assistantId: _selectedAssistant,
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
      _refreshConversations();
      return;
    }

    // 设置防抖Timer，500ms后执行搜索
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _logger.debug('执行搜索: $_searchQuery');
      _refreshConversations();
    });
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // 顶部空间，避免与状态栏重叠
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 搜索框
          ValueListenableBuilder<bool>(
            valueListenable: _showClearButton,
            builder: (context, showClear, child) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "搜索对话标题...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: showClear
                        ? IconButton(
                            key: const ValueKey('clear_button'),
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged("");
                            },
                          )
                        : const SizedBox.shrink(key: ValueKey('empty_space')),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _onSearchChanged,
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
      child: PagingListener<int, ConversationUiState>(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) {
          return _buildGroupedPagedListView(state, fetchNextPage);
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
          return _buildConversationItemWithGroup(
            conversation,
            globalIndex,
            allItems,
            groups,
          );
        },
        firstPageErrorIndicatorBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('加载失败'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _pagingController.refresh(),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        firstPageProgressIndicatorBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        noItemsFoundIndicatorBuilder: (context) =>
            ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, searchQuery, child) {
                final isEmpty = searchQuery.trim().isEmpty;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEmpty ? "暂无聊天记录" : "未找到包含 \"$searchQuery\" 的对话",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isEmpty) ...[
                        const SizedBox(height: 8),
                        Consumer(
                          builder: (context, ref, _) {
                            final selectedAssistant = ref.watch(
                              aiAssistantProvider(_selectedAssistant),
                            );
                            return Text(
                              "开始与${selectedAssistant?.name ?? 'AI助手'}聊天吧！",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            );
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          "尝试使用不同的关键词",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 4),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              groupKey,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // 聊天项目
        _buildChatHistoryItem(conversation),
      ],
    );
  }

  Widget _buildChatHistoryItem(ConversationUiState conversation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // 打开特定的聊天记录
            _logger.debug(
              '点击对话: ${conversation.id}, 标题: ${conversation.channelName}',
            );
            widget.onChatClicked(conversation.id);
          },
          onLongPress: () {
            // 显示上下文菜单
            _showContextMenu(context, conversation);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.channelName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 消息数量指示器
                if (conversation.messages.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      conversation.messages.length.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10,
                      ),
                    ),
                  ),
                // 更多选项按钮
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Text('删除对话'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
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

  // 显示上下文菜单
  void _showContextMenu(
    BuildContext context,
    ConversationUiState conversation,
  ) {
    // 显示操作菜单
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 200, 0, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('删除对话'),
            ],
          ),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (value == 'delete') {
        _showDeleteConfirmDialog(conversation);
      }
    });
  }

  Widget _buildAssistantSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
        final selectedAssistant = ref.watch(
          aiAssistantProvider(_selectedAssistant),
        );

        return assistantsAsync.when(
          data: (assistants) => Container(
            margin: const EdgeInsets.all(16),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _isAssistantDropdownExpanded =
                        !_isAssistantDropdownExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 当前选中的助手
                      Row(
                        children: [
                          Text(
                            selectedAssistant?.avatar ?? '🤖',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAssistant?.name ?? 'AI助手',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                if (selectedAssistant != null)
                                  Text(
                                    selectedAssistant.description,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isAssistantDropdownExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_up),
                          ),
                        ],
                      ),

                      // 展开的助手列表
                      if (_isAssistantDropdownExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // 助手列表
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: assistants.length > 10
                                ? 200
                                : double.infinity,
                          ),
                          child: assistants.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    _assistantSearchQuery.isNotEmpty
                                        ? '未找到匹配的助手'
                                        : '暂无可用助手',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
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
                                      borderRadius: BorderRadius.circular(8),
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              assistant.avatar,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                                          color:
                                                              Colors.grey[600],
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
            margin: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            margin: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('加载助手失败: $error'),
                  const SizedBox(height: 8),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 聊天历史和设置按钮
          Row(
            children: [
              // 聊天历史搜索按钮
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // 打开全面搜索页面
                    _openChatSearchScreen();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "聊天历史",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 设置按钮
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _showSettingsDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "设置",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
