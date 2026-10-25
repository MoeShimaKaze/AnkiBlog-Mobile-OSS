import 'dart:async';
import 'dart:convert';

import 'package:ankiblog_mobile/core/constants/api_constants.dart';
import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/article.dart';
import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:ankiblog_mobile/data/models/custom_page.dart';
import 'package:ankiblog_mobile/data/models/daily_outfit.dart';
import 'package:ankiblog_mobile/data/models/link.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/data/models/public_content.dart';
import 'package:ankiblog_mobile/data/models/search_result.dart';
import 'package:ankiblog_mobile/data/models/site_config.dart';
import 'package:ankiblog_mobile/data/sources/local/json_cache_local_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final publicRepositoryProvider = Provider<PublicRepository>((ref) {
  return PublicRepository(
    ref.watch(dioProvider),
    ref.watch(jsonCacheLocalSourceProvider),
  );
});

class PublicRepository {
  const PublicRepository(this._dio, this._cache);

  final Dio _dio;
  final JsonCacheLocalSource _cache;

  static const _publicCacheMaxAge = Duration(hours: 24);

  Future<T> _cachedGet<T>({
    required String path,
    Map<String, Object?> queryParameters = const {},
    Options? options,
    required T Function(Object? data) parser,
  }) async {
    final key = jsonEncode([path, queryParameters]);
    final cached = await _cache.getFresh(key, maxAge: _publicCacheMaxAge);
    if (cached != null) {
      unawaited(_refreshCache(path, queryParameters, options, key));
      return parser(cached);
    }

    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      await _cache.put(key, response.data);
      return parser(response.data);
    } catch (_) {
      final fallback = await _cache.getAny(key);
      if (fallback != null) return parser(fallback);
      rethrow;
    }
  }

  Future<void> _refreshCache(
    String path,
    Map<String, Object?> queryParameters,
    Options? options,
    String key,
  ) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      await _cache.put(key, response.data);
    } catch (_) {
      // Cached content should remain usable when refresh fails.
    }
  }

  Future<SiteConfig> getSiteConfig() async {
    return _cachedGet(
      path: '/public/site/config',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) =>
            SiteConfig.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<SiteConfig> getSiteBasicInfo() async {
    return _cachedGet(
      path: '/public/site/basic',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) =>
            SiteConfig.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<PageResponse<Article>> getArticles({
    int page = 0,
    int size = ApiConstants.pageSize,
    bool? featured,
  }) async {
    final queryParameters = <String, Object>{
      'page': page,
      'size': size,
      'sort': 'publishedAt,desc',
    };
    if (featured != null) {
      queryParameters['featured'] = featured;
    }
    return _cachedGet(
      path: '/public/articles',
      queryParameters: queryParameters,
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => PageResponse.fromJson(data, Article.fromJson),
      ),
    );
  }

  Future<Article> getArticle(String slug) async {
    return _cachedGet(
      path: '/public/articles/$slug',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => Article.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<PageResponse<Product>> getProducts({
    int page = 0,
    int size = ApiConstants.pageSize,
    bool? featured,
    bool? isPurchased,
    String? keyword,
    String? categoryId,
    List<String> tags = const [],
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParameters = <String, Object>{
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (featured != null) {
      queryParameters['featured'] = featured;
    }
    if (isPurchased != null) {
      queryParameters['isPurchased'] = isPurchased;
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParameters['keyword'] = keyword.trim();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParameters['categoryId'] = categoryId;
    }
    if (tags.isNotEmpty) {
      queryParameters['tags'] = tags;
    }
    if (minPrice != null) {
      queryParameters['minPrice'] = minPrice;
    }
    if (maxPrice != null) {
      queryParameters['maxPrice'] = maxPrice;
    }
    return _cachedGet(
      path: '/public/products',
      queryParameters: queryParameters,
      options: Options(listFormat: ListFormat.multi),
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => PageResponse.fromJson(data, Product.fromJson),
      ),
    );
  }

  Future<Product> getProduct(String slug) async {
    return _cachedGet(
      path: '/public/products/$slug',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => Product.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<Product> markProductPurchased(String productId, bool purchased) async {
    final response = await _dio.post<Object?>(
      '/public/products/$productId/purchase-mark',
      queryParameters: {'purchased': purchased},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => Product.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<PageResponse<CustomPage>> getCustomPages({
    int page = 0,
    int size = ApiConstants.pageSize,
    String? keyword,
  }) async {
    final isSearch = keyword != null && keyword.trim().isNotEmpty;
    return _cachedGet(
      path: isSearch ? '/public/pages/search' : '/public/pages',
      queryParameters: {
        'page': page,
        'size': size,
        if (isSearch) 'keyword': keyword.trim(),
      },
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => PageResponse.fromJson(data, CustomPage.fromJson),
      ),
    );
  }

  Future<List<CustomPage>> getFeaturedCustomPages() async {
    return _cachedGet(
      path: '/public/pages/featured',
      parser: (data) => ApiResponse.unwrap(data, (data) {
        final items = data as List? ?? const [];
        return items
            .whereType<Map<String, dynamic>>()
            .map(CustomPage.fromJson)
            .toList(growable: false);
      }),
    );
  }

  Future<CustomPage> getCustomPage(String slug) async {
    return _cachedGet(
      path: '/public/pages/$slug',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) =>
            CustomPage.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<List<DailyOutfitSuggestion>> getDailyOutfitSuggestions({
    int limit = 12,
  }) async {
    return _cachedGet(
      path: '/public/daily-outfit/recent',
      queryParameters: {'limit': limit},
      parser: (data) => ApiResponse.unwrap(data, (data) {
        final items = data as List? ?? const [];
        return items
            .whereType<Map<String, dynamic>>()
            .map(DailyOutfitSuggestion.fromJson)
            .toList(growable: false);
      }),
    );
  }

  Future<DailyOutfitSuggestion> getDailyOutfitSuggestion(String id) async {
    return _cachedGet(
      path: '/public/daily-outfit/$id',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => DailyOutfitSuggestion.fromJson(
          data as Map<String, dynamic>? ?? const {},
        ),
      ),
    );
  }

  Future<List<FriendLink>> getFriendLinks() async {
    return _cachedGet(
      path: '/public/friend-links',
      parser: (data) {
        return ApiResponse.unwrap(data, (data) {
          final items = data as List? ?? const [];
          return items
              .whereType<Map<String, dynamic>>()
              .map(FriendLink.fromJson)
              .toList(growable: false);
        });
      },
    );
  }

  Future<List<SocialLink>> getSocialLinks() async {
    return _cachedGet(
      path: '/public/social-links',
      parser: (data) {
        return ApiResponse.unwrap(data, (data) {
          final items = data as List? ?? const [];
          return items
              .whereType<Map<String, dynamic>>()
              .map(SocialLink.fromJson)
              .toList(growable: false);
        });
      },
    );
  }

  Future<List<ProductCategory>> getProductCategories() async {
    return _cachedGet(
      path: '/public/products/categories/tree',
      parser: (data) {
        return ApiResponse.unwrap(data, (data) {
          final items = data as List? ?? const [];
          return items
              .whereType<Map<String, dynamic>>()
              .map(ProductCategory.fromJson)
              .toList(growable: false);
        });
      },
    );
  }

  Future<List<ProductTag>> getProductTags() async {
    return _cachedGet(
      path: '/public/products/tags',
      parser: (data) {
        return ApiResponse.unwrap(data, (data) {
          final items = data as List? ?? const [];
          return items
              .whereType<Map<String, dynamic>>()
              .map(ProductTag.fromJson)
              .toList(growable: false);
        });
      },
    );
  }

  Future<List<PublicTodo>> getPublicTodos({int page = 0, int size = 20}) async {
    return _cachedGet(
      path: '/public/todos',
      queryParameters: {'page': page, 'size': size},
      parser: (data) => ApiResponse.unwrap(data, (data) {
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            return content
                .whereType<Map<String, dynamic>>()
                .map(PublicTodo.fromJson)
                .toList(growable: false);
          }
        }
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PublicTodo.fromJson)
              .toList(growable: false);
        }
        return const <PublicTodo>[];
      }),
    );
  }

  Future<List<PublicOutfit>> getPublicOutfits({
    int page = 0,
    int size = 20,
  }) async {
    return _cachedGet(
      path: '/public/outfits',
      queryParameters: {'page': page, 'size': size},
      parser: (data) => ApiResponse.unwrap(data, (data) {
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            return content
                .whereType<Map<String, dynamic>>()
                .map(PublicOutfit.fromJson)
                .toList(growable: false);
          }
        }
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PublicOutfit.fromJson)
              .toList(growable: false);
        }
        return const <PublicOutfit>[];
      }),
    );
  }

  Future<PublicOutfit> getPublicOutfitById(String id) async {
    return _cachedGet(
      path: '/public/outfits/$id',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) => PublicOutfit.fromJson(data as Map<String, dynamic>),
      ),
    );
  }

  Future<List<PublicMakeup>> getPublicMakeups({
    int page = 0,
    int size = 20,
  }) async {
    return _cachedGet(
      path: '/public/makeups',
      queryParameters: {'page': page, 'size': size},
      parser: (data) => ApiResponse.unwrap(data, (data) {
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            return content
                .whereType<Map<String, dynamic>>()
                .map(PublicMakeup.fromJson)
                .toList(growable: false);
          }
        }
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PublicMakeup.fromJson)
              .toList(growable: false);
        }
        return const <PublicMakeup>[];
      }),
    );
  }

  Future<GoalsSummary> getGoalsSummary() async {
    return _cachedGet(
      path: '/public/goals/summary',
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) =>
            GoalsSummary.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<SearchResult> search({
    required String query,
    String type = 'ALL',
    int page = 0,
    int size = 20,
  }) async {
    return _cachedGet(
      path: '/public/search',
      queryParameters: {
        'query': query,
        'type': type,
        'page': page,
        'size': size,
      },
      parser: (data) => ApiResponse.unwrap(
        data,
        (data) =>
            SearchResult.fromJson(data as Map<String, dynamic>? ?? const {}),
      ),
    );
  }
}
