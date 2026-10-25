import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/category_tree_selector.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminPurchaseListPage extends ConsumerStatefulWidget {
  const AdminPurchaseListPage({super.key});

  @override
  ConsumerState<AdminPurchaseListPage> createState() =>
      _AdminPurchaseListPageState();
}

class _AdminPurchaseListPageState extends ConsumerState<AdminPurchaseListPage> {
  final List<Map<String, dynamic>> _items = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  String? _selectedCategoryId;
  final List<String> _selectedTags = [];

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
    _minPriceController.dispose();
    _maxPriceController.dispose();
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
          .getPurchasedProducts(
            page: _page,
            size: 20,
            keyword: _keywordController.text,
            categoryId: _selectedCategoryId,
            tags: _selectedTags,
            minPrice: double.tryParse(_minPriceController.text),
            maxPrice: double.tryParse(_maxPriceController.text),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已购产品'),
        actions: [
          IconButton(
            icon: Icon(
              _hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  bool get _hasActiveFilters =>
      _keywordController.text.trim().isNotEmpty ||
      _selectedCategoryId != null ||
      _selectedTags.isNotEmpty ||
      _minPriceController.text.trim().isNotEmpty ||
      _maxPriceController.text.trim().isNotEmpty;

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

  Widget _buildBody() {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
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
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
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
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无已购产品'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _items.clear();
          _page = 0;
          _hasMore = true;
          _isInitialLoading = true;
        });
        _loadMore();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = _items[index];
          return _PurchasedProductCard(item: item);
        },
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    final categoriesFuture = ref
        .read(publicRepositoryProvider)
        .getProductCategories();
    final tagsFuture = ref.read(publicRepositoryProvider).getProductTags();
    String? draftCategoryId = _selectedCategoryId;
    final draftTags = List<String>.from(_selectedTags);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FutureBuilder<List<Object>>(
          future: Future.wait<Object>([categoriesFuture, tagsFuture]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final categories = snapshot.data![0] as List<ProductCategory>;
            final tags = snapshot.data![1] as List<ProductTag>;

            return StatefulBuilder(
              builder: (context, setSheetState) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '筛选已购产品',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _keywordController,
                            decoration: const InputDecoration(
                              labelText: '关键词',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CategoryTreeSelector(
                            categories: categories,
                            selectedIds: draftCategoryId == null
                                ? const []
                                : [draftCategoryId!],
                            onChanged: (ids) => setSheetState(
                              () => draftCategoryId = ids.isEmpty
                                  ? null
                                  : ids.first,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '最低价',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _maxPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '最高价',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              '标签',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tags.map((tag) {
                                final selected = draftTags.contains(tag.name);
                                return FilterChip(
                                  label: Text(tag.name),
                                  selected: selected,
                                  onSelected: (checked) {
                                    setSheetState(() {
                                      if (checked) {
                                        draftTags.add(tag.name);
                                      } else {
                                        draftTags.remove(tag.name);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  _keywordController.clear();
                                  _minPriceController.clear();
                                  _maxPriceController.clear();
                                  setState(() {
                                    _selectedCategoryId = null;
                                    _selectedTags.clear();
                                  });
                                  Navigator.pop(ctx);
                                  _reload();
                                },
                                child: const Text('重置'),
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategoryId = draftCategoryId;
                                    _selectedTags
                                      ..clear()
                                      ..addAll(draftTags);
                                  });
                                  Navigator.pop(ctx);
                                  _reload();
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('应用'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PurchasedProductCard extends StatelessWidget {
  const _PurchasedProductCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? '未知产品';
    final brand = item['brand']?.toString();
    final mainImage =
        item['main_image']?.toString() ?? item['mainImage']?.toString();
    final price = item['price'];
    final originalPrice = item['original_price'] ?? item['originalPrice'];
    final categoryName =
        item['category_name']?.toString() ?? item['categoryName']?.toString();
    final wearCount = item['wear_count'] ?? item['wearCount'];
    final useCount = item['use_count'] ?? item['useCount'];
    final slug = item['slug']?.toString();

    return InkWell(
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      if (originalPrice != null &&
                          originalPrice != price &&
                          originalPrice is num &&
                          originalPrice > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '¥${originalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (categoryName != null && categoryName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      if (wearCount != null &&
                          wearCount is num &&
                          wearCount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '穿搭 $wearCount 次',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (useCount != null &&
                          useCount is num &&
                          useCount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '使用 $useCount 次',
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
    );
  }
}
