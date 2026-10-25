import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/favorite_button.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/image_gallery.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_viewer.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool? _isPurchased;
  bool _purchaseLoading = false;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productDetailProvider(widget.slug));
    final isAdmin = ref.watch(authProvider).isAdmin;
    return Scaffold(
      appBar: AppBar(
        actions: [
          product.whenOrNull(
                data: (data) => FavoriteButton(productId: data.id),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: AsyncStateView(
        value: product,
        builder: (data) {
          final isPurchased = _isPurchased ?? data.isPurchased;
          final allImages = data.allImages;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image gallery
              if (allImages.isNotEmpty)
                ImageGallery(images: allImages, height: 280)
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 48),
                  ),
                ),
              const SizedBox(height: 16),

              // Name + Price card
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${data.currency} ${data.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (data.hasDiscount == true &&
                            data.originalPrice != null &&
                            data.originalPrice! > data.price) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${data.currency} ${data.originalPrice!.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (data.discountPercentage != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${data.discountPercentage!.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                    if (data.categoryName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.categoryName!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                    if (data.brand != null && data.brand!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.brand!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                    // Stats
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.viewCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.bookmark_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data.favoriteCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (data.wearCount > 0) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.checkroom_outlined,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '穿搭${data.wearCount}次',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    // Status badges
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (isPurchased)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '已购买',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (data.featured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '推荐',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tags
              if (data.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Purchase buttons
              if (data.purchaseUrl != null ||
                  data.affiliateUrl != null ||
                  isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (data.purchaseUrl != null)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(data.purchaseUrl!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('购买链接'),
                        ),
                      ),
                    if (data.purchaseUrl != null && data.affiliateUrl != null)
                      const SizedBox(width: 12),
                    if (data.affiliateUrl != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(data.affiliateUrl!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.link),
                          label: const Text('推广链接'),
                        ),
                      ),
                    if (isAdmin) ...[
                      if (data.purchaseUrl != null || data.affiliateUrl != null)
                        const SizedBox(width: 12),
                      Expanded(
                        child: _purchaseLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : isPurchased
                            ? FilledButton.icon(
                                onPressed: () =>
                                    _togglePurchase(data.id, false),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('已购买'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: () => _togglePurchase(data.id, true),
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text('标记购买'),
                              ),
                      ),
                    ],
                  ],
                ),
              ],

              // Description
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '商品详情',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownViewer(
                      data: data.description.isEmpty
                          ? data.summary
                          : data.description,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _togglePurchase(String productId, bool purchased) async {
    setState(() => _purchaseLoading = true);
    try {
      final repo = ref.read(publicRepositoryProvider);
      final updated = await repo.markProductPurchased(productId, purchased);
      if (mounted) {
        setState(() {
          _isPurchased = updated.isPurchased;
          _purchaseLoading = false;
        });
        ref.invalidate(productDetailProvider(widget.slug));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(purchased ? '已标记为已购买' : '已取消购买标记')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _purchaseLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }
}
