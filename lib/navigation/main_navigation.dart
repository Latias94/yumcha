import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/app_drawer.dart';
import '../screens/chat_screen.dart';
import '../providers/conversation_notifier.dart';
import '../services/logger_service.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({
    super.key,
    this.initialConversationId,
    this.initialMessageId,
  });

  final String? initialConversationId;
  final String? initialMessageId;

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  static final LoggerService _logger = LoggerService();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    _logger.info('MainNavigation initState 被调用', {
      'initialConversationId': widget.initialConversationId,
      'initialMessageId': widget.initialMessageId,
    });

    // 如果有初始对话ID，在下一帧开始加载
    if (widget.initialConversationId != null) {
      _logger.info('MainNavigation初始化，准备加载对话', {
        'conversationId': widget.initialConversationId,
        'messageId': widget.initialMessageId,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasInitialized) {
          _logger.info('开始加载初始对话', {
            'conversationId': widget.initialConversationId,
          });
          final conversationNotifier = ref.read(
            currentConversationProvider.notifier,
          );
          conversationNotifier.switchToConversation(
            widget.initialConversationId!,
          );
          setState(() {
            _hasInitialized = true;
          });
        }
      });
    } else {
      _logger.info('MainNavigation 没有初始对话ID，将显示默认状态');
    }
  }

  /// 创建新聊天并导航到新页面
  void _createNewChatWithAnimation(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(currentConversationProvider.notifier);

    // 先创建新对话
    await notifier.createNewConversation();

    // 检查 context 是否仍然有效
    if (!context.mounted) return;

    // 使用 pushReplacement 替换当前页面
    // 使用默认的页面转场动画
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(currentConversationProvider);
    final conversationNotifier = ref.read(currentConversationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(conversationState)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _createNewChatWithAnimation(context, ref);
            },
            tooltip: '新对话',
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedMenu: conversationState.selectedMenu,
        onChatClicked: (chatId) {
          _logger.debug('MainNavigation 收到点击事件', {'chatId': chatId});
          // 防止在加载状态时重复点击
          if (!conversationState.isLoading) {
            conversationNotifier.switchToConversation(chatId);
            Navigator.of(context).pop(); // Close drawer
          }
        },
        onProfileClicked: (String userId) {}, // 移除profile功能，保留空实现避免错误
      ),
      body: _getCurrentScreen(conversationState, conversationNotifier),
    );
  }

  String _getAppBarTitle(CurrentConversationState state) {
    if (state.conversation != null) {
      return state.conversation!.channelName;
    }
    return "聊天";
  }

  Widget _getCurrentScreen(
    CurrentConversationState state,
    CurrentConversationNotifier notifier,
  ) {
    // 如果正在加载
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载...'),
          ],
        ),
      );
    }

    // 如果有错误
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                notifier.clearError();
                notifier.createNewConversation();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 显示当前对话
    if (state.conversation != null) {
      return ChatScreen(
        conversationState: state.conversation!,
        showAppBar: false,
        onAssistantConfigChanged: notifier.onAssistantConfigChanged,
        onConversationUpdated: notifier.updateConversation,
        initialMessageId: widget.initialMessageId,
      );
    }

    // 没有对话时显示加载状态
    return const Center(child: Text('正在初始化...'));
  }
}
