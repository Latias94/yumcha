import 'package:flutter/material.dart';
import '../models/ai_model.dart';
import '../services/notification_service.dart';

class ModelEditDialog extends StatefulWidget {
  final AiModel? model;
  final Function(AiModel) onSave;

  const ModelEditDialog({super.key, this.model, required this.onSave});

  @override
  State<ModelEditDialog> createState() => _ModelEditDialogState();
}

class _ModelEditDialogState extends State<ModelEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _displayNameController;
  late Set<ModelCapability> _selectedCapabilities;
  bool _isEnabled = true;

  bool get _isEditing => widget.model != null;

  @override
  void initState() {
    super.initState();
    final model = widget.model;
    _nameController = TextEditingController(text: model?.name ?? '');
    _displayNameController = TextEditingController(
      text: model?.displayName ?? '',
    );
    _selectedCapabilities = Set.from(
      model?.capabilities ?? [ModelCapability.reasoning],
    );
    _isEnabled = model?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      NotificationService().showWarning('请输入模型名称');
      return;
    }

    final metadata = <String, dynamic>{};

    final now = DateTime.now();
    final model = AiModel(
      id: widget.model?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      capabilities: _selectedCapabilities.toList(),
      metadata: metadata,
      isEnabled: _isEnabled,
      createdAt: widget.model?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSave(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? '编辑模型' : '添加模型'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 模型名称
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '模型名称 *',
                  hintText: '例如: gpt-4, claude-3-sonnet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 显示名称
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: '显示名称',
                  hintText: '用户友好的显示名称（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 支持的功能
              const Text(
                '支持的功能',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ModelCapability.values.map((capability) {
                  final isSelected = _selectedCapabilities.contains(capability);
                  return FilterChip(
                    label: Text(capability.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCapabilities.add(capability);
                        } else {
                          _selectedCapabilities.remove(capability);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 启用状态
              SwitchListTile(
                title: const Text('启用'),
                subtitle: const Text('禁用后此模型将不会出现在模型选择列表中'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _save, child: Text(_isEditing ? '更新' : '添加')),
      ],
    );
  }
}
