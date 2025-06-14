import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../../../domain/entities/enhanced_message.dart';
import '../../../../domain/entities/message.dart';
import '../../../../../../shared/infrastructure/services/media/media_storage_service.dart';

/// 多媒体集成使用示例
/// 
/// 展示如何在聊天界面中创建和显示包含多媒体内容的消息
class MediaIntegrationExample {
  static final MediaStorageService _mediaService = MediaStorageService();

  /// 示例1：创建包含AI生成图片的消息
  static Future<EnhancedMessage> createAiImageMessage({
    required String aiResponse,
    required String imageUrl,
    required String assistantName,
  }) async {
    try {
      // 模拟下载AI生成的图片数据
      // 在实际应用中，这里会从网络下载图片
      final imageData = _createSampleImageData();
      
      // 存储图片
      final mediaMetadata = await _mediaService.storeMedia(
        data: imageData,
        fileName: 'ai_generated_${DateTime.now().millisecondsSinceEpoch}.png',
        mimeType: 'image/png',
        networkUrl: imageUrl,
        customProperties: {
          'type': 'ai_generated',
          'source': 'dalle',
          'description': 'AI生成的图片',
        },
      );

      // 创建增强消息
      return EnhancedMessage.withAiGeneratedImage(
        author: assistantName,
        content: aiResponse,
        imageUrl: imageUrl,
        imageDescription: 'AI生成的图片',
      );
    } catch (e) {
      // 降级：创建仅包含文本的消息
      return EnhancedMessage(
        author: assistantName,
        content: '$aiResponse\n\n[图片加载失败: $e]',
        timestamp: DateTime.now(),
        isFromUser: false,
      );
    }
  }

  /// 示例2：创建包含TTS音频的消息
  static Future<EnhancedMessage> createTtsAudioMessage({
    required String textContent,
    required String audioUrl,
    required String assistantName,
    Duration? audioDuration,
  }) async {
    try {
      // 模拟下载TTS音频数据
      final audioData = _createSampleAudioData();
      
      // 存储音频
      final mediaMetadata = await _mediaService.storeMedia(
        data: audioData,
        fileName: 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
        mimeType: 'audio/mpeg',
        networkUrl: audioUrl,
        cacheExpiry: const Duration(days: 7), // 7天后过期
        customProperties: {
          'type': 'tts_generated',
          'text_length': textContent.length,
          'duration_ms': audioDuration?.inMilliseconds,
        },
      );

      // 创建增强消息
      return EnhancedMessage.withTtsAudio(
        author: assistantName,
        content: textContent,
        audioUrl: audioUrl,
        audioDuration: audioDuration,
      );
    } catch (e) {
      // 降级：创建仅包含文本的消息
      return EnhancedMessage(
        author: assistantName,
        content: '$textContent\n\n[音频加载失败: $e]',
        timestamp: DateTime.now(),
        isFromUser: false,
      );
    }
  }

  /// 示例3：创建包含多种媒体类型的混合消息
  static Future<EnhancedMessage> createMixedMediaMessage({
    required String userText,
    required String userName,
    List<String> imageUrls = const [],
    List<String> audioUrls = const [],
  }) async {
    final allMediaFiles = <MediaMetadata>[];

    // 处理图片
    for (int i = 0; i < imageUrls.length; i++) {
      try {
        final imageData = _createSampleImageData();
        
        final mediaMetadata = await _mediaService.storeMedia(
          data: imageData,
          fileName: 'user_image_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
          networkUrl: imageUrls[i],
          customProperties: {
            'type': 'user_image',
            'category': 'mixed_message',
            'index': i,
          },
        );

        allMediaFiles.add(mediaMetadata);
      } catch (e) {
        // 忽略单个文件的错误，继续处理其他文件
        debugPrint('处理图片失败: ${imageUrls[i]}, $e');
      }
    }

    // 处理音频
    for (int i = 0; i < audioUrls.length; i++) {
      try {
        final audioData = _createSampleAudioData();
        
        final mediaMetadata = await _mediaService.storeMedia(
          data: audioData,
          fileName: 'user_audio_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.mp3',
          mimeType: 'audio/mpeg',
          networkUrl: audioUrls[i],
          customProperties: {
            'type': 'user_audio',
            'category': 'mixed_message',
            'index': i,
          },
        );

        allMediaFiles.add(mediaMetadata);
      } catch (e) {
        // 忽略单个文件的错误，继续处理其他文件
        debugPrint('处理音频失败: ${audioUrls[i]}, $e');
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

  /// 示例4：从现有Message创建EnhancedMessage
  static EnhancedMessage enhanceExistingMessage(
    Message originalMessage, {
    List<MediaMetadata>? mediaFiles,
  }) {
    return EnhancedMessage.fromMessage(
      originalMessage,
      mediaFiles: mediaFiles,
    );
  }

  /// 示例5：检查消息的多媒体内容
  static void analyzeMessageMedia(EnhancedMessage message) {
    debugPrint('=== 消息多媒体分析 ===');
    debugPrint('消息ID: ${message.id}');
    debugPrint('作者: ${message.author}');
    debugPrint('是否包含多媒体: ${message.hasMediaFiles}');
    
    if (message.hasMediaFiles) {
      debugPrint('多媒体文件总数: ${message.mediaFiles.length}');
      debugPrint('总大小: ${message.formattedTotalMediaSize}');
      
      if (message.hasImages) {
        debugPrint('图片数量: ${message.imageFiles.length}');
        for (final image in message.imageFiles) {
          debugPrint('  - ${image.fileName} (${image.formattedSize})');
        }
      }
      
      if (message.hasAudio) {
        debugPrint('音频数量: ${message.audioFiles.length}');
        for (final audio in message.audioFiles) {
          debugPrint('  - ${audio.fileName} (${audio.formattedSize})');
        }
      }
      
      if (message.hasVideo) {
        debugPrint('视频数量: ${message.videoFiles.length}');
        for (final video in message.videoFiles) {
          debugPrint('  - ${video.fileName} (${video.formattedSize})');
        }
      }
    }
    debugPrint('==================');
  }

  /// 示例6：演示如何在UI中使用
  static Widget buildExampleChatMessage(EnhancedMessage message) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 消息头部
            Row(
              children: [
                Icon(
                  message.isFromUser ? Icons.person : Icons.smart_toy,
                  color: message.isFromUser ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  message.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 消息内容
            Text(message.content),
            
            // 多媒体内容指示器
            if (message.hasMediaFiles) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '多媒体内容:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (message.hasImages)
                      Text('📷 ${message.imageFiles.length} 张图片'),
                    if (message.hasAudio)
                      Text('🎵 ${message.audioFiles.length} 个音频'),
                    if (message.hasVideo)
                      Text('🎬 ${message.videoFiles.length} 个视频'),
                    Text('总大小: ${message.formattedTotalMediaSize}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 辅助方法

  /// 创建示例图片数据（实际应用中会从网络或文件系统获取）
  static Uint8List _createSampleImageData() {
    // 创建一个简单的1x1像素PNG图片的字节数据
    const pngHeader = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
      0x49, 0x48, 0x44, 0x52, // IHDR
      0x00, 0x00, 0x00, 0x01, // width: 1
      0x00, 0x00, 0x00, 0x01, // height: 1
      0x08, 0x02, 0x00, 0x00, 0x00, // bit depth, color type, compression, filter, interlace
      0x90, 0x77, 0x53, 0xDE, // CRC
      0x00, 0x00, 0x00, 0x0C, // IDAT chunk length
      0x49, 0x44, 0x41, 0x54, // IDAT
      0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, // compressed data
      0xE2, 0x21, 0xBC, 0x33, // CRC
      0x00, 0x00, 0x00, 0x00, // IEND chunk length
      0x49, 0x45, 0x4E, 0x44, // IEND
      0xAE, 0x42, 0x60, 0x82, // CRC
    ];
    return Uint8List.fromList(pngHeader);
  }

  /// 创建示例音频数据（实际应用中会从网络或文件系统获取）
  static Uint8List _createSampleAudioData() {
    // 创建一个简单的MP3文件头部字节数据
    const mp3Header = [
      0xFF, 0xFB, 0x90, 0x00, // MP3 frame header
      // 这里只是示例数据，实际的MP3文件会更复杂
    ];
    // 添加一些填充数据来模拟音频内容
    final data = List<int>.from(mp3Header);
    data.addAll(List.filled(1024, 0)); // 添加1KB的填充数据
    return Uint8List.fromList(data);
  }

  /// 格式化时间戳
  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
