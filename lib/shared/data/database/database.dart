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

// 消息表 - 重构版本，支持版本管理和丰富元数据
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
  DateTimeColumn get updatedAt => dateTime()();

  // 版本管理
  TextColumn get parentMessageId => text().nullable()(); // 父消息ID（用于重新生成的消息）
  IntColumn get version => integer().withDefault(const Constant(1))(); // 消息版本号
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // 是否为当前活跃版本

  // 消息状态管理
  TextColumn get status =>
      text().withDefault(const Constant('normal'))(); // 消息状态
  TextColumn get errorInfo => text().nullable()(); // 错误信息

  // AI响应元数据（JSON格式）
  TextColumn get metadata => text().nullable()(); // 存储AI响应的详细信息

  // 多媒体内容元数据（JSON格式）
  TextColumn get mediaMetadata => text().nullable()(); // 存储多媒体文件的元数据信息

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
    FavoriteModels,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes(m);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 数据库迁移策略
          await _performMigration(m, from, to);
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
      'CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp);',
    );
    // 为消息内容搜索添加索引
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_content ON messages(content);',
    );
  }

  /// 执行数据库迁移
  Future<void> _performMigration(Migrator m, int from, int to) async {
    // 版本1到版本2：添加设置表
    if (from < 2) {
      await m.createTable(settings);
      // 为设置表创建索引
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_settings_key ON settings(key);',
      );
    }

    // 版本2到版本3：为助手表添加MCP服务器ID字段
    if (from < 3) {
      await m.database.customStatement(
        'ALTER TABLE assistants ADD COLUMN mcp_server_ids TEXT NOT NULL DEFAULT "[]";',
      );
    }

    // 版本3到版本4：修复消息表中status字段的null值
    if (from < 4) {
      // 更新所有status为null的记录，设置为默认值'normal'
      await m.database.customStatement(
        'UPDATE messages SET status = "normal" WHERE status IS NULL;',
      );
      // 更新所有version为null的记录，设置为默认值1
      await m.database.customStatement(
        'UPDATE messages SET version = 1 WHERE version IS NULL;',
      );
      // 更新所有is_active为null的记录，设置为默认值true
      await m.database.customStatement(
        'UPDATE messages SET is_active = 1 WHERE is_active IS NULL;',
      );
    }

    // 版本4到版本5：为消息表添加多媒体元数据字段
    if (from < 5) {
      await m.database.customStatement(
        'ALTER TABLE messages ADD COLUMN media_metadata TEXT;',
      );
    }

    // 未来版本升级时在此处添加迁移逻辑
    // if (from < 6) {
    //   await m.createTable(newTable);
    // }
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
            ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
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

  Future<int> deleteMessage(String id) =>
      (delete(messages)..where((m) => m.id.equals(id))).go();

  // 获取对话的最后一条消息
  Future<MessageData?> getLastMessageByConversation(String conversationId) =>
      (select(messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
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

  // 搜索消息内容
  Future<List<MessageData>> searchMessages(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final searchQuery = select(messages).join([
      leftOuterJoin(
        conversations,
        conversations.id.equalsExp(messages.conversationId),
      ),
    ]);

    // 添加搜索条件
    searchQuery.where(messages.content.like('%${query.trim()}%'));

    // 如果指定了助手ID，添加助手过滤条件
    if (assistantId != null && assistantId.isNotEmpty) {
      searchQuery.where(conversations.assistantId.equals(assistantId));
    }

    // 按时间倒序排列
    searchQuery.orderBy([OrderingTerm.desc(messages.timestamp)]);

    // 分页
    searchQuery.limit(limit, offset: offset);

    final results = await searchQuery.get();
    return results.map((row) => row.readTable(messages)).toList();
  }

  // 获取搜索结果数量
  Future<int> getSearchResultCount(String query, {String? assistantId}) async {
    if (query.trim().isEmpty) {
      return 0;
    }

    final countQuery = selectOnly(messages).join([
      leftOuterJoin(
        conversations,
        conversations.id.equalsExp(messages.conversationId),
      ),
    ]);

    final countExp = messages.id.count();
    countQuery.addColumns([countExp]);

    // 添加搜索条件
    countQuery.where(messages.content.like('%${query.trim()}%'));

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
