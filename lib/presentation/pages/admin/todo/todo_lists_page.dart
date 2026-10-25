import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminTodoListsPage extends ConsumerWidget {
  const AdminTodoListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(todoListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('待办管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todoListsProvider);
          ref.invalidate(myDayItemsProvider);
          ref.invalidate(importantItemsProvider);
          ref.invalidate(plannedItemsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SmartListTile(
              icon: Icons.wb_sunny_outlined,
              label: '我的一天',
              color: Theme.of(context).colorScheme.primary,
              onTap: () => context.push('/admin/todos/smart/my-day'),
            ),
            _SmartListTile(
              icon: Icons.star_outline,
              label: '重要',
              color: Theme.of(context).colorScheme.error,
              onTap: () => context.push('/admin/todos/smart/important'),
            ),
            _SmartListTile(
              icon: Icons.event_outlined,
              label: '计划内',
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () => context.push('/admin/todos/smart/planned'),
            ),
            const SizedBox(height: 16),
            Text(
              '列表',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            AsyncStateView(
              value: lists,
              builder: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('暂无列表，点击右下角创建')),
                  );
                }
                return Column(
                  children: items
                      .map(
                        (list) => _ListTile(
                          list: list,
                          onTap: () =>
                              context.push('/admin/todos/lists/${list.id}'),
                          onDelete: () => _deleteList(context, ref, list),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateListDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建列表'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '列表名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(adminRepositoryProvider).createTodoList(name: name);
      ref.invalidate(todoListsProvider);
    }
  }

  Future<void> _deleteList(
    BuildContext context,
    WidgetRef ref,
    AdminTodoList list,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除列表'),
        content: Text('确定要删除"${list.name}"吗？'),
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
      await ref.read(adminRepositoryProvider).deleteTodoList(list.id);
      ref.invalidate(todoListsProvider);
    }
  }
}

class _SmartListTile extends StatelessWidget {
  const _SmartListTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.list,
    required this.onTap,
    required this.onDelete,
  });

  final AdminTodoList list;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          list.icon != null ? _parseIcon(list.icon!) : Icons.list_outlined,
        ),
        title: Text(list.name),
        subtitle: Text('${list.itemCount} 项'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  IconData _parseIcon(String icon) {
    // Simple icon name mapping
    const iconMap = {
      'list': Icons.list_outlined,
      'home': Icons.home_outlined,
      'work': Icons.work_outlined,
      'school': Icons.school_outlined,
      'shopping': Icons.shopping_cart_outlined,
    };
    return iconMap[icon] ?? Icons.list_outlined;
  }
}
