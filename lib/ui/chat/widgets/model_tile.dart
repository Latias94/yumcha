import 'package:flutter/material.dart';
import '../../../services/favorite_model_repository.dart';
import '../../../models/ai_assistant.dart';

/// 模型能力枚举
enum ModelCapability {
  chat('聊天'),
  tools('工具'),
  reasoning('思考'),
  vision('视觉'),
  imageGeneration('画图'),
  embedding('嵌入');

  const ModelCapability(this.label);
  final String label;

  IconData get icon {
    switch (this) {
      case ModelCapability.chat:
        return Icons.chat_bubble_outline;
      case ModelCapability.tools:
        return Icons.build_outlined;
      case ModelCapability.reasoning:
        return Icons.psychology_outlined;
      case ModelCapability.vision:
        return Icons.visibility_outlined;
      case ModelCapability.imageGeneration:
        return Icons.image_outlined;
      case ModelCapability.embedding:
        return Icons.storage_outlined;
    }
  }
}

/// 模型列表项组件
class ModelTile extends StatelessWidget {
  const ModelTile({
    super.key,
    required this.assistant,
    required this.isSelected,
    required this.isFavorite,
    required this.favoriteModelRepository,
    required this.onTap,
    this.onFavoriteChanged,
  });

  final AiAssistant assistant;
  final bool isSelected;
  final bool isFavorite;
  final FavoriteModelRepository favoriteModelRepository;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capabilities = _getAssistantCapabilities(assistant);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 选中状态指示器
                if (isSelected)
                  Container(
                    width: 4,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                // 助手头像
                CircleAvatar(
                  backgroundColor: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.8)
                      : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.8,
                        ),
                  child: Text(
                    assistant.avatar,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(width: 12),

                // 助手信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 助手名称
                      Text(
                        assistant.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // 模型名称
                      Text(
                        assistant.modelName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 助手能力
                      _buildCapabilities(context, capabilities),
                    ],
                  ),
                ),

                // 收藏按钮
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFavorite
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                      size: 20,
                    ),
                    onPressed: () async {
                      await favoriteModelRepository.toggleFavoriteModel(
                        assistant.providerId,
                        assistant.modelName,
                      );
                      onFavoriteChanged?.call();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilities(
    BuildContext context,
    List<ModelCapability> capabilities,
  ) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: capabilities.map((capability) {
        // 聊天能力用文字显示
        if (capability == ModelCapability.chat) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.8,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              capability.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          );
        }

        // 其他能力用图标显示
        return Tooltip(
          message: capability.label,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.8,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              capability.icon,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 根据助手配置获取支持的能力
  List<ModelCapability> _getAssistantCapabilities(AiAssistant assistant) {
    final capabilities = <ModelCapability>[];

    // 所有助手都支持聊天
    capabilities.add(ModelCapability.chat);

    // 根据助手配置添加能力
    if (assistant.enableTools) {
      capabilities.add(ModelCapability.tools);
    }

    if (assistant.enableReasoning) {
      capabilities.add(ModelCapability.reasoning);
    }

    if (assistant.enableVision) {
      capabilities.add(ModelCapability.vision);
    }

    if (assistant.enableImageGeneration) {
      capabilities.add(ModelCapability.imageGeneration);
    }

    if (assistant.enableEmbedding) {
      capabilities.add(ModelCapability.embedding);
    }

    return capabilities;
  }
}
