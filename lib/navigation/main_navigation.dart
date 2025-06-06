// 🏠 主导航界面
//
// YumCha 应用的主要导航容器，提供应用的核心界面结构。
// 集成了侧边栏导航、聊天界面和状态管理，是用户的主要交互界面。
//
// 🎯 **主要功能**:
// - 🏠 **主界面容器**: 作为应用的主要界面容器和导航中心
// - 📱 **侧边栏集成**: 集成 AppDrawer 提供导航和聊天历史
// - 💬 **聊天界面**: 嵌入 ChatScreen 提供聊天功能
// - 🔄 **状态管理**: 管理当前对话状态和界面状态
// - 🚀 **深度链接**: 支持通过 URL 直接打开特定对话
// - ➕ **新建对话**: 提供创建新对话的快捷操作
// - 🔍 **初始化处理**: 处理应用启动时的初始化逻辑
//
// 🏗️ **架构特点**:
// - 使用 ConsumerStatefulWidget 集成 Riverpod 状态管理
// - 支持初始对话 ID 和消息 ID 的传递
// - 提供完整的错误处理和加载状态
// - 集成日志记录和调试信息
//
// 📱 **界面组成**:
// - AppBar: 显示当前对话标题和新建对话按钮
// - Drawer: 侧边栏导航和聊天历史列表
// - Body: 主要内容区域，显示聊天界面或状态页面
//
// 🔄 **状态处理**:
// - 加载状态：显示加载指示器
// - 错误状态：显示错误信息和重试按钮
// - 正常状态：显示聊天界面
// - 空状态：显示初始化提示

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/app_drawer.dart';
import '../screens/chat_screen.dart';
import '../providers/conversation_notifier.dart';
import '../services/logger_service.dart';

/// 主导航界面组件
///
/// YumCha 应用的核心导航容器，提供完整的应用界面结构。
/// 支持深度链接、状态管理和用户交互。
///
/// **核心功能**:
/// - 🏠 作为应用的主要界面容器
/// - 📱 集成侧边栏导航和聊天功能
/// - 🔗 支持深度链接直接打开特定对话
/// - 🔄 管理对话状态和界面状态
/// - ➕ 提供新建对话的快捷操作
///
/// **参数说明**:
/// - [initialConversationId]: 初始要打开的对话 ID（用于深度链接）
/// - [initialMessageId]: 初始要定位的消息 ID（用于消息链接）
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({
    super.key,
    this.initialConversationId,
    this.initialMessageId,
  });

  /// 初始对话 ID
  ///
  /// 用于深度链接场景，应用启动时直接打开指定的对话。
  /// 如果为 null，则显示默认状态或最近的对话。
  final String? initialConversationId;

  /// 初始消息 ID
  ///
  /// 用于消息链接场景，打开对话后定位到指定的消息。
  /// 通常与 initialConversationId 一起使用。
  final String? initialMessageId;

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

/// 主导航界面状态管理类
///
/// 负责管理主导航界面的状态和生命周期。
/// 处理初始化逻辑、对话切换和界面更新。
class _MainNavigationState extends ConsumerState<MainNavigation> {
  /// 日志服务实例
  static final LoggerService _logger = LoggerService();

  /// 是否已完成初始化
  ///
  /// 用于防止重复初始化，确保初始对话只加载一次。
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    _logger.info('MainNavigation initState 被调用', {
      'initialConversationId': widget.initialConversationId,
      'initialMessageId': widget.initialMessageId,
    });

    // 如果有初始对话ID，在下一帧开始加载
    if (widget.initialConversationId != null) {
      _logger.info('MainNavigation初始化，准备加载对话', {
        'conversationId': widget.initialConversationId,
        'messageId': widget.initialMessageId,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasInitialized) {
          _logger.info('开始加载初始对话', {
            'conversationId': widget.initialConversationId,
          });
          final conversationNotifier = ref.read(
            currentConversationProvider.notifier,
          );
          conversationNotifier.switchToConversation(
            widget.initialConversationId!,
          );
          setState(() {
            _hasInitialized = true;
          });
        }
      });
    } else {
      _logger.info('MainNavigation 没有初始对话ID，将显示默认状态');
    }
  }

  /// 创建新聊天并导航到新页面
  ///
  /// 创建一个新的对话，并使用页面替换的方式刷新界面。
  /// 这样可以确保新对话的状态正确初始化，并提供流畅的用户体验。
  ///
  /// **执行流程**:
  /// 1. 通过 ConversationNotifier 创建新对话
  /// 2. 检查 context 是否仍然有效（防止异步操作后 widget 已销毁）
  /// 3. 使用 pushReplacement 替换当前页面，触发重新构建
  /// 4. 新页面将显示刚创建的对话
  ///
  /// **参数说明**:
  /// - [context]: 当前的构建上下文
  /// - [ref]: Riverpod 的 WidgetRef，用于访问状态管理
  ///
  /// **注意事项**:
  /// - 使用异步操作，需要检查 context.mounted
  /// - 使用 pushReplacement 而不是 setState，确保状态完全重置
  void _createNewChatWithAnimation(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(currentConversationProvider.notifier);

    // 先创建新对话
    await notifier.createNewConversation();

    // 检查 context 是否仍然有效
    if (!context.mounted) return;

    // 使用 pushReplacement 替换当前页面
    // 使用默认的页面转场动画
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(currentConversationProvider);
    final conversationNotifier = ref.read(currentConversationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(conversationState)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _createNewChatWithAnimation(context, ref);
            },
            tooltip: '新对话',
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedMenu: conversationState.selectedMenu,
        onChatClicked: (chatId) {
          _logger.debug('MainNavigation 收到点击事件', {'chatId': chatId});
          // 防止在加载状态时重复点击
          if (!conversationState.isLoading) {
            conversationNotifier.switchToConversation(chatId);
            Navigator.of(context).pop(); // Close drawer
          }
        },
        onProfileClicked: (String userId) {}, // 移除profile功能，保留空实现避免错误
      ),
      body: _getCurrentScreen(conversationState, conversationNotifier),
    );
  }

  /// 获取 AppBar 标题
  ///
  /// 根据当前对话状态动态生成 AppBar 的标题文本。
  ///
  /// **逻辑说明**:
  /// - 如果有当前对话：显示对话的名称
  /// - 如果没有对话：显示默认的"聊天"标题
  ///
  /// **参数说明**:
  /// - [state]: 当前对话状态
  ///
  /// **返回值**:
  /// - 返回要显示在 AppBar 中的标题字符串
  String _getAppBarTitle(CurrentConversationState state) {
    if (state.conversation != null) {
      return state.conversation!.channelName;
    }
    return "聊天";
  }

  /// 获取当前要显示的屏幕内容
  ///
  /// 根据对话状态决定显示哪个界面组件。
  /// 处理加载、错误、正常和空状态的界面展示。
  ///
  /// **状态处理**:
  /// - **加载状态**: 显示加载指示器和提示文本
  /// - **错误状态**: 显示错误信息和重试按钮
  /// - **正常状态**: 显示聊天界面
  /// - **空状态**: 显示初始化提示
  ///
  /// **参数说明**:
  /// - [state]: 当前对话状态
  /// - [notifier]: 对话状态管理器，用于状态操作
  ///
  /// **返回值**:
  /// - 返回要显示的 Widget 组件
  Widget _getCurrentScreen(
    CurrentConversationState state,
    CurrentConversationNotifier notifier,
  ) {
    // 如果正在加载
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载...'),
          ],
        ),
      );
    }

    // 如果有错误
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                notifier.clearError();
                notifier.createNewConversation();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 显示当前对话
    if (state.conversation != null) {
      return ChatScreen(
        conversationState: state.conversation!,
        showAppBar: false,
        onAssistantConfigChanged: notifier.onAssistantConfigChanged,
        onConversationUpdated: notifier.updateConversation,
        initialMessageId: widget.initialMessageId,
      );
    }

    // 没有对话时显示加载状态
    return const Center(child: Text('正在初始化...'));
  }
}
