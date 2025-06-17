import '../entities/message.dart';
import '../entities/message_block.dart';
import '../entities/message_status.dart';
import '../entities/message_block_status.dart';

/// 消息仓库接口
/// 
/// 定义消息和消息块的数据访问操作，支持块化消息架构
abstract class MessageRepository {
  // ========== 消息操作 ==========
  
  /// 获取对话的所有消息（包含消息块）
  Future<List<Message>> getMessagesByConversation(String conversationId);
  
  /// 获取单个消息（包含消息块）
  Future<Message?> getMessage(String id);
  
  /// 创建新消息
  Future<String> createMessage({
    required String conversationId,
    required String role,
    required String assistantId,
    MessageStatus status = MessageStatus.userSuccess,
    String? modelId,
    Map<String, dynamic>? metadata,
  });
  
  /// 更新消息状态
  Future<void> updateMessageStatus(String messageId, MessageStatus status);
  
  /// 更新消息元数据
  Future<void> updateMessageMetadata(String messageId, Map<String, dynamic> metadata);
  
  /// 删除消息（级联删除消息块）
  Future<void> deleteMessage(String messageId);

  /// 保存完整消息（包括消息和所有块）
  Future<void> saveMessage(Message message);
  
  // ========== 消息块操作 ==========
  
  /// 获取消息的所有块
  Future<List<MessageBlock>> getMessageBlocks(String messageId);
  
  /// 获取单个消息块
  Future<MessageBlock?> getMessageBlock(String blockId);
  
  /// 添加文本块
  Future<String> addTextBlock({
    required String messageId,
    required String content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  });
  
  /// 添加思考过程块
  Future<String> addThinkingBlock({
    required String messageId,
    required String content,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  });
  
  /// 添加图片块
  Future<String> addImageBlock({
    required String messageId,
    required String imageUrl,
    int orderIndex = 0,
    Map<String, dynamic>? metadata,
  });
  
  /// 添加代码块
  Future<String> addCodeBlock({
    required String messageId,
    required String code,
    String? language,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  });
  
  /// 添加工具调用块
  Future<String> addToolBlock({
    required String messageId,
    required String toolName,
    required Map<String, dynamic> arguments,
    String? result,
    int orderIndex = 0,
    MessageBlockStatus status = MessageBlockStatus.success,
  });
  
  /// 添加错误块
  Future<String> addErrorBlock({
    required String messageId,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? errorDetails,
    int orderIndex = 0,
  });
  
  /// 更新消息块内容
  Future<void> updateBlockContent(String blockId, String content);

  /// 更新消息块状态
  Future<void> updateBlockStatus(String blockId, MessageBlockStatus status);

  /// 删除消息块
  Future<void> deleteMessageBlock(String blockId);
  
  // ========== 复合操作 ==========
  
  /// 获取消息及其所有块
  Future<Message> getMessageWithBlocks(String messageId);
  
  /// 获取对话的所有消息及其块
  Future<List<Message>> getConversationWithBlocks(String conversationId);
  
  /// 创建用户消息（包含文本块）
  Future<Message> createUserMessage({
    required String conversationId,
    required String assistantId,
    required String content,
    List<String>? imageUrls,
  });
  
  /// 创建AI消息占位符
  Future<Message> createAiMessagePlaceholder({
    required String conversationId,
    required String assistantId,
    String? modelId,
  });
  
  /// 完成AI消息（添加内容块并更新状态）
  Future<void> completeAiMessage({
    required String messageId,
    required String content,
    String? thinkingContent,
    List<Map<String, dynamic>>? toolCalls,
    Map<String, dynamic>? metadata,
  });
  
  // ========== 流式处理支持 ==========
  
  /// 开始流式消息处理
  Future<void> startStreamingMessage(String messageId);

  /// 设置流式消息的基本信息
  void setStreamingMessageInfo({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  });

  /// 更新流式消息内容
  Future<void> updateStreamingContent({
    required String messageId,
    required String content,
    String? thinkingContent,
  });

  /// 完成流式消息处理
  Future<void> finishStreamingMessage({
    required String messageId,
    Map<String, dynamic>? metadata,
  });
  
  /// 处理流式消息错误
  Future<void> handleStreamingError({
    required String messageId,
    required String errorMessage,
    String? partialContent,
  });
  
  // ========== 搜索和查询 ==========
  
  /// 搜索消息内容（基于消息块）
  Future<List<Message>> searchMessages({
    required String query,
    String? conversationId,
    String? assistantId,
    int limit = 50,
    int offset = 0,
  });
  
  /// 获取搜索结果数量
  Future<int> getSearchResultCount({
    required String query,
    String? conversationId,
    String? assistantId,
  });
  
  // ========== 统计和分析 ==========
  
  /// 获取对话的消息数量
  Future<int> getMessageCount(String conversationId);
  
  /// 获取对话的最后一条消息
  Future<Message?> getLastMessage(String conversationId);
  
  /// 获取消息的块数量
  Future<int> getBlockCount(String messageId);
}
