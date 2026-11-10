import 'package:rojgar/features/app/models/user_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;
  AuthResponse({required this.token, required this.user});

  int get id => user.id;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ??
        json['access_token'] ??
        json['auth_token'] ??
        (json['data'] is Map ? (json['data']['token'] ?? json['data']['access_token']) : null) ??
        '';

    final Map<String, dynamic> userData = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : (json['user'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['user'] as Map)
            : <String, dynamic>{});

    if (!userData.containsKey('id')) {
      final fallbackId = json['id'] ?? json['candidate_id'] ?? json['user_id'];
      if (fallbackId != null) {
        userData['id'] = fallbackId;
      }
    }

    return AuthResponse(
      token: token.toString(),
      user: UserModel.fromJson(userData),
    );
  }
}
