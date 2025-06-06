import 'package:flutter/foundation.dart';

/// 用户档案数据模型
///
/// 表示用户的个人信息和档案数据，包含基本信息、状态、社交信息等。
/// 这个模型主要用于用户身份识别和个人信息展示。
///
/// 核心特性：
/// - 👤 **身份信息**: 用户 ID、姓名、显示名称等基本身份信息
/// - 📊 **状态信息**: 用户状态、职位、描述等动态信息
/// - 🖼️ **头像支持**: 支持用户头像 URL
/// - 🌐 **社交信息**: 支持 Twitter 等社交媒体链接
/// - 🌍 **时区支持**: 支持用户时区设置
/// - 🔄 **不可变性**: 使用 @immutable 确保数据不可变
///
/// 使用场景：
/// - 用户信息展示
/// - 个人档案管理
/// - 社交功能支持
/// - 多用户系统的身份识别
@immutable
class UserProfile {
  /// 用户唯一标识符
  final String userId;

  /// 用户真实姓名
  final String name;

  /// 用户显示名称（昵称）
  final String displayName;

  /// 用户状态（在线、离线、忙碌等）
  final String status;

  /// 用户职位或角色
  final String position;

  /// 用户描述或个人简介
  final String description;

  /// 用户头像 URL
  final String? avatarUrl;

  /// Twitter 用户名或链接
  final String? twitter;

  /// 用户时区
  final String? timeZone;

  /// 共同频道或群组信息
  final String? commonChannels;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.displayName,
    required this.status,
    required this.position,
    required this.description,
    this.avatarUrl,
    this.twitter,
    this.timeZone,
    this.commonChannels,
  });

  UserProfile copyWith({
    String? userId,
    String? name,
    String? displayName,
    String? status,
    String? position,
    String? description,
    String? avatarUrl,
    String? twitter,
    String? timeZone,
    String? commonChannels,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      position: position ?? this.position,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      twitter: twitter ?? this.twitter,
      timeZone: timeZone ?? this.timeZone,
      commonChannels: commonChannels ?? this.commonChannels,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.userId == userId &&
        other.name == name &&
        other.displayName == displayName &&
        other.status == status &&
        other.position == position &&
        other.description == description &&
        other.avatarUrl == avatarUrl &&
        other.twitter == twitter &&
        other.timeZone == timeZone &&
        other.commonChannels == commonChannels;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      name,
      displayName,
      status,
      position,
      description,
      avatarUrl,
      twitter,
      timeZone,
      commonChannels,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, name: $name, displayName: $displayName, status: $status)';
  }
}
