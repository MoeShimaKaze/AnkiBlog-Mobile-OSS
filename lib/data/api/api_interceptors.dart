import 'dart:async';

import 'package:ankiblog_mobile/core/constants/api_constants.dart';
import 'package:ankiblog_mobile/data/sources/local/auth_local_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authLocalSource, {this.onSessionExpired});

  final AuthLocalSource _authLocalSource;
  final FutureOr<void> Function()? onSessionExpired;

  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _authLocalSource.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('AuthInterceptor: token attached for ${options.path}');
      } else {
        debugPrint('AuthInterceptor: NO token for ${options.path}');
      }
    } catch (e) {
      debugPrint('AuthInterceptor: failed to read token: $e');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint(
      'AuthInterceptor ERROR: ${err.response?.statusCode} ${err.requestOptions.path} ${err.message} type=${err.type}',
    );

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _handleSessionExpired();
      debugPrint('AuthInterceptor: refresh failed, cleared tokens');
      return handler.next(err);
    }

    final refreshed = await _refreshToken();
    if (!refreshed) {
      await _handleSessionExpired();
      debugPrint('AuthInterceptor: token refresh failed, cleared tokens');
      return handler.next(err);
    }

    try {
      final response = await _retry(err.requestOptions);
      debugPrint(
        'AuthInterceptor: retry succeeded for ${err.requestOptions.path}',
      );
      handler.resolve(response);
    } on DioException catch (e) {
      debugPrint('AuthInterceptor: retry failed: ${e.message}');
      handler.next(e);
    }
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _authLocalSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post<Object?>(
        '/auth/refresh',
        queryParameters: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final tokenData = data['data'];
        final newAccessToken = switch (tokenData) {
          final String token => token,
          final Map<String, dynamic> tokenMap =>
            tokenMap['access_token']?.toString() ??
                tokenMap['accessToken']?.toString(),
          _ => null,
        };
        final newRefreshToken = tokenData is Map<String, dynamic>
            ? tokenData['refresh_token']?.toString() ??
                  tokenData['refreshToken']?.toString()
            : refreshToken;

        if (newAccessToken != null && newRefreshToken != null) {
          await _authLocalSource.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _handleSessionExpired() async {
    await _authLocalSource.clearAll();
    await onSessionExpired?.call();
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _authLocalSource.getAccessToken();
    requestOptions.headers['Authorization'] = 'Bearer $token';

    final retryDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    return retryDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
}
