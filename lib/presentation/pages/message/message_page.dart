import 'package:ankiblog_mobile/data/models/subscription.dart';
import 'package:ankiblog_mobile/data/repositories/subscription_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final mySubscriptionsProvider = FutureProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).getMySubscriptions();
});

final subscriptionTypesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).getSubscriptionTypes();
});

class MessagePage extends ConsumerWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text('登录后查看消息'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('去登录'),
            ),
          ],
        ),
      );
    }

    final subscriptions = ref.watch(mySubscriptionsProvider);
    final types = ref.watch(subscriptionTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息与通知'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSubscribeDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mySubscriptionsProvider);
          ref.invalidate(subscriptionTypesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: Subscriptions
            Text(
              '邮件订阅',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '订阅后将通过邮件接收通知',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            subscriptions.when(
              data: (subs) {
                if (subs.isEmpty) {
                  return GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text('暂无订阅'),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _showSubscribeDialog(context, ref),
                          child: const Text('添加订阅'),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: subs
                      .map(
                        (sub) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SubscriptionTile(subscription: sub),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Text('加载失败: $e'),
              ),
            ),

            const SizedBox(height: 24),

            // Section: Available types
            types.when(
              data: (typeList) {
                if (typeList.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '可订阅类型',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...typeList.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                _typeIcon(type),
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_typeLabel(type))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscribeDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    String selectedType = 'USER_NEW_ARTICLE';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('添加邮件订阅'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  hintText: '输入接收通知的邮箱',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: '订阅类型'),
                items: const [
                  DropdownMenuItem(
                    value: 'USER_NEW_ARTICLE',
                    child: Text('新文章通知'),
                  ),
                  DropdownMenuItem(
                    value: 'USER_NEW_PRODUCT',
                    child: Text('新产品通知'),
                  ),
                  DropdownMenuItem(
                    value: 'USER_COMMENT_REPLY',
                    child: Text('评论回复通知'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedType = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;
                try {
                  await ref
                      .read(subscriptionRepositoryProvider)
                      .subscribe(email: email, subscriptionType: selectedType);
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(mySubscriptionsProvider);
                } on Exception catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text('订阅失败: $e')));
                  }
                }
              },
              child: const Text('订阅'),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'USER_NEW_ARTICLE':
        return '新文章通知';
      case 'USER_NEW_PRODUCT':
        return '新产品通知';
      case 'USER_COMMENT_REPLY':
        return '评论回复通知';
      default:
        return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'USER_NEW_ARTICLE':
        return Icons.article_outlined;
      case 'USER_NEW_PRODUCT':
        return Icons.shopping_bag_outlined;
      case 'USER_COMMENT_REPLY':
        return Icons.comment_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}

class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            subscription.status == 'ACTIVE'
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            color: subscription.status == 'ACTIVE'
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.subscriptionTypeDescription ??
                      subscription.subscriptionType,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subscription.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: subscription.status == 'ACTIVE'
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subscription.statusDescription ?? subscription.status,
              style: TextStyle(
                fontSize: 11,
                color: subscription.status == 'ACTIVE'
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
