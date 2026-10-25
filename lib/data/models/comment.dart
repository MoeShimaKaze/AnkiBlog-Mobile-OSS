import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class Comment {
  const Comment({
    required this.id,
    required this.content,
    this.authorId,
    this.authorName,
    this.authorAvatar,
    this.parentId,
    this.depth,
    this.status,
    this.approved,
    this.pinned,
    this.likeCount,
    this.replyCount,
    this.replies,
    this.createdAt,
    this.updatedAt,
    this.articleId,
    this.articleTitle,
    this.articleSlug,
  });

  final String id;
  final String content;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;
  final String? parentId;
  final int? depth;
  final String? status;
  final bool? approved;
  final bool? pinned;
  final int? likeCount;
  final int? replyCount;
  final List<Comment>? replies;
  final String? createdAt;
  final String? updatedAt;
  final String? articleId;
  final String? articleTitle;
  final String? articleSlug;

  factory Comment.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    final replies = rawReplies is List
        ? rawReplies
              .whereType<Map<String, dynamic>>()
              .map(Comment.fromJson)
              .toList(growable: false)
        : null;

    return Comment(
      id: stringValue(json, 'id'),
      content: stringValue(json, 'content'),
      authorId:
          nullableString(json, 'author_id') ?? nullableString(json, 'authorId'),
      authorName:
          nullableString(json, 'author_name') ??
          nullableString(json, 'authorName') ??
          nullableString(json, 'username'),
      authorAvatar:
          nullableString(json, 'author_avatar') ??
          nullableString(json, 'authorAvatar'),
      parentId:
          nullableString(json, 'parent_id') ?? nullableString(json, 'parentId'),
      depth: _optionalInt(json, 'depth'),
      status: nullableString(json, 'status'),
      approved: _optionalBool(json, 'approved'),
      pinned: _optionalBool(json, 'pinned'),
      likeCount:
          _optionalInt(json, 'like_count') ?? _optionalInt(json, 'likeCount'),
      replyCount:
          _optionalInt(json, 'reply_count') ?? _optionalInt(json, 'replyCount'),
      replies: replies,
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
      updatedAt:
          nullableString(json, 'updated_at') ??
          nullableString(json, 'updatedAt'),
      articleId:
          nullableString(json, 'article_id') ??
          nullableString(json, 'articleId'),
      articleTitle:
          nullableString(json, 'article_title') ??
          nullableString(json, 'articleTitle'),
      articleSlug:
          nullableString(json, 'article_slug') ??
          nullableString(json, 'articleSlug'),
    );
  }

  static int? _optionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _optionalBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }
}
