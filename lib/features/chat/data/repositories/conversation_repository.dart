import 'dart:convert';
import '../../../../shared/data/database/database.dart';
import '../../domain/entities/conversation_ui_state.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/entities/message_block_status.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/repositories/message_repository.dart';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

class ConversationRepository {
  final AppDatabase _database;
  final MessageRepository _messageRepository;
  final _uuid = Uuid();
  final LoggerService _logger = LoggerService();

  ConversationRepository(this._database, this._messageRepository);

  // 获取所有对话
  Future<List<ConversationUiState>> getAllConversations() async {
    final conversationDataList = await _database.getAllConversations();
    final conversations = <ConversationUiState>[];

    for (final conversationData in conversationDataList) {
      final messages = await getMessagesByConversation(conversationData.id);
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
      final messages = await getMessagesByConversation(conversationData.id);
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
        final messages = await getMessagesByConversation(conversationData.id);
        conversations.add(_dataToModel(conversationData, messages));
      } else {
        // 只获取最后一条消息作为预览
        final lastMessage = await _database.getLastMessageByConversation(
          conversationData.id,
        );
        List<Message> previewMessage = [];
        if (lastMessage != null) {
          // 获取消息的内容块
          final blocks = await _database.getMessageBlocks(lastMessage.id);
          final message = _dataToMessage(lastMessage, blocks);
          previewMessage = [message];
        }
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

    final messages = await getMessagesByConversation(id);
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
            ? conversation.messages.first.createdAt
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
                ? conversation.messages.last.createdAt
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

          // 使用MessageRepository统一保存消息
          await _messageRepository.saveMessage(message);
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
                ? conversation.messages.last.createdAt
                : DateTime.now(),
          ),
          updatedAt: Value(DateTime.now()),
        );
        await _database.updateConversation(conversation.id, companion);

        // 获取数据库中现有的消息
        final existingMessages = await getMessagesByConversation(
          conversation.id,
        );

        // 找出新增的消息（基于ID和时间戳比较）
        final newMessages = <Message>[];
        for (final message in conversation.messages) {
          // 跳过空内容的AI消息（流式传输的占位符）
          if (!message.isFromUser && message.content.trim().isEmpty) {
            continue;
          }

          final exists = existingMessages.any(
            (existing) =>
                existing.id == message.id ||
                (existing.content == message.content &&
                existing.role == message.role &&
                existing.createdAt
                        .difference(message.createdAt)
                        .abs()
                        .inSeconds <
                    2), // 2秒内的时间差认为是同一条消息
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

          // 使用MessageRepository统一保存消息
          await _messageRepository.saveMessage(message);
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



  // 获取对话的消息数量
  Future<int> getMessageCountByConversation(String conversationId) async {
    return await _database.getMessageCountByConversation(conversationId);
  }

  // 已移除废弃的addMessage方法 - 请使用MessageRepository.createUserMessage或addBlockMessage



  // 已移除重复的addBlockMessage方法 - 请使用MessageRepository.saveMessage

  // 已移除重复的消息块操作方法 - 请使用MessageRepository中的对应方法

  // 删除消息
  Future<int> deleteMessage(String id) async {
    return await _database.deleteMessage(id);
  }

  // 将数据库模型转换为业务模型
  ConversationUiState _dataToModel(
    ConversationData data,
    List<Message> messages,
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
          // 获取消息的内容块
          final blocks = await _database.getMessageBlocks(messageData.id);

          // 创建Message对象
          final message = _dataToMessage(messageData, blocks);

          results.add(
            MessageSearchResult(
              message: message,
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
        List<Message> previewMessage = [];
        if (lastMessage != null) {
          // 获取消息的内容块
          final blocks = await _database.getMessageBlocks(lastMessage.id);
          final message = _dataToMessage(lastMessage, blocks);
          previewMessage = [message];
        }
        conversations.add(_dataToModel(conversationData, previewMessage));
      }
      return conversations;
    } catch (e) {
      _logger.error('搜索对话标题失败: ${e.toString()}');
      return [];
    }
  }


}

// 搜索结果模型
class MessageSearchResult {
  final Message message;
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
