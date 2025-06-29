import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ui_state.dart';

/// UI state notifier for managing visual and interaction aspects
///
/// This notifier manages scrolling, virtual scrolling, pagination,
/// theming, layout, and other UI-related state.
class UIStateNotifier extends StateNotifier<UIState> {
  final Ref _ref;

  UIStateNotifier(this._ref) : super(const UIState());

  // === Scroll Management ===

  /// Update scroll position
  void updateScrollPosition(double position) {
    state = state.updateScrollPosition(position);
  }

  /// Set auto-scroll enabled
  void setAutoScrollEnabled(bool enabled) {
    if (state.shouldAutoScroll == enabled) return;

    state = state.copyWith(
      shouldAutoScroll: enabled,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set scroll to message
  void setScrollToMessage(String? messageId) {
    state = state.copyWith(
      scrollToMessageId: messageId,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update scroll configuration
  void updateScrollConfig(ScrollConfig config) {
    state = state.copyWith(
      scrollConfig: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Virtual Scrolling ===

  /// Update visible range
  void updateVisibleRange(int startIndex, int endIndex) {
    state = state.updateVisibleRange(startIndex, endIndex);
  }

  /// Update item height
  void updateItemHeight(String messageId, double height) {
    final newItemHeights = Map<String, double>.from(state.itemHeights);
    newItemHeights[messageId] = height;

    state = state.copyWith(
      itemHeights: newItemHeights,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update virtual scroll configuration
  void updateVirtualScrollConfig(VirtualScrollConfig config) {
    state = state.copyWith(
      virtualScrollConfig: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Pagination ===

  /// Set loading more
  void setLoadingMore(bool loading) {
    if (state.isLoadingMore == loading) return;

    state = state.copyWith(
      isLoadingMore: loading,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set has more
  void setHasMore(bool hasMore) {
    if (state.hasMore == hasMore) return;

    state = state.copyWith(
      hasMore: hasMore,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update current page size
  void updateCurrentPageSize(int pageSize) {
    if (state.currentPageSize == pageSize) return;

    state = state.copyWith(
      currentPageSize: pageSize,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update pagination configuration
  void updatePaginationConfig(PaginationConfig config) {
    state = state.copyWith(
      paginationConfig: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Theme and Appearance ===

  /// Update theme configuration
  void updateThemeConfig(ThemeConfig config) {
    state = state.copyWith(
      themeConfig: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set theme mode
  void setThemeMode(ThemeMode themeMode) {
    final newConfig = state.themeConfig.copyWith(themeMode: themeMode);
    updateThemeConfig(newConfig);
  }

  /// Set font size multiplier
  void setFontSizeMultiplier(double multiplier) {
    final newConfig =
        state.themeConfig.copyWith(fontSizeMultiplier: multiplier);
    updateThemeConfig(newConfig);
  }

  /// Toggle compact mode
  void toggleCompactMode() {
    final newConfig = state.themeConfig
        .copyWith(isCompactMode: !state.themeConfig.isCompactMode);
    updateThemeConfig(newConfig);
  }

  /// Set primary color
  void setPrimaryColor(Color? color) {
    final newConfig = state.themeConfig.copyWith(primaryColorSeed: color);
    updateThemeConfig(newConfig);
  }

  // === Layout ===

  /// Update layout configuration
  void updateLayoutConfig(LayoutConfig config) {
    state = state.copyWith(
      layoutConfig: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set sidebar width
  void setSidebarWidth(double width) {
    final newConfig = state.layoutConfig.copyWith(sidebarWidth: width);
    updateLayoutConfig(newConfig);
  }

  /// Set chat max width
  void setChatMaxWidth(double width) {
    final newConfig = state.layoutConfig.copyWith(chatMaxWidth: width);
    updateLayoutConfig(newConfig);
  }

  /// Toggle message avatars
  void toggleMessageAvatars() {
    final newConfig = state.layoutConfig.copyWith(
      showMessageAvatars: !state.layoutConfig.showMessageAvatars,
    );
    updateLayoutConfig(newConfig);
  }

  /// Toggle message timestamps
  void toggleMessageTimestamps() {
    final newConfig = state.layoutConfig.copyWith(
      showMessageTimestamps: !state.layoutConfig.showMessageTimestamps,
    );
    updateLayoutConfig(newConfig);
  }

  // === Animation ===

  /// Update animation configuration
  void updateAnimationConfig(AnimationConfig config) {
    state = state.copyWith(
      animationConfig: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Toggle animations
  void toggleAnimations() {
    final newConfig = state.animationConfig.copyWith(
      enabled: !state.animationConfig.enabled,
    );
    updateAnimationConfig(newConfig);
  }

  /// Set reduced motion
  void setReducedMotion(bool useReducedMotion) {
    final newConfig =
        state.animationConfig.copyWith(useReducedMotion: useReducedMotion);
    updateAnimationConfig(newConfig);
  }

  // === Window and Viewport ===

  /// Update viewport size
  void updateViewportSize(Size size) {
    state = state.updateViewportSize(size);
  }

  /// Set window focused
  void setWindowFocused(bool focused) {
    if (state.isWindowFocused == focused) return;

    state = state.copyWith(
      isWindowFocused: focused,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set app in foreground
  void setAppInForeground(bool inForeground) {
    if (state.isAppInForeground == inForeground) return;

    state = state.copyWith(
      isAppInForeground: inForeground,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Input State ===

  /// Set input focused
  void setInputFocused(bool focused) {
    if (state.isInputFocused == focused) return;

    state = state.copyWith(
      isInputFocused: focused,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update input height
  void updateInputHeight(double height) {
    if (state.inputHeight == height) return;

    state = state.copyWith(
      inputHeight: height,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set input expanded
  void setInputExpanded(bool expanded) {
    if (state.isInputExpanded == expanded) return;

    state = state.copyWith(
      isInputExpanded: expanded,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Loading and Progress ===

  /// Set global loading
  void setGlobalLoading(bool loading, {String? message}) {
    state = state.copyWith(
      isGlobalLoading: loading,
      loadingMessage: loading ? message : null,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update progress
  void updateProgress(double? progress) {
    state = state.copyWith(
      progressValue: progress,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Error Display ===

  /// Show error
  void showError(String message,
      {ErrorOverlayType type = ErrorOverlayType.general}) {
    state = state.showError(message, type: type);
  }

  /// Hide error
  void hideError() {
    state = state.hideError();
  }

  // === Performance Monitoring ===

  /// Update performance metrics
  void updatePerformanceMetrics({double? frameRate, double? memoryUsage}) {
    state = state.updatePerformanceMetrics(
      frameRate: frameRate,
      memoryUsage: memoryUsage,
    );
  }

  /// Toggle performance overlay
  void togglePerformanceOverlay() {
    state = state.copyWith(
      showPerformanceOverlay: !state.showPerformanceOverlay,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Accessibility ===

  /// Set high contrast mode
  void setHighContrastMode(bool enabled) {
    if (state.highContrastMode == enabled) return;

    state = state.copyWith(
      highContrastMode: enabled,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set large text mode
  void setLargeTextMode(bool enabled) {
    if (state.largeTextMode == enabled) return;

    state = state.copyWith(
      largeTextMode: enabled,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set screen reader active
  void setScreenReaderActive(bool active) {
    if (state.screenReaderActive == active) return;

    state = state.copyWith(
      screenReaderActive: active,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Cleanup and Reset ===

  /// Reset UI state
  void reset() {
    state = const UIState();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

/// UI state provider
final uiStateProvider = StateNotifierProvider<UIStateNotifier, UIState>((ref) {
  return UIStateNotifier(ref);
});
