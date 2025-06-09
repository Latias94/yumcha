// 🎨 聊天样式状态管理
//
// 管理聊天界面的显示样式设置，提供响应式的样式状态管理。
// 当用户在设置中更改聊天样式时，所有聊天界面会自动更新。
//
// 🎯 **主要功能**:
// - 📱 **样式状态管理**: 管理当前选中的聊天样式
// - 🔄 **自动同步**: 监听设置变化并自动更新界面
// - 💾 **持久化存储**: 自动保存和加载用户的样式偏好
// - 🎨 **响应式更新**: 所有使用样式的组件会自动重建
//
// 🔧 **使用方式**:
// ```dart
// // 在组件中监听样式变化
// final chatStyle = ref.watch(chatStyleProvider);
// 
// // 更新样式
// ref.read(chatStyleProvider.notifier).updateStyle(ChatBubbleStyle.card);
// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_bubble_style.dart';
import '../../../../shared/infrastructure/services/preference_service.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 聊天样式状态类
class ChatStyleState {
  const ChatStyleState({
    required this.style,
    this.isLoading = false,
    this.error,
  });

  /// 当前选中的聊天样式
  final ChatBubbleStyle style;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  ChatStyleState copyWith({
    ChatBubbleStyle? style,
    bool? isLoading,
    String? error,
  }) {
    return ChatStyleState(
      style: style ?? this.style,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 聊天样式状态管理器
class ChatStyleNotifier extends StateNotifier<ChatStyleState> {
  ChatStyleNotifier() : super(const ChatStyleState(style: ChatBubbleStyle.list)) {
    _loadStyle();
  }

  final _preferenceService = PreferenceService();
  final _logger = LoggerService();

  /// 加载保存的样式设置
  Future<void> _loadStyle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final styleValue = await _preferenceService.getChatBubbleStyle();
      final style = ChatBubbleStyle.fromValue(styleValue);
      
      state = state.copyWith(
        style: style,
        isLoading: false,
      );
      
      _logger.debug('聊天样式加载成功', {'style': style.value});
    } catch (e) {
      _logger.error('聊天样式加载失败', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: '加载样式设置失败: $e',
      );
    }
  }

  /// 更新聊天样式
  Future<void> updateStyle(ChatBubbleStyle newStyle) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _preferenceService.saveChatBubbleStyle(newStyle.value);
      
      state = state.copyWith(
        style: newStyle,
        isLoading: false,
      );
      
      _logger.debug('聊天样式更新成功', {'style': newStyle.value});
    } catch (e) {
      _logger.error('聊天样式更新失败', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: '保存样式设置失败: $e',
      );
    }
  }

  /// 重新加载样式设置
  Future<void> reload() async {
    await _loadStyle();
  }
}

/// 聊天样式 Provider
final chatStyleProvider = StateNotifierProvider<ChatStyleNotifier, ChatStyleState>((ref) {
  return ChatStyleNotifier();
});

/// 便捷的样式获取 Provider
final currentChatStyleProvider = Provider<ChatBubbleStyle>((ref) {
  return ref.watch(chatStyleProvider).style;
});
