import 'package:ankiblog_mobile/core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalSource {
  AuthLocalSource(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> saveUser({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
    required String role,
    required bool isApproved,
    String? bio,
    String? website,
    String? createdAt,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.userId, value: id),
      _storage.write(key: StorageKeys.userEmail, value: email),
      _storage.write(key: StorageKeys.userDisplayName, value: displayName),
      if (avatarUrl != null)
        _storage.write(key: StorageKeys.userAvatarUrl, value: avatarUrl),
      _storage.write(key: StorageKeys.userRole, value: role),
      _storage.write(key: StorageKeys.isApproved, value: isApproved.toString()),
      if (bio != null) _storage.write(key: StorageKeys.userBio, value: bio),
      if (website != null)
        _storage.write(key: StorageKeys.userWebsite, value: website),
      if (createdAt != null)
        _storage.write(key: StorageKeys.userCreatedAt, value: createdAt),
    ]);
  }

  Future<Map<String, String?>> getUser() async {
    final results = await Future.wait([
      _storage.read(key: StorageKeys.userId),
      _storage.read(key: StorageKeys.userEmail),
      _storage.read(key: StorageKeys.userDisplayName),
      _storage.read(key: StorageKeys.userAvatarUrl),
      _storage.read(key: StorageKeys.userRole),
      _storage.read(key: StorageKeys.isApproved),
      _storage.read(key: StorageKeys.userBio),
      _storage.read(key: StorageKeys.userWebsite),
      _storage.read(key: StorageKeys.userCreatedAt),
    ]);
    return {
      'id': results[0],
      'email': results[1],
      'displayName': results[2],
      'avatarUrl': results[3],
      'role': results[4],
      'isApproved': results[5],
      'bio': results[6],
      'website': results[7],
      'createdAt': results[8],
    };
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
