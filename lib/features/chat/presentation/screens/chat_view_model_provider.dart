import 'package:flutter/widgets.dart';
import 'chat_view_model.dart';

/// ChatViewModel的InheritedWidget，用于在widget树中传递聊天状态
class ChatViewModelProvider extends InheritedWidget {
  /// 创建ChatViewModelProvider
  const ChatViewModelProvider({
    super.key,
    required this.viewModel,
    required super.child,
  });

  /// 聊天视图模型
  final ChatViewModel viewModel;

  /// 从context中获取ChatViewModel
  static ChatViewModel of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ChatViewModelProvider>();
    assert(provider != null, 'No ChatViewModelProvider found in context');
    return provider!.viewModel;
  }

  /// 从context中获取ChatViewModel，如果不存在则返回null
  static ChatViewModel? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ChatViewModelProvider>();
    return provider?.viewModel;
  }

  @override
  bool updateShouldNotify(ChatViewModelProvider oldWidget) {
    return viewModel != oldWidget.viewModel;
  }
}
