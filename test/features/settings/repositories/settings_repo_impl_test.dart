import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_repo_impl_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late SettingsRepoImpl repo;

  setUp(() {
    mockDio = MockDio();
    repo = SettingsRepoImpl(mockDio);
  });

  group('SettingsRepoImpl', () {
    group('getSettings', () {
      test('should return settings model for valid username', () async {
        final result = await repo.getSettings('testuser');

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (settings) {
            expect(settings.username, 'testuser');
            expect(settings.protectedAccount, false);
            expect(settings.allowTagging, true);
          },
        );
      });

      test('should return initial settings for any username', () async {
        final result = await repo.getSettings('anotheruser');

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (settings) {
            expect(settings.username, 'anotheruser');
            expect(settings.mutedWords, isEmpty);
            expect(settings.lastUpdated, null);
          },
        );
      });
    });

    group('updateSettings', () {
      test('should return updated settings with timestamp', () async {
        final newModel = SettingsModel.initial('testuser').copyWith(
          protectedAccount: true,
          mutedWords: ['spam'],
        );

        final result = await repo.updateSettings(newModel: newModel);

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (updated) {
            expect(updated.protectedAccount, true);
            expect(updated.mutedWords, ['spam']);
            expect(updated.lastUpdated, isNotNull);
          },
        );
      });

      test('should preserve all settings properties', () async {
        final newModel = SettingsModel(
          username: 'user123',
          protectedAccount: true,
          allowTagging: false,
          directMessagesFromEveryone: true,
          personalizedAds: false,
          dataSharingWithPartners: true,
          spacesEnabled: false,
          mutedWords: ['word1', 'word2'],
          lastUpdated: null,
        );

        final result = await repo.updateSettings(newModel: newModel);

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (updated) {
            expect(updated.username, 'user123');
            expect(updated.protectedAccount, true);
            expect(updated.allowTagging, false);
            expect(updated.directMessagesFromEveryone, true);
            expect(updated.personalizedAds, false);
            expect(updated.dataSharingWithPartners, true);
            expect(updated.spacesEnabled, false);
            expect(updated.mutedWords, ['word1', 'word2']);
            expect(updated.lastUpdated, isNotNull);
          },
        );
      });
    });

    group('getBlockedAccounts', () {
      test('should return blocked users list on success', () async {
        final mockResponse = Response(
          data: {
            'users': [
              {
                'name': 'Blocked User',
                'username': 'blockeduser',
                'photo': '',
                'bio': 'Blocked',
                'verified': false,
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/blocks'),
        );

        when(mockDio.get('api/blocks')).thenAnswer((_) async => mockResponse);

        final result = await repo.getBlockedAccounts('testuser');

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (users) {
            expect(users.length, 1);
            expect(users[0].displayName, 'Blocked User');
          },
        );
        verify(mockDio.get('api/blocks')).called(1);
      });

      test('should return failure on dio exception', () async {
        when(mockDio.get('api/blocks')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'api/blocks'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await repo.getBlockedAccounts('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "Can't get Blocked users, try again later..");
          },
          (r) => fail('Should not return success'),
        );
      });

      test('should return failure on general exception', () async {
        when(mockDio.get('api/blocks')).thenThrow(Exception('Network error'));

        final result = await repo.getBlockedAccounts('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "Can't get Blocked users, try again later..");
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('getMutedAccounts', () {
      test('should return muted users list on success', () async {
        final mockResponse = Response(
          data: {
            'users': [
              {
                'name': 'Muted User',
                'username': 'muteduser',
                'photo': '',
                'bio': 'Muted',
                'verified': true,
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes'),
        );

        when(mockDio.get('api/mutes')).thenAnswer((_) async => mockResponse);

        final result = await repo.getMutedAccounts('testuser');

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (users) {
            expect(users.length, 1);
            expect(users[0].displayName, 'Muted User');
            expect(users[0].isVerified, true);
          },
        );
        verify(mockDio.get('api/mutes')).called(1);
      });

      test('should return failure on dio exception', () async {
        when(mockDio.get('api/mutes')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'api/mutes'),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repo.getMutedAccounts('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "Can't get muted users, try again later..");
          },
          (r) => fail('Should not return success'),
        );
      });

      test('should return failure on general exception', () async {
        when(mockDio.get('api/mutes')).thenThrow(Exception('Server error'));

        final result = await repo.getMutedAccounts('testuser');

        expect(result.isLeft(), true);
      });
    });

    group('fetchMutedAccounts', () {
      test('should return paginated muted users with default limit', () async {
        final mockResponse = Response(
          data: {
            'users': [
              {
                'name': 'User 1',
                'username': 'user1',
                'photo': '',
                'bio': '',
                'verified': false,
              }
            ],
            'nextCursor': 'cursor123',
            'hasMore': true,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes'),
        );

        when(mockDio.get('api/mutes', queryParameters: {'limit': 30}))
            .thenAnswer((_) async => mockResponse);

        final result = await repo.fetchMutedAccounts();

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (response) {
            expect(response.users.length, 1);
            expect(response.nextCursor, 'cursor123');
            expect(response.hasMore, true);
          },
        );
        verify(mockDio.get('api/mutes', queryParameters: {'limit': 30})).called(1);
      });

      test('should pass custom limit parameter', () async {
        final mockResponse = Response(
          data: {
            'users': [],
            'nextCursor': null,
            'hasMore': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes'),
        );

        when(mockDio.get('api/mutes', queryParameters: {'limit': 50}))
            .thenAnswer((_) async => mockResponse);

        await repo.fetchMutedAccounts(limit: 50);

        verify(mockDio.get('api/mutes', queryParameters: {'limit': 50})).called(1);
      });

      test('should pass cursor parameter when provided', () async {
        final mockResponse = Response(
          data: {
            'users': [],
            'nextCursor': null,
            'hasMore': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes'),
        );

        when(mockDio.get('api/mutes', queryParameters: {'limit': 30, 'cursor': 'abc123'}))
            .thenAnswer((_) async => mockResponse);

        await repo.fetchMutedAccounts(cursor: 'abc123');

        verify(mockDio.get('api/mutes', queryParameters: {'limit': 30, 'cursor': 'abc123'}))
            .called(1);
      });

      test('should not include cursor param when cursor is null', () async {
        final mockResponse = Response(
          data: {
            'users': [],
            'nextCursor': null,
            'hasMore': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes'),
        );

        when(mockDio.get('api/mutes', queryParameters: {'limit': 30}))
            .thenAnswer((_) async => mockResponse);

        await repo.fetchMutedAccounts(cursor: null);

        verify(mockDio.get('api/mutes', queryParameters: {'limit': 30})).called(1);
      });

      test('should not include cursor param when cursor is empty', () async {
        final mockResponse = Response(
          data: {
            'users': [],
            'nextCursor': null,
            'hasMore': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes'),
        );

        when(mockDio.get('api/mutes', queryParameters: {'limit': 30}))
            .thenAnswer((_) async => mockResponse);

        await repo.fetchMutedAccounts(cursor: '');

        verify(mockDio.get('api/mutes', queryParameters: {'limit': 30})).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.get('api/mutes', queryParameters: anyNamed('queryParameters')))
            .thenThrow(Exception('Network error'));

        final result = await repo.fetchMutedAccounts();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, 'Failed to fetch muted accounts');
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('fetchBlockedAccounts', () {
      test('should return paginated blocked users with default limit', () async {
        final mockResponse = Response(
          data: {
            'users': [
              {
                'name': 'Blocked User',
                'username': 'blocked1',
                'photo': '',
                'bio': '',
                'verified': false,
              }
            ],
            'nextCursor': 'cursor456',
            'hasMore': true,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/blocks'),
        );

        when(mockDio.get('api/blocks', queryParameters: {'limit': 30}))
            .thenAnswer((_) async => mockResponse);

        final result = await repo.fetchBlockedAccounts();

        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (response) {
            expect(response.users.length, 1);
            expect(response.users[0].displayName, 'Blocked User');
            expect(response.nextCursor, 'cursor456');
            expect(response.hasMore, true);
          },
        );
      });

      test('should pass custom limit and cursor', () async {
        final mockResponse = Response(
          data: {
            'users': [],
            'nextCursor': null,
            'hasMore': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/blocks'),
        );

        when(mockDio.get('api/blocks', queryParameters: {'limit': 20, 'cursor': 'xyz789'}))
            .thenAnswer((_) async => mockResponse);

        await repo.fetchBlockedAccounts(limit: 20, cursor: 'xyz789');

        verify(mockDio.get('api/blocks', queryParameters: {'limit': 20, 'cursor': 'xyz789'}))
            .called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.get('api/blocks', queryParameters: anyNamed('queryParameters')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: 'api/blocks'),
        ));

        final result = await repo.fetchBlockedAccounts();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, 'Failed to fetch blocked accounts');
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('blockAccount', () {
      test('should block user successfully', () async {
        when(mockDio.post('api/blocks/testuser'))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/blocks/testuser'),
                ));

        final result = await repo.blockAccount('testuser');

        expect(result.isRight(), true);
        verify(mockDio.post('api/blocks/testuser')).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.post('api/blocks/testuser')).thenThrow(Exception('Error'));

        final result = await repo.blockAccount('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "couldn't block user");
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('unblockAccount', () {
      test('should unblock user successfully', () async {
        when(mockDio.delete('api/blocks/testuser'))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/blocks/testuser'),
                ));

        final result = await repo.unblockAccount('testuser');

        expect(result.isRight(), true);
        verify(mockDio.delete('api/blocks/testuser')).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.delete('api/blocks/testuser')).thenThrow(Exception('Error'));

        final result = await repo.unblockAccount('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "couldn't unblock user");
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('muteAccount', () {
      test('should mute user successfully', () async {
        when(mockDio.post('api/mutes/testuser'))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/mutes/testuser'),
                ));

        final result = await repo.muteAccount('testuser');

        expect(result.isRight(), true);
        verify(mockDio.post('api/mutes/testuser')).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.post('api/mutes/testuser')).thenThrow(Exception('Error'));

        final result = await repo.muteAccount('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "couldn't mute user");
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('unMuteAccount', () {
      test('should unmute user successfully', () async {
        when(mockDio.delete('api/mutes/testuser'))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/mutes/testuser'),
                ));

        final result = await repo.unMuteAccount('testuser');

        expect(result.isRight(), true);
        verify(mockDio.delete('api/mutes/testuser')).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.delete('api/mutes/testuser')).thenThrow(Exception('Error'));

        final result = await repo.unMuteAccount('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "couldn't unmute user");
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('followUser', () {
      test('should follow user successfully', () async {
        when(mockDio.post('api/followers/testuser'))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/followers/testuser'),
                ));

        final result = await repo.followUser('testuser');

        expect(result.isRight(), true);
        verify(mockDio.post('api/followers/testuser')).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.post('api/followers/testuser')).thenThrow(Exception('Error'));

        final result = await repo.followUser('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "couldn't follow user");
          },
          (r) => fail('Should not return success'),
        );
      });
    });

    group('unFollowUser', () {
      test('should unfollow user successfully', () async {
        when(mockDio.delete('api/followers/testuser'))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/followers/testuser'),
                ));

        final result = await repo.unFollowUser('testuser');

        expect(result.isRight(), true);
        verify(mockDio.delete('api/followers/testuser')).called(1);
      });

      test('should return failure on exception', () async {
        when(mockDio.delete('api/followers/testuser')).thenThrow(Exception('Error'));

        final result = await repo.unFollowUser('testuser');

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "couldn't unfollow user");
          },
          (r) => fail('Should not return success'),
        );
      });
    });
  });
}
