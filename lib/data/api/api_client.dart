import 'package:ankiblog_mobile/core/constants/api_constants.dart';
import 'package:ankiblog_mobile/data/api/api_interceptors.dart';
import 'package:ankiblog_mobile/data/api/auth_session_events.dart';
import 'package:ankiblog_mobile/data/sources/local/auth_local_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authLocalSourceProvider = Provider<AuthLocalSource>((ref) {
  return AuthLocalSource(ref.watch(secureStorageProvider));
});

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    ref.watch(authLocalSourceProvider),
    onSessionExpired: () {
      ref.read(authSessionExpiredRevisionProvider.notifier).state++;
    },
  );
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    ref.watch(authInterceptorProvider),
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final path = response.requestOptions.path;
        final payload = response.data;
        debugPrint(
          '[DEBUG] Response: $path statusCode=${response.statusCode} data=${payload.runtimeType}',
        );
        if (payload is Map<String, dynamic>) {
          debugPrint(
            '[DEBUG] Response: $path keys=${payload.keys.toList()} success=${payload['success']}',
          );
          if (payload['data'] is Map) {
            final data = payload['data'] as Map;
            debugPrint(
              '[DEBUG] Response: $path data.keys=${data.keys.toList()}',
            );
            if (data.containsKey('content')) {
              final content = data['content'];
              debugPrint(
                '[DEBUG] Response: $path content type=${content.runtimeType} length=${content is List ? content.length : "N/A"}',
              );
            }
          } else if (payload['data'] is List) {
            debugPrint(
              '[DEBUG] Response: $path data is List, length=${(payload['data'] as List).length}',
            );
          }
          if (payload['success'] == false) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                message: payload['message']?.toString() ?? 'Request failed',
              ),
            );
            return;
          }
        }
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
          '[DEBUG] DioError: ${error.requestOptions.path} type=${error.type} statusCode=${error.response?.statusCode} message=${error.message}',
        );
        handler.next(error);
      },
    ),
  ]);

  return dio;
});
