import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/stat_card.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(dashboardOverviewProvider);
    final trendsAsync = ref.watch(dashboardTrendsProvider(30));

    return Scaffold(
      appBar: AppBar(title: const Text('仪表盘')),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('加载失败', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(e.toString(), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(dashboardOverviewProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (overview) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardOverviewProvider);
            ref.invalidate(dashboardTrendsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsGrid(context, overview),
              const SizedBox(height: 16),
              _buildTrendChart(context, trendsAsync),
              const SizedBox(height: 16),
              _buildRecentArticles(context, overview.recentArticles),
              const SizedBox(height: 16),
              _buildRecentComments(context, overview.recentComments),
              const SizedBox(height: 16),
              _buildRecentUsers(context, overview.recentUsers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminDashboardOverview data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        StatCard(
          label: '文章',
          value: '${data.articleCount}',
          icon: Icons.article_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        StatCard(
          label: '产品',
          value: '${data.productCount}',
          icon: Icons.shopping_bag_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
        StatCard(
          label: '用户',
          value: '${data.userCount}',
          icon: Icons.people_outline,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        StatCard(
          label: '评论',
          value: '${data.commentCount}',
          icon: Icons.comment_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        StatCard(
          label: '活跃用户',
          value: '${data.activeUsers}',
          icon: Icons.person_outline,
        ),
        StatCard(
          label: '待审评论',
          value: '${data.pendingComments}',
          icon: Icons.mark_chat_unread_outlined,
        ),
        StatCard(
          label: '今日浏览',
          value: '${data.todayViews}',
          icon: Icons.visibility_outlined,
        ),
        StatCard(
          label: '总浏览',
          value: '${data.totalViews}',
          icon: Icons.bar_chart_outlined,
        ),
      ],
    );
  }

  Widget _buildTrendChart(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> trendsAsync,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('近30天访问趋势', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          trendsAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SizedBox(height: 200, child: Center(child: Text('图表加载失败: $e'))),
            data: (trends) => _LineChartWidget(data: trends),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentArticles(
    BuildContext context,
    List<AdminArticle> articles,
  ) {
    if (articles.isEmpty) return const SizedBox.shrink();
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近文章', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...articles
              .take(5)
              .map(
                (a) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.article_outlined, size: 20),
                  title: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    a.status,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Text(
                    '${a.viewCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildRecentComments(
    BuildContext context,
    List<AdminComment> comments,
  ) {
    if (comments.isEmpty) return const SizedBox.shrink();
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近评论', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...comments
              .take(5)
              .map(
                (c) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.comment_outlined, size: 20),
                  title: Text(
                    c.authorName ?? '匿名',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    c.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers(BuildContext context, List<AdminUser> users) {
    if (users.isEmpty) return const SizedBox.shrink();
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近注册用户', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...users
              .take(5)
              .map(
                (u) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundImage: u.avatarUrl != null
                        ? NetworkImage(u.avatarUrl!)
                        : null,
                    child: u.avatarUrl == null
                        ? Text(
                            (u.displayName ?? u.username).isNotEmpty
                                ? (u.displayName ?? u.username)[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                  title: Text(
                    u.displayName ?? u.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(u.status),
                ),
              ),
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  const _LineChartWidget({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('暂无趋势数据')));
    }

    final cs = Theme.of(context).colorScheme;
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final views = data[i]['views'] ?? data[i]['count'] ?? 0;
      spots.add(FlSpot(i.toDouble(), (views as num).toDouble()));
    }

    final maxY = spots.fold<double>(0, (m, s) => s.y > m ? s.y : m);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (data.length / 5).ceilToDouble().clamp(1, 100),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = data[idx]['date']?.toString() ?? '';
                  return Text(
                    date.length >= 5 ? date.substring(date.length - 5) : date,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: cs.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: cs.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          minY: 0,
        ),
      ),
    );
  }
}
