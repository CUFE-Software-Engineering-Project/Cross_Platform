import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/TokensModel.dart';

void main() {
  group('TokensModel Tests', () {
    const String tAccessToken = 'access_token_value_longer_than_20_chars';
    const String tRefreshToken = 'refresh_token_value_longer_than_20_chars';
    test('fromMap creates instance from flat JSON map', () {
      final map = {'accessToken': tAccessToken, 'refreshToken': tRefreshToken};

      final model = TokensModel.fromMap(map);

      expect(model.accessToken, tAccessToken);
      expect(model.refreshToken, tRefreshToken);
      expect(model.accessTokenExpiry.isAfter(DateTime.now()), true);
      expect(model.refreshTokenExpiry.isAfter(DateTime.now()), true);
    });
    test('fromMap creates instance from nested "tokens" key', () {
      final map = {
        'tokens': {'accessToken': tAccessToken, 'refreshToken': tRefreshToken},
      };

      final model = TokensModel.fromMap(map);

      expect(model.accessToken, tAccessToken);
      expect(model.refreshToken, tRefreshToken);
    });
    test('fromMap_login parses "Token" and "Refresh_token" correctly', () {
      final map = {'Token': tAccessToken, 'Refresh_token': tRefreshToken};

      final model = TokensModel.fromMap_login(map);

      expect(model.accessToken, tAccessToken);
      expect(model.refreshToken, tRefreshToken);
    });

    test('fromMap_reset_password parses "accesstoken" and "refresh_token"', () {
      final map = {'accesstoken': tAccessToken, 'refresh_token': tRefreshToken};

      final model = TokensModel.fromMap_reset_password(map);

      expect(model.accessToken, tAccessToken);
      expect(model.refreshToken, tRefreshToken);
    });

    test('fromMap_update parses "access" and "refresh"', () {
      final map = {'access': tAccessToken, 'refresh': tRefreshToken};

      final model = TokensModel.fromMap_update(map);

      expect(model.accessToken, tAccessToken);
      expect(model.refreshToken, tRefreshToken);
    });

    test('fromRefreshResponse parses "access_token" and "refresh_token"', () {
      final map = {
        'access_token': tAccessToken,
        'refresh_token': tRefreshToken,
      };

      final model = TokensModel.fromRefreshResponse(map);

      expect(model.accessToken, tAccessToken);
      expect(model.refreshToken, tRefreshToken);
    });

    group('Expiry Logic', () {
      test('should return TRUE if date is in the PAST', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final model = TokensModel(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
          accessTokenExpiry: pastDate,
          refreshTokenExpiry: pastDate,
        );

        expect(model.isAccessTokenExpired, true);
        expect(model.isRefreshTokenExpired, true);
      });

      test('should return FALSE if date is in the FUTURE', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));

        final model = TokensModel(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
          accessTokenExpiry: futureDate,
          refreshTokenExpiry: futureDate,
        );

        expect(model.isAccessTokenExpired, false);
        expect(model.isRefreshTokenExpired, false);
      });
    });

    test('toMap returns correct map structure', () {
      final date = DateTime.now();
      final model = TokensModel(
        accessToken: tAccessToken,
        refreshToken: tRefreshToken,
        accessTokenExpiry: date,
        refreshTokenExpiry: date,
      );

      final result = model.toMap();

      expect(result['access_token'], tAccessToken);
      expect(result['refresh_token'], tRefreshToken);
      expect(result['access_token_expiry'], date.toIso8601String());
      expect(result['refresh_token_expiry'], date.toIso8601String());
    });

    test('toString returns formatted string with substrings', () {
      final model = TokensModel(
        accessToken: '12345678901234567890_extra',
        refreshToken: 'abcdefghijabcdefghij_extra',
        accessTokenExpiry: DateTime(2025),
        refreshTokenExpiry: DateTime(2026),
      );

      final str = model.toString();
      expect(str.contains('12345678901234567890'), true);
      expect(str.contains('abcdefghijabcdefghij'), true);
      expect(str.contains('_extra'), false);
    });
  });
}
