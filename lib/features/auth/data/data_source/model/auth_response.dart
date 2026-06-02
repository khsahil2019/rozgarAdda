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
        json['data']?['token'] ??
        json['data']?['access_token'] ??
        '';

    final userData = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};

    if (!userData.containsKey('id') && json.containsKey('candidate_id')) {
      userData['id'] = json['candidate_id'];
    }

    return AuthResponse(
      token: token,
      user: UserModel.fromJson(userData),
    );
  }
}
