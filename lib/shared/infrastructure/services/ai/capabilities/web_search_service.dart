import 'dart:async';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../core/ai_service_base.dart';
import 'package:llm_dart/llm_dart.dart';

/// Web搜索服务 - 处理AI Web搜索功能
///
/// 这个服务专门处理AI Web搜索功能，包括：
/// - 🔍 **实时搜索**：获取最新的网络信息
/// - 📰 **新闻搜索**：搜索最新新闻资讯
/// - 🎯 **学术搜索**：搜索学术论文和研究
/// - 🌐 **多语言搜索**：支持多种语言搜索
///
/// ## 支持的提供商
/// - **xAI Grok**：实时搜索和新闻
/// - **Anthropic Claude**：Web搜索工具
/// - **OpenAI**：搜索增强模型
/// - **Perplexity**：原生搜索能力
///
/// ## 使用示例
/// ```dart
/// final webSearchService = WebSearchService();
/// await webSearchService.initialize();
///
/// final result = await webSearchService.searchWeb(
///   provider: provider,
///   assistant: assistant,
///   query: 'latest AI developments',
///   maxResults: 5,
/// );
/// ```
class WebSearchService extends AiServiceBase {
  // 单例模式实现
  static final WebSearchService _instance = WebSearchService._internal();
  factory WebSearchService() => _instance;
  WebSearchService._internal();

  /// Web搜索统计信息
  final Map<String, WebSearchStats> _stats = {};

  /// 服务初始化状态
  bool _isInitialized = false;

  @override
  String get serviceName => 'WebSearchService';

  @override
  Set<AiCapability> get supportedCapabilities => {
        AiCapability.webSearch,
      };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化Web搜索服务');
    _isInitialized = true;
    logger.info('Web搜索服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理Web搜索服务资源');
    _stats.clear();
    _isInitialized = false;
  }

  /// Web搜索
  ///
  /// 使用AI进行Web搜索并返回结果
  Future<WebSearchResponse> searchWeb({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String query,
    int maxResults = 5,
    String? language,
    List<String>? allowedDomains,
    List<String>? blockedDomains,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    logger.info('开始Web搜索', {
      'requestId': requestId,
      'provider': provider.name,
      'query': query,
      'maxResults': maxResults,
      'language': language,
    });

    try {
      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: assistant,
        modelName: _getSearchModel(provider),
      );

      final chatProvider = await adapter.createProvider();

      // 构建搜索消息
      final messages = <ChatMessage>[];

      // 添加系统提示
      if (assistant.systemPrompt.isNotEmpty) {
        messages.add(ChatMessage.system(assistant.systemPrompt));
      }

      // 添加搜索查询
      final searchPrompt = _buildSearchPrompt(query, maxResults, language);
      messages.add(ChatMessage.user(searchPrompt));

      // 发送搜索请求
      final response = await chatProvider.chat(messages);
      final duration = DateTime.now().difference(startTime);

      // 更新统计信息
      _updateStats(provider.id, true, duration);

      logger.info('Web搜索完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'responseLength': response.text?.length ?? 0,
      });

      return WebSearchResponse(
        results: _parseSearchResults(response.text ?? ''),
        query: query,
        duration: duration,
        isSuccess: true,
        usage: response.usage,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, false, duration);

      logger.error('Web搜索失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return WebSearchResponse(
        results: [],
        query: query,
        duration: duration,
        isSuccess: false,
        error: 'Web搜索失败: $e',
      );
    }
  }

  /// 新闻搜索
  ///
  /// 专门搜索新闻内容
  Future<WebSearchResponse> searchNews({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String query,
    int maxResults = 5,
    String? fromDate,
    String? toDate,
  }) async {
    await initialize();

    final requestId = _generateRequestId();
    final startTime = DateTime.now();

    logger.info('开始新闻搜索', {
      'requestId': requestId,
      'provider': provider.name,
      'query': query,
      'maxResults': maxResults,
      'fromDate': fromDate,
      'toDate': toDate,
    });

    try {
      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: assistant,
        modelName: _getSearchModel(provider),
      );

      final chatProvider = await adapter.createProvider();

      // 构建新闻搜索消息
      final messages = <ChatMessage>[];

      // 添加系统提示
      if (assistant.systemPrompt.isNotEmpty) {
        messages.add(ChatMessage.system(assistant.systemPrompt));
      }

      // 添加新闻搜索查询
      final newsPrompt =
          _buildNewsSearchPrompt(query, maxResults, fromDate, toDate);
      messages.add(ChatMessage.user(newsPrompt));

      // 发送搜索请求
      final response = await chatProvider.chat(messages);
      final duration = DateTime.now().difference(startTime);

      // 更新统计信息
      _updateStats(provider.id, true, duration);

      logger.info('新闻搜索完成', {
        'requestId': requestId,
        'duration': '${duration.inMilliseconds}ms',
        'responseLength': response.text?.length ?? 0,
      });

      return WebSearchResponse(
        results: _parseSearchResults(response.text ?? ''),
        query: query,
        duration: duration,
        isSuccess: true,
        usage: response.usage,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _updateStats(provider.id, false, duration);

      logger.error('新闻搜索失败', {
        'requestId': requestId,
        'error': e.toString(),
        'duration': '${duration.inMilliseconds}ms',
      });

      return WebSearchResponse(
        results: [],
        query: query,
        duration: duration,
        isSuccess: false,
        error: '新闻搜索失败: $e',
      );
    }
  }

  /// 检查提供商是否支持Web搜索
  bool supportsWebSearch(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'xai':
      case 'anthropic':
      case 'openai':
      case 'perplexity':
      case 'openrouter':
        return true;
      default:
        return false;
    }
  }

  /// 构建搜索提示
  String _buildSearchPrompt(String query, int maxResults, String? language) {
    final buffer = StringBuffer();
    buffer.writeln('请帮我搜索以下内容：');
    buffer.writeln('查询：$query');
    buffer.writeln('最大结果数：$maxResults');
    if (language != null) {
      buffer.writeln('语言：$language');
    }
    buffer.writeln('请提供准确、最新的搜索结果。');
    return buffer.toString();
  }

  /// 构建新闻搜索提示
  String _buildNewsSearchPrompt(
      String query, int maxResults, String? fromDate, String? toDate) {
    final buffer = StringBuffer();
    buffer.writeln('请帮我搜索最新新闻：');
    buffer.writeln('查询：$query');
    buffer.writeln('最大结果数：$maxResults');
    if (fromDate != null) {
      buffer.writeln('开始日期：$fromDate');
    }
    if (toDate != null) {
      buffer.writeln('结束日期：$toDate');
    }
    buffer.writeln('请提供最新、可靠的新闻信息。');
    return buffer.toString();
  }

  /// 解析搜索结果
  List<SearchResult> _parseSearchResults(String responseText) {
    // 简化的结果解析 - 实际使用中应该根据具体的响应格式进行解析
    final results = <SearchResult>[];

    // 这里应该实现具体的解析逻辑
    // 目前返回一个示例结果
    results.add(SearchResult(
      title: '搜索结果',
      url: 'https://example.com',
      snippet: responseText.length > 200
          ? '${responseText.substring(0, 200)}...'
          : responseText,
      publishDate: DateTime.now(),
    ));

    return results;
  }

  /// 获取搜索模型
  String _getSearchModel(models.AiProvider provider) {
    switch (provider.type.name.toLowerCase()) {
      case 'xai':
        return 'grok-3';
      case 'anthropic':
        return 'claude-sonnet-4-20250514';
      case 'openai':
        return 'gpt-4o-search-preview';
      case 'perplexity':
        return 'llama-3.1-sonar-large-128k-online';
      default:
        return 'default-search-model';
    }
  }

  /// 更新统计信息
  void _updateStats(String providerId, bool success, Duration duration) {
    final currentStats = _stats[providerId] ?? WebSearchStats();

    _stats[providerId] = WebSearchStats(
      totalRequests: currentStats.totalRequests + 1,
      successfulRequests: success
          ? currentStats.successfulRequests + 1
          : currentStats.successfulRequests,
      failedRequests: success
          ? currentStats.failedRequests
          : currentStats.failedRequests + 1,
      totalDuration: currentStats.totalDuration + duration,
      lastRequestTime: DateTime.now(),
    );
  }

  /// 生成请求ID
  String _generateRequestId() {
    return 'web_search_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取Web搜索统计信息
  Map<String, WebSearchStats> getWebSearchStats() => Map.from(_stats);

  /// 清除统计信息
  void clearStats([String? providerId]) {
    if (providerId != null) {
      _stats.remove(providerId);
    } else {
      _stats.clear();
    }
  }
}

/// Web搜索响应
class WebSearchResponse {
  final List<SearchResult> results;
  final String query;
  final Duration duration;
  final bool isSuccess;
  final String? error;
  final UsageInfo? usage;

  const WebSearchResponse({
    required this.results,
    required this.query,
    required this.duration,
    required this.isSuccess,
    this.error,
    this.usage,
  });
}

/// 搜索结果
class SearchResult {
  final String title;
  final String url;
  final String snippet;
  final DateTime? publishDate;

  const SearchResult({
    required this.title,
    required this.url,
    required this.snippet,
    this.publishDate,
  });
}

/// Web搜索统计信息
class WebSearchStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final Duration totalDuration;
  final DateTime? lastRequestTime;

  const WebSearchStats({
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.totalDuration = Duration.zero,
    this.lastRequestTime,
  });

  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;
  Duration get averageDuration => totalRequests > 0
      ? Duration(microseconds: totalDuration.inMicroseconds ~/ totalRequests)
      : Duration.zero;
}
