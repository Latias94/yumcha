import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import 'unified_ai_management_providers.dart';
import '../../domain/entities/unified_ai_management_state.dart';

/// 统一AI管理测试工具类
/// 
/// 用于测试和验证新的统一AI管理系统是否正常工作
class UnifiedAiManagementTest {
  static final LoggerService _logger = LoggerService();

  /// 测试统一AI管理系统的基本功能
  static Future<void> testBasicFunctionality(WidgetRef ref) async {
    _logger.info('开始测试统一AI管理系统');

    try {
      // 1. 测试状态初始化
      await _testStateInitialization(ref);

      // 2. 测试Provider访问
      await _testProviderAccess(ref);

      // 3. 测试配置管理
      await _testConfigurationManagement(ref);

      // 4. 测试事件系统
      await _testEventSystem(ref);

      _logger.info('✅ 统一AI管理系统测试通过');
    } catch (error) {
      _logger.error('❌ 统一AI管理系统测试失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 测试状态初始化
  static Future<void> _testStateInitialization(WidgetRef ref) async {
    _logger.info('测试状态初始化...');

    final state = ref.read(unifiedAiManagementProvider);
    
    // 检查初始状态
    if (state.isLoading) {
      _logger.info('状态正在加载中...');
      
      // 等待初始化完成
      await _waitForInitialization(ref);
    }

    final finalState = ref.read(unifiedAiManagementProvider);
    
    if (!finalState.isInitialized) {
      throw Exception('状态初始化失败');
    }

    _logger.info('✅ 状态初始化测试通过');
  }

  /// 测试Provider访问
  static Future<void> _testProviderAccess(WidgetRef ref) async {
    _logger.info('测试Provider访问...');

    // 测试基础Provider
    final providers = ref.read(aiProvidersProvider);
    final assistants = ref.read(aiAssistantsProvider);

    _logger.info('Provider数据', {
      'providersCount': providers.length,
      'assistantsCount': assistants.length,
    });

    // 测试启用的Provider
    final enabledProviders = ref.read(enabledAiProvidersProvider);
    final enabledAssistants = ref.read(enabledAiAssistantsProvider);

    _logger.info('启用的Provider数据', {
      'enabledProvidersCount': enabledProviders.length,
      'enabledAssistantsCount': enabledAssistants.length,
    });

    // 测试统计信息
    final providerStats = ref.read(providerStatsProvider);
    final assistantStats = ref.read(assistantStatsProvider);

    _logger.info('统计信息', {
      'providerStats': providerStats,
      'assistantStats': assistantStats,
    });

    _logger.info('✅ Provider访问测试通过');
  }

  /// 测试配置管理
  static Future<void> _testConfigurationManagement(WidgetRef ref) async {
    _logger.info('测试配置管理...');

    // 测试当前选择
    final currentSelection = ref.read(currentAiSelectionProvider);
    
    _logger.info('当前选择', {
      'assistant': currentSelection.assistant?.name,
      'provider': currentSelection.provider?.name,
      'model': currentSelection.model?.name,
    });

    // 测试配置检查
    final hasCompleteConfig = ref.read(hasCompleteConfigurationProvider);
    final needsBackup = ref.read(needsConfigBackupProvider);

    _logger.info('配置状态', {
      'hasCompleteConfig': hasCompleteConfig,
      'needsBackup': needsBackup,
    });

    // 测试模板
    final templates = ref.read(availableTemplatesProvider);
    final templatesList = ref.read(configTemplatesListProvider);

    _logger.info('配置模板', {
      'templatesCount': templates.length,
      'templatesListCount': templatesList.length,
    });

    _logger.info('✅ 配置管理测试通过');
  }

  /// 测试事件系统
  static Future<void> _testEventSystem(WidgetRef ref) async {
    _logger.info('测试事件系统...');

    // 测试最后事件
    final lastEvent = ref.read(aiManagementEventProvider);

    _logger.info('事件状态', {
      'lastEvent': lastEvent?.runtimeType.toString() ?? 'null',
    });

    _logger.info('✅ 事件系统测试通过');
  }

  /// 等待初始化完成
  static Future<void> _waitForInitialization(WidgetRef ref) async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      final state = ref.read(unifiedAiManagementProvider);
      
      if (state.isInitialized) {
        return;
      }

      if (state.hasError) {
        throw Exception('初始化失败: ${state.error}');
      }

      await Future.delayed(checkInterval);
    }

    throw Exception('初始化超时');
  }

  /// 测试自定义提供商添加
  static Future<void> testAddCustomProvider(WidgetRef ref) async {
    _logger.info('测试添加自定义提供商...');

    try {
      final actions = ref.read(aiManagementActionsProvider);
      
      await actions.addCustomProvider(
        name: 'Test Provider',
        apiKey: 'test-api-key',
        baseUrl: 'https://api.test.com',
        template: ConfigTemplate.openai, // 使用 OpenAI 兼容模板
      );

      _logger.info('✅ 自定义提供商添加测试通过');
    } catch (error) {
      _logger.error('❌ 自定义提供商添加测试失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 测试自定义助手创建
  static Future<void> testCreateCustomAssistant(WidgetRef ref) async {
    _logger.info('测试创建自定义助手...');

    try {
      final actions = ref.read(aiManagementActionsProvider);
      
      await actions.createCustomAssistant(
        name: 'Test Assistant',
        systemPrompt: 'You are a helpful test assistant.',
        description: 'A test assistant for validation',
        streamOutput: true,
        supportsVision: false,
        supportsTools: false,
      );

      _logger.info('✅ 自定义助手创建测试通过');
    } catch (error) {
      _logger.error('❌ 自定义助手创建测试失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 运行完整测试套件
  static Future<void> runFullTestSuite(WidgetRef ref) async {
    _logger.info('🚀 开始运行完整的统一AI管理测试套件');

    try {
      // 基础功能测试
      await testBasicFunctionality(ref);

      // 自定义功能测试（可选，因为可能会修改数据）
      // await testAddCustomProvider(ref);
      // await testCreateCustomAssistant(ref);

      _logger.info('🎉 统一AI管理测试套件全部通过！');
    } catch (error) {
      _logger.error('💥 统一AI管理测试套件失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 获取系统状态报告
  static Map<String, dynamic> getSystemStatusReport(WidgetRef ref) {
    final state = ref.read(unifiedAiManagementProvider);
    final providerStats = ref.read(providerStatsProvider);
    final assistantStats = ref.read(assistantStatsProvider);
    final hasCompleteConfig = ref.read(hasCompleteConfigurationProvider);

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'isInitialized': state.isInitialized,
      'isLoading': state.isLoading,
      'hasError': state.hasError,
      'error': state.error,
      'providerStats': {
        'total': providerStats.total,
        'enabled': providerStats.enabled,
        'connected': providerStats.connected,
      },
      'assistantStats': {
        'total': assistantStats.total,
        'enabled': assistantStats.enabled,
        'custom': assistantStats.custom,
      },
      'configuration': {
        'hasCompleteConfig': hasCompleteConfig,
        'needsBackup': ref.read(needsConfigBackupProvider),
      },
      'capabilities': {
        'visionProviders': ref.read(visionProvidersProvider).length,
        'toolProviders': ref.read(toolProvidersProvider).length,
        'ttsProviders': ref.read(ttsProvidersProvider).length,
        'reasoningProviders': ref.read(reasoningProvidersProvider).length,
      },
    };
  }
}
