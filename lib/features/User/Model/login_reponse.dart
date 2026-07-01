import 'package:flutter_application_1/features/Token/model/token_model.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';

class LoginResponse {
  final TokenModel token;
  final UserModel user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: TokenModel(
        accessToken: json['access_token'] ?? '',
        refreshToken: json['refresh_token'] ?? '',
        tokenType: json['token_type'] ?? 'Bearer',
        expiredIn: json['expires_in'] ?? 0,
      ),
      user: UserModel.fromJson(json['user']),
    );
  }
}
