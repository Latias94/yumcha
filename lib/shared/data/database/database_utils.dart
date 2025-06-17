/// 数据库工具类和数据模型
/// 
/// 包含数据库性能监控、数据清理等功能的辅助类和数据模型

/// 数据清理结果
class DataCleanupResult {
  bool success = false;
  int conversationsDeleted = 0;
  int messagesDeleted = 0;
  int messageBlocksDeleted = 0;
  String? error;
  
  DataCleanupResult();
  
  /// 总删除数量
  int get totalDeleted => conversationsDeleted + messagesDeleted + messageBlocksDeleted;
  
  /// 格式化结果
  String get summary {
    if (!success) {
      return '清理失败: ${error ?? "未知错误"}';
    }
    
    final parts = <String>[];
    if (conversationsDeleted > 0) parts.add('对话: $conversationsDeleted');
    if (messagesDeleted > 0) parts.add('消息: $messagesDeleted');
    if (messageBlocksDeleted > 0) parts.add('消息块: $messageBlocksDeleted');
    
    if (parts.isEmpty) {
      return '无数据需要清理';
    }
    
    return '已清理 ${parts.join(', ')}';
  }
}

/// 数据库统计信息
class DatabaseStats {
  int conversationCount = 0;
  int messageCount = 0;
  int messageBlockCount = 0;
  int providerCount = 0;
  int assistantCount = 0;
  int favoriteModelCount = 0;
  int settingCount = 0;
  
  int databaseSizeBytes = 0;
  DateTime? lastActivityAt;
  
  DatabaseStats();
  
  /// 格式化数据库大小
  String get formattedSize {
    if (databaseSizeBytes < 1024) {
      return '${databaseSizeBytes}B';
    } else if (databaseSizeBytes < 1024 * 1024) {
      return '${(databaseSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else if (databaseSizeBytes < 1024 * 1024 * 1024) {
      return '${(databaseSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(databaseSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
  
  /// 总记录数
  int get totalRecords => conversationCount + messageCount + messageBlockCount + 
                         providerCount + assistantCount + favoriteModelCount + settingCount;
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'conversationCount': conversationCount,
      'messageCount': messageCount,
      'messageBlockCount': messageBlockCount,
      'providerCount': providerCount,
      'assistantCount': assistantCount,
      'favoriteModelCount': favoriteModelCount,
      'settingCount': settingCount,
      'databaseSizeBytes': databaseSizeBytes,
      'formattedSize': formattedSize,
      'totalRecords': totalRecords,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
    };
  }
}

/// 查询执行计划
class QueryPlan {
  final int id;
  final int parent;
  final String detail;
  
  QueryPlan({
    required this.id,
    required this.parent,
    required this.detail,
  });
  
  /// 是否使用了索引
  bool get usesIndex => detail.toLowerCase().contains('index');
  
  /// 是否是全表扫描
  bool get isTableScan => detail.toLowerCase().contains('scan table');
  
  /// 性能等级 (1-5, 5最好)
  int get performanceLevel {
    if (usesIndex) return 5;
    if (isTableScan) return 1;
    if (detail.toLowerCase().contains('search')) return 3;
    return 2;
  }
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent': parent,
      'detail': detail,
      'usesIndex': usesIndex,
      'isTableScan': isTableScan,
      'performanceLevel': performanceLevel,
    };
  }
}

/// 数据库性能监控器
class DatabasePerformanceMonitor {
  static final Map<String, List<Duration>> _queryTimes = {};
  static final Map<String, int> _queryCount = {};
  
  /// 记录查询时间
  static void recordQuery(String queryType, Duration duration) {
    _queryTimes.putIfAbsent(queryType, () => []).add(duration);
    _queryCount[queryType] = (_queryCount[queryType] ?? 0) + 1;
  }
  
  /// 获取查询统计
  static Map<String, QueryStats> getQueryStats() {
    final stats = <String, QueryStats>{};
    
    for (final entry in _queryTimes.entries) {
      final times = entry.value;
      if (times.isNotEmpty) {
        final total = times.fold(Duration.zero, (a, b) => a + b);
        final average = Duration(microseconds: total.inMicroseconds ~/ times.length);
        final max = times.reduce((a, b) => a > b ? a : b);
        final min = times.reduce((a, b) => a < b ? a : b);
        
        stats[entry.key] = QueryStats(
          queryType: entry.key,
          count: _queryCount[entry.key] ?? 0,
          totalTime: total,
          averageTime: average,
          maxTime: max,
          minTime: min,
        );
      }
    }
    
    return stats;
  }
  
  /// 清除统计数据
  static void clearStats() {
    _queryTimes.clear();
    _queryCount.clear();
  }
  
  /// 获取慢查询
  static List<QueryStats> getSlowQueries({Duration threshold = const Duration(milliseconds: 100)}) {
    return getQueryStats()
        .values
        .where((stats) => stats.averageTime > threshold)
        .toList()
      ..sort((a, b) => b.averageTime.compareTo(a.averageTime));
  }
}

/// 查询统计信息
class QueryStats {
  final String queryType;
  final int count;
  final Duration totalTime;
  final Duration averageTime;
  final Duration maxTime;
  final Duration minTime;
  
  QueryStats({
    required this.queryType,
    required this.count,
    required this.totalTime,
    required this.averageTime,
    required this.maxTime,
    required this.minTime,
  });
  
  /// 每秒查询数
  double get queriesPerSecond {
    if (totalTime.inMilliseconds == 0) return 0;
    return count * 1000 / totalTime.inMilliseconds;
  }
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'queryType': queryType,
      'count': count,
      'totalTimeMs': totalTime.inMilliseconds,
      'averageTimeMs': averageTime.inMilliseconds,
      'maxTimeMs': maxTime.inMilliseconds,
      'minTimeMs': minTime.inMilliseconds,
      'queriesPerSecond': queriesPerSecond,
    };
  }
}

/// 数据库健康检查结果
class DatabaseHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final List<String> recommendations;
  final DatabaseStats stats;
  
  DatabaseHealthCheck({
    required this.isHealthy,
    required this.issues,
    required this.recommendations,
    required this.stats,
  });
  
  /// 创建健康的检查结果
  factory DatabaseHealthCheck.healthy(DatabaseStats stats) {
    return DatabaseHealthCheck(
      isHealthy: true,
      issues: [],
      recommendations: [],
      stats: stats,
    );
  }
  
  /// 创建有问题的检查结果
  factory DatabaseHealthCheck.unhealthy(
    DatabaseStats stats,
    List<String> issues,
    List<String> recommendations,
  ) {
    return DatabaseHealthCheck(
      isHealthy: false,
      issues: issues,
      recommendations: recommendations,
      stats: stats,
    );
  }
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'isHealthy': isHealthy,
      'issues': issues,
      'recommendations': recommendations,
      'stats': stats.toMap(),
    };
  }
}

/// 数据库配置选项
class DatabaseConfig {
  final int cacheSize;
  final String journalMode;
  final String synchronous;
  final String tempStore;
  final int mmapSize;
  final bool foreignKeys;
  
  const DatabaseConfig({
    this.cacheSize = -10000, // 10MB
    this.journalMode = 'WAL',
    this.synchronous = 'NORMAL',
    this.tempStore = 'MEMORY',
    this.mmapSize = 268435456, // 256MB
    this.foreignKeys = true,
  });
  
  /// 默认配置
  static const DatabaseConfig defaultConfig = DatabaseConfig();
  
  /// 高性能配置
  static const DatabaseConfig highPerformance = DatabaseConfig(
    cacheSize: -20000, // 20MB
    synchronous: 'OFF',
    mmapSize: 536870912, // 512MB
  );

  /// 安全配置
  static const DatabaseConfig safe = DatabaseConfig(
    synchronous: 'FULL',
    mmapSize: 134217728, // 128MB
  );
}
