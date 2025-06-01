import 'package:flutter/material.dart';
import '../models/chat_history.dart';
import '../models/ai_assistant.dart';
import '../models/conversation_ui_state.dart';
import '../services/assistant_repository.dart';
import '../services/conversation_repository.dart';
import '../services/database_service.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  final String selectedMenu;
  final Function(String) onChatClicked;
  final Function(String) onProfileClicked;

  const AppDrawer({
    super.key,
    required this.selectedMenu,
    required this.onChatClicked,
    required this.onProfileClicked,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _assistantSearchController =
      TextEditingController();
  late final AssistantRepository _assistantRepository;
  late final ConversationRepository _conversationRepository;

  String _selectedAssistant = "ai";
  String _searchQuery = "";
  String _assistantSearchQuery = "";
  bool _isAssistantDropdownExpanded = false;
  List<AiAssistant> _assistants = [];
  List<ConversationUiState> _conversations = [];
  bool _isLoadingAssistants = true;
  bool _isLoadingConversations = true;

  @override
  void initState() {
    super.initState();
    _assistantRepository = AssistantRepository(
      DatabaseService.instance.database,
    );
    _conversationRepository = ConversationRepository(
      DatabaseService.instance.database,
    );
    _loadAssistants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _assistantSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssistants() async {
    try {
      final assistants = await _assistantRepository.getEnabledAssistants();
      setState(() {
        _assistants = assistants;
        _isLoadingAssistants = false;
        // 如果有助手，设置第一个为默认选中
        if (assistants.isNotEmpty && _selectedAssistant == "ai") {
          _selectedAssistant = assistants.first.id;
        }
      });
      // 加载助手后，加载对应的对话
      _loadConversations();
    } catch (e) {
      setState(() => _isLoadingAssistants = false);
    }
  }

  Future<void> _loadConversations() async {
    if (_selectedAssistant == "ai" || _selectedAssistant.isEmpty) return;

    try {
      setState(() => _isLoadingConversations = true);
      final conversations = await _conversationRepository
          .getConversationsByAssistant(_selectedAssistant);
      setState(() {
        _conversations = conversations;
        _isLoadingConversations = false;
      });
    } catch (e) {
      setState(() => _isLoadingConversations = false);
    }
  }

  List<AiAssistant> get _filteredAssistants {
    if (_assistantSearchQuery.isEmpty) {
      return _assistants;
    }
    return _assistants
        .where(
          (assistant) =>
              assistant.name.toLowerCase().contains(
                _assistantSearchQuery.toLowerCase(),
              ) ||
              assistant.description.toLowerCase().contains(
                _assistantSearchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  AiAssistant? get _selectedAssistantData {
    return _assistants.firstWhere(
      (assistant) => assistant.id == _selectedAssistant,
      orElse: () => AiAssistant(
        id: 'default',
        name: 'AI助手',
        description: '通用AI助手',
        avatar: '🤖',
        systemPrompt: '',
        providerId: '',
        modelName: '',
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 2048,
        contextLength: 10,
        streamOutput: true,
        customHeaders: {},
        customBody: {},
        stopSequences: [],
        enableWebSearch: false,
        enableCodeExecution: false,
        enableImageGeneration: false,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  List<ChatHistoryGroup> get _filteredChatHistory {
    if (_isLoadingConversations) {
      return [];
    }

    // 将对话转换为ChatHistoryItem
    final items = _conversations.map((conversation) {
      final lastMessage = conversation.messages.isNotEmpty
          ? conversation.messages.first.content
          : '暂无消息';

      return ChatHistoryItem(
        id: conversation.id,
        title: conversation.channelName,
        preview: lastMessage,
        timestamp: conversation.messages.isNotEmpty
            ? conversation.messages.first.timestamp
            : DateTime.now(),
        assistantType: "ai", // 默认为AI类型，可以根据助手类型调整
        messageCount: conversation.messages.length,
        assistantId: conversation.assistantId,
      );
    }).toList();

    // 按时间分组
    final groups = _groupConversationsByTime(items);

    if (_searchQuery.isEmpty) {
      return groups;
    }

    // 过滤搜索结果
    final filteredGroups = <ChatHistoryGroup>[];
    for (final group in groups) {
      final filteredItems = group.items
          .where(
            (item) =>
                item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.preview.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();

      if (filteredItems.isNotEmpty) {
        filteredGroups.add(
          ChatHistoryGroup(title: group.title, items: filteredItems),
        );
      }
    }

    return filteredGroups;
  }

  List<ChatHistoryGroup> _groupConversationsByTime(
    List<ChatHistoryItem> items,
  ) {
    if (items.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    final todayItems = <ChatHistoryItem>[];
    final yesterdayItems = <ChatHistoryItem>[];
    final thisWeekItems = <ChatHistoryItem>[];
    final earlierItems = <ChatHistoryItem>[];

    for (final item in items) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );

      if (itemDate.isAtSameMomentAs(today)) {
        todayItems.add(item);
      } else if (itemDate.isAtSameMomentAs(yesterday)) {
        yesterdayItems.add(item);
      } else if (itemDate.isAfter(thisWeek)) {
        thisWeekItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    final groups = <ChatHistoryGroup>[];

    if (todayItems.isNotEmpty) {
      groups.add(ChatHistoryGroup(title: "今天", items: todayItems));
    }
    if (yesterdayItems.isNotEmpty) {
      groups.add(ChatHistoryGroup(title: "昨天", items: yesterdayItems));
    }
    if (thisWeekItems.isNotEmpty) {
      groups.add(ChatHistoryGroup(title: "本周", items: thisWeekItems));
    }
    if (earlierItems.isNotEmpty) {
      groups.add(ChatHistoryGroup(title: "更早", items: earlierItems));
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 搜索框
          _buildSearchHeader(),

          // 聊天记录列表
          Expanded(child: _buildChatHistoryList()),

          // 助手选择下拉框
          _buildAssistantSelector(),

          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // 顶部空间，避免与状态栏重叠
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "搜索聊天记录...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList() {
    if (_isLoadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }

    final groups = _filteredChatHistory;

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty
                  ? Icons.chat_bubble_outline
                  : Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? "暂无聊天记录" : "未找到匹配的记录",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "开始与${_selectedAssistantData?.name ?? 'AI助手'}聊天吧！",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分组标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 聊天记录列表
            ...group.items.map((item) => _buildChatHistoryItem(item)),

            // 分组间的间距
            if (groupIndex < groups.length - 1) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildChatHistoryItem(ChatHistoryItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // 打开特定的聊天记录
            widget.onChatClicked(item.id);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.preview.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.preview,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantSelector() {
    final selectedAssistant = _selectedAssistantData;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _isAssistantDropdownExpanded = !_isAssistantDropdownExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 当前选中的助手
                Row(
                  children: [
                    Text(
                      selectedAssistant?.avatar ?? '🤖',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAssistant?.name ?? 'AI助手',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          if (selectedAssistant != null)
                            Text(
                              selectedAssistant.description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isAssistantDropdownExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_up),
                    ),
                  ],
                ),

                // 展开的助手列表
                if (_isAssistantDropdownExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // 搜索框
                  if (_assistants.length > 5) ...[
                    TextField(
                      controller: _assistantSearchController,
                      decoration: InputDecoration(
                        hintText: "搜索助手...",
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _assistantSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _assistantSearchController.clear();
                                  setState(() {
                                    _assistantSearchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        isDense: true,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                      onChanged: (value) {
                        setState(() {
                          _assistantSearchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 助手列表
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _assistants.length > 10
                          ? 200
                          : double.infinity,
                    ),
                    child: _isLoadingAssistants
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _filteredAssistants.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _assistantSearchQuery.isNotEmpty
                                  ? '未找到匹配的助手'
                                  : '暂无可用助手',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredAssistants.length,
                            itemBuilder: (context, index) {
                              final assistant = _filteredAssistants[index];
                              if (assistant.id == _selectedAssistant) {
                                return const SizedBox.shrink();
                              }

                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    _selectedAssistant = assistant.id;
                                    _isAssistantDropdownExpanded = false;
                                    _assistantSearchController.clear();
                                    _assistantSearchQuery = "";
                                  });
                                  // 切换助手后重新加载对话
                                  _loadConversations();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        assistant.avatar,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              assistant.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                            Text(
                                              assistant.description,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 聊天历史和设置按钮
          Row(
            children: [
              // 聊天历史按钮
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    // TODO: 打开完整的聊天历史页面
                    _showChatHistoryDialog();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "聊天历史",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 设置按钮
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    _showSettingsDialog();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.settings, size: 18),
                      const SizedBox(width: 8),
                      Text("设置", style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChatHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("聊天历史"),
        content: const Text("这里将显示完整的聊天历史记录，支持搜索和筛选功能。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("关闭"),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    Navigator.of(context).pop(); // 关闭侧边栏
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }
}
