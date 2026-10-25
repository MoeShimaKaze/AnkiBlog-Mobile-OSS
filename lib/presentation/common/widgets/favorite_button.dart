import 'package:ankiblog_mobile/data/repositories/interaction_repository.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final productFavoriteStatusProvider = FutureProvider.family<bool, String>((
  ref,
  productId,
) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return false;
  return ref
      .watch(interactionRepositoryProvider)
      .getProductFavoriteStatus(productId);
});

class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool _isToggling = false;

  Future<void> _toggle() async {
    if (!ref.read(isAuthenticatedProvider)) {
      if (mounted) context.push('/login');
      return;
    }

    setState(() => _isToggling = true);
    try {
      final favorited = await ref
          .read(interactionRepositoryProvider)
          .toggleProductFavorite(widget.productId);
      ref.invalidate(productFavoriteStatusProvider(widget.productId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(favorited ? '已收藏' : '已取消收藏')));
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritedAsync = ref.watch(
      productFavoriteStatusProvider(widget.productId),
    );
    final isFavorited = favoritedAsync.valueOrNull ?? false;

    return IconButton(
      onPressed: _isToggling ? null : _toggle,
      icon: _isToggling
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isFavorited ? Icons.bookmark : Icons.bookmark_outline,
              color: isFavorited ? Theme.of(context).colorScheme.primary : null,
            ),
    );
  }
}
