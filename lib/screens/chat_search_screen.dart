import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_search_providers.dart';
import '../providers/conversation_notifier.dart';
import '../components/search_result_item.dart';
import '../services/logger_service.dart';

class ChatSearchScreen extends ConsumerStatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  ConsumerState<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends ConsumerState<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 接近底部时加载更多
      ref.read(searchResultsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchType = ref.watch(searchTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天历史搜索'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '搜索聊天记录和消息内容...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
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
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
              ),

              // 搜索类型选择
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildSearchTypeChip(
                      label: '全部',
                      type: SearchType.all,
                      isSelected: searchType == SearchType.all,
                    ),
                    const SizedBox(width: 8),
                    _buildSearchTypeChip(
                      label: '对话标题',
                      type: SearchType.conversations,
                      isSelected: searchType == SearchType.conversations,
                    ),
                    const SizedBox(width: 8),
                    _buildSearchTypeChip(
                      label: '消息内容',
                      type: SearchType.messages,
                      isSelected: searchType == SearchType.messages,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: searchResults.when(
        data: (results) => _buildSearchResults(results, searchQuery),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildSearchTypeChip({
    required String label,
    required SearchType type,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(searchTypeProvider.notifier).state = type;
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildSearchResults(SearchResults results, String searchQuery) {
    if (searchQuery.trim().isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        title: '开始搜索',
        subtitle: '输入关键词搜索聊天记录和消息内容',
      );
    }

    final totalItems = results.conversations.length + results.messages.length;

    if (totalItems == 0) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: '未找到结果',
        subtitle: '尝试使用不同的关键词或搜索类型',
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 结果统计
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '找到 ${results.conversations.length} 个对话和 ${results.messages.length} 条消息',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),

        // 对话结果
        if (results.conversations.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                '对话 (${results.conversations.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final conversation = results.conversations[index];
              return ConversationSearchResultItem(
                result: conversation,
                searchQuery: searchQuery,
                onTap: () => _openConversation(conversation.id),
              );
            }, childCount: results.conversations.length),
          ),
        ],

        // 消息结果
        if (results.messages.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '消息 (${results.messages.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final message = results.messages[index];
              return MessageSearchResultItem(
                result: message,
                searchQuery: searchQuery,
                onTap: () => _openConversationWithMessage(
                  message.conversationId,
                  message.message.id!,
                ),
              );
            }, childCount: results.messages.length),
          ),
        ],

        // 加载更多指示器
        if (results.hasMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // 底部间距
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('搜索出错', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(searchResultsProvider);
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  void _openConversation(String conversationId) {
    _logger.info('打开对话', {'conversationId': conversationId});

    // 直接导航到主页面，而不是返回结果
    _navigateToConversation(conversationId, null);
  }

  void _openConversationWithMessage(String conversationId, String messageId) {
    _logger.info('打开对话并定位到消息', {
      'conversationId': conversationId,
      'messageId': messageId,
    });

    // 直接导航到主页面，而不是返回结果
    _navigateToConversation(conversationId, messageId);
  }

  void _navigateToConversation(String conversationId, String? messageId) async {
    _logger.info('搜索页面直接导航到对话', {
      'conversationId': conversationId,
      'messageId': messageId,
    });

    try {
      // 直接使用 Riverpod 切换对话状态
      final conversationNotifier = ref.read(
        currentConversationProvider.notifier,
      );

      _logger.info('开始切换对话状态');
      await conversationNotifier.switchToConversation(conversationId);

      _logger.info('对话状态切换完成，开始导航');

      // 检查 widget 是否还在
      if (!mounted) {
        _logger.warning('Widget 已经 unmounted，取消导航');
        return;
      }

      // 简单地返回主页面，不需要传递参数
      await Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (route) => false);

      _logger.info('搜索页面导航完成');
    } catch (error) {
      _logger.error('导航过程失败', {'error': error.toString()});
    }
  }
}
