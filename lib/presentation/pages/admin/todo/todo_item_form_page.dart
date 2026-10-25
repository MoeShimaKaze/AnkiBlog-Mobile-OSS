import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminTodoItemFormPage extends ConsumerStatefulWidget {
  const AdminTodoItemFormPage({super.key, this.listId});

  final String? listId;

  @override
  ConsumerState<AdminTodoItemFormPage> createState() =>
      _AdminTodoItemFormPageState();
}

class _AdminTodoItemFormPageState extends ConsumerState<AdminTodoItemFormPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _dueDate;
  bool _isMyDay = false;
  bool _isImportant = false;
  String? _selectedListId;
  final List<String> _steps = [];
  final _stepController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.listId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _addStep() {
    final text = _stepController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _steps.add(text);
        _stepController.clear();
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入标题')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .createTodoItem(
            title: title,
            listId: _selectedListId,
            note: _noteController.text.isEmpty ? null : _noteController.text,
            dueDate: _dueDate?.toIso8601String().substring(0, 10),
            isMyDay: _isMyDay,
            isImportant: _isImportant,
            steps: _steps,
          );
      // Invalidate related providers
      ref.invalidate(allActiveItemsProvider);
      ref.invalidate(myDayItemsProvider);
      ref.invalidate(importantItemsProvider);
      ref.invalidate(plannedItemsProvider);
      if (_selectedListId != null) {
        ref.invalidate(todoListItemsProvider(_selectedListId!));
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(todoListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('新建待办'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '截止日期',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                child: Text(
                  _dueDate != null
                      ? DateFormat('yy/MM/dd').format(_dueDate!)
                      : '选择日期',
                  style: _dueDate == null
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            lists.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (listItems) {
                if (listItems.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String>(
                  initialValue: _selectedListId,
                  decoration: const InputDecoration(
                    labelText: '所属列表',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.list),
                  ),
                  items: listItems
                      .map(
                        (l) =>
                            DropdownMenuItem(value: l.id, child: Text(l.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedListId = v),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilterChip(
                  label: const Text('我的一天'),
                  selected: _isMyDay,
                  onSelected: (v) => setState(() => _isMyDay = v),
                  avatar: Icon(
                    Icons.wb_sunny_outlined,
                    size: 18,
                    color: _isMyDay
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('重要'),
                  selected: _isImportant,
                  onSelected: (v) => setState(() => _isImportant = v),
                  avatar: Icon(
                    _isImportant ? Icons.star : Icons.star_outline,
                    size: 18,
                    color: _isImportant
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '步骤',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.value)),
                    GestureDetector(
                      onTap: () {
                        setState(() => _steps.removeAt(entry.key));
                      },
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: const InputDecoration(
                      hintText: '添加步骤...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addStep(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addStep,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
