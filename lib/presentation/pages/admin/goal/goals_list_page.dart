import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminGoalsListPage extends ConsumerStatefulWidget {
  const AdminGoalsListPage({super.key});

  @override
  ConsumerState<AdminGoalsListPage> createState() => _AdminGoalsListPageState();
}

class _AdminGoalsListPageState extends ConsumerState<AdminGoalsListPage> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(adminGoalsProvider(_statusFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('打卡目标'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('全部')),
              const PopupMenuItem(value: 'ACTIVE', child: Text('进行中')),
              const PopupMenuItem(value: 'PAUSED', child: Text('已暂停')),
              const PopupMenuItem(value: 'COMPLETED', child: Text('已完成')),
              const PopupMenuItem(value: 'ARCHIVED', child: Text('已归档')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/goals/create'),
        child: const Icon(Icons.add),
      ),
      body: AsyncStateView(
        value: goals,
        builder: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(_statusFilter != null ? '无匹配目标' : '暂无打卡目标'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(adminGoalsProvider(_statusFilter)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _GoalCard(goal: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final AdminGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (goal.status) {
      'ACTIVE' => Theme.of(context).colorScheme.primary,
      'PAUSED' => Theme.of(context).colorScheme.error,
      'COMPLETED' => Theme.of(context).colorScheme.tertiary,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    final statusLabel = switch (goal.status) {
      'ACTIVE' => '进行中',
      'PAUSED' => '已暂停',
      'COMPLETED' => '已完成',
      'ARCHIVED' => '已归档',
      _ => goal.status ?? '',
    };

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/admin/goals/${goal.id}'),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                goal.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: '连续', value: '${goal.currentStreak}天'),
                _Stat(label: '最长', value: '${goal.longestStreak}天'),
                _Stat(label: '总打卡', value: '${goal.totalCheckIns}次'),
                _Stat(label: '本月', value: '${goal.thisMonthCheckIns}次'),
              ],
            ),
            if (goal.status == 'ACTIVE') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _doCheckIn(context, ref),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('打卡'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _doCheckIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(adminRepositoryProvider).checkIn(goal.id);
      ref.invalidate(adminGoalsProvider(null));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('打卡成功!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打卡失败: $e')));
      }
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
