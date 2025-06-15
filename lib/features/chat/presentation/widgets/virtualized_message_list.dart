import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_providers.dart';
import 'message_view_adapter.dart';

/// 虚拟化消息列表
/// 
/// 使用虚拟化技术优化大量消息的渲染性能，
/// 只渲染可见区域的消息，提高滚动流畅度。
/// 
/// 功能特性：
/// - 🚀 **虚拟化渲染**: 只渲染可见消息，减少内存占用
/// - 📱 **自适应高度**: 根据消息内容动态计算高度
/// - 🔄 **懒加载**: 支持分页加载历史消息
/// - 📍 **位置保持**: 滚动位置智能保持
/// - ⚡ **性能优化**: 优化的重建和缓存策略
class VirtualizedMessageList extends ConsumerStatefulWidget {
  /// 对话ID
  final String conversationId;
  
  /// 消息列表
  final List<Message> messages;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 是否有更多消息
  final bool hasMore;
  
  /// 加载更多消息回调
  final VoidCallback? onLoadMore;
  
  /// 消息编辑回调
  final void Function(Message message)? onEditMessage;
  
  /// 消息重新生成回调
  final void Function(Message message)? onRegenerateMessage;
  
  /// 消息删除回调
  final void Function(Message message)? onDeleteMessage;
  
  /// 欢迎消息
  final String? welcomeMessage;

  const VirtualizedMessageList({
    super.key,
    required this.conversationId,
    required this.messages,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onEditMessage,
    this.onRegenerateMessage,
    this.onDeleteMessage,
    this.welcomeMessage,
  });

  @override
  ConsumerState<VirtualizedMessageList> createState() => _VirtualizedMessageListState();
}

class _VirtualizedMessageListState extends ConsumerState<VirtualizedMessageList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, double> _itemHeights = {};
  final GlobalKey _listKey = GlobalKey();
  
  /// 预估的消息高度
  static const double estimatedItemHeight = 120.0;
  
  /// 加载更多的触发距离
  static const double loadMoreThreshold = 200.0;
  
  /// 缓存的消息组件
  final Map<String, Widget> _cachedWidgets = {};
  
  /// 是否应该自动滚动到底部
  bool _shouldAutoScroll = true;
  
  /// 上次的消息数量
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _lastMessageCount = widget.messages.length;
  }

  @override
  void didUpdateWidget(VirtualizedMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检查是否有新消息
    if (widget.messages.length > _lastMessageCount) {
      _lastMessageCount = widget.messages.length;
      
      // 如果用户在底部，自动滚动到新消息
      if (_shouldAutoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatSettings = ref.watch(chatSettingsProvider);
    
    if (widget.messages.isEmpty && widget.welcomeMessage != null) {
      return _buildWelcomeMessage();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(
        controller: _scrollController,
        reverse: true, // 从底部开始显示
        slivers: [
          // 加载指示器
          if (widget.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          
          // 消息列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // 因为reverse=true，需要反转索引
                final messageIndex = widget.messages.length - 1 - index;
                final message = widget.messages[messageIndex];
                
                return _buildMessageItem(message, chatSettings);
              },
              childCount: widget.messages.length,
              findChildIndexCallback: (Key key) {
                // 优化查找性能
                if (key is ValueKey<String>) {
                  final messageId = key.value;
                  for (int i = 0; i < widget.messages.length; i++) {
                    if (widget.messages[i].id == messageId) {
                      return widget.messages.length - 1 - i; // 反转索引
                    }
                  }
                }
                return null;
              },
            ),
          ),
          
          // 加载更多指示器
          if (widget.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: widget.onLoadMore,
                    icon: const Icon(Icons.refresh),
                    label: const Text('加载更多消息'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(Message message, ChatSettings chatSettings) {
    // 使用缓存的组件（如果存在且设置未改变）
    final cacheKey = '${message.id}_${chatSettings.enableBlockView}';
    if (_cachedWidgets.containsKey(cacheKey)) {
      return _cachedWidgets[cacheKey]!;
    }

    final widget = RepaintBoundary(
      key: ValueKey(message.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: MessageViewAdapter(
          message: message,
          useBlockView: chatSettings.enableBlockView,
          onEdit: this.widget.onEditMessage != null 
            ? () => this.widget.onEditMessage!(message)
            : null,
          onRegenerate: this.widget.onRegenerateMessage != null
            ? () => this.widget.onRegenerateMessage!(message)
            : null,
          onDelete: this.widget.onDeleteMessage != null
            ? () => this.widget.onDeleteMessage!(message)
            : null,
        ),
      ),
    );

    // 缓存组件（限制缓存大小）
    if (_cachedWidgets.length > 50) {
      _cachedWidgets.clear();
    }
    _cachedWidgets[cacheKey] = widget;

    return widget;
  }

  /// 构建欢迎消息
  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              widget.welcomeMessage!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 处理滚动通知
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // 更新自动滚动状态
      final isAtBottom = _scrollController.position.pixels <= 100;
      if (_shouldAutoScroll != isAtBottom) {
        setState(() {
          _shouldAutoScroll = isAtBottom;
        });
      }
    }
    return false;
  }

  /// 滚动监听器
  void _onScroll() {
    // 检查是否需要加载更多
    if (widget.hasMore && 
        widget.onLoadMore != null && 
        !widget.isLoading &&
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - loadMoreThreshold) {
      widget.onLoadMore!();
    }
  }

  /// 滚动到底部
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    
    if (animated) {
      _scrollController.animateTo(
        0, // reverse=true时，0是底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  /// 滚动到指定消息
  void scrollToMessage(String messageId, {bool animated = true}) {
    final messageIndex = widget.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    // 计算滚动位置（这是一个简化的实现）
    final reversedIndex = widget.messages.length - 1 - messageIndex;
    final estimatedOffset = reversedIndex * estimatedItemHeight;

    if (animated) {
      _scrollController.animateTo(
        estimatedOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(estimatedOffset);
    }
  }
}

/// 消息列表性能监控器
class MessageListPerformanceMonitor {
  static final Map<String, DateTime> _renderTimes = {};
  static final Map<String, int> _renderCounts = {};

  /// 记录渲染开始
  static void startRender(String messageId) {
    _renderTimes[messageId] = DateTime.now();
  }

  /// 记录渲染结束
  static void endRender(String messageId) {
    final startTime = _renderTimes[messageId];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _renderCounts[messageId] = (_renderCounts[messageId] ?? 0) + 1;
      
      // 记录性能指标
      if (duration.inMilliseconds > 100) {
        debugPrint('Slow message render: $messageId took ${duration.inMilliseconds}ms');
      }
    }
  }

  /// 获取性能统计
  static Map<String, dynamic> getStats() {
    final totalRenders = _renderCounts.values.fold(0, (a, b) => a + b);
    final avgRenderTime = _renderTimes.isNotEmpty 
      ? _renderTimes.values.map((t) => DateTime.now().difference(t).inMilliseconds).reduce((a, b) => a + b) / _renderTimes.length
      : 0.0;

    return {
      'totalRenders': totalRenders,
      'avgRenderTime': avgRenderTime,
      'cachedMessages': _renderCounts.length,
    };
  }

  /// 清理统计数据
  static void clear() {
    _renderTimes.clear();
    _renderCounts.clear();
  }
}
