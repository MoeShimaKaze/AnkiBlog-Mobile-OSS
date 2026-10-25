import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/user.dart';
import 'package:ankiblog_mobile/data/sources/local/auth_local_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(dioProvider),
    ref.watch(authLocalSourceProvider),
  );
});

class UserRepository {
  const UserRepository(this._dio, this._authLocalSource);

  final Dio _dio;
  final AuthLocalSource _authLocalSource;

  Future<User> getProfile() async {
    final response = await _dio.get<Object?>('/user/profile');
    final user = ApiResponse.unwrap(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>? ?? const {}),
    );

    await _authLocalSource.saveUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isApproved: user.isApproved,
      bio: user.bio,
      website: user.website,
      createdAt: user.createdAt,
    );

    return user;
  }

  Future<User> updateProfile({
    String? displayName,
    String? bio,
    String? website,
  }) async {
    final params = <String, String>{};
    if (displayName != null) params['displayName'] = displayName;
    if (bio != null) params['bio'] = bio;
    if (website != null) params['website'] = website;

    final response = await _dio.put<Object?>(
      '/user/profile',
      queryParameters: params,
    );
    final user = ApiResponse.unwrap(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>? ?? const {}),
    );

    await _authLocalSource.saveUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isApproved: user.isApproved,
      bio: user.bio,
      website: user.website,
      createdAt: user.createdAt,
    );

    return user;
  }

  Future<User> uploadAvatar(
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post<Object?>(
      '/user/avatar/upload',
      data: formData,
      onSendProgress: onProgress,
    );
    final user = ApiResponse.unwrap(
      response.data,
      (data) => User.fromJson(data as Map<String, dynamic>? ?? const {}),
    );

    await _authLocalSource.saveUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isApproved: user.isApproved,
      bio: user.bio,
      website: user.website,
      createdAt: user.createdAt,
    );
    return user;
  }
}
