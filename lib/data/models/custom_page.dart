import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class CustomPage {
  const CustomPage({
    required this.id,
    required this.title,
    required this.slug,
    required this.subtitle,
    required this.summary,
    required this.content,
    required this.pageIcon,
    required this.viewCount,
    this.coverImage,
    this.featured = false,
    this.template,
    this.customCss,
    this.customJs,
    this.hasCustomCode = false,
    this.needsSecurityReview = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String slug;
  final String subtitle;
  final String summary;
  final String content;
  final String? pageIcon;
  final int viewCount;
  final String? coverImage;
  final bool featured;
  final String? template;
  final String? customCss;
  final String? customJs;
  final bool hasCustomCode;
  final bool needsSecurityReview;
  final String? createdAt;
  final String? updatedAt;

  factory CustomPage.fromJson(Map<String, dynamic> json) {
    return CustomPage(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title', 'Untitled'),
      slug: stringValue(json, 'slug', stringValue(json, 'id')),
      subtitle: stringValue(json, 'subtitle'),
      summary: stringValue(json, 'summary'),
      content: stringValue(json, 'content'),
      pageIcon: nullableString(json, 'page_icon'),
      viewCount: intValue(json, 'view_count'),
      coverImage:
          nullableString(json, 'cover_image') ??
          nullableString(json, 'coverImage'),
      featured: boolValue(json, 'featured') || boolValue(json, 'is_featured'),
      template: nullableString(json, 'template'),
      customCss:
          nullableString(json, 'custom_css') ??
          nullableString(json, 'customCss'),
      customJs:
          nullableString(json, 'custom_js') ?? nullableString(json, 'customJs'),
      hasCustomCode:
          boolValue(json, 'has_custom_code') ||
          boolValue(json, 'hasCustomCode'),
      needsSecurityReview:
          boolValue(json, 'needs_security_review') ||
          boolValue(json, 'needsSecurityReview'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
      updatedAt:
          nullableString(json, 'updated_at') ??
          nullableString(json, 'updatedAt'),
    );
  }
}
