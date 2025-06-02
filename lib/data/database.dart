import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'converters.dart';
import '../models/ai_model.dart';

part 'database.g.dart';

// 定义数据库中的枚举类型
enum ProviderType { openai, anthropic, google, ollama, custom }

// 提供商表
@DataClassName('ProviderData')
class Providers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<ProviderType>()(); // 存储枚举值
  TextColumn get apiKey => text()();
  TextColumn get baseUrl => text().nullable()();
  TextColumn get models => text()
      .map(const ModelListConverter())
      .withDefault(const Constant('[]'))(); // JSON string - 模型列表
  TextColumn get customHeaders =>
      text().map(const StringMapConverter())(); // JSON string
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 助手表
@DataClassName('AssistantData')
class Assistants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get avatar => text().withDefault(const Constant('🤖'))();
  TextColumn get systemPrompt => text()();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();

  // AI参数
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  RealColumn get topP => real().withDefault(const Constant(1.0))();
  IntColumn get maxTokens => integer().withDefault(const Constant(2048))();
  IntColumn get contextLength => integer().withDefault(const Constant(10))();
  BoolColumn get streamOutput => boolean().withDefault(const Constant(true))();
  RealColumn get frequencyPenalty => real().nullable()();
  RealColumn get presencePenalty => real().nullable()();

  // 自定义配置
  TextColumn get customHeaders => text()
      .map(const StringMapConverter())
      .withDefault(const Constant('{}'))(); // JSON string
  TextColumn get customBody => text()
      .map(const DynamicMapConverter())
      .withDefault(const Constant('{}'))(); // JSON string
  TextColumn get stopSequences => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))(); // JSON string

  // 功能开关
  BoolColumn get enableCodeExecution =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableImageGeneration =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableTools => boolean().withDefault(const Constant(false))();
  BoolColumn get enableReasoning =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableVision => boolean().withDefault(const Constant(false))();
  BoolColumn get enableEmbedding =>
      boolean().withDefault(const Constant(false))();

  // 状态
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  // 时间戳
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 收藏模型表
@DataClassName('FavoriteModelData')
class FavoriteModels extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()(); // 提供商ID
  TextColumn get modelName => text()(); // 模型名称
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 对话表
@DataClassName('ConversationData')
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get assistantId => text()();
  TextColumn get providerId => text()();
  TextColumn get modelId => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 消息表
@DataClassName('MessageData')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get content => text()();
  TextColumn get author => text()();
  BoolColumn get isFromUser => boolean()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Providers, Assistants, Conversations, Messages, FavoriteModels],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 开发阶段暂时不处理迁移，直接删除数据库重建
    },
  );

  // 提供商相关操作
  Future<List<ProviderData>> getAllProviders() => select(providers).get();

  Future<ProviderData?> getProvider(String id) =>
      (select(providers)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertProvider(ProvidersCompanion provider) =>
      into(providers).insert(provider);

  Future<bool> updateProvider(String id, ProvidersCompanion provider) async {
    final result = await (update(
      providers,
    )..where((p) => p.id.equals(id))).write(provider);
    return result > 0;
  }

  Future<int> deleteProvider(String id) =>
      (delete(providers)..where((p) => p.id.equals(id))).go();

  // 助手相关操作
  Future<List<AssistantData>> getAllAssistants() => select(assistants).get();

  Future<AssistantData?> getAssistant(String id) =>
      (select(assistants)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insertAssistant(AssistantsCompanion assistant) =>
      into(assistants).insert(assistant);

  Future<bool> updateAssistant(String id, AssistantsCompanion assistant) async {
    final result = await (update(
      assistants,
    )..where((a) => a.id.equals(id))).write(assistant);
    return result > 0;
  }

  Future<int> deleteAssistant(String id) =>
      (delete(assistants)..where((a) => a.id.equals(id))).go();

  // 获取指定提供商的助手
  Future<List<AssistantData>> getAssistantsByProvider(String providerId) =>
      (select(assistants)..where((a) => a.providerId.equals(providerId))).get();

  // 对话相关操作
  Future<List<ConversationData>> getAllConversations() => (select(
    conversations,
  )..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)])).get();

  // 分页获取所有对话
  Future<List<ConversationData>> getAllConversationsWithPagination({
    int limit = 20,
    int offset = 0,
  }) =>
      (select(conversations)
            ..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)])
            ..limit(limit, offset: offset))
          .get();

  Future<List<ConversationData>> getConversationsByAssistant(
    String assistantId,
  ) =>
      (select(conversations)
            ..where((c) => c.assistantId.equals(assistantId))
            ..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)]))
          .get();

  // 分页获取指定助手的对话
  Future<List<ConversationData>> getConversationsByAssistantWithPagination(
    String assistantId, {
    int limit = 20,
    int offset = 0,
  }) =>
      (select(conversations)
            ..where((c) => c.assistantId.equals(assistantId))
            ..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)])
            ..limit(limit, offset: offset))
          .get();

  // 获取对话数量（用于分页计算）
  Future<int> getConversationCount() async {
    final countExp = conversations.id.count();
    final query = selectOnly(conversations)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  // 获取指定助手的对话数量
  Future<int> getConversationCountByAssistant(String assistantId) async {
    final countExp = conversations.id.count();
    final query = selectOnly(conversations)
      ..addColumns([countExp])
      ..where(conversations.assistantId.equals(assistantId));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<ConversationData?> getConversation(String id) =>
      (select(conversations)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertConversation(ConversationsCompanion conversation) =>
      into(conversations).insert(conversation);

  Future<bool> updateConversation(
    String id,
    ConversationsCompanion conversation,
  ) async {
    final result = await (update(
      conversations,
    )..where((c) => c.id.equals(id))).write(conversation);
    return result > 0;
  }

  Future<int> deleteConversation(String id) async {
    // 先删除相关消息
    await (delete(messages)..where((m) => m.conversationId.equals(id))).go();
    // 再删除对话
    return (delete(conversations)..where((c) => c.id.equals(id))).go();
  }

  // 消息相关操作
  Future<List<MessageData>> getMessagesByConversation(String conversationId) =>
      (select(messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.desc(m.timestamp)]))
          .get();

  Future<MessageData?> getMessage(String id) =>
      (select(messages)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<int> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  Future<bool> updateMessage(String id, MessagesCompanion message) async {
    final result = await (update(
      messages,
    )..where((m) => m.id.equals(id))).write(message);
    return result > 0;
  }

  Future<int> deleteMessage(String id) =>
      (delete(messages)..where((m) => m.id.equals(id))).go();

  // 获取对话的最后一条消息
  Future<MessageData?> getLastMessageByConversation(String conversationId) =>
      (select(messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
            ..limit(1))
          .getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yumcha.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
