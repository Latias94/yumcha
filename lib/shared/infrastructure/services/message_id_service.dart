import 'dart:math';

/// 统一的消息ID管理服务
///
/// 🎯 **核心职责**：
/// - 为整个应用生成唯一的消息ID，避免重复和冲突
/// - 提供ID验证和解析功能
/// - 管理ID的生命周期和关联关系
/// - 遵循业界最佳实践，确保ID的唯一性和可追溯性
///
/// 🔧 **设计原则**：
/// - 单一职责：只负责ID管理，不涉及业务逻辑
/// - 统一格式：所有ID遵循相同的命名规范
/// - 可追溯性：ID包含时间戳和类型信息
/// - 防冲突：使用计数器和随机数确保唯一性
class MessageIdService {
  static final MessageIdService _instance = MessageIdService._internal();
  factory MessageIdService() => _instance;
  MessageIdService._internal();

  /// 消息计数器，用于确保同一毫秒内的ID唯一性
  int _messageCounter = 0;

  /// 随机数生成器，用于增加ID的随机性
  final Random _random = Random();

  /// ID关联关系缓存 - 用于追踪相关联的ID
  final Map<String, Set<String>> _idRelations = {};

  // ========== ID生成方法 ==========

  /// 生成用户消息ID
  ///
  /// 格式: user_[timestamp]_[counter]_[random]
  /// 例如: user_1703123456789_001_a1b2
  String generateUserMessageId() {
    return _generateId('user');
  }

  /// 生成AI消息ID
  ///
  /// 格式: ai_[timestamp]_[counter]_[random]
  /// 例如: ai_1703123456789_002_c3d4
  String generateAiMessageId() {
    return _generateId('ai');
  }

  /// 生成系统消息ID
  ///
  /// 格式: sys_[timestamp]_[counter]_[random]
  /// 例如: sys_1703123456789_003_e5f6
  String generateSystemMessageId() {
    return _generateId('sys');
  }

  /// 生成消息块ID
  ///
  /// 格式: block_[messageId]_[blockType]_[index]
  /// 例如: block_ai_1703123456789_002_c3d4_text_0
  String generateMessageBlockId({
    required String messageId,
    required String blockType,
    required int index,
  }) {
    return 'block_${messageId}_${blockType}_$index';
  }

  /// 生成请求ID（用于追踪API请求）
  ///
  /// 格式: req_[timestamp]_[microsecond]
  /// 例如: req_1703123456789_123456
  String generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final microsecond = DateTime.now().microsecond;
    return 'req_${timestamp}_$microsecond';
  }

  // ========== ID验证和解析 ==========

  /// 验证ID格式是否正确
  bool isValidMessageId(String id) {
    // 基本格式验证：prefix_timestamp_counter_random
    final parts = id.split('_');
    if (parts.length < 4) return false;

    // 验证前缀
    final validPrefixes = ['user', 'ai', 'sys', 'block', 'req'];
    if (!validPrefixes.contains(parts[0])) return false;

    // 验证时间戳（应该是数字）
    if (int.tryParse(parts[1]) == null) return false;

    return true;
  }

  /// 从ID中提取消息类型
  String? getMessageTypeFromId(String id) {
    if (!isValidMessageId(id)) return null;
    return id.split('_')[0];
  }

  /// 从ID中提取时间戳
  DateTime? getTimestampFromId(String id) {
    if (!isValidMessageId(id)) return null;
    final timestampStr = id.split('_')[1];
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 从消息块ID中提取父消息ID
  String? getParentMessageIdFromBlockId(String blockId) {
    if (!blockId.startsWith('block_')) return null;

    final parts = blockId.split('_');
    if (parts.length < 6) return null;

    // block_ai_1703123456789_002_c3d4_text_0
    // 提取: ai_1703123456789_002_c3d4
    return '${parts[1]}_${parts[2]}_${parts[3]}_${parts[4]}';
  }

  // ========== ID关联管理 ==========

  /// 建立ID之间的关联关系
  void linkIds(String primaryId, String relatedId) {
    _idRelations.putIfAbsent(primaryId, () => <String>{}).add(relatedId);
    _idRelations.putIfAbsent(relatedId, () => <String>{}).add(primaryId);
  }

  /// 获取与指定ID相关联的所有ID
  Set<String> getRelatedIds(String id) {
    return _idRelations[id] ?? <String>{};
  }

  /// 清理ID关联关系
  void clearIdRelations(String id) {
    final relatedIds = _idRelations[id] ?? <String>{};
    for (final relatedId in relatedIds) {
      _idRelations[relatedId]?.remove(id);
      if (_idRelations[relatedId]?.isEmpty == true) {
        _idRelations.remove(relatedId);
      }
    }
    _idRelations.remove(id);
  }

  // ========== 内部方法 ==========

  /// 内部ID生成方法
  String _generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final counter = _getNextCounter();
    final randomSuffix = _generateRandomSuffix();

    return '${prefix}_${timestamp}_${counter.toString().padLeft(3, '0')}_$randomSuffix';
  }

  /// 获取下一个计数器值
  int _getNextCounter() {
    _messageCounter = (_messageCounter + 1) % 1000; // 循环使用0-999
    return _messageCounter;
  }

  /// 生成随机后缀
  String _generateRandomSuffix() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
          4, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  // ========== 静态工具方法 ==========

  /// 验证消息ID格式是否正确（静态方法）
  static bool isValidId(String id) {
    // 匹配格式: prefix_timestamp_counter_random
    final standardRegex =
        RegExp(r'^(user|ai|sys|block|req)_\d{13}_\d{3}_[a-z0-9]{4}$');
    // 匹配消息块格式: block_messageId_blockType_index
    final blockRegex =
        RegExp(r'^block_[a-z]+_\d{13}_\d{3}_[a-z0-9]{4}_[a-z]+_\d+$');
    return standardRegex.hasMatch(id) || blockRegex.hasMatch(id);
  }

  /// 从消息ID中提取前缀（静态方法）
  static String? extractPrefix(String id) {
    if (!isValidId(id)) return null;
    return id.split('_')[0];
  }

  /// 从消息ID中提取时间戳（静态方法）
  static DateTime? extractTimestamp(String id) {
    if (!isValidId(id)) return null;
    try {
      final parts = id.split('_');
      final timestampIndex = parts[0] == 'block' ? 2 : 1; // 消息块ID的时间戳在第3个位置
      final timestamp = int.parse(parts[timestampIndex]);
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// 检查消息ID是否为用户消息
  static bool isUserMessage(String id) {
    return extractPrefix(id) == 'user';
  }

  /// 检查消息ID是否为AI消息
  static bool isAiMessage(String id) {
    return extractPrefix(id) == 'ai';
  }

  /// 检查消息ID是否为系统消息
  static bool isSystemMessage(String id) {
    return extractPrefix(id) == 'sys';
  }

  /// 检查是否为消息块ID
  static bool isBlockId(String id) {
    return extractPrefix(id) == 'block';
  }

  /// 检查是否为请求ID
  static bool isRequestId(String id) {
    return extractPrefix(id) == 'req';
  }

  // ========== 调试和统计 ==========

  /// 获取当前计数器值（用于调试）
  int get currentCounter => _messageCounter;

  /// 获取ID关联关系数量（用于调试）
  int get relationCount => _idRelations.length;

  /// 清理所有ID关联关系
  void clearAllRelations() {
    _idRelations.clear();
  }

  /// 重置计数器
  void resetCounter() {
    _messageCounter = 0;
  }
}
