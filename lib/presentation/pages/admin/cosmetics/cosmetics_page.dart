import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/category_tree_selector.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminCosmeticsPage extends ConsumerStatefulWidget {
  const AdminCosmeticsPage({super.key});

  @override
  ConsumerState<AdminCosmeticsPage> createState() => _AdminCosmeticsPageState();
}

class _AdminCosmeticsPageState extends ConsumerState<AdminCosmeticsPage>
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
        title: const Text('化妆品分析'),
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
    final overview = ref.watch(cosmeticOverviewProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(cosmeticOverviewProvider),
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
                onPressed: () => ref.invalidate(cosmeticOverviewProvider),
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
                    '化妆品概览',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(label: '总数量', value: '${data['totalItems'] ?? 0}'),
                      _Stat(
                        label: '总价值',
                        value:
                            '¥${(data['totalValue'] ?? 0).toStringAsFixed(0)}',
                      ),
                      _Stat(
                        label: '使用次数',
                        value: '${data['totalUsageCount'] ?? 0}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                        label: '闲置',
                        value: '${data['idleItemCount'] ?? 0}',
                        color: Theme.of(context).colorScheme.error,
                      ),
                      _Stat(
                        label: '即将过期',
                        value: '${data['expiringCount'] ?? 0}',
                        color: Theme.of(context).colorScheme.error,
                      ),
                      _Stat(
                        label: '活跃',
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
                        '你有 ${data['idleItemCount']} 件闲置化妆品，考虑使用或处理。',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if ((data['expiringCount'] ?? 0) > 0) ...[
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('${data['expiringCount']} 件化妆品即将过期，请注意检查。'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _CosmeticStatsSections(),
          ],
        ),
      ),
    );
  }
}

class _CosmeticStatsSections extends ConsumerWidget {
  const _CosmeticStatsSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(adminRepositoryProvider);
    return FutureBuilder<Map<String, dynamic>>(
      future: repository.getMakeupSettings(),
      builder: (context, settingsSnapshot) {
        final categoryIds = _makeupSettingCategoryIds(settingsSnapshot.data);
        final useDefaultSettings = categoryIds.isEmpty;
        return Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: repository.getCosmeticStyleStats(
                categoryIds: categoryIds,
                useDefaultSettings: useDefaultSettings,
              ),
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
              future: repository.getCosmetics(
                size: 200,
                categoryIds: categoryIds,
                useDefaultSettings: useDefaultSettings,
              ),
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
              future: repository.getMostUsedCosmetics(
                categoryIds: categoryIds,
                useDefaultSettings: useDefaultSettings,
              ),
              builder: (context, snapshot) {
                return _TopProductsCard(
                  title: '常用化妆品',
                  items: snapshot.data ?? const [],
                  metricKey: 'use_count',
                  fallbackMetricKey: 'useCount',
                  metricLabel: '使用',
                  loading: snapshot.connectionState != ConnectionState.done,
                );
              },
            ),
          ],
        );
      },
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
  final List<String> _selectedCategoryIds = [];
  bool _onlyPurchased = true;
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final settings = await ref
          .read(adminRepositoryProvider)
          .getMakeupSettings();
      final categoryIds = _makeupSettingCategoryIds(settings);
      if (mounted) {
        setState(() {
          _selectedCategoryIds
            ..clear()
            ..addAll(categoryIds);
        });
      }
    } catch (_) {
      // Keep loading products with backend default settings when settings fail.
    }
    if (mounted) {
      await _loadMore();
    }
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
          .getCosmetics(
            page: _page,
            size: 20,
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
      return const Center(child: Text('暂无化妆品'));
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
            return _CosmeticFilterPanel(
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
              onReset: () {
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
          return _CosmeticCard(item: item);
        },
      ),
    );
  }
}

class _CosmeticFilterPanel extends ConsumerWidget {
  const _CosmeticFilterPanel({
    required this.selectedCategoryIds,
    required this.onlyPurchased,
    required this.onCategoryChanged,
    required this.onOnlyPurchasedChanged,
    required this.onReset,
  });

  final List<String> selectedCategoryIds;
  final bool onlyPurchased;
  final ValueChanged<List<String>> onCategoryChanged;
  final ValueChanged<bool> onOnlyPurchasedChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
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
          .getCosmeticIdleItems(page: _page, size: 20);
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
      return const Center(child: Text('暂无闲置化妆品'));
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
          return _CosmeticCard(item: item);
        },
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? '未知化妆品';
    final brand = item['brand']?.toString();
    final mainImage =
        item['main_image']?.toString() ?? item['mainImage']?.toString();
    final price = item['price'];
    final usageCount = item['usage_count'] ?? item['usageCount'];
    final expiryDate = item['expiry_date'] ?? item['expiryDate'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.face_retouching_natural),
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
                      if (usageCount != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '使用 $usageCount 次',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  if (expiryDate != null)
                    Text(
                      '到期: ${expiryDate.toString().substring(0, 10)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
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

List<String> _makeupSettingCategoryIds(Map<String, dynamic>? settings) {
  final raw = settings?['category_ids'] ?? settings?['categoryIds'];
  if (raw is List) {
    return raw
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
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
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: RemoteImage(url: image, width: 44, height: 44),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('$metricLabel $count 次'),
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
