import 'package:ankiblog_mobile/data/models/daily_outfit.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DailyOutfitPage extends ConsumerWidget {
  const DailyOutfitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(dailyOutfitSuggestionsProvider);
    final isAdmin = ref.watch(authProvider).isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('今天穿什么'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: '管理推荐',
              icon: const Icon(Icons.tune),
              onPressed: () => context.push('/admin/daily-outfit'),
            ),
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dailyOutfitSuggestionsProvider),
          ),
        ],
      ),
      body: AsyncStateView(
        value: suggestions,
        builder: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('还没有公开的穿搭推荐'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dailyOutfitSuggestionsProvider);
              await ref.read(dailyOutfitSuggestionsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _DailyOutfitCard(suggestion: items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _DailyOutfitCard extends StatelessWidget {
  const _DailyOutfitCard({required this.suggestion});

  final DailyOutfitSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.suggestionDate.isEmpty
                      ? '今日推荐'
                      : suggestion.suggestionDate,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(suggestion: suggestion),
            ],
          ),
          if (suggestion.note?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(suggestion.note!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          if (suggestion.items.isEmpty)
            const Text('暂无推荐单品')
          else
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestion.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = suggestion.items[index];
                  return _OutfitItemTile(item: item);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _OutfitItemTile extends StatelessWidget {
  const _OutfitItemTile({required this.item});

  final DailyOutfitItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: item.productSlug == null || item.productSlug!.isEmpty
          ? null
          : () => context.push('/products/${item.productSlug}'),
      child: SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RemoteImage(
                url: item.productMainImage,
                width: 112,
                height: 82,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.productName ?? '未命名单品',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.suggestion});

  final DailyOutfitSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final color = switch (suggestion.status) {
      'ACCEPTED' => Colors.green,
      'REJECTED' => Colors.red,
      _ => Colors.orange,
    };
    return Chip(
      label: Text(suggestion.statusDisplayName),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      backgroundColor: color.withValues(alpha: 0.12),
    );
  }
}
