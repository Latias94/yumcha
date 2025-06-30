import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../providers/dependency_providers.dart';
import '../../../infrastructure/services/logger_service.dart';

/// 🔍 侧边栏搜索Provider
///
/// 遵循Riverpod最佳实践，通过Provider层访问数据，
/// 替代直接在UI组件中使用Repository的方式。

/// 搜索查询状态Provider
final drawerSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// 选中助手状态Provider
final drawerSelectedAssistantProvider =
    StateProvider.autoDispose<String>((ref) => 'ai');

/// 搜索结果Provider - 分页获取对话列表
final drawerConversationPageProvider = FutureProvider.autoDispose
    .family<List<ConversationUiState>, DrawerPageParams>((ref, params) async {
  final conversationRepository = ref.read(conversationRepositoryProvider);
  final logger = LoggerService();

  try {
    logger.debug('获取对话分页数据', {
      'pageKey': params.pageKey,
      'searchQuery': params.searchQuery,
      'assistantId': params.assistantId,
    });

    List<ConversationUiState> results;

    // 如果有搜索查询，使用综合搜索
    if (params.searchQuery.trim().isNotEmpty) {
      results = await _performComprehensiveSearch(
        conversationRepository,
        params.searchQuery,
        params.assistantId,
        limit: params.pageSize,
        offset: params.pageKey,
        logger: logger,
      );
    } else {
      // 否则使用正常的分页获取
      results = await conversationRepository
          .getConversationsByAssistantWithPagination(
        params.assistantId,
        limit: params.pageSize,
        offset: params.pageKey,
        includeMessages: false,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.warning('获取对话列表超时，返回空列表');
          return <ConversationUiState>[];
        },
      );
    }

    logger.debug('对话列表获取成功', {'count': results.length});
    return results;
  } catch (e, stackTrace) {
    logger.error('获取对话列表失败', {
      'error': e.toString(),
      'stackTrace': stackTrace.toString(),
      'params': params.toString(),
    });
    return []; // 出错时返回空列表
  }
});

/// 执行综合搜索的辅助函数
Future<List<ConversationUiState>> _performComprehensiveSearch(
  dynamic conversationRepository,
  String query,
  String assistantId, {
  int limit = 20,
  int offset = 0,
  required LoggerService logger,
}) async {
  final trimmedQuery = query.trim();
  if (trimmedQuery.isEmpty) {
    return [];
  }

  try {
    // 1. 搜索对话标题
    final conversationResults =
        await conversationRepository.searchConversationsByTitle(
      trimmedQuery,
      assistantId: assistantId,
      limit: limit,
      offset: offset,
    );

    // 2. 搜索消息内容
    final messageResults = await conversationRepository.searchMessages(
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
        final conversation =
            await conversationRepository.getConversation(conversationId);
        if (conversation != null) {
          uniqueConversations[conversationId] = conversation;
        }
      }
    }

    // 4. 按最后消息时间排序
    final sortedResults = uniqueConversations.values.toList();
    sortedResults.sort((a, b) {
      final aTime = a.messages.isNotEmpty
          ? a.messages.last.createdAt
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.messages.isNotEmpty
          ? b.messages.last.createdAt
          : DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime); // 降序排列
    });

    logger.debug(
      '综合搜索完成: 标题匹配=${conversationResults.length}, 消息匹配=${messageResults.length}, 去重后=${sortedResults.length}',
    );

    return sortedResults;
  } catch (e, stackTrace) {
    logger.error('综合搜索失败', {
      'error': e.toString(),
      'stackTrace': stackTrace.toString(),
      'query': trimmedQuery,
      'assistantId': assistantId,
    });
    return [];
  }
}

/// 分页参数数据类
class DrawerPageParams {
  final int pageKey;
  final String searchQuery;
  final String assistantId;
  final int pageSize;

  const DrawerPageParams({
    required this.pageKey,
    required this.searchQuery,
    required this.assistantId,
    this.pageSize = 20,
  });

  @override
  String toString() {
    return 'DrawerPageParams(pageKey: $pageKey, searchQuery: "$searchQuery", assistantId: $assistantId, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawerPageParams &&
        other.pageKey == pageKey &&
        other.searchQuery == searchQuery &&
        other.assistantId == assistantId &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode {
    return pageKey.hashCode ^
        searchQuery.hashCode ^
        assistantId.hashCode ^
        pageSize.hashCode;
  }
}
