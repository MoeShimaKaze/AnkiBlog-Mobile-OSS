import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.coverImage,
    required this.authorName,
    required this.tags,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String? coverImage;
  final String authorName;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final String? publishedAt;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title', 'Untitled'),
      slug: stringValue(json, 'slug', stringValue(json, 'id')),
      excerpt: stringValue(json, 'excerpt', stringValue(json, 'summary')),
      content: stringValue(
        json,
        'content',
        stringValue(json, 'rendered_content'),
      ),
      coverImage:
          nullableString(json, 'cover_image') ??
          nullableString(json, 'coverImage'),
      authorName: stringValue(json, 'author_name', 'Anki'),
      tags: _tags(json['tags']),
      viewCount: intValue(json, 'view_count'),
      likeCount: intValue(json, 'like_count'),
      commentCount: intValue(json, 'comment_count'),
      publishedAt: nullableString(json, 'published_at'),
    );
  }

  static List<String> _tags(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map((item) {
          if (item is Map<String, dynamic>) return item['name']?.toString();
          return item?.toString();
        })
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
