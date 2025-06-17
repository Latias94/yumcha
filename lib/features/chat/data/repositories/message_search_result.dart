import 'package:flutter/foundation.dart';
import '../../domain/entities/message.dart';

/// 消息搜索结果模型
///
/// 用于封装搜索到的消息及其相关的对话信息
@immutable
class MessageSearchResult {
  /// 搜索到的消息
  final Message message;

  /// 消息所属的对话ID
  final String conversationId;

  /// 消息所属的对话标题
  final String conversationTitle;

  /// 消息所属对话的助手ID
  final String assistantId;

  const MessageSearchResult({
    required this.message,
    required this.conversationId,
    required this.conversationTitle,
    required this.assistantId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageSearchResult &&
        other.message == message &&
        other.conversationId == conversationId &&
        other.conversationTitle == conversationTitle &&
        other.assistantId == assistantId;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        conversationId.hashCode ^
        conversationTitle.hashCode ^
        assistantId.hashCode;
  }

  @override
  String toString() {
    return 'MessageSearchResult(message: ${message.id}, conversationId: $conversationId, conversationTitle: $conversationTitle, assistantId: $assistantId)';
  }
}
