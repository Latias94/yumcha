import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_status.dart' as msg_status;
import '../../domain/entities/message_block_status.dart';
import '../../../../shared/data/database/database.dart';

/// 消息仓库实现类
class MessageRepositoryImpl implements MessageRepository {
  final AppDatabase _database;
  final _uuid = Uuid();

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
    final messageId = await createMessage(
      conversationId: conversationId,
      role: 'user',
      assistantId: assistantId,
      status: msg_status.MessageStatus.userSuccess,
    );

    // 添加文本块
    await addTextBlock(
      messageId: messageId,
      content: content,
      orderIndex: 0,
    );

    // 添加图片块
    if (imageUrls != null && imageUrls.isNotEmpty) {
      for (int i = 0; i < imageUrls.length; i++) {
        await addImageBlock(
          messageId: messageId,
          imageUrl: imageUrls[i],
          orderIndex: i + 1,
        );
      }
    }

    return await getMessageWithBlocks(messageId);
  }

  @override
  Future<Message> createAiMessagePlaceholder({
    required String conversationId,
    required String assistantId,
    String? modelId,
  }) async {
    final messageId = await createMessage(
      conversationId: conversationId,
      role: 'assistant',
      assistantId: assistantId,
      status: msg_status.MessageStatus.aiProcessing,
      modelId: modelId,
    );

    return await getMessageWithBlocks(messageId);
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

  @override
  Future<void> startStreamingMessage(String messageId) async {
    await updateMessageStatus(messageId, msg_status.MessageStatus.aiProcessing);
  }

  @override
  Future<void> updateStreamingContent({
    required String messageId,
    required String content,
    String? thinkingContent,
  }) async {
    // 获取现有的文本块
    final blocks = await getMessageBlocks(messageId);
    final textBlock = blocks.where((b) => b.type == MessageBlockType.mainText).firstOrNull;
    final thinkingBlock = blocks.where((b) => b.type == MessageBlockType.thinking).firstOrNull;

    // 更新或创建文本块
    if (textBlock != null) {
      await updateBlockContent(textBlock.id, content);
    } else {
      await addTextBlock(
        messageId: messageId,
        content: content,
        orderIndex: thinkingContent != null ? 1 : 0,
        status: MessageBlockStatus.streaming,
      );
    }

    // 更新或创建思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      if (thinkingBlock != null) {
        await updateBlockContent(thinkingBlock.id, thinkingContent);
      } else {
        await addThinkingBlock(
          messageId: messageId,
          content: thinkingContent,
          orderIndex: 0,
          status: MessageBlockStatus.streaming,
        );
      }
    }
  }

  @override
  Future<void> finishStreamingMessage({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    // 更新所有块的状态为成功
    final blocks = await getMessageBlocks(messageId);
    for (final block in blocks) {
      if (block.status == MessageBlockStatus.streaming) {
        await updateBlockStatus(block.id, MessageBlockStatus.success);
      }
    }

    // 更新消息状态
    await updateMessageStatus(messageId, msg_status.MessageStatus.aiSuccess);

    // 更新元数据
    if (metadata != null) {
      await updateMessageMetadata(messageId, metadata);
    }
  }

  @override
  Future<void> handleStreamingError({
    required String messageId,
    required String errorMessage,
    String? partialContent,
  }) async {
    // 添加错误块
    await addErrorBlock(
      messageId: messageId,
      errorMessage: errorMessage,
      orderIndex: 999, // 错误块放在最后
    );

    // 如果有部分内容，保留它
    if (partialContent != null && partialContent.isNotEmpty) {
      final blocks = await getMessageBlocks(messageId);
      final textBlock = blocks.where((b) => b.type == MessageBlockType.mainText).firstOrNull;

      if (textBlock != null) {
        await updateBlockContent(textBlock.id, partialContent);
        await updateBlockStatus(textBlock.id, MessageBlockStatus.success);
      }
    }

    // 更新消息状态为错误
    await updateMessageStatus(messageId, msg_status.MessageStatus.aiError);
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
