import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class InteractionStatus {
  const InteractionStatus({required this.liked, required this.favorited});

  final bool liked;
  final bool favorited;

  factory InteractionStatus.fromJson(Map<String, dynamic> json) {
    return InteractionStatus(
      liked: boolValue(json, 'liked') || boolValue(json, 'is_liked'),
      favorited:
          boolValue(json, 'favorited') || boolValue(json, 'is_favorited'),
    );
  }
}

class LikedArticle {
  const LikedArticle({
    required this.id,
    required this.title,
    required this.slug,
    this.coverImage,
    required this.likedAt,
  });

  final String id;
  final String title;
  final String slug;
  final String? coverImage;
  final String? likedAt;

  factory LikedArticle.fromJson(Map<String, dynamic> json) {
    final article = json['article'] as Map<String, dynamic>? ?? json;
    return LikedArticle(
      id: stringValue(article, 'id'),
      title: stringValue(article, 'title', 'Untitled'),
      slug: stringValue(article, 'slug', stringValue(article, 'id')),
      coverImage:
          nullableString(article, 'cover_image') ??
          nullableString(article, 'coverImage'),
      likedAt:
          nullableString(json, 'liked_at') ??
          nullableString(json, 'likedAt') ??
          nullableString(json, 'created_at'),
    );
  }
}

class FavoriteProduct {
  const FavoriteProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.mainImage,
    required this.price,
    required this.currency,
    required this.favoritedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String? mainImage;
  final double price;
  final String currency;
  final String? favoritedAt;

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? json;
    return FavoriteProduct(
      id: stringValue(product, 'id'),
      name: stringValue(product, 'name', 'Untitled'),
      slug: stringValue(product, 'slug', stringValue(product, 'id')),
      mainImage:
          nullableString(product, 'main_image') ??
          nullableString(product, 'mainImage'),
      price: doubleValue(product, 'price'),
      currency: stringValue(product, 'currency', 'CNY'),
      favoritedAt:
          nullableString(json, 'favorited_at') ??
          nullableString(json, 'favoritedAt') ??
          nullableString(json, 'created_at'),
    );
  }
}
