import 'dart:math';

/// 统一的消息ID生成服务
/// 
/// 负责为整个应用生成唯一的消息ID，避免重复和冲突
/// 遵循业界最佳实践，确保ID的唯一性和可追溯性
class MessageIdService {
  static final MessageIdService _instance = MessageIdService._internal();
  factory MessageIdService() => _instance;
  MessageIdService._internal();

  /// 消息计数器，用于确保同一毫秒内的ID唯一性
  int _messageCounter = 0;
  
  /// 随机数生成器，用于增加ID的随机性
  final Random _random = Random();

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
      Iterable.generate(4, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  /// 验证消息ID格式是否正确
  static bool isValidMessageId(String id) {
    // 匹配格式: prefix_timestamp_counter_random 或 ai_participantId_timestamp_counter_random
    final standardRegex = RegExp(r'^(user|ai|sys)_\d{13}_\d{3}_[a-z0-9]{4}$');
    final multiAiRegex = RegExp(r'^ai_[a-zA-Z0-9_-]+_\d{13}_\d{3}_[a-z0-9]{4}$');
    return standardRegex.hasMatch(id) || multiAiRegex.hasMatch(id);
  }

  /// 验证是否为多AI消息ID
  static bool isMultiAiMessageId(String id) {
    final multiAiRegex = RegExp(r'^ai_[a-zA-Z0-9_-]+_\d{13}_\d{3}_[a-z0-9]{4}$');
    return multiAiRegex.hasMatch(id);
  }

  /// 从多AI消息ID中提取参与者ID
  static String? extractParticipantId(String id) {
    if (!isMultiAiMessageId(id)) return null;
    final parts = id.split('_');
    if (parts.length >= 5) {
      return parts[1]; // ai_participantId_timestamp_counter_random
    }
    return null;
  }

  /// 从消息ID中提取前缀
  static String? extractPrefix(String id) {
    if (!isValidMessageId(id)) return null;
    return id.split('_')[0];
  }

  /// 从消息ID中提取时间戳
  static DateTime? extractTimestamp(String id) {
    if (!isValidMessageId(id)) return null;
    try {
      final timestamp = int.parse(id.split('_')[1]);
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
}
