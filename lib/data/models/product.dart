import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.summary,
    required this.mainImage,
    this.images,
    this.brand,
    this.model,
    required this.price,
    this.originalPrice,
    required this.currency,
    this.categoryName,
    this.category,
    required this.tags,
    this.purchaseUrl,
    this.affiliateUrl,
    required this.viewCount,
    required this.favoriteCount,
    this.hasDiscount,
    this.discountPercentage,
    this.isPurchased = false,
    this.featured = false,
    this.wearCount = 0,
    this.status,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String summary;
  final String? mainImage;
  final List<String>? images;
  final String? brand;
  final String? model;
  final double price;
  final double? originalPrice;
  final String currency;
  final String? categoryName;
  final ProductCategory? category;
  final List<String> tags;
  final String? purchaseUrl;
  final String? affiliateUrl;
  final int viewCount;
  final int favoriteCount;
  final bool? hasDiscount;
  final double? discountPercentage;
  final bool isPurchased;
  final bool featured;
  final int wearCount;
  final String? status;

  List<String> get allImages {
    final list = <String>[];
    if (mainImage != null && mainImage!.isNotEmpty) list.add(mainImage!);
    if (images != null) {
      for (final img in images!) {
        if (img.isNotEmpty && !list.contains(img)) list.add(img);
      }
    }
    return list;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : null;

    final rawTags = json['tags'];
    final tags = rawTags is List
        ? rawTags
              .map((e) {
                if (e is Map<String, dynamic>) {
                  return e['name']?.toString() ?? '';
                }
                return e.toString();
              })
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    final rawCategory = json['category'];
    final category = rawCategory is Map<String, dynamic>
        ? ProductCategory.fromJson(rawCategory)
        : null;

    return Product(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name', 'Untitled'),
      slug: stringValue(json, 'slug', stringValue(json, 'id')),
      description: stringValue(json, 'description'),
      summary: stringValue(json, 'summary'),
      mainImage:
          nullableString(json, 'main_image') ??
          nullableString(json, 'mainImage'),
      images: images,
      brand: nullableString(json, 'brand'),
      model: nullableString(json, 'model'),
      price: doubleValue(json, 'price'),
      originalPrice:
          _optionalDouble(json, 'original_price') ??
          _optionalDouble(json, 'originalPrice'),
      currency: stringValue(json, 'currency', 'CNY'),
      categoryName: nullableString(json, 'category_name') ?? category?.name,
      category: category,
      tags: tags,
      purchaseUrl:
          nullableString(json, 'purchase_url') ??
          nullableString(json, 'purchaseUrl'),
      affiliateUrl:
          nullableString(json, 'affiliate_url') ??
          nullableString(json, 'affiliateUrl'),
      viewCount: intValue(json, 'view_count') | intValue(json, 'viewCount'),
      favoriteCount:
          intValue(json, 'favorite_count') | intValue(json, 'favoriteCount'),
      hasDiscount:
          _optionalBool(json, 'has_discount') ??
          _optionalBool(json, 'hasDiscount'),
      discountPercentage:
          _optionalDouble(json, 'discount_percentage') ??
          _optionalDouble(json, 'discountPercentage'),
      isPurchased:
          _optionalBool(json, 'is_purchased') ??
          _optionalBool(json, 'isPurchased') ??
          false,
      featured: _optionalBool(json, 'featured') ?? false,
      wearCount:
          _optionalInt(json, 'wear_count') ??
          _optionalInt(json, 'wearCount') ??
          0,
      status: nullableString(json, 'status'),
    );
  }

  static double? _optionalDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool? _optionalBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  static int? _optionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.icon,
    this.coverImage,
    this.productCount = 0,
    this.children = const [],
  });

  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? icon;
  final String? coverImage;
  final int productCount;
  final List<ProductCategory> children;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = rawChildren is List
        ? rawChildren
              .whereType<Map<String, dynamic>>()
              .map(ProductCategory.fromJson)
              .toList(growable: false)
        : const <ProductCategory>[];

    return ProductCategory(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      slug: nullableString(json, 'slug'),
      description: nullableString(json, 'description'),
      icon: nullableString(json, 'icon'),
      coverImage:
          nullableString(json, 'cover_image') ??
          nullableString(json, 'coverImage'),
      productCount:
          intValue(json, 'product_count') | intValue(json, 'productCount'),
      children: children,
    );
  }
}

class ProductTag {
  const ProductTag({
    required this.id,
    required this.name,
    this.slug,
    this.color,
    this.usageCount = 0,
  });

  final String id;
  final String name;
  final String? slug;
  final String? color;
  final int usageCount;

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      slug: nullableString(json, 'slug'),
      color: nullableString(json, 'color'),
      usageCount: intValue(json, 'usage_count') | intValue(json, 'usageCount'),
    );
  }
}
