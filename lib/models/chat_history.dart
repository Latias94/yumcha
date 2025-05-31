class ChatHistoryItem {
  final String id;
  final String title;
  final String preview;
  final DateTime timestamp;
  final String assistantType; // "ai", "character", "developer"
  final int messageCount;

  const ChatHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
    required this.assistantType,
    required this.messageCount,
  });
}

class ChatHistoryGroup {
  final String title;
  final List<ChatHistoryItem> items;

  const ChatHistoryGroup({required this.title, required this.items});
}

class AssistantType {
  final String id;
  final String name;
  final String icon;

  const AssistantType({
    required this.id,
    required this.name,
    required this.icon,
  });
}
