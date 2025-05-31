import 'package:flutter/material.dart';
import '../components/app_drawer.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
import '../models/conversation_ui_state.dart';
import '../data/fake_data.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  String selectedMenu = "ai_chat";
  String? selectedUserId;

  void _onChatClicked(String chatId) {
    setState(() {
      selectedMenu = chatId;
      selectedUserId = null;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  void _onProfileClicked(String userId) {
    setState(() {
      selectedUserId = userId;
      selectedMenu = "";
    });
    Navigator.of(context).pop(); // Close drawer
  }

  String _getAppBarTitle() {
    if (selectedUserId != null) {
      switch (selectedUserId) {
        case "current_user":
          return "个人资料";
        case "ai_assistant":
          return "AI助手资料";
        case "character_xiaomeng":
          return "小萌资料";
        default:
          return "个人资料";
      }
    }

    switch (selectedMenu) {
      case "ai_chat":
        return "AI助手";
      case "character_chat":
        return "角色聊天 - 小萌";
      case "developer_chat":
        return "开发者讨论";
      case "random_chat":
        return "随机聊天";
      default:
        return "AI助手";
    }
  }

  Widget _getCurrentScreen() {
    if (selectedUserId != null) {
      return ProfileScreen(userId: selectedUserId!);
    }

    final conversations = FakeData.fakeConversations;

    switch (selectedMenu) {
      case "ai_chat":
        return ChatScreen(
          conversationState: conversations.isNotEmpty
              ? conversations[0]
              : ConversationUiState(
                  id: 'default-ai',
                  channelName: "AI助手",
                  channelMembers: 1,
                  assistantId: 'assistant-general',
                ),
          showAppBar: false,
        );
      case "character_chat":
        return ChatScreen(
          conversationState: conversations.length > 1
              ? conversations[1]
              : ConversationUiState(
                  id: 'default-character',
                  channelName: "角色聊天 - 小萌",
                  channelMembers: 1,
                  assistantId: 'assistant-general',
                ),
          showAppBar: false,
        );
      case "developer_chat":
        return ChatScreen(
          conversationState: conversations.length > 2
              ? conversations[2]
              : ConversationUiState(
                  id: 'default-developer',
                  channelName: "开发者讨论",
                  channelMembers: 15,
                  assistantId: 'assistant-developer',
                ),
          showAppBar: false,
        );
      case "random_chat":
        return ChatScreen(
          conversationState: ConversationUiState(
            id: 'random-chat',
            channelName: "随机聊天",
            channelMembers: 8,
            assistantId: 'assistant-general',
          ),
          showAppBar: false,
        );
      default:
        return ChatScreen(
          conversationState: conversations.isNotEmpty
              ? conversations[0]
              : ConversationUiState(
                  id: 'default-ai',
                  channelName: "AI助手",
                  channelMembers: 1,
                  assistantId: 'assistant-general',
                ),
          showAppBar: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
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
        selectedMenu: selectedMenu,
        onChatClicked: _onChatClicked,
        onProfileClicked: _onProfileClicked,
      ),
      body: _getCurrentScreen(),
    );
  }
}
