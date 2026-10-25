import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return _buildGuestView(context);
    }

    final user = authState.user!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
              ),
              title: Text(user.displayName),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User info card
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.push('/user/info'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu items
                  _MenuTile(
                    icon: Icons.article_outlined,
                    title: '我的评论',
                    onTap: () => context.push('/user/comments'),
                  ),
                  _MenuTile(
                    icon: Icons.thumb_up_outlined,
                    title: '我的点赞',
                    onTap: () => context.push('/user/likes'),
                  ),
                  _MenuTile(
                    icon: Icons.bookmark_outline,
                    title: '我的收藏',
                    onTap: () => context.push('/user/favorites'),
                  ),
                  _MenuTile(
                    icon: Icons.person_outline,
                    title: '个人资料',
                    onTap: () => context.push('/user/info'),
                  ),
                  _MenuTile(
                    icon: Icons.settings_outlined,
                    title: '设置',
                    onTap: () => context.push('/settings'),
                  ),

                  if (authState.isAdmin) ...[
                    const SizedBox(height: 16),
                    Text(
                      '管理',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MenuTile(
                      icon: Icons.checkroom_outlined,
                      title: '穿搭管理',
                      onTap: () => context.push('/admin/outfits'),
                    ),
                    _MenuTile(
                      icon: Icons.brush_outlined,
                      title: '妆容管理',
                      onTap: () => context.push('/admin/makeups'),
                    ),
                    _MenuTile(
                      icon: Icons.list_outlined,
                      title: '待办管理',
                      onTap: () => context.push('/admin/todos'),
                    ),
                    _MenuTile(
                      icon: Icons.flag_outlined,
                      title: '打卡目标',
                      onTap: () => context.push('/admin/goals'),
                    ),
                    _MenuTile(
                      icon: Icons.checkroom_outlined,
                      title: '衣橱分析',
                      onTap: () => context.push('/admin/wardrobe'),
                    ),
                    _MenuTile(
                      icon: Icons.brush_outlined,
                      title: '化妆品分析',
                      onTap: () => context.push('/admin/cosmetics'),
                    ),
                    _MenuTile(
                      icon: Icons.shopping_bag_outlined,
                      title: '已购产品',
                      onTap: () => context.push('/admin/purchases'),
                    ),
                    _MenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: '记账',
                      onTap: () => context.push('/admin/accounting'),
                    ),
                    const Divider(height: 24),
                    _MenuTile(
                      icon: Icons.dashboard_outlined,
                      title: '仪表盘',
                      onTap: () => context.push('/admin/dashboard'),
                    ),
                    _MenuTile(
                      icon: Icons.article_outlined,
                      title: '文章管理',
                      onTap: () => context.push('/admin/articles'),
                    ),
                    _MenuTile(
                      icon: Icons.shopping_bag_outlined,
                      title: '产品管理',
                      onTap: () => context.push('/admin/products'),
                    ),
                    _MenuTile(
                      icon: Icons.category_outlined,
                      title: '产品分类',
                      onTap: () => context.push('/admin/product-categories'),
                    ),
                    _MenuTile(
                      icon: Icons.comment_outlined,
                      title: '评论管理',
                      onTap: () => context.push('/admin/comments'),
                    ),
                    _MenuTile(
                      icon: Icons.people_outline,
                      title: '用户管理',
                      onTap: () => context.push('/admin/users'),
                    ),
                    _MenuTile(
                      icon: Icons.web_outlined,
                      title: '站点配置',
                      onTap: () => context.push('/admin/site'),
                    ),
                    _MenuTile(
                      icon: Icons.wallpaper_outlined,
                      title: '背景管理',
                      onTap: () => context.push('/admin/backgrounds'),
                    ),
                    _MenuTile(
                      icon: Icons.link_outlined,
                      title: '友情链接',
                      onTap: () => context.push('/admin/friend-links'),
                    ),
                    _MenuTile(
                      icon: Icons.share_outlined,
                      title: '社交链接',
                      onTap: () => context.push('/admin/social-links'),
                    ),
                    _MenuTile(
                      icon: Icons.description_outlined,
                      title: '页面类型',
                      onTap: () => context.push('/admin/pages'),
                    ),
                    _MenuTile(
                      icon: Icons.pages_outlined,
                      title: '自定义页面',
                      onTap: () => context.push('/admin/custom-pages'),
                    ),
                    _MenuTile(
                      icon: Icons.notifications_outlined,
                      title: '通知管理',
                      onTap: () => context.push('/admin/notifications'),
                    ),
                    _MenuTile(
                      icon: Icons.mark_email_read_outlined,
                      title: '订阅管理',
                      onTap: () => context.push('/admin/subscriptions'),
                    ),
                    _MenuTile(
                      icon: Icons.storage_outlined,
                      title: '缓存管理',
                      onTap: () => context.push('/admin/cache'),
                    ),
                    _MenuTile(
                      icon: Icons.folder_outlined,
                      title: '文件管理',
                      onTap: () => context.push('/admin/files'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text('未登录', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '登录后即可使用评论、点赞、收藏等功能',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('登录'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/register'),
              child: const Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
