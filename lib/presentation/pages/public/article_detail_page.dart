import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/comment_section.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/like_button.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_viewer.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(articleDetailProvider(slug));
    return Scaffold(
      appBar: AppBar(
        actions: [
          article.whenOrNull(
                data: (data) => LikeButton(
                  articleId: data.id,
                  initialCount: data.likeCount,
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: AsyncStateView(
        value: article,
        builder: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RemoteImage(
              url: data.coverImage,
              height: 220,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text(data.authorName),
                      Text('${data.viewCount} 浏览'),
                      Text('${data.likeCount} 喜欢'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(child: MarkdownViewer(data: data.content)),
            const SizedBox(height: 24),
            CommentSection(articleId: data.id),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
