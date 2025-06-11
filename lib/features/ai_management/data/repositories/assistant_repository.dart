import '../../../../shared/data/database/database.dart';
import '../../domain/entities/ai_assistant.dart';
import 'package:drift/drift.dart';

class AssistantRepository {
  final AppDatabase _database;

  AssistantRepository(this._database);

  // 获取所有助手
  Future<List<AiAssistant>> getAllAssistants() async {
    final assistantDataList = await _database.getAllAssistants();
    return assistantDataList.map(_dataToModel).toList();
  }

  // 根据ID获取助手
  Future<AiAssistant?> getAssistant(String id) async {
    final assistantData = await _database.getAssistant(id);
    if (assistantData == null) return null;
    return _dataToModel(assistantData);
  }

  // 添加新助手
  Future<String> insertAssistant(AiAssistant assistant) async {
    final companion = _modelToCompanion(assistant);
    await _database.insertAssistant(companion);
    return assistant.id;
  }

  // 更新助手
  Future<bool> updateAssistant(AiAssistant assistant) async {
    final companion = _modelToCompanion(assistant);
    return await _database.updateAssistant(assistant.id, companion);
  }

  // 删除助手
  Future<int> deleteAssistant(String id) async {
    return await _database.deleteAssistant(id);
  }

  // 获取启用的助手
  Future<List<AiAssistant>> getEnabledAssistants() async {
    final allAssistants = await getAllAssistants();
    return allAssistants.where((a) => a.isEnabled).toList();
  }

  // 切换助手启用状态
  Future<bool> toggleAssistantEnabled(String id) async {
    final assistant = await getAssistant(id);
    if (assistant == null) return false;

    final updatedAssistant = assistant.copyWith(
      isEnabled: !assistant.isEnabled,
      updatedAt: DateTime.now(),
    );

    return await updateAssistant(updatedAssistant);
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
