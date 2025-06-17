import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'converters.dart';
import 'database_utils.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';

part 'database.g.dart';

// 定义数据库中的枚举类型
enum ProviderType { openai, anthropic, google, deepseek, groq, ollama }

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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes(m);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 🚀 优化：根据版本进行渐进式迁移，避免数据丢失
          if (from < 2) {
            // 从版本1升级到版本2：添加新索引和FTS表
            await _upgradeToVersion2(m);
          }

          // 未来版本的迁移可以在这里添加
          // if (from < 3) {
          //   await _upgradeToVersion3(m);
          // }
        },
      );

  /// 🚀 新增：升级到版本2的迁移方法
  Future<void> _upgradeToVersion2(Migrator m) async {
    // 添加新的索引
    await _createIndexes(m);

    // 如果FTS表不存在，则创建并填充数据
    try {
      // 检查是否已存在FTS表
      final result = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='message_blocks_fts'",
      ).get();

      if (result.isEmpty) {
        // 创建FTS表和触发器
        await _createFTSTable();

        // 填充现有数据到FTS表
        await customStatement(
          'INSERT INTO message_blocks_fts(rowid, content) SELECT rowid, content FROM message_blocks WHERE content IS NOT NULL',
        );
      }
    } catch (e) {
      // 如果出错，记录日志但不中断迁移
      // 在生产环境中应该使用适当的日志框架
      debugPrint('FTS表创建失败: $e');
    }
  }

  /// 🚀 新增：创建FTS表的独立方法
  Future<void> _createFTSTable() async {
    // 创建FTS虚拟表
    await customStatement(
      '''CREATE VIRTUAL TABLE IF NOT EXISTS message_blocks_fts USING fts5(
        content,
        content='message_blocks',
        content_rowid='rowid'
      );''',
    );

    // 创建FTS触发器
    await customStatement(
      '''CREATE TRIGGER IF NOT EXISTS message_blocks_fts_insert AFTER INSERT ON message_blocks BEGIN
        INSERT INTO message_blocks_fts(rowid, content) VALUES (new.rowid, new.content);
      END;''',
    );

    await customStatement(
      '''CREATE TRIGGER IF NOT EXISTS message_blocks_fts_delete AFTER DELETE ON message_blocks BEGIN
        INSERT INTO message_blocks_fts(message_blocks_fts, rowid, content) VALUES('delete', old.rowid, old.content);
      END;''',
    );

    await customStatement(
      '''CREATE TRIGGER IF NOT EXISTS message_blocks_fts_update AFTER UPDATE ON message_blocks BEGIN
        INSERT INTO message_blocks_fts(message_blocks_fts, rowid, content) VALUES('delete', old.rowid, old.content);
        INSERT INTO message_blocks_fts(rowid, content) VALUES (new.rowid, new.content);
      END;''',
    );
  }

  /// 创建索引以提高查询性能
  Future<void> _createIndexes(Migrator m) async {
    // 🚀 优化：为AI聊天应用添加专门的复合索引和全文搜索索引

    // === 对话相关索引 ===
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_assistant_id ON conversations(assistant_id);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations(last_message_at);',
    );
    // 🚀 新增：对话的复合索引，用于按助手和时间查询
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_assistant_time ON conversations(assistant_id, last_message_at DESC);',
    );
    // 🚀 新增：对话标题搜索索引
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_title ON conversations(title);',
    );

    // === 消息相关索引 ===
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
    // 🚀 新增：消息的复合索引，用于按对话和时间查询
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_conversation_time ON messages(conversation_id, created_at ASC);',
    );
    // 🚀 新增：消息状态索引，用于查询特定状态的消息
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_status ON messages(status);',
    );

    // === 消息块相关索引 ===
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_message_id ON message_blocks(message_id);',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_type ON message_blocks(type);',
    );
    // 🚀 新增：消息块的复合索引，用于按消息和顺序查询
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_message_order ON message_blocks(message_id, order_index ASC);',
    );
    // 🚀 新增：消息块状态索引
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_blocks_status ON message_blocks(status);',
    );

    // === 全文搜索索引 ===
    // 🚀 新增：为消息块内容创建FTS虚拟表，提升搜索性能
    await m.database.customStatement(
      '''CREATE VIRTUAL TABLE IF NOT EXISTS message_blocks_fts USING fts5(
        content,
        content='message_blocks',
        content_rowid='rowid'
      );''',
    );

    // 🚀 新增：创建FTS触发器，自动同步数据
    await m.database.customStatement(
      '''CREATE TRIGGER IF NOT EXISTS message_blocks_fts_insert AFTER INSERT ON message_blocks BEGIN
        INSERT INTO message_blocks_fts(rowid, content) VALUES (new.rowid, new.content);
      END;''',
    );

    await m.database.customStatement(
      '''CREATE TRIGGER IF NOT EXISTS message_blocks_fts_delete AFTER DELETE ON message_blocks BEGIN
        INSERT INTO message_blocks_fts(message_blocks_fts, rowid, content) VALUES('delete', old.rowid, old.content);
      END;''',
    );

    await m.database.customStatement(
      '''CREATE TRIGGER IF NOT EXISTS message_blocks_fts_update AFTER UPDATE ON message_blocks BEGIN
        INSERT INTO message_blocks_fts(message_blocks_fts, rowid, content) VALUES('delete', old.rowid, old.content);
        INSERT INTO message_blocks_fts(rowid, content) VALUES (new.rowid, new.content);
      END;''',
    );

    // === 收藏模型索引 ===
    // 🚀 新增：收藏模型的复合索引
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_favorite_models_provider_model ON favorite_models(provider_id, model_name);',
    );

    // === 设置索引 ===
    // 🚀 新增：设置键的索引（主键已存在，这里添加类型索引）
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_settings_type ON settings(type);',
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
    // 🚀 优化：使用事务确保数据一致性，并级联删除相关数据
    return await transaction(() async {
      // 1. 先删除消息块
      await customStatement(
        'DELETE FROM message_blocks WHERE message_id IN (SELECT id FROM messages WHERE conversation_id = ?)',
        [id],
      );

      // 2. 删除消息
      await (delete(messages)..where((m) => m.conversationId.equals(id))).go();

      // 3. 删除对话
      final result = await (delete(conversations)..where((c) => c.id.equals(id))).go();

      return result;
    });
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

  // 🚀 优化：使用FTS全文搜索替代LIKE查询，提升搜索性能
  Future<List<MessageData>> searchMessages(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // 尝试使用FTS全文搜索
      return await _searchMessagesWithFTS(query, assistantId: assistantId, limit: limit, offset: offset);
    } catch (e) {
      // 如果FTS搜索失败，回退到LIKE搜索
      return await _searchMessagesWithLike(query, assistantId: assistantId, limit: limit, offset: offset);
    }
  }

  // 🚀 新增：使用FTS全文搜索
  Future<List<MessageData>> _searchMessagesWithFTS(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    // 构建FTS查询
    final ftsQuery = query.trim().split(' ').map((term) => '"$term"').join(' OR ');

    // 使用FTS搜索获取匹配的消息块
    final sql = '''
      SELECT DISTINCT m.* FROM messages m
      INNER JOIN message_blocks mb ON mb.message_id = m.id
      INNER JOIN message_blocks_fts fts ON fts.rowid = mb.rowid
      ${assistantId != null ? 'INNER JOIN conversations c ON c.id = m.conversation_id' : ''}
      WHERE fts MATCH ?
      ${assistantId != null ? 'AND c.assistant_id = ?' : ''}
      ORDER BY m.created_at DESC
      LIMIT ? OFFSET ?
    ''';

    final params = [
      ftsQuery,
      if (assistantId != null) assistantId,
      limit,
      offset,
    ];

    final result = await customSelect(sql, variables: params.map((p) => Variable(p)).toList()).get();
    return Future.wait(result.map((row) => messages.mapFromRow(row)));
  }

  // 🚀 保留：LIKE搜索作为回退方案
  Future<List<MessageData>> _searchMessagesWithLike(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
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

  // ========== 🚀 新增：批量操作优化 ==========

  /// 批量插入消息块
  Future<void> batchInsertMessageBlocks(List<MessageBlocksCompanion> blocks) async {
    if (blocks.isEmpty) return;

    await batch((batch) {
      for (final block in blocks) {
        batch.insert(messageBlocks, block);
      }
    });
  }

  /// 批量更新消息状态
  Future<int> batchUpdateMessageStatus(List<String> messageIds, String status) async {
    if (messageIds.isEmpty) return 0;

    final placeholders = List.filled(messageIds.length, '?').join(',');
    await customStatement(
      'UPDATE messages SET status = ?, updated_at = ? WHERE id IN ($placeholders)',
      [status, DateTime.now(), ...messageIds],
    );
    return messageIds.length;
  }

  /// 批量删除消息
  Future<int> batchDeleteMessages(List<String> messageIds) async {
    if (messageIds.isEmpty) return 0;

    return await transaction(() async {
      // 1. 删除消息块
      final placeholders = List.filled(messageIds.length, '?').join(',');
      await customStatement(
        'DELETE FROM message_blocks WHERE message_id IN ($placeholders)',
        messageIds,
      );

      // 2. 删除消息
      await customStatement(
        'DELETE FROM messages WHERE id IN ($placeholders)',
        messageIds,
      );

      return messageIds.length;
    });
  }

  // ========== 🚀 新增：数据清理和归档 ==========

  /// 清理过期数据
  Future<DataCleanupResult> cleanupExpiredData({
    Duration? conversationRetention,
    Duration? messageRetention,
    int? maxConversationsPerAssistant,
    bool dryRun = false,
  }) async {
    final result = DataCleanupResult();

    try {
      await transaction(() async {
        // 1. 清理过期对话
        if (conversationRetention != null) {
          final cutoffDate = DateTime.now().subtract(conversationRetention);
          final expiredConversations = await (select(conversations)
                ..where((c) => c.lastMessageAt.isSmallerThanValue(cutoffDate)))
              .get();

          if (!dryRun && expiredConversations.isNotEmpty) {
            for (final conv in expiredConversations) {
              await deleteConversation(conv.id);
            }
          }
          result.conversationsDeleted = expiredConversations.length;
        }

        // 2. 清理过期消息（保留对话但删除旧消息）
        if (messageRetention != null) {
          final cutoffDate = DateTime.now().subtract(messageRetention);
          final expiredMessages = await (select(messages)
                ..where((m) => m.createdAt.isSmallerThanValue(cutoffDate)))
              .get();

          if (!dryRun && expiredMessages.isNotEmpty) {
            final messageIds = expiredMessages.map((m) => m.id).toList();
            await batchDeleteMessages(messageIds);
          }
          result.messagesDeleted = expiredMessages.length;
        }

        // 3. 限制每个助手的对话数量
        if (maxConversationsPerAssistant != null) {
          final assistants = await getAllAssistants();
          for (final assistant in assistants) {
            final conversations = await (select(this.conversations)
                  ..where((c) => c.assistantId.equals(assistant.id))
                  ..orderBy([(c) => OrderingTerm.desc(c.lastMessageAt)]))
                .get();

            if (conversations.length > maxConversationsPerAssistant) {
              final toDelete = conversations.skip(maxConversationsPerAssistant).toList();
              if (!dryRun) {
                for (final conv in toDelete) {
                  await deleteConversation(conv.id);
                }
              }
              result.conversationsDeleted += toDelete.length;
            }
          }
        }
      });

      result.success = true;
    } catch (e) {
      result.success = false;
      result.error = e.toString();
    }

    return result;
  }

  /// 获取数据库统计信息
  Future<DatabaseStats> getDatabaseStats() async {
    final stats = DatabaseStats();

    // 表行数统计
    stats.conversationCount = await getConversationCount();
    stats.messageCount = await _getTableRowCount('messages');
    stats.messageBlockCount = await _getTableRowCount('message_blocks');
    stats.providerCount = await _getTableRowCount('providers');
    stats.assistantCount = await _getTableRowCount('assistants');

    // 数据库文件大小
    final dbFile = File(p.join((await getApplicationDocumentsDirectory()).path, 'yumcha.db'));
    if (await dbFile.exists()) {
      stats.databaseSizeBytes = await dbFile.length();
    }

    // 最新活动时间
    final latestMessage = await (select(messages)
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    if (latestMessage != null) {
      stats.lastActivityAt = latestMessage.createdAt;
    }

    return stats;
  }

  /// 获取表行数
  Future<int> _getTableRowCount(String tableName) async {
    final result = await customSelect('SELECT COUNT(*) as count FROM $tableName').getSingle();
    return result.data['count'] as int;
  }

  // ========== 🚀 新增：性能监控 ==========

  /// 分析查询性能
  Future<List<QueryPlan>> analyzeQuery(String sql, [List<Object?>? parameters]) async {
    final plans = <QueryPlan>[];

    try {
      final result = await customSelect(
        'EXPLAIN QUERY PLAN $sql',
        variables: parameters?.map((p) => Variable(p)).toList() ?? [],
      ).get();

      for (final row in result) {
        plans.add(QueryPlan(
          id: row.data['id'] as int,
          parent: row.data['parent'] as int,
          detail: row.data['detail'] as String,
        ));
      }
    } catch (e) {
      // 查询分析失败，返回空列表
    }

    return plans;
  }

  /// 优化数据库
  Future<void> optimizeDatabase() async {
    try {
      // 更新统计信息
      await customStatement('ANALYZE');

      // 优化查询计划器
      await customStatement('PRAGMA optimize');

      // 清理未使用的页面
      await customStatement('VACUUM');

      // 重建索引
      await customStatement('REINDEX');
    } catch (e) {
      debugPrint('数据库优化失败: $e');
    }
  }

  // ========== 🚀 新增：数据库健康检查 ==========

  /// 执行数据库健康检查
  Future<DatabaseHealthCheck> performHealthCheck() async {
    final stats = await getDatabaseStats();
    final issues = <String>[];
    final recommendations = <String>[];

    // 检查数据库大小
    if (stats.databaseSizeBytes > 100 * 1024 * 1024) { // 100MB
      issues.add('数据库文件过大 (${stats.formattedSize})');
      recommendations.add('考虑清理历史数据或启用数据归档');
    }

    // 检查消息数量
    if (stats.messageCount > 50000) {
      issues.add('消息数量过多 (${stats.messageCount})');
      recommendations.add('建议清理旧消息或设置消息保留期限');
    }

    // 检查对话数量
    if (stats.conversationCount > 1000) {
      issues.add('对话数量过多 (${stats.conversationCount})');
      recommendations.add('建议清理无用对话或设置对话数量限制');
    }

    // 检查最后活动时间
    if (stats.lastActivityAt != null) {
      final daysSinceLastActivity = DateTime.now().difference(stats.lastActivityAt!).inDays;
      if (daysSinceLastActivity > 30) {
        issues.add('数据库长时间未活动 ($daysSinceLastActivity 天)');
        recommendations.add('考虑备份数据并清理过期内容');
      }
    }

    // 检查索引使用情况
    try {
      final indexStats = await _checkIndexUsage();
      if (indexStats.unusedIndexes.isNotEmpty) {
        issues.add('存在未使用的索引: ${indexStats.unusedIndexes.join(', ')}');
        recommendations.add('考虑删除未使用的索引以节省空间');
      }
    } catch (e) {
      // 索引检查失败，忽略
    }

    final isHealthy = issues.isEmpty;

    if (isHealthy) {
      return DatabaseHealthCheck.healthy(stats);
    } else {
      return DatabaseHealthCheck.unhealthy(stats, issues, recommendations);
    }
  }

  /// 检查索引使用情况
  Future<IndexUsageStats> _checkIndexUsage() async {
    final usedIndexes = <String>[];
    final unusedIndexes = <String>[];

    try {
      // 获取所有索引
      final indexes = await customSelect('SELECT name FROM sqlite_master WHERE type = "index" AND name NOT LIKE "sqlite_%"').get();

      for (final index in indexes) {
        final indexName = index.data['name'] as String;

        // 检查索引是否被使用（这是一个简化的检查）
        // 在实际应用中，可能需要更复杂的统计信息
        if (indexName.startsWith('idx_')) {
          usedIndexes.add(indexName);
        } else {
          unusedIndexes.add(indexName);
        }
      }
    } catch (e) {
      // 检查失败，返回空结果
    }

    return IndexUsageStats(
      usedIndexes: usedIndexes,
      unusedIndexes: unusedIndexes,
    );
  }

  // ========== 🚀 新增：外键约束检查 ==========

  /// 检查外键完整性
  Future<void> checkForeignKeyIntegrity() async {
    try {
      final result = await customSelect('PRAGMA foreign_key_check').get();
      if (result.isNotEmpty) {
        debugPrint('发现外键约束违规: ${result.length} 条');
      }
    } catch (e) {
      debugPrint('外键检查失败: $e');
    }
  }
}

/// 索引使用统计
class IndexUsageStats {
  final List<String> usedIndexes;
  final List<String> unusedIndexes;

  IndexUsageStats({
    required this.usedIndexes,
    required this.unusedIndexes,
  });

  int get totalIndexes => usedIndexes.length + unusedIndexes.length;
  double get usageRate => totalIndexes > 0 ? usedIndexes.length / totalIndexes : 0.0;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yumcha.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // 🚀 优化：创建数据库连接并配置性能参数
    final database = NativeDatabase.createInBackground(file, setup: (rawDb) {
      // 启用WAL模式，提升并发性能
      rawDb.execute('PRAGMA journal_mode = WAL;');

      // 设置缓存大小为10MB
      rawDb.execute('PRAGMA cache_size = -10000;');

      // 启用外键约束
      rawDb.execute('PRAGMA foreign_keys = ON;');

      // 设置同步模式为NORMAL，平衡性能和安全性
      rawDb.execute('PRAGMA synchronous = NORMAL;');

      // 设置临时存储在内存中
      rawDb.execute('PRAGMA temp_store = MEMORY;');

      // 设置mmap大小为256MB
      rawDb.execute('PRAGMA mmap_size = 268435456;');

      // 优化查询计划器
      rawDb.execute('PRAGMA optimize;');
    });

    return database;
  });
}
