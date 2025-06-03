import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/conversation_repository.dart';
import '../services/assistant_repository.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';

// Repository Providers
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository(DatabaseService.instance.database);
});

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return AssistantRepository(DatabaseService.instance.database);
});

// 搜索查询状态
final searchQueryProvider = StateProvider<String>((ref) => '');

// 搜索类型枚举
enum SearchType { all, conversations, messages }

// 搜索类型状态
final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.all);

// 搜索结果Provider
final searchResultsProvider =
    AsyncNotifierProvider<SearchResultsNotifier, SearchResults>(() {
      return SearchResultsNotifier();
    });

// 搜索结果数据模型
class SearchResults {
  final List<MessageSearchResult> messages;
  final List<ConversationSearchResult> conversations;
  final bool hasMore;
  final int totalCount;

  const SearchResults({
    required this.messages,
    required this.conversations,
    required this.hasMore,
    required this.totalCount,
  });

  SearchResults copyWith({
    List<MessageSearchResult>? messages,
    List<ConversationSearchResult>? conversations,
    bool? hasMore,
    int? totalCount,
  }) {
    return SearchResults(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// 对话搜索结果模型
class ConversationSearchResult {
  final String id;
  final String title;
  final String assistantId;
  final String assistantName;
  final DateTime lastMessageAt;
  final int messageCount;

  const ConversationSearchResult({
    required this.id,
    required this.title,
    required this.assistantId,
    required this.assistantName,
    required this.lastMessageAt,
    required this.messageCount,
  });
}

// 搜索结果项基类
abstract class SearchResultItem {
  String get conversationId;
  String? get messageId => null; // 消息搜索结果才有messageId
}

// 对话搜索结果项
class ConversationResultItem extends SearchResultItem {
  final ConversationSearchResult conversation;

  ConversationResultItem(this.conversation);

  @override
  String get conversationId => conversation.id;
}

// 消息搜索结果项
class MessageResultItem extends SearchResultItem {
  final MessageSearchResult message;

  MessageResultItem(this.message);

  @override
  String get conversationId => message.conversationId;

  @override
  String? get messageId => message.message.id;
}

// 搜索结果状态管理
class SearchResultsNotifier extends AsyncNotifier<SearchResults> {
  Timer? _debounce;
  final LoggerService _logger = LoggerService();

  static const int _pageSize = 20;
  int _currentOffset = 0;
  String _lastQuery = '';
  SearchType _lastSearchType = SearchType.all;

  @override
  FutureOr<SearchResults> build() {
    // 监听搜索查询和类型变化
    final query = ref.watch(searchQueryProvider);
    final searchType = ref.watch(searchTypeProvider);

    // 清理旧的防抖Timer
    _debounce?.cancel();

    // 如果查询为空，返回空结果
    if (query.trim().isEmpty) {
      return const SearchResults(
        messages: [],
        conversations: [],
        hasMore: false,
        totalCount: 0,
      );
    }

    // 如果查询或搜索类型发生变化，重置分页
    if (query != _lastQuery || searchType != _lastSearchType) {
      _currentOffset = 0;
      _lastQuery = query;
      _lastSearchType = searchType;
    }

    // 设置防抖搜索
    final completer = Completer<SearchResults>();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _performSearch(query, searchType, 0);
        completer.complete(results);
      } catch (e, s) {
        _logger.error('搜索失败', {
          'error': e.toString(),
          'stackTrace': s.toString(),
        });
        completer.completeError(e, s);
      }
    });

    return completer.future;
  }

  // 加载更多搜索结果
  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore) return;

    final query = ref.read(searchQueryProvider);
    final searchType = ref.read(searchTypeProvider);

    if (query.trim().isEmpty) return;

    try {
      _currentOffset += _pageSize;
      final newResults = await _performSearch(
        query,
        searchType,
        _currentOffset,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          messages: [...currentState.messages, ...newResults.messages],
          conversations: [
            ...currentState.conversations,
            ...newResults.conversations,
          ],
          hasMore: newResults.hasMore,
          totalCount: newResults.totalCount,
        ),
      );
    } catch (e) {
      _logger.error('加载更多搜索结果失败', {'error': e.toString()});
      // 保持当前状态，不更新为错误状态
    }
  }

  // 执行搜索
  Future<SearchResults> _performSearch(
    String query,
    SearchType searchType,
    int offset,
  ) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const SearchResults(
        messages: [],
        conversations: [],
        hasMore: false,
        totalCount: 0,
      );
    }

    List<MessageSearchResult> messages = [];
    List<ConversationSearchResult> conversations = [];
    int totalCount = 0;

    // 根据搜索类型执行不同的搜索
    switch (searchType) {
      case SearchType.all:
        // 搜索消息和对话
        final conversationRepository = ref.read(conversationRepositoryProvider);
        final messageResults = await conversationRepository.searchMessages(
          trimmedQuery,
          limit: _pageSize ~/ 2,
          offset: offset ~/ 2,
        );
        messages = messageResults;

        final conversationResults = await _searchConversations(
          trimmedQuery,
          limit: _pageSize ~/ 2,
          offset: offset ~/ 2,
        );
        conversations = conversationResults;

        totalCount = messages.length + conversations.length;
        break;

      case SearchType.messages:
        // 只搜索消息
        final conversationRepository = ref.read(conversationRepositoryProvider);
        final messageResults = await conversationRepository.searchMessages(
          trimmedQuery,
          limit: _pageSize,
          offset: offset,
        );
        messages = messageResults;
        totalCount = messages.length;
        break;

      case SearchType.conversations:
        // 只搜索对话标题
        final conversationResults = await _searchConversations(
          trimmedQuery,
          limit: _pageSize,
          offset: offset,
        );
        conversations = conversationResults;
        totalCount = conversations.length;
        break;
    }

    // 判断是否还有更多数据
    final hasMore =
        (searchType == SearchType.all && totalCount >= _pageSize) ||
        (searchType != SearchType.all && totalCount >= _pageSize);

    return SearchResults(
      messages: messages,
      conversations: conversations,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  // 搜索对话并转换为结果模型
  Future<List<ConversationSearchResult>> _searchConversations(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final conversationRepository = ref.read(conversationRepositoryProvider);
    final conversationResults = await conversationRepository
        .searchConversationsByTitle(query, limit: limit, offset: offset);

    final results = <ConversationSearchResult>[];
    for (final conversation in conversationResults) {
      // 获取助手信息
      final assistantName = await _getAssistantName(conversation.assistantId);

      results.add(
        ConversationSearchResult(
          id: conversation.id,
          title: conversation.channelName,
          assistantId: conversation.assistantId ?? '',
          assistantName: assistantName,
          lastMessageAt: conversation.messages.isNotEmpty
              ? conversation.messages.first.timestamp
              : DateTime.now(),
          messageCount: conversation.messages.length,
        ),
      );
    }

    return results;
  }

  // 获取助手名称
  Future<String> _getAssistantName(String? assistantId) async {
    if (assistantId == null || assistantId.isEmpty) {
      return 'AI助手';
    }

    try {
      final assistantRepository = ref.read(assistantRepositoryProvider);
      final assistant = await assistantRepository.getAssistant(assistantId);
      return assistant?.name ?? 'AI助手';
    } catch (e) {
      _logger.error('获取助手名称失败', {
        'assistantId': assistantId,
        'error': e.toString(),
      });
      return 'AI助手';
    }
  }
}
