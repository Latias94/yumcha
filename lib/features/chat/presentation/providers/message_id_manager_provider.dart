import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/message_id_manager.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';

/// MessageIdManager Provider
///
/// 提供统一的消息ID管理器实例
final messageIdManagerProvider = Provider<MessageIdManager>((ref) {
  final messageIdService = ref.read(messageIdServiceProvider);
  return MessageIdManager(messageIdService);
});

/// 流式消息ID列表 Provider
///
/// 提供当前活跃的流式消息ID列表
final activeStreamingMessageIdsProvider = Provider<List<String>>((ref) {
  final manager = ref.read(messageIdManagerProvider);
  return manager.getActiveStreamingMessageIds();
});

/// 消息ID统计信息 Provider
///
/// 提供消息ID管理的统计信息
final messageIdStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final manager = ref.read(messageIdManagerProvider);
  return manager.getStatistics();
});

/// 检查消息是否正在流式处理的 Provider
///
/// 用于检查指定消息ID是否正在进行流式处理
final isStreamingMessageProvider =
    Provider.family<bool, String>((ref, messageId) {
  final manager = ref.read(messageIdManagerProvider);
  return manager.isStreamingMessage(messageId);
});
