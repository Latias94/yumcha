import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../../features/chat/data/repositories/conversation_repository.dart';
import '../../../infrastructure/services/logger_service.dart';
import '../../providers/providers.dart';
import '../../../../features/settings/domain/entities/app_setting.dart';
import '../../../../features/settings/presentation/providers/settings_notifier.dart';
import 'drawer_constants.dart';

/// 侧边栏搜索服务
///
/// 提供搜索相关的业务逻辑，包括：
/// - 防抖搜索
/// - 综合搜索（标题+内容）
/// - 搜索状态管理
/// - 分页数据获取
class DrawerSearchService {
  final ConversationRepository _conversationRepository;
  final LoggerService _logger = LoggerService();
  final WidgetRef _ref;

  // 搜索防抖Timer
  Timer? _searchDebounce;

  // 搜索状态
  String _searchQuery = "";
  String _selectedAssistant = "ai";

  // 分页配置
  static const int _pageSize = DrawerConstants.pageSize;

  DrawerSearchService({
    required ConversationRepository conversationRepository,
    required WidgetRef ref,
  })  : _conversationRepository = conversationRepository,
        _ref = ref;

  /// 设置当前搜索查询
  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  /// 设置当前选中的助手并保存到设置
  Future<void> setSelectedAssistant(String assistantId) async {
    _selectedAssistant = assistantId;

    // 保存到设置中
    try {
      final settingsNotifier = _ref.read(settingsNotifierProvider.notifier);
      await settingsNotifier.setSetting<String>(
        key: SettingKeys.lastUsedAssistantId,
        value: assistantId,
        description: '最后使用的助手ID',
      );
      _logger.debug('助手选择已保存到设置: $assistantId');
    } catch (e) {
      _logger.error('保存助手选择失败', {
        'assistantId': assistantId,
        'error': e.toString(),
      });
    }
  }

  /// 获取当前搜索查询
  String get searchQuery => _searchQuery;

  /// 获取当前选中的助手
  String get selectedAssistant => _selectedAssistant;

  /// 防抖搜索
  void performDebouncedSearch({
    required String query,
    required VoidCallback onSearchStart,
    required VoidCallback onSearchComplete,
    Duration debounceDelay =
        const Duration(milliseconds: DrawerConstants.searchDebounceMs),
  }) {
    // 取消之前的防抖Timer
    _searchDebounce?.cancel();

    // 更新搜索查询
    _searchQuery = query;

    // 如果搜索查询为空，立即完成
    if (query.trim().isEmpty) {
      onSearchComplete();
      return;
    }

    // 显示搜索状态
    onSearchStart();

    // 设置防抖Timer
    _searchDebounce = Timer(debounceDelay, () {
      _logger.debug('执行搜索: $_searchQuery');
      onSearchComplete();
    });
  }

  /// 获取分页数据
  Future<List<ConversationUiState>> fetchPage(int pageKey) async {
    _logger.debug(
      '开始获取分页数据: pageKey=$pageKey, searchQuery="$_searchQuery", assistant=$_selectedAssistant',
    );

    // 确保有有效的助手选择
    if (_selectedAssistant == "ai" || _selectedAssistant.isEmpty) {
      // 尝试重新初始化助手选择
      final assistantsAsync = _ref.read(enabledAiAssistantsProvider);
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
        results = await performComprehensiveSearch(
          _searchQuery,
          _selectedAssistant,
          limit: _pageSize,
          offset: pageKey,
        );
        _logger.debug('搜索结果数量: ${results.length}');
      } else {
        // 否则使用正常的分页获取
        _logger.debug('获取正常对话列表: assistantId=$_selectedAssistant');

        // 添加超时保护，避免无限等待
        results = await _conversationRepository
            .getConversationsByAssistantWithPagination(
          _selectedAssistant,
          limit: _pageSize,
          offset: pageKey,
          includeMessages: false, // 不包含完整消息内容，提高性能
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            _logger.warning('获取对话列表超时，返回空列表');
            return <ConversationUiState>[];
          },
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

  /// 执行综合搜索（搜索对话标题和消息内容）
  Future<List<ConversationUiState>> performComprehensiveSearch(
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
      final conversationResults =
          await _conversationRepository.searchConversationsByTitle(
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
          final conversation =
              await _conversationRepository.getConversation(conversationId);
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

  /// 初始化选中的助手（从设置中恢复）
  Future<void> initializeSelectedAssistant(
      VoidCallback onRefreshConversations) async {
    // 检查助手数据的加载状态
    final assistantsAsyncValue = _ref.read(aiAssistantNotifierProvider);
    _logger.debug('助手数据状态: ${assistantsAsyncValue.runtimeType}');

    assistantsAsyncValue.when(
      data: (allAssistants) {
        _logger.debug('所有助手数量: ${allAssistants.length}');
        final enabledAssistants = allAssistants.where((a) => a.isEnabled).toList();
        _logger.debug('启用的助手数量: ${enabledAssistants.length}');
        for (final assistant in enabledAssistants) {
          _logger.debug('启用的助手: ${assistant.id} - ${assistant.name}');
        }
      },
      loading: () => _logger.debug('助手数据正在加载中'),
      error: (error, stack) => _logger.error('助手数据加载失败: $error'),
    );

    final assistantsAsync = _ref.read(enabledAiAssistantsProvider);
    if (assistantsAsync.isEmpty) {
      _logger.warning('没有可用助手，等待数据加载...');

      // 如果助手数据还在加载中，等待一段时间后重试
      await Future.delayed(const Duration(milliseconds: 500));
      final retryAssistants = _ref.read(enabledAiAssistantsProvider);
      if (retryAssistants.isEmpty) {
        _logger.error('重试后仍然没有可用助手');
        return;
      }
      _logger.debug('重试后找到助手: ${retryAssistants.length}个');
    }

    try {
      final enabledAssistants = _ref.read(enabledAiAssistantsProvider);

      // 从设置中读取上次选择的助手
      final settingsNotifier = _ref.read(settingsNotifierProvider.notifier);
      final lastUsedAssistantId = settingsNotifier.getValue<String>(
        SettingKeys.lastUsedAssistantId,
      );

      _logger.debug('从设置中读取的助手ID: $lastUsedAssistantId');

      String targetAssistantId;

      if (lastUsedAssistantId != null && lastUsedAssistantId.isNotEmpty) {
        // 验证保存的助手是否仍然有效
        final isValidAssistant = enabledAssistants.any(
          (a) => a.id == lastUsedAssistantId,
        );

        if (isValidAssistant) {
          targetAssistantId = lastUsedAssistantId;
          _logger.debug('恢复上次选择的助手: $targetAssistantId');
        } else {
          // 如果保存的助手无效，选择第一个可用助手
          targetAssistantId = enabledAssistants.first.id;
          _logger.debug('上次选择的助手无效，选择第一个可用助手: $targetAssistantId');
        }
      } else {
        // 如果没有保存的选择，选择第一个可用助手
        targetAssistantId = enabledAssistants.first.id;
        _logger.debug('没有保存的助手选择，选择第一个可用助手: $targetAssistantId');
      }

      // 更新选择的助手
      if (_selectedAssistant != targetAssistantId) {
        _selectedAssistant = targetAssistantId;

        // 保存新的选择到设置（如果是从默认值或无效值切换过来的）
        if (lastUsedAssistantId != targetAssistantId) {
          await settingsNotifier.setSetting<String>(
            key: SettingKeys.lastUsedAssistantId,
            value: targetAssistantId,
            description: '最后使用的助手ID',
          );
        }

        onRefreshConversations();
      }
    } catch (e) {
      _logger.error('初始化助手选择失败', {
        'error': e.toString(),
      });

      // 出错时使用第一个可用助手
      final enabledAssistants = _ref.read(enabledAiAssistantsProvider);
      if (enabledAssistants.isNotEmpty) {
        _selectedAssistant = enabledAssistants.first.id;
        onRefreshConversations();
      }
    }
  }

  /// 清理资源
  void dispose() {
    _searchDebounce?.cancel();
  }
}
