import 'package:flutter/foundation.dart';

/// 简化的状态更新管理器
///
/// 不再使用去重逻辑，确保所有状态更新都被及时处理
class StateUpdateDeduplicator {
  StateUpdateDeduplicator({
    Duration? minInterval, // 保留参数兼容性，但不使用
  });

  /// 检查是否应该执行更新（简化版本，总是返回true）
  bool shouldUpdate(String key) {
    // 不再使用去重逻辑，所有更新都被允许
    return true;
  }

  /// 延迟执行更新（简化版本，立即执行）
  void scheduleUpdate(String key, VoidCallback callback) {
    // 不再使用延迟和去重，立即执行回调
    callback();
  }

  /// 强制执行更新（简化版本，立即执行）
  void forceUpdate(String key, VoidCallback callback) {
    // 不再使用去重，立即执行回调
    callback();
  }

  /// 取消待处理的更新（简化版本，无操作）
  void cancelUpdate(String key) {
    // 简化版本中没有待处理的更新需要取消
  }

  /// 获取统计信息
  StateUpdateStats getStats() {
    return StateUpdateStats(
      totalKeys: 0, // 不再跟踪键
      pendingUpdates: 0, // 不再有待处理的更新
      oldestRecord: null, // 不再跟踪记录
    );
  }

  /// 释放资源（简化版本）
  void dispose() {
    // 简化版本中没有需要清理的资源
  }
}

/// 状态更新统计信息
class StateUpdateStats {
  final int totalKeys;
  final int pendingUpdates;
  final DateTime? oldestRecord;

  const StateUpdateStats({
    required this.totalKeys,
    required this.pendingUpdates,
    this.oldestRecord,
  });

  @override
  String toString() {
    return 'StateUpdateStats(totalKeys: $totalKeys, pendingUpdates: $pendingUpdates, oldestRecord: $oldestRecord)';
  }
}

/// 简化的消息状态更新管理器
///
/// 不再使用去重逻辑，确保所有消息更新都被及时处理
class MessageStateDeduplicator extends StateUpdateDeduplicator {
  MessageStateDeduplicator() : super();

  /// 标记消息为流式状态（保留接口兼容性）
  void markAsStreaming(String messageId) {
    // 简化版本中不需要特殊标记
  }

  /// 取消流式状态标记（保留接口兼容性）
  void unmarkAsStreaming(String messageId) {
    // 简化版本中不需要特殊处理
  }

  /// 检查消息内容更新是否应该执行（总是返回true）
  bool shouldUpdateMessageContent(String messageId, String newContent) {
    // 不再使用去重逻辑，所有更新都被允许
    return true;
  }

  /// 检查消息状态更新是否应该执行（总是返回true）
  bool shouldUpdateMessageStatus(String messageId, String newStatus) {
    // 不再使用去重逻辑，所有更新都被允许
    return true;
  }

  /// 调度消息内容更新（立即执行）
  void scheduleMessageContentUpdate(
      String messageId, String newContent, VoidCallback callback) {
    // 不再使用延迟，立即执行回调
    callback();
  }

  /// 调度消息状态更新（立即执行）
  void scheduleMessageStatusUpdate(
      String messageId, String newStatus, VoidCallback callback) {
    // 不再使用延迟，立即执行回调
    callback();
  }

  @override
  void dispose() {
    // 简化版本中没有需要清理的资源
    super.dispose();
  }
}

/// 简化的流式更新管理器
///
/// 不再使用去重逻辑，确保所有流式更新都被及时处理
class StreamingUpdateDeduplicator extends StateUpdateDeduplicator {
  StreamingUpdateDeduplicator() : super();

  /// 检查流式更新是否应该执行（总是返回true）
  bool shouldUpdateStreaming(String messageId) {
    // 不再使用去重逻辑，所有更新都被允许
    return true;
  }

  /// 调度流式更新（立即执行）
  void scheduleStreamingUpdate(String messageId, VoidCallback callback) {
    // 不再使用延迟，立即执行回调
    callback();
  }

  /// 强制执行流式更新完成（立即执行）
  void forceStreamingComplete(String messageId, VoidCallback callback) {
    // 不再使用延迟，立即执行回调
    callback();
  }
}

/// 全局去重器实例
class GlobalDeduplicators {
  static final StateUpdateDeduplicator _general = StateUpdateDeduplicator();
  static final MessageStateDeduplicator _message = MessageStateDeduplicator();
  static final StreamingUpdateDeduplicator _streaming =
      StreamingUpdateDeduplicator();

  /// 通用状态更新去重器
  static StateUpdateDeduplicator get general => _general;

  /// 消息状态更新去重器
  static MessageStateDeduplicator get message => _message;

  /// 流式更新去重器
  static StreamingUpdateDeduplicator get streaming => _streaming;

  /// 释放所有资源
  static void disposeAll() {
    _general.dispose();
    _message.dispose();
    _streaming.dispose();
  }
}
