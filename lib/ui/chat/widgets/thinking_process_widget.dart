import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

/// 思考过程显示组件
/// 用于显示AI推理模型的思考过程，支持折叠/展开
class ThinkingProcessWidget extends StatefulWidget {
  const ThinkingProcessWidget({
    super.key,
    required this.thinkingContent,
    this.isExpanded = false,
  });

  /// 思考过程内容
  final String thinkingContent;

  /// 是否默认展开
  final bool isExpanded;

  @override
  State<ThinkingProcessWidget> createState() => _ThinkingProcessWidgetState();
}

class _ThinkingProcessWidgetState extends State<ThinkingProcessWidget>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：标题和展开/折叠按钮
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // 思考图标
                  Icon(
                    Icons.psychology,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  
                  // 标题文本
                  Expanded(
                    child: Text(
                      '深度思考过程',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  
                  // 耗时提示（模拟）
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '耗时',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 展开/折叠图标
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 内容区域（可展开/折叠）
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: _buildThinkingContent(context, theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建思考过程内容
  Widget _buildThinkingContent(BuildContext context, ThemeData theme) {
    // 检查内容是否包含markdown语法
    final hasMarkdown = _hasMarkdownSyntax(widget.thinkingContent);
    
    if (!hasMarkdown) {
      // 普通文本显示
      return Text(
        widget.thinkingContent,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 14,
          height: 1.4,
        ),
      );
    }

    try {
      // Markdown渲染
      final config = MarkdownConfig(
        configs: [
          PConfig(
            textStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          H1Config(
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          H2Config(
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          CodeConfig(
            style: TextStyle(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
        ],
      );

      return MarkdownBlock(
        data: widget.thinkingContent,
        config: config,
      );
    } catch (e) {
      // 如果markdown渲染失败，回退到普通文本
      return Text(
        widget.thinkingContent,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 14,
          height: 1.4,
        ),
      );
    }
  }

  /// 检查文本是否包含markdown语法
  bool _hasMarkdownSyntax(String text) {
    final markdownPatterns = [
      RegExp(r'#{1,6}\s'), // 标题
      RegExp(r'\*\*.*\*\*'), // 粗体
      RegExp(r'\*.*\*'), // 斜体
      RegExp(r'`.*`'), // 行内代码
      RegExp(r'```'), // 代码块
      RegExp(r'\[.*\]\(.*\)'), // 链接
      RegExp(r'^[-*+]\s', multiLine: true), // 无序列表
      RegExp(r'^\d+\.\s', multiLine: true), // 有序列表
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(text));
  }
}

/// 思考过程解析工具类
class ThinkingProcessParser {
  /// 从消息内容中提取思考过程和实际回复内容
  static ThinkingProcessResult parseMessage(String content) {
    // 查找 <think>...</think> 标签
    final thinkRegex = RegExp(r'<think>(.*?)</think>', dotAll: true);
    final match = thinkRegex.firstMatch(content);
    
    if (match != null) {
      final thinkingContent = match.group(1)?.trim() ?? '';
      final actualContent = content.replaceAll(thinkRegex, '').trim();
      
      return ThinkingProcessResult(
        hasThinkingProcess: true,
        thinkingContent: thinkingContent,
        actualContent: actualContent,
      );
    }
    
    return ThinkingProcessResult(
      hasThinkingProcess: false,
      thinkingContent: '',
      actualContent: content,
    );
  }
}

/// 思考过程解析结果
class ThinkingProcessResult {
  const ThinkingProcessResult({
    required this.hasThinkingProcess,
    required this.thinkingContent,
    required this.actualContent,
  });

  /// 是否包含思考过程
  final bool hasThinkingProcess;
  
  /// 思考过程内容
  final String thinkingContent;
  
  /// 实际回复内容
  final String actualContent;
}
