import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/confirm_delete_dialog.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductManagePage extends ConsumerStatefulWidget {
  const ProductManagePage({super.key});

  @override
  ConsumerState<ProductManagePage> createState() => _ProductManagePageState();
}

class _ProductManagePageState extends ConsumerState<ProductManagePage> {
  final List<AdminProduct> _items = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  String? _keyword;
  String? _statusFilter;
  bool? _featuredFilter;

  static const _statusOptions = [
    (null, '全部'),
    ('ACTIVE', '上架'),
    ('DRAFT', '草稿'),
    ('OUT_OF_STOCK', '缺货'),
    ('DISCONTINUED', '停售'),
  ];

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

  void _resetAndReload() {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _isInitialLoading = true;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getAdminProducts(
            keyword: _keyword,
            status: _statusFilter,
            featured: _featuredFilter,
            page: _page,
            size: 20,
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

  Future<void> _toggleFeatured(AdminProduct product) async {
    try {
      await ref.read(adminRepositoryProvider).patchProductFeatured(product.id);
      _resetAndReload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _changeStatus(AdminProduct product, String status) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .patchProductStatus(product.id, status);
      _resetAndReload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('产品状态已更新为${_statusLabel(status)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('状态更新失败: $e')));
      }
    }
  }

  String _statusLabel(String status) {
    return switch (status) {
      'ACTIVE' => '上架',
      'OUT_OF_STOCK' => '缺货',
      'DISCONTINUED' => '停售',
      _ => '草稿',
    };
  }

  Future<void> _delete(AdminProduct product) async {
    final repo = ref.read(adminRepositoryProvider);
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: '删除产品',
      description: '确定要删除「${product.name}」吗？此操作不可撤销。',
      onSendCode: () => repo.sendProductDeleteCode(product.id),
      onConfirm: (code) => repo.deleteProduct(product.id, code),
    );
    if (confirmed) {
      _resetAndReload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('产品已删除')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('产品管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/products/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索产品名称...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _keyword != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _keyword = null;
                    _resetAndReload();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onSubmitted: (v) {
          _keyword = v.trim().isEmpty ? null : v.trim();
          _resetAndReload();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ..._statusOptions.map((opt) {
            final selected = _statusFilter == opt.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(opt.$2),
                selected: selected,
                onSelected: (_) {
                  setState(() => _statusFilter = selected ? null : opt.$1);
                  _resetAndReload();
                },
              ),
            );
          }),
          FilterChip(
            avatar: const Icon(Icons.star_outline, size: 16),
            label: const Text('精选'),
            selected: _featuredFilter == true,
            onSelected: (v) {
              setState(() => _featuredFilter = v ? true : null);
              _resetAndReload();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
            Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: _resetAndReload, child: const Text('重试')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无产品'));
    }

    return RefreshIndicator(
      onRefresh: () async => _resetAndReload(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _ProductCard(
            product: _items[index],
            onTap: () =>
                context.push('/admin/products/edit/${_items[index].id}'),
            onToggleFeatured: () => _toggleFeatured(_items[index]),
            onStatusChanged: (status) => _changeStatus(_items[index], status),
            onDelete: () => _delete(_items[index]),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onToggleFeatured,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final AdminProduct product;
  final VoidCallback onTap;
  final VoidCallback onToggleFeatured;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDelete;

  static Widget _statusBadge(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    Color bgColor;
    Color textColor;
    String label;
    switch (status) {
      case 'ACTIVE':
        bgColor = cs.primaryContainer;
        textColor = cs.onPrimaryContainer;
        label = '上架';
        break;
      case 'OUT_OF_STOCK':
        bgColor = cs.tertiaryContainer;
        textColor = cs.onTertiaryContainer;
        label = '缺货';
        break;
      case 'DISCONTINUED':
        bgColor = cs.errorContainer;
        textColor = cs.onErrorContainer;
        label = '停售';
        break;
      default:
        bgColor = cs.surfaceContainerHighest;
        textColor = cs.onSurfaceVariant;
        label = '草稿';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: textColor, fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (product.mainImage != null && product.mainImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RemoteImage(
                  url: product.mainImage!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (product.featured)
                        Icon(Icons.star, size: 16, color: cs.primary),
                    ],
                  ),
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!,
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  Row(
                    children: [
                      if (product.price != null)
                        Text(
                          '¥${product.price!.toStringAsFixed(2)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (product.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.categoryName!,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      if (product.isPurchased) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.shopping_cart, size: 14, color: cs.primary),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      _statusBadge(context, product.status),
                      if (product.tags.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.tags.take(3).join(' / '),
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'featured') onToggleFeatured();
                if (v.startsWith('status:')) {
                  onStatusChanged(v.substring('status:'.length));
                }
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'featured',
                  child: Text(product.featured ? '取消精选' : '设为精选'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'status:ACTIVE', child: Text('上架')),
                const PopupMenuItem(value: 'status:DRAFT', child: Text('设为草稿')),
                const PopupMenuItem(
                  value: 'status:OUT_OF_STOCK',
                  child: Text('标记缺货'),
                ),
                const PopupMenuItem(
                  value: 'status:DISCONTINUED',
                  child: Text('标记停售'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
