import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/calendar_strip.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

String _formatAdminDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('yy/MM/dd HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}

class AdminOutfitListPage extends ConsumerStatefulWidget {
  const AdminOutfitListPage({super.key});

  @override
  ConsumerState<AdminOutfitListPage> createState() =>
      _AdminOutfitListPageState();
}

class _AdminOutfitListPageState extends ConsumerState<AdminOutfitListPage> {
  int _calYear = DateTime.now().year;
  int _calMonth = DateTime.now().month;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final outfits = ref.watch(adminOutfitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('穿搭管理'),
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/outfits/create'),
        child: const Icon(Icons.add),
      ),
      body: _showCalendar ? _buildCalendarView() : _buildListView(outfits),
    );
  }

  Widget _buildListView(AsyncValue<List<AdminOutfit>> outfits) {
    return outfits.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(adminOutfitListProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('暂无穿搭记录'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminOutfitListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OutfitCard(item: items[index]),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    final calendar = ref.watch(
      adminOutfitCalendarProvider((year: _calYear, month: _calMonth)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AsyncStateView(
            value: calendar,
            builder: (data) {
              final activeDays = data.dailyOutfits.keys.toSet();
              return GlassContainer(
                child: CalendarStrip(
                  year: _calYear,
                  month: _calMonth,
                  activeDays: activeDays,
                  onMonthChange: (y, m) {
                    setState(() {
                      _calYear = y;
                      _calMonth = m;
                    });
                  },
                  onDayTap: (day) {
                    final dayOutfits = data.dailyOutfits[day];
                    if (dayOutfits != null && dayOutfits.isNotEmpty) {
                      _showDayOutfits(day, dayOutfits);
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '共 ${(ref.watch(adminOutfitCalendarProvider((year: _calYear, month: _calMonth))).valueOrNull?.totalInMonth ?? 0)} 条记录',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showDayOutfits(int day, List<AdminOutfit> outfits) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '$_calYear年$_calMonth月$day日',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            ...outfits.map(
              (o) => ListTile(
                leading: o.outfitImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          o.outfitImage!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.checkroom),
                title: Text(o.note ?? '穿搭 #${o.id.substring(0, 8)}'),
                subtitle: Text('${o.items.length} 件单品'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin/outfits/${o.id}');
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.item});

  final AdminOutfit item;

  static String _itemTypeLabel(String? type) {
    switch (type) {
      case 'MAIN':
        return '主要单品';
      case 'ACCESSORY':
        return '配饰';
      default:
        return type ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/admin/outfits/${item.id}'),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.outfitImage != null && item.outfitImage!.isNotEmpty)
              RemoteImage(
                url: item.outfitImage,
                height: 180,
                width: double.infinity,
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatAdminDate(item.outfitDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${item.items.length} 件单品',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.note!, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            if (item.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.items
                    .take(5)
                    .map(
                      (oi) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          oi.productName ?? _itemTypeLabel(oi.itemType),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
