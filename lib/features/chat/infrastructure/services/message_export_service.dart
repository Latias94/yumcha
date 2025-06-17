import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/exceptions/chat_exceptions.dart';
import 'chat_logger_service.dart';

/// 导出格式枚举
enum ExportFormat {
  text,
  json,
  markdown,
  html,
  csv,
}

/// 消息导出服务
///
/// 提供多种格式的消息导出功能，
/// 支持文本、JSON、Markdown等格式。
///
/// 功能特性：
/// - 📄 **多格式支持**: 支持TXT、JSON、MD、HTML等格式
/// - 🎯 **选择性导出**: 支持导出指定消息或消息块
/// - 📊 **结构化导出**: 保持消息的层次结构
/// - 🎨 **格式化输出**: 美观的格式化输出
/// - 📱 **跨平台**: 支持移动端和桌面端
class MessageExportService {
  /// 导出消息列表
  Future<String> exportMessages({
    required List<Message> messages,
    required ExportFormat format,
    String? title,
    bool includeMetadata = true,
    bool includeThinking = false,
  }) async {
    ChatLoggerService.logDebug(
      'Exporting ${messages.length} messages in ${format.name} format',
    );

    try {
      String content;

      switch (format) {
        case ExportFormat.text:
          content = _exportAsText(messages, includeMetadata, includeThinking);
          break;
        case ExportFormat.json:
          content = _exportAsJson(messages, includeMetadata);
          break;
        case ExportFormat.markdown:
          content = _exportAsMarkdown(
              messages, title, includeMetadata, includeThinking);
          break;
        case ExportFormat.html:
          content =
              _exportAsHtml(messages, title, includeMetadata, includeThinking);
          break;
        case ExportFormat.csv:
          content = _exportAsCsv(messages, includeMetadata);
          break;
      }

      ChatLoggerService.logDebug('Export completed successfully');
      return content;
    } catch (e) {
      ChatLoggerService.logException(
        ValidationException.invalidParameter(
            'export', 'Failed to export messages: $e'),
      );
      rethrow;
    }
  }

  /// 导出为文本格式
  String _exportAsText(
      List<Message> messages, bool includeMetadata, bool includeThinking) {
    final buffer = StringBuffer();

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];

      // 消息头
      buffer.writeln('=' * 50);
      buffer.writeln('消息 ${i + 1} - ${message.isFromUser ? '用户' : 'AI助手'}');
      buffer.writeln('时间: ${_formatDateTime(message.createdAt)}');

      if (includeMetadata) {
        buffer.writeln('ID: ${message.id}');
        buffer.writeln('状态: ${message.status.displayName}');
        if (message.modelId != null) {
          buffer.writeln('模型: ${message.modelId}');
        }
      }

      buffer.writeln('-' * 30);

      // 消息内容
      for (final block in message.blocks) {
        if (block.type == MessageBlockType.thinking && !includeThinking) {
          continue;
        }

        buffer.writeln();
        buffer.writeln('[${_getBlockTypeName(block.type)}]');
        buffer.writeln(block.content ?? '');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 导出为JSON格式
  String _exportAsJson(List<Message> messages, bool includeMetadata) {
    final data = {
      'exportTime': DateTime.now().toIso8601String(),
      'messageCount': messages.length,
      'messages': messages
          .map((message) => {
                'id': message.id,
                'conversationId': message.conversationId,
                'role': message.role,
                'assistantId': message.assistantId,
                'createdAt': message.createdAt.toIso8601String(),
                'updatedAt': message.updatedAt.toIso8601String(),
                if (includeMetadata) ...{
                  'status': message.status.name,
                  'modelId': message.modelId,
                  'metadata': message.metadata,
                },
                'blocks': message.blocks
                    .map((block) => {
                          'id': block.id,
                          'type': block.type.name,
                          'content': block.content,
                          // 'orderIndex': block.orderIndex, // MessageBlock没有orderIndex属性
                          'status': block.status.name,
                          if (block.language != null)
                            'language': block.language,
                          if (block.toolName != null)
                            'toolName': block.toolName,
                          if (includeMetadata) ...{
                            'createdAt': block.createdAt.toIso8601String(),
                            'metadata': block.metadata,
                          },
                        })
                    .toList(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 导出为Markdown格式
  String _exportAsMarkdown(List<Message> messages, String? title,
      bool includeMetadata, bool includeThinking) {
    final buffer = StringBuffer();

    // 标题
    if (title != null) {
      buffer.writeln('# $title');
      buffer.writeln();
    }

    // 元信息
    buffer.writeln('**导出时间**: ${_formatDateTime(DateTime.now())}');
    buffer.writeln('**消息数量**: ${messages.length}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // 消息内容
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];

      // 消息标题
      buffer.writeln(
          '## 消息 ${i + 1} - ${message.isFromUser ? '👤 用户' : '🤖 AI助手'}');
      buffer.writeln();

      if (includeMetadata) {
        buffer.writeln('- **时间**: ${_formatDateTime(message.createdAt)}');
        buffer.writeln('- **ID**: `${message.id}`');
        buffer.writeln('- **状态**: ${message.status.displayName}');
        if (message.modelId != null) {
          buffer.writeln('- **模型**: ${message.modelId}');
        }
        buffer.writeln();
      }

      // 消息块
      for (final block in message.blocks) {
        if (block.type == MessageBlockType.thinking && !includeThinking) {
          continue;
        }

        switch (block.type) {
          case MessageBlockType.mainText:
            buffer.writeln(block.content ?? '');
            break;
          case MessageBlockType.code:
            final language = block.language ?? '';
            buffer.writeln('```$language');
            buffer.writeln(block.content ?? '');
            buffer.writeln('```');
            break;
          case MessageBlockType.thinking:
            buffer.writeln('> **思考过程**:');
            buffer
                .writeln('> ${(block.content ?? '').replaceAll('\n', '\n> ')}');
            break;
          case MessageBlockType.tool:
            buffer.writeln('**🔧 工具调用**: ${block.toolName ?? '未知工具'}');
            buffer.writeln('```json');
            buffer.writeln(block.content ?? '');
            buffer.writeln('```');
            break;
          case MessageBlockType.image:
            buffer.writeln('![图片](${block.content ?? ''})');
            break;
          case MessageBlockType.error:
            buffer.writeln('> ⚠️ **错误**: ${block.content ?? ''}');
            break;
          default:
            buffer.writeln(
                '**${_getBlockTypeName(block.type)}**: ${block.content ?? ''}');
        }

        buffer.writeln();
      }

      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 导出为HTML格式
  String _exportAsHtml(List<Message> messages, String? title,
      bool includeMetadata, bool includeThinking) {
    final buffer = StringBuffer();

    // HTML头部
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="zh-CN">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln(
        '  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('  <title>${title ?? '聊天记录'}</title>');
    buffer.writeln('  <style>');
    buffer.writeln(_getHtmlStyles());
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    // 标题
    if (title != null) {
      buffer.writeln('  <h1>$title</h1>');
    }

    // 元信息
    buffer.writeln('  <div class="meta-info">');
    buffer.writeln(
        '    <p><strong>导出时间</strong>: ${_formatDateTime(DateTime.now())}</p>');
    buffer.writeln('    <p><strong>消息数量</strong>: ${messages.length}</p>');
    buffer.writeln('  </div>');

    // 消息列表
    buffer.writeln('  <div class="messages">');

    for (final message in messages) {
      final roleClass = message.isFromUser ? 'user' : 'assistant';
      buffer.writeln('    <div class="message $roleClass">');
      buffer.writeln('      <div class="message-header">');
      buffer.writeln(
          '        <span class="role">${message.isFromUser ? '👤 用户' : '🤖 AI助手'}</span>');
      buffer.writeln(
          '        <span class="time">${_formatDateTime(message.createdAt)}</span>');
      buffer.writeln('      </div>');

      buffer.writeln('      <div class="message-content">');
      for (final block in message.blocks) {
        if (block.type == MessageBlockType.thinking && !includeThinking) {
          continue;
        }

        buffer.writeln('        <div class="block ${block.type.name}">');
        buffer.writeln('          ${_formatBlockContentForHtml(block)}');
        buffer.writeln('        </div>');
      }
      buffer.writeln('      </div>');

      buffer.writeln('    </div>');
    }

    buffer.writeln('  </div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  /// 导出为CSV格式
  String _exportAsCsv(List<Message> messages, bool includeMetadata) {
    final buffer = StringBuffer();

    // CSV头部
    final headers = [
      'ID',
      'Role',
      'Content',
      'CreatedAt',
      if (includeMetadata) ...[
        'Status',
        'ModelId',
        'BlockCount',
      ],
    ];
    buffer.writeln(headers.map(_escapeCsvField).join(','));

    // 数据行
    for (final message in messages) {
      final row = [
        message.id,
        message.role,
        message.content.replaceAll('\n', ' '),
        message.createdAt.toIso8601String(),
        if (includeMetadata) ...[
          message.status.displayName,
          message.modelId ?? '',
          message.blocks.length.toString(),
        ],
      ];
      buffer.writeln(row.map(_escapeCsvField).join(','));
    }

    return buffer.toString();
  }

  /// 保存导出内容到文件
  Future<File> saveToFile({
    required String content,
    required String fileName,
    String? directory,
  }) async {
    final dir = directory != null
        ? Directory(directory)
        : await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    ChatLoggerService.logFileOperation('export', file.path,
        fileSize: content.length);
    return file;
  }

  /// 获取块类型名称
  String _getBlockTypeName(MessageBlockType type) {
    switch (type) {
      case MessageBlockType.mainText:
        return '文本';
      case MessageBlockType.code:
        return '代码';
      case MessageBlockType.thinking:
        return '思考过程';
      case MessageBlockType.tool:
        return '工具调用';
      case MessageBlockType.image:
        return '图片';
      case MessageBlockType.error:
        return '错误';
      default:
        return '未知';
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 转义CSV字段
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// 格式化HTML块内容
  String _formatBlockContentForHtml(MessageBlock block) {
    final content = block.content ?? '';

    switch (block.type) {
      case MessageBlockType.code:
        return '<pre><code class="${block.language ?? ''}">${_escapeHtml(content)}</code></pre>';
      case MessageBlockType.thinking:
        return '<div class="thinking-content">${_escapeHtml(content).replaceAll('\n', '<br>')}</div>';
      case MessageBlockType.error:
        return '<div class="error-content">⚠️ ${_escapeHtml(content)}</div>';
      default:
        return '<div class="text-content">${_escapeHtml(content).replaceAll('\n', '<br>')}</div>';
    }
  }

  /// 转义HTML
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// 获取HTML样式
  String _getHtmlStyles() {
    return '''
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; }
    .meta-info { background: #f5f5f5; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
    .messages { max-width: 800px; }
    .message { margin-bottom: 20px; padding: 15px; border-radius: 8px; }
    .message.user { background: #e3f2fd; }
    .message.assistant { background: #f3e5f5; }
    .message-header { display: flex; justify-content: space-between; margin-bottom: 10px; font-weight: bold; }
    .block { margin: 10px 0; }
    .thinking-content { background: #fff3e0; padding: 10px; border-radius: 4px; font-style: italic; }
    .error-content { background: #ffebee; padding: 10px; border-radius: 4px; color: #c62828; }
    pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }
    ''';
  }
}
