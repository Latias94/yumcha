// ℹ️ 关于应用屏幕
//
// 显示应用的基本信息、版本信息、开发者信息、许可证信息等。
// 提供用户了解应用详情和获取支持的入口。
//
// 🎯 **主要功能**:
// - 📱 **应用信息**: 显示应用名称、版本、构建信息
// - 👨‍💻 **开发者信息**: 显示开发者和贡献者信息
// - 📄 **许可证**: 显示开源许可证和第三方库信息
// - 🔗 **链接**: 提供官网、GitHub、反馈等链接
// - 📊 **统计信息**: 显示应用使用统计
// - 🆘 **支持**: 提供帮助和支持信息
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 卡片式布局展示不同类型的信息
// - 支持点击链接跳转到外部页面
// - 提供应用图标和品牌展示

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
      });
    } catch (e) {
      // 处理错误
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        NotificationService().showError('无法打开链接: $url');
      }
    } catch (e) {
      NotificationService().showError('打开链接失败: $e');
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    NotificationService().showSuccess('已复制到剪贴板');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("关于"),
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
                  // 应用信息卡片
                  _buildAppInfoCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 版本信息卡片
                  _buildVersionInfoCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 开发者信息卡片
                  _buildDeveloperInfoCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 链接卡片
                  _buildLinksCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 许可证信息卡片
                  _buildLicenseCard(),
                  SizedBox(height: DesignConstants.spaceXL),

                  // 致谢卡片
                  _buildAcknowledgmentsCard(),
                  SizedBox(height: DesignConstants.spaceXXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingXL,
        child: Column(
          children: [
            // 应用图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            // 应用名称
            Text(
              'YumCha',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: DesignConstants.spaceS),
            
            // 应用描述
            Text(
              '一个现代化的 AI 聊天客户端',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignConstants.spaceM),
            
            // 特性标签
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip('多平台支持'),
                _buildFeatureChip('MCP 集成'),
                _buildFeatureChip('多模型支持'),
                _buildFeatureChip('开源免费'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildVersionInfoCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '版本信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            if (_packageInfo != null) ...[
              _buildInfoRow('版本号', _packageInfo!.version),
              _buildInfoRow('构建号', _packageInfo!.buildNumber),
              _buildInfoRow('包名', _packageInfo!.packageName),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfoCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '开发者信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            _buildInfoRow('开发者', 'YumCha Team'),
            _buildInfoRow('技术栈', 'Flutter + Dart'),
            _buildInfoRow('架构', 'Clean Architecture + Riverpod'),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '相关链接',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            _buildLinkItem(
              Icons.home,
              '官方网站',
              'https://yumcha.app',
              () => _launchUrl('https://yumcha.app'),
            ),
            _buildLinkItem(
              Icons.code,
              'GitHub 仓库',
              'https://github.com/yumcha/yumcha',
              () => _launchUrl('https://github.com/yumcha/yumcha'),
            ),
            _buildLinkItem(
              Icons.bug_report,
              '问题反馈',
              'https://github.com/yumcha/yumcha/issues',
              () => _launchUrl('https://github.com/yumcha/yumcha/issues'),
            ),
            _buildLinkItem(
              Icons.email,
              '联系我们',
              'contact@yumcha.app',
              () => _launchUrl('mailto:contact@yumcha.app'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gavel,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '许可证信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            _buildInfoRow('应用许可证', 'AGPL v3'),
            _buildInfoRow('核心库许可证', 'MIT (llm_dart)'),
            
            SizedBox(height: DesignConstants.spaceM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'YumCha',
                    applicationVersion: _packageInfo?.version ?? '未知',
                    applicationIcon: Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('查看第三方许可证'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcknowledgmentsCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '致谢',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            Text(
              '感谢所有为 YumCha 项目做出贡献的开发者和用户。'
              '特别感谢 Flutter 团队、Riverpod 团队以及所有开源项目的维护者。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignConstants.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    IconData icon,
    String title,
    String url,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        url,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
