import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String? id; // 数据库ID，可选（新创建的消息可能还没有ID）
  final String author;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? avatarUrl;
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
