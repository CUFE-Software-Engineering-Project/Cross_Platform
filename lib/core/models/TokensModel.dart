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
    return TokensModel(
      accessToken: map['access_token'],
      refreshToken: map['refresh_token'],
      accessTokenExpiry: DateTime.now().add(const Duration(minutes: 15)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
    );
  }

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiry);

  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiry);

  Map<String, dynamic> toMap() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
