import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:ankiblog_mobile/data/models/interaction.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final interactionRepositoryProvider = Provider<InteractionRepository>((ref) {
  return InteractionRepository(ref.watch(dioProvider));
});

class InteractionRepository {
  const InteractionRepository(this._dio);

  final Dio _dio;

  Future<bool> toggleArticleLike(String articleId) async {
    final response = await _dio.post<Object?>(
      '/user/interactions/articles/$articleId/like',
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is Map<String, dynamic>) {
        return boolValue(data, 'liked') || boolValue(data, 'is_liked');
      }
      return data == true;
    });
  }

  Future<bool> getArticleLikeStatus(String articleId) async {
    final response = await _dio.get<Object?>(
      '/user/interactions/articles/$articleId/like-status',
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is Map<String, dynamic>) {
        return boolValue(data, 'liked') || boolValue(data, 'is_liked');
      }
      return data == true;
    });
  }

  Future<PageResponse<LikedArticle>> getMyLikedArticles({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/user/interactions/my-liked-articles',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, LikedArticle.fromJson),
    );
  }

  Future<bool> toggleProductFavorite(String productId) async {
    final response = await _dio.post<Object?>(
      '/user/interactions/products/$productId/favorite',
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is Map<String, dynamic>) {
        return boolValue(data, 'favorited') || boolValue(data, 'is_favorited');
      }
      return data == true;
    });
  }

  Future<bool> getProductFavoriteStatus(String productId) async {
    final response = await _dio.get<Object?>(
      '/user/interactions/products/$productId/favorite-status',
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is Map<String, dynamic>) {
        return boolValue(data, 'favorited') || boolValue(data, 'is_favorited');
      }
      return data == true;
    });
  }

  Future<PageResponse<FavoriteProduct>> getMyFavoriteProducts({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/user/interactions/my-favorite-products',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, FavoriteProduct.fromJson),
    );
  }

  static bool boolValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }
}
