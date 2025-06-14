import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'media_storage_service.dart';
import '../../../../features/chat/domain/entities/enhanced_message.dart';
import '../../../../features/chat/domain/entities/message.dart';
import '../logger_service.dart';

/// 多媒体存储服务使用示例
/// 
/// 展示如何在AI聊天应用中使用多媒体存储功能
class MediaUsageExample {
  final MediaStorageService _mediaService = MediaStorageService();
  final LoggerService _logger = LoggerService();

  /// 示例1：处理AI生成的图片
  Future<EnhancedMessage> handleAiGeneratedImage({
    required String aiResponse,
    required String imageUrl,
    required String assistantName,
  }) async {
    try {
      // 下载AI生成的图片
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      final imageData = response.bodyBytes;
      
      // 存储图片
      final mediaMetadata = await _mediaService.storeMedia(
        data: imageData,
        fileName: 'ai_generated_${DateTime.now().millisecondsSinceEpoch}.png',
        mimeType: 'image/png',
        networkUrl: imageUrl,
        customProperties: {
          'type': 'ai_generated',
          'source': 'dalle',
          'prompt_hash': aiResponse.hashCode.toString(),
        },
      );

      // 创建包含图片的增强消息
      return EnhancedMessage.withAiGeneratedImage(
        author: assistantName,
        content: aiResponse,
        imageUrl: imageUrl,
        imageDescription: 'AI生成的图片',
      );
    } catch (e) {
      _logger.error('处理AI生成图片失败: $e');
      
      // 降级：创建仅包含URL的消息
      return EnhancedMessage.withAiGeneratedImage(
        author: assistantName,
        content: aiResponse,
        imageUrl: imageUrl,
        imageDescription: '图片加载失败',
      );
    }
  }

  /// 示例2：处理TTS音频
  Future<EnhancedMessage> handleTtsAudio({
    required String textContent,
    required String audioUrl,
    required String assistantName,
    Duration? audioDuration,
  }) async {
    try {
      // 下载TTS音频
      final response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download audio: ${response.statusCode}');
      }

      final audioData = response.bodyBytes;
      
      // 存储音频（设置缓存过期时间）
      final mediaMetadata = await _mediaService.storeMedia(
        data: audioData,
        fileName: 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
        mimeType: 'audio/mpeg',
        networkUrl: audioUrl,
        cacheExpiry: Duration(days: 7), // 7天后过期
        customProperties: {
          'type': 'tts_generated',
          'text_length': textContent.length,
          'duration_ms': audioDuration?.inMilliseconds,
        },
      );

      // 创建包含音频的增强消息
      return EnhancedMessage.withTtsAudio(
        author: assistantName,
        content: textContent,
        audioUrl: audioUrl,
        audioDuration: audioDuration,
      );
    } catch (e) {
      _logger.error('处理TTS音频失败: $e');
      
      // 降级：创建仅包含文本的消息
      return EnhancedMessage(
        author: assistantName,
        content: textContent,
        timestamp: DateTime.now(),
        isFromUser: false,
      );
    }
  }

  /// 示例3：处理用户上传的多媒体文件
  Future<List<MediaMetadata>> handleUserUploads(
    List<File> files,
  ) async {
    final mediaList = <MediaMetadata>[];

    for (final file in files) {
      try {
        final data = await file.readAsBytes();
        final fileName = file.path.split('/').last;
        final mimeType = _getMimeTypeFromExtension(fileName);

        final mediaMetadata = await _mediaService.storeMedia(
          data: data,
          fileName: fileName,
          mimeType: mimeType,
          customProperties: {
            'type': 'user_upload',
            'original_path': file.path,
          },
        );

        mediaList.add(mediaMetadata);
        _logger.info('用户文件上传成功: $fileName');
      } catch (e) {
        _logger.error('用户文件上传失败: ${file.path}, $e');
      }
    }

    return mediaList;
  }

  /// 示例4：创建包含多种媒体类型的混合消息
  Future<EnhancedMessage> createMixedMediaMessage({
    required String userText,
    required List<File> imageFiles,
    required List<File> audioFiles,
    required String userName,
  }) async {
    final allMediaFiles = <MediaMetadata>[];

    // 处理图片文件
    for (final imageFile in imageFiles) {
      try {
        final data = await imageFile.readAsBytes();
        final fileName = imageFile.path.split('/').last;

        final mediaMetadata = await _mediaService.storeMedia(
          data: data,
          fileName: fileName,
          mimeType: 'image/jpeg', // 假设是JPEG
          customProperties: {
            'type': 'user_image',
            'category': 'mixed_message',
          },
        );

        allMediaFiles.add(mediaMetadata);
      } catch (e) {
        _logger.error('处理图片文件失败: ${imageFile.path}, $e');
      }
    }

    // 处理音频文件
    for (final audioFile in audioFiles) {
      try {
        final data = await audioFile.readAsBytes();
        final fileName = audioFile.path.split('/').last;

        final mediaMetadata = await _mediaService.storeMedia(
          data: data,
          fileName: fileName,
          mimeType: 'audio/mpeg', // 假设是MP3
          customProperties: {
            'type': 'user_audio',
            'category': 'mixed_message',
          },
        );

        allMediaFiles.add(mediaMetadata);
      } catch (e) {
        _logger.error('处理音频文件失败: ${audioFile.path}, $e');
      }
    }

    // 创建混合媒体消息
    return EnhancedMessage.withMedia(
      author: userName,
      content: userText,
      timestamp: DateTime.now(),
      isFromUser: true,
      mediaFiles: allMediaFiles,
    );
  }

  /// 示例5：检索和显示媒体文件
  Future<Uint8List?> getMediaFileData(MediaMetadata metadata) async {
    try {
      final data = await _mediaService.retrieveMedia(metadata);
      if (data != null) {
        _logger.info('成功检索媒体文件: ${metadata.fileName}');
        return data;
      } else {
        _logger.warning('媒体文件不存在或已过期: ${metadata.fileName}');
        return null;
      }
    } catch (e) {
      _logger.error('检索媒体文件失败: ${metadata.fileName}, $e');
      return null;
    }
  }

  /// 示例6：清理和维护
  Future<void> performMaintenance() async {
    try {
      // 清理过期缓存
      final cleanedCount = await _mediaService.cleanupExpiredCache();
      _logger.info('清理了 $cleanedCount 个过期缓存文件');

      // 获取存储统计
      final stats = await _mediaService.getStorageStats();
      _logger.info('存储统计: $stats');

      // 如果存储空间过大，可以进行额外清理
      final totalSizeBytes = stats['mediaSizeBytes'] as int? ?? 0;
      final maxSizeBytes = 100 * 1024 * 1024; // 100MB限制

      if (totalSizeBytes > maxSizeBytes) {
        _logger.warning('存储空间超过限制，建议清理旧文件');
        // 这里可以实现更复杂的清理逻辑
      }
    } catch (e) {
      _logger.error('维护操作失败: $e');
    }
  }

  /// 示例7：数据导出
  Future<String?> exportConversationMedia(
    List<EnhancedMessage> messages,
    String exportPath,
  ) async {
    try {
      final allMediaFiles = <MediaMetadata>[];
      
      // 收集所有媒体文件
      for (final message in messages) {
        allMediaFiles.addAll(message.mediaFiles);
      }

      // 导出媒体文件
      final exportedFiles = await _mediaService.exportMediaFiles(
        allMediaFiles,
        exportPath,
      );

      _logger.info('导出了 ${exportedFiles.length} 个媒体文件到 $exportPath');
      return exportPath;
    } catch (e) {
      _logger.error('导出媒体文件失败: $e');
      return null;
    }
  }

  /// 辅助方法：根据文件扩展名获取MIME类型
  String _getMimeTypeFromExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }
}
