import 'dart:convert';
import '../../domain/entities/enhanced_message.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_block_status.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/entities/message_metadata.dart';
import '../../domain/entities/message_role.dart';
import '../../domain/entities/legacy_message.dart';
import '../../../../shared/infrastructure/services/media/media_storage_service.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// EnhancedMessage迁移服务
/// 
/// 负责将EnhancedMessage转换为新的块化消息系统
/// 这是一个过渡期的工具，用于平滑迁移到新架构
class EnhancedMessageMigrationService {
  final LoggerService _logger = LoggerService();

  /// 将EnhancedMessage转换为块化消息
  /// 
  /// 将包含多媒体内容的EnhancedMessage转换为新的Message + MessageBlock结构
  Message convertToBlockMessage(EnhancedMessage enhancedMessage) {
    _logger.debug('开始转换EnhancedMessage到块化消息', {
      'messageId': enhancedMessage.id,
      'hasMediaFiles': enhancedMessage.hasMediaFiles,
      'mediaFilesCount': enhancedMessage.mediaFiles.length,
    });

    // 创建消息块列表
    final blocks = <MessageBlock>[];
    
    // 1. 创建主文本块（如果有内容）
    if (enhancedMessage.content.isNotEmpty) {
      blocks.add(MessageBlock.text(
        id: '${enhancedMessage.id}_text',
        messageId: enhancedMessage.id!,
        content: enhancedMessage.content,
        status: _convertLegacyStatusToBlockStatus(enhancedMessage.status),
        createdAt: enhancedMessage.timestamp,
      ));
    }

    // 2. 为每个多媒体文件创建对应的块
    for (int i = 0; i < enhancedMessage.mediaFiles.length; i++) {
      final mediaFile = enhancedMessage.mediaFiles[i];
      final blockId = '${enhancedMessage.id}_media_$i';

      if (mediaFile.isImage) {
        // 创建图片块
        blocks.add(MessageBlock.image(
          id: blockId,
          messageId: enhancedMessage.id!,
          url: mediaFile.networkUrl ?? mediaFile.localPath ?? '',
          fileId: mediaFile.id,
          status: MessageBlockStatus.success,
          createdAt: mediaFile.createdAt,
        ));
      } else if (mediaFile.isAudio || mediaFile.isVideo || _isDocument(mediaFile)) {
        // 创建文件块
        blocks.add(MessageBlock(
          id: blockId,
          messageId: enhancedMessage.id!,
          type: MessageBlockType.file,
          status: MessageBlockStatus.success,
          createdAt: mediaFile.createdAt,
          url: mediaFile.networkUrl ?? mediaFile.localPath,
          fileId: mediaFile.id,
          metadata: {
            'fileName': mediaFile.fileName,
            'mimeType': mediaFile.mimeType,
            'sizeBytes': mediaFile.sizeBytes,
            'strategy': mediaFile.strategy.toString(),
            'customProperties': mediaFile.customProperties,
          },
        ));
      }
    }

    // 3. 创建新的块化消息
    final blockMessage = Message(
      id: enhancedMessage.id!,
      conversationId: '', // 需要从上下文获取
      role: enhancedMessage.isFromUser ? 'user' : 'assistant',
      assistantId: enhancedMessage.isFromUser ? 'user' : 'unknown', // 需要从上下文获取
      status: _convertLegacyStatusToMessageStatus(enhancedMessage.status),
      createdAt: enhancedMessage.timestamp,
      updatedAt: enhancedMessage.timestamp,
      blocks: blocks,
      metadata: _createMetadataMap(enhancedMessage),
    );

    _logger.debug('EnhancedMessage转换完成', {
      'messageId': enhancedMessage.id,
      'blocksCount': blocks.length,
      'textBlocks': blocks.where((b) => b.type == MessageBlockType.mainText).length,
      'imageBlocks': blocks.where((b) => b.type == MessageBlockType.image).length,
      'fileBlocks': blocks.where((b) => b.type == MessageBlockType.file).length,
    });

    return blockMessage;
  }

  /// 将块化消息转换为EnhancedMessage（向后兼容）
  /// 
  /// 用于需要EnhancedMessage接口的旧代码
  EnhancedMessage convertFromBlockMessage(Message blockMessage) {
    _logger.debug('开始转换块化消息到EnhancedMessage', {
      'messageId': blockMessage.id,
      'blocksCount': blockMessage.blocks.length,
    });

    // 提取主文本内容
    final textBlocks = blockMessage.blocks
        .where((block) => block.type == MessageBlockType.mainText)
        .toList();
    final content = textBlocks.isNotEmpty ? textBlocks.first.content ?? '' : '';

    // 提取多媒体文件
    final mediaFiles = <MediaMetadata>[];
    
    for (final block in blockMessage.blocks) {
      if (block.type == MessageBlockType.image) {
        // 转换图片块
        mediaFiles.add(MediaMetadata(
          id: block.fileId ?? block.id,
          fileName: 'image.png',
          mimeType: 'image/png',
          sizeBytes: 0,
          strategy: MediaStorageStrategy.networkUrl,
          networkUrl: block.url,
          createdAt: block.createdAt,
          customProperties: {'type': 'image'},
        ));
      } else if (block.type == MessageBlockType.file) {
        // 转换文件块
        final metadata = block.metadata ?? {};
        mediaFiles.add(MediaMetadata(
          id: block.fileId ?? block.id,
          fileName: metadata['fileName'] ?? 'file',
          mimeType: metadata['mimeType'] ?? 'application/octet-stream',
          sizeBytes: metadata['sizeBytes'] ?? 0,
          strategy: _parseStorageStrategy(metadata['strategy']),
          networkUrl: block.url,
          localPath: block.url,
          createdAt: block.createdAt,
          customProperties: metadata['customProperties'] ?? {},
        ));
      }
    }

    // 创建EnhancedMessage
    final enhancedMessage = EnhancedMessage(
      id: blockMessage.id,
      author: blockMessage.role == 'user' ? 'User' : 'Assistant',
      content: content,
      timestamp: blockMessage.createdAt,
      isFromUser: blockMessage.role == 'user',
      duration: _extractDurationFromMetadata(blockMessage.metadata),
      metadata: _convertMetadataToMessageMetadata(blockMessage.metadata),
      status: _convertMessageStatusToLegacyStatus(blockMessage.status),
      mediaFiles: mediaFiles,
    );

    _logger.debug('块化消息转换完成', {
      'messageId': blockMessage.id,
      'contentLength': content.length,
      'mediaFilesCount': mediaFiles.length,
    });

    return enhancedMessage;
  }

  /// 转换Legacy状态到块状态
  MessageBlockStatus _convertLegacyStatusToBlockStatus(LegacyMessageStatus legacyStatus) {
    switch (legacyStatus) {
      case LegacyMessageStatus.normal:
      case LegacyMessageStatus.system:
        return MessageBlockStatus.success;
      case LegacyMessageStatus.streaming:
        return MessageBlockStatus.streaming;
      case LegacyMessageStatus.error:
      case LegacyMessageStatus.failed:
        return MessageBlockStatus.error;
      case LegacyMessageStatus.sending:
      case LegacyMessageStatus.temporary:
      case LegacyMessageStatus.regenerating:
        return MessageBlockStatus.pending;
    }
  }

  /// 转换Legacy状态到消息状态
  MessageStatus _convertLegacyStatusToMessageStatus(LegacyMessageStatus legacyStatus) {
    switch (legacyStatus) {
      case LegacyMessageStatus.normal:
        return MessageStatus.aiSuccess;
      case LegacyMessageStatus.streaming:
        return MessageStatus.aiProcessing;
      case LegacyMessageStatus.error:
      case LegacyMessageStatus.failed:
        return MessageStatus.aiError;
      case LegacyMessageStatus.sending:
      case LegacyMessageStatus.temporary:
      case LegacyMessageStatus.regenerating:
        return MessageStatus.aiProcessing;
      case LegacyMessageStatus.system:
        return MessageStatus.system;
    }
  }

  /// 转换消息状态到Legacy状态
  LegacyMessageStatus _convertMessageStatusToLegacyStatus(MessageStatus messageStatus) {
    switch (messageStatus) {
      case MessageStatus.userSuccess:
      case MessageStatus.aiSuccess:
        return LegacyMessageStatus.normal;
      case MessageStatus.aiProcessing:
      case MessageStatus.aiPending:
        return LegacyMessageStatus.streaming;
      case MessageStatus.aiError:
        return LegacyMessageStatus.error;
      case MessageStatus.aiPaused:
        return LegacyMessageStatus.failed;
      case MessageStatus.system:
        return LegacyMessageStatus.system;
      case MessageStatus.temporary:
        return LegacyMessageStatus.temporary;
    }
  }

  /// 解析存储策略
  MediaStorageStrategy _parseStorageStrategy(String? strategyString) {
    if (strategyString == null) return MediaStorageStrategy.networkUrl;

    switch (strategyString) {
      case 'MediaStorageStrategy.localFile':
        return MediaStorageStrategy.localFile;
      case 'MediaStorageStrategy.networkUrl':
        return MediaStorageStrategy.networkUrl;
      case 'MediaStorageStrategy.database':
        return MediaStorageStrategy.database;
      case 'MediaStorageStrategy.cache':
        return MediaStorageStrategy.cache;
      default:
        return MediaStorageStrategy.networkUrl;
    }
  }

  /// 批量转换EnhancedMessage列表
  List<Message> convertEnhancedMessagesToBlockMessages(List<EnhancedMessage> enhancedMessages) {
    return enhancedMessages.map((msg) => convertToBlockMessage(msg)).toList();
  }

  /// 批量转换块化消息列表
  List<EnhancedMessage> convertBlockMessagesToEnhancedMessages(List<Message> blockMessages) {
    return blockMessages.map((msg) => convertFromBlockMessage(msg)).toList();
  }

  // 辅助方法

  /// 检查是否是文档类型
  bool _isDocument(MediaMetadata mediaFile) {
    return mediaFile.mimeType.startsWith('application/') &&
        (mediaFile.mimeType.contains('pdf') ||
            mediaFile.mimeType.contains('word') ||
            mediaFile.mimeType.contains('excel') ||
            mediaFile.mimeType.contains('powerpoint') ||
            mediaFile.mimeType.contains('text'));
  }

  /// 创建元数据映射
  Map<String, dynamic>? _createMetadataMap(EnhancedMessage enhancedMessage) {
    if (enhancedMessage.metadata == null && enhancedMessage.duration == null) {
      return null;
    }

    final metadata = <String, dynamic>{};

    if (enhancedMessage.metadata != null) {
      metadata.addAll(enhancedMessage.metadata!.toJson());
    }

    if (enhancedMessage.duration != null) {
      metadata['totalDurationMs'] = enhancedMessage.duration!.inMilliseconds;
    }

    return metadata;
  }

  /// 从元数据中提取持续时间
  Duration? _extractDurationFromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    final ms = metadata['totalDurationMs'] as int?;
    return ms != null ? Duration(milliseconds: ms) : null;
  }

  /// 转换元数据到MessageMetadata
  MessageMetadata? _convertMetadataToMessageMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    try {
      return MessageMetadata.fromJson(metadata);
    } catch (e) {
      // 如果转换失败，返回null
      return null;
    }
  }
}
