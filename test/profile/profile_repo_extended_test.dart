import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';

import 'profile_providers_mockito_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProfileRepo>()])
void main() {
  setUpAll(() {
    provideDummy<Either<Failure, void>>(Left(Failure('dummy')));
    provideDummy<Either<Failure, List<UserModel>>>(Left(Failure('dummy')));
  });

  group('Profile providers (extended mockito)', () {
    late MockProfileRepo mockRepo;

    setUp(() {
      mockRepo = MockProfileRepo();
    });

    test('unFollowControllerProvider calls repo.unFollowUser and returns Right', () async {
      when(mockRepo.unFollowUser('other')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unFollowControllerProvider);
      final res = await fn('other');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unFollowUser('other')).called(1);
    });

    test('followersProvider returns followers on success', () async {
      final mockFollowers = [
        UserModel(userName: 'follower1', displayName: 'Follower One', image: '', bio: '', isVerified: false, isFollowing: false, isFollower: false),
        UserModel(userName: 'follower2', displayName: 'Follower Two', image: '', bio: '', isVerified: false, isFollowing: false, isFollower: false),
      ];
      when(mockRepo.getFollowers('testuser')).thenAnswer((_) async => Right(mockFollowers));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(followersProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 2));
    });

    test('followingsProvider returns followings on success', () async {
      final mockFollowings = [
        UserModel(userName: 'following1', displayName: 'Following One', image: '', bio: '', isVerified: false, isFollowing: false, isFollower: false),
      ];
      when(mockRepo.getFollowings('testuser')).thenAnswer((_) async => Right(mockFollowings));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(followingsProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });

    test('blockUserProvider calls repo.blockUser and returns Right', () async {
      when(mockRepo.blockUser('other')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(blockUserProvider);
      final res = await fn('other');

      expect(res.isRight(), isTrue);
      verify(mockRepo.blockUser('other')).called(1);
    });

    test('unBlockUserProvider calls repo.unBlockUser and returns Right', () async {
      when(mockRepo.unBlockUser('other')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unBlockUserProvider);
      final res = await fn('other');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unBlockUser('other')).called(1);
    });

    test('muteUserProvider calls repo.muteUser and returns Right', () async {
      when(mockRepo.muteUser('other')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(muteUserProvider);
      final res = await fn('other');

      expect(res.isRight(), isTrue);
      verify(mockRepo.muteUser('other')).called(1);
    });

    test('unMuteUserProvider calls repo.unMuteUser and returns Right', () async {
      when(mockRepo.unMuteUser('other')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unMuteUserProvider);
      final res = await fn('other');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unMuteUser('other')).called(1);
    });
    test('getMutedUsersProvider returns muted list on success', () async {
      final mockMuted = [
        UserModel(userName: 'muted1', displayName: 'Muted One', image: '', bio: '', isVerified: false, isFollowing: false, isFollower: false),
      ];
      when(mockRepo.getMutedList('testuser')).thenAnswer((_) async => Right(mockMuted));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(getMutedUsersProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });

    test('getBlockedUsersProvider returns blocked list on success', () async {
      final mockBlocked = [
        UserModel(userName: 'blocked1', displayName: 'Blocked One', image: '', bio: '', isVerified: false, isFollowing: false, isFollower: false),
      ];
      when(mockRepo.getBlockedList('testuser')).thenAnswer((_) async => Right(mockBlocked));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(getBlockedUsersProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });
    test('profilePostsProvider returns posts on success', () async {
      final mockPosts = [
        ProfileTweetModel(
          id: '1',
          text: 'test post',
          timeAgo: '1h',
          likes: 0,
          retweets: 0,
          replies: 0,
          activityNumber: 0,
          isLikedByMe: false,
          isSavedByMe: false,
          isRepostedWithMe: false,
          quotesCount: 0,
          userId: 'user1',
          userUserName: 'testuser',
          userDisplayName: 'Test User',
          profileMediaId: '',
          verified: false,
          protectedAccount: false,
          type: TweetType.Tweet,
          mediaIds: [],
          parentId: "123"
        ),
      ];
      when(mockRepo.getProfilePosts('testuser')).thenAnswer((_) async => Right(mockPosts));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(profilePostsProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });

    test('profileLikesProvider returns liked posts on success', () async {
      final mockLikes = [
        ProfileTweetModel(
          id: '2',
          text: 'liked post',
          timeAgo: '2h',
          likes: 1,
          retweets: 0,
          replies: 0,
          activityNumber: 0,
          isLikedByMe: true,
          isSavedByMe: false,
          isRepostedWithMe: false,
          quotesCount: 0,
          userId: 'user2',
          userUserName: 'anotheruser',
          userDisplayName: 'Another User',
          profileMediaId: '',
          verified: false,
          protectedAccount: false,
          type: TweetType.Tweet,
          mediaIds: [],
          parentId: "123"
        ),
      ];
      when(mockRepo.getProfileLikes('testuser')).thenAnswer((_) async => Right(mockLikes));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(profileLikesProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });
    test('likeTweetProvider calls repo.likeTweet and returns Right', () async {
      when(mockRepo.likeTweet('tweet1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(likeTweetProvider);
      final res = await fn('tweet1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.likeTweet('tweet1')).called(1);
    });

    test('unlikeTweetProvider calls repo.unLikeTweet and returns Right', () async {
      when(mockRepo.unLikeTweet('tweet1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unlikeTweetProvider);
      final res = await fn('tweet1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unLikeTweet('tweet1')).called(1);
    });

    test('saveTweetProvider calls repo.saveTweet and returns Right', () async {
      when(mockRepo.saveTweet('tweet1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(saveTweetProvider);
      final res = await fn('tweet1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.saveTweet('tweet1')).called(1);
    });

    test('unSaveTweetProvider calls repo.unSaveTweet and returns Right', () async {
      when(mockRepo.unSaveTweet('tweet1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unSaveTweetProvider);
      final res = await fn('tweet1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unSaveTweet('tweet1')).called(1);
    });
    test('verifiedFollowersProvider returns verified followers on success', () async {
      final mockUsers = [
        UserModel(userName: 'verified1', displayName: 'Verified One', image: '', bio: '', isVerified: true),
      ];
      when(mockRepo.getVerifiedFollowers('testuser')).thenAnswer((_) async => Right(mockUsers));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(verifiedFollowersProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });

    test('followersYouKnowProvider returns followers you know on success', () async {
      final mockUsers = [
        UserModel(userName: 'known1', displayName: 'Known One', image: '', bio: '', isFollower: true),
      ];
      when(mockRepo.getFollowersYouKnow('testuser')).thenAnswer((_) async => Right(mockUsers));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(followersYouKnowProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });
  });
}
