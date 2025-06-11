import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../data/database/database.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart'
    as ai_provider;
import '../../../features/ai_management/domain/entities/ai_model.dart';
import '../../presentation/providers/dependency_providers.dart';
import 'logger_service.dart';

/// 数据初始化服务
///
/// 负责在应用首次启动时创建默认的助手和提供商数据。
/// 遵循Riverpod最佳实践，通过Provider依赖注入管理。
///
/// 核心特性：
/// - 🚀 **首次启动检测**: 检查数据库是否为空，只在首次启动时初始化
/// - 🤖 **默认助手创建**: 创建通用助手供用户立即使用
/// - 🔌 **默认提供商创建**: 创建常用AI提供商配置模板
/// - 📊 **状态跟踪**: 通过AsyncValue跟踪初始化状态
/// - 🛡️ **错误处理**: 完整的错误处理和日志记录
///
/// 使用场景：
/// - 应用首次启动时自动调用
/// - 数据库重置后重新初始化
/// - 开发环境数据准备
class DataInitializationService {
  DataInitializationService(this._ref);

  final Ref _ref;

  // 创建一个本地logger实例，避免依赖全局初始化
  dynamic get _logger {
    try {
      return LoggerService();
    } catch (e) {
      // 如果LoggerService未初始化，创建一个简单的fallback
      return _FallbackLogger();
    }
  }

  /// 检查并初始化默认数据
  ///
  /// 这是数据初始化的主入口方法，负责：
  /// 1. 检查数据库是否已有数据
  /// 2. 如果是首次启动，创建默认助手和提供商
  /// 3. 记录初始化结果
  ///
  /// @returns Future<bool> 是否执行了初始化
  Future<bool> initializeDefaultDataIfNeeded() async {
    try {
      _logger.info('🚀 开始检查数据初始化需求');

      // 检查是否需要初始化
      final needsInitialization = await _needsInitialization();
      if (!needsInitialization) {
        _logger.info('✅ 数据库已有数据，跳过初始化');
        return false;
      }

      _logger.info('📦 首次启动检测到，开始初始化默认数据');

      // 创建默认助手
      await _createDefaultAssistants();

      // 创建默认提供商
      await _createDefaultProviders();

      _logger.info('✅ 默认数据初始化完成');
      return true;
    } catch (e, stackTrace) {
      _logger.error('❌ 数据初始化失败', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      rethrow;
    }
  }

  /// 检查是否需要初始化数据
  ///
  /// 通过检查助手和提供商表是否为空来判断是否需要初始化。
  /// 只有当两个表都为空时才认为需要初始化。
  Future<bool> _needsInitialization() async {
    try {
      final database = _ref.read(databaseProvider);

      // 检查助手表
      final assistants = await database.getAllAssistants();
      final providers = await database.getAllProviders();

      final needsInit = assistants.isEmpty && providers.isEmpty;

      _logger.debug('数据初始化检查结果', {
        'assistantCount': assistants.length,
        'providerCount': providers.length,
        'needsInitialization': needsInit,
      });

      return needsInit;
    } catch (e) {
      _logger.error('检查初始化需求失败', {'error': e.toString()});
      // 如果检查失败，为了安全起见，不执行初始化
      return false;
    }
  }

  /// 创建默认助手
  ///
  /// 创建一个通用的默认助手，用户可以立即开始使用。
  /// 助手配置为通用聊天场景，温度适中，支持流式输出。
  Future<void> _createDefaultAssistants() async {
    try {
      _logger.info('🤖 开始创建默认助手');

      final database = _ref.read(databaseProvider);
      final now = DateTime.now();

      // 创建默认助手
      final defaultAssistant = AiAssistant(
        id: 'default-assistant',
        name: '通用助手',
        description: '一个友好的AI助手，可以帮助您解答问题、进行对话和完成各种任务。',
        avatar: '🤖',
        systemPrompt: '你是一个友好、有帮助的AI助手。请用简洁、准确的方式回答用户的问题，并在适当的时候提供有用的建议。',
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 2048,
        contextLength: 10,
        streamOutput: true,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
        customHeaders: const {},
        customBody: const {},
        stopSequences: const [],
        enableCodeExecution: false,
        enableImageGeneration: false,
        enableTools: false,
        enableReasoning: false,
        enableVision: false,
        enableEmbedding: false,
        mcpServerIds: const [],
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final companion = AssistantsCompanion.insert(
        id: defaultAssistant.id,
        name: defaultAssistant.name,
        description: defaultAssistant.description,
        avatar: Value(defaultAssistant.avatar),
        systemPrompt: defaultAssistant.systemPrompt,
        temperature: Value(defaultAssistant.temperature),
        topP: Value(defaultAssistant.topP),
        maxTokens: Value(defaultAssistant.maxTokens),
        contextLength: Value(defaultAssistant.contextLength),
        streamOutput: Value(defaultAssistant.streamOutput),
        frequencyPenalty: Value(defaultAssistant.frequencyPenalty),
        presencePenalty: Value(defaultAssistant.presencePenalty),
        customHeaders: Value(defaultAssistant.customHeaders),
        customBody: Value(defaultAssistant.customBody),
        stopSequences: Value(defaultAssistant.stopSequences),
        enableCodeExecution: Value(defaultAssistant.enableCodeExecution),
        enableImageGeneration: Value(defaultAssistant.enableImageGeneration),
        enableTools: Value(defaultAssistant.enableTools),
        enableReasoning: Value(defaultAssistant.enableReasoning),
        enableVision: Value(defaultAssistant.enableVision),
        enableEmbedding: Value(defaultAssistant.enableEmbedding),
        mcpServerIds: Value(defaultAssistant.mcpServerIds),
        isEnabled: Value(defaultAssistant.isEnabled),
        createdAt: Value(defaultAssistant.createdAt),
        updatedAt: Value(defaultAssistant.updatedAt),
      );

      await database.insertAssistant(companion);

      _logger.info('✅ 默认助手创建成功', {
        'assistantId': defaultAssistant.id,
        'assistantName': defaultAssistant.name,
      });
    } catch (e) {
      _logger.error('❌ 创建默认助手失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 创建默认提供商
  ///
  /// 创建常用AI提供商的配置模板，用户可以根据需要配置API密钥。
  /// 包括OpenAI、Anthropic、Google等主流提供商。
  Future<void> _createDefaultProviders() async {
    try {
      _logger.info('🔌 开始创建默认提供商');

      final database = _ref.read(databaseProvider);
      final now = DateTime.now();

      // 定义默认提供商列表
      final defaultProviders = [
        _createOpenAIProvider(now),
        _createAnthropicProvider(now),
        _createGoogleProvider(now),
        _createDeepSeekProvider(now),
      ];

      // 批量插入提供商
      for (final provider in defaultProviders) {
        // 将domain的ProviderType映射到数据库的ProviderType
        final dbProviderType = _mapProviderType(provider.type);

        final companion = ProvidersCompanion.insert(
          id: provider.id,
          name: provider.name,
          type: dbProviderType,
          apiKey: provider.apiKey,
          baseUrl: Value(provider.baseUrl),
          models: Value(provider.models),
          customHeaders: provider.customHeaders,
          isEnabled: Value(provider.isEnabled),
          createdAt: provider.createdAt,
          updatedAt: provider.updatedAt,
        );

        await database.insertProvider(companion);
      }

      _logger.info('✅ 默认提供商创建成功', {
        'providerCount': defaultProviders.length,
        'providers': defaultProviders.map((p) => p.name).toList(),
      });
    } catch (e) {
      _logger.error('❌ 创建默认提供商失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 创建OpenAI提供商配置
  ai_provider.AiProvider _createOpenAIProvider(DateTime now) {
    return ai_provider.AiProvider(
      id: 'openai',
      name: 'OpenAI',
      type: ai_provider.ProviderType.openai,
      baseUrl: 'https://api.openai.com/v1',
      apiKey: '', // 用户需要自己配置
      models: [
        AiModel(
          id: 'gpt-4o-mini',
          name: 'gpt-4o-mini',
          displayName: 'GPT-4o mini',
          capabilities: [
            ModelCapability.reasoning,
            ModelCapability.vision,
            ModelCapability.tools
          ],
          metadata: {
            'contextLength': 128000,
            'maxTokens': 16384,
            'description': 'GPT-4o mini模型，快速且经济',
          },
          createdAt: now,
          updatedAt: now,
        ),
        AiModel(
          id: 'gpt-4o',
          name: 'gpt-4o',
          displayName: 'GPT-4o',
          capabilities: [
            ModelCapability.reasoning,
            ModelCapability.vision,
            ModelCapability.tools
          ],
          metadata: {
            'contextLength': 128000,
            'maxTokens': 4096,
            'description': 'GPT-4o模型，最新的多模态模型',
          },
          createdAt: now,
          updatedAt: now,
        ),
      ],
      isEnabled: false, // 默认禁用，需要用户配置API密钥后启用
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建Anthropic提供商配置
  ai_provider.AiProvider _createAnthropicProvider(DateTime now) {
    return ai_provider.AiProvider(
      id: 'anthropic',
      name: 'Anthropic',
      type: ai_provider.ProviderType.anthropic,
      baseUrl: 'https://api.anthropic.com',
      apiKey: '', // 用户需要自己配置
      models: [
        AiModel(
          id: 'claude-3-5-haiku-20241022',
          name: 'claude-3-5-haiku-20241022',
          displayName: 'Claude 3.5 Haiku',
          capabilities: [
            ModelCapability.reasoning,
            ModelCapability.vision,
            ModelCapability.tools
          ],
          metadata: {
            'contextLength': 200000,
            'maxTokens': 8192,
            'description': 'Claude 3.5 Haiku，快速且经济的模型',
          },
          createdAt: now,
          updatedAt: now,
        ),
        AiModel(
          id: 'claude-3-5-sonnet-20241022',
          name: 'claude-3-5-sonnet-20241022',
          displayName: 'Claude 3.5 Sonnet',
          capabilities: [
            ModelCapability.reasoning,
            ModelCapability.vision,
            ModelCapability.tools
          ],
          metadata: {
            'contextLength': 200000,
            'maxTokens': 8192,
            'description': 'Claude 3.5 Sonnet，平衡性能和成本',
          },
          createdAt: now,
          updatedAt: now,
        ),
      ],
      isEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建Google提供商配置
  ai_provider.AiProvider _createGoogleProvider(DateTime now) {
    return ai_provider.AiProvider(
      id: 'google',
      name: 'Google',
      type: ai_provider.ProviderType.google,
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      apiKey: '', // 用户需要自己配置
      models: [
        AiModel(
          id: 'gemini-1.5-flash',
          name: 'gemini-1.5-flash',
          displayName: 'Gemini 1.5 Flash',
          capabilities: [
            ModelCapability.reasoning,
            ModelCapability.vision,
            ModelCapability.tools
          ],
          metadata: {
            'contextLength': 1000000,
            'maxTokens': 8192,
            'description': 'Gemini 1.5 Flash，快速响应的多模态模型',
          },
          createdAt: now,
          updatedAt: now,
        ),
        AiModel(
          id: 'gemini-1.5-pro',
          name: 'gemini-1.5-pro',
          displayName: 'Gemini 1.5 Pro',
          capabilities: [
            ModelCapability.reasoning,
            ModelCapability.vision,
            ModelCapability.tools
          ],
          metadata: {
            'contextLength': 2000000,
            'maxTokens': 8192,
            'description': 'Gemini 1.5 Pro，高性能的多模态模型',
          },
          createdAt: now,
          updatedAt: now,
        ),
      ],
      isEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建DeepSeek提供商配置
  ai_provider.AiProvider _createDeepSeekProvider(DateTime now) {
    return ai_provider.AiProvider(
      id: 'deepseek',
      name: 'DeepSeek',
      type: ai_provider.ProviderType.custom,
      baseUrl: 'https://api.deepseek.com',
      apiKey: '', // 用户需要自己配置
      models: [
        AiModel(
          id: 'deepseek-chat',
          name: 'deepseek-chat',
          displayName: 'DeepSeek Chat',
          capabilities: [ModelCapability.reasoning, ModelCapability.tools],
          metadata: {
            'contextLength': 32768,
            'maxTokens': 4096,
            'description': 'DeepSeek Chat，通用对话模型',
          },
          createdAt: now,
          updatedAt: now,
        ),
        AiModel(
          id: 'deepseek-reasoner',
          name: 'deepseek-reasoner',
          displayName: 'DeepSeek Reasoner',
          capabilities: [ModelCapability.reasoning, ModelCapability.tools],
          metadata: {
            'contextLength': 32768,
            'maxTokens': 4096,
            'description': 'DeepSeek Reasoner，专注于推理的模型',
          },
          createdAt: now,
          updatedAt: now,
        ),
      ],
      isEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 将domain的ProviderType映射到数据库的ProviderType
  ProviderType _mapProviderType(ai_provider.ProviderType domainType) {
    switch (domainType) {
      case ai_provider.ProviderType.openai:
        return ProviderType.openai;
      case ai_provider.ProviderType.anthropic:
        return ProviderType.anthropic;
      case ai_provider.ProviderType.google:
        return ProviderType.google;
      case ai_provider.ProviderType.ollama:
        return ProviderType.ollama;
      case ai_provider.ProviderType.custom:
        return ProviderType.custom;
    }
  }
}

/// 数据初始化服务Provider
///
/// 提供DataInitializationService实例，遵循Riverpod依赖注入原则。
final dataInitializationServiceProvider =
    Provider<DataInitializationService>((ref) {
  return DataInitializationService(ref);
});

/// 数据初始化Provider
///
/// 负责在应用启动时检查并初始化默认数据。
/// 这是一个FutureProvider，会在应用启动时自动执行。
///
/// ## 特性
/// - ⚡ **异步初始化**：不阻塞UI线程
/// - 🔄 **幂等性**：多次调用安全，只在需要时初始化
/// - 📊 **状态跟踪**：通过AsyncValue跟踪初始化状态
/// - 🛡️ **错误处理**：完整的错误处理和日志记录
///
/// ## 使用方式
/// ```dart
/// // 在应用启动时
/// await ref.read(initializeDefaultDataProvider.future);
///
/// // 监听初始化状态
/// ref.listen(initializeDefaultDataProvider, (previous, next) {
///   next.when(
///     data: (initialized) => print(initialized ? '✅ 数据已初始化' : '✅ 数据已存在'),
///     loading: () => print('🔄 正在初始化数据...'),
///     error: (error, stack) => print('❌ 初始化失败: $error'),
///   );
/// });
/// ```
final initializeDefaultDataProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(dataInitializationServiceProvider);
  return await service.initializeDefaultDataIfNeeded();
});

/// 简单的fallback logger，用于测试环境
class _FallbackLogger {
  void info(String message, [Map<String, dynamic>? data]) {
    print('INFO: $message ${data != null ? data.toString() : ''}');
  }

  void debug(String message, [Map<String, dynamic>? data]) {
    print('DEBUG: $message ${data != null ? data.toString() : ''}');
  }

  void error(String message, [Map<String, dynamic>? data]) {
    print('ERROR: $message ${data != null ? data.toString() : ''}');
  }

  void warning(String message, [Map<String, dynamic>? data]) {
    print('WARNING: $message ${data != null ? data.toString() : ''}');
  }
}
