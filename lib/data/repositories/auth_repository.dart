import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/user.dart';
import 'package:ankiblog_mobile/data/sources/local/auth_local_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(authLocalSourceProvider),
  );
});

class AuthRepository {
  const AuthRepository(this._dio, this._authLocalSource);

  final Dio _dio;
  final AuthLocalSource _authLocalSource;

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    final loginResponse = ApiResponse.unwrap(
      response.data,
      (data) =>
          LoginResponse.fromJson(data as Map<String, dynamic>? ?? const {}),
    );

    await _authLocalSource.saveTokens(
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
    );
    await _authLocalSource.saveUser(
      id: loginResponse.user.id,
      email: loginResponse.user.email,
      displayName: loginResponse.user.displayName,
      avatarUrl: loginResponse.user.avatarUrl,
      role: loginResponse.user.role,
      isApproved: loginResponse.user.isApproved,
      bio: loginResponse.user.bio,
      website: loginResponse.user.website,
      createdAt: loginResponse.user.createdAt,
    );

    return loginResponse;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
    required String verificationCode,
  }) async {
    await _dio.post<Object?>(
      '/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'display_name': displayName,
      },
      queryParameters: {'verificationCode': verificationCode},
    );
  }

  Future<void> sendRegisterCode(String email) async {
    await _dio.post<Object?>(
      '/auth/send-register-code',
      queryParameters: {'email': email},
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post<Object?>('/auth/logout');
    } catch (_) {
      // Ignore logout API errors
    }
    await _authLocalSource.clearAll();
  }

  Future<bool> isLoggedIn() => _authLocalSource.hasToken();

  Future<User?> getStoredUser() async {
    final userData = await _authLocalSource.getUser();
    if (userData['id'] == null) return null;
    return User(
      id: userData['id']!,
      email: userData['email'] ?? '',
      displayName: userData['displayName'] ?? '',
      role: userData['role'] ?? 'USER',
      avatarUrl: userData['avatarUrl'],
      isApproved: userData['isApproved'] == 'true',
      bio: userData['bio'],
      website: userData['website'],
      createdAt: userData['createdAt'],
    );
  }
}
