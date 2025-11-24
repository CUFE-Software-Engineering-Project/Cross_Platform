import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo_impl.dart';

import 'dio_mocks.mocks.dart';

Future<List<String>> mockGetMediaUrls(List<String> mediaIds) async {
  return mediaIds.map((id) => 'https://example.com/image/$id').toList();
}

void main() {
  group('SettingsRepoImpl', () {
    late MockDio mockDio;
    late SettingsRepoImpl repo;

    setUp(() {
      mockDio = MockDio();
      repo = SettingsRepoImpl(mockDio, mediaUrlsFetcher: mockGetMediaUrls);
    });

    test('getBlockedAccounts returns users on success', () async {
      when(mockDio.get(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {
              "users": [
                {"name": "user1", "username": "user1", "photo": "id1"}
              ]
            },
          ));

      final result = await repo.getBlockedAccounts('testuser');
      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('should not fail'),
        (r) {
          expect(r.length, 1);
          expect(r[0].userName, 'user1');
          expect(r[0].image, 'https://example.com/image/id1');
        },
      );
    });

    test('getBlockedAccounts returns failure on DioError', () async {
      when(mockDio.get(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.getBlockedAccounts('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('getMutedAccounts returns users on success', () async {
      when(mockDio.get(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {
              "users": [
                {"name": "user2", "username": "user2", "photo": "id2"}
              ]
            },
          ));

      final result = await repo.getMutedAccounts('testuser');
      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('should not fail'),
        (r) {
          expect(r.length, 1);
          expect(r[0].userName, 'user2');
          expect(r[0].image, 'https://example.com/image/id2');
        },
      );
    });

    test('getMutedAccounts returns failure on DioError', () async {
      when(mockDio.get(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.getMutedAccounts('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('blockAccount returns success on 200', () async {
      when(mockDio.post(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      final result = await repo.blockAccount('testuser');
      expect(result, isA<Right>());
    });

    test('blockAccount returns failure on DioError', () async {
      when(mockDio.post(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.blockAccount('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('unblockAccount returns success on 200', () async {
      when(mockDio.delete(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      final result = await repo.unblockAccount('testuser');
      expect(result, isA<Right>());
    });

    test('unblockAccount returns failure on DioError', () async {
      when(mockDio.delete(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.unblockAccount('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('muteAccount returns success on 200', () async {
      when(mockDio.post(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      final result = await repo.muteAccount('testuser');
      expect(result, isA<Right>());
    });

    test('muteAccount returns failure on DioError', () async {
      when(mockDio.post(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.muteAccount('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('unMuteAccount returns success on 200', () async {
      when(mockDio.delete(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      final result = await repo.unMuteAccount('testuser');
      expect(result, isA<Right>());
    });

    test('unMuteAccount returns failure on DioError', () async {
      when(mockDio.delete(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.unMuteAccount('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('followUser returns success on 200', () async {
      when(mockDio.post(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      final result = await repo.followUser('testuser');
      expect(result, isA<Right>());
    });

    test('followUser returns failure on DioError', () async {
      when(mockDio.post(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.followUser('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('unFollowUser returns success on 200', () async {
      when(mockDio.delete(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      final result = await repo.unFollowUser('testuser');
      expect(result, isA<Right>());
    });

    test('unFollowUser returns failure on DioError', () async {
      when(mockDio.delete(any)).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      final result = await repo.unFollowUser('testuser');
      expect(result, isA<Left<Failure, void>>());
    });

    test('getSettings returns initial settings model', () async {
      final result = await repo.getSettings('testuser');
      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('should not fail'),
        (r) {
          expect(r.username, 'testuser');
          expect(r.protectedAccount, isFalse);
        },
      );
    });

    test('updateSettings returns updated model', () async {
      final initialModel = SettingsModel.initial('testuser');
      final newModel = initialModel.copyWith(protectedAccount: true);

      final result = await repo.updateSettings(newModel: newModel);
      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('should not fail'),
        (r) {
          expect(r.protectedAccount, isTrue);
          expect(r.lastUpdated, isNotNull);
        },
      );
    });
  });
}
