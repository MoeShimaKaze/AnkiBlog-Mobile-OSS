import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionManagePage extends ConsumerStatefulWidget {
  const SubscriptionManagePage({super.key});

  @override
  ConsumerState<SubscriptionManagePage> createState() =>
      _SubscriptionManagePageState();
}

class _SubscriptionManagePageState
    extends ConsumerState<SubscriptionManagePage> {
  final List<AdminSubscription> _items = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  String? _keyword;

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
          .getSubscriptions(keyword: _keyword, page: _page, size: 20);
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

  Future<void> _delete(AdminSubscription sub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除订阅'),
        content: Text('确定要删除「${sub.email ?? sub.subscriberName ?? sub.id}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteSubscription(sub.id);
        _resetAndReload();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('订阅已删除')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(subscriptionStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('订阅管理')),
      body: Column(
        children: [
          // Stats panel
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => _StatsPanel(stats: stats),
          ),
          _buildSearchBar(),
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
          hintText: '搜索邮箱...',
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
      return const Center(child: Text('暂无订阅'));
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
          return _SubscriptionCard(
            subscription: _items[index],
            onDelete: () => _delete(_items[index]),
          );
        },
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total =
        stats['totalSubscriptions'] ?? stats['total_subscriptions'] ?? 0;
    final active =
        stats['activeSubscriptions'] ?? stats['active_subscriptions'] ?? 0;
    final todayNew =
        stats['todayNewSubscriptions'] ?? stats['today_new_subscriptions'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: '总订阅', value: '$total', color: cs.primary),
            _StatItem(label: '活跃', value: '$active', color: cs.tertiary),
            _StatItem(label: '今日新增', value: '$todayNew', color: cs.secondary),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription, required this.onDelete});

  final AdminSubscription subscription;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor(cs),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.email_outlined,
                size: 20,
                color: _statusOnColor(cs),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.email ?? subscription.subscriberName ?? '未知',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    if (subscription.subscriptionTypeDescription != null) ...[
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
                          subscription.subscriptionTypeDescription!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (subscription.statusDescription != null)
                      Text(
                        subscription.statusDescription!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _statusTextColor(cs),
                          fontSize: 11,
                        ),
                      ),
                    if (subscription.notificationCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '已通知${subscription.notificationCount}次',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subscription.createdAt != null)
                  Text(
                    '订阅于 ${subscription.createdAt!.substring(0, 10)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('删除')),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ColorScheme cs) {
    switch (subscription.status) {
      case 'ACTIVE':
        return cs.primaryContainer;
      case 'UNSUBSCRIBED':
        return cs.surfaceContainerHighest;
      case 'BOUNCED':
        return cs.errorContainer;
      default:
        return cs.surfaceContainerHighest;
    }
  }

  Color _statusOnColor(ColorScheme cs) {
    switch (subscription.status) {
      case 'ACTIVE':
        return cs.onPrimaryContainer;
      case 'UNSUBSCRIBED':
        return cs.onSurfaceVariant;
      case 'BOUNCED':
        return cs.onErrorContainer;
      default:
        return cs.onSurfaceVariant;
    }
  }

  Color _statusTextColor(ColorScheme cs) {
    switch (subscription.status) {
      case 'ACTIVE':
        return cs.primary;
      case 'UNSUBSCRIBED':
        return cs.onSurfaceVariant;
      case 'BOUNCED':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }
}
