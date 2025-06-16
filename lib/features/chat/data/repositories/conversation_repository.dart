import 'dart:convert';
import '../../../../shared/data/database/database.dart';
import '../../domain/entities/conversation_ui_state.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/entities/message_block_status.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/legacy_message.dart';
import '../../domain/entities/enhanced_message.dart';
import '../../domain/entities/message_metadata.dart';
import '../../infrastructure/services/enhanced_message_migration_service.dart';

import '../../../../shared/infrastructure/services/media/media_storage_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

class ConversationRepository {
  final AppDatabase _database;
  final _uuid = Uuid();
  final LoggerService _logger = LoggerService();
  final EnhancedMessageMigrationService _migrationService = EnhancedMessageMigrationService();

  ConversationRepository(this._database);

  // 获取所有对话
  Future<List<ConversationUiState>> getAllConversations() async {
    final conversationDataList = await _database.getAllConversations();
    final conversations = <ConversationUiState>[];

    for (final conversationData in conversationDataList) {
      final messages = await getMessagesByConversationLegacy(conversationData.id);
      conversations.add(_dataToModel(conversationData, messages));
    }

    return conversations;
  }

  // 根据助手ID获取对话
  Future<List<ConversationUiState>> getConversationsByAssistant(
    String assistantId,
  ) async {
    final conversationDataList = await _database.getConversationsByAssistant(
      assistantId,
    );
    final conversations = <ConversationUiState>[];

    for (final conversationData in conversationDataList) {
      final messages = await getMessagesByConversationLegacy(conversationData.id);
      conversations.add(_dataToModel(conversationData, messages));
    }

    return conversations;
  }

  // 分页获取指定助手的对话（只获取对话元信息，不包含具体消息）
  Future<List<ConversationUiState>> getConversationsByAssistantWithPagination(
    String assistantId, {
    int limit = 20,
    int offset = 0,
    bool includeMessages = false, // 是否包含消息内容
  }) async {
    final conversationDataList =
        await _database.getConversationsByAssistantWithPagination(
      assistantId,
      limit: limit,
      offset: offset,
    );
    final conversations = <ConversationUiState>[];

    for (final conversationData in conversationDataList) {
      if (includeMessages) {
        // 包含完整消息
        final messages = await getMessagesByConversationLegacy(conversationData.id);
        conversations.add(_dataToModel(conversationData, messages));
      } else {
        // 只获取最后一条消息作为预览
        final lastMessage = await _database.getLastMessageByConversation(
          conversationData.id,
        );
        final previewMessage = lastMessage != null
            ? [_messageDataToModel(lastMessage)]
            : <LegacyMessage>[];
        conversations.add(_dataToModel(conversationData, previewMessage));
      }
    }

    return conversations;
  }

  // 获取指定助手的对话数量
  Future<int> getConversationCountByAssistant(String assistantId) async {
    return await _database.getConversationCountByAssistant(assistantId);
  }

  // 根据ID获取对话
  Future<ConversationUiState?> getConversation(String id) async {
    final conversationData = await _database.getConversation(id);
    if (conversationData == null) return null;

    final messages = await getMessagesByConversationLegacy(id);
    return _dataToModel(conversationData, messages);
  }

  // 创建新对话
  Future<String> createConversation({
    required String title,
    required String assistantId,
    required String providerId,
    String? modelId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      assistantId: Value(assistantId),
      providerId: Value(providerId),
      modelId: Value(modelId),
      lastMessageAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _database.insertConversation(companion);
    return id;
  }

  // 更新对话
  Future<bool> updateConversation(ConversationUiState conversation) async {
    final companion = ConversationsCompanion(
      title: Value(conversation.channelName),
      assistantId: Value(conversation.assistantId ?? ''),
      providerId: Value(conversation.selectedProviderId),
      modelId: Value(conversation.selectedModelId),
      lastMessageAt: Value(
        conversation.messages.isNotEmpty
            ? conversation.messages.first.timestamp
            : DateTime.now(),
      ),
      updatedAt: Value(DateTime.now()),
    );
    _logger.info('更新对话: ${conversation.id}');
    return await _database.updateConversation(conversation.id, companion);
  }

  // 保存对话（创建或更新）
  Future<bool> saveConversation(ConversationUiState conversation) async {
    try {
      // 检查对话是否已存在
      final existingConversation = await _database.getConversation(
        conversation.id,
      );

      if (existingConversation == null) {
        // 创建新对话
        final companion = ConversationsCompanion(
          id: Value(conversation.id),
          title: Value(conversation.channelName),
          assistantId: Value(conversation.assistantId ?? ''),
          providerId: Value(conversation.selectedProviderId),
          modelId: Value(conversation.selectedModelId),
          lastMessageAt: Value(
            conversation.messages.isNotEmpty
                ? conversation.messages.last.timestamp
                : DateTime.now(),
          ),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        await _database.insertConversation(companion);

        // 保存所有消息（跳过不应持久化的消息）
        for (final message in conversation.messages) {
          // 跳过不应持久化的消息（错误、临时、发送中等状态）
          if (!message.shouldPersist) {
            continue;
          }

          // 跳过空内容的AI消息（流式传输的占位符）
          if (!message.isFromUser && message.content.trim().isEmpty) {
            continue;
          }

          await addMessage(
            conversationId: conversation.id,
            content: message.content,
            author: message.author,
            isFromUser: message.isFromUser,
            imageUrl: message.imageUrl,
            avatarUrl: message.avatarUrl,
            duration: message.duration,
            status: message.status,
            errorInfo: message.errorInfo,
          );
        }
        _logger.info('创建新对话: ${conversation.id}');
      } else {
        // 更新现有对话
        final companion = ConversationsCompanion(
          title: Value(conversation.channelName),
          assistantId: Value(conversation.assistantId ?? ''),
          providerId: Value(conversation.selectedProviderId),
          modelId: Value(conversation.selectedModelId),
          lastMessageAt: Value(
            conversation.messages.isNotEmpty
                ? conversation.messages.last.timestamp
                : DateTime.now(),
          ),
          updatedAt: Value(DateTime.now()),
        );
        await _database.updateConversation(conversation.id, companion);

        // 获取数据库中现有的消息
        final existingMessages = await getMessagesByConversationLegacy(
          conversation.id,
        );

        // 找出新增的消息（基于时间戳和内容比较）
        final newMessages = <LegacyMessage>[];
        for (final message in conversation.messages) {
          // 跳过空内容的AI消息（流式传输的占位符）
          if (!message.isFromUser && message.content.trim().isEmpty) {
            continue;
          }

          final exists = existingMessages.any(
            (existing) =>
                existing.content == message.content &&
                existing.author == message.author &&
                existing.isFromUser == message.isFromUser &&
                existing.timestamp
                        .difference(message.timestamp)
                        .abs()
                        .inSeconds <
                    2, // 2秒内的时间差认为是同一条消息
          );
          if (!exists) {
            newMessages.add(message);
          }
        }

        // 只保存新增的消息（且应该持久化的消息）
        for (final message in newMessages) {
          // 跳过不应持久化的消息
          if (!message.shouldPersist) {
            continue;
          }

          await _addMessageDirect(
            conversationId: conversation.id,
            content: message.content,
            author: message.author,
            isFromUser: message.isFromUser,
            imageUrl: message.imageUrl,
            avatarUrl: message.avatarUrl,
            timestamp: message.timestamp,
            duration: message.duration,
            status: message.status,
            errorInfo: message.errorInfo,
          );
        }

        if (newMessages.isNotEmpty) {
          _logger.info('更新对话 ${conversation.id}，新增 ${newMessages.length} 条消息');
        } else {
          _logger.info('更新对话信息: ${conversation.id}');
        }
      }

      return true;
    } catch (e) {
      _logger.error('保存对话失败: $e');
      return false;
    }
  }

  // 私有方法：直接添加消息（不更新对话的最后消息时间）
  Future<String> _addMessageDirect({
    required String conversationId,
    required String content,
    required String author,
    required bool isFromUser,
    String? imageUrl,
    String? avatarUrl,
    DateTime? timestamp,
    Duration? duration,
    LegacyMessageStatus status = LegacyMessageStatus.normal,
    String? errorInfo,
  }) async {
    final id = _uuid.v4();
    final now = timestamp ?? DateTime.now();

    // 使用新的块化架构
    final role = isFromUser ? 'user' : 'assistant';
    final companion = MessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      role: role,
      assistantId: '', // 旧数据中没有assistantId，使用空字符串
      createdAt: now,
      updatedAt: now,
      status: Value(_convertLegacyStatusToMessageStatus(status).name),
      metadata: Value(errorInfo != null ? jsonEncode({'errorInfo': errorInfo}) : null),
    );

    await _database.insertMessage(companion);

    // 如果有内容，创建主文本块
    if (content.isNotEmpty) {
      await _database.insertMessageBlock(MessageBlocksCompanion.insert(
        id: '${id}_main',
        messageId: id,
        type: 'mainText',
        createdAt: now,
        updatedAt: now,
        content: Value(content),
        orderIndex: Value(0),
      ));
    }

    return id;
  }

  /// 将LegacyMessageStatus转换为MessageStatus
  MessageStatus _convertLegacyStatusToMessageStatus(LegacyMessageStatus legacyStatus) {
    switch (legacyStatus) {
      case LegacyMessageStatus.normal:
        return MessageStatus.userSuccess; // 默认为用户成功状态
      case LegacyMessageStatus.sending:
        return MessageStatus.aiPending;
      case LegacyMessageStatus.streaming:
        return MessageStatus.aiProcessing;
      case LegacyMessageStatus.error:
      case LegacyMessageStatus.failed:
        return MessageStatus.aiError;
      case LegacyMessageStatus.system:
        return MessageStatus.system;
      case LegacyMessageStatus.temporary:
        return MessageStatus.temporary;
      case LegacyMessageStatus.regenerating:
        return MessageStatus.aiProcessing;
    }
  }

  // 删除对话
  Future<int> deleteConversation(String id) async {
    return await _database.deleteConversation(id);
  }

  // 获取对话的消息（返回新的块化消息）
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    final messageDataList = await _database.getMessagesByConversation(conversationId);
    final messages = <Message>[];

    for (final messageData in messageDataList) {
      final blocks = await _database.getMessageBlocks(messageData.id);
      final message = _dataToMessage(messageData, blocks);
      messages.add(message);
    }

    return messages;
  }

  // 获取对话的消息（兼容性方法，返回LegacyMessage）
  Future<List<LegacyMessage>> getMessagesByConversationLegacy(String conversationId) async {
    final messageDataList = await _database.getMessagesByConversation(
      conversationId,
    );
    return messageDataList.map(_messageDataToModel).toList();
  }

  // 获取对话的消息数量
  Future<int> getMessageCountByConversation(String conversationId) async {
    return await _database.getMessageCountByConversation(conversationId);
  }

  // 添加消息
  Future<String> addMessage({
    String? id, // 可选的ID参数，如果不提供则自动生成
    required String conversationId,
    required String content,
    required String author,
    required bool isFromUser,
    String? imageUrl,
    String? avatarUrl,
    Duration? duration,
    LegacyMessageStatus status = LegacyMessageStatus.normal,
    String? errorInfo,
    List<dynamic>? mediaFiles, // 简化类型，避免导入问题
  }) async {
    final messageId = id ?? _uuid.v4(); // 使用传入的ID或生成新ID
    final now = DateTime.now();

    // 使用新的块化架构
    final role = isFromUser ? 'user' : 'assistant';

    // 构建元数据
    Map<String, dynamic>? metadata;
    if (errorInfo != null || duration != null || imageUrl != null || avatarUrl != null) {
      metadata = <String, dynamic>{};
      if (errorInfo != null) metadata['errorInfo'] = errorInfo;
      if (duration != null) metadata['duration'] = duration.inMilliseconds;
      if (imageUrl != null) metadata['imageUrl'] = imageUrl;
      if (avatarUrl != null) metadata['avatarUrl'] = avatarUrl;
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        metadata['mediaFiles'] = mediaFiles;
      }
    }

    final companion = MessagesCompanion.insert(
      id: messageId,
      conversationId: conversationId,
      role: role,
      assistantId: '', // 旧数据中没有assistantId，使用空字符串
      createdAt: now,
      updatedAt: now,
      status: Value(_convertLegacyStatusToMessageStatus(status).name),
      metadata: Value(metadata != null ? jsonEncode(metadata) : null),
    );

    await _database.insertMessage(companion);

    // 如果有内容，创建主文本块
    if (content.isNotEmpty) {
      await _database.insertMessageBlock(MessageBlocksCompanion.insert(
        id: '${messageId}_main',
        messageId: messageId,
        type: 'mainText',
        createdAt: now,
        updatedAt: now,
        content: Value(content),
        orderIndex: Value(0),
      ));
    }

    // 更新对话的最后消息时间
    await _database.updateConversation(
      conversationId,
      ConversationsCompanion(lastMessageAt: Value(now), updatedAt: Value(now)),
    );

    return messageId;
  }

  // 添加增强消息（包含多媒体内容）- 使用迁移服务转换为块化消息
  Future<String> addEnhancedMessage({
    String? id,
    required String conversationId,
    required EnhancedMessage message,
  }) async {
    // 使用迁移服务将 EnhancedMessage 转换为块化消息
    final blockMessage = _migrationService.convertToBlockMessage(message);

    // 添加块化消息
    return await addBlockMessage(
      id: id ?? message.id,
      conversationId: conversationId,
      message: blockMessage,
    );
  }

  // 添加块化消息
  Future<String> addBlockMessage({
    String? id,
    required String conversationId,
    required Message message,
  }) async {
    final messageId = id ?? message.id;
    final now = DateTime.now();

    // 插入消息记录
    final companion = MessagesCompanion.insert(
      id: messageId,
      conversationId: conversationId,
      role: message.role,
      assistantId: message.assistantId,
      createdAt: now,
      updatedAt: now,
      status: Value(message.status.name),
      modelId: Value(message.modelId),
      metadata: Value(message.metadata != null ? jsonEncode(message.metadata) : null),
    );

    await _database.insertMessage(companion);

    // 插入消息块
    for (int i = 0; i < message.blocks.length; i++) {
      final block = message.blocks[i];
      await _database.insertMessageBlock(MessageBlocksCompanion.insert(
        id: block.id,
        messageId: messageId,
        type: block.type.name,
        createdAt: block.createdAt,
        updatedAt: block.updatedAt ?? block.createdAt,
        content: Value(block.content),
        status: Value(block.status.name),
        orderIndex: Value(i),
        metadata: Value(block.metadata != null ? jsonEncode(block.metadata) : null),
      ));
    }

    // 更新对话的最后消息时间
    await _database.updateConversation(
      conversationId,
      ConversationsCompanion(lastMessageAt: Value(now), updatedAt: Value(now)),
    );

    return messageId;
  }

  // 更新块化消息
  Future<bool> updateBlockMessage({
    required String messageId,
    required Message updatedMessage,
  }) async {
    try {
      final now = DateTime.now();

      // 更新消息记录
      final messageCompanion = MessagesCompanion(
        status: Value(updatedMessage.status.name),
        updatedAt: Value(now),
        metadata: Value(updatedMessage.metadata != null ? jsonEncode(updatedMessage.metadata) : null),
      );

      await _database.updateMessage(messageId, messageCompanion);

      // 删除旧的消息块
      final existingBlocks = await _database.getMessageBlocks(messageId);
      for (final block in existingBlocks) {
        await _database.deleteMessageBlock(block.id);
      }

      // 插入新的消息块
      for (int i = 0; i < updatedMessage.blocks.length; i++) {
        final block = updatedMessage.blocks[i];
        await _database.insertMessageBlock(MessageBlocksCompanion.insert(
          id: block.id,
          messageId: messageId,
          type: block.type.name,
          createdAt: block.createdAt,
          updatedAt: block.updatedAt ?? now,
          content: Value(block.content),
          status: Value(block.status.name),
          orderIndex: Value(i),
          metadata: Value(block.metadata != null ? jsonEncode(block.metadata) : null),
        ));
      }

      _logger.info('更新块化消息成功', {
        'messageId': messageId,
        'blocksCount': updatedMessage.blocks.length,
      });

      return true;
    } catch (e) {
      _logger.error('更新块化消息失败: $e');
      return false;
    }
  }

  // 更新单个消息块
  Future<bool> updateMessageBlock({
    required String blockId,
    required MessageBlock updatedBlock,
  }) async {
    try {
      final companion = MessageBlocksCompanion(
        type: Value(updatedBlock.type.name),
        status: Value(updatedBlock.status.name),
        content: Value(updatedBlock.content),
        updatedAt: Value(DateTime.now()),
        metadata: Value(updatedBlock.metadata != null ? jsonEncode(updatedBlock.metadata) : null),
      );

      await _database.updateMessageBlock(blockId, companion);

      _logger.info('更新消息块成功', {
        'blockId': blockId,
        'type': updatedBlock.type.name,
      });

      return true;
    } catch (e) {
      _logger.error('更新消息块失败: $e');
      return false;
    }
  }

  // 删除消息块
  Future<bool> deleteMessageBlock(String blockId) async {
    try {
      await _database.deleteMessageBlock(blockId);
      _logger.info('删除消息块成功', {'blockId': blockId});
      return true;
    } catch (e) {
      _logger.error('删除消息块失败: $e');
      return false;
    }
  }

  // 获取单个消息块
  Future<MessageBlock?> getMessageBlock(String blockId) async {
    try {
      final blockData = await _database.getMessageBlock(blockId);
      if (blockData != null) {
        return _blockDataToBlock(blockData);
      }
      return null;
    } catch (e) {
      _logger.error('获取消息块失败: $e');
      return null;
    }
  }

  // 删除消息
  Future<int> deleteMessage(String id) async {
    return await _database.deleteMessage(id);
  }

  // 将数据库模型转换为业务模型
  ConversationUiState _dataToModel(
    ConversationData data,
    List<LegacyMessage> messages,
  ) {
    return ConversationUiState(
      id: data.id,
      channelName: data.title,
      channelMembers: 1, // 默认为1，因为是AI对话
      messages: messages,
      assistantId: data.assistantId,
      selectedProviderId: data.providerId,
      selectedModelId: data.modelId,
    );
  }

  // 将数据库数据转换为新的块化消息
  Message _dataToMessage(MessageData messageData, List<MessageBlockData> blockDataList) {
    final blocks = blockDataList.map((blockData) => _blockDataToBlock(blockData)).toList();

    // 解析消息状态
    MessageStatus status;
    try {
      status = MessageStatus.values.firstWhere(
        (s) => s.name == messageData.status,
        orElse: () => MessageStatus.userSuccess,
      );
    } catch (e) {
      status = MessageStatus.userSuccess;
    }

    // 解析元数据
    Map<String, dynamic>? metadata;
    if (messageData.metadata != null) {
      try {
        metadata = jsonDecode(messageData.metadata!);
      } catch (e) {
        _logger.warning('解析消息元数据失败: $e');
      }
    }

    return Message(
      id: messageData.id,
      conversationId: messageData.conversationId,
      role: messageData.role,
      assistantId: messageData.assistantId,
      blockIds: blocks.map((block) => block.id).toList(),
      blocks: blocks,
      status: status,
      createdAt: messageData.createdAt,
      updatedAt: messageData.updatedAt,
      modelId: messageData.modelId,
      metadata: metadata,
    );
  }

  // 将数据库块数据转换为消息块
  MessageBlock _blockDataToBlock(MessageBlockData blockData) {
    // 解析块类型
    MessageBlockType type;
    try {
      type = MessageBlockType.values.firstWhere(
        (t) => t.name == blockData.type,
        orElse: () => MessageBlockType.unknown,
      );
    } catch (e) {
      type = MessageBlockType.unknown;
    }

    // 解析块状态
    MessageBlockStatus status;
    try {
      status = MessageBlockStatus.values.firstWhere(
        (s) => s.name == blockData.status,
        orElse: () => MessageBlockStatus.success,
      );
    } catch (e) {
      status = MessageBlockStatus.success;
    }

    // 解析元数据
    Map<String, dynamic>? metadata;
    if (blockData.metadata != null) {
      try {
        metadata = jsonDecode(blockData.metadata!);
      } catch (e) {
        _logger.warning('解析消息块元数据失败: $e');
      }
    }

    return MessageBlock(
      id: blockData.id,
      messageId: blockData.messageId,
      type: type,
      status: status,
      createdAt: blockData.createdAt,
      updatedAt: blockData.updatedAt,
      content: blockData.content,
      metadata: metadata,
    );
  }

  // 搜索消息
  Future<List<MessageSearchResult>> searchMessages(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messageDataList = await _database.searchMessages(
        query,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );

      final results = <MessageSearchResult>[];
      for (final messageData in messageDataList) {
        // 获取对应的对话信息
        final conversationData = await _database.getConversation(
          messageData.conversationId,
        );
        if (conversationData != null) {
          results.add(
            MessageSearchResult(
              message: _messageDataToModel(messageData),
              conversationId: messageData.conversationId,
              conversationTitle: conversationData.title,
              assistantId: conversationData.assistantId,
            ),
          );
        }
      }
      return results;
    } catch (e) {
      _logger.error('搜索消息失败: ${e.toString()}');
      return [];
    }
  }

  // 获取搜索结果数量
  Future<int> getSearchResultCount(String query, {String? assistantId}) async {
    try {
      return await _database.getSearchResultCount(
        query,
        assistantId: assistantId,
      );
    } catch (e) {
      _logger.error('获取搜索结果数量失败: ${e.toString()}');
      return 0;
    }
  }

  // 搜索对话标题
  Future<List<ConversationUiState>> searchConversationsByTitle(
    String query, {
    String? assistantId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final conversationDataList = await _database.searchConversationsByTitle(
        query,
        assistantId: assistantId,
        limit: limit,
        offset: offset,
      );

      final conversations = <ConversationUiState>[];
      for (final conversationData in conversationDataList) {
        // 只获取最后一条消息作为预览
        final lastMessage = await _database.getLastMessageByConversation(
          conversationData.id,
        );
        final previewMessage = lastMessage != null
            ? [_messageDataToModel(lastMessage)]
            : <LegacyMessage>[];
        conversations.add(_dataToModel(conversationData, previewMessage));
      }
      return conversations;
    } catch (e) {
      _logger.error('搜索对话标题失败: ${e.toString()}');
      return [];
    }
  }

  // 将消息数据库模型转换为业务模型
  LegacyMessage _messageDataToModel(MessageData data) {
    // 解析元数据
    MessageMetadata? metadata;
    if (data.metadata != null) {
      try {
        metadata = MessageMetadata.fromJsonString(data.metadata!);
      } catch (e) {
        // 如果解析失败，忽略元数据
        _logger.warning('解析消息元数据失败: $e');
      }
    }

    // 解析多媒体元数据
    List<MediaMetadata> mediaFiles = [];
    try {
      final mediaMetadataJson = data.toJson()['mediaMetadata'] as String?;
      if (mediaMetadataJson != null) {
        mediaFiles = EnhancedMessage.parseMediaMetadata(mediaMetadataJson);
      }
    } catch (e) {
      // 向后兼容：如果字段不存在或解析失败，忽略
      _logger.debug('解析多媒体元数据失败: $e');
    }

    // 解析消息状态
    LegacyMessageStatus status = LegacyMessageStatus.normal;
    try {
      // 尝试从数据库字段解析状态，如果字段不存在则使用默认值
      final statusString = data.toJson()['status'] as String?;
      if (statusString != null) {
        status = LegacyMessageStatus.values.firstWhere(
          (s) => s.name == statusString,
          orElse: () => LegacyMessageStatus.normal,
        );
      }
    } catch (e) {
      // 向后兼容：如果解析失败，使用默认状态
      _logger.debug('解析消息状态失败，使用默认状态: $e');
    }

    // 获取错误信息
    String? errorInfo;
    try {
      errorInfo = data.toJson()['errorInfo'] as String?;
    } catch (e) {
      // 向后兼容：如果字段不存在，忽略
      _logger.debug('获取错误信息失败: $e');
    }

    // 如果有多媒体文件，返回EnhancedMessage，否则返回普通Message
    if (mediaFiles.isNotEmpty) {
      return EnhancedMessage(
        id: data.toJson()['id'] as String?,
        author: data.toJson()['author'] as String? ?? 'Unknown',
        content: data.toJson()['content'] as String? ?? '',
        timestamp: data.toJson()['timestamp'] as DateTime? ?? DateTime.now(),
        imageUrl: data.toJson()['imageUrl'] as String?,
        avatarUrl: data.toJson()['avatarUrl'] as String?,
        isFromUser: data.toJson()['isFromUser'] as bool? ?? false,
        metadata: metadata,
        parentMessageId: data.toJson()['parentMessageId'] as String?,
        version: data.toJson()['version'] as int? ?? 1,
        isActive: data.toJson()['isActive'] as bool? ?? true,
        status: status,
        errorInfo: errorInfo,
        mediaFiles: mediaFiles,
        // 向后兼容：如果没有元数据但有总耗时，使用总耗时
        duration: metadata?.totalDurationMs != null
            ? Duration(milliseconds: metadata!.totalDurationMs!)
            : null,
      );
    } else {
      return LegacyMessage(
        id: data.toJson()['id'] as String?,
        author: data.toJson()['author'] as String? ?? 'Unknown',
        content: data.toJson()['content'] as String? ?? '',
        timestamp: data.toJson()['timestamp'] as DateTime? ?? DateTime.now(),
        imageUrl: data.toJson()['imageUrl'] as String?,
        avatarUrl: data.toJson()['avatarUrl'] as String?,
        isFromUser: data.toJson()['isFromUser'] as bool? ?? false,
        metadata: metadata,
        parentMessageId: data.toJson()['parentMessageId'] as String?,
        version: data.toJson()['version'] as int? ?? 1,
        isActive: data.toJson()['isActive'] as bool? ?? true,
        status: status,
        errorInfo: errorInfo,
        // 向后兼容：如果没有元数据但有总耗时，使用总耗时
        duration: metadata?.totalDurationMs != null
            ? Duration(milliseconds: metadata!.totalDurationMs!)
            : null,
      );
    }
  }
}

// 搜索结果模型
class MessageSearchResult {
  final LegacyMessage message;
  final String conversationId;
  final String conversationTitle;
  final String assistantId;

  const MessageSearchResult({
    required this.message,
    required this.conversationId,
    required this.conversationTitle,
    required this.assistantId,
  });
}
