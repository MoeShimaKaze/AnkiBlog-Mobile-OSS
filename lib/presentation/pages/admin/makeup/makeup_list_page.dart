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

String _formatMakeupDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    return DateFormat('yy/MM/dd HH:mm').format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

class AdminMakeupListPage extends ConsumerStatefulWidget {
  const AdminMakeupListPage({super.key});

  @override
  ConsumerState<AdminMakeupListPage> createState() =>
      _AdminMakeupListPageState();
}

class _AdminMakeupListPageState extends ConsumerState<AdminMakeupListPage> {
  int _calYear = DateTime.now().year;
  int _calMonth = DateTime.now().month;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final makeups = ref.watch(adminMakeupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('妆容管理'),
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/makeups/create'),
        child: const Icon(Icons.add),
      ),
      body: _showCalendar ? _buildCalendarView() : _buildListView(makeups),
    );
  }

  Widget _buildListView(AsyncValue<List<AdminMakeup>> makeups) {
    return AsyncStateView(
      value: makeups,
      builder: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('暂无妆容记录'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminMakeupListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _MakeupCard(item: items[index]),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    final calendar = ref.watch(
      adminMakeupCalendarProvider((year: _calYear, month: _calMonth)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AsyncStateView(
        value: calendar,
        builder: (items) {
          final activeDays = <int>{};
          for (final m in items) {
            if (m.makeupDate != null) {
              try {
                final dt = DateTime.parse(m.makeupDate!);
                if (dt.year == _calYear && dt.month == _calMonth) {
                  activeDays.add(dt.day);
                }
              } catch (_) {}
            }
          }

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
                final dayMakeups = items.where((m) {
                  if (m.makeupDate == null) return false;
                  try {
                    final dt = DateTime.parse(m.makeupDate!);
                    return dt.day == day;
                  } catch (_) {
                    return false;
                  }
                }).toList();
                if (dayMakeups.isNotEmpty) {
                  _showDayMakeups(day, dayMakeups);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showDayMakeups(int day, List<AdminMakeup> makeups) {
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
            ...makeups.map(
              (m) => ListTile(
                leading: m.makeupImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          m.makeupImage!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.brush),
                title: Text(m.lookName ?? '妆容 #${m.id.substring(0, 8)}'),
                subtitle: Text('${m.items.length} 件产品'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin/makeups/${m.id}');
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

class _MakeupCard extends StatelessWidget {
  const _MakeupCard({required this.item});

  final AdminMakeup item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/admin/makeups/${item.id}'),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.makeupImage != null && item.makeupImage!.isNotEmpty)
              RemoteImage(
                url: item.makeupImage,
                height: 180,
                width: double.infinity,
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (item.lookName != null && item.lookName!.isNotEmpty) ...[
                  Expanded(
                    child: Text(
                      item.lookName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],
                Text(
                  _formatMakeupDate(item.makeupDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
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
                      (mi) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mi.productName ?? mi.usageTypeName ?? '',
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
