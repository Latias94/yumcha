import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/streaming_message_service.dart';
import '../../domain/entities/message_status.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';

/// 流式消息服务Provider
final streamingMessageServiceProvider = Provider<StreamingMessageService>((ref) {
  final messageRepository = ref.read(messageRepositoryProvider);
  return StreamingMessageService(messageRepository);
});

/// 流式消息更新流Provider
final streamingMessageUpdateStreamProvider = StreamProvider<StreamingMessageUpdate>((ref) {
  final streamingService = ref.read(streamingMessageServiceProvider);
  return streamingService.updateStream;
});

/// 活跃流式消息数量Provider
final activeStreamingCountProvider = Provider<int>((ref) {
  final streamingService = ref.read(streamingMessageServiceProvider);
  return streamingService.activeStreamingCount;
});

/// 特定消息的流式状态Provider
final messageStreamingStatusProvider = Provider.family<MessageStatus?, String>((ref, messageId) {
  final streamingService = ref.read(streamingMessageServiceProvider);
  return streamingService.getStreamingStatus(messageId);
});

/// 流式消息控制器Provider
/// 
/// 提供流式消息的控制方法，如暂停、恢复、取消等
final streamingMessageControllerProvider = Provider<StreamingMessageController>((ref) {
  final streamingService = ref.read(streamingMessageServiceProvider);
  return StreamingMessageController(streamingService);
});

/// 流式消息控制器
/// 
/// 封装流式消息的控制操作，提供简洁的API
class StreamingMessageController {
  final StreamingMessageService _streamingService;

  StreamingMessageController(this._streamingService);

  /// 初始化流式消息
  Future<void> initializeStreaming({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) async {
    await _streamingService.initializeStreaming(
      messageId: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      metadata: metadata,
    );
  }

  /// 更新流式内容
  Future<void> updateContent({
    required String messageId,
    String? contentDelta,
    String? thinkingDelta,
    String? fullContent,
    String? fullThinking,
    Map<String, dynamic>? metadata,
  }) async {
    await _streamingService.updateContent(
      messageId: messageId,
      contentDelta: contentDelta,
      thinkingDelta: thinkingDelta,
      fullContent: fullContent,
      fullThinking: fullThinking,
      metadata: metadata,
    );
  }

  /// 完成流式消息
  Future<void> completeStreaming({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    await _streamingService.completeStreaming(
      messageId: messageId,
      metadata: metadata,
    );
  }

  /// 暂停流式消息
  Future<void> pauseStreaming(String messageId) async {
    await _streamingService.pauseStreaming(messageId);
  }

  /// 恢复流式消息
  Future<void> resumeStreaming(String messageId) async {
    await _streamingService.resumeStreaming(messageId);
  }

  /// 取消流式消息
  Future<void> cancelStreaming(String messageId) async {
    await _streamingService.cancelStreaming(messageId);
  }

  /// 获取活跃流式消息数量
  int get activeStreamingCount => _streamingService.activeStreamingCount;

  /// 获取流式消息状态
  MessageStatus? getStreamingStatus(String messageId) {
    return _streamingService.getStreamingStatus(messageId);
  }
}
