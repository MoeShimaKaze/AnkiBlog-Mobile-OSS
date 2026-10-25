import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/comment.dart';
import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(dioProvider));
});

class CommentRepository {
  const CommentRepository(this._dio);

  final Dio _dio;

  Future<List<Comment>> getArticleComments(
    String articleId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/public/comments/article/$articleId',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(Comment.fromJson)
            .toList(growable: false);
      }
      // Fallback for paginated response
      if (data is Map<String, dynamic>) {
        final content = data['content'];
        if (content is List) {
          return content
              .whereType<Map<String, dynamic>>()
              .map(Comment.fromJson)
              .toList(growable: false);
        }
      }
      return const <Comment>[];
    });
  }

  Future<Comment> createComment(String articleId, String content) async {
    final response = await _dio.post<Object?>(
      '/public/comments/article/$articleId',
      data: {'content': content},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => Comment.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<PageResponse<Comment>> getMyComments({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/user/comments',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, Comment.fromJson),
    );
  }

  Future<void> deleteComment(String commentId) async {
    await _dio.delete<Object?>('/user/comments/$commentId');
  }
}
