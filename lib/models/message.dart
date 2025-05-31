import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String author;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? avatarUrl;
  final bool isFromUser;

  const Message({
    required this.author,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.avatarUrl,
    required this.isFromUser,
  });

  Message copyWith({
    String? author,
    String? content,
    DateTime? timestamp,
    String? imageUrl,
    String? avatarUrl,
    bool? isFromUser,
  }) {
    return Message(
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
    return 'Message(author: $author, content: $content, timestamp: $timestamp, isFromUser: $isFromUser)';
  }
}
