import 'dart:collection';
import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import 'chat_logger_service.dart';

/// 缓存的渲染结果
class _CachedRenderResult {
  final Widget widget;
  final String contentHash;
  final DateTime createdAt;
  final DateTime lastAccessed;

  _CachedRenderResult({
    required this.widget,
    required this.contentHash,
    required this.createdAt,
    required this.lastAccessed,
  });

  /// 创建更新访问时间的副本
  _CachedRenderResult withUpdatedAccess() {
    return _CachedRenderResult(
      widget: widget,
      contentHash: contentHash,
      createdAt: createdAt,
      lastAccessed: DateTime.now(),
    );
  }

  /// 检查是否过期（超过5分钟）
  bool get isExpired {
    return DateTime.now().difference(createdAt).inMinutes > 5;
  }
}

/// 消息缓存服务
///
/// 提供智能的消息和消息块缓存机制，
/// 优化内存使用和访问性能。
///
/// 功能特性：
/// - 🧠 **智能缓存**: LRU算法管理缓存
/// - 📊 **分层缓存**: 消息和消息块分别缓存
/// - 🔄 **自动清理**: 基于内存压力自动清理
/// - 📈 **性能监控**: 缓存命中率统计
/// - ⚙️ **可配置**: 灵活的缓存策略配置
class MessageCacheService {
  /// 消息缓存
  final LRUCache<String, Message> _messageCache;

  /// 消息块缓存
  final LRUCache<String, MessageBlock> _blockCache;

  /// 对话消息列表缓存
  final LRUCache<String, List<Message>> _conversationCache;

  /// 内容哈希缓存 - 用于快速检测内容变化
  final LRUCache<String, String> _contentHashCache;

  /// 渲染缓存 - 缓存已渲染的Widget
  final LRUCache<String, _CachedRenderResult> _renderCache;

  /// 缓存统计
  final CacheStatistics _statistics = CacheStatistics();

  /// 单例实例
  static MessageCacheService? _instance;

  MessageCacheService._({
    int maxMessageCacheSize = 1000,
    int maxBlockCacheSize = 5000,
    int maxConversationCacheSize = 50,
    int maxContentHashCacheSize = 2000,
    int maxRenderCacheSize = 500,
  })  : _messageCache = LRUCache(maxMessageCacheSize),
        _blockCache = LRUCache(maxBlockCacheSize),
        _conversationCache = LRUCache(maxConversationCacheSize),
        _contentHashCache = LRUCache(maxContentHashCacheSize),
        _renderCache = LRUCache(maxRenderCacheSize);

  /// 获取单例实例
  factory MessageCacheService.instance({
    int maxMessageCacheSize = 1000,
    int maxBlockCacheSize = 5000,
    int maxConversationCacheSize = 50,
  }) {
    _instance ??= MessageCacheService._(
      maxMessageCacheSize: maxMessageCacheSize,
      maxBlockCacheSize: maxBlockCacheSize,
      maxConversationCacheSize: maxConversationCacheSize,
    );
    return _instance!;
  }

  /// 缓存消息
  void cacheMessage(Message message) {
    _messageCache.put(message.id, message);
    _statistics.recordCacheOperation('message_put');

    // 同时缓存消息块
    for (final block in message.blocks) {
      _blockCache.put(block.id, block);
      _statistics.recordCacheOperation('block_put');
    }

    ChatLoggerService.logCacheOperation('put', 'message:${message.id}');
  }

  /// 获取缓存的消息
  Message? getCachedMessage(String messageId) {
    final message = _messageCache.get(messageId);

    if (message != null) {
      _statistics.recordCacheHit('message');
      ChatLoggerService.logCacheOperation('get', 'message:$messageId',
          hit: true);
    } else {
      _statistics.recordCacheMiss('message');
      ChatLoggerService.logCacheOperation('get', 'message:$messageId',
          hit: false);
    }

    return message;
  }

  /// 缓存消息块
  void cacheMessageBlock(MessageBlock block) {
    _blockCache.put(block.id, block);
    _statistics.recordCacheOperation('block_put');
    ChatLoggerService.logCacheOperation('put', 'block:${block.id}');
  }

  /// 获取缓存的消息块
  MessageBlock? getCachedMessageBlock(String blockId) {
    final block = _blockCache.get(blockId);

    if (block != null) {
      _statistics.recordCacheHit('block');
      ChatLoggerService.logCacheOperation('get', 'block:$blockId', hit: true);
    } else {
      _statistics.recordCacheMiss('block');
      ChatLoggerService.logCacheOperation('get', 'block:$blockId', hit: false);
    }

    return block;
  }

  /// 缓存对话消息列表
  void cacheConversationMessages(
      String conversationId, List<Message> messages) {
    _conversationCache.put(conversationId, List.from(messages));
    _statistics.recordCacheOperation('conversation_put');
    ChatLoggerService.logCacheOperation('put', 'conversation:$conversationId');
  }

  /// 获取缓存的对话消息列表
  List<Message>? getCachedConversationMessages(String conversationId) {
    final messages = _conversationCache.get(conversationId);

    if (messages != null) {
      _statistics.recordCacheHit('conversation');
      ChatLoggerService.logCacheOperation('get', 'conversation:$conversationId',
          hit: true);
      return List.from(messages); // 返回副本避免修改缓存
    } else {
      _statistics.recordCacheMiss('conversation');
      ChatLoggerService.logCacheOperation('get', 'conversation:$conversationId',
          hit: false);
      return null;
    }
  }

  /// 更新缓存中的消息
  void updateCachedMessage(Message message) {
    if (_messageCache.containsKey(message.id)) {
      _messageCache.put(message.id, message);
      _statistics.recordCacheOperation('message_update');

      // 更新消息块缓存
      for (final block in message.blocks) {
        _blockCache.put(block.id, block);
        _statistics.recordCacheOperation('block_update');
      }

      // 清除相关的对话缓存
      _invalidateConversationCache(message.conversationId);

      ChatLoggerService.logCacheOperation('update', 'message:${message.id}');
    }
  }

  /// 删除缓存中的消息
  void removeCachedMessage(String messageId) {
    final message = _messageCache.remove(messageId);
    if (message != null) {
      _statistics.recordCacheOperation('message_remove');

      // 删除相关的消息块缓存
      for (final block in message.blocks) {
        _blockCache.remove(block.id);
        _statistics.recordCacheOperation('block_remove');
      }

      // 清除相关的对话缓存
      _invalidateConversationCache(message.conversationId);

      ChatLoggerService.logCacheOperation('remove', 'message:$messageId');
    }
  }

  /// 清除对话缓存
  void _invalidateConversationCache(String conversationId) {
    _conversationCache.remove(conversationId);
    _statistics.recordCacheOperation('conversation_invalidate');
    ChatLoggerService.logCacheOperation(
        'invalidate', 'conversation:$conversationId');
  }

  /// 清除所有缓存
  void clearAll() {
    final messageCount = _messageCache.length;
    final blockCount = _blockCache.length;
    final conversationCount = _conversationCache.length;

    _messageCache.clear();
    _blockCache.clear();
    _conversationCache.clear();
    _statistics.reset();

    ChatLoggerService.logDebug(
      'Cache cleared: $messageCount messages, $blockCount blocks, $conversationCount conversations',
    );
  }

  /// 清理过期缓存
  void cleanup() {
    final beforeSize =
        _messageCache.length + _blockCache.length + _conversationCache.length;

    // LRU缓存会自动清理，这里可以添加额外的清理逻辑
    // 例如：清理超过一定时间的缓存项

    final afterSize =
        _messageCache.length + _blockCache.length + _conversationCache.length;

    if (beforeSize != afterSize) {
      ChatLoggerService.logDebug(
        'Cache cleanup: ${beforeSize - afterSize} items removed',
      );
    }
  }

  /// 获取缓存统计信息
  CacheStatistics getStatistics() {
    return _statistics.copy();
  }

  /// 生成内容哈希
  String generateContentHash(Message message) {
    final hashComponents = [
      message.id,
      message.content,
      message.role,
      message.status.name,
      message.blocks.length.toString(),
      message.updatedAt?.millisecondsSinceEpoch.toString() ?? '',
      // 包含所有块的内容
      ...message.blocks
          .map((block) => '${block.type.name}:${block.content ?? ''}'),
    ];
    return hashComponents.join('|').hashCode.toString();
  }

  /// 检查内容是否已更改
  bool hasContentChanged(String key, String currentHash) {
    final cachedHash = _contentHashCache.get(key);
    return cachedHash != currentHash;
  }

  /// 更新内容哈希
  void updateContentHash(String key, String hash) {
    _contentHashCache.put(key, hash);
    _statistics.recordCacheOperation('hash_update');
  }

  /// 缓存渲染结果
  void cacheRenderResult(String key, Widget widget, String contentHash) {
    final result = _CachedRenderResult(
      widget: widget,
      contentHash: contentHash,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    _renderCache.put(key, result);
    _statistics.recordCacheOperation('render_put');
    ChatLoggerService.logCacheOperation('put', 'render:$key');
  }

  /// 获取缓存的渲染结果
  Widget? getCachedRenderResult(String key, String currentContentHash) {
    final cached = _renderCache.get(key);

    if (cached != null) {
      // 检查内容哈希是否匹配且未过期
      if (cached.contentHash == currentContentHash && !cached.isExpired) {
        // 更新访问时间
        _renderCache.put(key, cached.withUpdatedAccess());
        _statistics.recordCacheHit('render');
        ChatLoggerService.logCacheOperation('get', 'render:$key', hit: true);
        return cached.widget;
      } else {
        // 内容已变化或已过期，移除缓存
        _renderCache.remove(key);
        _statistics.recordCacheOperation('render_invalidate');
      }
    }

    _statistics.recordCacheMiss('render');
    ChatLoggerService.logCacheOperation('get', 'render:$key', hit: false);
    return null;
  }

  /// 清理过期的渲染缓存
  void cleanupExpiredRenderCache() {
    final keysToRemove = <String>[];

    // 这里需要遍历缓存，但LRUCache没有提供遍历方法
    // 在实际实现中，可能需要扩展LRUCache类来支持这个功能

    for (final key in keysToRemove) {
      _renderCache.remove(key);
      _statistics.recordCacheOperation('render_cleanup');
    }

    if (keysToRemove.isNotEmpty) {
      ChatLoggerService.logDebug(
          'Cleaned up ${keysToRemove.length} expired render cache items');
    }
  }

  /// 获取缓存状态
  Map<String, dynamic> getCacheStatus() {
    return {
      'messageCache': {
        'size': _messageCache.length,
        'maxSize': _messageCache.maxSize,
        'hitRate': _statistics.getHitRate('message'),
      },
      'blockCache': {
        'size': _blockCache.length,
        'maxSize': _blockCache.maxSize,
        'hitRate': _statistics.getHitRate('block'),
      },
      'conversationCache': {
        'size': _conversationCache.length,
        'maxSize': _conversationCache.maxSize,
        'hitRate': _statistics.getHitRate('conversation'),
      },
      'contentHashCache': {
        'size': _contentHashCache.length,
        'maxSize': _contentHashCache.maxSize,
        'hitRate': _statistics.getHitRate('hash'),
      },
      'renderCache': {
        'size': _renderCache.length,
        'maxSize': _renderCache.maxSize,
        'hitRate': _statistics.getHitRate('render'),
      },
      'totalOperations': _statistics.totalOperations,
      'overallHitRate': _statistics.overallHitRate,
    };
  }
}

/// LRU缓存实现
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  LRUCache(this.maxSize);

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // 移到最后（最近使用）
    }
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first); // 移除最久未使用的
    }
    _cache[key] = value;
  }

  V? remove(K key) {
    return _cache.remove(key);
  }

  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  void clear() {
    _cache.clear();
  }

  int get length => _cache.length;
}

/// 缓存统计信息
class CacheStatistics {
  final Map<String, int> _hits = {};
  final Map<String, int> _misses = {};
  final Map<String, int> _operations = {};

  void recordCacheHit(String cacheType) {
    _hits[cacheType] = (_hits[cacheType] ?? 0) + 1;
  }

  void recordCacheMiss(String cacheType) {
    _misses[cacheType] = (_misses[cacheType] ?? 0) + 1;
  }

  void recordCacheOperation(String operationType) {
    _operations[operationType] = (_operations[operationType] ?? 0) + 1;
  }

  double getHitRate(String cacheType) {
    final hits = _hits[cacheType] ?? 0;
    final misses = _misses[cacheType] ?? 0;
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  double get overallHitRate {
    final totalHits = _hits.values.fold(0, (a, b) => a + b);
    final totalMisses = _misses.values.fold(0, (a, b) => a + b);
    final total = totalHits + totalMisses;
    return total > 0 ? totalHits / total : 0.0;
  }

  int get totalOperations {
    return _operations.values.fold(0, (a, b) => a + b);
  }

  void reset() {
    _hits.clear();
    _misses.clear();
    _operations.clear();
  }

  CacheStatistics copy() {
    final copy = CacheStatistics();
    copy._hits.addAll(_hits);
    copy._misses.addAll(_misses);
    copy._operations.addAll(_operations);
    return copy;
  }

  Map<String, dynamic> toJson() {
    return {
      'hits': Map.from(_hits),
      'misses': Map.from(_misses),
      'operations': Map.from(_operations),
      'overallHitRate': overallHitRate,
      'totalOperations': totalOperations,
    };
  }
}
