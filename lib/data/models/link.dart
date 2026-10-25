import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class FriendLink {
  const FriendLink({
    required this.id,
    required this.siteName,
    required this.siteUrl,
    required this.description,
    required this.avatarUrl,
  });

  final String id;
  final String siteName;
  final String siteUrl;
  final String description;
  final String? avatarUrl;

  factory FriendLink.fromJson(Map<String, dynamic> json) {
    return FriendLink(
      id: stringValue(json, 'id'),
      siteName: stringValue(json, 'site_name', stringValue(json, 'siteName')),
      siteUrl: stringValue(json, 'site_url', stringValue(json, 'siteUrl')),
      description: stringValue(json, 'description'),
      avatarUrl: nullableString(json, 'avatar_url'),
    );
  }
}

class SocialLink {
  const SocialLink({
    required this.id,
    required this.title,
    required this.url,
    required this.platform,
    required this.color,
  });

  final String id;
  final String title;
  final String url;
  final String platform;
  final String color;

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title', stringValue(json, 'platform_name')),
      url: stringValue(json, 'url'),
      platform: stringValue(json, 'platform'),
      color: stringValue(json, 'color', '#8EA7FF'),
    );
  }
}
