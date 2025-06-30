import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import '../state/message_block_state.dart';
import 'deduplication_manager.dart';

/// Tool call execution status
enum ToolCallExecutionStatus {
  /// Tool call is pending execution
  pending,

  /// Tool call is currently being executed
  executing,

  /// Tool call completed successfully
  completed,

  /// Tool call failed with error
  failed,

  /// Tool call was cancelled
  cancelled,
}

/// Tool call execution result
class ToolCallResult {
  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> arguments;
  final String? result;
  final String? error;
  final ToolCallExecutionStatus status;
  final DateTime timestamp;
  final Duration? executionTime;
  final Map<String, dynamic> metadata;

  ToolCallResult({
    required this.toolCallId,
    required this.toolName,
    required this.arguments,
    this.result,
    this.error,
    required this.status,
    DateTime? timestamp,
    this.executionTime,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess =>
      status == ToolCallExecutionStatus.completed && error == null;
  bool get isError => status == ToolCallExecutionStatus.failed || error != null;
  bool get isPending => status == ToolCallExecutionStatus.pending;
  bool get isExecuting => status == ToolCallExecutionStatus.executing;

  /// Convert to formatted message for AI
  String toAIMessage() {
    if (isError) {
      return '''Tool Call Error:
Tool: $toolName
Arguments: ${jsonEncode(arguments)}
Error: ${error ?? 'Unknown error'}

Please inform the user that the tool call failed and suggest alternative approaches.''';
    }

    return '''Tool Call Result:
Tool: $toolName
Arguments: ${jsonEncode(arguments)}
Result: ${result ?? 'No result'}

Please use this information to answer the user's question.''';
  }

  /// Convert to message block
  EnhancedMessageBlock toMessageBlock(String messageId, int order) {
    return EnhancedMessageBlock(
      id: '${messageId}_tool_$toolCallId',
      messageId: messageId,
      type: EnhancedMessageBlockType.tool,
      content: result ?? error ?? '',
      status: isSuccess
          ? MessageBlockStatus.success
          : isError
              ? MessageBlockStatus.error
              : MessageBlockStatus.processing,
      createdAt: timestamp,
      updatedAt: timestamp,
      order: order,
      toolCallInfo: ToolCallInfo(
        callId: toolCallId,
        toolName: toolName,
        arguments: arguments,
        response: result,
        status: _mapToToolCallStatus(status),
        errorMessage: error,
        executionTimeMs: executionTime?.inMilliseconds,
      ),
      metadata: {
        'toolCallId': toolCallId,
        'toolName': toolName,
        'executionTime': executionTime?.inMilliseconds,
        ...metadata,
      },
    );
  }

  ToolCallStatus _mapToToolCallStatus(ToolCallExecutionStatus status) {
    switch (status) {
      case ToolCallExecutionStatus.pending:
        return ToolCallStatus.pending;
      case ToolCallExecutionStatus.executing:
        return ToolCallStatus.executing;
      case ToolCallExecutionStatus.completed:
        return ToolCallStatus.completed;
      case ToolCallExecutionStatus.failed:
        return ToolCallStatus.failed;
      case ToolCallExecutionStatus.cancelled:
        return ToolCallStatus.cancelled;
    }
  }

  @override
  String toString() =>
      'ToolCallResult(id: $toolCallId, tool: $toolName, status: $status)';
}

/// Tool call handler for managing tool execution and result formatting
///
/// This class handles the complete lifecycle of tool calls, ensuring that
/// tool results are properly formatted and transmitted to the AI model.
/// Inspired by Cherry Studio's tool call management.
///
/// Key features:
/// - Complete tool call lifecycle management
/// - Proper result formatting for AI consumption
/// - Error handling and recovery
/// - Deduplication of tool calls
/// - Message block integration
class ToolCallHandler {
  /// Active tool calls (toolCallId -> ToolCallResult)
  final Map<String, ToolCallResult> _activeToolCalls = {};

  /// Tool call history (for debugging and analytics)
  final List<ToolCallResult> _toolCallHistory = [];

  /// Tool call listeners
  final Map<String, List<Function(ToolCallResult)>> _listeners = {};

  /// Deduplication manager
  late final DeduplicationManager _deduplicationManager;

  /// Maximum history size
  static const int _maxHistorySize = 100;

  /// Tool call timeout duration
  static const Duration _toolCallTimeout = Duration(minutes: 2);

  ToolCallHandler() {
    _deduplicationManager = DeduplicationManager.instance;
  }

  /// Start a tool call execution
  Future<ToolCallResult> startToolCall({
    required String toolCallId,
    required String toolName,
    required Map<String, dynamic> arguments,
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Starting tool call: $toolName ($toolCallId)',
          name: 'ToolCallHandler');

      // Check for duplicate tool calls
      final deduplicationKey = _generateToolCallKey(toolName, arguments);
      if (!_deduplicationManager.shouldAllowRequest(
        deduplicationKey,
        metadata: {
          'type': 'tool_call',
          'toolName': toolName,
          'toolCallId': toolCallId,
        },
        throwOnDuplicate: false,
      )) {
        developer.log('Duplicate tool call detected, skipping: $toolCallId',
            name: 'ToolCallHandler');
        return ToolCallResult(
          toolCallId: toolCallId,
          toolName: toolName,
          arguments: arguments,
          error: 'Duplicate tool call detected',
          status: ToolCallExecutionStatus.failed,
          metadata: metadata ?? {},
        );
      }

      // Create initial result
      final result = ToolCallResult(
        toolCallId: toolCallId,
        toolName: toolName,
        arguments: arguments,
        status: ToolCallExecutionStatus.executing,
        metadata: metadata ?? {},
      );

      // Store active tool call
      _activeToolCalls[toolCallId] = result;

      // Notify listeners
      _notifyListeners(toolCallId, result);

      developer.log('Tool call started: $toolCallId', name: 'ToolCallHandler');
      return result;
    } catch (error) {
      developer.log('Failed to start tool call: $toolCallId, error: $error',
          name: 'ToolCallHandler');

      final errorResult = ToolCallResult(
        toolCallId: toolCallId,
        toolName: toolName,
        arguments: arguments,
        error: error.toString(),
        status: ToolCallExecutionStatus.failed,
        metadata: metadata ?? {},
      );

      _addToHistory(errorResult);
      return errorResult;
    }
  }

  /// Complete a tool call with success result
  Future<ToolCallResult> completeToolCall({
    required String toolCallId,
    required String result,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Completing tool call: $toolCallId',
          name: 'ToolCallHandler');

      final activeCall = _activeToolCalls[toolCallId];
      if (activeCall == null) {
        throw Exception('Tool call not found: $toolCallId');
      }

      // Create completed result
      final completedResult = ToolCallResult(
        toolCallId: toolCallId,
        toolName: activeCall.toolName,
        arguments: activeCall.arguments,
        result: result,
        status: ToolCallExecutionStatus.completed,
        executionTime: executionTime,
        metadata: {
          ...activeCall.metadata,
          ...?metadata,
        },
      );

      // Remove from active calls
      _activeToolCalls.remove(toolCallId);

      // Add to history
      _addToHistory(completedResult);

      // Notify listeners
      _notifyListeners(toolCallId, completedResult);

      developer.log(
          'Tool call completed: $toolCallId, result length: ${result.length}',
          name: 'ToolCallHandler');
      return completedResult;
    } catch (error) {
      developer.log('Failed to complete tool call: $toolCallId, error: $error',
          name: 'ToolCallHandler');
      return await failToolCall(
        toolCallId: toolCallId,
        error: error.toString(),
        executionTime: executionTime,
        metadata: metadata,
      );
    }
  }

  /// Fail a tool call with error
  Future<ToolCallResult> failToolCall({
    required String toolCallId,
    required String error,
    Duration? executionTime,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Failing tool call: $toolCallId, error: $error',
          name: 'ToolCallHandler');

      final activeCall = _activeToolCalls[toolCallId];
      if (activeCall == null) {
        throw Exception('Tool call not found: $toolCallId');
      }

      // Create failed result
      final failedResult = ToolCallResult(
        toolCallId: toolCallId,
        toolName: activeCall.toolName,
        arguments: activeCall.arguments,
        error: error,
        status: ToolCallExecutionStatus.failed,
        executionTime: executionTime,
        metadata: {
          ...activeCall.metadata,
          ...?metadata,
        },
      );

      // Remove from active calls
      _activeToolCalls.remove(toolCallId);

      // Add to history
      _addToHistory(failedResult);

      // Notify listeners
      _notifyListeners(toolCallId, failedResult);

      developer.log('Tool call failed: $toolCallId', name: 'ToolCallHandler');
      return failedResult;
    } catch (handlingError) {
      developer.log(
          'Failed to handle tool call failure: $toolCallId, error: $handlingError',
          name: 'ToolCallHandler');

      // Create emergency failed result
      final emergencyResult = ToolCallResult(
        toolCallId: toolCallId,
        toolName: 'unknown',
        arguments: {},
        error: 'Failed to handle tool call failure: $handlingError',
        status: ToolCallExecutionStatus.failed,
        metadata: metadata ?? {},
      );

      _addToHistory(emergencyResult);
      return emergencyResult;
    }
  }

  /// Cancel a tool call
  Future<ToolCallResult> cancelToolCall({
    required String toolCallId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Cancelling tool call: $toolCallId, reason: $reason',
          name: 'ToolCallHandler');

      final activeCall = _activeToolCalls[toolCallId];
      if (activeCall == null) {
        throw Exception('Tool call not found: $toolCallId');
      }

      // Create cancelled result
      final cancelledResult = ToolCallResult(
        toolCallId: toolCallId,
        toolName: activeCall.toolName,
        arguments: activeCall.arguments,
        error: reason ?? 'Tool call cancelled',
        status: ToolCallExecutionStatus.cancelled,
        metadata: {
          ...activeCall.metadata,
          ...?metadata,
        },
      );

      // Remove from active calls
      _activeToolCalls.remove(toolCallId);

      // Add to history
      _addToHistory(cancelledResult);

      // Notify listeners
      _notifyListeners(toolCallId, cancelledResult);

      developer.log('Tool call cancelled: $toolCallId',
          name: 'ToolCallHandler');
      return cancelledResult;
    } catch (error) {
      developer.log('Failed to cancel tool call: $toolCallId, error: $error',
          name: 'ToolCallHandler');
      rethrow;
    }
  }

  /// Get tool call result
  ToolCallResult? getToolCallResult(String toolCallId) {
    // Check active calls first
    final activeCall = _activeToolCalls[toolCallId];
    if (activeCall != null) return activeCall;

    // Check history
    try {
      return _toolCallHistory
          .firstWhere((result) => result.toolCallId == toolCallId);
    } catch (e) {
      return null;
    }
  }

  /// Get all active tool calls
  List<ToolCallResult> getActiveToolCalls() {
    return _activeToolCalls.values.toList();
  }

  /// Get tool call history
  List<ToolCallResult> getToolCallHistory({int? limit}) {
    final history = List<ToolCallResult>.from(_toolCallHistory.reversed);
    if (limit != null && history.length > limit) {
      return history.take(limit).toList();
    }
    return history;
  }

  /// Add tool call listener
  void addListener(String toolCallId, Function(ToolCallResult) listener) {
    if (!_listeners.containsKey(toolCallId)) {
      _listeners[toolCallId] = [];
    }
    _listeners[toolCallId]!.add(listener);
  }

  /// Remove tool call listener
  void removeListener(String toolCallId, Function(ToolCallResult) listener) {
    _listeners[toolCallId]?.remove(listener);
    if (_listeners[toolCallId]?.isEmpty == true) {
      _listeners.remove(toolCallId);
    }
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final totalCalls = _toolCallHistory.length;
    final successfulCalls = _toolCallHistory.where((r) => r.isSuccess).length;
    final failedCalls = _toolCallHistory.where((r) => r.isError).length;

    return {
      'totalCalls': totalCalls,
      'activeCalls': _activeToolCalls.length,
      'successfulCalls': successfulCalls,
      'failedCalls': failedCalls,
      'successRate': totalCalls > 0 ? successfulCalls / totalCalls : 0.0,
      'failureRate': totalCalls > 0 ? failedCalls / totalCalls : 0.0,
      'averageExecutionTime': _calculateAverageExecutionTime(),
    };
  }

  /// Generate tool call key for deduplication
  String _generateToolCallKey(String toolName, Map<String, dynamic> arguments) {
    final keyData = {
      'toolName': toolName,
      'arguments': arguments,
    };
    return _deduplicationManager.generateRequestKey(
      content: jsonEncode(keyData),
      additionalContext: {'type': 'tool_call'},
    );
  }

  /// Add result to history
  void _addToHistory(ToolCallResult result) {
    _toolCallHistory.add(result);

    // Maintain history size limit
    if (_toolCallHistory.length > _maxHistorySize) {
      _toolCallHistory.removeAt(0);
    }
  }

  /// Notify listeners
  void _notifyListeners(String toolCallId, ToolCallResult result) {
    final listeners = _listeners[toolCallId];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(result);
        } catch (error) {
          developer.log('Error in tool call listener: $error',
              name: 'ToolCallHandler');
        }
      }
    }
  }

  /// Calculate average execution time
  double _calculateAverageExecutionTime() {
    final completedCalls =
        _toolCallHistory.where((r) => r.executionTime != null).toList();

    if (completedCalls.isEmpty) return 0.0;

    final totalTime = completedCalls.fold<int>(
      0,
      (sum, call) => sum + call.executionTime!.inMilliseconds,
    );

    return totalTime / completedCalls.length;
  }

  /// Dispose of the handler
  void dispose() {
    _activeToolCalls.clear();
    _toolCallHistory.clear();
    _listeners.clear();

    developer.log('ToolCallHandler disposed', name: 'ToolCallHandler');
  }
}

/// Tool call integration service for seamless AI integration
///
/// This service provides high-level integration between tool calls and AI models,
/// ensuring that tool results are properly formatted and integrated into the
/// conversation context.
class ToolCallIntegrationService {
  final ToolCallHandler _toolCallHandler;

  ToolCallIntegrationService(this._toolCallHandler);

  /// Process tool calls and format results for AI
  Future<List<String>> processToolCallsForAI({
    required List<Map<String, dynamic>> toolCalls,
    required String messageId,
    required Future<String> Function(
            String toolName, Map<String, dynamic> arguments)
        executeToolCall,
  }) async {
    final results = <String>[];

    for (final toolCallData in toolCalls) {
      final toolCallId = toolCallData['id'] as String;
      final toolName = toolCallData['function']['name'] as String;
      final arguments =
          toolCallData['function']['arguments'] as Map<String, dynamic>;

      try {
        // Start tool call
        await _toolCallHandler.startToolCall(
          toolCallId: toolCallId,
          toolName: toolName,
          arguments: arguments,
          messageId: messageId,
        );

        // Execute tool call
        final startTime = DateTime.now();
        final result = await executeToolCall(toolName, arguments);
        final executionTime = DateTime.now().difference(startTime);

        // Complete tool call
        final toolResult = await _toolCallHandler.completeToolCall(
          toolCallId: toolCallId,
          result: result,
          executionTime: executionTime,
        );

        // Format for AI
        results.add(toolResult.toAIMessage());
      } catch (error) {
        // Handle tool call failure
        final toolResult = await _toolCallHandler.failToolCall(
          toolCallId: toolCallId,
          error: error.toString(),
        );

        // Format error for AI
        results.add(toolResult.toAIMessage());
      }
    }

    return results;
  }

  /// Create message blocks from tool call results
  List<EnhancedMessageBlock> createToolCallBlocks({
    required String messageId,
    required List<String> toolCallIds,
    int startOrder = 0,
  }) {
    final blocks = <EnhancedMessageBlock>[];

    for (int i = 0; i < toolCallIds.length; i++) {
      final toolCallId = toolCallIds[i];
      final result = _toolCallHandler.getToolCallResult(toolCallId);

      if (result != null) {
        blocks.add(result.toMessageBlock(messageId, startOrder + i));
      }
    }

    return blocks;
  }

  /// Format tool call results for conversation context
  String formatToolCallsForContext(List<String> toolCallIds) {
    final results = <String>[];

    for (final toolCallId in toolCallIds) {
      final result = _toolCallHandler.getToolCallResult(toolCallId);
      if (result != null) {
        results.add(result.toAIMessage());
      }
    }

    return results.join('\n\n');
  }
}
