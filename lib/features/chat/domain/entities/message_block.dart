import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'message_block_type.dart';
import 'message_block_status.dart';

/// 消息块实体
///
/// 表示消息中的一个内容块，支持多种类型的内容
/// 每个消息可以包含多个消息块，实现更精细的内容管理
@immutable
class MessageBlock {
  /// 消息块ID
  final String id;

  /// 所属消息ID
  final String messageId;

  /// 消息块类型
  final MessageBlockType type;

  /// 消息块状态
  final MessageBlockStatus status;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 文本内容（用于文本类型的块）
  final String? content;

  /// 代码语言（用于代码块）
  final String? language;

  /// 文件ID（用于文件类型的块）
  final String? fileId;

  /// URL（用于图片、文件等资源）
  final String? url;

  /// 工具ID（用于工具调用块）
  final String? toolId;

  /// 工具名称（用于工具调用块）
  final String? toolName;

  /// 工具参数（JSON格式，用于工具调用块）
  final String? arguments;

  /// 模型ID（用于标识生成此块的模型）
  final String? modelId;

  /// 模型名称
  final String? modelName;

  /// 通用元数据（JSON格式）
  final Map<String, dynamic>? metadata;

  /// 错误信息（当状态为error时）
  final Map<String, dynamic>? error;

  /// 源块ID（用于翻译等场景）
  final String? sourceBlockId;

  /// 引用信息（JSON格式，用于引用块）
  final List<Map<String, dynamic>>? citationReferences;

  /// 思考时间（毫秒，用于思考过程块）
  final int? thinkingMillsec;

  const MessageBlock({
    required this.id,
    required this.messageId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.content,
    this.language,
    this.fileId,
    this.url,
    this.toolId,
    this.toolName,
    this.arguments,
    this.modelId,
    this.modelName,
    this.metadata,
    this.error,
    this.sourceBlockId,
    this.citationReferences,
    this.thinkingMillsec,
  });

  /// 复制并修改消息块
  MessageBlock copyWith({
    String? id,
    String? messageId,
    MessageBlockType? type,
    MessageBlockStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? content,
    String? language,
    String? fileId,
    String? url,
    String? toolId,
    String? toolName,
    String? arguments,
    String? modelId,
    String? modelName,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? error,
    String? sourceBlockId,
    List<Map<String, dynamic>>? citationReferences,
    int? thinkingMillsec,
  }) {
    return MessageBlock(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      content: content ?? this.content,
      language: language ?? this.language,
      fileId: fileId ?? this.fileId,
      url: url ?? this.url,
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      arguments: arguments ?? this.arguments,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      metadata: metadata ?? this.metadata,
      error: error ?? this.error,
      sourceBlockId: sourceBlockId ?? this.sourceBlockId,
      citationReferences: citationReferences ?? this.citationReferences,
      thinkingMillsec: thinkingMillsec ?? this.thinkingMillsec,
    );
  }

  /// 创建文本块
  factory MessageBlock.text({
    required String id,
    required String messageId,
    required String content,
    MessageBlockStatus status = MessageBlockStatus.success,
    DateTime? createdAt,
    String? modelId,
    String? modelName,
  }) {
    return MessageBlock(
      id: id,
      messageId: messageId,
      type: MessageBlockType.mainText,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      content: content,
      modelId: modelId,
      modelName: modelName,
    );
  }

  /// 创建思考过程块
  factory MessageBlock.thinking({
    required String id,
    required String messageId,
    required String content,
    MessageBlockStatus status = MessageBlockStatus.success,
    DateTime? createdAt,
    int? thinkingMillsec,
    String? modelId,
    String? modelName,
  }) {
    return MessageBlock(
      id: id,
      messageId: messageId,
      type: MessageBlockType.thinking,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      content: content,
      thinkingMillsec: thinkingMillsec,
      modelId: modelId,
      modelName: modelName,
    );
  }

  /// 创建代码块
  factory MessageBlock.code({
    required String id,
    required String messageId,
    required String content,
    String? language,
    MessageBlockStatus status = MessageBlockStatus.success,
    DateTime? createdAt,
    String? modelId,
    String? modelName,
  }) {
    return MessageBlock(
      id: id,
      messageId: messageId,
      type: MessageBlockType.code,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      content: content,
      language: language,
      modelId: modelId,
      modelName: modelName,
    );
  }

  /// 创建图片块
  factory MessageBlock.image({
    required String id,
    required String messageId,
    required String url,
    String? fileId,
    MessageBlockStatus status = MessageBlockStatus.success,
    DateTime? createdAt,
  }) {
    return MessageBlock(
      id: id,
      messageId: messageId,
      type: MessageBlockType.image,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      url: url,
      fileId: fileId,
    );
  }

  /// 创建工具调用块
  factory MessageBlock.tool({
    required String id,
    required String messageId,
    required String toolName,
    required Map<String, dynamic> arguments,
    String? toolId,
    MessageBlockStatus status = MessageBlockStatus.success,
    DateTime? createdAt,
    String? modelId,
    String? modelName,
  }) {
    return MessageBlock(
      id: id,
      messageId: messageId,
      type: MessageBlockType.tool,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      toolId: toolId,
      toolName: toolName,
      arguments: jsonEncode(arguments),
      modelId: modelId,
      modelName: modelName,
    );
  }

  /// 创建错误块
  factory MessageBlock.error({
    required String id,
    required String messageId,
    required String content,
    Map<String, dynamic>? error,
    DateTime? createdAt,
  }) {
    return MessageBlock(
      id: id,
      messageId: messageId,
      type: MessageBlockType.error,
      status: MessageBlockStatus.error,
      createdAt: createdAt ?? DateTime.now(),
      content: content,
      error: error,
    );
  }

  /// 获取工具参数（解析JSON）
  Map<String, dynamic>? get toolArguments {
    if (arguments == null) return null;
    try {
      return jsonDecode(arguments!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 是否有内容
  bool get hasContent {
    return content != null && content!.isNotEmpty;
  }

  /// 是否有错误
  bool get hasError {
    return status.isError &&
        (error != null || (content != null && content!.isNotEmpty));
  }

  /// 获取思考时间
  Duration? get thinkingDuration {
    if (thinkingMillsec != null) {
      return Duration(milliseconds: thinkingMillsec!);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageBlock &&
        other.id == id &&
        other.messageId == messageId &&
        other.type == type &&
        other.status == status &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(id, messageId, type, status, content);
  }

  @override
  String toString() {
    return 'MessageBlock(id: $id, messageId: $messageId, type: $type, status: $status, content: ${content?.substring(0, content!.length > 50 ? 50 : content!.length)}...)';
  }
}
