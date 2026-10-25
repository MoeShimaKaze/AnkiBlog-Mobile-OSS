import 'package:ankiblog_mobile/data/repositories/interaction_repository.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final articleLikeStatusProvider = FutureProvider.family<bool, String>((
  ref,
  articleId,
) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return false;
  return ref
      .watch(interactionRepositoryProvider)
      .getArticleLikeStatus(articleId);
});

class LikeButton extends ConsumerStatefulWidget {
  const LikeButton({super.key, required this.articleId, this.initialCount = 0});

  final String articleId;
  final int initialCount;

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  bool _isToggling = false;

  Future<void> _toggle() async {
    if (!ref.read(isAuthenticatedProvider)) {
      if (mounted) context.push('/login');
      return;
    }

    setState(() => _isToggling = true);
    try {
      final liked = await ref
          .read(interactionRepositoryProvider)
          .toggleArticleLike(widget.articleId);
      ref.invalidate(articleLikeStatusProvider(widget.articleId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(liked ? '已点赞' : '已取消点赞')));
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
    final likedAsync = ref.watch(articleLikeStatusProvider(widget.articleId));
    final isLiked = likedAsync.valueOrNull ?? false;

    return IconButton(
      onPressed: _isToggling ? null : _toggle,
      icon: _isToggling
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: isLiked ? Theme.of(context).colorScheme.primary : null,
            ),
    );
  }
}
