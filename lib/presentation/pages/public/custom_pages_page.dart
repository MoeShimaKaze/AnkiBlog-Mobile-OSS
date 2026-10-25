import 'package:ankiblog_mobile/data/models/custom_page.dart';
import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomPagesPage extends ConsumerStatefulWidget {
  const CustomPagesPage({super.key});

  @override
  ConsumerState<CustomPagesPage> createState() => _CustomPagesPageState();
}

class _CustomPagesPageState extends ConsumerState<CustomPagesPage> {
  final _searchController = TextEditingController();
  final List<CustomPage> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final nextPage = reset ? 0 : _page;
      final result = await ref
          .read(publicRepositoryProvider)
          .getCustomPages(
            page: nextPage,
            size: 10,
            keyword: _searchController.text,
          );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(result.content);
        _page = nextPage + 1;
        _hasMore = result.hasNext;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final featured = ref.watch(featuredCustomPagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('自定义页面')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredCustomPagesProvider);
          await _load(reset: true);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '搜索页面',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _load(reset: true);
                        },
                      ),
              ),
              onSubmitted: (_) => _load(reset: true),
            ),
            const SizedBox(height: 16),
            featured.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '精选页面',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 176,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => SizedBox(
                          width: 220,
                          child: _CustomPageCard(page: items[index]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            Text(
              '全部页面',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (_items.isEmpty && !_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: Text('暂无公开自定义页面')),
              )
            else
              for (final page in _items) ...[
                _CustomPageCard(page: page),
                const SizedBox(height: 12),
              ],
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasMore)
              OutlinedButton(
                onPressed: () => _load(),
                child: const Text('加载更多'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomPageCard extends StatelessWidget {
  const _CustomPageCard({required this.page});

  final CustomPage page;

  @override
  Widget build(BuildContext context) {
    final description = page.summary.isNotEmpty ? page.summary : page.subtitle;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/pages/${page.slug}'),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (page.coverImage?.isNotEmpty == true) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RemoteImage(url: page.coverImage, width: 86, height: 86),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  page.pageIcon?.isNotEmpty == true ? page.pageIcon! : '页',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          page.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (page.featured)
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${page.viewCount} 次浏览',
                    style: Theme.of(context).textTheme.labelSmall,
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
