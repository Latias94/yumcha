import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/design_constants.dart';

/// 侧边栏搜索头部组件
/// 
/// 提供搜索功能，包括：
/// - 响应式搜索框
/// - 防抖搜索
/// - 清除按钮动画
/// - 搜索状态指示
class DrawerSearchHeader extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueNotifier<bool> showClearButton;

  const DrawerSearchHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.showClearButton,
  });

  @override
  ConsumerState<DrawerSearchHeader> createState() => _DrawerSearchHeaderState();
}

class _DrawerSearchHeaderState extends ConsumerState<DrawerSearchHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignConstants.spaceL,
        DesignConstants.spaceL,
        DesignConstants.spaceL,
        DesignConstants.spaceS,
      ),
      child: Column(
        children: [
          // 顶部空间，避免与状态栏重叠
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 搜索框
          ValueListenableBuilder<bool>(
            valueListenable: widget.showClearButton,
            builder: (context, showClear, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: DesignConstants.radiusXXL,
                  boxShadow: DesignConstants.shadowS(theme),
                ),
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: deviceType == DeviceType.desktop
                        ? "搜索对话标题和内容..."
                        : "搜索对话...",
                    hintStyle: TextStyle(
                      fontSize: DesignConstants.getResponsiveFontSize(
                        context,
                        mobile: 14.0,
                        tablet: 15.0,
                        desktop: 16.0,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: deviceType == DeviceType.mobile
                          ? DesignConstants.iconSizeM
                          : DesignConstants.iconSizeL,
                    ),
                    suffixIcon: AnimatedSwitcher(
                      duration: DesignConstants.animationFast,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: showClear
                          ? IconButton(
                              key: const ValueKey('clear_button'),
                              icon: const Icon(Icons.clear),
                              iconSize: deviceType == DeviceType.mobile
                                  ? DesignConstants.iconSizeM
                                  : DesignConstants.iconSizeL,
                              onPressed: () {
                                widget.searchController.clear();
                                widget.onSearchChanged("");
                              },
                              tooltip: '清除搜索',
                            )
                          : const SizedBox.shrink(key: ValueKey('empty_space')),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: DesignConstants.radiusXXL,
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: deviceType == DeviceType.mobile
                          ? DesignConstants.spaceM
                          : DesignConstants.spaceL,
                      horizontal: DesignConstants.spaceS,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: DesignConstants.getResponsiveFontSize(context),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
