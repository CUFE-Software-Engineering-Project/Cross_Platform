class TokensModel {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;
  final DateTime refreshTokenExpiry;

  TokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
  });

  factory TokensModel.fromMap(Map<String, dynamic> map) {
    final tokensData = map.containsKey('tokens') ? map['tokens'] : map;
    return TokensModel(
      accessToken: tokensData['accessToken'] as String,
      refreshToken: tokensData['refreshToken'] as String,
      accessTokenExpiry: DateTime.now().add(const Duration(minutes: 60)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );
  }

  factory TokensModel.fromMap_login(Map<String, dynamic> map) {
    return TokensModel(
      accessToken: map['Token'] as String,
      refreshToken: map['Refresh_token'] as String,
      accessTokenExpiry: DateTime.now().add(const Duration(minutes: 60)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );
  }

  factory TokensModel.fromRefreshResponse(Map<String, dynamic> map) {
    return TokensModel(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      accessTokenExpiry: DateTime.now().add(const Duration(minutes: 60)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );
  }

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiry);

  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiry);

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expiry': accessTokenExpiry.toIso8601String(),
      'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TokensModel(accessToken: ${accessToken.substring(0, 20)}..., refreshToken: ${refreshToken.substring(0, 20)}..., accessExpiry: $accessTokenExpiry, refreshExpiry: $refreshTokenExpiry)';
  }
}
