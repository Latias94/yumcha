import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_status.dart' as msg_status;
import '../../domain/entities/message_block_status.dart';
import '../../domain/services/message_factory.dart';
import '../../../../shared/data/database/database.dart';

/// 消息仓库实现类
class MessageRepositoryImpl implements MessageRepository {
  final AppDatabase _database;
  final _uuid = Uuid();
  final _messageFactory = MessageFactory();

  MessageRepositoryImpl(this._database);

  @override
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    try {
      final messageDataList = await _database.getMessagesByConversation(conversationId);
      final messages = <Message>[];

      for (final messageData in messageDataList) {
        final blocks = await _database.getMessageBlocks(messageData.id);
        final message = _dataToMessage(messageData, blocks);
        messages.add(message);
      }

      return messages;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Message?> getMessage(String id) async {
    try {
      final messageData = await _database.getMessage(id);
      if (messageData == null) return null;

      final blocks = await _database.getMessageBlocks(id);
      return _dataToMessage(messageData, blocks);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createMessage({
    required String conversationId,
    required String role,
    required String assistantId,
    msg_status.MessageStatus status = msg_status.MessageStatus.userSuccess,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) async {
    final messageId = _uuid.v4();
    final now = DateTime.now();

    await _database.insertMessage(MessagesCompanion.insert(
      id: messageId,
      conversationId: conversationId,
      role: role,
      assistantId: assistantId,
      createdAt: now,
      updatedAt: now,
      status: Value(status.name),
      modelId: Value(modelId),
      metadata: Value(metadata != null ? _encodeJson(metadata) : null),
    ));

    return messageId;
  }

  @override
  Future<void> updateMessageStatus(String messageId, msg_status.MessageStatus status) async {
    await _database.updateMessage(messageId, MessagesCompanion(
      status: Value(status.name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> updateMessageMetadata(String messageId, Map<String, dynamic> metadata) async {
    await _database.updateMessage(messageId, MessagesCompanion(
      metadata: Value(_encodeJson(metadata)),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _database.deleteMessage(messageId);
  }

  @override
  Future<List<MessageBlock>> getMessageBlocks(String messageId) async {
    try {
      final blockDataList = await _database.getMessageBlocks(messageId);
      return blockDataList.map(_dataToMessageBlock).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MessageBlock?> getMessageBlock(String blockId) async {
    try {
      final blockData = await _database.getMessageBlock(blockId);
      return blockData != null ? _dataToMessageBlock(blockData) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> addTextBlock({
    required String messageId,
    required String content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.mainText,
      content: content,
      orderIndex: orderIndex,
      status: status,
    );
  }

  @override
  Future<String> addThinkingBlock({
    required String messageId,
    required String content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.thinking,
      content: content,
      orderIndex: orderIndex,
      status: status,
    );
  }

  @override
  Future<String> addImageBlock({
    required String messageId,
    required String imageUrl,
    int orderIndex = 0,
    Map<String, dynamic>? metadata,
  }) async {
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.image,
      content: imageUrl,
      orderIndex: orderIndex,
      metadata: metadata,
    );
  }

  @override
  Future<String> addCodeBlock({
    required String messageId,
    required String code,
    String? language,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    final metadata = language != null ? {'language': language} : null;
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.code,
      content: code,
      orderIndex: orderIndex,
      status: status,
      metadata: metadata,
    );
  }

  @override
  Future<String> addToolBlock({
    required String messageId,
    required String toolName,
    required Map<String, dynamic> arguments,
    String? result,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  }) async {
    final metadata = {
      'toolName': toolName,
      'arguments': arguments,
    };
    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.tool,
      content: result,
      orderIndex: orderIndex,
      status: status,
      metadata: metadata,
    );
  }

  @override
  Future<String> addErrorBlock({
    required String messageId,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? errorDetails,
    int orderIndex = 0,
  }) async {
    final metadata = <String, dynamic>{};
    if (errorCode != null) metadata['errorCode'] = errorCode;
    if (errorDetails != null) metadata['errorDetails'] = errorDetails;

    return await _addBlock(
      messageId: messageId,
      type: MessageBlockType.error,
      content: errorMessage,
      orderIndex: orderIndex,
      status: MessageBlockStatus.error,
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  @override
  Future<void> updateBlockContent(String blockId, String content) async {
    await _database.updateMessageBlock(blockId, MessageBlocksCompanion(
      content: Value(content),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> updateBlockStatus(String blockId, MessageBlockStatus status) async {
    await _database.updateMessageBlock(blockId, MessageBlocksCompanion(
      status: Value(status.name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> appendToTextBlock(String blockId, String content) async {
    final blockData = await _database.getMessageBlock(blockId);
    if (blockData == null) {
      throw Exception('消息块不存在: $blockId');
    }

    final currentContent = blockData.content ?? '';
    final newContent = currentContent + content;

    await _database.updateMessageBlock(blockId, MessageBlocksCompanion(
      content: Value(newContent),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteMessageBlock(String blockId) async {
    await _database.deleteMessageBlock(blockId);
  }

  /// 添加消息块的通用方法
  Future<String> _addBlock({
    required String messageId,
    required MessageBlockType type,
    String? content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
    Map<String, dynamic>? metadata,
  }) async {
    final blockId = _uuid.v4();
    final now = DateTime.now();

    await _database.insertMessageBlock(MessageBlocksCompanion.insert(
      id: blockId,
      messageId: messageId,
      type: type.name,
      createdAt: now,
      updatedAt: now,
      content: Value(content),
      status: Value(status.name),
      orderIndex: Value(orderIndex),
      metadata: Value(metadata != null ? _encodeJson(metadata) : null),
    ));

    // 更新消息的blockIds
    await _updateMessageBlockIds(messageId);

    return blockId;
  }

  /// 更新消息的blockIds字段
  Future<void> _updateMessageBlockIds(String messageId) async {
    final blocks = await _database.getMessageBlocks(messageId);
    final blockIds = blocks.map((block) => block.id).toList();

    await _database.updateMessage(messageId, MessagesCompanion(
      blockIds: Value(blockIds),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> saveMessage(Message message) async {
    // 使用UPSERT操作，避免先查询再插入/更新的模式
    await _upsertMessageWithBlocks(message);
  }

  /// 使用优化的保存策略保存或更新消息及其块
  Future<void> _upsertMessageWithBlocks(Message message) async {
    try {
      // 1. 尝试插入消息，如果失败则更新
      await _upsertMessage(message);

      // 2. 批量处理消息块
      if (message.blocks.isNotEmpty) {
        await _batchUpsertMessageBlocks(message.blocks);
      }
    } catch (e) {
      // 如果优化方式失败，回退到传统方式
      await _fallbackSaveMessage(message);
    }
  }

  /// 单个消息的UPSERT操作
  Future<void> _upsertMessage(Message message) async {
    try {
      // 尝试插入
      await _database.insertMessage(MessagesCompanion.insert(
        id: message.id,
        conversationId: message.conversationId,
        role: message.role,
        assistantId: message.assistantId,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        status: Value(message.status.name),
        modelId: Value(message.modelId),
        metadata: Value(message.metadata != null ? _encodeJson(message.metadata!) : null),
        blockIds: Value(message.blockIds),
      ));
    } catch (e) {
      // 如果插入失败（通常是主键冲突），则更新
      await _database.updateMessage(message.id, MessagesCompanion(
        status: Value(message.status.name),
        updatedAt: Value(message.updatedAt),
        metadata: Value(message.metadata != null ? _encodeJson(message.metadata!) : null),
        blockIds: Value(message.blockIds),
      ));
    }
  }

  /// 批量UPSERT消息块
  Future<void> _batchUpsertMessageBlocks(List<MessageBlock> blocks) async {
    for (final block in blocks) {
      await _upsertMessageBlock(block);
    }
  }

  /// 单个消息块的UPSERT操作
  Future<void> _upsertMessageBlock(MessageBlock block) async {
    try {
      // 尝试插入
      await _database.insertMessageBlock(MessageBlocksCompanion.insert(
        id: block.id,
        messageId: block.messageId,
        type: block.type.name,
        createdAt: block.createdAt,
        updatedAt: block.updatedAt ?? block.createdAt,
        content: Value(block.content),
        status: Value(block.status.name),
        orderIndex: Value(0),
        metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
      ));
    } catch (e) {
      // 如果插入失败（通常是主键冲突），则更新
      await _database.updateMessageBlock(block.id, MessageBlocksCompanion(
        content: Value(block.content),
        status: Value(block.status.name),
        updatedAt: Value(block.updatedAt ?? DateTime.now()),
        metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
      ));
    }
  }

  /// 回退保存方式（兼容性保证）
  Future<void> _fallbackSaveMessage(Message message) async {
    final existingMessage = await _database.getMessage(message.id);
    if (existingMessage != null) {
      await _updateExistingMessage(message);
    } else {
      await _saveMessageToDatabase(message);
    }
  }

  /// 更新已存在的消息（保留用于兼容性）
  Future<void> _updateExistingMessage(Message message) async {
    // 更新消息记录
    await _database.updateMessage(message.id, MessagesCompanion(
      status: Value(message.status.name),
      updatedAt: Value(message.updatedAt),
      metadata: Value(message.metadata != null ? _encodeJson(message.metadata!) : null),
    ));

    // 使用增量更新替代删除重建
    await _incrementalUpdateBlocks(message.id, message.blocks);
  }

  /// 增量更新消息块
  Future<void> _incrementalUpdateBlocks(String messageId, List<MessageBlock> newBlocks) async {
    final existingBlocks = await _database.getMessageBlocks(messageId);
    final existingBlockIds = existingBlocks.map((b) => b.id).toSet();
    final newBlockIds = newBlocks.map((b) => b.id).toSet();

    // 删除不再存在的块
    final blocksToDelete = existingBlockIds.difference(newBlockIds);
    for (final blockId in blocksToDelete) {
      await _database.deleteMessageBlock(blockId);
    }

    // 更新或插入新块
    for (final block in newBlocks) {
      if (existingBlockIds.contains(block.id)) {
        // 更新现有块
        await _database.updateMessageBlock(block.id, MessageBlocksCompanion(
          content: Value(block.content),
          status: Value(block.status.name),
          updatedAt: Value(block.updatedAt ?? DateTime.now()),
          metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
        ));
      } else {
        // 插入新块
        await _database.insertMessageBlock(MessageBlocksCompanion.insert(
          id: block.id,
          messageId: block.messageId,
          type: block.type.name,
          createdAt: block.createdAt,
          updatedAt: block.updatedAt ?? block.createdAt,
          content: Value(block.content),
          status: Value(block.status.name),
          orderIndex: Value(0),
          metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
        ));
      }
    }
  }

  /// 保存完整消息到数据库（包括消息和所有块）
  Future<void> _saveMessageToDatabase(Message message) async {
    // 1. 保存消息
    await _database.insertMessage(MessagesCompanion.insert(
      id: message.id,
      conversationId: message.conversationId,
      role: message.role,
      assistantId: message.assistantId,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      status: Value(message.status.name),
      modelId: Value(message.modelId),
      metadata: Value(message.metadata != null ? _encodeJson(message.metadata!) : null),
      blockIds: Value(message.blockIds),
    ));

    // 2. 保存所有消息块
    for (final block in message.blocks) {
      await _database.insertMessageBlock(MessageBlocksCompanion.insert(
        id: block.id,
        messageId: block.messageId,
        type: block.type.name,
        createdAt: block.createdAt,
        updatedAt: block.updatedAt ?? block.createdAt,
        content: Value(block.content),
        status: Value(block.status.name),
        orderIndex: Value(0), // MessageBlock没有orderIndex字段，使用默认值
        metadata: Value(block.metadata != null ? _encodeJson(block.metadata!) : null),
      ));
    }
  }

  /// 将数据库数据转换为Message实体
  Message _dataToMessage(MessageData data, List<MessageBlockData> blockDataList) {
    final blocks = blockDataList.map(_dataToMessageBlock).toList();
    
    return Message(
      id: data.id,
      conversationId: data.conversationId,
      role: data.role,
      assistantId: data.assistantId,
      blockIds: data.blockIds,
      status: msg_status.MessageStatus.values.firstWhere(
        (s) => s.name == data.status,
        orElse: () => msg_status.MessageStatus.userSuccess,
      ),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      modelId: data.modelId,
      metadata: data.metadata != null ? _decodeJson(data.metadata!) : null,
      blocks: blocks,
    );
  }

  /// 将数据库数据转换为MessageBlock实体
  MessageBlock _dataToMessageBlock(MessageBlockData data) {
    return MessageBlock(
      id: data.id,
      messageId: data.messageId,
      type: MessageBlockType.values.firstWhere(
        (t) => t.name == data.type,
        orElse: () => MessageBlockType.mainText,
      ),
      status: MessageBlockStatus.values.firstWhere(
        (s) => s.name == data.status,
        orElse: () => MessageBlockStatus.success,
      ),
      content: data.content,
      metadata: data.metadata != null ? _decodeJson(data.metadata!) : null,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// JSON编码
  String _encodeJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return '{}';
    }
  }

  /// JSON解码
  Map<String, dynamic> _decodeJson(String json) {
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  // ========== 复合操作 ==========

  @override
  Future<Message> getMessageWithBlocks(String messageId) async {
    final message = await getMessage(messageId);
    if (message == null) {
      throw Exception('消息不存在: $messageId');
    }
    return message;
  }

  @override
  Future<List<Message>> getConversationWithBlocks(String conversationId) async {
    return await getMessagesByConversation(conversationId);
  }

  @override
  Future<Message> createUserMessage({
    required String conversationId,
    required String assistantId,
    required String content,
    List<String>? imageUrls,
  }) async {
    // 使用MessageFactory创建完整的用户消息
    final message = _messageFactory.createUserMessage(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      imageUrls: imageUrls,
    );

    // 保存消息到数据库
    await _saveMessageToDatabase(message);

    return message;
  }

  @override
  Future<Message> createAiMessagePlaceholder({
    required String conversationId,
    required String assistantId,
    String? modelId,
  }) async {
    // 使用MessageFactory创建AI消息占位符
    final message = _messageFactory.createAiMessagePlaceholder(
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
    );

    // 保存消息到数据库
    await _saveMessageToDatabase(message);

    return message;
  }

  @override
  Future<void> completeAiMessage({
    required String messageId,
    required String content,
    String? thinkingContent,
    List<Map<String, dynamic>>? toolCalls,
    Map<String, dynamic>? metadata,
  }) async {
    int orderIndex = 0;

    // 添加思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      await addThinkingBlock(
        messageId: messageId,
        content: thinkingContent,
        orderIndex: orderIndex++,
      );
    }

    // 添加主文本块
    if (content.isNotEmpty) {
      await addTextBlock(
        messageId: messageId,
        content: content,
        orderIndex: orderIndex++,
      );
    }

    // 添加工具调用块
    if (toolCalls != null && toolCalls.isNotEmpty) {
      for (final toolCall in toolCalls) {
        await addToolBlock(
          messageId: messageId,
          toolName: toolCall['name'] as String,
          arguments: toolCall['arguments'] as Map<String, dynamic>,
          result: toolCall['result'] as String?,
          orderIndex: orderIndex++,
        );
      }
    }

    // 更新消息状态和元数据
    await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);
    if (metadata != null) {
      await updateMessageMetadata(messageId, metadata);
    }
  }

  // ========== 流式处理支持 ==========

  /// 流式消息块缓存，避免重复查询数据库
  final Map<String, List<MessageBlock>> _streamingBlocksCache = {};

  /// 流式消息内容缓存，只在内存中更新，不写入数据库
  final Map<String, Map<String, String>> _streamingContentCache = {};

  @override
  Future<void> startStreamingMessage(String messageId) async {
    await updateMessageStatus(messageId, msg_status.MessageStatus.aiProcessing);
    // 初始化流式消息的块缓存和内容缓存
    _streamingBlocksCache[messageId] = [];
    _streamingContentCache[messageId] = {};
  }

  @override
  Future<void> updateStreamingContent({
    required String messageId,
    required String content,
    String? thinkingContent,
  }) async {
    // 🚀 优化：流式过程中只更新内存缓存，不写入数据库
    // 这样可以避免频繁的数据库写入操作

    // 更新内存中的内容缓存
    final contentCache = _streamingContentCache[messageId] ?? {};
    contentCache['mainText'] = content;
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      contentCache['thinking'] = thinkingContent;
    }
    _streamingContentCache[messageId] = contentCache;

    // 获取或创建块缓存
    List<MessageBlock> blocks = _streamingBlocksCache[messageId] ?? [];
    if (blocks.isEmpty) {
      // 如果缓存为空，从数据库加载一次
      blocks = await getMessageBlocks(messageId);
      _streamingBlocksCache[messageId] = blocks;
    }

    // 更新缓存中的块内容（仅内存操作）
    final now = DateTime.now();

    // 更新或创建文本块
    var textBlock = blocks.where((b) => b.type == MessageBlockType.mainText).firstOrNull;
    if (textBlock != null) {
      final index = blocks.indexWhere((b) => b.id == textBlock!.id);
      if (index != -1) {
        blocks[index] = textBlock.copyWith(content: content, updatedAt: now);
      }
    } else {
      // 创建新的文本块（仅在缓存中）
      textBlock = MessageBlock.text(
        id: '${messageId}_text',
        messageId: messageId,
        content: content,
        status: MessageBlockStatus.streaming,
        createdAt: now,
      );
      blocks.add(textBlock);
    }

    // 更新或创建思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      var thinkingBlock = blocks.where((b) => b.type == MessageBlockType.thinking).firstOrNull;
      if (thinkingBlock != null) {
        final index = blocks.indexWhere((b) => b.id == thinkingBlock!.id);
        if (index != -1) {
          blocks[index] = thinkingBlock.copyWith(content: thinkingContent, updatedAt: now);
        }
      } else {
        // 创建新的思考块（仅在缓存中）
        thinkingBlock = MessageBlock.thinking(
          id: '${messageId}_thinking',
          messageId: messageId,
          content: thinkingContent,
          status: MessageBlockStatus.streaming,
          createdAt: now,
        );
        blocks.insert(0, thinkingBlock); // 思考块放在开头
      }
    }

    _streamingBlocksCache[messageId] = blocks;

    // 注意：这里不再写入数据库，只在流式结束时统一写入
  }



  @override
  Future<void> finishStreamingMessage({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    // 🚀 优化：流式结束时一次性将缓存内容写入数据库

    // 获取缓存的块信息
    final cachedBlocks = _streamingBlocksCache[messageId];
    if (cachedBlocks == null || cachedBlocks.isEmpty) {
      // 如果没有缓存，说明没有流式更新，直接更新状态
      await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);
      if (metadata != null) {
        await updateMessageMetadata(messageId, metadata);
      }
      return;
    }

    // 使用事务确保数据一致性
    await _database.transaction(() async {
      // 1. 批量保存或更新所有消息块
      for (final block in cachedBlocks) {
        final finalBlock = block.copyWith(
          status: MessageBlockStatus.success,
          updatedAt: DateTime.now(),
        );
        await _upsertMessageBlock(finalBlock);
      }

      // 2. 更新消息状态
      await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);

      // 3. 更新元数据（如果有）
      if (metadata != null) {
        await updateMessageMetadata(messageId, metadata);
      }

      // 4. 更新消息的blockIds字段
      await _updateMessageBlockIds(messageId);
    });

    // 清理缓存
    _streamingBlocksCache.remove(messageId);
    _streamingContentCache.remove(messageId);
  }

  @override
  Future<void> handleStreamingError({
    required String messageId,
    required String errorMessage,
    String? partialContent,
  }) async {
    final List<Future<void>> operations = [];

    // 添加错误块
    operations.add(addErrorBlock(
      messageId: messageId,
      errorMessage: errorMessage,
      orderIndex: 999, // 错误块放在最后
    ));

    // 如果有部分内容，保留它
    if (partialContent != null && partialContent.isNotEmpty) {
      // 使用缓存的块信息
      final cachedBlocks = _streamingBlocksCache[messageId];
      final blocks = cachedBlocks ?? await getMessageBlocks(messageId);
      final textBlock = blocks.where((b) => b.type == MessageBlockType.mainText).firstOrNull;

      if (textBlock != null) {
        operations.add(updateBlockContent(textBlock.id, partialContent));
        operations.add(updateBlockStatus(textBlock.id, MessageBlockStatus.success));
      }
    }

    // 更新消息状态为错误
    operations.add(updateMessageStatus(messageId, msg_status.MessageStatus.aiError));

    // 并行执行所有操作
    await Future.wait(operations);

    // 清理缓存
    _streamingBlocksCache.remove(messageId);
  }

  // ========== 搜索和查询 ==========

  @override
  Future<List<Message>> searchMessages({
    required String query,
    String? conversationId,
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messages = await _database.searchMessages(
        query,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );

      final result = <Message>[];
      for (final messageData in messages) {
        // 如果指定了对话ID，过滤结果
        if (conversationId != null && messageData.conversationId != conversationId) {
          continue;
        }

        final blocks = await _database.getMessageBlocks(messageData.id);
        final message = _dataToMessage(messageData, blocks);
        result.add(message);
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> getSearchResultCount({
    required String query,
    String? conversationId,
    String? assistantId,
  }) async {
    try {
      return await _database.getSearchResultCount(
        query,
        assistantId: assistantId,
      );
    } catch (e) {
      return 0;
    }
  }

  // ========== 统计和分析 ==========

  @override
  Future<int> getMessageCount(String conversationId) async {
    try {
      final messages = await _database.getMessagesByConversation(conversationId);
      return messages.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Message?> getLastMessage(String conversationId) async {
    try {
      final messageData = await _database.getLastMessageByConversation(conversationId);
      if (messageData == null) return null;

      final blocks = await _database.getMessageBlocks(messageData.id);
      return _dataToMessage(messageData, blocks);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getBlockCount(String messageId) async {
    try {
      final blocks = await _database.getMessageBlocks(messageId);
      return blocks.length;
    } catch (e) {
      return 0;
    }
  }
}
