#!/usr/bin/env dart

/// 简单的 MCP 服务器示例
/// 提供基本的计算和文本处理工具
///
/// 使用方法：
/// 1. 编译: dart compile exe examples/simple_mcp_server.dart -o simple_mcp_server
/// 2. 在 YumCha 中配置:
///    - 名称: 计算工具服务器
///    - 类型: Standard I/O
///    - 命令: /path/to/simple_mcp_server
///    - 参数: (留空)
library;

import 'package:mcp_dart/mcp_dart.dart';

void main() async {
  // 创建 MCP 服务器
  final server = McpServer(
    Implementation(name: "simple-tools-server", version: "1.0.0"),
    options: ServerOptions(
      capabilities: ServerCapabilities(
        tools: ServerCapabilitiesTools(),
      ),
    ),
  );

  // 注册计算工具
  server.tool(
    "calculate",
    description: '执行基本的数学运算',
    inputSchemaProperties: {
      'operation': {
        'type': 'string',
        'enum': ['add', 'subtract', 'multiply', 'divide'],
        'description': '要执行的运算类型',
      },
      'a': {
        'type': 'number',
        'description': '第一个数字',
      },
      'b': {
        'type': 'number',
        'description': '第二个数字',
      },
    },
    callback: ({args, extra}) async {
      final operation = args!['operation'] as String;
      final a = (args['a'] as num).toDouble();
      final b = (args['b'] as num).toDouble();

      double result;
      switch (operation) {
        case 'add':
          result = a + b;
          break;
        case 'subtract':
          result = a - b;
          break;
        case 'multiply':
          result = a * b;
          break;
        case 'divide':
          if (b == 0) {
            throw Exception('除数不能为零');
          }
          result = a / b;
          break;
        default:
          throw Exception('不支持的运算类型: $operation');
      }

      return CallToolResult.fromContent(
        content: [
          TextContent(text: '计算结果: $a $operation $b = $result'),
        ],
      );
    },
  );

  // 注册文本处理工具
  server.tool(
    "text_transform",
    description: '对文本进行各种转换操作',
    inputSchemaProperties: {
      'text': {
        'type': 'string',
        'description': '要处理的文本',
      },
      'operation': {
        'type': 'string',
        'enum': ['uppercase', 'lowercase', 'reverse', 'length'],
        'description': '要执行的文本操作',
      },
    },
    callback: ({args, extra}) async {
      final text = args!['text'] as String;
      final operation = args['operation'] as String;

      String result;
      switch (operation) {
        case 'uppercase':
          result = '转换为大写: ${text.toUpperCase()}';
          break;
        case 'lowercase':
          result = '转换为小写: ${text.toLowerCase()}';
          break;
        case 'reverse':
          result = '反转文本: ${text.split('').reversed.join('')}';
          break;
        case 'length':
          result = '文本长度: ${text.length} 个字符';
          break;
        default:
          throw Exception('不支持的文本操作: $operation');
      }

      return CallToolResult.fromContent(
        content: [
          TextContent(text: result),
        ],
      );
    },
  );

  // 注册时间工具
  server.tool(
    "current_time",
    description: '获取当前时间信息',
    inputSchemaProperties: {
      'format': {
        'type': 'string',
        'enum': ['iso', 'readable', 'timestamp'],
        'description': '时间格式',
        'default': 'readable',
      },
    },
    callback: ({args, extra}) async {
      final format = args?['format'] as String? ?? 'readable';
      final now = DateTime.now();

      String result;
      switch (format) {
        case 'iso':
          result = 'ISO 格式时间: ${now.toIso8601String()}';
          break;
        case 'readable':
          result =
              '当前时间: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
          break;
        case 'timestamp':
          result = '时间戳: ${now.millisecondsSinceEpoch}';
          break;
        default:
          throw Exception('不支持的时间格式: $format');
      }

      return CallToolResult.fromContent(
        content: [
          TextContent(text: result),
        ],
      );
    },
  );

  // 注册随机数生成工具
  server.tool(
    "random_number",
    description: '生成指定范围内的随机数',
    inputSchemaProperties: {
      'min': {
        'type': 'number',
        'description': '最小值',
        'default': 1,
      },
      'max': {
        'type': 'number',
        'description': '最大值',
        'default': 100,
      },
      'count': {
        'type': 'integer',
        'description': '生成数量',
        'default': 1,
        'minimum': 1,
        'maximum': 10,
      },
    },
    callback: ({args, extra}) async {
      final min = (args?['min'] as num?)?.toInt() ?? 1;
      final max = (args?['max'] as num?)?.toInt() ?? 100;
      final count = (args?['count'] as num?)?.toInt() ?? 1;

      if (min >= max) {
        throw Exception('最小值必须小于最大值');
      }

      final random = DateTime.now().millisecondsSinceEpoch;
      final numbers = <int>[];

      for (int i = 0; i < count; i++) {
        final seed = random + i;
        final value = min + (seed % (max - min + 1));
        numbers.add(value);
      }

      final result =
          count == 1 ? '随机数: ${numbers.first}' : '随机数列表: ${numbers.join(', ')}';

      return CallToolResult.fromContent(
        content: [
          TextContent(text: result),
        ],
      );
    },
  );

  // 连接到标准输入输出
  await server.connect(StdioServerTransport());
}
