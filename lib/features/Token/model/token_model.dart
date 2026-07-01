class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiredIn;

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiredIn,
  });

  factory TokenModel.fromJson(
    Map<String, dynamic> json,
    String? existRefreshToken,
  ) {
    return TokenModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? existRefreshToken ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiredIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiredIn,
    };
  }

  // Create copy with updated tokens
  TokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiredIn,
    DateTime? receivedAt,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiredIn: expiredIn ?? this.expiredIn,
    );
  }
}
