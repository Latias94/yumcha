import 'package:flutter/foundation.dart';

/// 聊天消息数据模型
///
/// 表示聊天对话中的单条消息，包含消息内容、作者、时间戳等信息。
/// 支持文本消息和图像消息，区分用户消息和 AI 回复。
///
/// 核心特性：
/// - 💬 **消息内容**: 支持文本和图像内容
/// - 👤 **作者标识**: 区分用户和 AI 助手
/// - ⏰ **时间戳**: 记录消息的创建时间
/// - 🖼️ **多媒体支持**: 支持图像 URL 和头像 URL
/// - 🔄 **不可变性**: 使用 @immutable 确保数据不可变
/// - 💾 **数据库兼容**: 支持数据库 ID 的可选字段
///
/// 业务逻辑：
/// - 用户发送的消息 isFromUser 为 true
/// - AI 回复的消息 isFromUser 为 false
/// - 新创建的消息可能没有数据库 ID（id 为 null）
/// - 保存到数据库后会分配唯一的 ID
///
/// 使用场景：
/// - 聊天界面的消息显示
/// - 消息历史的存储和加载
/// - AI 服务的上下文传递
@immutable
class Message {
  /// 数据库 ID（可选，新创建的消息可能还没有 ID）
  final String? id;

  /// 消息作者（用户名或 AI 助手名）
  final String author;

  /// 消息内容（文本内容）
  final String content;

  /// 消息时间戳
  final DateTime timestamp;

  /// 图像 URL（可选，用于图像消息）
  final String? imageUrl;

  /// 头像 URL（可选，用于显示作者头像）
  final String? avatarUrl;

  /// 是否为用户发送的消息（true: 用户消息，false: AI 回复）
  final bool isFromUser;

  const Message({
    this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.avatarUrl,
    required this.isFromUser,
  });

  Message copyWith({
    String? id,
    String? author,
    String? content,
    DateTime? timestamp,
    String? imageUrl,
    String? avatarUrl,
    bool? isFromUser,
  }) {
    return Message(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFromUser: isFromUser ?? this.isFromUser,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.author == author &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.imageUrl == imageUrl &&
        other.avatarUrl == avatarUrl &&
        other.isFromUser == isFromUser;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      author,
      content,
      timestamp,
      imageUrl,
      avatarUrl,
      isFromUser,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, author: $author, content: $content, timestamp: $timestamp, isFromUser: $isFromUser)';
  }
}
