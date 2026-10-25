import 'package:ankiblog_mobile/data/models/article.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class SearchResult {
  const SearchResult({
    this.articles = const [],
    this.products = const [],
    this.matchedTags = const [],
    this.summary,
  });

  final List<Article> articles;
  final List<Product> products;
  final List<TagSearchResult> matchedTags;
  final SearchSummary? summary;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'];
    final articles = rawArticles is Map<String, dynamic>
        ? (rawArticles['content'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(Article.fromJson)
              .toList(growable: false)
        : <Article>[];

    final rawProducts = json['products'];
    final products = rawProducts is Map<String, dynamic>
        ? (rawProducts['content'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList(growable: false)
        : <Product>[];

    final rawTags = json['matched_tags'] ?? json['matchedTags'];
    final tags = rawTags is List
        ? rawTags
              .whereType<Map<String, dynamic>>()
              .map(TagSearchResult.fromJson)
              .toList(growable: false)
        : <TagSearchResult>[];

    final rawSummary = json['summary'];
    final summary = rawSummary is Map<String, dynamic>
        ? SearchSummary.fromJson(rawSummary)
        : null;

    return SearchResult(
      articles: articles,
      products: products,
      matchedTags: tags,
      summary: summary,
    );
  }

  bool get isEmpty =>
      articles.isEmpty && products.isEmpty && matchedTags.isEmpty;
}

class TagSearchResult {
  const TagSearchResult({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.articleCount = 0,
    this.productCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final int articleCount;
  final int productCount;

  factory TagSearchResult.fromJson(Map<String, dynamic> json) {
    return TagSearchResult(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      description: nullableString(json, 'description'),
      color: nullableString(json, 'color'),
      icon: nullableString(json, 'icon'),
      articleCount:
          intValue(json, 'article_count') | intValue(json, 'articleCount'),
      productCount:
          intValue(json, 'product_count') | intValue(json, 'productCount'),
    );
  }
}

class SearchSummary {
  const SearchSummary({
    this.query = '',
    this.totalArticles = 0,
    this.totalProducts = 0,
    this.responseTime = 0,
    this.hasTagMatches = false,
    this.matchedTagNames = const [],
  });

  final String query;
  final int totalArticles;
  final int totalProducts;
  final int responseTime;
  final bool hasTagMatches;
  final List<String> matchedTagNames;

  factory SearchSummary.fromJson(Map<String, dynamic> json) {
    final rawNames = json['matched_tag_names'] ?? json['matchedTagNames'];
    final names = rawNames is List
        ? rawNames.map((e) => e.toString()).toList(growable: false)
        : <String>[];

    return SearchSummary(
      query: stringValue(json, 'query'),
      totalArticles:
          intValue(json, 'total_articles') | intValue(json, 'totalArticles'),
      totalProducts:
          intValue(json, 'total_products') | intValue(json, 'totalProducts'),
      responseTime:
          intValue(json, 'response_time') | intValue(json, 'responseTime'),
      hasTagMatches:
          boolValue(json, 'has_tag_matches') ||
          boolValue(json, 'hasTagMatches'),
      matchedTagNames: names,
    );
  }
}
