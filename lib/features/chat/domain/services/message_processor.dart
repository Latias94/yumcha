import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../entities/chat_message_content.dart';
import '../entities/message.dart';

/// 消息处理结果
@immutable
class MessageProcessingResult {
  /// 处理后的文本内容
  final String processedText;
  
  /// 是否成功处理
  final bool success;
  
  /// 错误信息（如果处理失败）
  final String? error;
  
  /// 处理后的附件信息
  final List<ProcessedAttachment>? attachments;
  
  /// 额外的元数据
  final Map<String, dynamic>? metadata;

  const MessageProcessingResult({
    required this.processedText,
    this.success = true,
    this.error,
    this.attachments,
    this.metadata,
  });

  /// 创建成功结果
  factory MessageProcessingResult.success(
    String processedText, {
    List<ProcessedAttachment>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return MessageProcessingResult(
      processedText: processedText,
      success: true,
      attachments: attachments,
      metadata: metadata,
    );
  }

  /// 创建失败结果
  factory MessageProcessingResult.failure(String error) {
    return MessageProcessingResult(
      processedText: '',
      success: false,
      error: error,
    );
  }
}

/// 处理后的附件信息
@immutable
class ProcessedAttachment {
  /// 附件类型
  final String type;
  
  /// 附件ID或URL
  final String reference;
  
  /// 附件名称
  final String name;
  
  /// 附件大小
  final int size;
  
  /// 额外信息
  final Map<String, dynamic>? metadata;

  const ProcessedAttachment({
    required this.type,
    required this.reference,
    required this.name,
    required this.size,
    this.metadata,
  });
}

/// 消息处理器接口
abstract class MessageProcessor {
  /// 处理器名称
  String get name;
  
  /// 处理器描述
  String get description;
  
  /// 支持的内容类型
  List<Type> get supportedContentTypes;
  
  /// 是否支持指定的内容类型
  bool supports(ChatMessageContent content);
  
  /// 处理消息内容
  Future<MessageProcessingResult> process(
    ChatMessageContent content,
    Map<String, dynamic>? params,
  );
}

/// 直接处理器（不做任何处理）
class DirectProcessor implements MessageProcessor {
  @override
  String get name => 'direct';

  @override
  String get description => '直接发送，不做任何预处理';

  @override
  List<Type> get supportedContentTypes => [TextContent];

  @override
  bool supports(ChatMessageContent content) => content is TextContent;

  @override
  Future<MessageProcessingResult> process(
    ChatMessageContent content,
    Map<String, dynamic>? params,
  ) async {
    if (content is TextContent) {
      return MessageProcessingResult.success(content.text);
    }
    return MessageProcessingResult.failure('不支持的内容类型');
  }
}

/// 提示词预处理器
class PromptPreprocessor implements MessageProcessor {
  @override
  String get name => 'prompt_preprocessor';

  @override
  String get description => '将多媒体内容转换为统一的文本提示词';

  @override
  List<Type> get supportedContentTypes => [
    TextContent,
    ImageContent,
    FileContent,
    MixedContent,
  ];

  @override
  bool supports(ChatMessageContent content) => true;

  @override
  Future<MessageProcessingResult> process(
    ChatMessageContent content,
    Map<String, dynamic>? params,
  ) async {
    try {
      String processedText = '';
      List<ProcessedAttachment> attachments = [];

      switch (content) {
        case TextContent textContent:
          processedText = textContent.text;
          break;

        case ImageContent imageContent:
          processedText = _processImageToPrompt(imageContent);
          attachments.add(ProcessedAttachment(
            type: 'image',
            reference: 'embedded',
            name: imageContent.fileName ?? 'image',
            size: imageContent.size,
          ));
          break;

        case FileContent fileContent:
          processedText = _processFileToPrompt(fileContent);
          attachments.add(ProcessedAttachment(
            type: 'file',
            reference: 'embedded',
            name: fileContent.fileName,
            size: fileContent.size,
          ));
          break;

        case MixedContent mixedContent:
          final parts = <String>[];
          
          if (mixedContent.hasText) {
            parts.add(mixedContent.text!);
          }
          
          for (final attachment in mixedContent.attachments) {
            if (attachment is ImageContent) {
              parts.add(_processImageToPrompt(attachment));
              attachments.add(ProcessedAttachment(
                type: 'image',
                reference: 'embedded',
                name: attachment.fileName ?? 'image',
                size: attachment.size,
              ));
            } else if (attachment is FileContent) {
              parts.add(_processFileToPrompt(attachment));
              attachments.add(ProcessedAttachment(
                type: 'file',
                reference: 'embedded',
                name: attachment.fileName,
                size: attachment.size,
              ));
            }
          }
          
          processedText = parts.join('\n\n');
          break;
      }

      return MessageProcessingResult.success(
        processedText,
        attachments: attachments.isNotEmpty ? attachments : null,
      );
    } catch (e) {
      return MessageProcessingResult.failure('预处理失败: $e');
    }
  }

  String _processImageToPrompt(ImageContent image) {
    final parts = <String>[];
    
    parts.add('[图片]');
    
    if (image.fileName != null) {
      parts.add('文件名: ${image.fileName}');
    }
    
    parts.add('大小: ${image.formattedSize}');
    
    if (image.description != null && image.description!.isNotEmpty) {
      parts.add('描述: ${image.description}');
    } else {
      parts.add('请分析这张图片的内容');
    }
    
    return parts.join('\n');
  }

  String _processFileToPrompt(FileContent file) {
    final parts = <String>[];
    
    parts.add('[${file.typeDescription}]');
    parts.add('文件名: ${file.fileName}');
    parts.add('大小: ${file.formattedSize}');
    
    if (file.description != null && file.description!.isNotEmpty) {
      parts.add('描述: ${file.description}');
    } else {
      if (file.isDocument) {
        parts.add('请分析这个文档的内容');
      } else if (file.isAudio) {
        parts.add('请转录这个音频文件');
      } else if (file.isVideo) {
        parts.add('请分析这个视频的内容');
      } else {
        parts.add('请分析这个文件');
      }
    }
    
    return parts.join('\n');
  }
}

/// 多模态处理器
class MultimodalProcessor implements MessageProcessor {
  @override
  String get name => 'multimodal';

  @override
  String get description => '使用多模态AI API处理图片和文件';

  @override
  List<Type> get supportedContentTypes => [
    ImageContent,
    FileContent,
    MixedContent,
  ];

  @override
  bool supports(ChatMessageContent content) {
    return content is ImageContent || 
           content is FileContent || 
           content is MixedContent;
  }

  @override
  Future<MessageProcessingResult> process(
    ChatMessageContent content,
    Map<String, dynamic>? params,
  ) async {
    // TODO: 实现多模态API调用
    // 这里应该调用实际的多模态服务
    return MessageProcessingResult.failure('多模态处理器尚未实现');
  }
}

/// 云上传处理器
class CloudUploadProcessor implements MessageProcessor {
  @override
  String get name => 'cloud_upload';

  @override
  String get description => '上传文件到云服务（如OpenAI文件API）';

  @override
  List<Type> get supportedContentTypes => [FileContent];

  @override
  bool supports(ChatMessageContent content) => content is FileContent;

  @override
  Future<MessageProcessingResult> process(
    ChatMessageContent content,
    Map<String, dynamic>? params,
  ) async {
    if (content is! FileContent) {
      return MessageProcessingResult.failure('只支持文件内容');
    }

    // TODO: 实现云上传逻辑
    // 这里应该调用实际的云上传服务
    return MessageProcessingResult.failure('云上传处理器尚未实现');
  }
}

/// 消息处理器管理器
class MessageProcessorManager {
  final Map<String, MessageProcessor> _processors = {};

  MessageProcessorManager() {
    // 注册默认处理器
    register(DirectProcessor());
    register(PromptPreprocessor());
    register(MultimodalProcessor());
    register(CloudUploadProcessor());
  }

  /// 注册处理器
  void register(MessageProcessor processor) {
    _processors[processor.name] = processor;
  }

  /// 获取处理器
  MessageProcessor? getProcessor(String name) {
    return _processors[name];
  }

  /// 获取支持指定内容的处理器
  List<MessageProcessor> getSupportedProcessors(ChatMessageContent content) {
    return _processors.values
        .where((processor) => processor.supports(content))
        .toList();
  }

  /// 根据策略获取处理器
  MessageProcessor? getProcessorByStrategy(MessageProcessingStrategy strategy) {
    switch (strategy) {
      case MessageProcessingStrategy.direct:
        return getProcessor('direct');
      case MessageProcessingStrategy.preprocessToPrompt:
        return getProcessor('prompt_preprocessor');
      case MessageProcessingStrategy.multimodal:
        return getProcessor('multimodal');
      case MessageProcessingStrategy.cloudUpload:
        return getProcessor('cloud_upload');
      case MessageProcessingStrategy.custom:
        return null; // 需要指定自定义处理器名称
    }
  }

  /// 处理消息请求
  Future<MessageProcessingResult> processRequest(ChatMessageRequest request) async {
    MessageProcessor? processor;

    if (request.strategy == MessageProcessingStrategy.custom) {
      if (request.customProcessor != null) {
        processor = getProcessor(request.customProcessor!);
      }
    } else {
      processor = getProcessorByStrategy(request.strategy);
    }

    if (processor == null) {
      return MessageProcessingResult.failure('找不到合适的处理器');
    }

    if (!processor.supports(request.content)) {
      return MessageProcessingResult.failure('处理器不支持此内容类型');
    }

    return await processor.process(request.content, request.processingParams);
  }
}
