# YumCha 新架构使用指南

## 快速开始

### 1. 导入核心Provider
```dart
import 'package:yumcha/core/providers/core_providers.dart';
```

### 2. 在Widget中使用状态
```dart
class ChatScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听聊天状态
    final chatState = ref.watch(chatStateProvider);
    final currentConversation = ref.watch(currentConversationProvider);
    
    // 监听设置状态
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentAssistant = ref.watch(currentAssistantProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(currentConversation?.title ?? 'New Chat'),
        actions: [
          // 搜索按钮
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => ref.read(searchStateProvider.notifier).toggleSearch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: MessageListWidget(),
          ),
          // 输入框
          MessageInputWidget(),
        ],
      ),
    );
  }
}
```

### 3. 执行操作
```dart
class MessageActions {
  static Future<void> sendMessage(WidgetRef ref, String content) async {
    final chatNotifier = ref.read(chatStateProvider.notifier);
    await chatNotifier.sendMessage(content);
  }
  
  static Future<void> editMessage(WidgetRef ref, String messageId, String newContent) async {
    final operationNotifier = ref.read(messageOperationStateProvider.notifier);
    await operationNotifier.editMessage(messageId, newContent);
  }
  
  static Future<void> deleteMessage(WidgetRef ref, String messageId) async {
    final operationNotifier = ref.read(messageOperationStateProvider.notifier);
    await operationNotifier.deleteMessage(messageId);
  }
}
```

## 核心概念

### 状态管理层次
```
CoreState (根状态)
├── ChatState (聊天状态)
│   ├── conversations (对话列表)
│   ├── currentConversation (当前对话)
│   ├── messages (消息列表)
│   └── status (聊天状态)
├── StreamingState (流式状态)
│   ├── activeStreams (活跃流)
│   ├── streamingMessages (流式消息)
│   └── toolCalls (工具调用)
├── MessageOperationState (消息操作状态)
│   ├── editingMessages (编辑中的消息)
│   ├── deletingMessages (删除中的消息)
│   └── operationHistory (操作历史)
├── SearchState (搜索状态)
│   ├── query (搜索查询)
│   ├── results (搜索结果)
│   └── options (搜索选项)
├── SettingsState (设置状态)
│   ├── theme (主题设置)
│   ├── language (语言设置)
│   └── behavior (行为设置)
└── AssistantState (助手状态)
    ├── assistants (助手列表)
    ├── selectedAssistant (选中助手)
    └── models (可用模型)
```

### Provider类型说明

#### StateNotifierProvider
用于可变状态管理，提供状态修改方法：
```dart
final chatStateProvider = StateNotifierProvider<ChatStateNotifier, ChatState>(...);

// 使用
final chatState = ref.watch(chatStateProvider);
final chatNotifier = ref.read(chatStateProvider.notifier);
```

#### Provider
用于只读状态和计算属性：
```dart
final currentConversationProvider = Provider<Conversation?>((ref) {
  return ref.watch(chatStateProvider.select((state) => state.currentConversation));
});
```

#### Provider.family
用于参数化的状态访问：
```dart
final messageByIdProvider = Provider.family<Message?, String>((ref, messageId) {
  return ref.watch(chatStateProvider.select((state) => 
    state.messages.where((m) => m.id == messageId).firstOrNull));
});
```

## 常用操作示例

### 聊天操作
```dart
// 发送消息
await ref.read(chatStateProvider.notifier).sendMessage('Hello!');

// 创建新对话
await ref.read(chatStateProvider.notifier).createConversation();

// 切换对话
await ref.read(chatStateProvider.notifier).switchConversation(conversationId);

// 删除对话
await ref.read(chatStateProvider.notifier).deleteConversation(conversationId);
```

### 消息操作
```dart
// 编辑消息
await ref.read(messageOperationStateProvider.notifier).editMessage(messageId, newContent);

// 删除消息
await ref.read(messageOperationStateProvider.notifier).deleteMessage(messageId);

// 复制消息
await ref.read(messageOperationStateProvider.notifier).copyMessage(messageId);

// 重新生成消息
await ref.read(messageOperationStateProvider.notifier).regenerateMessage(messageId);

// 批量删除
await ref.read(messageOperationStateProvider.notifier).batchDeleteMessages(messageIds);
```

### 搜索操作
```dart
// 开始搜索
ref.read(searchStateProvider.notifier).startSearch('search query');

// 设置搜索选项
ref.read(searchStateProvider.notifier).setSearchOptions(
  caseSensitive: true,
  useRegex: false,
  searchInConversations: true,
);

// 导航到下一个结果
ref.read(searchStateProvider.notifier).nextResult();

// 清除搜索
ref.read(searchStateProvider.notifier).clearSearch();
```

### 设置操作
```dart
// 切换主题
await ref.read(settingsStateProvider.notifier).setThemeMode(ThemeMode.dark);

// 设置语言
await ref.read(settingsStateProvider.notifier).setLanguageCode('zh-CN');

// 设置默认模型
await ref.read(settingsStateProvider.notifier).setDefaultChatModel('gpt-4');

// 启用功能
await ref.read(settingsStateProvider.notifier).setFeatureFlag('experimental_feature', true);
```

### 助手操作
```dart
// 选择助手
await ref.read(assistantStateProvider.notifier).selectAssistant(assistantId);

// 创建助手
final assistant = await ref.read(assistantStateProvider.notifier).createAssistant(
  name: 'My Assistant',
  systemPrompt: 'You are a helpful assistant',
  description: 'Custom assistant for specific tasks',
);

// 更新助手
await ref.read(assistantStateProvider.notifier).updateAssistant(updatedAssistant);

// 切换收藏
await ref.read(assistantStateProvider.notifier).toggleFavorite(assistantId);
```

## 状态监听和响应

### 监听状态变化
```dart
ref.listen<ChatState>(chatStateProvider, (previous, next) {
  if (next.status == ChatStatus.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat error: ${next.error}')),
    );
  }
});
```

### 条件性监听
```dart
ref.listen<bool>(
  chatStateProvider.select((state) => state.isLoading),
  (previous, isLoading) {
    if (isLoading) {
      showLoadingDialog();
    } else {
      hideLoadingDialog();
    }
  },
);
```

## 错误处理

### 全局错误处理
```dart
class ErrorHandler {
  static void handleChatError(WidgetRef ref, String error) {
    ref.read(chatStateProvider.notifier).clearError();
    // 显示错误消息
    showErrorSnackBar(error);
  }
  
  static void handleOperationError(WidgetRef ref, String messageId, String error) {
    ref.read(messageOperationStateProvider.notifier).clearOperationError(messageId);
    // 显示操作错误
    showOperationErrorDialog(error);
  }
}
```

### 重试机制
```dart
Future<void> retryOperation(WidgetRef ref, VoidCallback operation) async {
  int retryCount = 0;
  const maxRetries = 3;
  
  while (retryCount < maxRetries) {
    try {
      await operation();
      break;
    } catch (error) {
      retryCount++;
      if (retryCount >= maxRetries) {
        ErrorHandler.handleChatError(ref, error.toString());
      } else {
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }
}
```

## 性能优化

### 细粒度状态订阅
```dart
// 好的做法：只订阅需要的状态片段
final isLoading = ref.watch(chatStateProvider.select((state) => state.isLoading));

// 避免：订阅整个状态对象
final chatState = ref.watch(chatStateProvider); // 会导致不必要的重建
```

### 使用Provider.family缓存
```dart
// 自动缓存不同参数的结果
final messageProvider = Provider.family<Message?, String>((ref, messageId) {
  return ref.watch(chatStateProvider.select((state) => 
    state.messages.where((m) => m.id == messageId).firstOrNull));
});
```

### 异步操作优化
```dart
// 使用AsyncValue处理异步状态
final conversationListProvider = FutureProvider<List<Conversation>>((ref) async {
  final chatService = ref.read(chatServiceProvider);
  return await chatService.loadConversations();
});

// 在UI中使用
ref.watch(conversationListProvider).when(
  data: (conversations) => ConversationList(conversations: conversations),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error.toString()),
);
```

## 测试

### 单元测试
```dart
void main() {
  group('ChatStateNotifier', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should send message successfully', () async {
      final notifier = container.read(chatStateProvider.notifier);
      
      await notifier.sendMessage('Test message');
      
      final state = container.read(chatStateProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first.content, 'Test message');
    });
  });
}
```

### Widget测试
```dart
testWidgets('should display chat messages', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: ChatScreen(),
      ),
    ),
  );
  
  // 验证UI状态
  expect(find.text('New Chat'), findsOneWidget);
  expect(find.byType(MessageListWidget), findsOneWidget);
});
```

这个新架构提供了强大的状态管理能力，同时保持了代码的清晰性和可维护性。通过合理使用这些Provider和状态管理模式，可以构建出高性能、可扩展的Flutter应用。
