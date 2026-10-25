import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    required this.isApproved,
    this.bio,
    this.website,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? avatarUrl;
  final bool isApproved;
  final String? bio;
  final String? website;
  final String? createdAt;

  bool get isAdmin => role == 'ADMIN';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: stringValue(json, 'id'),
      email: stringValue(json, 'email'),
      displayName: stringValue(
        json,
        'display_name',
        stringValue(json, 'displayName', stringValue(json, 'username')),
      ),
      role: stringValue(json, 'role', 'USER'),
      avatarUrl:
          nullableString(json, 'avatar_url') ??
          nullableString(json, 'avatarUrl'),
      isApproved:
          boolValue(json, 'is_approved') || boolValue(json, 'isApproved'),
      bio: nullableString(json, 'bio'),
      website: nullableString(json, 'website'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final User user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: stringValue(
        json,
        'access_token',
        stringValue(json, 'accessToken'),
      ),
      refreshToken: stringValue(
        json,
        'refresh_token',
        stringValue(json, 'refreshToken'),
      ),
      user: User.fromJson((json['user'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}
