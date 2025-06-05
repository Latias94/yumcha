# MCP 集成文档

## 概述

YumCha AI 聊天应用现已集成 Model Context Protocol (MCP) 功能，允许 AI 助手调用外部工具和服务。

## 功能特性

### 1. MCP 工具调用支持
- **非流式聊天**：AI 响应中包含工具调用时，自动执行 MCP 工具并返回结果
- **流式聊天**：实时处理工具调用，流式返回工具执行结果
- **错误处理**：完善的工具调用错误处理和日志记录

### 2. 自动工具检测
- 检查助手是否启用工具功能 (`enableTools`)
- 检查 MCP 服务是否启用
- 自动解析 AI 模型返回的工具调用请求

### 3. 工具结果集成
- 工具调用结果包含在 AI 响应中
- 支持多个工具的并发调用
- 详细的执行时间和状态信息

## 使用方法

### 1. 启用 MCP 服务
在设置中启用 MCP 服务并配置 MCP 服务器：

```dart
// 通过设置界面或代码启用
final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
await settingsNotifier.setMcpEnabled(true);
```

### 2. 配置助手工具支持
确保 AI 助手启用了工具功能：

```dart
final assistant = AiAssistant(
  // ... 其他配置
  enableTools: true, // 启用工具调用
);
```

### 3. 检查可用工具
```dart
final aiService = AiService();

// 检查是否有可用的 MCP 工具
if (aiService.hasMcpToolsAvailable) {
  // 获取工具列表
  final tools = aiService.getAvailableMcpTools();
  print('可用工具: $tools');
  
  // 获取特定工具信息
  final toolInfo = aiService.getMcpToolInfo('calculator');
  print('工具信息: $toolInfo');
}
```

### 4. 发送带工具调用的消息

#### 非流式调用
```dart
final response = await aiService.sendMessage(
  assistantId: 'your-assistant-id',
  chatHistory: chatHistory,
  userMessage: '请帮我计算 2 + 3',
  selectedProviderId: 'provider-id',
  selectedModelName: 'model-name',
);

// 检查是否有工具调用结果
if (response.hasToolResults) {
  for (final toolResult in response.toolResults!) {
    print('工具: ${toolResult.toolName}');
    print('结果: ${toolResult.result}');
    print('成功: ${toolResult.isSuccess}');
  }
}
```

#### 流式调用
```dart
await for (final event in aiService.sendMessageStream(
  assistantId: 'your-assistant-id',
  chatHistory: chatHistory,
  userMessage: '请帮我计算 2 + 3',
  selectedProviderId: 'provider-id',
  selectedModelName: 'model-name',
)) {
  if (event.isContent) {
    // 处理文本内容
    print('内容: ${event.contentDelta}');
  } else if (event.isToolResult) {
    // 处理工具调用结果
    final toolResult = event.toolResult!;
    print('工具调用: ${toolResult.toolName} -> ${toolResult.result}');
  } else if (event.isDone) {
    // 流式完成，获取所有工具结果
    if (event.allToolResults?.isNotEmpty == true) {
      print('所有工具调用完成: ${event.allToolResults!.length} 个');
    }
  }
}
```

## 工具调用流程

### 1. AI 模型生成工具调用
当 AI 模型决定需要调用工具时，会返回 `ToolCall` 对象：

```dart
ToolCall(
  id: 'call_123',
  callType: 'function',
  function: FunctionCall(
    name: 'calculator',
    arguments: '{"operation": "add", "a": 2, "b": 3}',
  ),
)
```

### 2. 参数解析和验证
系统自动解析 JSON 格式的参数：

```dart
Map<String, dynamic> arguments;
try {
  arguments = jsonDecode(toolCall.function.arguments);
} catch (e) {
  // 处理解析错误
  arguments = {};
}
```

### 3. MCP 工具调用
调用对应的 MCP 服务器工具：

```dart
final result = await mcpService.callTool(
  toolName: toolCall.function.name,
  arguments: arguments,
);
```

### 4. 结果返回
工具执行结果包装为 `McpToolResult`：

```dart
McpToolResult(
  toolName: 'calculator',
  arguments: {'operation': 'add', 'a': 2, 'b': 3},
  result: '5',
  error: null,
  duration: Duration(milliseconds: 150),
)
```

## 错误处理

### 1. 工具不存在
```dart
McpToolResult(
  toolName: 'unknown_tool',
  arguments: {},
  result: '',
  error: '找不到工具: unknown_tool',
  duration: Duration.zero,
)
```

### 2. 参数解析失败
```dart
// 日志记录参数解析错误
_logger.error('解析工具参数失败', {
  'toolName': toolCall.function.name,
  'arguments': toolCall.function.arguments,
  'error': e.toString(),
});
```

### 3. 工具执行异常
```dart
McpToolResult(
  toolName: 'calculator',
  arguments: {'operation': 'divide', 'a': 1, 'b': 0},
  result: '',
  error: '工具调用异常: Division by zero',
  duration: Duration(milliseconds: 50),
)
```

## 调试和监控

### 1. 调试日志
启用调试模式查看详细的工具调用日志：

```dart
final aiService = AiService();
aiService.setDebugMode(true);

// 查看调试日志
final debugLogs = aiService.debugLogs;
for (final log in debugLogs) {
  print('${log.timestamp}: ${log.response}');
}
```

### 2. 性能监控
每个工具调用都包含执行时间信息：

```dart
final toolResult = await mcpService.callTool(
  toolName: 'slow_tool',
  arguments: {},
);

print('工具执行时间: ${toolResult.duration.inMilliseconds}ms');
```

## 最佳实践

### 1. 工具启用检查
在发送消息前检查工具可用性：

```dart
if (!aiService.hasMcpToolsAvailable) {
  // 提示用户配置 MCP 服务器
  showDialog('请先配置 MCP 服务器');
  return;
}
```

### 2. 错误处理
始终检查工具调用结果：

```dart
for (final toolResult in response.toolResults ?? []) {
  if (!toolResult.isSuccess) {
    _logger.warning('工具调用失败', {
      'tool': toolResult.toolName,
      'error': toolResult.error,
    });
  }
}
```

### 3. 超时处理
为长时间运行的工具设置合理的超时：

```dart
// MCP 服务内部会处理超时
// 可以通过配置调整超时时间
```

## 示例 MCP 服务器

项目包含一个简单的 MCP 服务器示例 (`examples/simple_mcp_server.dart`)，提供：

- 计算器工具 (calculator)
- 文本处理工具 (text_processor)  
- 时间工具 (current_time)

可以用作测试和开发参考。
