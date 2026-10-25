import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminGoalDetailPage extends ConsumerStatefulWidget {
  const AdminGoalDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<AdminGoalDetailPage> createState() =>
      _AdminGoalDetailPageState();
}

class _AdminGoalDetailPageState extends ConsumerState<AdminGoalDetailPage> {
  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(adminGoalDetailProvider(widget.id));
    final milestones = ref.watch(goalMilestonesProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('目标详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: AsyncStateView(
        value: goal,
        builder: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminGoalDetailProvider(widget.id));
            ref.invalidate(goalMilestonesProvider(widget.id));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _StatusChip(status: data.status),
                        ],
                      ),
                      if (data.description != null &&
                          data.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(data.description!),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(label: '当前连续', value: '${data.currentStreak}天'),
                          _Stat(label: '最长连续', value: '${data.longestStreak}天'),
                          _Stat(label: '总打卡', value: '${data.totalCheckIns}次'),
                          _Stat(
                            label: '本月',
                            value: '${data.thisMonthCheckIns}次',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (data.status == 'ACTIVE')
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _doCheckIn(context),
                          icon: const Icon(Icons.check),
                          label: const Text('打卡'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _pauseGoal(context),
                        child: const Text('暂停'),
                      ),
                    ],
                  ),
                if (data.status == 'PAUSED')
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _resumeGoal(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('恢复'),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  '里程碑',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AsyncStateView(
                  value: milestones,
                  builder: (mItems) {
                    if (mItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('暂无里程碑')),
                      );
                    }
                    return Column(
                      children: mItems
                          .map((m) => _MilestoneCard(milestone: m))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _doCheckIn(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(adminRepositoryProvider).checkIn(widget.id);
      ref.invalidate(adminGoalDetailProvider(widget.id));
      ref.invalidate(adminGoalsProvider(null));
      if (context.mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('打卡成功!')));
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('打卡失败: $e')));
      }
    }
  }

  Future<void> _pauseGoal(BuildContext context) async {
    await ref.read(adminRepositoryProvider).pauseGoal(widget.id);
    ref.invalidate(adminGoalDetailProvider(widget.id));
    ref.invalidate(adminGoalsProvider(null));
  }

  Future<void> _resumeGoal(BuildContext context) async {
    await ref.read(adminRepositoryProvider).resumeGoal(widget.id);
    ref.invalidate(adminGoalDetailProvider(widget.id));
    ref.invalidate(adminGoalsProvider(null));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除目标'),
        content: const Text('确定要删除这个目标吗？所有打卡记录将丢失。'),
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
    if (confirmed == true && context.mounted) {
      await ref.read(adminRepositoryProvider).deleteGoal(widget.id);
      ref.invalidate(adminGoalsProvider(null));
      if (context.mounted) context.pop();
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'ACTIVE' => Theme.of(context).colorScheme.primary,
      'PAUSED' => Theme.of(context).colorScheme.error,
      'COMPLETED' => Theme.of(context).colorScheme.tertiary,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    final label = switch (status) {
      'ACTIVE' => '进行中',
      'PAUSED' => '已暂停',
      'COMPLETED' => '已完成',
      'ARCHIVED' => '已归档',
      _ => status ?? '',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.milestone});

  final AdminMilestone milestone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              milestone.unlocked
                  ? Icons.emoji_events
                  : Icons.emoji_events_outlined,
              color: milestone.unlocked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: milestone.unlocked
                          ? null
                          : TextDecoration.none,
                    ),
                  ),
                  if (milestone.description != null &&
                      milestone.description!.isNotEmpty)
                    Text(
                      milestone.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: milestone.targetValue > 0
                        ? (milestone.currentValue / milestone.targetValue)
                              .clamp(0.0, 1.0)
                        : 0,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${milestone.currentValue}/${milestone.targetValue}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
