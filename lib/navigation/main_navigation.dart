import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/app_drawer.dart';
import '../screens/chat_screen.dart';
import '../models/conversation_ui_state.dart';
import '../services/conversation_repository.dart';
import '../services/assistant_repository.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  String selectedMenu = "new_chat";
  late final ConversationRepository _conversationRepository;
  late final AssistantRepository _assistantRepository;
  ConversationUiState? _currentConversation;
  bool _isLoadingConversation = false;
  bool _isLoadingLastConfig = true;

  // 记住上次的配置
  String? _lastUsedAssistantId;
  String? _lastUsedProviderId;
  String? _lastUsedModelName;

  // UUID生成器
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _conversationRepository = ConversationRepository(
      DatabaseService.instance.database,
    );
    _assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    _loadLastConfiguration();
  }

  // 加载上次使用的配置
  Future<void> _loadLastConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAssistantId = prefs.getString('last_assistant_id');
      final lastProviderId = prefs.getString('last_provider_id');
      final lastModelName = prefs.getString('last_model_name');

      setState(() {
        _lastUsedAssistantId = lastAssistantId;
        _lastUsedProviderId = lastProviderId;
        _lastUsedModelName = lastModelName;
        _isLoadingLastConfig = false;
      });

      // 创建新对话，使用上次的配置
      await _createNewConversation();
    } catch (e) {
      setState(() => _isLoadingLastConfig = false);
      // 如果加载失败，创建默认对话
      await _createNewConversation();
    }
  }

  // 保存当前配置
  Future<void> _saveCurrentConfiguration(
    String assistantId,
    String providerId,
    String modelName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_assistant_id', assistantId);
      await prefs.setString('last_provider_id', providerId);
      await prefs.setString('last_model_name', modelName);

      setState(() {
        _lastUsedAssistantId = assistantId;
        _lastUsedProviderId = providerId;
        _lastUsedModelName = modelName;
      });
    } catch (e) {
      print('保存配置失败: $e');
    }
  }

  // 创建新对话
  Future<void> _createNewConversation() async {
    try {
      // 生成固定的UUID作为对话ID
      final conversationId = _uuid.v4();

      // 如果有上次的助手ID，尝试获取助手信息
      if (_lastUsedAssistantId != null) {
        final assistant = await _assistantRepository.getAssistant(
          _lastUsedAssistantId!,
        );
        if (assistant != null) {
          setState(() {
            _currentConversation = ConversationUiState(
              id: conversationId,
              channelName: "与${assistant.name}的新对话",
              channelMembers: 1,
              assistantId: assistant.id,
              selectedProviderId: '', // 临时修复：助手不再关联提供商
              messages: [],
            );
          });
          return;
        }
      }

      // 如果没有上次的配置或助手不存在，创建默认对话
      final assistants = await _assistantRepository.getAllAssistants();
      final defaultAssistant = assistants.isNotEmpty ? assistants.first : null;

      setState(() {
        _currentConversation = ConversationUiState(
          id: conversationId,
          channelName: defaultAssistant != null
              ? "与${defaultAssistant.name}的新对话"
              : "新对话",
          channelMembers: 1,
          assistantId: defaultAssistant?.id ?? '',
          selectedProviderId: '', // 临时修复：助手不再关联提供商
          messages: [],
        );
      });

      // 如果有默认助手，保存其配置
      if (defaultAssistant != null) {
        await _saveCurrentConfiguration(
          defaultAssistant.id,
          '', // 临时修复：助手不再关联提供商
          '', // 临时修复：助手不再关联模型
        );
      }
    } catch (e) {
      // 创建空白对话
      setState(() {
        _currentConversation = ConversationUiState(
          id: _uuid.v4(),
          channelName: "新对话",
          channelMembers: 1,
          assistantId: '',
          selectedProviderId: '',
          messages: [],
        );
      });
    }
  }

  void _onChatClicked(String chatId) {
    setState(() {
      selectedMenu = chatId;
    });

    if (chatId == "new_chat") {
      // 创建新对话
      _createNewConversation();
    } else {
      // 加载现有对话
      _loadConversation(chatId);
    }
    Navigator.of(context).pop(); // Close drawer
  }

  // 当助手配置改变时调用
  void _onAssistantConfigChanged(
    String assistantId,
    String providerId,
    String modelName,
  ) {
    _saveCurrentConfiguration(assistantId, providerId, modelName);
  }

  // 当对话有内容时，保存到数据库
  Future<void> _saveConversationIfNeeded(
    ConversationUiState conversation,
  ) async {
    // 只有当对话有消息时才保存（不再检查ID前缀，因为现在直接使用UUID）
    if (conversation.messages.isNotEmpty) {
      try {
        // 直接保存对话，不再重新生成ID
        await _conversationRepository.saveConversation(conversation);

        // 更新菜单选择（如果需要的话）
        if (selectedMenu != conversation.id) {
          setState(() {
            selectedMenu = conversation.id;
          });
        }
      } catch (e) {
        print('保存对话失败: $e');
      }
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    try {
      setState(() => _isLoadingConversation = true);
      final conversation = await _conversationRepository.getConversation(
        conversationId,
      );
      setState(() {
        _currentConversation = conversation;
        _isLoadingConversation = false;
      });
    } catch (e) {
      setState(() => _isLoadingConversation = false);
      print('加载对话失败: $e');
    }
  }

  String _getAppBarTitle() {
    if (_currentConversation != null) {
      return _currentConversation!.channelName;
    }
    return "聊天";
  }

  Widget _getCurrentScreen() {
    // 如果正在加载配置
    if (_isLoadingLastConfig) {
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

    // 如果正在加载对话
    if (_isLoadingConversation) {
      return const Center(child: CircularProgressIndicator());
    }

    // 显示当前对话
    if (_currentConversation != null) {
      return ChatScreen(
        conversationState: _currentConversation!,
        showAppBar: false,
        onAssistantConfigChanged: _onAssistantConfigChanged,
        onConversationUpdated: _saveConversationIfNeeded,
      );
    }

    // 没有对话时显示加载状态
    return const Center(child: Text('正在初始化...'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _createNewConversation();
            },
            tooltip: '新对话',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedMenu: selectedMenu,
        onChatClicked: _onChatClicked,
        onProfileClicked: (String userId) {}, // 移除profile功能，保留空实现避免错误
      ),
      body: _getCurrentScreen(),
    );
  }
}
