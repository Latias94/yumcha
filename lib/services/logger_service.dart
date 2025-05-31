import 'package:logger/logger.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  late final Logger _logger;

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

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // AI专用日志方法
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

  void aiStreamStart(String assistantId, String model) {
    _logger.i(
      '🚀 AI流式请求开始',
      error: {'assistantId': assistantId, 'model': model},
    );
  }

  void aiStreamChunk(String assistantId, int chunkCount, int totalLength) {
    if (chunkCount % 20 == 0) {
      // 每20个chunk记录一次
      _logger.d(
        '📡 AI流式数据',
        error: {
          'assistantId': assistantId,
          'chunks': chunkCount,
          'totalLength': totalLength,
        },
      );
    }
  }

  void aiStreamComplete(
    String assistantId,
    int totalChunks,
    Duration duration,
  ) {
    _logger.i(
      '🏁 AI流式请求完成',
      error: {
        'assistantId': assistantId,
        'totalChunks': totalChunks,
        'duration': '${duration.inMilliseconds}ms',
      },
    );
  }

  void aiStreamStopped(
    String assistantId,
    int chunksReceived,
    Duration duration,
  ) {
    _logger.w(
      '⏹️ AI流式请求被停止',
      error: {
        'assistantId': assistantId,
        'chunksReceived': chunksReceived,
        'duration': '${duration.inMilliseconds}ms',
      },
    );
  }
}
