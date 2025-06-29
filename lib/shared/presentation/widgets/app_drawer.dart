import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../design_system/design_constants.dart';
import '../../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../features/chat/presentation/providers/unified_chat_notifier.dart';
import '../providers/conversation_title_notifier.dart';

import '../../infrastructure/services/notification_service.dart';
import '../../infrastructure/services/logger_service.dart';
import '../providers/dependency_providers.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import 'package:yumcha/features/search/presentation/screens/chat_search_screen.dart';

// 导入拆分后的组件
import 'drawer/drawer_search_header.dart';
import 'drawer/drawer_conversation_list.dart';
import 'drawer/drawer_assistant_selector.dart';
import 'drawer/drawer_bottom_buttons.dart';
import 'drawer/drawer_search_service.dart';
import 'drawer/drawer_constants.dart';

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
  DrawerSearchService? _searchService;
  final LoggerService _logger = LoggerService();

  String _selectedAssistant = "ai";

  // 用于控制清除按钮显示的ValueNotifier
  final ValueNotifier<bool> _showClearButton = ValueNotifier<bool>(false);

  // 用于控制搜索状态显示的ValueNotifier
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>("");

  // 用于控制搜索加载状态的ValueNotifier
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);

  // 使用 infinite_scroll_pagination 5.0.0 正确的 API
  PagingController<int, ConversationUiState>? _pagingController;

  // 分页配置
  static const int _pageSize = DrawerConstants.pageSize;

  @override
  void initState() {
    super.initState();
    // 延迟初始化，在第一次 build 时通过 ref.watch 获取依赖
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  /// 初始化服务 - 使用响应式的方式获取依赖
  void _initializeServices() {
    if (!mounted) return;

    // ✅ 正确：通过Provider架构，不直接传递Repository
    _searchService = DrawerSearchService(
      ref: ref,
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
      fetchPage: (pageKey) =>
          _searchService?.fetchPage(pageKey) ?? Future.value([]),
    );

    // 监听助手状态变化
    _initializeSelectedAssistant();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController?.dispose();
    _searchService?.dispose();
    _showClearButton.dispose();
    _searchQueryNotifier.dispose();
    _isSearching.dispose();
    super.dispose();
  }

  // 初始化选中的助手
  Future<void> _initializeSelectedAssistant() async {
    final searchService = _searchService;
    if (searchService == null) return;

    try {
      await searchService.initializeSelectedAssistant(() {
        if (mounted) {
          setState(() {
            _selectedAssistant = searchService.selectedAssistant;
          });
          // 只有在助手ID有效时才刷新对话列表
          if (_selectedAssistant.isNotEmpty && _selectedAssistant != "ai") {
            _refreshConversations();
          }
        }
      });
    } catch (e) {
      _logger.error('初始化助手失败', {'error': e.toString()});
      // 如果初始化失败，尝试手动设置一个默认助手
      final enabledAssistants = ref.read(enabledAiAssistantsProvider);
      if (enabledAssistants.isNotEmpty && mounted) {
        setState(() {
          _selectedAssistant = enabledAssistants.first.id;
        });
        _refreshConversations();
      }
    }
  }

  // 处理搜索变化
  void _onSearchChanged(String value) {
    final searchService = _searchService;
    final pagingController = _pagingController;
    if (searchService == null || pagingController == null) return;

    searchService.performDebouncedSearch(
      query: value,
      onSearchStart: () {
        _isSearching.value = true;
      },
      onSearchComplete: () {
        _isSearching.value = false;
        pagingController.refresh();
      },
    );

    // 更新UI状态通知器
    _showClearButton.value = value.isNotEmpty;
    _searchQueryNotifier.value = value;
  }

  // 删除对话
  Future<void> _deleteConversation(String conversationId) async {
    try {
      // 检查删除的对话是否是当前正在显示的对话
      final currentConversation = ref.read(currentConversationProvider);
      final isCurrentConversation = currentConversation?.id == conversationId;

      _logger.info('删除对话: $conversationId, 是否为当前对话: $isCurrentConversation');

      // ✅ 正确：通过 Provider 获取 Repository
      final conversationRepository = ref.read(conversationRepositoryProvider);
      await conversationRepository.deleteConversation(conversationId);

      // 如果删除的是当前对话，创建新对话
      if (isCurrentConversation) {
        _logger.info('删除的是当前对话，创建新对话');
        final chatNotifier = ref.read(unifiedChatProvider.notifier);
        await chatNotifier.createNewConversation();
      }

      // 刷新分页列表
      _pagingController?.refresh();
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
        'previewMessageCount': conversation.messages.length,
      });

      // 显示加载提示
      NotificationService().showInfo('正在重新生成标题...');

      final conversationRepository = ref.read(conversationRepositoryProvider);

      // 获取完整的对话消息（因为对话列表中只包含预览消息）
      final fullConversation =
          await conversationRepository.getConversation(conversation.id);

      if (fullConversation == null) {
        _logger.warning('对话不存在', {'conversationId': conversation.id});
        NotificationService().showError('对话不存在');
        return;
      }

      // 检查是否有足够的消息
      if (fullConversation.messages.length < 2) {
        _logger.info('消息数量不足，无法生成标题', {
          'conversationId': conversation.id,
          'messageCount': fullConversation.messages.length,
          'requiredCount': 2,
        });
        NotificationService().showWarning(
            '消息数量不足，无法生成标题，当前消息数量: ${fullConversation.messages.length}');
        return;
      }

      final titleNotifier =
          ref.read(conversationTitleNotifierProvider.notifier);

      // 使用完整的消息列表进行标题生成
      await titleNotifier.regenerateTitle(
          conversation.id, fullConversation.messages);

      _logger.info('标题重新生成成功', {
        'conversationId': conversation.id,
        'messageCount': fullConversation.messages.length,
      });

      NotificationService().showSuccess('标题重新生成成功');

      _refreshConversations();
    } catch (e, stackTrace) {
      _logger.error('重新生成标题失败', {
        'conversationId': conversation.id,
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
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
    _pagingController?.refresh();
  }

  // 处理助手变化
  Future<void> _onAssistantChanged(String assistantId) async {
    setState(() {
      _selectedAssistant = assistantId;
    });
    await _searchService?.setSelectedAssistant(assistantId);
    _refreshConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // 监听统一聊天状态变化，当对话列表需要刷新时自动刷新
        ref.listen(
            unifiedChatProvider.select(
                (state) => state.conversationState.recentConversations.length),
            (previous, next) {
          // 当对话数量发生变化时，刷新对话列表
          if (mounted && previous != next) {
            _logger.debug('对话数量变化，刷新分页控制器: $previous -> $next');
            _refreshConversations();
          }
        });

        final theme = Theme.of(context);
        final deviceType = DesignConstants.getDeviceType(context);

        return Drawer(
          width: deviceType == DeviceType.desktop
              ? DrawerConstants.desktopWidth
              : deviceType == DeviceType.tablet
                  ? DrawerConstants.tabletWidth
                  : null, // 使用默认宽度
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: DesignConstants.shadowL(theme),
            ),
            child: Column(
              children: [
                // 搜索框
                DrawerSearchHeader(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  showClearButton: _showClearButton,
                ),

                // 聊天记录列表
                Expanded(
                  child: _pagingController != null && _searchService != null
                      ? DrawerConversationList(
                          pagingController: _pagingController!,
                          searchQuery: _searchService!.searchQuery,
                          isSearching: _isSearching,
                          searchQueryNotifier: _searchQueryNotifier,
                          onConversationTap: (conversation) =>
                              widget.onChatClicked(conversation.id),
                          onDeleteConversation: _showDeleteConfirmDialog,
                          onRegenerateTitle: _regenerateTitle,
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),

                // 助手选择下拉框
                DrawerAssistantSelector(
                  selectedAssistant: _selectedAssistant,
                  onAssistantChanged: _onAssistantChanged,
                ),

                // 底部按钮
                DrawerBottomButtons(
                  onSearchTap: _openChatSearchScreen,
                  onSettingsTap: _showSettingsDialog,
                ),
              ],
            ),
          ),
        );
      },
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
