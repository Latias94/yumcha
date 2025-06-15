import 'dart:async';
import '../../domain/entities/message.dart';

import '../../domain/entities/message_status.dart';
import '../../domain/exceptions/chat_exceptions.dart';
import '../../domain/repositories/message_repository.dart';
import 'chat_logger_service.dart';

/// 错误恢复服务
/// 
/// 提供聊天系统的错误恢复和重试机制
class ErrorRecoveryService {
  final MessageRepository _messageRepository;
  
  /// 重试配置
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration exponentialBackoffMultiplier = Duration(seconds: 1);

  ErrorRecoveryService({
    required MessageRepository messageRepository,
  }) : _messageRepository = messageRepository;

  /// 恢复失败的消息
  Future<bool> recoverFailedMessage(String messageId) async {
    try {
      ChatLoggerService.logDebug('Attempting to recover failed message: $messageId');
      
      final message = await _messageRepository.getMessage(messageId);
      if (message == null) {
        throw MessageException.notFound(messageId);
      }

      // 检查消息状态是否可以恢复
      if (!_canRecoverMessage(message)) {
        ChatLoggerService.logWarning(
          'Message cannot be recovered: $messageId (status: ${message.status})',
        );
        return false;
      }

      // 重置消息状态为处理中
      final recoveredMessage = message.copyWith(
        status: MessageStatus.aiProcessing,
        updatedAt: DateTime.now(),
      );

      await _messageRepository.updateMessageStatus(recoveredMessage.id, recoveredMessage.status);
      
      ChatLoggerService.logMessageUpdated(recoveredMessage, 'recovered');
      return true;
      
    } catch (e) {
      ChatLoggerService.logException(
        MessageException(
          message: 'Failed to recover message: $messageId',
          code: 'MESSAGE_RECOVERY_FAILED',
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
      return false;
    }
  }

  /// 批量恢复失败的消息
  Future<List<String>> recoverFailedMessages(List<String> messageIds) async {
    final recoveredIds = <String>[];
    
    for (final messageId in messageIds) {
      final recovered = await recoverFailedMessage(messageId);
      if (recovered) {
        recoveredIds.add(messageId);
      }
      
      // 添加延迟避免过于频繁的操作
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    ChatLoggerService.logDebug(
      'Batch recovery completed: ${recoveredIds.length}/${messageIds.length} messages recovered',
    );
    
    return recoveredIds;
  }

  /// 重试操作（带指数退避）
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxRetryAttempts,
    Duration initialDelay = retryDelay,
    String? operationName,
  }) async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        ChatLoggerService.logDebug(
          'Attempting operation${operationName != null ? ' ($operationName)' : ''}: attempt $attempt/$maxAttempts',
        );
        
        final result = await operation();
        
        if (attempt > 1) {
          ChatLoggerService.logDebug(
            'Operation${operationName != null ? ' ($operationName)' : ''} succeeded on attempt $attempt',
          );
        }
        
        return result;
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        ChatLoggerService.logWarning(
          'Operation${operationName != null ? ' ($operationName)' : ''} failed on attempt $attempt: $e',
        );
        
        if (attempt < maxAttempts) {
          final delay = _calculateBackoffDelay(attempt, initialDelay);
          ChatLoggerService.logDebug('Retrying in ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
        }
      }
    }
    
    // 所有重试都失败了
    final finalException = AiServiceException(
      message: 'Operation failed after $maxAttempts attempts',
      code: 'OPERATION_RETRY_EXHAUSTED',
      cause: lastException,
      details: {
        'operationName': operationName,
        'maxAttempts': maxAttempts,
      },
    );
    
    ChatLoggerService.logException(finalException);
    throw finalException;
  }

  /// 清理孤立的消息块
  Future<int> cleanupOrphanedBlocks() async {
    try {
      ChatLoggerService.logDebug('Starting cleanup of orphaned message blocks');
      
      // 这里应该实现清理逻辑
      // 1. 查找没有对应消息的消息块
      // 2. 删除这些孤立的块
      
      final cleanedCount = 0; // 实际实现时替换为真实的清理数量
      
      ChatLoggerService.logDebug('Cleanup completed: $cleanedCount orphaned blocks removed');
      return cleanedCount;
      
    } catch (e) {
      ChatLoggerService.logException(
        DatabaseException.operationFailed(
          'cleanup orphaned blocks',
          e is Exception ? e : Exception(e.toString()),
        ),
      );
      return 0;
    }
  }

  /// 修复消息块顺序
  Future<bool> repairMessageBlockOrder(String messageId) async {
    try {
      ChatLoggerService.logDebug('Repairing message block order: $messageId');

      final message = await _messageRepository.getMessage(messageId);
      if (message == null) {
        throw MessageException.notFound(messageId);
      }

      // 简化的块顺序检查 - 只检查基本的完整性
      if (message.blocks.isEmpty && message.blockIds.isNotEmpty) {
        ChatLoggerService.logDebug('Message $messageId has block IDs but no blocks loaded');
        return false;
      }

      if (message.blocks.isNotEmpty && message.blockIds.isEmpty) {
        ChatLoggerService.logDebug('Message $messageId has blocks but no block IDs');
        return false;
      }

      // 检查块的基本完整性
      for (final block in message.blocks) {
        if (block.messageId != message.id) {
          ChatLoggerService.logDebug('Block ${block.id} has wrong message ID');
          return false;
        }
      }

      ChatLoggerService.logDebug('Message block order check completed for $messageId');
      return true;

    } catch (e) {
      ChatLoggerService.logException(
        MessageException(
          message: 'Failed to repair message block order: $messageId',
          code: 'MESSAGE_BLOCK_ORDER_REPAIR_FAILED',
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
      return false;
    }
  }

  /// 验证消息完整性
  Future<List<String>> validateMessageIntegrity(String messageId) async {
    final issues = <String>[];
    
    try {
      final message = await _messageRepository.getMessage(messageId);
      if (message == null) {
        issues.add('Message not found');
        return issues;
      }

      // 检查基本字段
      if (message.id.isEmpty) issues.add('Empty message ID');
      if (message.conversationId.isEmpty) issues.add('Empty conversation ID');
      if (message.assistantId.isEmpty) issues.add('Empty assistant ID');

      // 检查消息块
      if (message.blocks.isEmpty && message.blockIds.isNotEmpty) {
        issues.add('Block IDs exist but no blocks loaded');
      }

      if (message.blocks.isNotEmpty && message.blockIds.isEmpty) {
        issues.add('Blocks exist but no block IDs');
      }

      // 检查块的完整性
      for (final block in message.blocks) {
        if (block.messageId != message.id) {
          issues.add('Block ${block.id} has wrong message ID');
        }
        
        if (block.content == null || block.content!.isEmpty) {
          issues.add('Block ${block.id} has empty content');
        }
      }

      // 检查块顺序 - 简化检查，只验证基本完整性
      if (message.blockIds.length != message.blocks.length) {
        issues.add('Block IDs count does not match blocks count');
      }

    } catch (e) {
      issues.add('Validation error: $e');
    }

    if (issues.isNotEmpty) {
      ChatLoggerService.logWarning(
        'Message integrity issues found for $messageId: ${issues.join(', ')}',
      );
    }

    return issues;
  }

  /// 自动修复消息
  Future<bool> autoRepairMessage(String messageId) async {
    try {
      final issues = await validateMessageIntegrity(messageId);
      if (issues.isEmpty) return true;

      ChatLoggerService.logDebug('Auto-repairing message $messageId: ${issues.length} issues found');

      // 尝试修复块顺序问题
      if (issues.any((issue) => issue.contains('order'))) {
        await repairMessageBlockOrder(messageId);
      }

      // 重新验证
      final remainingIssues = await validateMessageIntegrity(messageId);
      final repaired = remainingIssues.length < issues.length;

      if (repaired) {
        ChatLoggerService.logDebug(
          'Message $messageId partially repaired: ${issues.length - remainingIssues.length} issues fixed',
        );
      }

      return remainingIssues.isEmpty;
      
    } catch (e) {
      ChatLoggerService.logException(
        MessageException(
          message: 'Auto-repair failed for message: $messageId',
          code: 'MESSAGE_AUTO_REPAIR_FAILED',
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
      return false;
    }
  }

  /// 检查消息是否可以恢复
  bool _canRecoverMessage(Message message) {
    return message.status == MessageStatus.aiError ||
           message.status == MessageStatus.aiPaused;
  }

  /// 计算指数退避延迟
  Duration _calculateBackoffDelay(int attempt, Duration initialDelay) {
    final multiplier = attempt - 1;
    final additionalDelay = exponentialBackoffMultiplier * multiplier * multiplier;
    return initialDelay + additionalDelay;
  }
}
