import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import '../models/chat_history.dart';
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
  String _selectedAssistant = "ai";
  String _searchQuery = "";
  bool _isAssistantDropdownExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatHistoryGroup> get _filteredChatHistory {
    final groups = getChatHistoryGroups(_selectedAssistant);

    if (_searchQuery.isEmpty) {
      return groups;
    }

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
    final groups = _filteredChatHistory;

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
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
            // TODO: 打开特定的聊天记录
            Navigator.of(context).pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              item.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantSelector() {
    final selectedType = assistantTypes.firstWhere(
      (type) => type.id == _selectedAssistant,
      orElse: () => assistantTypes.first,
    );

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
                Row(
                  children: [
                    Text(
                      selectedType.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedType.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isAssistantDropdownExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_up),
                    ),
                  ],
                ),

                if (_isAssistantDropdownExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  ...assistantTypes.map((type) {
                    if (type.id == _selectedAssistant)
                      return const SizedBox.shrink();

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _selectedAssistant = type.id;
                          _isAssistantDropdownExpanded = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              type.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
      child: Row(
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
                  Text("聊天历史", style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 设置按钮
          Expanded(
            child: FilledButton.tonal(
              onPressed: () {
                // TODO: 打开设置页面
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
    );
  }

  String _getAssistantIcon(String assistantType) {
    switch (assistantType) {
      case "ai":
        return "🤖";
      case "character":
        return "😊";
      case "developer":
        return "💻";
      default:
        return "🤖";
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}分钟前";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}小时前";
    } else {
      return "${diff.inDays}天前";
    }
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
