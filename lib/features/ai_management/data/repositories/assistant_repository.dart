import '../../../../shared/data/database/database.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/infrastructure/services/validation_service.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:drift/drift.dart';

/// AI助手数据仓库 - 管理AI助手的数据持久化操作
///
/// AssistantRepository实现了Repository模式，负责AI助手数据的CRUD操作：
/// - 📊 **数据管理**：助手的增删改查操作
/// - 🔄 **模型转换**：数据库模型与业务模型的转换
/// - ✅ **数据验证**：确保助手数据的完整性和有效性
/// - 📝 **操作日志**：记录所有数据操作的详细日志
/// - 🛡️ **错误处理**：统一的异常处理和错误包装
/// - 🎛️ **状态管理**：助手启用/禁用状态管理
class AssistantRepository {
  /// 数据库实例
  final AppDatabase _database;

  /// 数据验证服务
  final ValidationService _validationService = ValidationService.instance;

  /// 日志记录服务
  final LoggerService _logger = LoggerService();

  AssistantRepository(this._database);

  /// 获取所有AI助手
  ///
  /// 从数据库中检索所有已配置的AI助手，包括启用和禁用的。
  ///
  /// @returns 所有AI助手的列表
  Future<List<AiAssistant>> getAllAssistants() async {
    try {
      _logger.debug('开始获取所有AI助手');
      final assistantDataList = await _database.getAllAssistants();
      final assistants = assistantDataList.map(_dataToModel).toList();

      _logger.info('AI助手获取成功', {'count': assistants.length});
      return assistants;
    } catch (e, stackTrace) {
      _logger.error('获取AI助手失败', {'error': e.toString()});
      throw DatabaseError(
        message: '获取AI助手失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 根据ID获取特定助手
  ///
  /// @param id 助手的唯一标识符
  /// @returns 找到的助手，如果不存在则返回null
  Future<AiAssistant?> getAssistant(String id) async {
    try {
      _logger.debug('开始获取助手', {'assistantId': id});
      final assistantData = await _database.getAssistant(id);
      if (assistantData == null) {
        _logger.debug('助手不存在', {'assistantId': id});
        return null;
      }

      final assistant = _dataToModel(assistantData);
      _logger.debug('助手获取成功', {'assistantId': id, 'name': assistant.name});
      return assistant;
    } catch (e, stackTrace) {
      _logger.error('获取助手失败', {'assistantId': id, 'error': e.toString()});
      throw DatabaseError(
        message: '获取助手失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 添加新助手
  ///
  /// @param assistant 要添加的助手对象
  /// @returns 助手的ID
  Future<String> insertAssistant(AiAssistant assistant) async {
    _logger.info('开始添加新助手', {'name': assistant.name});

    // 验证助手数据
    _validationService.validateAiAssistant(assistant);

    try {
      final companion = _modelToCompanion(assistant);
      await _database.insertAssistant(companion);

      _logger.info('助手添加成功', {'name': assistant.name, 'id': assistant.id});
      return assistant.id;
    } catch (e, stackTrace) {
      _logger.error('助手添加失败', {'name': assistant.name, 'error': e.toString()});
      throw DatabaseError(
        message: '添加助手失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 更新助手
  ///
  /// @param assistant 要更新的助手对象
  /// @returns 是否更新成功
  Future<bool> updateAssistant(AiAssistant assistant) async {
    _logger.info('开始更新助手', {'name': assistant.name, 'id': assistant.id});

    // 验证助手数据
    _validationService.validateAiAssistant(assistant);

    try {
      final companion = _modelToCompanion(assistant);
      final result = await _database.updateAssistant(assistant.id, companion);

      _logger.info('助手更新完成', {'name': assistant.name, 'success': result});
      return result;
    } catch (e, stackTrace) {
      _logger.error('助手更新失败', {'name': assistant.name, 'error': e.toString()});
      throw DatabaseError(
        message: '更新助手失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 删除助手
  ///
  /// @param id 要删除的助手ID
  /// @returns 删除的记录数
  Future<int> deleteAssistant(String id) async {
    try {
      _logger.info('开始删除助手', {'assistantId': id});
      final result = await _database.deleteAssistant(id);

      _logger.info('助手删除完成', {'assistantId': id, 'deletedCount': result});
      return result;
    } catch (e, stackTrace) {
      _logger.error('助手删除失败', {'assistantId': id, 'error': e.toString()});
      throw DatabaseError(
        message: '删除助手失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 获取启用的助手
  ///
  /// @returns 所有启用状态的助手列表
  Future<List<AiAssistant>> getEnabledAssistants() async {
    try {
      _logger.debug('开始获取启用的助手');
      final allAssistants = await getAllAssistants();
      final enabledAssistants =
          allAssistants.where((a) => a.isEnabled).toList();

      _logger.info('启用助手获取成功', {'count': enabledAssistants.length});
      return enabledAssistants;
    } catch (e, stackTrace) {
      _logger.error('获取启用助手失败', {'error': e.toString()});
      throw DatabaseError(
        message: '获取启用助手失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 切换助手启用状态
  ///
  /// @param id 助手ID
  /// @returns 是否切换成功
  Future<bool> toggleAssistantEnabled(String id) async {
    try {
      _logger.info('开始切换助手启用状态', {'assistantId': id});

      final assistant = await getAssistant(id);
      if (assistant == null) {
        _logger.warning('助手不存在，无法切换状态', {'assistantId': id});
        return false;
      }

      final updatedAssistant = assistant.copyWith(
        isEnabled: !assistant.isEnabled,
        updatedAt: DateTime.now(),
      );

      final result = await updateAssistant(updatedAssistant);

      _logger.info('助手状态切换完成', {
        'assistantId': id,
        'newStatus': updatedAssistant.isEnabled,
        'success': result,
      });

      return result;
    } catch (e, stackTrace) {
      _logger.error('助手状态切换失败', {'assistantId': id, 'error': e.toString()});
      throw DatabaseError(
        message: '切换助手状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 批量更新助手状态
  ///
  /// @param assistantIds 助手ID列表
  /// @param isEnabled 新的启用状态
  /// @returns 成功更新的数量
  Future<int> batchUpdateAssistantStatus(
      List<String> assistantIds, bool isEnabled) async {
    try {
      _logger.info('开始批量更新助手状态', {
        'count': assistantIds.length,
        'isEnabled': isEnabled,
      });

      int successCount = 0;
      for (final id in assistantIds) {
        final assistant = await getAssistant(id);
        if (assistant != null) {
          final updatedAssistant = assistant.copyWith(
            isEnabled: isEnabled,
            updatedAt: DateTime.now(),
          );

          if (await updateAssistant(updatedAssistant)) {
            successCount++;
          }
        }
      }

      _logger.info('批量更新助手状态完成', {
        'total': assistantIds.length,
        'success': successCount,
      });

      return successCount;
    } catch (e, stackTrace) {
      _logger.error('批量更新助手状态失败', {'error': e.toString()});
      throw DatabaseError(
        message: '批量更新助手状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // 将数据库模型转换为业务模型
  AiAssistant _dataToModel(AssistantData data) {
    return AiAssistant(
      id: data.id,
      name: data.name,
      description: data.description,
      avatar: data.avatar,
      systemPrompt: data.systemPrompt,
      temperature: data.temperature,
      topP: data.topP,
      maxTokens: data.maxTokens,
      contextLength: data.contextLength,
      streamOutput: data.streamOutput,
      frequencyPenalty: data.frequencyPenalty,
      presencePenalty: data.presencePenalty,
      customHeaders: data.customHeaders,
      customBody: data.customBody,
      stopSequences: data.stopSequences,
      enableCodeExecution: data.enableCodeExecution,
      enableImageGeneration: data.enableImageGeneration,
      enableTools: data.enableTools,
      enableReasoning: data.enableReasoning,
      enableVision: data.enableVision,
      enableEmbedding: data.enableEmbedding,
      mcpServerIds: data.mcpServerIds,
      isEnabled: data.isEnabled,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // 将业务模型转换为数据库Companion
  AssistantsCompanion _modelToCompanion(AiAssistant assistant) {
    return AssistantsCompanion(
      id: Value(assistant.id),
      name: Value(assistant.name),
      description: Value(assistant.description),
      avatar: Value(assistant.avatar),
      systemPrompt: Value(assistant.systemPrompt),
      temperature: Value(assistant.temperature),
      topP: Value(assistant.topP),
      maxTokens: Value(assistant.maxTokens),
      contextLength: Value(assistant.contextLength),
      streamOutput: Value(assistant.streamOutput),
      frequencyPenalty: Value(assistant.frequencyPenalty),
      presencePenalty: Value(assistant.presencePenalty),
      customHeaders: Value(assistant.customHeaders),
      customBody: Value(assistant.customBody),
      stopSequences: Value(assistant.stopSequences),
      enableCodeExecution: Value(assistant.enableCodeExecution),
      enableImageGeneration: Value(assistant.enableImageGeneration),
      enableTools: Value(assistant.enableTools),
      enableReasoning: Value(assistant.enableReasoning),
      enableVision: Value(assistant.enableVision),
      enableEmbedding: Value(assistant.enableEmbedding),
      mcpServerIds: Value(assistant.mcpServerIds),
      isEnabled: Value(assistant.isEnabled),
      createdAt: Value(assistant.createdAt),
      updatedAt: Value(assistant.updatedAt),
    );
  }
}
