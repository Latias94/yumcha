import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String userId;
  final String name;
  final String displayName;
  final String status;
  final String position;
  final String description;
  final String? avatarUrl;
  final String? twitter;
  final String? timeZone;
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
