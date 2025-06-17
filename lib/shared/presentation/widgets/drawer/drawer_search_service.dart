import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../infrastructure/services/logger_service.dart';
import '../../providers/providers.dart';
import '../../../../features/settings/domain/entities/app_setting.dart';
import '../../../../features/settings/presentation/providers/settings_notifier.dart';
import 'drawer_constants.dart';
import 'drawer_search_providers.dart';

/// 侧边栏搜索服务
///
/// ✅ 重构后的版本 - 遵循Riverpod最佳实践
///
/// 提供搜索相关的业务逻辑，包括：
/// - 防抖搜索
/// - 搜索状态管理
/// - 通过Provider访问数据（不直接依赖Repository）
class DrawerSearchService {
  final LoggerService _logger = LoggerService();
  final WidgetRef _ref;

  // 搜索防抖Timer
  Timer? _searchDebounce;

  // 分页配置
  static const int _pageSize = DrawerConstants.pageSize;

  DrawerSearchService({
    required WidgetRef ref,
  }) : _ref = ref;

  /// 设置当前搜索查询
  void setSearchQuery(String query) {
    _ref.read(drawerSearchQueryProvider.notifier).state = query;
  }

  /// 设置当前选中的助手并保存到设置
  Future<void> setSelectedAssistant(String assistantId) async {
    _ref.read(drawerSelectedAssistantProvider.notifier).state = assistantId;

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
  String get searchQuery => _ref.read(drawerSearchQueryProvider);

  /// 获取当前选中的助手
  String get selectedAssistant => _ref.read(drawerSelectedAssistantProvider);

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

    // 更新搜索查询到Provider
    setSearchQuery(query);

    // 如果搜索查询为空，立即完成
    if (query.trim().isEmpty) {
      onSearchComplete();
      return;
    }

    // 显示搜索状态
    onSearchStart();

    // 设置防抖Timer
    _searchDebounce = Timer(debounceDelay, () {
      _logger.debug('执行搜索: $query');
      onSearchComplete();
    });
  }

  /// 获取分页数据 - 通过Provider访问
  Future<List<ConversationUiState>> fetchPage(int pageKey) async {
    final searchQuery = _ref.read(drawerSearchQueryProvider);
    final selectedAssistant = _ref.read(drawerSelectedAssistantProvider);

    _logger.debug(
      '开始获取分页数据: pageKey=$pageKey, searchQuery="$searchQuery", assistant=$selectedAssistant',
    );

    // 确保有有效的助手选择
    String assistantId = selectedAssistant;
    if (assistantId == "ai" || assistantId.isEmpty) {
      // 尝试重新初始化助手选择
      final assistants = _ref.read(aiAssistantsProvider);
      final enabledAssistants = assistants.where((a) => a.isEnabled).toList();
      if (enabledAssistants.isNotEmpty) {
        assistantId = enabledAssistants.first.id;
        setSelectedAssistant(assistantId); // 更新到Provider
        _logger.debug('重新初始化助手选择: $assistantId');
      } else {
        _logger.warning('没有可用助手');
        return []; // 没有可用助手时返回空列表
      }
    }

    try {
      // 使用Provider获取数据
      final params = DrawerPageParams(
        pageKey: pageKey,
        searchQuery: searchQuery,
        assistantId: assistantId,
        pageSize: _pageSize,
      );

      final asyncValue =
          await _ref.read(drawerConversationPageProvider(params).future);
      return asyncValue;
    } catch (e, stackTrace) {
      _logger.error('获取对话列表失败', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'pageKey': pageKey,
        'searchQuery': searchQuery,
        'selectedAssistant': assistantId,
      });
      return []; // 出错时返回空列表而不是抛出异常
    }
  }

  /// 初始化选中的助手（从设置中恢复）
  Future<void> initializeSelectedAssistant(
      VoidCallback onRefreshConversations) async {
    // 检查助手数据的加载状态
    try {
      final allAssistants = _ref.read(aiAssistantsProvider);
      final enabledAssistants =
          allAssistants.where((a) => a.isEnabled).toList();

      if (enabledAssistants.isEmpty) {
        _logger.warning('没有可用助手，等待数据加载...');

        // 如果助手数据还在加载中，等待一段时间后重试
        await Future.delayed(const Duration(milliseconds: 500));
        final retryAssistants =
            _ref.read(aiAssistantsProvider).where((a) => a.isEnabled).toList();
        if (retryAssistants.isEmpty) {
          _logger.error('重试后仍然没有可用助手');
          return;
        }
        _logger.debug('重试后找到助手: ${retryAssistants.length}个');
      }
    } catch (error) {
      _logger.error('助手数据加载失败: $error');
      return;
    }

    try {
      final allAssistants = _ref.read(aiAssistantsProvider);
      final enabledAssistants =
          allAssistants.where((a) => a.isEnabled).toList();

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

      // 获取当前选择的助手
      final currentSelectedAssistant =
          _ref.read(drawerSelectedAssistantProvider);

      // 更新选择的助手
      if (currentSelectedAssistant != targetAssistantId) {
        await setSelectedAssistant(targetAssistantId);

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
      final allAssistants = _ref.read(aiAssistantsProvider);
      final enabledAssistants =
          allAssistants.where((a) => a.isEnabled).toList();
      if (enabledAssistants.isNotEmpty) {
        await setSelectedAssistant(enabledAssistants.first.id);
        onRefreshConversations();
      }
    }
  }

  /// 清理资源
  void dispose() {
    _searchDebounce?.cancel();
  }
}
