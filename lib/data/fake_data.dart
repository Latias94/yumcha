import '../models/message.dart';
import '../models/conversation_ui_state.dart';
import '../models/user_profile.dart';
import '../models/chat_history.dart';

// 表情符号常量
class Emojis {
  static const String pinkHeart = "💕";
  static const String melting = "🫠";
  static const String clouds = "😶‍🌫️";
  static const String flamingo = "🦩";
  static const String points = "👉";
  static const String robot = "🤖";
  static const String sparkles = "✨";
  static const String thinking = "🤔";
  static const String wave = "👋";
}

// 示例消息数据
final List<Message> initialAIMessages = [
  Message(
    author: "AI助手",
    content: "你好！我是你的AI助手${Emojis.wave}，有什么可以帮助你的吗？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isFromUser: false,
  ),
  Message(
    author: "用户",
    content: "你能帮我解释一下Flutter是什么吗？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    isFromUser: true,
  ),
  Message(
    author: "AI助手",
    content:
        "当然可以！${Emojis.sparkles} Flutter是Google开发的开源UI工具包，"
        "可以让开发者使用一套代码同时构建移动、Web和桌面应用。它使用Dart语言，"
        "具有热重载、丰富的组件库等特性。你想了解Flutter的哪个方面呢？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
    isFromUser: false,
  ),
  Message(
    author: "用户",
    content: "听起来很棒！那Flutter和React Native相比有什么优势吗？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    isFromUser: true,
  ),
  Message(
    author: "AI助手",
    content:
        "好问题！${Emojis.thinking} Flutter相比React Native的主要优势包括：\n\n"
        "1. **性能更好** - 直接编译为原生代码\n"
        "2. **一致性** - 在不同平台上渲染效果一致\n"
        "3. **热重载** - 开发效率更高\n"
        "4. **丰富的组件** - Material和Cupertino设计组件\n"
        "5. **单一代码库** - 真正的跨平台开发\n\n"
        "当然，React Native也有其优势，比如更大的社区和更多的第三方库。选择哪个主要取决于项目需求和团队技能。",
    timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
    isFromUser: false,
  ),
  Message(
    author: "用户",
    content: "谢谢解释！${Emojis.pinkHeart} 我准备开始学习Flutter了",
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    isFromUser: true,
  ),
  Message(
    author: "AI助手",
    content:
        "太棒了！${Emojis.sparkles} 建议你从Flutter官方文档开始，"
        "然后可以尝试一些简单的项目。如果在学习过程中遇到问题，随时可以问我！祝你学习愉快${Emojis.robot}",
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    isFromUser: false,
  ),
];

final List<Message> initialCharacterMessages = [
  Message(
    author: "小萌",
    content: "主人～${Emojis.wave} 小萌今天想和你聊聊天呢！有什么有趣的事情要分享吗？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    isFromUser: false,
  ),
  Message(
    author: "用户",
    content: "你好小萌！今天天气不错，你在做什么呢？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    isFromUser: true,
  ),
  Message(
    author: "小萌",
    content:
        "小萌在整理资料呢～${Emojis.sparkles} 发现了很多有趣的知识！"
        "比如说，你知道猫咪的胡须可以感知空气流动吗？这样它们就能在黑暗中导航了${Emojis.thinking}",
    timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
    isFromUser: false,
  ),
  Message(
    author: "用户",
    content: "哇，这个我还真不知道！小萌真聪明${Emojis.pinkHeart}",
    timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    isFromUser: true,
  ),
  Message(
    author: "小萌",
    content:
        "嘿嘿～谢谢主人夸奖${Emojis.melting} 小萌还知道很多小知识呢！"
        "要不要小萌给你讲个笑话？",
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isFromUser: false,
  ),
];

// 对话UI状态
final ConversationUiState aiChatState = ConversationUiState(
  channelName: "AI助手",
  channelMembers: 1,
  initialMessages: initialAIMessages,
);

final ConversationUiState characterChatState = ConversationUiState(
  channelName: "角色聊天 - 小萌",
  channelMembers: 1,
  initialMessages: initialCharacterMessages,
);

final ConversationUiState developerChatState = ConversationUiState(
  channelName: "开发者讨论",
  channelMembers: 15,
  initialMessages: [
    Message(
      author: "张小明",
      content: "大家好！有人用过Flutter的状态管理库Riverpod吗？",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isFromUser: false,
    ),
    Message(
      author: "李开发",
      content: "用过！Riverpod比Provider更现代化，推荐试试${Emojis.points}",
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      isFromUser: false,
    ),
    Message(
      author: "王程序员",
      content: "是的，Riverpod的编译时安全性很棒，而且支持自动销毁",
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      isFromUser: false,
    ),
    Message(
      author: "用户",
      content: "听起来不错！有推荐的学习资源吗？",
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isFromUser: true,
    ),
    Message(
      author: "张小明",
      content: "官方文档很详细，还有Andrea Bizzotto的YouTube教程系列很不错${Emojis.sparkles}",
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      isFromUser: false,
    ),
  ],
);

// 用户资料数据
final UserProfile currentUser = UserProfile(
  userId: "current_user",
  name: "用户 (你)",
  displayName: "用户",
  status: "在线",
  position: "Flutter开发者",
  description: "这是您的个人资料页面。您可以在这里查看和编辑您的信息。",
  avatarUrl: null,
);

final UserProfile aiAssistant = UserProfile(
  userId: "ai_assistant",
  name: "AI助手",
  displayName: "助手",
  status: "随时为您服务",
  position: "人工智能助手",
  description:
      "我是您的AI助手，可以帮助您解答问题、提供建议和进行有趣的对话。"
      "我使用先进的人工智能技术，致力于为您提供最好的服务体验。",
  avatarUrl: null,
);

final UserProfile characterXiaoMeng = UserProfile(
  userId: "character_xiaomeng",
  name: "小萌",
  displayName: "小萌",
  status: "活力满满",
  position: "AI角色助手",
  description:
      "我是小萌～一个活泼可爱的AI角色！喜欢和大家聊天，分享有趣的知识和故事。"
      "我会用萌萌的语气和你对话，希望能给你带来快乐${Emojis.pinkHeart}",
  avatarUrl: null,
);

// 聊天频道列表
final List<ChatChannel> chatChannels = [
  ChatChannel(
    id: "ai_chat",
    name: "AI助手",
    description: "与AI助手进行智能对话",
    memberCount: 1,
    unreadCount: 0,
    lastMessage: "太棒了！建议你从Flutter官方文档开始...",
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  ChatChannel(
    id: "character_chat",
    name: "角色聊天",
    description: "与AI角色进行有趣的对话",
    memberCount: 1,
    unreadCount: 2,
    lastMessage: "要不要小萌给你讲个笑话？",
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  ChatChannel(
    id: "developer_chat",
    name: "开发者讨论",
    description: "Flutter开发技术交流",
    memberCount: 15,
    unreadCount: 1,
    lastMessage: "官方文档很详细，还有Andrea Bizzotto的YouTube...",
    lastMessageTime: DateTime.now().subtract(
      const Duration(hours: 1, minutes: 40),
    ),
  ),
  ChatChannel(
    id: "random_chat",
    name: "随机聊天",
    description: "轻松愉快的日常话题",
    memberCount: 8,
    unreadCount: 0,
    lastMessage: "今天天气真不错！",
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

// 聊天频道数据模型
class ChatChannel {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final int unreadCount;
  final String lastMessage;
  final DateTime lastMessageTime;

  const ChatChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.unreadCount,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}

// 助手类型列表
const List<AssistantType> assistantTypes = [
  AssistantType(id: "ai", name: "AI助手", icon: "🤖"),
  AssistantType(id: "character", name: "小萌", icon: "😊"),
  AssistantType(id: "developer", name: "开发助手", icon: "💻"),
];

// 聊天历史记录
final List<ChatHistoryItem> chatHistory = [
  // 今天的记录
  ChatHistoryItem(
    id: "chat_001",
    title: "Flutter状态管理讨论",
    preview: "我们今天聊了关于Provider和Riverpod的区别...",
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    assistantType: "ai",
    messageCount: 15,
  ),
  ChatHistoryItem(
    id: "chat_002",
    title: "小萌的日常聊天",
    preview: "主人～今天过得怎么样呀？小萌想听你的故事...",
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    assistantType: "character",
    messageCount: 8,
  ),
  ChatHistoryItem(
    id: "chat_003",
    title: "代码优化建议",
    preview: "关于这段代码的性能优化，我觉得可以从以下几个方面...",
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    assistantType: "developer",
    messageCount: 12,
  ),

  // 昨天的记录
  ChatHistoryItem(
    id: "chat_004",
    title: "UI设计讨论",
    preview: "Material Design 3的新特性真的很棒，特别是动态颜色...",
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    assistantType: "ai",
    messageCount: 22,
  ),
  ChatHistoryItem(
    id: "chat_005",
    title: "小萌的睡前故事",
    preview: "主人要睡觉了吗？小萌给你讲个温馨的小故事吧...",
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    assistantType: "character",
    messageCount: 6,
  ),

  // 前天的记录
  ChatHistoryItem(
    id: "chat_006",
    title: "数据库设计方案",
    preview: "对于这个项目的数据库架构，我建议使用关系型数据库...",
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    assistantType: "developer",
    messageCount: 18,
  ),
  ChatHistoryItem(
    id: "chat_007",
    title: "学习计划制定",
    preview: "一个好的学习计划应该包含明确的目标和时间安排...",
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
    assistantType: "ai",
    messageCount: 25,
  ),

  // 上周的记录
  ChatHistoryItem(
    id: "chat_008",
    title: "小萌的游戏时间",
    preview: "主人想和小萌一起玩游戏吗？我们可以玩文字游戏...",
    timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
    assistantType: "character",
    messageCount: 14,
  ),
  ChatHistoryItem(
    id: "chat_009",
    title: "API设计最佳实践",
    preview: "RESTful API的设计需要考虑资源的合理划分和HTTP方法的正确使用...",
    timestamp: DateTime.now().subtract(const Duration(days: 6, hours: 7)),
    assistantType: "developer",
    messageCount: 31,
  ),
];

// 按天分组聊天历史
List<ChatHistoryGroup> getChatHistoryGroups([String? assistantFilter]) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final thisWeek = today.subtract(const Duration(days: 7));

  // 过滤助手类型
  final filteredHistory = assistantFilter != null
      ? chatHistory
            .where((item) => item.assistantType == assistantFilter)
            .toList()
      : chatHistory;

  final groups = <ChatHistoryGroup>[];

  // 今天
  final todayItems = filteredHistory.where((item) {
    final itemDate = DateTime(
      item.timestamp.year,
      item.timestamp.month,
      item.timestamp.day,
    );
    return itemDate.isAtSameMomentAs(today);
  }).toList();

  if (todayItems.isNotEmpty) {
    groups.add(ChatHistoryGroup(title: "今天", items: todayItems));
  }

  // 昨天
  final yesterdayItems = filteredHistory.where((item) {
    final itemDate = DateTime(
      item.timestamp.year,
      item.timestamp.month,
      item.timestamp.day,
    );
    return itemDate.isAtSameMomentAs(yesterday);
  }).toList();

  if (yesterdayItems.isNotEmpty) {
    groups.add(ChatHistoryGroup(title: "昨天", items: yesterdayItems));
  }

  // 本周
  final thisWeekItems = filteredHistory.where((item) {
    final itemDate = DateTime(
      item.timestamp.year,
      item.timestamp.month,
      item.timestamp.day,
    );
    return itemDate.isBefore(yesterday) && itemDate.isAfter(thisWeek);
  }).toList();

  if (thisWeekItems.isNotEmpty) {
    groups.add(ChatHistoryGroup(title: "本周", items: thisWeekItems));
  }

  // 更早
  final earlierItems = filteredHistory.where((item) {
    final itemDate = DateTime(
      item.timestamp.year,
      item.timestamp.month,
      item.timestamp.day,
    );
    return itemDate.isBefore(thisWeek);
  }).toList();

  if (earlierItems.isNotEmpty) {
    groups.add(ChatHistoryGroup(title: "更早", items: earlierItems));
  }

  return groups;
}
