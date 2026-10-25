import 'package:ankiblog_mobile/data/models/public_content.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(publicTodosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('待办清单')),
      body: AsyncStateView(
        value: todos,
        builder: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('暂无待办'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _TodoTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({required this.item});

  final PublicTodo item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassContainer(
      child: Row(
        children: [
          Icon(
            item.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.completed
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.completed ? colorScheme.onSurfaceVariant : null,
                  ),
                ),
                if (item.listName != null && item.listName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.listName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.stepCount > 0) ...[
            const SizedBox(width: 8),
            Text(
              '${item.completedStepCount}/${item.stepCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (item.priority != null && item.priority!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _priorityColor(
                  item.priority!,
                  colorScheme,
                ).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.priority!,
                style: TextStyle(
                  fontSize: 11,
                  color: _priorityColor(item.priority!, colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _priorityColor(String priority, ColorScheme scheme) {
    switch (priority.toLowerCase()) {
      case 'high':
      case '高':
        return scheme.error;
      case 'medium':
      case '中':
        return scheme.tertiary;
      default:
        return scheme.onSurfaceVariant;
    }
  }
}
