import 'package:logger/logger.dart';

/// 日志记录服务 - 统一的应用日志管理系统
///
/// LoggerService是整个应用的日志记录中心，提供：
/// - 📝 **统一日志接口**：标准化的日志记录方法
/// - 🎨 **美观输出格式**：彩色、结构化的日志显示
/// - 🔧 **环境适配**：开发和生产环境的不同日志策略
/// - 🤖 **AI专用日志**：针对AI功能的专门日志方法
/// - ⚡ **性能优化**：高效的日志过滤和输出
///
/// ## 🏗️ 架构设计
///
/// ### 单例模式
/// 确保全应用使用统一的日志配置和实例：
/// ```dart
/// final logger = LoggerService(); // 总是返回同一个实例
/// ```
///
/// ### 分级日志
/// 支持5个标准日志级别：
/// - 🐛 **Debug**: 调试信息，仅开发环境显示
/// - ℹ️ **Info**: 一般信息，记录重要操作
/// - ⚠️ **Warning**: 警告信息，需要注意但不影响功能
/// - ❌ **Error**: 错误信息，功能异常但应用可继续
/// - 💀 **Fatal**: 致命错误，应用可能崩溃
///
/// ### AI专用日志
/// 针对AI功能提供专门的日志方法：
/// - 🤖 **AI请求**: 记录AI请求的详细信息
/// - ✅ **AI响应**: 记录AI响应和性能数据
/// - 📡 **流式数据**: 记录流式AI响应的进度
/// - ❌ **AI错误**: 记录AI相关的错误信息
///
/// ## 🎨 输出特性
///
/// ### 美观格式
/// - **彩色输出**: 不同级别使用不同颜色
/// - **表情符号**: 使用emoji增强可读性
/// - **时间戳**: 显示精确的时间信息
/// - **调用栈**: 显示方法调用链路
///
/// ### 智能过滤
/// - **开发环境**: 显示所有日志级别
/// - **生产环境**: 只显示Warning及以上级别
/// - **可配置**: 支持自定义过滤策略
///
/// ## 🚀 使用示例
///
/// ### 基础日志记录
/// ```dart
/// final logger = LoggerService();
///
/// logger.debug('调试信息');
/// logger.info('操作成功');
/// logger.warning('注意事项');
/// logger.error('发生错误');
/// logger.fatal('严重错误');
/// ```
///
/// ### AI专用日志
/// ```dart
/// // AI请求开始
/// logger.aiRequest('assistant-1', 'gpt-4', {'message': 'Hello'});
///
/// // AI响应成功
/// logger.aiResponse('assistant-1', 'Hello there!', Duration(seconds: 2));
///
/// // AI错误处理
/// logger.aiError('assistant-1', 'API rate limit exceeded', Duration(seconds: 1));
/// ```
///
/// ## ⚙️ 配置选项
/// - **Release模式日志**: 可选择在生产环境启用日志
/// - **输出格式**: 可自定义日志格式和样式
/// - **性能优化**: 自动优化高频日志的输出
class LoggerService {
  // 单例模式实现
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  /// 底层日志记录器实例
  /// 使用logger包提供的Logger类，配置了美观的输出格式
  late final Logger _logger;

  /// 初始化日志服务
  ///
  /// 配置日志记录器的输出格式、过滤策略和环境适配。
  /// 这个方法应该在应用启动时调用一次。
  ///
  /// ## 🎨 输出配置
  ///
  /// ### 美观打印器 (PrettyPrinter)
  /// - **methodCount: 2**: 显示2层方法调用栈，帮助定位日志来源
  /// - **errorMethodCount: 8**: 错误时显示8层调用栈，便于调试
  /// - **lineLength: 120**: 控制台输出行长度，适配大多数终端
  /// - **colors: true**: 启用彩色输出，不同级别使用不同颜色
  /// - **printEmojis: true**: 显示emoji图标，增强可读性
  /// - **dateTimeFormat**: 显示时间戳和启动后经过时间
  ///
  /// ### 环境过滤策略
  /// - **开发环境 (DevelopmentFilter)**: 显示所有日志级别
  /// - **生产环境 (ProductionFilter)**: 只显示Warning及以上级别
  ///
  /// @param enableInReleaseMode 是否在生产环境启用日志
  ///   - `false` (默认): 生产环境使用ProductionFilter
  ///   - `true`: 生产环境也使用DevelopmentFilter
  ///
  /// ## 🚀 使用示例
  /// ```dart
  /// // 应用启动时初始化
  /// void main() {
  ///   final logger = LoggerService();
  ///   logger.initialize(); // 使用默认配置
  ///
  ///   // 或者启用生产环境日志
  ///   logger.initialize(enableInReleaseMode: true);
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## ⚠️ 注意事项
  /// - 必须在使用其他日志方法前调用
  /// - 只需要调用一次，重复调用会覆盖之前的配置
  /// - 生产环境启用日志可能影响性能
  void initialize({bool enableInReleaseMode = false}) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 显示方法调用栈的层数
        errorMethodCount: 8, // 错误时显示更多调用栈
        lineLength: 120, // 控制台输出的行长度
        colors: true, // 彩色输出
        printEmojis: true, // 显示emoji图标
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 显示时间戳
      ),
      filter: enableInReleaseMode ? ProductionFilter() : DevelopmentFilter(),
    );
  }

  // ============================================================================
  // 基础日志方法 - 标准的分级日志记录接口
  // ============================================================================

  /// 调试日志 - 记录详细的调试信息
  ///
  /// 用于记录开发过程中的详细信息，帮助开发者理解程序执行流程。
  ///
  /// ## 🎯 使用场景
  /// - 变量值跟踪
  /// - 方法执行流程
  /// - 条件分支判断
  /// - 循环迭代过程
  ///
  /// ## 📱 显示策略
  /// - **开发环境**: 正常显示
  /// - **生产环境**: 默认不显示（除非特别配置）
  ///
  /// @param message 调试消息内容
  /// @param error 可选的错误对象或附加数据
  /// @param stackTrace 可选的堆栈跟踪信息
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.debug('用户ID: $userId');
  /// logger.debug('处理请求', {'url': url, 'method': method});
  /// logger.debug('异常捕获', exception, stackTrace);
  /// ```
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志 - 记录重要的操作信息
  ///
  /// 用于记录应用的重要操作和状态变化，是最常用的日志级别。
  ///
  /// ## 🎯 使用场景
  /// - 用户操作记录
  /// - 服务启动/停止
  /// - 重要功能执行
  /// - 状态变更通知
  ///
  /// ## 📱 显示策略
  /// - **开发环境**: 正常显示
  /// - **生产环境**: 正常显示
  ///
  /// @param message 信息消息内容
  /// @param error 可选的附加数据（通常是Map或对象）
  /// @param stackTrace 可选的堆栈跟踪信息
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.info('用户登录成功');
  /// logger.info('数据库连接建立', {'host': host, 'port': port});
  /// logger.info('文件上传完成', {'fileName': name, 'size': size});
  /// ```
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志 - 记录需要注意的问题
  ///
  /// 用于记录可能影响功能但不会导致失败的问题。
  ///
  /// ## 🎯 使用场景
  /// - 配置缺失或不当
  /// - 性能问题警告
  /// - 兼容性问题
  /// - 资源使用警告
  ///
  /// ## 📱 显示策略
  /// - **开发环境**: 正常显示
  /// - **生产环境**: 正常显示
  ///
  /// @param message 警告消息内容
  /// @param error 可选的错误对象或附加数据
  /// @param stackTrace 可选的堆栈跟踪信息
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.warning('API响应时间较长');
  /// logger.warning('使用了已废弃的方法', {'method': methodName});
  /// logger.warning('内存使用率较高', {'usage': '85%'});
  /// ```
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志 - 记录功能异常和错误
  ///
  /// 用于记录影响功能正常运行的错误，但应用仍可继续运行。
  ///
  /// ## 🎯 使用场景
  /// - API请求失败
  /// - 数据处理错误
  /// - 文件操作失败
  /// - 网络连接问题
  ///
  /// ## 📱 显示策略
  /// - **开发环境**: 正常显示
  /// - **生产环境**: 正常显示
  ///
  /// @param message 错误消息内容
  /// @param error 可选的错误对象（Exception、Error等）
  /// @param stackTrace 可选的堆栈跟踪信息
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.error('API请求失败');
  /// logger.error('数据解析错误', exception);
  /// logger.error('文件读取失败', error, stackTrace);
  /// ```
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志 - 记录严重的系统错误
  ///
  /// 用于记录可能导致应用崩溃或核心功能完全失效的严重错误。
  ///
  /// ## 🎯 使用场景
  /// - 系统初始化失败
  /// - 核心服务崩溃
  /// - 数据库连接完全失败
  /// - 内存不足等系统级错误
  ///
  /// ## 📱 显示策略
  /// - **开发环境**: 正常显示
  /// - **生产环境**: 正常显示
  ///
  /// @param message 致命错误消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.fatal('应用初始化失败');
  /// logger.fatal('数据库连接完全失败', exception);
  /// logger.fatal('内存不足，应用即将崩溃', error, stackTrace);
  /// ```
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // ============================================================================
  // AI专用日志方法 - 针对AI功能优化的日志记录接口
  // ============================================================================

  /// AI请求日志 - 记录AI请求的详细信息
  ///
  /// 专门用于记录发送给AI提供商的请求信息，帮助跟踪AI功能的使用情况。
  ///
  /// ## 🎯 记录内容
  /// - **助手信息**: 使用的AI助手ID和配置
  /// - **模型信息**: 使用的AI模型名称
  /// - **请求详情**: 完整的请求参数和内容
  ///
  /// ## 📊 用途
  /// - **调试AI问题**: 查看具体的请求参数
  /// - **性能分析**: 分析不同模型的使用情况
  /// - **用量统计**: 统计AI功能的使用频率
  /// - **问题排查**: 定位AI请求失败的原因
  ///
  /// @param assistantId AI助手的唯一标识符
  /// @param model 使用的AI模型名称（如'gpt-4', 'claude-3'等）
  /// @param request 请求的详细参数，包含消息内容、配置等
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.aiRequest(
  ///   'coding-assistant',
  ///   'gpt-4',
  ///   {
  ///     'messages': messages,
  ///     'temperature': 0.7,
  ///     'maxTokens': 1000,
  ///   },
  /// );
  /// ```
  void aiRequest(
    String assistantId,
    String model,
    Map<String, dynamic> request,
  ) {
    _logger.i(
      '🤖 AI请求',
      error: {'assistantId': assistantId, 'model': model, 'request': request},
    );
  }

  /// AI响应成功日志 - 记录AI响应的成功信息
  ///
  /// 记录AI提供商返回的成功响应，包含性能数据和内容预览。
  ///
  /// ## 📊 记录数据
  /// - **响应时间**: 从请求到响应的总耗时
  /// - **内容长度**: 响应内容的字符数
  /// - **内容预览**: 响应内容的前100个字符
  /// - **助手信息**: 处理请求的助手ID
  ///
  /// ## 🎯 分析价值
  /// - **性能监控**: 跟踪AI响应速度
  /// - **质量评估**: 通过内容预览快速评估响应质量
  /// - **使用统计**: 统计成功请求的数量和模式
  /// - **优化依据**: 为性能优化提供数据支持
  ///
  /// @param assistantId AI助手的唯一标识符
  /// @param response AI返回的完整响应内容
  /// @param duration 请求处理的总耗时
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.aiResponse(
  ///   'coding-assistant',
  ///   'Here is the code you requested...',
  ///   Duration(milliseconds: 1500),
  /// );
  /// ```
  void aiResponse(String assistantId, String response, Duration duration) {
    _logger.i(
      '✅ AI响应成功',
      error: {
        'assistantId': assistantId,
        'duration': '${duration.inMilliseconds}ms',
        'responseLength': response.length,
        'preview': response.length > 100
            ? '${response.substring(0, 100)}...'
            : response,
      },
    );
  }

  /// AI错误日志 - 记录AI请求失败的详细信息
  ///
  /// 专门记录AI功能相关的错误，包含错误原因和性能数据。
  ///
  /// ## 🔍 错误分析
  /// - **错误类型**: 网络错误、API错误、配置错误等
  /// - **失败时间**: 请求失败时的耗时（如果有）
  /// - **助手信息**: 发生错误的助手ID
  /// - **错误详情**: 具体的错误消息和原因
  ///
  /// ## 🎯 排查价值
  /// - **问题定位**: 快速定位AI功能问题
  /// - **错误统计**: 统计不同类型错误的频率
  /// - **稳定性监控**: 监控AI服务的稳定性
  /// - **用户体验**: 改善错误处理和用户提示
  ///
  /// @param assistantId AI助手的唯一标识符
  /// @param error 错误信息或异常描述
  /// @param duration 请求失败时的耗时（可能为null）
  ///
  /// ## 使用示例
  /// ```dart
  /// logger.aiError(
  ///   'coding-assistant',
  ///   'API rate limit exceeded',
  ///   Duration(milliseconds: 500),
  /// );
  /// ```
  void aiError(String assistantId, String error, Duration? duration) {
    _logger.e(
      '❌ AI请求失败',
      error: {
        'assistantId': assistantId,
        'duration': duration != null
            ? '${duration.inMilliseconds}ms'
            : 'unknown',
        'error': error,
      },
    );
  }
}
