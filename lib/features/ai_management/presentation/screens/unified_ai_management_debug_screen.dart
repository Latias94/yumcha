import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yumcha/shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';
import '../providers/unified_ai_management_test.dart';

/// 统一AI管理调试界面
///
/// 用于测试和调试新的统一AI管理系统
class UnifiedAiManagementDebugScreen extends ConsumerStatefulWidget {
  const UnifiedAiManagementDebugScreen({super.key});

  @override
  ConsumerState<UnifiedAiManagementDebugScreen> createState() =>
      _UnifiedAiManagementDebugScreenState();
}

class _UnifiedAiManagementDebugScreenState
    extends ConsumerState<UnifiedAiManagementDebugScreen> {
  bool _isRunningTest = false;
  String? _testResult;
  Map<String, dynamic>? _statusReport;

  @override
  void initState() {
    super.initState();
    _refreshStatusReport();
  }

  void _refreshStatusReport() {
    setState(() {
      _statusReport = UnifiedAiManagementTest.getSystemStatusReport(ref);
    });
  }

  Future<void> _runBasicTest() async {
    setState(() {
      _isRunningTest = true;
      _testResult = null;
    });

    try {
      await UnifiedAiManagementTest.testBasicFunctionality(ref);
      setState(() {
        _testResult = '✅ 基础功能测试通过';
      });
    } catch (error) {
      setState(() {
        _testResult = '❌ 基础功能测试失败: $error';
      });
    } finally {
      setState(() {
        _isRunningTest = false;
      });
      _refreshStatusReport();
    }
  }

  Future<void> _runFullTestSuite() async {
    setState(() {
      _isRunningTest = true;
      _testResult = null;
    });

    try {
      await UnifiedAiManagementTest.runFullTestSuite(ref);
      setState(() {
        _testResult = '🎉 完整测试套件通过';
      });
    } catch (error) {
      setState(() {
        _testResult = '💥 完整测试套件失败: $error';
      });
    } finally {
      setState(() {
        _isRunningTest = false;
      });
      _refreshStatusReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(unifiedAiManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('统一AI管理调试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStatusReport,
            tooltip: '刷新状态',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 系统状态卡片
            _buildSystemStatusCard(theme, state),
            SizedBox(height: DesignConstants.spaceL),

            // 测试控制卡片
            _buildTestControlCard(theme),
            SizedBox(height: DesignConstants.spaceL),

            // 测试结果卡片
            if (_testResult != null) ...[
              _buildTestResultCard(theme),
              SizedBox(height: DesignConstants.spaceL),
            ],

            // 详细状态报告卡片
            if (_statusReport != null) _buildStatusReportCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard(ThemeData theme, state) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统状态',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: DesignConstants.spaceM),
            _buildStatusRow('初始化状态', state.isInitialized ? '✅ 已初始化' : '❌ 未初始化'),
            _buildStatusRow('加载状态', state.isLoading ? '🔄 加载中' : '✅ 已加载'),
            _buildStatusRow(
                '错误状态', state.hasError ? '❌ ${state.error}' : '✅ 正常'),
            _buildStatusRow('提供商数量', '${state.providers.length}'),
            _buildStatusRow('助手数量', '${state.assistants.length}'),
            _buildStatusRow(
                '配置完整性', state.hasCompleteConfiguration ? '✅ 完整' : '❌ 不完整'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestControlCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '测试控制',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: DesignConstants.spaceM),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunningTest ? null : _runBasicTest,
                    child: _isRunningTest
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('运行基础测试'),
                  ),
                ),
                SizedBox(width: DesignConstants.spaceM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunningTest ? null : _runFullTestSuite,
                    child: _isRunningTest
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('运行完整测试'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultCard(ThemeData theme) {
    final isSuccess = _testResult!.contains('✅') || _testResult!.contains('🎉');

    return Card(
      color: isSuccess
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '测试结果',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: DesignConstants.spaceM),
            Text(
              _testResult!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSuccess
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusReportCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细状态报告',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: DesignConstants.spaceM),
            _buildReportSection('提供商统计', _statusReport!['providerStats']),
            _buildReportSection('助手统计', _statusReport!['assistantStats']),
            _buildReportSection('配置状态', _statusReport!['configuration']),
            _buildReportSection('能力统计', _statusReport!['capabilities']),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: DesignConstants.spaceS),
        ...data.entries.map((entry) => Padding(
              padding: EdgeInsets.only(left: DesignConstants.spaceM),
              child: _buildStatusRow(entry.key, entry.value.toString()),
            )),
        SizedBox(height: DesignConstants.spaceM),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignConstants.spaceXS),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
