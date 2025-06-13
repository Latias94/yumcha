import 'package:flutter/foundation.dart';

/// 聊天消息内容类型的基类
@immutable
sealed class ChatMessageContent {
  const ChatMessageContent();
}

/// 文本消息内容
@immutable
class TextContent extends ChatMessageContent {
  final String text;

  const TextContent(this.text);

  @override
  String toString() => 'TextContent(text: $text)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

/// 图片消息内容
@immutable
class ImageContent extends ChatMessageContent {
  final Uint8List data;
  final String? mimeType;
  final String? fileName;
  final String? description; // 用户添加的图片描述

  const ImageContent({
    required this.data,
    this.mimeType,
    this.fileName,
    this.description,
  });

  /// 文件大小（字节）
  int get size => data.length;

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() =>
      'ImageContent(fileName: $fileName, size: $formattedSize, mimeType: $mimeType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageContent &&
          runtimeType == other.runtimeType &&
          listEquals(data, other.data) &&
          mimeType == other.mimeType &&
          fileName == other.fileName &&
          description == other.description;

  @override
  int get hashCode => Object.hash(data, mimeType, fileName, description);
}

/// 文件消息内容
@immutable
class FileContent extends ChatMessageContent {
  final Uint8List data;
  final String fileName;
  final String mimeType;
  final String? description; // 用户添加的文件描述

  const FileContent({
    required this.data,
    required this.fileName,
    required this.mimeType,
    this.description,
  });

  /// 文件大小（字节）
  int get size => data.length;

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 是否是文档类型
  bool get isDocument {
    return mimeType.startsWith('application/') &&
        (mimeType.contains('pdf') ||
            mimeType.contains('word') ||
            mimeType.contains('excel') ||
            mimeType.contains('powerpoint') ||
            mimeType.contains('text'));
  }

  /// 是否是音频类型
  bool get isAudio => mimeType.startsWith('audio/');

  /// 是否是视频类型
  bool get isVideo => mimeType.startsWith('video/');

  /// 获取文件类型描述
  String get typeDescription {
    if (mimeType.contains('pdf')) return 'PDF文档';
    if (mimeType.contains('word')) return 'Word文档';
    if (mimeType.contains('excel')) return 'Excel表格';
    if (mimeType.contains('powerpoint')) return 'PowerPoint演示文稿';
    if (mimeType.startsWith('text/')) return '文本文件';
    if (mimeType.startsWith('audio/')) return '音频文件';
    if (mimeType.startsWith('video/')) return '视频文件';
    return '文件';
  }

  @override
  String toString() =>
      'FileContent(fileName: $fileName, size: $formattedSize, type: $typeDescription)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileContent &&
          runtimeType == other.runtimeType &&
          listEquals(data, other.data) &&
          fileName == other.fileName &&
          mimeType == other.mimeType &&
          description == other.description;

  @override
  int get hashCode => Object.hash(data, fileName, mimeType, description);
}

/// 混合消息内容（包含文本和多个附件）
@immutable
class MixedContent extends ChatMessageContent {
  final String? text;
  final List<ChatMessageContent> attachments;

  const MixedContent({
    this.text,
    required this.attachments,
  });

  /// 是否有文本内容
  bool get hasText => text != null && text!.isNotEmpty;

  /// 是否有附件
  bool get hasAttachments => attachments.isNotEmpty;

  /// 获取所有图片附件
  List<ImageContent> get images =>
      attachments.whereType<ImageContent>().toList();

  /// 获取所有文件附件
  List<FileContent> get files => attachments.whereType<FileContent>().toList();

  /// 附件总数
  int get attachmentCount => attachments.length;

  /// 附件总大小
  int get totalSize {
    int total = 0;
    for (final attachment in attachments) {
      if (attachment is ImageContent) {
        total += attachment.size;
      } else if (attachment is FileContent) {
        total += attachment.size;
      }
    }
    return total;
  }

  /// 格式化的总大小
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024)
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() =>
      'MixedContent(text: $text, attachments: ${attachments.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MixedContent &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          listEquals(attachments, other.attachments);

  @override
  int get hashCode => Object.hash(text, attachments);
}

/// 消息处理策略
enum MessageProcessingStrategy {
  /// 直接发送（不预处理）
  direct,

  /// 预处理为统一prompt
  preprocessToPrompt,

  /// 使用多模态API
  multimodal,

  /// 上传到云服务（如OpenAI文件API）
  cloudUpload,

  /// 自定义处理
  custom,
}

/// 扩展的消息发送请求
@immutable
class ChatMessageRequest {
  /// 消息内容
  final ChatMessageContent content;

  /// 处理策略
  final MessageProcessingStrategy strategy;

  /// 自定义处理器名称（当strategy为custom时使用）
  final String? customProcessor;

  /// 额外的处理参数
  final Map<String, dynamic>? processingParams;

  /// 是否需要预览确认
  final bool requiresPreview;

  const ChatMessageRequest({
    required this.content,
    this.strategy = MessageProcessingStrategy.direct,
    this.customProcessor,
    this.processingParams,
    this.requiresPreview = false,
  });

  /// 创建文本消息请求
  factory ChatMessageRequest.text(
    String text, {
    MessageProcessingStrategy strategy = MessageProcessingStrategy.direct,
    Map<String, dynamic>? processingParams,
  }) {
    return ChatMessageRequest(
      content: TextContent(text),
      strategy: strategy,
      processingParams: processingParams,
    );
  }

  /// 创建图片消息请求
  factory ChatMessageRequest.image(
    Uint8List data, {
    String? mimeType,
    String? fileName,
    String? description,
    MessageProcessingStrategy strategy = MessageProcessingStrategy.multimodal,
    Map<String, dynamic>? processingParams,
    bool requiresPreview = true,
  }) {
    return ChatMessageRequest(
      content: ImageContent(
        data: data,
        mimeType: mimeType,
        fileName: fileName,
        description: description,
      ),
      strategy: strategy,
      processingParams: processingParams,
      requiresPreview: requiresPreview,
    );
  }

  /// 创建文件消息请求
  factory ChatMessageRequest.file(
    Uint8List data, {
    required String fileName,
    required String mimeType,
    String? description,
    MessageProcessingStrategy strategy = MessageProcessingStrategy.cloudUpload,
    Map<String, dynamic>? processingParams,
    bool requiresPreview = true,
  }) {
    return ChatMessageRequest(
      content: FileContent(
        data: data,
        fileName: fileName,
        mimeType: mimeType,
        description: description,
      ),
      strategy: strategy,
      processingParams: processingParams,
      requiresPreview: requiresPreview,
    );
  }

  /// 创建混合消息请求
  factory ChatMessageRequest.mixed({
    String? text,
    required List<ChatMessageContent> attachments,
    MessageProcessingStrategy strategy = MessageProcessingStrategy.multimodal,
    Map<String, dynamic>? processingParams,
    bool requiresPreview = true,
  }) {
    return ChatMessageRequest(
      content: MixedContent(
        text: text,
        attachments: attachments,
      ),
      strategy: strategy,
      processingParams: processingParams,
      requiresPreview: requiresPreview,
    );
  }

  @override
  String toString() =>
      'ChatMessageRequest(content: $content, strategy: $strategy)';
}
