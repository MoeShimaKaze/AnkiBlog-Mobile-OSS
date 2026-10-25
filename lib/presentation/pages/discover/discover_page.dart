import 'package:ankiblog_mobile/data/models/article.dart';
import 'package:ankiblog_mobile/data/models/custom_page.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('发现'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '文章'),
              Tab(text: '产品'),
              Tab(text: '页面'),
              Tab(text: '链接'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AsyncStateView(
              value: ref.watch(articleListProvider),
              builder: (items) => _ArticleList(items: items),
            ),
            _ProductTabView(),
            AsyncStateView(
              value: ref.watch(customPageListProvider),
              builder: (items) => _PageList(items: items),
            ),
            _LinksView(ref: ref),
          ],
        ),
      ),
    );
  }
}

class _ArticleList extends StatelessWidget {
  const _ArticleList({required this.items});

  final List<Article> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => context.push('/articles/${item.slug}'),
          child: GlassContainer(
            child: Row(
              children: [
                RemoteImage(url: item.coverImage, width: 96, height: 86),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductTabView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(productCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider);

    return Column(
      children: [
        // Category filter chips
        categories.when(
          data: (cats) {
            if (cats.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('全部'),
                      selected: selectedCategory == null,
                      onSelected: (_) =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              null,
                    ),
                  ),
                  for (final cat in cats)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: selectedCategory == cat.name,
                        onSelected: (_) =>
                            ref.read(selectedCategoryProvider.notifier).state =
                                selectedCategory == cat.name ? null : cat.name,
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        // Product grid
        Expanded(
          child: AsyncStateView(
            value: products,
            builder: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('暂无产品'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () => context.push('/products/${item.slug}'),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RemoteImage(
                            url: item.mainImage,
                            height: 126,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            '${item.currency} ${item.price.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PageList extends StatelessWidget {
  const _PageList({required this.items});

  final List<CustomPage> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tileColor: Theme.of(context).cardTheme.color,
          title: Text(item.title),
          subtitle: Text(item.summary.isEmpty ? item.subtitle : item.summary),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/pages/${item.slug}'),
        );
      },
    );
  }
}

class _LinksView extends StatelessWidget {
  const _LinksView({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendLinksProvider);
    final socials = ref.watch(socialLinksProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('友情链接', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        AsyncStateView(
          value: friends,
          builder: (items) => Column(
            children: [
              for (final item in items)
                _ExternalLinkTile(
                  title: item.siteName,
                  subtitle: item.description,
                  url: item.siteUrl,
                  icon: Icons.link,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('社交链接', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        AsyncStateView(
          value: socials,
          builder: (items) => Column(
            children: [
              for (final item in items)
                _ExternalLinkTile(
                  title: item.title,
                  subtitle: item.platform,
                  url: item.url,
                  icon: Icons.public,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExternalLinkTile extends StatelessWidget {
  const _ExternalLinkTile({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Theme.of(context).cardTheme.color,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      ),
    );
  }
}
