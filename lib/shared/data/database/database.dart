import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'converters.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';

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

  // MCP 配置
  TextColumn get mcpServerIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))(); // JSON string - MCP服务器ID列表

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

// 消息表 - 块化重构版本，消息作为块的容器
@DataClassName('MessageData')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get role => text()(); // 'user' | 'assistant' | 'system'
  TextColumn get assistantId => text()(); // 关联的助手ID
  TextColumn get blockIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))(); // 消息块ID列表
  TextColumn get status => text().withDefault(const Constant('userSuccess'))(); // 消息状态
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // 元数据
  TextColumn get modelId => text().nullable()(); // 使用的模型ID
  TextColumn get metadata => text().nullable()(); // 消息元数据（JSON格式）

  @override
  Set<Column> get primaryKey => {id};
}

// 消息块表 - 存储具体的消息内容块
@DataClassName('MessageBlockData')
class MessageBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()(); // 所属消息ID
  TextColumn get type => text()(); // 块类型：mainText, thinking, image, code, tool, file, error, citation
  TextColumn get status => text().withDefault(const Constant('success'))(); // 块状态
  TextColumn get content => text().nullable()(); // 块内容
  TextColumn get metadata => text().nullable()(); // 块元数据（JSON格式）
  IntColumn get orderIndex => integer().withDefault(const Constant(0))(); // 块在消息中的顺序
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 设置表
@DataClassName('SettingData')
class Settings extends Table {
  TextColumn get key => text()(); // 设置键名
  TextColumn get value => text()(); // 设置值（JSON字符串）
  TextColumn get type => text()(); // 值类型：string, bool, int, double, json
  TextColumn get description => text().nullable()(); // 设置描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Providers,
    Assistants,
    Conversations,
    Messages,
    MessageBlocks,
    FavoriteModels,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes(m);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 开发阶段：直接删除所有表重新创建
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
          await _createIndexes(m);
        },
      );

  /// 创建索引以提高查询性能
  Future<void> _createIndexes(Migrator m) async {
    // 为常用查询字段创建索引
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_assistant_id ON conversations(assistant_id);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations(last_message_at);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_role ON messages(role);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_assistant_id ON messages(assistant_id);',
    );
    // 为消息块内容搜索添加索引
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_content ON message_blocks(content);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_message_id ON message_blocks(message_id);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_type ON message_blocks(type);',
    );
  }



  // 提供商相关操作
  Future<List<ProviderData>> getAllProviders() => select(providers).get();

  Future<ProviderData?> getProvider(String id) =>
      (select(providers)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertProvider(ProvidersCompanion provider) =>
      into(providers).insert(provider);

  Future<bool> updateProvider(String id, ProvidersCompanion provider) async {
    final result = await (update(
      providers,
    )..where((p) => p.id.equals(id)))
        .write(provider);
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
    )..where((a) => a.id.equals(id)))
        .write(assistant);
    return result > 0;
  }

  Future<int> deleteAssistant(String id) =>
      (delete(assistants)..where((a) => a.id.equals(id))).go();

  // 对话相关操作
  Future<List<ConversationData>> getAllConversations() => (select(
        conversations,
      )..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)]))
          .get();

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
    )..where((c) => c.id.equals(id)))
        .write(conversation);
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
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .get();

  Future<MessageData?> getMessage(String id) =>
      (select(messages)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<int> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  Future<bool> updateMessage(String id, MessagesCompanion message) async {
    final result = await (update(
      messages,
    )..where((m) => m.id.equals(id)))
        .write(message);
    return result > 0;
  }

  Future<int> deleteMessage(String id) async {
    // 先删除相关的消息块
    await (delete(messageBlocks)..where((mb) => mb.messageId.equals(id))).go();
    // 再删除消息
    return (delete(messages)..where((m) => m.id.equals(id))).go();
  }

  // 消息块相关操作
  Future<List<MessageBlockData>> getMessageBlocks(String messageId) =>
      (select(messageBlocks)
            ..where((mb) => mb.messageId.equals(messageId))
            ..orderBy([(mb) => OrderingTerm.asc(mb.orderIndex)]))
          .get();

  Future<MessageBlockData?> getMessageBlock(String id) =>
      (select(messageBlocks)..where((mb) => mb.id.equals(id))).getSingleOrNull();

  Future<int> insertMessageBlock(MessageBlocksCompanion block) =>
      into(messageBlocks).insert(block);

  Future<bool> updateMessageBlock(String id, MessageBlocksCompanion block) async {
    final result = await (update(
      messageBlocks,
    )..where((mb) => mb.id.equals(id)))
        .write(block);
    return result > 0;
  }

  Future<int> deleteMessageBlock(String id) =>
      (delete(messageBlocks)..where((mb) => mb.id.equals(id))).go();

  // 获取对话的最后一条消息
  Future<MessageData?> getLastMessageByConversation(String conversationId) =>
      (select(messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  // 获取对话的消息数量
  Future<int> getMessageCountByConversation(String conversationId) async {
    final countExp = messages.id.count();
    final query = selectOnly(messages)
      ..addColumns([countExp])
      ..where(messages.conversationId.equals(conversationId));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  // 搜索消息内容（基于消息块）
  Future<List<MessageData>> searchMessages(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // 搜索消息块内容，然后获取对应的消息
    final searchQuery = select(messages).join([
      innerJoin(
        messageBlocks,
        messageBlocks.messageId.equalsExp(messages.id),
      ),
      leftOuterJoin(
        conversations,
        conversations.id.equalsExp(messages.conversationId),
      ),
    ]);

    // 添加搜索条件
    searchQuery.where(messageBlocks.content.like('%${query.trim()}%'));

    // 如果指定了助手ID，添加助手过滤条件
    if (assistantId != null && assistantId.isNotEmpty) {
      searchQuery.where(conversations.assistantId.equals(assistantId));
    }

    // 按时间倒序排列
    searchQuery.orderBy([OrderingTerm.desc(messages.createdAt)]);

    // 分页
    searchQuery.limit(limit, offset: offset);

    final results = await searchQuery.get();
    return results.map((row) => row.readTable(messages)).toList();
  }

  // 获取搜索结果数量（基于消息块）
  Future<int> getSearchResultCount(String query, {String? assistantId}) async {
    if (query.trim().isEmpty) {
      return 0;
    }

    final countQuery = selectOnly(messages).join([
      innerJoin(
        messageBlocks,
        messageBlocks.messageId.equalsExp(messages.id),
      ),
      leftOuterJoin(
        conversations,
        conversations.id.equalsExp(messages.conversationId),
      ),
    ]);

    final countExp = messages.id.count();
    countQuery.addColumns([countExp]);

    // 添加搜索条件
    countQuery.where(messageBlocks.content.like('%${query.trim()}%'));

    // 如果指定了助手ID，添加助手过滤条件
    if (assistantId != null && assistantId.isNotEmpty) {
      countQuery.where(conversations.assistantId.equals(assistantId));
    }

    final result = await countQuery.getSingle();
    return result.read(countExp) ?? 0;
  }

  // 搜索对话标题
  Future<List<ConversationData>> searchConversationsByTitle(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final searchQuery = select(conversations);

    // 添加标题搜索条件
    searchQuery.where((c) => c.title.like('%${query.trim()}%'));

    // 如果指定了助手ID，添加助手过滤条件
    if (assistantId != null && assistantId.isNotEmpty) {
      searchQuery.where((c) => c.assistantId.equals(assistantId));
    }

    // 按最后消息时间倒序排列
    searchQuery.orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)]);

    // 分页
    searchQuery.limit(limit, offset: offset);

    return await searchQuery.get();
  }
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
