import 'package:logger/logger.dart';
import 'package:logging/logging.dart' as logging;

/// 简洁的日志打印器 - 类似Rust tracing log风格
class _SimplePrinter extends LogPrinter {
  static final _levelColors = {
    Level.trace: AnsiColor.fg(8), // 灰色
    Level.debug: AnsiColor.fg(12), // 亮蓝色
    Level.info: AnsiColor.fg(10), // 亮绿色
    Level.warning: AnsiColor.fg(11), // 亮黄色
    Level.error: AnsiColor.fg(9), // 亮红色
    Level.fatal: AnsiColor.fg(13), // 亮紫色
  };

  static final _levelNames = {
    Level.trace: 'TRACE',
    Level.debug: 'DEBUG',
    Level.info: 'INFO ',
    Level.warning: 'WARN ',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };

  @override
  List<String> log(LogEvent event) {
    final color = _levelColors[event.level] ?? AnsiColor.none();
    final levelName = _levelNames[event.level] ?? 'UNKNOWN';
    final time = DateTime.now();
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${(time.millisecond ~/ 10).toString().padLeft(2, '0')}';

    final message = event.message.toString();
    final error = event.error;

    // 提取代码位置信息
    final location = _extractLocation(StackTrace.current);

    final output = <String>[];

    // 处理多行消息
    final messageLines = message.split('\n');
    final locationStr = location.isNotEmpty ? '$location: ' : '';

    // 计算缩进长度：时间(11) + 空格(1) + 级别(5) + 空格(1) + 位置 = 18 + 位置长度
    final indentLength = 18 + locationStr.length;
    final indent = ' ' * indentLength;

    // 第一行：完整的日志头 + 第一行消息
    output.add('${color('$timeStr $levelName')} $locationStr${messageLines.first}');

    // 后续行：使用缩进对齐
    if (messageLines.length > 1) {
      for (int i = 1; i < messageLines.length; i++) {
        output.add('$indent${messageLines[i]}');
      }
    }

    // 如果有错误信息，添加到下一行
    if (error != null) {
      final errorStr = error.toString();
      if (errorStr.isNotEmpty && errorStr != message) {
        final errorLines = errorStr.split('\n');
        for (int i = 0; i < errorLines.length; i++) {
          final prefix = i == 0 ? '     └─ ' : '        ';
          output.add('${color(prefix)}${errorLines[i]}');
        }
      }
    }

    // 如果有堆栈跟踪且是错误级别，显示简化的堆栈
    if (event.stackTrace != null && event.level.index >= Level.error.index) {
      final stackLines = event.stackTrace.toString().split('\n');
      final relevantLines = stackLines
          .where((line) => line.contains('package:') && !line.contains('logger'))
          .take(2);

      for (final line in relevantLines) {
        final cleanLine = line.trim().replaceAll(RegExp(r'#\d+\s+'), '');
        output.add('${color('     └─ ')}$cleanLine');
      }
    }

    return output;
  }

  /// 从堆栈跟踪中提取代码位置信息
  /// 返回格式: filename:line 或 class.method:line
  String _extractLocation(StackTrace? stackTrace) {
    if (stackTrace == null) return '';

    final stackLines = stackTrace.toString().split('\n');

    // 跳过前几行（通常是logger内部调用），查找真正的调用位置
    for (final line in stackLines) {
      // 跳过logger、logging相关的内部调用
      if (line.contains('logger') ||
          line.contains('logging') ||
          line.contains('_SimplePrinter') ||
          line.contains('LoggerService')) {
        continue;
      }

      // 查找应用代码
      if (line.contains('package:')) {
        // 提取文件名和行号
        // 格式通常是: #1      method (package:app/path/file.dart:123:45)
        final match = RegExp(r'package:[^/]+/([^/]+/)*([^/:]+\.dart):(\d+)').firstMatch(line);
        if (match != null) {
          final filename = match.group(2)?.replaceAll('.dart', '') ?? '';
          final lineNumber = match.group(3) ?? '';
          return '$filename:$lineNumber';
        }

        // 如果上面的正则没匹配到，尝试更简单的格式
        final simpleMatch = RegExp(r'([^/]+\.dart):(\d+)').firstMatch(line);
        if (simpleMatch != null) {
          final filename = simpleMatch.group(1)?.replaceAll('.dart', '') ?? '';
          final lineNumber = simpleMatch.group(2) ?? '';
          return '$filename:$lineNumber';
        }
      }

      // 如果不是package:开头但包含.dart，也尝试提取
      if (line.contains('.dart:')) {
        final match = RegExp(r'([^/\s]+\.dart):(\d+)').firstMatch(line);
        if (match != null) {
          final filename = match.group(1)?.replaceAll('.dart', '') ?? '';
          final lineNumber = match.group(2) ?? '';
          return '$filename:$lineNumber';
        }
      }
    }

    return '';
  }
}

/// 自定义日志过滤器 - 支持在发布模式下也显示日志
class _CustomLogFilter extends LogFilter {
  _CustomLogFilter({
    this.enableInReleaseMode = false,
  });

  final bool enableInReleaseMode;

  @override
  bool shouldLog(LogEvent event) {
    // 如果启用了发布模式日志，总是显示
    if (enableInReleaseMode) {
      return event.level.index >= Logger.level.index;
    }

    // 否则使用默认的开发模式过滤器行为
    bool inDebugMode = false;
    assert(inDebugMode = true);

    if (inDebugMode) {
      return event.level.index >= Logger.level.index;
    }

    return false;
  }
}

/// 日志记录服务 - 统一的应用日志管理系统
///
/// 提供彩色、结构化的日志输出，支持debug/info/warning/error/fatal五个级别
/// 使用单例模式，支持HTTP日志集成
class LoggerService {
  // 单例模式实现
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  Logger? _logger;

  Logger get logger {
    if (_logger == null) {
      initialize();
    }
    return _logger!;
  }



  /// 初始化日志服务
  ///
  /// @param enableInReleaseMode 是否在生产环境启用日志
  /// @param enableHttpLogging 是否启用 HTTP 日志记录
  /// @param logLevel 日志级别，默认为debug级别
  void initialize({
    bool enableInReleaseMode = false,
    bool enableHttpLogging = true,
    Level logLevel = Level.debug,
  }) {
    // 设置全局日志级别
    Logger.level = logLevel;

    _logger = Logger(
      printer: _SimplePrinter(),
      filter: _CustomLogFilter(enableInReleaseMode: enableInReleaseMode),
    );

    // 配置 llm_dart HTTP 日志集成
    if (enableHttpLogging) {
      _setupHttpLogging();
    }

    // 输出当前日志配置信息
    _logger!.i('📋 日志服务已初始化 - 级别: ${logLevel.name}, HTTP日志: $enableHttpLogging, 发布模式: $enableInReleaseMode');
  }

  /// 配置 llm_dart HTTP 日志集成
  void _setupHttpLogging() {
    // 设置 logging 包的日志级别
    logging.Logger.root.level = logging.Level.ALL;

    // 监听所有 logging 包的日志记录
    logging.Logger.root.onRecord.listen((record) {
      // 过滤出 HTTP 相关的日志
      if (_isHttpLog(record)) {
        _handleHttpLog(record);
      }
    });
  }

  /// 检查是否为 HTTP 相关日志
  bool _isHttpLog(logging.LogRecord record) {
    final loggerName = record.loggerName.toLowerCase();
    final message = record.message.toLowerCase();

    // 检查日志来源是否为 HTTP 相关
    return loggerName.contains('http') ||
        loggerName.contains('dio') ||
        loggerName.contains('client') ||
        message.contains('request') ||
        message.contains('response') ||
        message.contains('http');
  }

  /// 处理 HTTP 日志记录
  void _handleHttpLog(logging.LogRecord record) {
    // 过滤敏感信息
    final sanitizedMessage = _sanitizeHttpMessage(record.message);

    // 根据 logging 包的级别映射到对应的日志方法
    switch (record.level.name) {
      case 'SEVERE':
      case 'SHOUT':
        error('HTTP: $sanitizedMessage', record.error, record.stackTrace);
        break;
      case 'WARNING':
        warning('HTTP: $sanitizedMessage', record.error, record.stackTrace);
        break;
      case 'INFO':
        info('HTTP: $sanitizedMessage');
        break;
      case 'CONFIG':
      case 'FINE':
      case 'FINER':
      case 'FINEST':
      default:
        debug('HTTP: $sanitizedMessage');
        break;
    }
  }

  /// 清理 HTTP 日志消息中的敏感信息
  String _sanitizeHttpMessage(String message) {
    String sanitized = message;

    // 清理常见的API密钥模式
    sanitized = sanitized.replaceAll(RegExp(r'sk-[a-zA-Z0-9]{20,}'), 'sk-***');
    sanitized =
        sanitized.replaceAll(RegExp(r'Bearer [a-zA-Z0-9]{20,}'), 'Bearer ***');
    sanitized = sanitized.replaceAll(
        RegExp(r'"api[_-]?key":\s*"[^"]*"'), '"api_key": "***"');
    sanitized = sanitized.replaceAll(
        RegExp(r'"authorization":\s*"[^"]*"'), '"authorization": "***"');

    // 截断过长的响应体
    if (sanitized.length > 1000) {
      sanitized = '${sanitized.substring(0, 1000)}... [截断]';
    }

    return sanitized;
  }

  // 日志级别管理

  /// 设置日志级别
  ///
  /// 可用级别：
  /// - Level.trace: 最详细的日志
  /// - Level.debug: 调试日志
  /// - Level.info: 信息日志
  /// - Level.warning: 警告日志
  /// - Level.error: 错误日志
  /// - Level.fatal: 致命错误日志
  void setLevel(Level level) {
    Logger.level = level;
    logger.i('📋 日志级别已更改为: ${level.name}');
  }

  /// 获取当前日志级别
  Level get currentLevel => Logger.level;

  /// 检查当前是否在调试模式
  bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // 基础日志方法

  /// 调试日志 - 开发环境显示，生产环境默认不显示
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志 - 记录重要操作
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志 - 记录需要注意的问题
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志 - 记录功能异常
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志 - 记录严重的系统错误
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.f(message, error: error, stackTrace: stackTrace);
  }
}
