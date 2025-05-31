import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final bool showAppBar;

  const ProfileScreen({
    super.key,
    required this.userId,
    this.showAppBar = true,
  });

  UserProfile _getUserProfile(String userId) {
    switch (userId) {
      case "current_user":
        return currentUser;
      case "ai_assistant":
        return aiAssistant;
      case "character_xiaomeng":
        return characterXiaoMeng;
      default:
        return currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _getUserProfile(userId);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text("个人资料"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Implement menu
                  },
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 64,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: profile.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profile.avatarUrl!,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getIconForUser(userId),
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getIconForUser(userId),
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              profile.status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.position,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("关于", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      profile.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (profile.twitter != null || profile.timeZone != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "详细信息",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (profile.twitter != null)
                        _buildInfoRow(
                          context,
                          Icons.alternate_email,
                          "Twitter",
                          profile.twitter!,
                        ),
                      if (profile.timeZone != null)
                        _buildInfoRow(
                          context,
                          Icons.access_time,
                          "时区",
                          profile.timeZone!,
                        ),
                      if (profile.commonChannels != null)
                        _buildInfoRow(
                          context,
                          Icons.forum,
                          "共同频道",
                          "${profile.commonChannels}个",
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text("发送消息"),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.call),
                    title: const Text("语音通话"),
                    onTap: () {
                      // TODO: Implement voice call
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.videocam),
                    title: const Text("视频通话"),
                    onTap: () {
                      // TODO: Implement video call
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForUser(String userId) {
    switch (userId) {
      case "current_user":
        return Icons.person;
      case "ai_assistant":
        return Icons.smart_toy;
      case "character_xiaomeng":
        return Icons.face;
      default:
        return Icons.account_circle;
    }
  }
}
