import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_state.freezed.dart';

/// Scroll behavior configuration
@freezed
class ScrollConfig with _$ScrollConfig {
  const factory ScrollConfig({
    /// Whether to auto-scroll to new messages
    @Default(true) bool autoScroll,

    /// Auto-scroll threshold (distance from bottom to trigger auto-scroll)
    @Default(100.0) double autoScrollThreshold,

    /// Scroll animation duration in milliseconds
    @Default(300) int scrollAnimationDuration,

    /// Whether to show scroll-to-bottom button
    @Default(true) bool showScrollToBottomButton,

    /// Scroll physics type
    @Default(ScrollPhysicsType.platform) ScrollPhysicsType physicsType,
  }) = _ScrollConfig;
}

/// Scroll physics types
enum ScrollPhysicsType {
  /// Platform default physics
  platform,

  /// Bouncing physics (iOS style)
  bouncing,

  /// Clamping physics (Android style)
  clamping,

  /// Never scrollable
  never,

  /// Always scrollable
  always,
}

/// Virtual scrolling configuration
@freezed
class VirtualScrollConfig with _$VirtualScrollConfig {
  const factory VirtualScrollConfig({
    /// Whether virtual scrolling is enabled
    @Default(true) bool enabled,

    /// Threshold for enabling virtual scrolling (number of items)
    @Default(50) int enableThreshold,

    /// Number of items to render outside visible area
    @Default(5) int overscan,

    /// Estimated item height for virtual scrolling
    @Default(100.0) double estimatedItemHeight,

    /// Whether to cache item heights
    @Default(true) bool cacheItemHeights,
  }) = _VirtualScrollConfig;
}

/// Pagination configuration
@freezed
class PaginationConfig with _$PaginationConfig {
  const factory PaginationConfig({
    /// Initial page size
    @Default(20) int initialPageSize,

    /// Load more page size
    @Default(10) int loadMorePageSize,

    /// Whether to enable infinite scroll
    @Default(true) bool enableInfiniteScroll,

    /// Distance from top to trigger load more
    @Default(200.0) double loadMoreThreshold,

    /// Whether to show load more button
    @Default(false) bool showLoadMoreButton,
  }) = _PaginationConfig;
}

/// Theme configuration
@freezed
class ThemeConfig with _$ThemeConfig {
  const factory ThemeConfig({
    /// Current theme mode
    @Default(ThemeMode.system) ThemeMode themeMode,

    /// Font size multiplier
    @Default(1.0) double fontSizeMultiplier,

    /// Whether to use compact mode
    @Default(false) bool isCompactMode,

    /// Primary color seed
    @Default(null) Color? primaryColorSeed,

    /// Whether to use material 3 design
    @Default(true) bool useMaterial3,

    /// Custom theme name
    @Default(null) String? customThemeName,
  }) = _ThemeConfig;
}

/// Layout configuration
@freezed
class LayoutConfig with _$LayoutConfig {
  const factory LayoutConfig({
    /// Sidebar width
    @Default(280.0) double sidebarWidth,

    /// Whether sidebar is collapsible
    @Default(true) bool sidebarCollapsible,

    /// Chat area max width
    @Default(800.0) double chatMaxWidth,

    /// Message bubble max width percentage
    @Default(0.8) double messageBubbleMaxWidthPercent,

    /// Whether to show message avatars
    @Default(true) bool showMessageAvatars,

    /// Whether to show message timestamps
    @Default(true) bool showMessageTimestamps,

    /// Message spacing
    @Default(8.0) double messageSpacing,
  }) = _LayoutConfig;
}

/// Animation configuration
@freezed
class AnimationConfig with _$AnimationConfig {
  const factory AnimationConfig({
    /// Whether animations are enabled
    @Default(true) bool enabled,

    /// Animation duration multiplier
    @Default(1.0) double durationMultiplier,

    /// Whether to use reduced motion
    @Default(false) bool useReducedMotion,

    /// Page transition type
    @Default(PageTransitionType.slide) PageTransitionType pageTransitionType,

    /// Message animation type
    @Default(MessageAnimationType.fadeIn)
    MessageAnimationType messageAnimationType,
  }) = _AnimationConfig;
}

/// Page transition types
enum PageTransitionType {
  /// Slide transition
  slide,

  /// Fade transition
  fade,

  /// Scale transition
  scale,

  /// No transition
  none,
}

/// Message animation types
enum MessageAnimationType {
  /// Fade in animation
  fadeIn,

  /// Slide up animation
  slideUp,

  /// Scale animation
  scale,

  /// No animation
  none,
}

/// UI state management for visual and interaction aspects
///
/// Manages scrolling, virtual scrolling, pagination, theming, and layout.
/// This complements the runtime state by focusing on visual presentation.
@freezed
class UIState with _$UIState {
  const factory UIState({
    // === Scroll Management ===
    /// Current scroll position
    @Default(0.0) double scrollPosition,

    /// Whether auto-scroll is enabled
    @Default(true) bool shouldAutoScroll,

    /// Target message ID to scroll to
    @Default(null) String? scrollToMessageId,

    /// Scroll configuration
    @Default(ScrollConfig()) ScrollConfig scrollConfig,

    // === Virtual Scrolling ===
    /// Visible range start index
    @Default(0) int visibleStartIndex,

    /// Visible range end index
    @Default(50) int visibleEndIndex,

    /// Item heights cache (messageId -> height)
    @Default({}) Map<String, double> itemHeights,

    /// Virtual scroll configuration
    @Default(VirtualScrollConfig()) VirtualScrollConfig virtualScrollConfig,

    // === Pagination ===
    /// Whether more content is being loaded
    @Default(false) bool isLoadingMore,

    /// Whether there's more content to load
    @Default(true) bool hasMore,

    /// Current page size
    @Default(20) int currentPageSize,

    /// Pagination configuration
    @Default(PaginationConfig()) PaginationConfig paginationConfig,

    // === Theme and Appearance ===
    /// Theme configuration
    @Default(ThemeConfig()) ThemeConfig themeConfig,

    /// Layout configuration
    @Default(LayoutConfig()) LayoutConfig layoutConfig,

    /// Animation configuration
    @Default(AnimationConfig()) AnimationConfig animationConfig,

    // === Window and Viewport ===
    /// Current viewport size
    @Default(null) Size? viewportSize,

    /// Whether window is focused
    @Default(true) bool isWindowFocused,

    /// Whether app is in foreground
    @Default(true) bool isAppInForeground,

    // === Input State ===
    /// Whether input field is focused
    @Default(false) bool isInputFocused,

    /// Input field height
    @Default(56.0) double inputHeight,

    /// Whether input is expanded (multiline)
    @Default(false) bool isInputExpanded,

    // === Loading and Progress ===
    /// Global loading state
    @Default(false) bool isGlobalLoading,

    /// Loading message
    @Default(null) String? loadingMessage,

    /// Progress value (0.0 to 1.0)
    @Default(null) double? progressValue,

    // === Error Display ===
    /// Whether error overlay is shown
    @Default(false) bool showErrorOverlay,

    /// Error overlay message
    @Default(null) String? errorOverlayMessage,

    /// Error overlay type
    @Default(ErrorOverlayType.general) ErrorOverlayType errorOverlayType,

    // === Responsive Design ===
    /// Current screen size category
    @Default(ScreenSize.desktop) ScreenSize screenSize,

    /// Whether in mobile layout
    @Default(false) bool isMobileLayout,

    /// Whether in tablet layout
    @Default(false) bool isTabletLayout,

    /// Whether in desktop layout
    @Default(true) bool isDesktopLayout,

    // === Performance Monitoring ===
    /// Frame rate (FPS)
    @Default(60.0) double frameRate,

    /// Memory usage in MB
    @Default(0.0) double memoryUsage,

    /// Whether performance overlay is shown
    @Default(false) bool showPerformanceOverlay,

    // === Accessibility ===
    /// Whether high contrast mode is enabled
    @Default(false) bool highContrastMode,

    /// Whether large text mode is enabled
    @Default(false) bool largeTextMode,

    /// Whether screen reader is active
    @Default(false) bool screenReaderActive,

    // === Last Update ===
    /// Last UI update timestamp
    @Default(null) DateTime? lastUpdateTime,
  }) = _UIState;

  const UIState._();

  // === Computed Properties ===

  /// Whether virtual scrolling should be enabled
  bool get shouldUseVirtualScrolling {
    return virtualScrollConfig.enabled &&
        currentPageSize >= virtualScrollConfig.enableThreshold;
  }

  /// Whether to show scroll to bottom button
  bool get shouldShowScrollToBottomButton {
    return scrollConfig.showScrollToBottomButton &&
        scrollPosition > scrollConfig.autoScrollThreshold;
  }

  /// Whether animations should be disabled
  bool get shouldDisableAnimations {
    return !animationConfig.enabled ||
        animationConfig.useReducedMotion ||
        screenReaderActive;
  }

  /// Current effective font size
  double get effectiveFontSize {
    double baseFontSize = 14.0;
    if (largeTextMode) baseFontSize *= 1.3;
    return baseFontSize * themeConfig.fontSizeMultiplier;
  }

  /// Whether in compact layout mode
  bool get isCompactLayout {
    return themeConfig.isCompactMode || isMobileLayout;
  }

  /// Effective message bubble max width
  double get effectiveMessageBubbleMaxWidth {
    if (viewportSize == null) return 600.0;

    final maxWidth =
        viewportSize!.width * layoutConfig.messageBubbleMaxWidthPercent;
    return maxWidth.clamp(300.0, layoutConfig.chatMaxWidth);
  }

  /// Whether performance monitoring is active
  bool get isPerformanceMonitoringActive {
    return showPerformanceOverlay || frameRate < 30.0 || memoryUsage > 500.0;
  }
}

/// Screen size categories
enum ScreenSize {
  /// Mobile phones (< 600px width)
  mobile,

  /// Tablets (600px - 1024px width)
  tablet,

  /// Desktop (> 1024px width)
  desktop,
}

/// Error overlay types
enum ErrorOverlayType {
  /// General error
  general,

  /// Network error
  network,

  /// Authentication error
  authentication,

  /// Permission error
  permission,

  /// Critical system error
  critical,
}

/// Helper methods for UIState manipulation
extension UIStateHelpers on UIState {
  /// Update scroll position
  UIState updateScrollPosition(double position) {
    return copyWith(
      scrollPosition: position,
      shouldAutoScroll: position <= scrollConfig.autoScrollThreshold,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update visible range for virtual scrolling
  UIState updateVisibleRange(int startIndex, int endIndex) {
    return copyWith(
      visibleStartIndex: startIndex,
      visibleEndIndex: endIndex,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update viewport size and responsive layout
  UIState updateViewportSize(Size size) {
    final screenSize = _determineScreenSize(size.width);

    return copyWith(
      viewportSize: size,
      screenSize: screenSize,
      isMobileLayout: screenSize == ScreenSize.mobile,
      isTabletLayout: screenSize == ScreenSize.tablet,
      isDesktopLayout: screenSize == ScreenSize.desktop,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Show error overlay
  UIState showError(String message,
      {ErrorOverlayType type = ErrorOverlayType.general}) {
    return copyWith(
      showErrorOverlay: true,
      errorOverlayMessage: message,
      errorOverlayType: type,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Hide error overlay
  UIState hideError() {
    return copyWith(
      showErrorOverlay: false,
      errorOverlayMessage: null,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update performance metrics
  UIState updatePerformanceMetrics({
    double? frameRate,
    double? memoryUsage,
  }) {
    return copyWith(
      frameRate: frameRate ?? this.frameRate,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Determine screen size category from width
  static ScreenSize _determineScreenSize(double width) {
    if (width < 600) return ScreenSize.mobile;
    if (width < 1024) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }
}
