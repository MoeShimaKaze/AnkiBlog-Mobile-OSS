import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreatePage extends ConsumerWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('创作')),
        body: const Center(child: Text('仅管理员可使用此功能')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('创作中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '快速创建',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '记录生活、抽取推荐、管理内容',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CreateOverview(repo: ref.read(adminRepositoryProvider)),
          const SizedBox(height: 16),
          _QuickAction(
            icon: Icons.edit_note,
            label: '写文章',
            description: '快速创建一篇博客文章',
            color: Theme.of(context).colorScheme.primaryContainer,
            onTap: () => context.push('/admin/articles/create'),
          ),
          _QuickAction(
            icon: Icons.add_shopping_cart,
            label: '新建商品',
            description: '添加新的商品展示内容',
            color: Theme.of(context).colorScheme.tertiaryContainer,
            onTap: () => context.push('/admin/products/create'),
          ),
          _QuickAction(
            icon: Icons.payments_outlined,
            label: '记一笔',
            description: '进入记账页面添加收支记录',
            color: Theme.of(context).colorScheme.errorContainer,
            onTap: () => context.push('/admin/accounting'),
          ),
          _QuickAction(
            icon: Icons.auto_awesome,
            label: '今天穿什么',
            description: '随机抽取今日穿搭推荐',
            color: Theme.of(context).colorScheme.secondaryContainer,
            onTap: () => context.push('/admin/daily-outfit'),
          ),
          _QuickAction(
            icon: Icons.checkroom,
            label: '记录穿搭',
            description: '记录今天的穿搭组合',
            color: Theme.of(context).colorScheme.primaryContainer,
            onTap: () => context.push('/admin/outfits/create'),
          ),
          _QuickAction(
            icon: Icons.brush,
            label: '记录妆容',
            description: '记录今天的妆容',
            color: Theme.of(context).colorScheme.tertiaryContainer,
            onTap: () => context.push('/admin/makeups/create'),
          ),
          _QuickAction(
            icon: Icons.check_box_outlined,
            label: '新建待办',
            description: '添加新的待办事项',
            color: Theme.of(context).colorScheme.secondaryContainer,
            onTap: () => context.push('/admin/todos/create'),
          ),
          _QuickAction(
            icon: Icons.flag_outlined,
            label: '新建目标',
            description: '设定新的打卡目标',
            color: Theme.of(context).colorScheme.errorContainer,
            onTap: () => context.push('/admin/goals/create'),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: '生活管理'),
          _ManageTile(
            icon: Icons.auto_awesome_outlined,
            title: '今天穿什么',
            onTap: () => context.push('/admin/daily-outfit'),
          ),
          _ManageTile(
            icon: Icons.checkroom_outlined,
            title: '穿搭管理',
            onTap: () => context.push('/admin/outfits'),
          ),
          _ManageTile(
            icon: Icons.brush_outlined,
            title: '妆容管理',
            onTap: () => context.push('/admin/makeups'),
          ),
          _ManageTile(
            icon: Icons.list_outlined,
            title: '待办管理',
            onTap: () => context.push('/admin/todos'),
          ),
          _ManageTile(
            icon: Icons.flag_outlined,
            title: '打卡目标',
            onTap: () => context.push('/admin/goals'),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '分析与财务'),
          _ManageTile(
            icon: Icons.checkroom_outlined,
            title: '衣橱分析',
            onTap: () => context.push('/admin/wardrobe'),
          ),
          _ManageTile(
            icon: Icons.brush_outlined,
            title: '化妆品分析',
            onTap: () => context.push('/admin/cosmetics'),
          ),
          _ManageTile(
            icon: Icons.shopping_bag_outlined,
            title: '已购产品',
            onTap: () => context.push('/admin/purchases'),
          ),
          _ManageTile(
            icon: Icons.account_balance_wallet_outlined,
            title: '记账',
            onTap: () => context.push('/admin/accounting'),
          ),
        ],
      ),
    );
  }
}

class _CreateOverview extends StatefulWidget {
  const _CreateOverview({required this.repo});

  final AdminRepository repo;

  @override
  State<_CreateOverview> createState() => _CreateOverviewState();
}

class _CreateOverviewState extends State<_CreateOverview> {
  late Future<_CreateOverviewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CreateOverviewData> _load() async {
    var myDayCount = 0;
    var activeGoals = 0;
    var recentOutfits = const <AdminOutfit>[];
    var recentMakeups = const <AdminMakeup>[];

    try {
      myDayCount = (await widget.repo.getMyDayItems()).length;
    } catch (_) {}
    try {
      activeGoals = (await widget.repo.getGoals(status: 'ACTIVE')).length;
    } catch (_) {}
    try {
      recentOutfits = (await widget.repo.getOutfits(size: 3)).content;
    } catch (_) {}
    try {
      recentMakeups = (await widget.repo.getMakeups(size: 3)).content;
    } catch (_) {}

    return _CreateOverviewData(
      myDayCount: myDayCount,
      activeGoals: activeGoals,
      recentOutfits: recentOutfits,
      recentMakeups: recentMakeups,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CreateOverviewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '今日概览',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 20),
                    tooltip: '刷新',
                    onPressed: loading ? null : _refresh,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _OverviewMetric(
                      label: '我的一天',
                      value: data?.myDayCount.toString() ?? '-',
                      icon: Icons.today_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OverviewMetric(
                      label: '进行中目标',
                      value: data?.activeGoals.toString() ?? '-',
                      icon: Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '最近记录',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (loading && data == null)
                const LinearProgressIndicator()
              else
                _RecentRecords(data: data ?? _CreateOverviewData.empty()),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RecentRecords extends StatelessWidget {
  const _RecentRecords({required this.data});

  final _CreateOverviewData data;

  @override
  Widget build(BuildContext context) {
    final records = <_RecentRecord>[
      ...data.recentOutfits.map(
        (item) => _RecentRecord(
          icon: Icons.checkroom_outlined,
          title: '穿搭记录',
          subtitle: item.note ?? '${item.items.length} 件单品',
          rawDate: item.outfitDate ?? item.createdAt,
        ),
      ),
      ...data.recentMakeups.map(
        (item) => _RecentRecord(
          icon: Icons.brush_outlined,
          title: item.lookName ?? item.makeupDate ?? '妆容记录',
          subtitle: item.note ?? '最近妆容',
          rawDate: item.makeupDate ?? item.createdAt,
        ),
      ),
    ];

    if (records.isEmpty) {
      return Text(
        '暂无最近记录',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    records.sort((a, b) {
      final aDate = a.dateTime;
      final bDate = b.dateTime;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    final grouped = <String, List<_RecentRecord>>{};
    for (final record in records.take(6)) {
      grouped.putIfAbsent(record.dateGroup, () => []).add(record);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (record) => _RecentRecordTile(record: record),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _RecentRecord {
  const _RecentRecord({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rawDate,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? rawDate;

  DateTime? get dateTime {
    final value = rawDate?.trim();
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  String get dateGroup {
    final parsed = dateTime;
    if (parsed == null) return '未记录日期';
    return DateFormat('yyMMdd').format(parsed);
  }

  String get timeLabel {
    final parsed = dateTime;
    if (parsed == null) return '';
    return DateFormat('HH:mm').format(parsed);
  }
}

class _RecentRecordTile extends StatelessWidget {
  const _RecentRecordTile({required this.record});

  final _RecentRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(record.icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  record.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (record.timeLabel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              record.timeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreateOverviewData {
  const _CreateOverviewData({
    required this.myDayCount,
    required this.activeGoals,
    required this.recentOutfits,
    required this.recentMakeups,
  });

  final int myDayCount;
  final int activeGoals;
  final List<AdminOutfit> recentOutfits;
  final List<AdminMakeup> recentMakeups;

  factory _CreateOverviewData.empty() {
    return const _CreateOverviewData(
      myDayCount: 0,
      activeGoals: 0,
      recentOutfits: [],
      recentMakeups: [],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  const _ManageTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
