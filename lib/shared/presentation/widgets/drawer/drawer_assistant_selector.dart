import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/design_constants.dart';
import '../../providers/providers.dart';
import 'drawer_constants.dart';

/// 侧边栏助手选择器组件
///
/// 提供助手选择功能，包括：
/// - 当前选中助手显示
/// - 助手列表展开/收起
/// - 助手搜索功能
/// - 响应式设计
class DrawerAssistantSelector extends ConsumerStatefulWidget {
  final String selectedAssistant;
  final Function(String) onAssistantChanged;

  const DrawerAssistantSelector({
    super.key,
    required this.selectedAssistant,
    required this.onAssistantChanged,
  });

  @override
  ConsumerState<DrawerAssistantSelector> createState() =>
      _DrawerAssistantSelectorState();
}

class _DrawerAssistantSelectorState
    extends ConsumerState<DrawerAssistantSelector> {
  final TextEditingController _assistantSearchController =
      TextEditingController();
  String _assistantSearchQuery = "";
  bool _isAssistantDropdownExpanded = false;

  @override
  void dispose() {
    _assistantSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    return Consumer(
      builder: (context, ref, _) {
        final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
        final selectedAssistant = ref.watch(
          aiAssistantProvider(widget.selectedAssistant),
        );

        return assistantsAsync.when(
          data: (assistants) => _buildAssistantSelector(
            context,
            theme,
            deviceType,
            assistants,
            selectedAssistant,
          ),
          loading: () => _buildLoadingIndicator(context),
          error: (error, stack) => _buildErrorIndicator(context, error, ref),
        );
      },
    );
  }

  Widget _buildAssistantSelector(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    List<dynamic> assistants,
    dynamic selectedAssistant,
  ) {
    return Container(
      margin: EdgeInsets.all(DesignConstants.spaceL),
      decoration: BoxDecoration(
        borderRadius: DesignConstants.radiusL,
        boxShadow: DesignConstants.shadowS(theme),
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: DesignConstants.radiusL,
        child: InkWell(
          borderRadius: DesignConstants.radiusL,
          onTap: () {
            setState(() {
              _isAssistantDropdownExpanded = !_isAssistantDropdownExpanded;
            });
          },
          child: AnimatedContainer(
            duration: DesignConstants.animationNormal,
            curve: DesignConstants.curveStandard,
            padding: EdgeInsets.all(
              deviceType == DeviceType.mobile
                  ? DesignConstants.spaceL
                  : DesignConstants.spaceXL,
            ),
            child: Column(
              children: [
                // 当前选中的助手
                _buildCurrentAssistant(
                    context, theme, deviceType, selectedAssistant),

                // 展开的助手列表
                if (_isAssistantDropdownExpanded) ...[
                  SizedBox(height: DesignConstants.spaceM),
                  const Divider(height: 1),
                  SizedBox(height: DesignConstants.spaceS),
                  _buildAssistantList(context, assistants),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAssistant(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    dynamic selectedAssistant,
  ) {
    return Row(
      children: [
        // 助手头像
        Container(
          width: deviceType == DeviceType.mobile ? 40 : 48,
          height: deviceType == DeviceType.mobile ? 40 : 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: DesignConstants.radiusM,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: DesignConstants.borderWidthThin,
            ),
          ),
          child: Center(
            child: Text(
              selectedAssistant?.avatar ?? '🤖',
              style: TextStyle(
                fontSize: deviceType == DeviceType.mobile ? 20 : 24,
              ),
            ),
          ),
        ),
        SizedBox(width: DesignConstants.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedAssistant?.name ?? 'AI助手',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: DesignConstants.getResponsiveFontSize(
                    context,
                    mobile: 15.0,
                    tablet: 16.0,
                    desktop: 17.0,
                  ),
                ),
              ),
              if (selectedAssistant != null) ...[
                SizedBox(height: DesignConstants.spaceXS),
                Text(
                  selectedAssistant.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 12.0,
                      tablet: 13.0,
                      desktop: 14.0,
                    ),
                  ),
                  maxLines: deviceType == DeviceType.desktop ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        AnimatedRotation(
          turns: _isAssistantDropdownExpanded ? 0.5 : 0,
          duration: DesignConstants.animationFast,
          curve: DesignConstants.curveStandard,
          child: Icon(
            Icons.keyboard_arrow_up,
            size: deviceType == DeviceType.mobile
                ? DesignConstants.iconSizeM
                : DesignConstants.iconSizeL,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAssistantList(BuildContext context, List<dynamic> assistants) {
    // 过滤助手列表
    final filteredAssistants = assistants.where((assistant) {
      if (_assistantSearchQuery.isEmpty) return true;
      return assistant.name
          .toLowerCase()
          .contains(_assistantSearchQuery.toLowerCase());
    }).toList();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            assistants.length > DrawerConstants.assistantListScrollThreshold
                ? DrawerConstants.assistantDropdownMaxHeight
                : double.infinity,
      ),
      child: filteredAssistants.isEmpty
          ? _buildNoAssistantsFound(context)
          : ListView.builder(
              shrinkWrap: true,
              itemCount: filteredAssistants.length,
              itemBuilder: (context, index) {
                final assistant = filteredAssistants[index];
                if (assistant.id == widget.selectedAssistant) {
                  return const SizedBox.shrink();
                }

                return _buildAssistantItem(context, assistant);
              },
            ),
    );
  }

  Widget _buildAssistantItem(BuildContext context, dynamic assistant) {
    return InkWell(
      borderRadius: DesignConstants.radiusS,
      onTap: () {
        setState(() {
          _isAssistantDropdownExpanded = false;
          _assistantSearchController.clear();
          _assistantSearchQuery = "";
        });
        widget.onAssistantChanged(assistant.id);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: DesignConstants.spaceS,
          horizontal: DesignConstants.spaceS,
        ),
        child: Row(
          children: [
            Text(
              assistant.avatar,
              style: const TextStyle(fontSize: 18),
            ),
            SizedBox(width: DesignConstants.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assistant.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (assistant.description.isNotEmpty) ...[
                    SizedBox(height: DesignConstants.spaceXS),
                    Text(
                      assistant.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAssistantsFound(BuildContext context) {
    return Padding(
      padding: DesignConstants.paddingL,
      child: Text(
        _assistantSearchQuery.isNotEmpty ? '未找到匹配的助手' : '暂无可用助手',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      margin: DesignConstants.paddingL,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorIndicator(
      BuildContext context, Object error, WidgetRef ref) {
    return Container(
      margin: DesignConstants.paddingL,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            SizedBox(height: DesignConstants.spaceS),
            Text('加载助手失败: $error'),
            SizedBox(height: DesignConstants.spaceS),
            ElevatedButton(
              onPressed: () => ref.refresh(aiAssistantNotifierProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
