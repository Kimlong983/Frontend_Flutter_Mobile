import 'user_model.dart';

/// Response of /api/auth/login and /api/auth/refresh (JwtRes).
class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final UserModel? user;

  LoginResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
      tokenType: json['tokenType']?.toString(),
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      user: json['user'] is Map ? UserModel.fromJson(Map<String, dynamic>.from(json['user'])) : null,
    );
  }
}
