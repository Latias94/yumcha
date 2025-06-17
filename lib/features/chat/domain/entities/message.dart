import 'package:flutter/foundation.dart';
import 'message_metadata.dart';
import 'message_block.dart';
import 'message_block_type.dart';
import 'message_status.dart';

/// 块化消息数据模型
///
/// 重构后的消息类，采用块化架构设计。消息作为块的容器，
/// 具体内容存储在MessageBlock中，支持多模态内容和精细化状态管理。
///
/// 核心特性：
/// - 🧩 **块化架构**: 消息内容分解为独立的块
/// - 🎭 **角色系统**: 支持user、assistant、system角色
/// - 📊 **状态管理**: 消息级和块级的独立状态
/// - 🔄 **流式支持**: 支持实时的流式内容更新
/// - 🛠️ **多模态**: 原生支持文本、图片、工具调用等
/// - 🔗 **关联性**: 消息与助手、模型的关联
///
/// 架构设计：
/// - Message: 消息元数据容器
/// - MessageBlock: 具体内容单元
/// - 一对多关系: 一个消息包含多个块
/// - 有序管理: 块按orderIndex排序
///
/// 使用场景：
/// - 聊天界面的消息显示
/// - 流式消息的实时更新
/// - 多模态内容的组织
/// - 消息状态的精细管理
@immutable
class Message {
  /// 消息ID
  final String id;

  /// 所属对话ID
  final String conversationId;

  /// 消息角色 ('user' | 'assistant' | 'system')
  final String role;

  /// 关联的助手ID
  final String assistantId;

  /// 消息块ID列表（有序）
  final List<String> blockIds;

  /// 消息状态
  final MessageStatus status;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 使用的模型ID
  final String? modelId;

  /// 消息元数据
  final Map<String, dynamic>? metadata;

  /// 关联的消息块列表（运行时加载）
  final List<MessageBlock> blocks;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.assistantId,
    this.blockIds = const [],
    this.status = MessageStatus.userSuccess,
    required this.createdAt,
    required this.updatedAt,
    this.modelId,
    this.metadata,
    this.blocks = const [],
  });

  /// 复制并修改部分属性
  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? assistantId,
    List<String>? blockIds,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? modelId,
    Map<String, dynamic>? metadata,
    List<MessageBlock>? blocks,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      assistantId: assistantId ?? this.assistantId,
      blockIds: blockIds ?? this.blockIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      modelId: modelId ?? this.modelId,
      metadata: metadata ?? this.metadata,
      blocks: blocks ?? this.blocks,
    );
  }

  /// 创建用户消息
  factory Message.user({
    required String id,
    required String conversationId,
    required String assistantId,
    List<String> blockIds = const [],
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    final now = createdAt ?? DateTime.now();
    return Message(
      id: id,
      conversationId: conversationId,
      role: 'user',
      assistantId: assistantId,
      blockIds: blockIds,
      status: MessageStatus.userSuccess,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// 创建AI消息
  factory Message.assistant({
    required String id,
    required String conversationId,
    required String assistantId,
    List<String> blockIds = const [],
    MessageStatus status = MessageStatus.aiProcessing,
    DateTime? createdAt,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    final now = createdAt ?? DateTime.now();
    return Message(
      id: id,
      conversationId: conversationId,
      role: 'assistant',
      assistantId: assistantId,
      blockIds: blockIds,
      status: status,
      createdAt: now,
      updatedAt: now,
      modelId: modelId,
      metadata: metadata,
    );
  }

  /// 创建系统消息
  factory Message.system({
    required String id,
    required String conversationId,
    required String assistantId,
    List<String> blockIds = const [],
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    final now = createdAt ?? DateTime.now();
    return Message(
      id: id,
      conversationId: conversationId,
      role: 'system',
      assistantId: assistantId,
      blockIds: blockIds,
      status: MessageStatus.system,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// 是否是用户消息
  bool get isFromUser => role == 'user';

  /// 是否是AI消息
  bool get isAiMessage => role == 'assistant';

  /// 是否是系统消息
  bool get isSystemMessage => role == 'system';

  /// 是否应该持久化到数据库
  bool get shouldPersist => status.shouldPersist;

  /// 是否是错误状态
  bool get isError => status.isError;

  /// 是否是临时状态
  bool get isTemporary => status.isTemporary;

  /// 是否有消息块
  bool get hasBlocks => blockIds.isNotEmpty;

  /// 获取主文本内容（从第一个文本块获取）
  String get content {
    final textBlock = blocks.firstWhere(
      (block) => block.type == MessageBlockType.mainText,
      orElse: () => MessageBlock.text(
        id: '',
        messageId: id,
        content: '',
      ),
    );
    return textBlock.content ?? '';
  }

  /// 获取思考过程内容
  String? get thinkingContent {
    try {
      final thinkingBlock = blocks.firstWhere(
        (block) => block.type == MessageBlockType.thinking,
      );
      return thinkingBlock.content;
    } catch (e) {
      return null;
    }
  }

  /// 是否包含思考过程
  bool get hasThinking {
    return blocks.any((block) => block.type == MessageBlockType.thinking);
  }

  /// 是否包含工具调用
  bool get hasToolCalls {
    return blocks.any((block) => block.type == MessageBlockType.tool);
  }

  /// 是否包含图片
  bool get hasImages {
    return blocks.any((block) => block.type == MessageBlockType.image);
  }

  /// 是否包含代码
  bool get hasCode {
    return blocks.any((block) => block.type == MessageBlockType.code);
  }

  /// 获取所有图片块
  List<MessageBlock> get imageBlocks {
    return blocks
        .where((block) => block.type == MessageBlockType.image)
        .toList();
  }

  /// 获取所有工具调用块
  List<MessageBlock> get toolBlocks {
    return blocks
        .where((block) => block.type == MessageBlockType.tool)
        .toList();
  }

  /// 获取所有代码块
  List<MessageBlock> get codeBlocks {
    return blocks
        .where((block) => block.type == MessageBlockType.code)
        .toList();
  }

  /// 获取思考过程耗时（从元数据）
  Duration? get thinkingDuration {
    if (metadata != null && metadata!.containsKey('thinkingDurationMs')) {
      final ms = metadata!['thinkingDurationMs'] as int?;
      return ms != null ? Duration(milliseconds: ms) : null;
    }
    return null;
  }

  /// 获取总响应耗时（从元数据）
  Duration? get totalDuration {
    if (metadata != null && metadata!.containsKey('totalDurationMs')) {
      final ms = metadata!['totalDurationMs'] as int?;
      return ms != null ? Duration(milliseconds: ms) : null;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.role == role &&
        other.assistantId == assistantId &&
        listEquals(other.blockIds, blockIds) &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      conversationId,
      role,
      assistantId,
      Object.hashAll(blockIds),
      status,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, role: $role, conversationId: $conversationId, '
        'assistantId: $assistantId, status: $status, blocks: ${blocks.length})';
  }
}
