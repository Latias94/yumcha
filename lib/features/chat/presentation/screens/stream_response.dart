import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/infrastructure/services/ai/core/ai_response_models.dart';

/// 流式响应处理器 - 管理AI流式输出
class StreamResponse {
  StreamResponse({required this.stream, this.onUpdate, this.onDone}) {
    _startListening();
  }

  /// 流式数据源
  final Stream<AiStreamEvent> stream;

  /// 内容更新回调
  final VoidCallback? onUpdate;

  /// 完成回调（包含错误处理）
  final void Function(String? error)? onDone;

  String _content = '';
  String _thinking = '';
  StreamSubscription<AiStreamEvent>? _subscription;
  bool _isCanceled = false;
  bool _isDone = false;

  /// 获取当前累积的内容
  String get content => _content;

  /// 获取当前累积的思考内容
  String get thinking => _thinking;

  /// 获取完整的内容（包含思考内容）
  String get fullContent {
    if (_thinking.isNotEmpty) {
      return '<think>\n$_thinking\n</think>\n\n$_content';
    }
    return _content;
  }

  /// 是否已被取消
  bool get isCanceled => _isCanceled;

  /// 是否已完成
  bool get isDone => _isDone;

  void _startListening() {
    _subscription = stream.listen(
      (event) {
        if (_isCanceled || _isDone) return;

        if (event.error != null) {
          _isDone = true;
          onDone?.call(event.error);
        } else if (event.contentDelta != null) {
          _content += event.contentDelta!;
          onUpdate?.call();
        } else if (event.thinkingDelta != null) {
          _thinking += event.thinkingDelta!;
          onUpdate?.call();
        } else if (event.isDone) {
          _isDone = true;
          onDone?.call(null);
        }
      },
      onError: (error) {
        if (_isCanceled || _isDone) return;

        _isDone = true;
        onDone?.call('流式响应错误: $error');
      },
      onDone: () {
        if (_isCanceled || _isDone) return;

        _isDone = true;
        onDone?.call(null);
      },
    );
  }

  /// 取消流式响应
  void cancel() {
    if (_isDone) return;

    _isCanceled = true;
    _isDone = true;
    _subscription?.cancel();
    onDone?.call('已取消');
  }

  /// 释放资源
  void dispose() {
    _subscription?.cancel();
  }
}
