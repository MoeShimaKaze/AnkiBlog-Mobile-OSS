import 'package:ankiblog_mobile/data/models/article.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/section_header.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

String _formatHomeDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('yy/MM/dd HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final site = ref.watch(siteConfigProvider);
    final articles = ref.watch(featuredArticlesProvider);
    final products = ref.watch(featuredProductsProvider);
    final todos = ref.watch(publicTodosProvider);
    final outfits = ref.watch(publicOutfitsProvider);
    final makeups = ref.watch(publicMakeupsProvider);
    final goals = ref.watch(goalsSummaryProvider);
    final siteData = site.asData?.value;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(siteConfigProvider);
        ref.invalidate(featuredArticlesProvider);
        ref.invalidate(featuredProductsProvider);
        ref.invalidate(publicTodosProvider);
        ref.invalidate(publicOutfitsProvider);
        ref.invalidate(publicMakeupsProvider);
        ref.invalidate(goalsSummaryProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              siteData?.heroTitle.isNotEmpty == true
                  ? siteData!.heroTitle
                  : 'AnkiBlog',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
              child: AsyncStateView(
                value: site,
                builder: (data) => GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    data.heroSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: '推荐文章')),
          SliverToBoxAdapter(
            child: AsyncStateView(
              value: articles,
              builder: (items) => _HorizontalArticles(items: items),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: '最新产品')),
          SliverToBoxAdapter(
            child: AsyncStateView(
              value: products,
              builder: (items) => _HorizontalProducts(items: items),
            ),
          ),

          // Goals summary
          SliverToBoxAdapter(
            child: AsyncStateView(
              value: goals,
              builder: (data) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '打卡概览',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _GoalStat(
                            label: '进行中',
                            value: '${data.activeGoalCount}',
                          ),
                          _GoalStat(
                            label: '累计打卡',
                            value: '${data.totalCheckInDays}',
                          ),
                          _GoalStat(
                            label: '当前连续',
                            value: '${data.maxCurrentStreak}天',
                          ),
                          _GoalStat(
                            label: '本月打卡',
                            value: '${data.thisMonthCheckIns}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Recent todos
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '待办清单',
              trailing: TextButton(
                onPressed: () => context.push('/todos'),
                child: const Text('查看全部'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AsyncStateView(
              value: todos,
              builder: (items) {
                if (items.isEmpty) return const _EmptyStrip(text: '暂无待办');
                final preview = items.take(5).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: preview
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassContainer(
                              child: Row(
                                children: [
                                  Icon(
                                    t.completed
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: t.completed
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        decoration: t.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),

          // Recent outfits
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '穿搭记录',
              trailing: TextButton(
                onPressed: () => context.push('/outfits'),
                child: const Text('查看全部'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AsyncStateView(
              value: outfits,
              builder: (items) {
                if (items.isEmpty) return const _EmptyStrip(text: '暂无穿搭记录');
                return SizedBox(
                  height: 180,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return SizedBox(
                        width: 150,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/outfits/${item.id}'),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.outfitImage != null &&
                                    item.outfitImage!.isNotEmpty)
                                  RemoteImage(
                                    url: item.outfitImage,
                                    height: 110,
                                    width: double.infinity,
                                  )
                                else
                                  Expanded(
                                    child: Center(
                                      child: Icon(
                                        Icons.checkroom,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                if (item.outfitDate != null)
                                  Text(
                                    _formatHomeDate(item.outfitDate),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Recent makeups
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '妆容记录',
              trailing: TextButton(
                onPressed: () => context.push('/makeups'),
                child: const Text('查看全部'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AsyncStateView(
              value: makeups,
              builder: (items) {
                if (items.isEmpty) return const _EmptyStrip(text: '暂无妆容记录');
                return SizedBox(
                  height: 180,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return SizedBox(
                        width: 150,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/makeups'),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.makeupImage != null &&
                                    item.makeupImage!.isNotEmpty)
                                  RemoteImage(
                                    url: item.makeupImage,
                                    height: 110,
                                    width: double.infinity,
                                  )
                                else
                                  Expanded(
                                    child: Center(
                                      child: Icon(
                                        Icons.brush,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                if (item.lookName != null &&
                                    item.lookName!.isNotEmpty)
                                  Text(
                                    item.lookName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _HorizontalArticles extends StatelessWidget {
  const _HorizontalArticles({required this.items});

  final List<Article> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyStrip(text: '暂无推荐文章');
    return SizedBox(
      height: 244,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 260,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/articles/${item.slug}'),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RemoteImage(
                      url: item.coverImage,
                      height: 118,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts({required this.items});

  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyStrip(text: '暂无产品');
    return SizedBox(
      height: 218,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 176,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/products/${item.slug}'),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        RemoteImage(
                          url: item.mainImage,
                          height: 118,
                          width: double.infinity,
                        ),
                        if (item.isPurchased)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 10,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '已购',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (item.featured)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer
                                    .withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.star,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.currency} ${item.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(child: Center(child: Text(text))),
    );
  }
}

class _GoalStat extends StatelessWidget {
  const _GoalStat({required this.label, required this.value});

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
