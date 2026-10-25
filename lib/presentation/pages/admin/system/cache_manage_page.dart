import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CacheManagePage extends ConsumerWidget {
  const CacheManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(cacheStatsProvider);
    final redisAsync = ref.watch(redisInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('缓存管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () {
              ref.invalidate(cacheStatsProvider);
              ref.invalidate(redisInfoProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cacheStatsProvider);
          ref.invalidate(redisInfoProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRedisInfo(context, ref, redisAsync),
            const SizedBox(height: 16),
            _buildCacheStats(context, ref, statsAsync),
            const SizedBox(height: 16),
            _buildActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildRedisInfo(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> redisAsync,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Redis 信息', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          redisAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('加载失败: $e'),
            data: (info) {
              final entries = info.entries.toList();
              return Column(
                children: entries.take(10).map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${e.value}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStats(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AdminCacheStats>> statsAsync,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('缓存统计', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          statsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('加载失败: $e'),
            data: (stats) {
              if (stats.isEmpty) return const Text('暂无缓存数据');
              return Column(
                children: stats.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name ?? '未知',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '命中: ${s.hitCount} | 未命中: ${s.missCount} | 大小: ${s.size}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(s.hitRate * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          tooltip: '清除',
                          onPressed: () async {
                            if (s.name == null) return;
                            try {
                              await ref
                                  .read(adminRepositoryProvider)
                                  .clearCache(s.name!);
                              ref.invalidate(cacheStatsProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('清除失败: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('操作', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('清除所有缓存'),
                  content: const Text('确定要清除所有缓存吗？这可能会影响性能。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await ref.read(adminRepositoryProvider).clearAllCaches();
                  ref.invalidate(cacheStatsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('所有缓存已清除')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('清除失败: $e')));
                  }
                }
              }
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('清除所有缓存'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await ref.read(adminRepositoryProvider).warmupCache('articles');
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('缓存预热已启动')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('预热失败: $e')));
                }
              }
            },
            icon: const Icon(Icons.whatshot_outlined),
            label: const Text('预热文章缓存'),
          ),
        ],
      ),
    );
  }
}
