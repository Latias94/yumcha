// 📤 分享屏幕
//
// 提供应用分享功能，包括分享应用、分享聊天记录、生成邀请链接等。
// 支持多种分享方式和社交平台集成。
//
// 🎯 **主要功能**:
// - 📱 **应用分享**: 分享应用下载链接和介绍
// - 💬 **聊天分享**: 分享特定的聊天记录
// - 🔗 **邀请链接**: 生成邀请好友的链接
// - 📊 **分享统计**: 显示分享数据和效果
// - 🎨 **分享卡片**: 生成精美的分享卡片
// - 📋 **快速复制**: 快速复制分享内容
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 卡片式布局展示不同分享选项
// - 支持预览分享内容
// - 提供多种分享渠道选择

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final String _appDownloadUrl = 'https://yumcha.app/download';
  final String _appDescription = 'YumCha - 现代化的 AI 聊天客户端，支持多模型、MCP 集成，开源免费！';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("分享"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: DesignConstants.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 应用分享卡片
                  _buildAppShareCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 二维码分享卡片
                  _buildQRCodeCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 社交分享卡片
                  _buildSocialShareCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 聊天分享卡片
                  _buildChatShareCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 分享统计卡片
                  _buildShareStatsCard(),
                  SizedBox(height: DesignConstants.spaceXXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppShareCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '分享应用',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            // 应用预览
            Container(
              padding: DesignConstants.paddingL,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(width: DesignConstants.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YumCha',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'AI 聊天客户端',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignConstants.spaceM),
                  Text(
                    _appDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: DesignConstants.spaceM),
                  Text(
                    _appDownloadUrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: DesignConstants.spaceL),
            
            // 分享按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareApp,
                    icon: const Icon(Icons.share),
                    label: const Text('分享应用'),
                  ),
                ),
                SizedBox(width: DesignConstants.spaceM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyAppLink,
                    icon: const Icon(Icons.copy),
                    label: const Text('复制链接'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '二维码分享',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            Center(
              child: Container(
                padding: DesignConstants.paddingL,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _appDownloadUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: DesignConstants.spaceL),
            
            Text(
              '扫描二维码下载 YumCha',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialShareCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.public,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '社交分享',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            // 社交平台按钮
            Wrap(
              spacing: DesignConstants.spaceM,
              runSpacing: DesignConstants.spaceM,
              children: [
                _buildSocialButton(
                  icon: Icons.message,
                  label: '微信',
                  color: Colors.green,
                  onTap: () => _shareToWeChat(),
                ),
                _buildSocialButton(
                  icon: Icons.alternate_email,
                  label: '微博',
                  color: Colors.red,
                  onTap: () => _shareToWeibo(),
                ),
                _buildSocialButton(
                  icon: Icons.chat,
                  label: 'QQ',
                  color: Colors.blue,
                  onTap: () => _shareToQQ(),
                ),
                _buildSocialButton(
                  icon: Icons.email,
                  label: '邮件',
                  color: Colors.orange,
                  onTap: () => _shareByEmail(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatShareCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '聊天分享',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            Text(
              '分享有趣的 AI 对话内容',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _shareChatHistory,
                icon: const Icon(Icons.history),
                label: const Text('选择聊天记录分享'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStatsCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '分享统计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('总分享次数', '42'),
                ),
                Expanded(
                  child: _buildStatItem('本月分享', '8'),
                ),
                Expanded(
                  child: _buildStatItem('成功邀请', '3'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: DesignConstants.spaceS),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignConstants.spaceXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        '$_appDescription\n\n下载链接: $_appDownloadUrl',
        subject: 'YumCha - AI 聊天客户端',
      );
    } catch (e) {
      NotificationService().showError('分享失败: $e');
    }
  }

  Future<void> _copyAppLink() async {
    await Clipboard.setData(ClipboardData(text: _appDownloadUrl));
    NotificationService().showSuccess('链接已复制到剪贴板');
  }

  Future<void> _shareToWeChat() async {
    NotificationService().showInfo('微信分享功能开发中...');
  }

  Future<void> _shareToWeibo() async {
    NotificationService().showInfo('微博分享功能开发中...');
  }

  Future<void> _shareToQQ() async {
    NotificationService().showInfo('QQ分享功能开发中...');
  }

  Future<void> _shareByEmail() async {
    try {
      await Share.share(
        '$_appDescription\n\n下载链接: $_appDownloadUrl',
        subject: 'YumCha - AI 聊天客户端推荐',
      );
    } catch (e) {
      NotificationService().showError('邮件分享失败: $e');
    }
  }

  Future<void> _shareChatHistory() async {
    NotificationService().showInfo('聊天记录分享功能开发中...');
  }
}
