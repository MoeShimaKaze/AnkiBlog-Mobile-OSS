import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminTodoListDetailPage extends ConsumerStatefulWidget {
  const AdminTodoListDetailPage({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<AdminTodoListDetailPage> createState() =>
      _AdminTodoListDetailPageState();
}

class _AdminTodoListDetailPageState
    extends ConsumerState<AdminTodoListDetailPage> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(todoListItemsProvider(widget.listId));

    return Scaffold(
      appBar: AppBar(title: const Text('待办列表')),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/admin/todos/create?listId=${widget.listId}'),
        child: const Icon(Icons.add),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('加载失败: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(todoListItemsProvider(widget.listId)),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (todoItems) {
          if (todoItems.isEmpty) {
            return const Center(child: Text('暂无待办'));
          }
          final active = todoItems.where((t) => !t.completed).toList();
          final completed = todoItems.where((t) => t.completed).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(todoListItemsProvider(widget.listId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...active.map(
                  (t) => _TodoItemCard(
                    item: t,
                    onToggle: () => _toggleComplete(t),
                    onToggleImportant: () => _toggleImportant(t),
                    onDelete: () => _deleteItem(t),
                  ),
                ),
                if (completed.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '已完成 (${completed.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...completed.map(
                    (t) => _TodoItemCard(
                      item: t,
                      onToggle: () => _toggleComplete(t),
                      onToggleImportant: () => _toggleImportant(t),
                      onDelete: () => _deleteItem(t),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleComplete(AdminTodoItem item) async {
    final repo = ref.read(adminRepositoryProvider);
    if (item.completed) {
      await repo.uncompleteTodoItem(item.id);
    } else {
      await repo.completeTodoItem(item.id);
    }
    ref.invalidate(todoListItemsProvider(widget.listId));
    ref.invalidate(allActiveItemsProvider);
  }

  Future<void> _toggleImportant(AdminTodoItem item) async {
    await ref.read(adminRepositoryProvider).toggleImportant(item.id);
    ref.invalidate(todoListItemsProvider(widget.listId));
    ref.invalidate(importantItemsProvider);
  }

  Future<void> _deleteItem(AdminTodoItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除待办'),
        content: Text('确定要删除"${item.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminRepositoryProvider).deleteTodoItem(item.id);
      ref.invalidate(todoListItemsProvider(widget.listId));
    }
  }
}

class _TodoItemCard extends StatelessWidget {
  const _TodoItemCard({
    required this.item,
    required this.onToggle,
    required this.onToggleImportant,
    required this.onDelete,
  });

  final AdminTodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onToggleImportant;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                item.completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: item.completed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      decoration: item.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (item.dueDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.dueDate!.substring(0, 10),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (item.steps.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${item.steps.where((s) => s.completed).length}/${item.steps.length} 步骤',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggleImportant,
              child: Icon(
                item.important ? Icons.star : Icons.star_outline,
                color: item.important
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
