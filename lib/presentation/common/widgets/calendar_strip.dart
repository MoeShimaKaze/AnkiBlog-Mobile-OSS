import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    super.key,
    required this.year,
    required this.month,
    required this.activeDays,
    this.onDayTap,
    this.onMonthChange,
  });

  final int year;
  final int month;
  final Set<int> activeDays;
  final ValueChanged<int>? onDayTap;
  final void Function(int year, int month)? onMonthChange;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;
    final today = DateTime.now();
    final isCurrentMonth = today.year == year && today.month == month;

    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        _buildWeekdayLabels(context),
        const SizedBox(height: 4),
        _buildGrid(context, daysInMonth, firstWeekday, isCurrentMonth, today),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final monthName = DateFormat(
      'yyyy年M月',
      'zh_CN',
    ).format(DateTime(year, month));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = month == 1 ? 12 : month - 1;
            final prevYear = month == 1 ? year - 1 : year;
            onMonthChange?.call(prevYear, prev);
          },
        ),
        Text(
          monthName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = month == 12 ? 1 : month + 1;
            final nextYear = month == 12 ? year + 1 : year;
            onMonthChange?.call(nextYear, next);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    int daysInMonth,
    int firstWeekday,
    bool isCurrentMonth,
    DateTime today,
  ) {
    final cells = <Widget>[];
    // Monday = 1, so offset = firstWeekday - 1
    final offset = firstWeekday - 1;

    for (var i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final isActive = activeDays.contains(day);
      final isToday = isCurrentMonth && today.day == day;

      cells.add(
        GestureDetector(
          onTap: isActive ? () => onDayTap?.call(day) : null,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : isToday
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      );
    }

    while (cells.length < 42) {
      cells.add(const SizedBox());
    }

    return Table(
      children: List.generate(6, (rowIndex) {
        final start = rowIndex * 7;
        return TableRow(
          children: cells
              .skip(start)
              .take(7)
              .map((cell) => SizedBox(height: 44, child: cell))
              .toList(growable: false),
        );
      }),
    );
  }
}
