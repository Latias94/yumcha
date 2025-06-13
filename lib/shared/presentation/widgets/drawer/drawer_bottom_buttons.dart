import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../design_system/design_constants.dart';
import 'drawer_constants.dart';

/// 侧边栏底部按钮组件
///
/// 提供底部操作按钮，包括：
/// - 智能布局切换（水平/垂直）
/// - 紧凑模式支持
/// - 响应式设计
/// - 动态宽度计算
class DrawerBottomButtons extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  const DrawerBottomButtons({
    super.key,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Container(
      padding: EdgeInsets.all(DesignConstants.spaceL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: DesignConstants.borderWidthThin,
          ),
        ),
      ),
      child: Column(
        children: [
          // 智能布局：桌面端优先使用水平布局，空间不足时切换到垂直布局
          if (isDesktop)
            _buildDesktopButtonLayout(context, theme, deviceType)
          else
            // 移动端和平板端水平布局
            _buildMobileButtonLayout(context, theme, deviceType),
        ],
      ),
    );
  }

  /// 桌面端智能按钮布局
  /// 优先使用水平布局，当空间不足时自动切换到垂直布局
  Widget _buildDesktopButtonLayout(
      BuildContext context, ThemeData theme, DeviceType deviceType) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算按钮所需的最小宽度
        // 考虑图标、文字、内边距和间距
        const double iconWidth = DrawerConstants.buttonIconWidth;
        const double spacing = DrawerConstants.buttonSpacing;
        const double horizontalPadding =
            DrawerConstants.buttonHorizontalPadding;
        const double buttonSpacing = DrawerConstants.buttonLayoutSpacing;

        // 估算文字宽度（基于字符数和字体大小）
        final fontSize = DesignConstants.getResponsiveFontSize(
          context,
          mobile: 14.0,
          tablet: 15.0,
          desktop: 15.0, // 降低桌面端字体大小以节省空间
        );
        const double avgCharWidth = DrawerConstants.chineseCharWidthRatio;
        final double searchTextWidth = "聊天历史".length * fontSize * avgCharWidth;
        final double settingsTextWidth = "设置".length * fontSize * avgCharWidth;

        final double minButtonWidth = iconWidth +
            spacing +
            math.max(searchTextWidth, settingsTextWidth) +
            horizontalPadding;
        final double totalHorizontalWidth = minButtonWidth * 2 + buttonSpacing;

        // 如果可用宽度足够，使用水平布局；否则使用垂直布局
        if (constraints.maxWidth >= totalHorizontalWidth) {
          return _buildHorizontalButtonLayout(context, theme, deviceType);
        } else {
          return _buildVerticalButtonLayout(context, theme, deviceType);
        }
      },
    );
  }

  /// 移动端和平板端按钮布局
  Widget _buildMobileButtonLayout(
      BuildContext context, ThemeData theme, DeviceType deviceType) {
    return Row(
      children: [
        Expanded(
          child: _buildBottomButton(
            context: context,
            icon: Icons.search,
            label: "聊天历史",
            onTap: onSearchTap,
            theme: theme,
            deviceType: deviceType,
          ),
        ),
        SizedBox(width: DesignConstants.spaceM),
        Expanded(
          child: _buildBottomButton(
            context: context,
            icon: Icons.settings,
            label: "设置",
            onTap: onSettingsTap,
            theme: theme,
            deviceType: deviceType,
          ),
        ),
      ],
    );
  }

  /// 水平按钮布局（桌面端优化版）
  Widget _buildHorizontalButtonLayout(
      BuildContext context, ThemeData theme, DeviceType deviceType) {
    return Row(
      children: [
        Expanded(
          child: _buildBottomButton(
            context: context,
            icon: Icons.search,
            label: "聊天历史",
            onTap: onSearchTap,
            theme: theme,
            deviceType: deviceType,
            isCompact: true, // 紧凑模式
          ),
        ),
        SizedBox(width: DesignConstants.spaceM),
        Expanded(
          child: _buildBottomButton(
            context: context,
            icon: Icons.settings,
            label: "设置",
            onTap: onSettingsTap,
            theme: theme,
            deviceType: deviceType,
            isCompact: true, // 紧凑模式
          ),
        ),
      ],
    );
  }

  /// 垂直按钮布局（桌面端备选方案）
  Widget _buildVerticalButtonLayout(
      BuildContext context, ThemeData theme, DeviceType deviceType) {
    return Column(
      children: [
        _buildBottomButton(
          context: context,
          icon: Icons.search,
          label: "聊天历史",
          onTap: onSearchTap,
          theme: theme,
          deviceType: deviceType,
        ),
        SizedBox(height: DesignConstants.spaceM),
        _buildBottomButton(
          context: context,
          icon: Icons.settings,
          label: "设置",
          onTap: onSettingsTap,
          theme: theme,
          deviceType: deviceType,
        ),
      ],
    );
  }

  Widget _buildBottomButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    required DeviceType deviceType,
    bool isCompact = false,
  }) {
    final isDesktop = deviceType == DeviceType.desktop;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: DesignConstants.radiusM,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isCompact
                ? DesignConstants.spaceM
                : (isDesktop ? DesignConstants.spaceL : DesignConstants.spaceM),
            horizontal:
                isCompact ? DesignConstants.spaceS : DesignConstants.spaceM,
          ),
          child: Row(
            mainAxisAlignment: isCompact
                ? MainAxisAlignment.center
                : (isDesktop
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center),
            mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(
                icon,
                size: isCompact
                    ? DesignConstants.iconSizeS
                    : DesignConstants.iconSizeM,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              SizedBox(width: DesignConstants.spaceS),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.8),
                    fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 14.0,
                      tablet: 15.0,
                      desktop: isCompact ? 14.0 : 15.0, // 紧凑模式使用更小字体
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
