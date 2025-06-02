import '../data/database.dart';
import '../models/conversation_ui_state.dart';
import '../models/message.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../services/logger_service.dart';

class ConversationRepository {
  final AppDatabase _database;
  final _uuid = Uuid();
  final LoggerService _logger = LoggerService();

  ConversationRepository(this._database);

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
    final conversationDataList = await _database
        .getConversationsByAssistantWithPagination(
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
        final previewMessage = lastMessage != null
            ? [_messageDataToModel(lastMessage)]
            : <Message>[];
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

        // 保存所有消息
        for (final message in conversation.messages) {
          await addMessage(
            conversationId: conversation.id,
            content: message.content,
            author: message.author,
            isFromUser: message.isFromUser,
            imageUrl: message.imageUrl,
            avatarUrl: message.avatarUrl,
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
        final existingMessages = await getMessagesByConversation(
          conversation.id,
        );

        // 找出新增的消息（基于时间戳和内容比较）
        final newMessages = <Message>[];
        for (final message in conversation.messages) {
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

        // 只保存新增的消息
        for (final message in newMessages) {
          await _addMessageDirect(
            conversationId: conversation.id,
            content: message.content,
            author: message.author,
            isFromUser: message.isFromUser,
            imageUrl: message.imageUrl,
            avatarUrl: message.avatarUrl,
            timestamp: message.timestamp,
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
  }) async {
    final id = _uuid.v4();
    final now = timestamp ?? DateTime.now();

    final companion = MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      content: Value(content),
      author: Value(author),
      isFromUser: Value(isFromUser),
      imageUrl: Value(imageUrl),
      avatarUrl: Value(avatarUrl),
      timestamp: Value(now),
      createdAt: Value(DateTime.now()),
    );

    await _database.insertMessage(companion);
    return id;
  }

  // 删除对话
  Future<int> deleteConversation(String id) async {
    return await _database.deleteConversation(id);
  }

  // 获取对话的消息
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    final messageDataList = await _database.getMessagesByConversation(
      conversationId,
    );
    return messageDataList.map(_messageDataToModel).toList();
  }

  // 添加消息
  Future<String> addMessage({
    required String conversationId,
    required String content,
    required String author,
    required bool isFromUser,
    String? imageUrl,
    String? avatarUrl,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      content: Value(content),
      author: Value(author),
      isFromUser: Value(isFromUser),
      imageUrl: Value(imageUrl),
      avatarUrl: Value(avatarUrl),
      timestamp: Value(now),
      createdAt: Value(now),
    );

    await _database.insertMessage(companion);

    // 更新对话的最后消息时间
    await _database.updateConversation(
      conversationId,
      ConversationsCompanion(lastMessageAt: Value(now), updatedAt: Value(now)),
    );

    return id;
  }

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

  // 将消息数据库模型转换为业务模型
  Message _messageDataToModel(MessageData data) {
    return Message(
      author: data.author,
      content: data.content,
      timestamp: data.timestamp,
      imageUrl: data.imageUrl,
      avatarUrl: data.avatarUrl,
      isFromUser: data.isFromUser,
    );
  }
}
