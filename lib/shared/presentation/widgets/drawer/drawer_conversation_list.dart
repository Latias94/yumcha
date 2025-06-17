import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../design_system/design_constants.dart';
import '../../../../features/chat/domain/entities/conversation_ui_state.dart';
import 'drawer_constants.dart';

/// 侧边栏对话列表组件
///
/// 提供对话列表功能，包括：
/// - 分页加载
/// - 搜索结果显示
/// - 日期分组
/// - 动画效果
/// - 对话操作菜单
class DrawerConversationList extends ConsumerWidget {
  final PagingController<int, ConversationUiState> pagingController;
  final String searchQuery;
  final ValueNotifier<bool> isSearching;
  final ValueNotifier<String> searchQueryNotifier;
  final Function(ConversationUiState) onConversationTap;
  final Function(ConversationUiState) onDeleteConversation;
  final Function(ConversationUiState) onRegenerateTitle;

  const DrawerConversationList({
    super.key,
    required this.pagingController,
    required this.searchQuery,
    required this.isSearching,
    required this.searchQueryNotifier,
    required this.onConversationTap,
    required this.onDeleteConversation,
    required this.onRegenerateTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        pagingController.refresh();
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isSearching,
        builder: (context, isSearchingValue, child) {
          return Stack(
            children: [
              PagingListener<int, ConversationUiState>(
                controller: pagingController,
                builder: (context, state, fetchNextPage) {
                  return _buildGroupedPagedListView(
                      context, state, fetchNextPage);
                },
              ),
              // 搜索加载指示器
              if (isSearchingValue) _buildSearchIndicator(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchIndicator(BuildContext context) {
    return Positioned(
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
              boxShadow: DesignConstants.shadowM(Theme.of(context)),
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
                    strokeWidth: DesignConstants.borderWidthMedium,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: DesignConstants.spaceS),
                Text(
                  '搜索中...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
        ),
      ),
    );
  }

  Widget _buildGroupedPagedListView(
    BuildContext context,
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
            context,
            conversation,
            globalIndex,
            allItems,
            groups,
          );

          // 只在搜索时显示动画
          if (searchQuery.trim().isNotEmpty) {
            return AnimationConfiguration.staggeredList(
              position: globalIndex,
              duration: const Duration(
                  milliseconds: DrawerConstants.staggeredAnimationDurationMs),
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
        firstPageErrorIndicatorBuilder: (context) =>
            _buildErrorIndicator(context),
        firstPageProgressIndicatorBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (context) => Padding(
          padding: DesignConstants.paddingL,
          child: const Center(child: CircularProgressIndicator()),
        ),
        noItemsFoundIndicatorBuilder: (context) =>
            _buildNoItemsIndicator(context),
      ),
      separatorBuilder: (context, index) =>
          SizedBox(height: DesignConstants.spaceXS),
    );
  }

  Widget _buildErrorIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          SizedBox(height: DesignConstants.spaceL),
          const Text('加载失败'),
          SizedBox(height: DesignConstants.spaceS),
          ElevatedButton(
            onPressed: () => pagingController.refresh(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsIndicator(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: searchQueryNotifier,
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
    );
  }

  // 按日期分组对话
  Map<String, List<ConversationUiState>> _groupConversationsByDate(
    List<ConversationUiState> conversations,
  ) {
    final groups = <String, List<ConversationUiState>>{};

    for (final conversation in conversations) {
      final timestamp = conversation.messages.isNotEmpty
          ? conversation.messages.first.createdAt
          : DateTime.now();

      final groupKey = _getDateGroupTitle(timestamp);
      groups.putIfAbsent(groupKey, () => []).add(conversation);
    }

    return groups;
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

  Widget _buildConversationItemWithGroup(
    BuildContext context,
    ConversationUiState conversation,
    int globalIndex,
    List<ConversationUiState> allItems,
    Map<String, List<ConversationUiState>> groups,
  ) {
    final timestamp = conversation.messages.isNotEmpty
        ? conversation.messages.first.createdAt
        : DateTime.now();
    final groupKey = _getDateGroupTitle(timestamp);

    // 检查是否是组内的第一个项目
    bool isFirstInGroup = false;
    if (globalIndex == 0) {
      isFirstInGroup = true;
    } else {
      final prevConversation = allItems[globalIndex - 1];
      final prevTimestamp = prevConversation.messages.isNotEmpty
          ? prevConversation.messages.first.createdAt
          : DateTime.now();
      final prevGroupKey = _getDateGroupTitle(prevTimestamp);
      isFirstInGroup = groupKey != prevGroupKey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 如果是组内第一个项目，显示组标题
        if (isFirstInGroup) _buildGroupHeader(context, groupKey),
        // 聊天项目
        _buildChatHistoryItem(context, conversation),
      ],
    );
  }

  Widget _buildGroupHeader(BuildContext context, String groupKey) {
    return Container(
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
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildChatHistoryItem(
      BuildContext context, ConversationUiState conversation) {
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
          onTap: () => onConversationTap(conversation),
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
                              conversation.messages.first.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

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
                      onRegenerateTitle(conversation);
                    } else if (value == 'delete') {
                      onDeleteConversation(conversation);
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
}
