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
// - 正常状态：显示聊天界面
// - 空状态：显示初始化提示
// - 错误处理：通过 SnackBar 和聊天气泡显示，不阻塞界面

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/presentation/widgets/app_drawer.dart';
import '../../core/widgets/modern_chat_view.dart';
import '../../core/providers/core_providers.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../shared/infrastructure/services/logger_service.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted && !_hasInitialized) {
          _logger.info('开始加载初始对话', {
            'conversationId': widget.initialConversationId,
          });
          final chatNotifier = ref.read(chatStateProvider.notifier);
          // TODO: Implement conversation loading from database
          // For now, create a placeholder conversation
          await chatNotifier.createConversation(
            title: 'Loaded Conversation',
            assistantId: null,
          );
          if (mounted) {
            setState(() {
              _hasInitialized = true;
            });
          }
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
    final chatNotifier = ref.read(chatStateProvider.notifier);

    // 先创建新对话
    await chatNotifier.createConversation(
      title: 'New Chat',
      assistantId: null,
    );

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
    final conversation = ref.watch(currentConversationProvider);
    final chatState = ref.watch(chatStateProvider);
    final chatNotifier = ref.read(chatStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(conversation)),
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
        selectedMenu: conversation?.id ?? 'new_chat',
        onChatClicked: (chatId) async {
          _logger.info('MainNavigation 收到聊天点击事件', {
            'chatId': chatId,
            'currentConversationId': conversation?.id,
            'isLoading': chatState.isLoading,
          });

          // 防止在加载状态时重复点击
          if (!chatState.isLoading) {
            _logger.info('开始切换对话', {'targetChatId': chatId});
            if (chatId == "new_chat") {
              await chatNotifier.createConversation(
                title: 'New Chat',
                assistantId: null,
              );
            } else {
              // TODO: Implement conversation loading from database
              await chatNotifier.createConversation(
                title: 'Loaded Chat',
                assistantId: null,
              );
            }
            if (context.mounted) {
              Navigator.of(context).pop(); // Close drawer
            }
          } else {
            _logger.warning('对话正在加载中，忽略点击事件');
          }
        },
        onProfileClicked: (String userId) {}, // 移除profile功能，保留空实现避免错误
      ),
      // 侧边栏手势配置 - 曲面屏优化
      drawerEnableOpenDragGesture: true, // 启用从屏幕边缘滑动打开侧边栏
      drawerEdgeDragWidth: 35.0, // 曲面屏适配：增加感应区域宽度，避开曲面边缘
      drawerDragStartBehavior: DragStartBehavior.start, // 手势开始行为
      onDrawerChanged: (isOpened) {
        // 可选：监听侧边栏开关状态
        _logger.debug('侧边栏状态变化: ${isOpened ? "打开" : "关闭"}');
      },
      body: _getCurrentScreen(conversation, chatState, chatNotifier),
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
  String _getAppBarTitle(ConversationUiState? conversation) {
    if (conversation != null) {
      return conversation.channelName;
    }
    return "聊天";
  }

  /// 获取当前要显示的屏幕内容
  ///
  /// 根据对话状态决定显示哪个界面组件。
  /// 处理加载、正常和空状态的界面展示。
  ///
  /// **状态处理**:
  /// - **加载状态**: 显示加载指示器和提示文本
  /// - **正常状态**: 显示聊天界面
  /// - **空状态**: 显示初始化提示
  ///
  /// **错误处理**:
  /// - 错误通过 NotificationService 显示 SnackBar
  /// - 错误信息在聊天气泡中显示
  /// - 不会替换整个聊天界面，保持用户可以继续聊天
  ///
  /// **参数说明**:
  /// - [state]: 当前对话状态
  /// - [notifier]: 对话状态管理器，用于状态操作
  ///
  /// **返回值**:
  /// - 返回要显示的 Widget 组件
  Widget _getCurrentScreen(
    ConversationUiState? conversation,
    ChatState chatState,
    ChatStateNotifier chatNotifier,
  ) {
    // _logger.debug('MainNavigation 渲染屏幕', {
    //   'isLoading': chatState.isLoading,
    //   'hasError': chatState.hasError,
    //   'hasConversation': conversation != null,
    //   'conversationId': conversation?.id,
    // });

    // 如果正在加载
    if (chatState.isLoading) {
      _logger.debug('显示加载状态');
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

    // 注意：错误处理已移除，错误现在通过以下方式处理：
    // 1. NotificationService 显示 SnackBar 通知
    // 2. ChatMessageView 在聊天气泡中显示错误信息
    // 3. 用户可以继续聊天，不会被错误界面阻塞

    // 始终显示聊天界面，无论是否有对话
    _logger.info('显示聊天界面', {
      'hasConversation': conversation != null,
      'conversationId': conversation?.id,
      'assistantId': conversation?.assistantId,
      'messageCount': conversation?.messages.length ?? 0,
    });

    // Use the modern chat view with new architecture
    return ModernChatView(
      conversationId: conversation?.id,
      assistantId: conversation?.assistantId,
      showAppBar: false,
      enableInput: true,
      onMessageSent: (message) {
        _logger.info('消息已发送', {
          'message': message,
          'conversationId': conversation?.id,
        });
      },
      onConversationChanged: (updatedConversation) {
        _logger.info('对话已更新', {
          'conversationId': updatedConversation?.id,
          'messageCount': updatedConversation?.messages.length ?? 0,
        });
      },
    );
  }
}
