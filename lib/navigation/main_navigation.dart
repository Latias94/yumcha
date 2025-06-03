import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/app_drawer.dart';
import '../screens/chat_screen.dart';
import '../providers/conversation_notifier.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(currentConversationProvider);
    final conversationNotifier = ref.read(currentConversationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(conversationState)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              conversationNotifier.createNewConversation();
            },
            tooltip: '新对话',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedMenu: conversationState.selectedMenu,
        onChatClicked: (chatId) {
          print('MainNavigation 收到点击事件: $chatId'); // 调试信息
          conversationNotifier.switchToConversation(chatId);
          Navigator.of(context).pop(); // Close drawer
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
      );
    }

    // 没有对话时显示加载状态
    return const Center(child: Text('正在初始化...'));
  }
}
