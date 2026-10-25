import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/category_tree_selector.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminWardrobePage extends ConsumerStatefulWidget {
  const AdminWardrobePage({super.key});

  @override
  ConsumerState<AdminWardrobePage> createState() => _AdminWardrobePageState();
}

class _AdminWardrobePageState extends ConsumerState<AdminWardrobePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('衣橱分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '概览'),
            Tab(text: '全部单品'),
            Tab(text: '闲置'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OverviewTab(), _ProductsTab(), _IdleTab()],
      ),
    );
  }
}

// ==================== Overview Tab ====================

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(wardrobeOverviewProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(wardrobeOverviewProvider),
      child: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('加载失败: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(wardrobeOverviewProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '衣橱概览',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(label: '总单品', value: '${data['totalItems'] ?? 0}'),
                      _Stat(
                        label: '总价值',
                        value:
                            '¥${(data['totalValue'] ?? 0).toStringAsFixed(0)}',
                      ),
                      _Stat(
                        label: '总穿搭',
                        value: '${data['totalWearCount'] ?? 0}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                        label: '闲置单品',
                        value: '${data['idleItemCount'] ?? 0}',
                        color: Theme.of(context).colorScheme.error,
                      ),
                      _Stat(
                        label: '已购入',
                        value: '${data['totalPurchased'] ?? 0}',
                      ),
                      _Stat(
                        label: '活跃单品',
                        value: '${data['activeItems'] ?? 0}',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if ((data['idleItemCount'] ?? 0) > 0) ...[
              const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '你有 ${data['idleItemCount']} 件闲置单品，考虑搭配使用或处理。',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _WardrobeStatsSections(),
          ],
        ),
      ),
    );
  }
}

class _WardrobeStatsSections extends ConsumerWidget {
  const _WardrobeStatsSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(adminRepositoryProvider);
    return Column(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: repository.getWardrobeStyleStats(),
          builder: (context, snapshot) {
            return _DistributionCard(
              title: '标签/风格分布',
              icon: Icons.sell_outlined,
              items: _statRows(snapshot.data),
              loading: snapshot.connectionState != ConnectionState.done,
            );
          },
        ),
        const SizedBox(height: 12),
        FutureBuilder<PageResponse<Map<String, dynamic>>>(
          future: repository.getWardrobeProducts(size: 200),
          builder: (context, snapshot) {
            return _DistributionCard(
              title: '商品分类分布',
              icon: Icons.category_outlined,
              items: _categoryRows(snapshot.data?.content),
              loading: snapshot.connectionState != ConnectionState.done,
            );
          },
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: repository.getWardrobeMostWorn(),
          builder: (context, snapshot) {
            return _TopProductsCard(
              title: '常穿单品',
              items: snapshot.data ?? const [],
              metricKey: 'wear_count',
              fallbackMetricKey: 'wearCount',
              metricLabel: '穿搭',
              loading: snapshot.connectionState != ConnectionState.done,
            );
          },
        ),
      ],
    );
  }
}

// ==================== Products Tab ====================

class _ProductsTab extends ConsumerStatefulWidget {
  const _ProductsTab();

  @override
  ConsumerState<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends ConsumerState<_ProductsTab> {
  final List<Map<String, dynamic>> _items = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _keywordController = TextEditingController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  final List<String> _selectedCategoryIds = [];
  bool _onlyPurchased = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getWardrobeProducts(
            page: _page,
            size: 20,
            keyword: _keywordController.text,
            categoryIds: _selectedCategoryIds,
            onlyPurchased: _onlyPurchased,
            useDefaultSettings: _selectedCategoryIds.isEmpty,
          );
      setState(() {
        _items.addAll(page.content);
        _hasMore = page.hasNext;
        _page++;
        _isInitialLoading = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitialLoading = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _reload() async {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _isInitialLoading = true;
      _error = null;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('加载失败: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                _error = null;
                _loadMore();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无单品'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _items.clear();
        _page = 0;
        _hasMore = true;
        _isInitialLoading = true;
        _loadMore();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_hasMore ? 1 : 0) + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _WardrobeFilterPanel(
              keywordController: _keywordController,
              selectedCategoryIds: _selectedCategoryIds,
              onlyPurchased: _onlyPurchased,
              onCategoryChanged: (value) {
                setState(() {
                  _selectedCategoryIds
                    ..clear()
                    ..addAll(value);
                });
                _reload();
              },
              onOnlyPurchasedChanged: (value) {
                setState(() => _onlyPurchased = value);
                _reload();
              },
              onSearch: _reload,
              onReset: () {
                _keywordController.clear();
                setState(() {
                  _selectedCategoryIds.clear();
                  _onlyPurchased = true;
                });
                _reload();
              },
            );
          }
          final itemIndex = index - 1;
          if (itemIndex == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = _items[itemIndex];
          return _ProductCard(item: item);
        },
      ),
    );
  }
}

class _WardrobeFilterPanel extends ConsumerWidget {
  const _WardrobeFilterPanel({
    required this.keywordController,
    required this.selectedCategoryIds,
    required this.onlyPurchased,
    required this.onCategoryChanged,
    required this.onOnlyPurchasedChanged,
    required this.onSearch,
    required this.onReset,
  });

  final TextEditingController keywordController;
  final List<String> selectedCategoryIds;
  final bool onlyPurchased;
  final ValueChanged<List<String>> onCategoryChanged;
  final ValueChanged<bool> onOnlyPurchasedChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: keywordController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                labelText: '搜索单品',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: onSearch,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ProductCategory>>(
              future: ref.read(publicRepositoryProvider).getProductCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? const <ProductCategory>[];
                return CategoryTreeSelector(
                  categories: categories,
                  selectedIds: selectedCategoryIds,
                  onChanged: onCategoryChanged,
                  multiSelect: true,
                );
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: onlyPurchased,
              onChanged: onOnlyPurchasedChanged,
              title: const Text('只显示已购'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                label: const Text('重置筛选'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Idle Tab ====================

class _IdleTab extends ConsumerStatefulWidget {
  const _IdleTab();

  @override
  ConsumerState<_IdleTab> createState() => _IdleTabState();
}

class _IdleTabState extends ConsumerState<_IdleTab> {
  final List<Map<String, dynamic>> _items = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getWardrobeIdleItems(page: _page, size: 20);
      setState(() {
        _items.addAll(page.content);
        _hasMore = page.hasNext;
        _page++;
        _isInitialLoading = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitialLoading = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('加载失败: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                _error = null;
                _loadMore();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无闲置单品'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _items.clear();
        _page = 0;
        _hasMore = true;
        _isInitialLoading = true;
        _loadMore();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = _items[index];
          return _ProductCard(item: item);
        },
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? '未知产品';
    final brand = item['brand']?.toString();
    final mainImage =
        item['main_image']?.toString() ?? item['mainImage']?.toString();
    final price = item['price'];
    final wearCount = item['wear_count'] ?? item['wearCount'];
    final slug = item['slug']?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: slug != null ? () => context.push('/products/$slug') : null,
        child: GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (mainImage != null && mainImage.isNotEmpty)
                RemoteImage(url: mainImage, width: 56, height: 56)
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (brand != null && brand.isNotEmpty)
                      Text(
                        brand,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    Row(
                      children: [
                        if (price != null)
                          Text(
                            '¥${(price is num ? price : double.tryParse(price.toString()) ?? 0).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        if (wearCount != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '穿搭 $wearCount 次',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

List<_DistributionRow> _statRows(List<Map<String, dynamic>>? rawItems) {
  final items = rawItems ?? const <Map<String, dynamic>>[];
  return items
      .map((item) {
        final name =
            item['name']?.toString() ??
            item['style']?.toString() ??
            item['tag']?.toString() ??
            '未分类';
        final count = item['count'] is num
            ? (item['count'] as num).toInt()
            : int.tryParse(item['count']?.toString() ?? '') ?? 0;
        return _DistributionRow(name: name, count: count);
      })
      .where((row) => row.count > 0)
      .toList(growable: false);
}

List<_DistributionRow> _categoryRows(List<Map<String, dynamic>>? rawItems) {
  final counts = <String, int>{};
  for (final item in rawItems ?? const <Map<String, dynamic>>[]) {
    final name =
        item['category_name']?.toString() ??
        item['categoryName']?.toString() ??
        '未分类';
    counts[name] = (counts[name] ?? 0) + 1;
  }
  final rows = counts.entries
      .map((entry) => _DistributionRow(name: entry.key, count: entry.value))
      .toList(growable: false);
  rows.sort((a, b) => b.count.compareTo(a.count));
  return rows;
}

class _DistributionRow {
  const _DistributionRow({required this.name, required this.count});
  final String name;
  final int count;
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.loading,
  });

  final String title;
  final IconData icon;
  final List<_DistributionRow> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final maxCount = items.isEmpty
        ? 1
        : items.map((item) => item.count).reduce((a, b) => a > b ? a : b);
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (items.isEmpty)
            Text('暂无数据', style: Theme.of(context).textTheme.bodySmall)
          else
            ...items.take(8).map((item) {
              final value = item.count / maxCount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.name)),
                        Text('${item.count} 件'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: value.clamp(0.0, 1.0)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard({
    required this.title,
    required this.items,
    required this.metricKey,
    required this.fallbackMetricKey,
    required this.metricLabel,
    required this.loading,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final String metricKey;
  final String fallbackMetricKey;
  final String metricLabel;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, size: 18),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (items.isEmpty)
            Text('暂无数据', style: Theme.of(context).textTheme.bodySmall)
          else
            ...items.take(5).map((item) {
              final name = item['name']?.toString() ?? '未知商品';
              final image =
                  item['main_image']?.toString() ??
                  item['mainImage']?.toString();
              final count = item[metricKey] ?? item[fallbackMetricKey] ?? 0;
              final slug = item['slug']?.toString();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: RemoteImage(url: image, width: 44, height: 44),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('$metricLabel $count 次'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: slug != null && slug.isNotEmpty
                    ? () => context.push('/products/$slug')
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
