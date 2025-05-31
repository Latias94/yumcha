import 'package:flutter/material.dart';
import '../models/conversation_ui_state.dart';
import '../models/message.dart';
import '../components/message_bubble.dart';
import '../components/chat_input.dart';
import '../data/fake_data.dart';

class ChatScreen extends StatefulWidget {
  final ConversationUiState conversationState;
  final bool showAppBar;

  const ChatScreen({
    super.key,
    required this.conversationState,
    this.showAppBar = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ConversationUiState _conversationState;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _conversationState = widget.conversationState;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final message = Message(
      author: "用户",
      content: content,
      timestamp: DateTime.now(),
      isFromUser: true,
    );

    setState(() {
      _conversationState = _conversationState.addMessage(message);
    });

    // Auto scroll to bottom
    _scrollToBottom();

    // Simulate AI response after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _addAIResponse(content);
    });
  }

  void _addAIResponse(String userMessage) {
    String aiResponse;
    String aiAuthor;

    // Determine response based on channel name
    if (_conversationState.channelName.contains("小萌")) {
      aiAuthor = "小萌";
      aiResponse = _getCharacterResponse(userMessage);
    } else if (_conversationState.channelName.contains("开发者")) {
      aiAuthor = "张小明";
      aiResponse = _getDeveloperResponse(userMessage);
    } else {
      aiAuthor = "AI助手";
      aiResponse = _getAIResponse(userMessage);
    }

    final aiMessage = Message(
      author: aiAuthor,
      content: aiResponse,
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    setState(() {
      _conversationState = _conversationState.addMessage(aiMessage);
    });

    _scrollToBottom();
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains("你好") ||
        message.contains("hello") ||
        message.contains("hi")) {
      return "你好！${Emojis.wave} 我是你的AI助手，有什么可以帮助你的吗？";
    } else if (message.contains("再见") || message.contains("bye")) {
      return "再见！${Emojis.wave} 很高兴为你服务，有需要随时找我。";
    } else if (message.contains("flutter")) {
      return "Flutter是Google开发的优秀UI框架！${Emojis.sparkles} 它可以让你用一套代码构建多平台应用。你想了解Flutter的哪个方面呢？";
    } else if (message.contains("编程") ||
        message.contains("代码") ||
        message.contains("开发")) {
      return "编程是一门很有趣的技能！${Emojis.thinking} 我可以帮你解答各种编程问题，从基础概念到高级技巧都可以。你遇到什么具体问题了吗？";
    } else if (message.contains("谢谢") || message.contains("感谢")) {
      return "不客气！${Emojis.pinkHeart} 我很乐意帮助你。还有其他问题吗？";
    } else {
      return "我理解了你说的「${userMessage}」。${Emojis.thinking} 这是一个很有趣的话题！让我想想如何更好地帮助你...";
    }
  }

  String _getCharacterResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains("你好") ||
        message.contains("hello") ||
        message.contains("hi")) {
      return "主人～${Emojis.wave} 小萌很高兴见到你呢！今天过得怎么样呀？";
    } else if (message.contains("再见") || message.contains("bye")) {
      return "主人要走了吗？${Emojis.melting} 小萌会想你的～记得常来找小萌聊天哦！";
    } else if (message.contains("可爱") || message.contains("萌")) {
      return "嘿嘿～主人夸小萌可爱呢！${Emojis.pinkHeart} 小萌超开心的！主人也很棒哦～";
    } else if (message.contains("笑话")) {
      return "好哦！小萌来讲个笑话～${Emojis.sparkles}\n\n为什么程序员喜欢黑暗？\n\n因为光明会带来bug！${Emojis.thinking} 怎么样，好笑吗？";
    } else if (message.contains("知识") || message.contains("学习")) {
      return "小萌最喜欢分享知识了！${Emojis.sparkles} 你知道吗？蜂鸟是唯一能够倒着飞的鸟类呢～还想听其他有趣的知识吗？";
    } else {
      return "哇～主人说的是「${userMessage}」呢！${Emojis.thinking} 小萌觉得好有趣！要不要小萌给你讲个相关的小故事呀？";
    }
  }

  String _getDeveloperResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains("flutter") || message.contains("dart")) {
      return "Flutter开发的话，我推荐先掌握Dart基础，然后学习Widget系统。${Emojis.points} 有什么具体问题吗？";
    } else if (message.contains("状态管理")) {
      return "状态管理确实是Flutter的重点！现在比较流行的有Provider、Riverpod、Bloc等。${Emojis.sparkles} 你倾向于哪种？";
    } else if (message.contains("问题") || message.contains("bug")) {
      return "遇到技术问题很正常，关键是要善于调试。${Emojis.thinking} 可以详细描述下你的问题吗？我们一起看看。";
    } else {
      return "嗯，关于「${userMessage}」这个话题，在开发中确实会遇到。${Emojis.points} 大家有什么经验可以分享的吗？";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_conversationState.channelName),
                  Text(
                    "${_conversationState.channelMembers} 成员",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: _conversationState.messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _conversationState.messages.length,
                    itemBuilder: (context, index) {
                      final message = _conversationState.messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          ChatInput(onSendMessage: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            "开始对话吧！",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "发送消息开始与AI助手的对话",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
