import '../models/ai_provider.dart' as models;
import '../models/ai_assistant.dart';
import '../models/message.dart';
import 'logger_service.dart';
import 'ai_dart_service.dart';
import '../ai_dart/ai_dart.dart';

/// AI 请求响应结果
class AiRequestResult {
  final String? content;
  final String? thinking;
  final String? error;
  final Duration? duration;
  final UsageInfo? usage;
  final bool wasCancelled;

  const AiRequestResult({
    this.content,
    this.thinking,
    this.error,
    this.duration,
    this.usage,
    this.wasCancelled = false,
  });

  bool get isSuccess => content != null && error == null;
}

/// AI 流式请求事件
class AiStreamEvent {
  final String? content;
  final String? thinkingDelta;
  final String? finalThinking;
  final String? error;
  final bool isDone;
  final UsageInfo? usage;
  final bool wasCancelled;

  const AiStreamEvent({
    this.content,
    this.thinkingDelta,
    this.finalThinking,
    this.error,
    this.isDone = false,
    this.usage,
    this.wasCancelled = false,
  });

  bool get isContent => content != null && !isDone;
  bool get isThinking => thinkingDelta != null;
  bool get isError => error != null;
}

/// AI 请求服务 - 使用新的 AI Dart 库处理请求
class AiRequestService {
  static final AiRequestService _instance = AiRequestService._internal();
  factory AiRequestService() => _instance;
  AiRequestService._internal();

  final LoggerService _logger = LoggerService();
  final AiDartService _aiDartService = AiDartService();

  /// 发送单次聊天请求
  Future<AiRequestResult> sendChatRequest({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async {
    try {
      final result = await _aiDartService.sendChatRequest(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      );

      return AiRequestResult(
        content: result.content,
        thinking: result.thinking,
        error: result.error,
        duration: result.duration,
        usage: result.usage,
      );
    } catch (e) {
      _logger.error('AI 请求服务异常', {'error': e.toString()});
      return AiRequestResult(error: 'AI 请求服务异常: $e', duration: Duration.zero);
    }
  }

  /// 发送流式聊天请求
  Stream<AiStreamEvent> sendChatStreamRequest({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required List<Message> chatHistory,
    required String userMessage,
  }) async* {
    try {
      final stream = _aiDartService.sendChatStreamRequest(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: userMessage,
      );

      await for (final event in stream) {
        yield AiStreamEvent(
          content: event.delta,
          thinkingDelta: event.thinkingDelta,
          finalThinking: event.finalThinking,
          error: event.error,
          isDone: event.isCompleted,
          usage: event.usage,
        );
      }
    } catch (e) {
      _logger.error('AI 流式请求服务异常', {'error': e.toString()});
      yield AiStreamEvent(error: 'AI 流式请求服务异常: $e');
    }
  }

  /// 测试提供商连接
  Future<bool> testProvider({
    required models.AiProvider provider,
    String? modelName,
  }) async {
    try {
      final testModel =
          modelName ?? provider.models.firstOrNull?.name ?? 'gpt-3.5-turbo';
      return await _aiDartService.testProvider(provider, testModel);
    } catch (e) {
      _logger.error('测试提供商异常', {'error': e.toString()});
      return false;
    }
  }
}
