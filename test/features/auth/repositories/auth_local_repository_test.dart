import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_local_repository_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late MockBox<UserModel> mockUserBox;
  late MockBox<dynamic> mockTokenBox;
  late AuthLocalRepository repository;

  setUp(() {
    mockUserBox = MockBox<UserModel>();
    mockTokenBox = MockBox<dynamic>();
    repository = AuthLocalRepository(
      userBox: mockUserBox,
      tokenBox: mockTokenBox,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  group('User Management', () {
    final testUser = UserModel(
      name: 'Test User',
      email: 'test@example.com',
      dob: '1990-01-01',
      username: 'testuser',
      id: '123',
      isEmailVerified: true,
      isVerified: false,
      bio: 'Test bio',
      photo: 'photo123',
      tfaVerified: true,
      interests: {'sports', 'music'},
      localProfilePhotoPath: '/path/to/photo',
    );

    test('saveUser should store user in box', () async {
      when(
        mockUserBox.put('currentUser', testUser),
      ).thenAnswer((_) async => Future.value());

      await repository.saveUser(testUser);

      verify(mockUserBox.put('currentUser', testUser)).called(1);
    });

    test('getUser should return user from box', () {
      when(mockUserBox.get('currentUser')).thenReturn(testUser);

      final result = repository.getUser();

      expect(result, equals(testUser));
      verify(mockUserBox.get('currentUser')).called(1);
    });

    test('getUser should return null when no user exists', () {
      when(mockUserBox.get('currentUser')).thenReturn(null);

      final result = repository.getUser();

      expect(result, isNull);
      verify(mockUserBox.get('currentUser')).called(1);
    });

    test('clearUser should delete user from box', () async {
      when(
        mockUserBox.delete('currentUser'),
      ).thenAnswer((_) async => Future.value());

      await repository.clearUser();

      verify(mockUserBox.delete('currentUser')).called(1);
    });
  });

  group('Token Management', () {
    final testTokens = TokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_456',
      accessTokenExpiry: DateTime(2025, 12, 31),
      refreshTokenExpiry: DateTime(2026, 1, 31),
    );

    test('saveTokens should store all token data', () async {
      when(mockTokenBox.putAll(any)).thenAnswer((_) async => Future.value());

      await repository.saveTokens(testTokens);

      final captured = verify(mockTokenBox.putAll(captureAny)).captured.single;
      expect(captured['accessToken'], equals('access_token_123'));
      expect(captured['refreshToken'], equals('refresh_token_456'));
      expect(captured['accessTokenExpiry'], equals('2025-12-31T00:00:00.000'));
      expect(captured['refreshTokenExpiry'], equals('2026-01-31T00:00:00.000'));
    });

    test('saveTokens should emit tokens to stream', () async {
      when(mockTokenBox.putAll(any)).thenAnswer((_) async => Future.value());

      expectLater(
        repository.tokenStream,
        emits(
          predicate<TokensModel>(
            (t) =>
                t.accessToken == testTokens.accessToken &&
                t.refreshToken == testTokens.refreshToken,
          ),
        ),
      );

      await repository.saveTokens(testTokens);
    });

    test('getTokens should return TokensModel when all data exists', () {
      when(mockTokenBox.get('accessToken')).thenReturn('access_token_123');
      when(mockTokenBox.get('refreshToken')).thenReturn('refresh_token_456');
      when(
        mockTokenBox.get('accessTokenExpiry'),
      ).thenReturn('2025-12-31T00:00:00.000');
      when(
        mockTokenBox.get('refreshTokenExpiry'),
      ).thenReturn('2026-01-31T00:00:00.000');

      final result = repository.getTokens();

      expect(result, isNotNull);
      expect(result!.accessToken, equals('access_token_123'));
      expect(result.refreshToken, equals('refresh_token_456'));
      expect(result.accessTokenExpiry, equals(DateTime(2025, 12, 31)));
      expect(result.refreshTokenExpiry, equals(DateTime(2026, 1, 31)));
    });

    test('getTokens should return null when accessToken is missing', () {
      when(mockTokenBox.get('accessToken')).thenReturn(null);
      when(mockTokenBox.get('refreshToken')).thenReturn('refresh_token_456');
      when(
        mockTokenBox.get('accessTokenExpiry'),
      ).thenReturn('2025-12-31T00:00:00.000');
      when(
        mockTokenBox.get('refreshTokenExpiry'),
      ).thenReturn('2026-01-31T00:00:00.000');

      final result = repository.getTokens();

      expect(result, isNull);
    });

    test('getTokens should return null when refreshToken is missing', () {
      when(mockTokenBox.get('accessToken')).thenReturn('access_token_123');
      when(mockTokenBox.get('refreshToken')).thenReturn(null);
      when(
        mockTokenBox.get('accessTokenExpiry'),
      ).thenReturn('2025-12-31T00:00:00.000');
      when(
        mockTokenBox.get('refreshTokenExpiry'),
      ).thenReturn('2026-01-31T00:00:00.000');

      final result = repository.getTokens();

      expect(result, isNull);
    });

    test('getTokens should return null when accessTokenExpiry is missing', () {
      when(mockTokenBox.get('accessToken')).thenReturn('access_token_123');
      when(mockTokenBox.get('refreshToken')).thenReturn('refresh_token_456');
      when(mockTokenBox.get('accessTokenExpiry')).thenReturn(null);
      when(
        mockTokenBox.get('refreshTokenExpiry'),
      ).thenReturn('2026-01-31T00:00:00.000');

      final result = repository.getTokens();

      expect(result, isNull);
    });

    test('getTokens should return null when refreshTokenExpiry is missing', () {
      when(mockTokenBox.get('accessToken')).thenReturn('access_token_123');
      when(mockTokenBox.get('refreshToken')).thenReturn('refresh_token_456');
      when(
        mockTokenBox.get('accessTokenExpiry'),
      ).thenReturn('2025-12-31T00:00:00.000');
      when(mockTokenBox.get('refreshTokenExpiry')).thenReturn(null);

      final result = repository.getTokens();

      expect(result, isNull);
    });

    test('getTokens should return null when date parsing fails', () {
      when(mockTokenBox.get('accessToken')).thenReturn('access_token_123');
      when(mockTokenBox.get('refreshToken')).thenReturn('refresh_token_456');
      when(mockTokenBox.get('accessTokenExpiry')).thenReturn('invalid_date');
      when(
        mockTokenBox.get('refreshTokenExpiry'),
      ).thenReturn('2026-01-31T00:00:00.000');

      final result = repository.getTokens();

      expect(result, isNull);
    });

    test('clearTokens should delete all token data', () async {
      when(
        mockTokenBox.deleteAll(any),
      ).thenAnswer((_) async => Future.value(4));

      await repository.clearTokens();

      final captured = verify(
        mockTokenBox.deleteAll(captureAny),
      ).captured.single;
      expect(
        captured,
        containsAll([
          'accessToken',
          'refreshToken',
          'accessTokenExpiry',
          'refreshTokenExpiry',
        ]),
      );
    });

    test('clearTokens should emit null to stream', () async {
      when(
        mockTokenBox.deleteAll(any),
      ).thenAnswer((_) async => Future.value(4));

      expectLater(repository.tokenStream, emits(null));

      await repository.clearTokens();
    });
  });

  group('Token Stream', () {
    test('tokenStream should emit multiple token updates', () async {
      when(mockTokenBox.putAll(any)).thenAnswer((_) async => Future.value());

      final tokens1 = TokensModel(
        accessToken: 'token1',
        refreshToken: 'refresh1',
        accessTokenExpiry: DateTime(2025, 12, 31),
        refreshTokenExpiry: DateTime(2026, 1, 31),
      );

      final tokens2 = TokensModel(
        accessToken: 'token2',
        refreshToken: 'refresh2',
        accessTokenExpiry: DateTime(2025, 12, 31),
        refreshTokenExpiry: DateTime(2026, 1, 31),
      );

      expectLater(
        repository.tokenStream,
        emitsInOrder([
          predicate<TokensModel>(
            (t) =>
                t.accessToken == tokens1.accessToken &&
                t.refreshToken == tokens1.refreshToken,
          ),
          predicate<TokensModel>(
            (t) =>
                t.accessToken == tokens2.accessToken &&
                t.refreshToken == tokens2.refreshToken,
          ),
        ]),
      );

      await repository.saveTokens(tokens1);
      await repository.saveTokens(tokens2);
    });

    test('tokenStream should emit token then null on clear', () async {
      when(mockTokenBox.putAll(any)).thenAnswer((_) async => Future.value());
      when(
        mockTokenBox.deleteAll(any),
      ).thenAnswer((_) async => Future.value(4));

      final tokens = TokensModel(
        accessToken: 'token',
        refreshToken: 'refresh',
        accessTokenExpiry: DateTime(2025, 12, 31),
        refreshTokenExpiry: DateTime(2026, 1, 31),
      );

      expectLater(
        repository.tokenStream,
        emitsInOrder([
          predicate<TokensModel>(
            (t) =>
                t.accessToken == tokens.accessToken &&
                t.refreshToken == tokens.refreshToken,
          ),
          isNull,
        ]),
      );

      await repository.saveTokens(tokens);
      await repository.clearTokens();
    });

    test('dispose should close token stream', () {
      repository.dispose();

      final sub = repository.tokenStream.listen((_) {});
      expect(sub, isA<StreamSubscription>());
      expect(sub.isPaused, isFalse);
    });
  });

  group('Integration Scenarios', () {
    test('complete auth flow: save user and tokens, then retrieve', () async {
      final user = UserModel(
        name: 'John Doe',
        email: 'john@example.com',
        dob: '1995-05-15',
        username: 'johndoe',
        id: '456',
        isEmailVerified: true,
        isVerified: true,
      );

      final tokens = TokensModel(
        accessToken: 'jwt_token',
        refreshToken: 'refresh_jwt',
        accessTokenExpiry: DateTime(2025, 12, 31),
        refreshTokenExpiry: DateTime(2026, 1, 31),
      );

      when(
        mockUserBox.put('currentUser', user),
      ).thenAnswer((_) async => Future.value());
      when(mockTokenBox.putAll(any)).thenAnswer((_) async => Future.value());
      when(mockUserBox.get('currentUser')).thenReturn(user);
      when(mockTokenBox.get('accessToken')).thenReturn('jwt_token');
      when(mockTokenBox.get('refreshToken')).thenReturn('refresh_jwt');
      when(
        mockTokenBox.get('accessTokenExpiry'),
      ).thenReturn('2025-12-31T00:00:00.000');
      when(
        mockTokenBox.get('refreshTokenExpiry'),
      ).thenReturn('2026-01-31T00:00:00.000');

      await repository.saveUser(user);
      await repository.saveTokens(tokens);

      final retrievedUser = repository.getUser();
      final retrievedTokens = repository.getTokens();

      expect(retrievedUser, equals(user));
      expect(retrievedTokens?.accessToken, equals('jwt_token'));
      expect(retrievedTokens?.refreshToken, equals('refresh_jwt'));
    });

    test('complete logout flow: clear user and tokens', () async {
      when(
        mockUserBox.delete('currentUser'),
      ).thenAnswer((_) async => Future.value());
      when(
        mockTokenBox.deleteAll(any),
      ).thenAnswer((_) async => Future.value(4));

      await repository.clearUser();
      await repository.clearTokens();

      verify(mockUserBox.delete('currentUser')).called(1);
      verify(mockTokenBox.deleteAll(any)).called(1);
    });
  });
}
