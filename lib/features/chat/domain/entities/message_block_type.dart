/// 消息块类型枚举
/// 
/// 定义消息中不同类型的内容块，支持多模态内容
enum MessageBlockType {
  /// 未知类型
  unknown,
  
  /// 主要文本内容
  mainText,
  
  /// 思考过程（Claude、OpenAI-o系列等）
  thinking,
  
  /// 翻译内容
  translation,
  
  /// 图片内容
  image,
  
  /// 代码块
  code,
  
  /// 工具调用
  tool,
  
  /// 文件内容
  file,
  
  /// 错误信息
  error,
  
  /// 引用/搜索结果
  citation,
}

/// 消息块类型扩展方法
extension MessageBlockTypeExtension on MessageBlockType {
  /// 获取类型的显示名称
  String get displayName {
    switch (this) {
      case MessageBlockType.unknown:
        return '未知';
      case MessageBlockType.mainText:
        return '文本';
      case MessageBlockType.thinking:
        return '思考过程';
      case MessageBlockType.translation:
        return '翻译';
      case MessageBlockType.image:
        return '图片';
      case MessageBlockType.code:
        return '代码';
      case MessageBlockType.tool:
        return '工具调用';
      case MessageBlockType.file:
        return '文件';
      case MessageBlockType.error:
        return '错误';
      case MessageBlockType.citation:
        return '引用';
    }
  }

  /// 是否是文本类型的块
  bool get isTextType {
    return this == MessageBlockType.mainText ||
           this == MessageBlockType.thinking ||
           this == MessageBlockType.translation ||
           this == MessageBlockType.code ||
           this == MessageBlockType.error;
  }

  /// 是否是媒体类型的块
  bool get isMediaType {
    return this == MessageBlockType.image ||
           this == MessageBlockType.file;
  }

  /// 是否是交互类型的块
  bool get isInteractiveType {
    return this == MessageBlockType.tool ||
           this == MessageBlockType.citation;
  }

  /// 是否支持编辑
  bool get isEditable {
    return this == MessageBlockType.mainText ||
           this == MessageBlockType.code;
  }

  /// 是否支持复制
  bool get isCopyable {
    return isTextType;
  }

  /// 是否支持删除
  bool get isDeletable {
    return this != MessageBlockType.mainText; // 主文本块通常不能删除
  }
}
