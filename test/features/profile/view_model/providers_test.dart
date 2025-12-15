import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/create_reply_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/models/for_you_response_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'providers_test.mocks.dart';

@GenerateMocks([ProfileRepo])
void main() {
  late MockProfileRepo mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockProfileRepo();
  });

  tearDown(() {
    container.dispose();
  });

  group('profileDataProvider', () {
    const testUsername = 'testuser';
    const currentUsername = 'currentuser';

    final testProfile = ProfileModel(
      id: '123',
      username: testUsername,
      displayName: 'Test User',
      bio: 'Test bio',
      followersCount: 100,
      followingCount: 50,
      tweetsCount: 200,
      isVerified: true,
      joinedDate: '2023-01-15',
      website: 'https://example.com',
      location: 'New York, USA',
      postCount: 150,
      birthDate: '1990-05-20',
      isFollowing: false,
      isFollower: false,
      protectedAccount: false,
      isBlockedByMe: false,
      isMutedByMe: false,
      email: 'test@example.com',
      avatarId: 'avatar123',
      bannerId: 'banner456',
    );

    test('should return profile data when repository succeeds', () async {
      // Arrange
      when(mockRepo.getProfileData(testUsername, currentUsername))
          .thenAnswer((_) async => Right(testProfile));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
          myUserNameProvider.overrideWithValue(currentUsername),
        ],
      );

      // Act
      final result = await container.read(
        profileDataProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (profile) {
          expect(profile.id, '123');
          expect(profile.username, testUsername);
          expect(profile.displayName, 'Test User');
        },
      );
      verify(mockRepo.getProfileData(testUsername, currentUsername)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final testFailure = Failure('Failed to load profile');
      when(mockRepo.getProfileData(testUsername, currentUsername))
          .thenAnswer((_) async => Left(testFailure));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
          myUserNameProvider.overrideWithValue(currentUsername),
        ],
      );

      // Act
      final result = await container.read(
        profileDataProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) {
          expect(failure.message, 'Failed to load profile');
        },
        (profile) => fail('Should return Left'),
      );
    });
  });

  group('followersProvider', () {
    const testUsername = 'testuser';

    final testFollowers = [
      UserModel(
        displayName: 'Follower 1',
        userName: 'follower1',
        image: 'image1',
        bio: 'Bio 1',
        isFollowing: false,
        isFollower: true,
        isVerified: false,
      ),
      UserModel(
        displayName: 'Follower 2',
        userName: 'follower2',
        image: 'image2',
        bio: 'Bio 2',
        isFollowing: false,
        isFollower: true,
        isVerified: true,
      ),
    ];

    test('should return list of followers when repository succeeds', () async {
      // Arrange
      when(mockRepo.getFollowers(testUsername))
          .thenAnswer((_) async => Right(testFollowers));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followersProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (followers) {
          expect(followers.length, 2);
          expect(followers[0].userName, 'follower1');
          expect(followers[1].userName, 'follower2');
        },
      );
      verify(mockRepo.getFollowers(testUsername)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final testFailure = Failure('Failed to load followers');
      when(mockRepo.getFollowers(testUsername))
          .thenAnswer((_) async => Left(testFailure));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followersProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) {
          expect(failure.message, 'Failed to load followers');
        },
        (followers) => fail('Should return Left'),
      );
    });
  });

  group('followingsProvider', () {
    const testUsername = 'testuser';

    final testFollowings = [
      UserModel(
        displayName: 'Following 1',
        userName: 'following1',
        image: 'image1',
        bio: 'Bio 1',
        isFollowing: true,
        isFollower: false,
        isVerified: false,
      ),
    ];

    test('should return list of followings when repository succeeds',
        () async {
      // Arrange
      when(mockRepo.getFollowings(testUsername))
          .thenAnswer((_) async => Right(testFollowings));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followingsProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (followings) {
          expect(followings.length, 1);
          expect(followings[0].userName, 'following1');
        },
      );
      verify(mockRepo.getFollowings(testUsername)).called(1);
    });
  });

  group('followControllerProvider', () {
    const testUsername = 'testuser';

    test('should call repository followUser method', () async {
      // Arrange
      when(mockRepo.followUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final followFunction = container.read(followControllerProvider);
      final result = await followFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.followUser(testUsername, any)).called(1);
    });
  });

  group('unFollowControllerProvider', () {
    const testUsername = 'testuser';

    test('should call repository unFollowUser method', () async {
      // Arrange
      when(mockRepo.unFollowUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unfollowFunction = container.read(unFollowControllerProvider);
      final result = await unfollowFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unFollowUser(testUsername, any)).called(1);
    });
  });

  group('blockUserProvider', () {
    const testUsername = 'testuser';

    test('should call repository blockUser method', () async {
      // Arrange
      when(mockRepo.blockUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final blockFunction = container.read(blockUserProvider);
      final result = await blockFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.blockUser(testUsername, any)).called(1);
    });
  });

  group('unBlockUserProvider', () {
    const testUsername = 'testuser';

    test('should call repository unBlockUser method', () async {
      // Arrange
      when(mockRepo.unBlockUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unblockFunction = container.read(unBlockUserProvider);
      final result = await unblockFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unBlockUser(testUsername, any)).called(1);
    });
  });

  group('muteUserProvider', () {
    const testUsername = 'testuser';

    test('should call repository muteUser method', () async {
      // Arrange
      when(mockRepo.muteUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final muteFunction = container.read(muteUserProvider);
      final result = await muteFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.muteUser(testUsername, any)).called(1);
    });
  });

  group('unMuteUserProvider', () {
    const testUsername = 'testuser';

    test('should call repository unMuteUser method', () async {
      // Arrange
      when(mockRepo.unMuteUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unmuteFunction = container.read(unMuteUserProvider);
      final result = await unmuteFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unMuteUser(testUsername, any)).called(1);
    });
  });

  group('editProfileProvider', () {
    final testProfile = ProfileModel(
      id: '123',
      username: 'testuser',
      displayName: 'Updated User',
      bio: 'Updated bio',
      followersCount: 100,
      followingCount: 50,
      tweetsCount: 200,
      isVerified: false,
      joinedDate: '2023-01-15',
      website: 'https://updated.com',
      location: 'Los Angeles, USA',
      postCount: 150,
      birthDate: '1990-05-20',
      isFollowing: false,
      isFollower: false,
      protectedAccount: true,
      isBlockedByMe: false,
      isMutedByMe: false,
      email: 'test@example.com',
      avatarId: 'avatar123',
      bannerId: 'banner456',
    );

    test('should call repository updateProfile method', () async {
      // Arrange
      when(mockRepo.updateProfile(newModel: testProfile))
          .thenAnswer((_) async => Right(testProfile));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final editFunction = container.read(editProfileProvider);
      final result = await editFunction(testProfile);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.updateProfile(newModel: testProfile)).called(1);
    });
  });

  group('likeTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository likeTweet method', () async {
      // Arrange
      when(mockRepo.likeTweet(tweetId, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final likeFunction = container.read(likeTweetProvider);
      final result = await likeFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.likeTweet(tweetId, any)).called(1);
    });
  });

  group('unlikeTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository unLikeTweet method', () async {
      // Arrange
      when(mockRepo.unLikeTweet(tweetId, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unlikeFunction = container.read(unlikeTweetProvider);
      final result = await unlikeFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unLikeTweet(tweetId, any)).called(1);
    });
  });

  group('deleteTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository deleteTweet method', () async {
      // Arrange
      when(mockRepo.deleteTweet(tweetId, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final deleteFunction = container.read(deleteTweetProvider);
      final result = await deleteFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.deleteTweet(tweetId, any)).called(1);
    });
  });

  group('updateProfileBannerProvider', () {
    const userId = 'user123';
    const mediaId = 'media456';

    test('should call repository updateProfileBanner method', () async {
      // Arrange
      when(mockRepo.updateProfileBanner(userId, mediaId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final updateBannerFunction = container.read(updateProfileBannerProvider);
      final result = await updateBannerFunction(userId, mediaId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.updateProfileBanner(userId, mediaId)).called(1);
    });
  });

  group('updateProfilePhotoProvider', () {
    const userId = 'user123';
    const mediaId = 'media456';

    test('should call repository updateProfilePhoto method', () async {
      // Arrange
      when(mockRepo.updateProfilePhoto(userId, mediaId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final updatePhotoFunction = container.read(updateProfilePhotoProvider);
      final result = await updatePhotoFunction(userId, mediaId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.updateProfilePhoto(userId, mediaId)).called(1);
    });
  });

  group('removeBannerProvider', () {
    const userId = 'user123';

    test('should call repository removeBanner method', () async {
      // Arrange
      when(mockRepo.removeBanner(userId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final removeBannerFunction = container.read(removeBannerProvider);
      final result = await removeBannerFunction(userId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.removeBanner(userId)).called(1);
    });
  });

  group('followersYouKnowProvider', () {
    const testUsername = 'testuser';

    final testFollowers = [
      UserModel(
        displayName: 'Known Follower',
        userName: 'knownfollower',
        image: 'image1',
        bio: 'Bio 1',
        isFollowing: false,
        isFollower: true,
        isVerified: false,
      ),
    ];

    test('should return list of followers you know when repository succeeds',
        () async {
      // Arrange
      when(mockRepo.getFollowersYouKnow(testUsername))
          .thenAnswer((_) async => Right(testFollowers));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followersYouKnowProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (followers) {
          expect(followers.length, 1);
          expect(followers[0].userName, 'knownfollower');
        },
      );
      verify(mockRepo.getFollowersYouKnow(testUsername)).called(1);
    });
  });

  group('verifiedFollowersProvider', () {
    const testUsername = 'testuser';

    final testFollowers = [
      UserModel(
        displayName: 'Verified Follower',
        userName: 'verifiedfollower',
        image: 'image1',
        bio: 'Bio 1',
        isFollowing: false,
        isFollower: true,
        isVerified: true,
      ),
    ];

    test('should return list of verified followers when repository succeeds',
        () async {
      // Arrange
      when(mockRepo.getVerifiedFollowers(testUsername))
          .thenAnswer((_) async => Right(testFollowers));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        verifiedFollowersProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (followers) {
          expect(followers.length, 1);
          expect(followers[0].isVerified, true);
        },
      );
      verify(mockRepo.getVerifiedFollowers(testUsername)).called(1);
    });
  });

  group('getBlockedUsersProvider', () {
    const testUsername = 'testuser';

    final testBlockedUsers = [
      UserModel(
        displayName: 'Blocked User',
        userName: 'blockeduser',
        image: 'image1',
        bio: 'Bio 1',
        isFollowing: false,
        isFollower: false,
        isVerified: false,
      ),
    ];

    test('should return list of blocked users when repository succeeds',
        () async {
      // Arrange
      when(mockRepo.getBlockedList(testUsername))
          .thenAnswer((_) async => Right(testBlockedUsers));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        getBlockedUsersProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (users) {
          expect(users.length, 1);
          expect(users[0].userName, 'blockeduser');
        },
      );
      verify(mockRepo.getBlockedList(testUsername)).called(1);
    });
  });

  group('getMutedUsersProvider', () {
    const testUsername = 'testuser';

    final testMutedUsers = [
      UserModel(
        displayName: 'Muted User',
        userName: 'muteduser',
        image: 'image1',
        bio: 'Bio 1',
        isFollowing: false,
        isFollower: false,
        isVerified: false,
      ),
    ];

    test('should return list of muted users when repository succeeds',
        () async {
      // Arrange
      when(mockRepo.getMutedList(testUsername))
          .thenAnswer((_) async => Right(testMutedUsers));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        getMutedUsersProvider(testUsername).future,
      );

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (users) {
          expect(users.length, 1);
          expect(users[0].userName, 'muteduser');
        },
      );
      verify(mockRepo.getMutedList(testUsername)).called(1);
    });
  });

  group('retweetTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository retweetProfileTweet method', () async {
      // Arrange
      when(mockRepo.retweetProfileTweet(tweetId, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final retweetFunction = container.read(retweetTweetProvider);
      final result = await retweetFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.retweetProfileTweet(tweetId, any)).called(1);
    });
  });

  group('deleteRetweetTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository deleteRetweetProfileTweet method', () async {
      // Arrange
      when(mockRepo.deleteRetweetProfileTweet(tweetId, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final deleteRetweetFunction = container.read(deleteRetweetTweetProvider);
      final result = await deleteRetweetFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.deleteRetweetProfileTweet(tweetId, any)).called(1);
    });
  });

  group('saveTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository saveTweet method', () async {
      // Arrange
      when(mockRepo.saveTweet(tweetId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final saveFunction = container.read(saveTweetProvider);
      final result = await saveFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.saveTweet(tweetId)).called(1);
    });
  });

  group('unSaveTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository unSaveTweet method', () async {
      // Arrange
      when(mockRepo.unSaveTweet(tweetId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unsaveFunction = container.read(unSaveTweetProvider);
      final result = await unsaveFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unSaveTweet(tweetId)).called(1);
    });
  });

  group('removeBannerProvider', () {
    const userId = 'user123';

    test('should call repository removeBanner method', () async {
      // Arrange
      when(mockRepo.removeBanner(userId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final removeFunction = container.read(removeBannerProvider);
      final result = await removeFunction(userId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.removeBanner(userId)).called(1);
    });
  });

  group('followersProvider', () {
    const testUsername = 'testuser';

    test('should call repository getFollowers method', () async {
      // Arrange
      when(mockRepo.getFollowers(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followersProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getFollowers(testUsername)).called(1);
    });
  });

  group('followingsProvider', () {
    const testUsername = 'testuser';

    test('should call repository getFollowings method', () async {
      // Arrange
      when(mockRepo.getFollowings(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followingsProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getFollowings(testUsername)).called(1);
    });
  });

  group('followersYouKnowProvider', () {
    const testUsername = 'testuser';

    test('should call repository getFollowersYouKnow method', () async {
      // Arrange
      when(mockRepo.getFollowersYouKnow(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        followersYouKnowProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getFollowersYouKnow(testUsername)).called(1);
    });
  });

  group('verifiedFollowersProvider', () {
    const testUsername = 'testuser';

    test('should call repository getVerifiedFollowers method', () async {
      // Arrange
      when(mockRepo.getVerifiedFollowers(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        verifiedFollowersProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getVerifiedFollowers(testUsername)).called(1);
    });
  });

  group('unBlockUserProvider', () {
    const testUsername = 'testuser';

    test('should call repository unBlockUser method', () async {
      // Arrange
      when(mockRepo.unBlockUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unblockFunction = container.read(unBlockUserProvider);
      final result = await unblockFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unBlockUser(testUsername, any)).called(1);
    });
  });

  group('getBlockedUsersProvider', () {
    const testUsername = 'testuser';

    test('should call repository getBlockedList method', () async {
      // Arrange
      when(mockRepo.getBlockedList(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        getBlockedUsersProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getBlockedList(testUsername)).called(1);
    });
  });

  group('getMutedUsersProvider', () {
    const testUsername = 'testuser';

    test('should call repository getMutedList method', () async {
      // Arrange
      when(mockRepo.getMutedList(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        getMutedUsersProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getMutedList(testUsername)).called(1);
    });
  });

  group('unMuteUserProvider', () {
    const testUsername = 'testuser';

    test('should call repository unMuteUser method', () async {
      // Arrange
      when(mockRepo.unMuteUser(testUsername, any))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unmuteFunction = container.read(unMuteUserProvider);
      final result = await unmuteFunction(testUsername);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unMuteUser(testUsername, any)).called(1);
    });
  });

  group('profilePostsProvider', () {
    const testUsername = 'testuser';

    test('should call repository getProfilePosts method', () async {
      // Arrange
      when(mockRepo.getProfilePosts(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        profilePostsProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getProfilePosts(testUsername)).called(1);
    });
  });

  group('profileMediaProvider', () {
    const testUsername = 'testuser';

    test('should call repository getMediaPosts method', () async {
      // Arrange
      when(mockRepo.getMediaPosts(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        profileMediaProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getMediaPosts(testUsername)).called(1);
    });
  });

  group('profileLikesProvider', () {
    const testUsername = 'testuser';

    test('should call repository getProfileLikes method', () async {
      // Arrange
      when(mockRepo.getProfileLikes(testUsername))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        profileLikesProvider(testUsername).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getProfileLikes(testUsername)).called(1);
    });
  });

  group('tweetRepliesProvider', () {
    const tweetId = 'tweet123';

    test('should call repository getTweetReplies method', () async {
      // Arrange
      when(mockRepo.getTweetReplies(tweetId))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        tweetRepliesProvider(tweetId).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getTweetReplies(tweetId)).called(1);
    });
  });

  group('changeEmailProfileProvider', () {
    const newEmail = 'newemail@test.com';

    test('should call repository changeEmailProfile method', () async {
      // Arrange
      when(mockRepo.changeEmailProfile(newEmail))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final changeEmailFunction = container.read(changeEmailProfileProvider);
      final result = await changeEmailFunction(newEmail);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.changeEmailProfile(newEmail)).called(1);
    });
  });

  group('verifyChangeEmailProfileProvider', () {
    const newEmail = 'newemail@test.com';
    const code = '123456';

    test('should call repository verifyChangeEmailProfile method', () async {
      // Arrange
      when(mockRepo.verifyChangeEmailProfile(newEmail, code))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final verifyFunction = container.read(verifyChangeEmailProfileProvider);
      final result = await verifyFunction(newEmail, code);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.verifyChangeEmailProfile(newEmail, code)).called(1);
    });
  });

  group('changePasswordProfileProvider', () {
    const oldPassword = 'oldpass123';
    const newPassword = 'newpass123';
    const confirmNewPassword = 'newpass123';

    test('should call repository changePasswordProfile method', () async {
      // Arrange
      when(mockRepo.changePasswordProfile(
        oldPassword,
        newPassword,
        confirmNewPassword,
      )).thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final changePasswordFunction = container.read(changePasswordProfileProvider);
      final result = await changePasswordFunction(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.changePasswordProfile(
        oldPassword,
        newPassword,
        confirmNewPassword,
      )).called(1);
    });
  });

  group('replyOnTweetProvider', () {
    const tweetId = 'tweet123';
    final createReplyModel = CreateReplyModel();

    test('should call repository replyOnTweet method', () async {
      // Arrange
      when(mockRepo.replyOnTweet(tweetId, createReplyModel))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final replyFunction = container.read(replyOnTweetProvider);
      final result = await replyFunction(tweetId, createReplyModel);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.replyOnTweet(tweetId, createReplyModel)).called(1);
    });
  });

  group('profileCurrentSearchProvider', () {
    const query = 'search query';

    test('should call repository profileCurrentSearch method', () async {
      // Arrange
      when(mockRepo.profileCurrentSearch(query))
          .thenAnswer((_) async => const Right([]));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(
        profileCurrentSearchProvider(query).future,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.profileCurrentSearch(query)).called(1);
    });
  });

  group('saveTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository saveTweet method', () async {
      // Arrange
      when(mockRepo.saveTweet(tweetId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final saveFunction = container.read(saveTweetProvider);
      final result = await saveFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.saveTweet(tweetId)).called(1);
    });
  });

  group('unSaveTweetProvider', () {
    const tweetId = 'tweet123';

    test('should call repository unSaveTweet method', () async {
      // Arrange
      when(mockRepo.unSaveTweet(tweetId))
          .thenAnswer((_) async => const Right(null));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final unsaveFunction = container.read(unSaveTweetProvider);
      final result = await unsaveFunction(tweetId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.unSaveTweet(tweetId)).called(1);
    });
  });

  group('editProfileProvider', () {
    final newProfileModel = ProfileModel(
      id: 'user123',
      username: 'updateduser',
      displayName: 'Updated User',
      bio: 'Updated bio',
      followersCount: 150,
      followingCount: 75,
      tweetsCount: 25,
      isVerified: true,
      joinedDate: 'January 2024',
      website: 'https://updated.com',
      location: 'Los Angeles',
      postCount: 25,
      birthDate: 'January 1, 1990',
      isFollowing: false,
      isFollower: false,
      protectedAccount: true,
      isBlockedByMe: false,
      isMutedByMe: false,
      email: 'updated@test.com',
      avatarId: 'avatar456',
      bannerId: 'banner456',
    );

    test('should call repository updateProfile method', () async {
      // Arrange
      when(mockRepo.updateProfile(newModel: newProfileModel))
          .thenAnswer((_) async => Right(newProfileModel));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final editFunction = container.read(editProfileProvider);
      final result = await editFunction(newProfileModel);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.updateProfile(newModel: newProfileModel)).called(1);
    });
  });

  group('forYouTrendsProvider', () {
    test('should call repository getForYouTrends method', () async {
      // Arrange
      final mockForYouResponse = ForYouResponseModel(
        categories: [],
        suggestedUsers: [],
      );
      when(mockRepo.getForYouTrends())
          .thenAnswer((_) async => Right(mockForYouResponse));

      container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act
      final result = await container.read(forYouTrendsProvider.future);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepo.getForYouTrends()).called(1);
    });
  });
}

