import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class SiteConfig {
  const SiteConfig({
    required this.siteName,
    required this.siteTagline,
    required this.siteDescription,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.logoUrl,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerBio,
  });

  final String siteName;
  final String siteTagline;
  final String siteDescription;
  final String heroTitle;
  final String heroSubtitle;
  final String? logoUrl;
  final String? ownerName;
  final String? ownerAvatar;
  final String? ownerBio;

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    return SiteConfig(
      siteName: _stringAny(json, 'site_name', 'siteName', 'AnkiBlog'),
      siteTagline: _stringAny(json, 'site_tagline', 'siteTagline'),
      siteDescription: _stringAny(json, 'site_description', 'siteDescription'),
      heroTitle: _stringAny(
        json,
        'hero_title',
        'heroTitle',
        _stringAny(json, 'site_name', 'siteName', 'AnkiBlog'),
      ),
      heroSubtitle: _stringAny(
        json,
        'hero_subtitle',
        'heroSubtitle',
        _stringAny(json, 'site_tagline', 'siteTagline'),
      ),
      logoUrl: _nullableStringAny(json, 'logo_url', 'logoUrl'),
      ownerName: _nullableStringAny(json, 'owner_name', 'ownerName'),
      ownerAvatar: _nullableStringAny(json, 'owner_avatar', 'ownerAvatar'),
      ownerBio: _nullableStringAny(json, 'owner_bio', 'ownerBio'),
    );
  }
}

String _stringAny(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey, [
  String fallback = '',
]) {
  return nullableString(json, snakeKey) ??
      nullableString(json, camelKey) ??
      fallback;
}

String? _nullableStringAny(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
) {
  return nullableString(json, snakeKey) ?? nullableString(json, camelKey);
}
