import 'dart:io' show Platform, InternetAddress;

/// 平台工具类 - 提供跨平台兼容性检查和配置
class PlatformUtils {
  /// 检查是否为桌面平台
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// 检查是否为移动平台
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// 获取当前平台名称
  static String get platformName {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  /// 获取平台图标
  static String get platformIcon {
    if (Platform.isWindows) return '🪟';
    if (Platform.isMacOS) return '🍎';
    if (Platform.isLinux) return '🐧';
    if (Platform.isAndroid) return '🤖';
    if (Platform.isIOS) return '📱';
    return '❓';
  }

  /// 检查是否支持本地进程执行（STDIO MCP）
  static bool get supportsLocalProcesses => isDesktop;

  /// 检查是否支持网络连接（HTTP/SSE MCP）
  static bool get supportsNetworkConnections => true;

  /// 获取推荐的文件路径分隔符
  static String get pathSeparator => Platform.pathSeparator;

  /// 获取推荐的可执行文件扩展名
  static String get executableExtension => Platform.isWindows ? '.exe' : '';

  /// 获取默认的MCP服务器安装路径
  static String get defaultMcpServerPath {
    if (Platform.isWindows) {
      return 'C:\\Program Files\\MCP\\';
    } else if (Platform.isMacOS) {
      return '/usr/local/bin/';
    } else if (Platform.isLinux) {
      return '/usr/local/bin/';
    }
    return '';
  }

  /// 获取用户配置目录
  static String get userConfigDirectory {
    if (Platform.isWindows) {
      return '${Platform.environment['APPDATA']}\\YumCha\\';
    } else if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Library/Application Support/YumCha/';
    } else if (Platform.isLinux) {
      return '${Platform.environment['HOME']}/.config/yumcha/';
    } else if (Platform.isAndroid) {
      return '/data/data/com.example.yumcha/files/';
    } else if (Platform.isIOS) {
      return 'Documents/';
    }
    return '';
  }

  /// 获取临时目录
  static String get tempDirectory {
    if (Platform.isWindows) {
      return Platform.environment['TEMP'] ?? 'C:\\temp\\';
    } else {
      return '/tmp/';
    }
  }

  /// 检查路径是否为绝对路径
  static bool isAbsolutePath(String path) {
    if (Platform.isWindows) {
      return path.length >= 3 &&
          path[1] == ':' &&
          (path[2] == '\\' || path[2] == '/');
    } else {
      return path.startsWith('/');
    }
  }

  /// 规范化路径
  static String normalizePath(String path) {
    if (Platform.isWindows) {
      return path.replaceAll('/', '\\');
    } else {
      return path.replaceAll('\\', '/');
    }
  }

  /// 获取平台特定的MCP服务器示例
  static Map<String, String> getMcpServerExamples() {
    if (Platform.isWindows) {
      return {
        'stdio_command': 'C:\\tools\\mcp-server.exe',
        'stdio_args': '--config "C:\\tools\\config.json"',
        'http_url': 'http://localhost:3000/mcp',
        'sse_url': 'http://localhost:3001/sse',
      };
    } else if (Platform.isMacOS || Platform.isLinux) {
      return {
        'stdio_command': '/usr/local/bin/mcp-server',
        'stdio_args': '--config /etc/mcp/config.json',
        'http_url': 'http://localhost:3000/mcp',
        'sse_url': 'http://localhost:3001/sse',
      };
    } else {
      // 移动端只支持网络连接
      return {
        'http_url': 'https://api.example.com/mcp',
        'sse_url': 'https://stream.example.com/sse',
      };
    }
  }

  /// 获取平台特定的性能建议
  static Map<String, dynamic> getPerformanceRecommendations() {
    return {
      'maxConcurrentConnections': isDesktop ? 10 : 5,
      'connectionTimeout': isDesktop ? 30000 : 15000, // 毫秒
      'retryAttempts': isDesktop ? 3 : 2,
      'enableLocalCache': true,
      'maxCacheSize': isDesktop ? 100 : 50, // MB
    };
  }

  /// 检查网络连接是否可用（简单检查）
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 获取平台特定的错误处理建议
  static String getErrorHandlingSuggestion(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'permission_denied':
        if (Platform.isWindows) {
          return '请以管理员身份运行应用程序';
        } else {
          return '请检查文件权限，可能需要使用 chmod +x 命令';
        }
      case 'file_not_found':
        return '请检查文件路径是否正确，路径分隔符应为 ${Platform.pathSeparator}';
      case 'network_error':
        if (isMobile) {
          return '请检查网络连接和移动数据权限';
        } else {
          return '请检查网络连接和防火墙设置';
        }
      default:
        return '请查看详细错误信息并检查系统日志';
    }
  }

  /// 获取平台特定的UI建议
  static Map<String, dynamic> getUIRecommendations() {
    return {
      'useNativeScrollbars': isDesktop,
      'enableHoverEffects': isDesktop,
      'defaultFontSize': isMobile ? 16.0 : 14.0,
      'buttonMinHeight': isMobile ? 48.0 : 36.0,
      'listItemHeight': isMobile ? 56.0 : 48.0,
      'enableSwipeGestures': isMobile,
      'showTooltips': isDesktop,
    };
  }
}
