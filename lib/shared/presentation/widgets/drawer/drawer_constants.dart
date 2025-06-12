/// 侧边栏相关常量配置
/// 
/// 集中管理侧边栏组件使用的各种常量，
/// 确保配置的一致性和易于维护。
class DrawerConstants {
  // 私有构造函数，防止实例化
  DrawerConstants._();

  /// 分页配置
  static const int pageSize = 20;
  
  /// 搜索防抖延迟（毫秒）
  static const int searchDebounceMs = 300;
  
  /// 侧边栏宽度配置
  static const double desktopWidth = 320.0;
  static const double tabletWidth = 300.0;
  
  /// 助手下拉列表最大高度
  static const double assistantDropdownMaxHeight = 200.0;
  
  /// 助手列表显示阈值（超过此数量显示滚动）
  static const int assistantListScrollThreshold = 10;
  
  /// 中文字符平均宽度系数（用于按钮宽度计算）
  static const double chineseCharWidthRatio = 0.6;
  
  /// 按钮宽度计算相关常量
  static const double buttonIconWidth = 20.0;
  static const double buttonSpacing = 8.0;
  static const double buttonHorizontalPadding = 24.0;
  static const double buttonLayoutSpacing = 12.0;
  
  /// 动画持续时间（毫秒）
  static const int staggeredAnimationDurationMs = 375;
  
  /// 搜索结果相关
  static const int maxSearchHistoryItems = 10;
  static const int searchResultsLimit = 100;
  
  /// 对话列表相关
  static const int maxConversationTitleLines = 2;
  static const int maxConversationDescriptionLines = 1;
  
  /// 缓存配置
  static const int maxCachedPages = 5;
  static const Duration cacheExpiration = Duration(minutes: 10);
}
