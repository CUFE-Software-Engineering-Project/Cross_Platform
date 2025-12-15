import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/repositories/profile_repo_impl.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDio mockDio;
  late ProviderContainer container;
  late ProfileRepoImpl repository;

  setUpAll(() async {
    // Setup Hive for testing
    Hive.init('test_hive_integration');
    Hive.registerAdapter(ProfileModelAdapter());
  });

  setUp(() {
    mockDio = MockDio();
    repository = ProfileRepoImpl(mockDio);
    
    // Create container with overridden providers
    container = ProviderContainer(
      overrides: [
        myUserNameProvider.overrideWith((ref) => 'testuser'),
        profileRepoProvider.overrideWith((ref) => repository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    // Clean up Hive box after each test
    try {
      if (Hive.isBoxOpen('profileDataBox')) {
        await Hive.box<ProfileModel>('profileDataBox').close();
      }
      await Hive.deleteBoxFromDisk('profileDataBox');
    } catch (_) {}
  });

  tearDownAll(() async {
    await Hive.close();
  });

  // Helper to execute code with Ref access
  Future<T> withRef<T>(Future<T> Function(Ref ref) callback) async {
    late T result;
    final provider = Provider<Future<T>>((ref) async {
      result = await callback(ref);
      return result;
    });
    await container.read(provider);
    return result;
  }

  group('ProfileRepoImpl Integration - followUser', () {
    test('should return Right when follow succeeds', () async {
      // Arrange
      when(mockDio.post('api/followers/targetuser')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/followers/targetuser'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.followUser('targetuser', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when follow fails', () async {
      // Arrange
      when(mockDio.post('api/followers/targetuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/followers/targetuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.followUser('targetuser', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "couldn't follow user"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - unFollowUser', () {
    test('should return Right when unfollow succeeds', () async {
      // Arrange
      when(mockDio.delete('api/followers/targetuser')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/followers/targetuser'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unFollowUser('targetuser', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when unfollow fails', () async {
      // Arrange
      when(mockDio.delete('api/followers/targetuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/followers/targetuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unFollowUser('targetuser', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "couldn't unfollow user"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - blockUser', () {
    test('should return Right when block succeeds', () async {
      // Arrange
      when(mockDio.post('api/blocks/targetuser')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/blocks/targetuser'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.blockUser('targetuser', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when block fails', () async {
      // Arrange
      when(mockDio.post('api/blocks/targetuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/blocks/targetuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.blockUser('targetuser', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "couldn't block user"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - unBlockUser', () {
    test('should return Right when unblock succeeds', () async {
      // Arrange
      when(mockDio.delete('api/blocks/targetuser')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/blocks/targetuser'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unBlockUser('targetuser', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when unblock fails', () async {
      // Arrange
      when(mockDio.delete('api/blocks/targetuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/blocks/targetuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unBlockUser('targetuser', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "couldn't unblock user"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - muteUser', () {
    test('should return Right when mute succeeds', () async {
      // Arrange
      when(mockDio.post('api/mutes/targetuser')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes/targetuser'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.muteUser('targetuser', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when mute fails', () async {
      // Arrange
      when(mockDio.post('api/mutes/targetuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/mutes/targetuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.muteUser('targetuser', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "couldn't mute user"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - unMuteUser', () {
    test('should return Right when unmute succeeds', () async {
      // Arrange
      when(mockDio.delete('api/mutes/targetuser')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/mutes/targetuser'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unMuteUser('targetuser', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when unmute fails', () async {
      // Arrange
      when(mockDio.delete('api/mutes/targetuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/mutes/targetuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unMuteUser('targetuser', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "couldn't unmute user"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - deleteTweet', () {
    test('should return Right when delete succeeds', () async {
      // Arrange
      when(mockDio.delete('api/tweets/tweet123')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/tweets/tweet123'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.deleteTweet('tweet123', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when delete fails', () async {
      // Arrange
      when(mockDio.delete('api/tweets/tweet123')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/tweets/tweet123'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.deleteTweet('tweet123', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Can't delete tweet"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - likeTweet', () {
    test('should return Right when like succeeds', () async {
      // Arrange
      when(mockDio.post('api/tweets/tweet123/likes')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/likes'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.likeTweet('tweet123', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when like fails', () async {
      // Arrange
      when(mockDio.post('api/tweets/tweet123/likes')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/likes'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.likeTweet('tweet123', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Can't like tweet"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - unLikeTweet', () {
    test('should return Right when unlike succeeds', () async {
      // Arrange
      when(mockDio.delete('api/tweets/tweet123/likes')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/likes'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unLikeTweet('tweet123', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when unlike fails', () async {
      // Arrange
      when(mockDio.delete('api/tweets/tweet123/likes')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/likes'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.unLikeTweet('tweet123', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Can't unlike tweet"),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - retweetProfileTweet', () {
    test('should return Right when retweet succeeds', () async {
      // Arrange
      when(mockDio.post('api/tweets/tweet123/retweets')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/retweets'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.retweetProfileTweet('tweet123', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when retweet fails', () async {
      // Arrange
      when(mockDio.post('api/tweets/tweet123/retweets')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/retweets'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.retweetProfileTweet('tweet123', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Can't retweet tweet, try agail..."),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - deleteRetweetProfileTweet', () {
    test('should return Right when delete retweet succeeds', () async {
      // Arrange
      when(mockDio.delete('api/tweets/tweet123/retweets')).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/retweets'),
        ),
      );

      // Act
      final result = await withRef((ref) => repository.deleteRetweetProfileTweet('tweet123', ref));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Failure when delete retweet fails', () async {
      // Arrange
      when(mockDio.delete('api/tweets/tweet123/retweets')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/tweets/tweet123/retweets'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await withRef((ref) => repository.deleteRetweetProfileTweet('tweet123', ref));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Can't delelte retweet tweet, try agail..."),
        (r) => fail('Should return failure'),
      );
    });
  });

  group('ProfileRepoImpl Integration - getProfileData with currentUsername', () {
    test('should store profile data when fetching current user profile successfully', () async {
      // Arrange
      final testProfileJson = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
        'bio': 'Test bio',
        'isVerified': true,
        'joinedDate': '2023-01-01',
        'followersCount': 100,
        'followingCount': 50,
        'tweetsCount': 200,
        'profileMedia': null,
        'bannerMedia': null,
        'birthDate': '1990-01-01',
        'website': 'https://test.com',
        'location': 'Test City',
        'isFollowing': false,
        'isFollower': false,
        'protectedAccount': false,
        'isBlockedByMe': false,
        'isMutedByMe': false,
      };

      when(mockDio.get('api/users/testuser')).thenAnswer(
        (_) async => Response(
          data: testProfileJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/users/testuser'),
        ),
      );

      // Act
      final result = await repository.getProfileData('testuser', 'testuser');

      // Assert
      expect(result.isRight(), true);
    });

    test('should return local data when API fails for current user and local data exists', () async {
      // Arrange - First store data, then fail API call
      final testProfileJson = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
        'bio': 'Test bio',
        'isVerified': true,
        'joinedDate': '2023-01-01',
        'followersCount': 100,
        'followingCount': 50,
        'tweetsCount': 200,
        'profileMedia': null,
        'bannerMedia': null,
        'birthDate': '1990-01-01',
        'website': 'https://test.com',
        'location': 'Test City',
        'isFollowing': false,
        'isFollower': false,
        'protectedAccount': false,
        'isBlockedByMe': false,
        'isMutedByMe': false,
      };

      // First successful call to store data
      when(mockDio.get('api/users/testuser')).thenAnswer(
        (_) async => Response(
          data: testProfileJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/users/testuser'),
        ),
      );
      
      await repository.getProfileData('testuser', 'testuser');

      // Then make API fail with DioException
      when(mockDio.get('api/users/testuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/testuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act - Should return cached local data
      final result = await repository.getProfileData('testuser', 'testuser');

      // Assert - Should succeed with local data
      expect(result.isRight(), true);
    });

    test('should return Failure when API fails for current user and no local data exists', () async {
      // Arrange
      when(mockDio.get('api/users/newuser')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/newuser'),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await repository.getProfileData('newuser', 'newuser');

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return local data when generic exception occurs for current user and local data exists', () async {
      // Arrange - First store data, then cause generic exception
      final testProfileJson = {
        'id': '123',
        'username': 'testuser2',
        'name': 'Test User 2',
        'email': 'test2@example.com',
        'bio': 'Test bio 2',
        'isVerified': true,
        'joinedDate': '2023-01-01',
        'followersCount': 100,
        'followingCount': 50,
        'tweetsCount': 200,
        'profileMedia': null,
        'bannerMedia': null,
        'birthDate': '1990-01-01',
        'website': 'https://test.com',
        'location': 'Test City',
        'isFollowing': false,
        'isFollower': false,
        'protectedAccount': false,
        'isBlockedByMe': false,
        'isMutedByMe': false,
      };

      // First successful call to store data
      when(mockDio.get('api/users/testuser2')).thenAnswer(
        (_) async => Response(
          data: testProfileJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'api/users/testuser2'),
        ),
      );
      
      await repository.getProfileData('testuser2', 'testuser2');

      // Then make API fail with generic exception
      when(mockDio.get('api/users/testuser2')).thenThrow(
        Exception('Network error'),
      );

      // Act - Should return cached local data
      final result = await repository.getProfileData('testuser2', 'testuser2');

      // Assert - Should succeed with local data
      expect(result.isRight(), true);
    });

    test('should return Failure when generic exception occurs for current user and no local data exists', () async {
      // Arrange
      when(mockDio.get('api/users/newuser2')).thenThrow(
        Exception('Network error'),
      );

      // Act
      final result = await repository.getProfileData('newuser2', 'newuser2');

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
