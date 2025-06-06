// import '../models/message.dart';
// import '../models/conversation_ui_state.dart';
// import '../models/user_profile.dart';
// import '../models/chat_history.dart';

// // 表情符号常量
// class Emojis {
//   static const String wave = "👋";
//   static const String sparkles = "✨";
//   static const String thinking = "🤔";
//   static const String pinkHeart = "💖";
//   static const String melting = "🫠";
//   static const String points = "👉";
// }

// // 示例消息数据
// final List<Message> initialAIMessages = [
//   Message(
//     author: "AI助手",
//     content: "你好！我是你的AI助手${Emojis.wave}，有什么可以帮助你的吗？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
//     isFromUser: false,
//   ),
//   Message(
//     author: "用户",
//     content: "你能帮我解释一下Flutter是什么吗？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
//     isFromUser: true,
//   ),
//   Message(
//     author: "AI助手",
//     content:
//         "当然可以！${Emojis.sparkles} Flutter是Google开发的开源UI工具包，"
//         "可以让开发者使用一套代码同时构建移动、Web和桌面应用。它使用Dart语言，"
//         "具有热重载、丰富的组件库等特性。你想了解Flutter的哪个方面呢？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
//     isFromUser: false,
//   ),
//   Message(
//     author: "用户",
//     content: "听起来很棒！那Flutter和React Native相比有什么优势吗？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
//     isFromUser: true,
//   ),
//   Message(
//     author: "AI助手",
//     content:
//         "好问题！${Emojis.thinking} Flutter相比React Native的主要优势包括：\n\n"
//         "1. **性能更好** - 直接编译为原生代码\n"
//         "2. **一致性** - 在不同平台上渲染效果一致\n"
//         "3. **热重载** - 开发效率更高\n"
//         "4. **丰富的组件** - Material和Cupertino设计组件\n"
//         "5. **单一代码库** - 真正的跨平台开发\n\n"
//         "当然，React Native也有其优势，比如更大的社区和更多的第三方库。选择哪个主要取决于项目需求和团队技能。",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
//     isFromUser: false,
//   ),
//   Message(
//     author: "用户",
//     content: "谢谢解释！${Emojis.pinkHeart} 我准备开始学习Flutter了",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
//     isFromUser: true,
//   ),
//   Message(
//     author: "AI助手",
//     content:
//         "太棒了！${Emojis.sparkles} 建议你从Flutter官方文档开始，"
//         "然后可以尝试一些简单的项目。如果在学习过程中遇到问题，随时可以问我！祝你学习愉快${Emojis.wave}",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
//     isFromUser: false,
//   ),
// ];

// final List<Message> initialCharacterMessages = [
//   Message(
//     author: "小萌",
//     content: "主人～${Emojis.wave} 小萌今天想和你聊聊天呢！有什么有趣的事情要分享吗？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
//     isFromUser: false,
//   ),
//   Message(
//     author: "用户",
//     content: "你好小萌！今天天气不错，你在做什么呢？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
//     isFromUser: true,
//   ),
//   Message(
//     author: "小萌",
//     content:
//         "小萌在整理资料呢～${Emojis.sparkles} 发现了很多有趣的知识！"
//         "比如说，你知道猫咪的胡须可以感知空气流动吗？这样它们就能在黑暗中导航了${Emojis.thinking}",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
//     isFromUser: false,
//   ),
//   Message(
//     author: "用户",
//     content: "哇，这个我还真不知道！小萌真聪明${Emojis.pinkHeart}",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
//     isFromUser: true,
//   ),
//   Message(
//     author: "小萌",
//     content:
//         "嘿嘿～谢谢主人夸奖${Emojis.melting} 小萌还知道很多小知识呢！"
//         "要不要小萌给你讲个笑话？",
//     timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
//     isFromUser: false,
//   ),
// ];

// // 对话UI状态
// final ConversationUiState aiChatState = ConversationUiState(
//   id: 'conv-1',
//   channelName: "小萌的AI聊天室",
//   channelMembers: 1,
//   messages: [
//     Message(
//       author: "小萌",
//       content: "主人～${Emojis.wave} 小萌很高兴见到你呢！今天过得怎么样呀？",
//       timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
//       isFromUser: false,
//     ),
//     Message(
//       author: "用户",
//       content: "你好小萌！今天工作有点累，想找你聊聊天",
//       timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
//       isFromUser: true,
//     ),
//   ],
//   assistantId: 'assistant-general', // 关联到通用助手
//   selectedProviderId: 'openai-default',
// );

// final ConversationUiState characterChatState = ConversationUiState(
//   id: 'conv-2',
//   channelName: "开发者社区",
//   channelMembers: 3,
//   messages: [
//     Message(
//       author: "张小明",
//       content:
//           "Flutter开发的话，我推荐先掌握Dart基础，然后学习Widget系统。${Emojis.points} 有什么具体问题吗？",
//       timestamp: DateTime.now().subtract(const Duration(hours: 1)),
//       isFromUser: false,
//     ),
//   ],
//   assistantId: 'assistant-developer', // 关联到开发助手
//   selectedProviderId: 'openai-default',
// );

// final ConversationUiState developerChatState = ConversationUiState(
//   id: 'conv-3',
//   channelName: "AI助手",
//   channelMembers: 1,
//   messages: [],
//   assistantId: 'assistant-general',
//   selectedProviderId: 'openai-default',
// );

// // 用户资料数据
// final UserProfile currentUser = UserProfile(
//   userId: "current_user",
//   name: "用户 (你)",
//   displayName: "用户",
//   status: "在线",
//   position: "Flutter开发者",
//   description: "这是您的个人资料页面。您可以在这里查看和编辑您的信息。",
//   avatarUrl: null,
// );

// final UserProfile aiAssistant = UserProfile(
//   userId: "ai_assistant",
//   name: "AI助手",
//   displayName: "助手",
//   status: "随时为您服务",
//   position: "人工智能助手",
//   description:
//       "我是您的AI助手，可以帮助您解答问题、提供建议和进行有趣的对话。"
//       "我使用先进的人工智能技术，致力于为您提供最好的服务体验。",
//   avatarUrl: null,
// );

// final UserProfile characterXiaoMeng = UserProfile(
//   userId: "character_xiaomeng",
//   name: "小萌",
//   displayName: "小萌",
//   status: "活力满满",
//   position: "AI角色助手",
//   description:
//       "我是小萌～一个活泼可爱的AI角色！喜欢和大家聊天，分享有趣的知识和故事。"
//       "我会用萌萌的语气和你对话，希望能给你带来快乐${Emojis.pinkHeart}",
//   avatarUrl: null,
// );

// // 聊天频道列表
// final List<ChatChannel> chatChannels = [
//   ChatChannel(
//     id: "ai_chat",
//     name: "AI助手",
//     description: "与AI助手进行智能对话",
//     memberCount: 1,
//     unreadCount: 0,
//     lastMessage: "太棒了！建议你从Flutter官方文档开始...",
//     lastMessageTime: DateTime.now().subtract(const Duration(minutes: 8)),
//   ),
//   ChatChannel(
//     id: "character_chat",
//     name: "角色聊天",
//     description: "与AI角色进行有趣的对话",
//     memberCount: 1,
//     unreadCount: 2,
//     lastMessage: "要不要小萌给你讲个笑话？",
//     lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
//   ),
//   ChatChannel(
//     id: "developer_chat",
//     name: "开发者讨论",
//     description: "Flutter开发技术交流",
//     memberCount: 15,
//     unreadCount: 1,
//     lastMessage: "官方文档很详细，还有Andrea Bizzotto的YouTube...",
//     lastMessageTime: DateTime.now().subtract(
//       const Duration(hours: 1, minutes: 40),
//     ),
//   ),
//   ChatChannel(
//     id: "random_chat",
//     name: "随机聊天",
//     description: "轻松愉快的日常话题",
//     memberCount: 8,
//     unreadCount: 0,
//     lastMessage: "今天天气真不错！",
//     lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
//   ),
// ];

// // 聊天频道数据模型
// class ChatChannel {
//   final String id;
//   final String name;
//   final String description;
//   final int memberCount;
//   final int unreadCount;
//   final String lastMessage;
//   final DateTime lastMessageTime;

//   const ChatChannel({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.memberCount,
//     required this.unreadCount,
//     required this.lastMessage,
//     required this.lastMessageTime,
//   });
// }

// // 助手类型列表
// const List<AssistantType> assistantTypes = [
//   AssistantType(id: "ai", name: "AI助手", icon: "🤖"),
//   AssistantType(id: "character", name: "小萌", icon: "😊"),
//   AssistantType(id: "developer", name: "开发助手", icon: "💻"),
// ];

// // 聊天历史记录
// final List<ChatHistoryItem> chatHistory = [
//   // 今天的记录
//   ChatHistoryItem(
//     id: "chat-1",
//     title: "Flutter开发问题讨论",
//     preview: "关于状态管理的最佳实践...",
//     timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//     assistantType: "developer",
//     messageCount: 15,
//   ),
//   ChatHistoryItem(
//     id: "chat-2",
//     title: "小萌的日常聊天",
//     preview: "主人今天心情怎么样呀～",
//     timestamp: DateTime.now().subtract(const Duration(hours: 4)),
//     assistantType: "character",
//     messageCount: 8,
//   ),

//   // 昨天的记录
//   ChatHistoryItem(
//     id: "chat-3",
//     title: "创意写作助手",
//     preview: "让我帮你写一个有趣的故事...",
//     timestamp: DateTime.now().subtract(const Duration(days: 1)),
//     assistantType: "creative",
//     messageCount: 23,
//   ),
//   ChatHistoryItem(
//     id: "chat-4",
//     title: "技术答疑",
//     preview: "关于算法优化的建议",
//     timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
//     assistantType: "ai",
//     messageCount: 12,
//   ),

//   // 前天的记录
//   ChatHistoryItem(
//     id: "chat-5",
//     title: "数据分析讨论",
//     preview: "这个数据趋势很有意思...",
//     timestamp: DateTime.now().subtract(const Duration(days: 3)),
//     assistantType: "analyst",
//     messageCount: 7,
//   ),
//   ChatHistoryItem(
//     id: "chat-6",
//     title: "语言学习",
//     preview: "今天我们来学习一些新单词",
//     timestamp: DateTime.now().subtract(const Duration(days: 4)),
//     assistantType: "teacher",
//     messageCount: 18,
//   ),
// ];

// // 按天分组聊天历史
// List<ChatHistoryGroup> getChatHistoryGroups([String? assistantFilter]) {
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   final yesterday = today.subtract(const Duration(days: 1));
//   final thisWeek = today.subtract(const Duration(days: 7));

//   // 过滤助手类型
//   final filteredHistory = assistantFilter != null
//       ? chatHistory
//             .where((item) => item.assistantType == assistantFilter)
//             .toList()
//       : chatHistory;

//   final groups = <ChatHistoryGroup>[];

//   // 今天
//   final todayItems = filteredHistory.where((item) {
//     final itemDate = DateTime(
//       item.timestamp.year,
//       item.timestamp.month,
//       item.timestamp.day,
//     );
//     return itemDate.isAtSameMomentAs(today);
//   }).toList();

//   if (todayItems.isNotEmpty) {
//     groups.add(ChatHistoryGroup(title: "今天", items: todayItems));
//   }

//   // 昨天
//   final yesterdayItems = filteredHistory.where((item) {
//     final itemDate = DateTime(
//       item.timestamp.year,
//       item.timestamp.month,
//       item.timestamp.day,
//     );
//     return itemDate.isAtSameMomentAs(yesterday);
//   }).toList();

//   if (yesterdayItems.isNotEmpty) {
//     groups.add(ChatHistoryGroup(title: "昨天", items: yesterdayItems));
//   }

//   // 本周
//   final thisWeekItems = filteredHistory.where((item) {
//     final itemDate = DateTime(
//       item.timestamp.year,
//       item.timestamp.month,
//       item.timestamp.day,
//     );
//     return itemDate.isBefore(yesterday) && itemDate.isAfter(thisWeek);
//   }).toList();

//   if (thisWeekItems.isNotEmpty) {
//     groups.add(ChatHistoryGroup(title: "本周", items: thisWeekItems));
//   }

//   // 更早
//   final earlierItems = filteredHistory.where((item) {
//     final itemDate = DateTime(
//       item.timestamp.year,
//       item.timestamp.month,
//       item.timestamp.day,
//     );
//     return itemDate.isBefore(thisWeek);
//   }).toList();

//   if (earlierItems.isNotEmpty) {
//     groups.add(ChatHistoryGroup(title: "更早", items: earlierItems));
//   }

//   return groups;
// }

// class FakeData {
//   static List<ConversationUiState> get fakeConversations => [
//     ConversationUiState(
//       id: 'conv-1',
//       channelName: "小萌的AI聊天室",
//       channelMembers: 1,
//       messages: [
//         Message(
//           author: "小萌",
//           content: "主人～${Emojis.wave} 小萌很高兴见到你呢！今天过得怎么样呀？",
//           timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
//           isFromUser: false,
//         ),
//         Message(
//           author: "用户",
//           content: "你好小萌！今天工作有点累，想找你聊聊天",
//           timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
//           isFromUser: true,
//         ),
//       ],
//       assistantId: 'assistant-general', // 关联到通用助手
//       selectedProviderId: 'openai-default',
//     ),
//     ConversationUiState(
//       id: 'conv-2',
//       channelName: "开发者社区",
//       channelMembers: 3,
//       messages: [
//         Message(
//           author: "张小明",
//           content:
//               "Flutter开发的话，我推荐先掌握Dart基础，然后学习Widget系统。${Emojis.points} 有什么具体问题吗？",
//           timestamp: DateTime.now().subtract(const Duration(hours: 1)),
//           isFromUser: false,
//         ),
//       ],
//       assistantId: 'assistant-developer', // 关联到开发助手
//       selectedProviderId: 'openai-default',
//     ),
//     ConversationUiState(
//       id: 'conv-3',
//       channelName: "AI助手",
//       channelMembers: 1,
//       messages: [],
//       assistantId: 'assistant-general',
//       selectedProviderId: 'openai-default',
//     ),
//   ];

//   static List<ChatHistoryGroup> get fakeChatHistory => [
//     ChatHistoryGroup(
//       title: "今天",
//       items: [
//         ChatHistoryItem(
//           id: "chat-1",
//           title: "Flutter开发问题讨论",
//           preview: "关于状态管理的最佳实践...",
//           timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//           assistantType: "developer",
//           messageCount: 15,
//         ),
//         ChatHistoryItem(
//           id: "chat-2",
//           title: "小萌的日常聊天",
//           preview: "主人今天心情怎么样呀～",
//           timestamp: DateTime.now().subtract(const Duration(hours: 4)),
//           assistantType: "character",
//           messageCount: 8,
//         ),
//       ],
//     ),
//     ChatHistoryGroup(
//       title: "昨天",
//       items: [
//         ChatHistoryItem(
//           id: "chat-3",
//           title: "创意写作助手",
//           preview: "让我帮你写一个有趣的故事...",
//           timestamp: DateTime.now().subtract(const Duration(days: 1)),
//           assistantType: "creative",
//           messageCount: 23,
//         ),
//         ChatHistoryItem(
//           id: "chat-4",
//           title: "技术答疑",
//           preview: "关于算法优化的建议",
//           timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
//           assistantType: "ai",
//           messageCount: 12,
//         ),
//       ],
//     ),
//     ChatHistoryGroup(
//       title: "本周早些时候",
//       items: [
//         ChatHistoryItem(
//           id: "chat-5",
//           title: "数据分析讨论",
//           preview: "这个数据趋势很有意思...",
//           timestamp: DateTime.now().subtract(const Duration(days: 3)),
//           assistantType: "analyst",
//           messageCount: 7,
//         ),
//         ChatHistoryItem(
//           id: "chat-6",
//           title: "语言学习",
//           preview: "今天我们来学习一些新单词",
//           timestamp: DateTime.now().subtract(const Duration(days: 4)),
//           assistantType: "teacher",
//           messageCount: 18,
//         ),
//       ],
//     ),
//   ];

//   static List<AssistantType> get availableAssistants => [
//     AssistantType(id: "general", name: "通用助手", icon: "🤖"),
//     AssistantType(id: "developer", name: "开发助手", icon: "👨‍💻"),
//     AssistantType(id: "creative", name: "创意助手", icon: "🎨"),
//     AssistantType(id: "analyst", name: "分析助手", icon: "📊"),
//     AssistantType(id: "translator", name: "翻译助手", icon: "🌍"),
//     AssistantType(id: "teacher", name: "教学助手", icon: "👩‍🏫"),
//   ];
// }
