import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';

import 'profile_repo_extended_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProfileRepo>()])
void main() {
  setUpAll(() {
    provideDummy<Either<Failure, void>>(Left(Failure('dummy')));
    provideDummy<Either<Failure, List<SearchUserModel>>>(Left(Failure('dummy')));
    provideDummy<Either<Failure, List<TweetReplyModel>>>(Left(Failure('dummy')));
  });

  group('Profile additional providers (mockito)', () {
    late MockProfileRepo mockRepo;

    setUp(() {
      mockRepo = MockProfileRepo();
    });

    test('updateProfileBannerProvider calls repo.updateProfileBanner and returns Right', () async {
      when(mockRepo.updateProfileBanner('user1', 'media1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(updateProfileBannerProvider);
      final res = await fn('user1', 'media1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.updateProfileBanner('user1', 'media1')).called(1);
    });

    test('updateProfilePhotoProvider calls repo.updateProfilePhoto and returns Right', () async {
      when(mockRepo.updateProfilePhoto('user1', 'media1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(updateProfilePhotoProvider);
      final res = await fn('user1', 'media1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.updateProfilePhoto('user1', 'media1')).called(1);
    });

    test('deleteTweetProvider calls repo.deleteTweet and returns Right', () async {
      when(mockRepo.deleteTweet('tweet1')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(deleteTweetProvider);
      final res = await fn('tweet1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.deleteTweet('tweet1')).called(1);
    });

    test('profileCurrentSearchProvider returns search results on success', () async {
      final mockSearchResults = [
        SearchUserModel(
          id: '1',
          username: 'user1',
          name: 'User One',
          verified: false,
          bio: 'Bio',
          profileMedia: '',
          followers: 100,
          score: 10,
          isFollowing: false,
          isFollower: false,
        ),
      ];
      when(mockRepo.profileCurrentSearch('query')).thenAnswer((_) async => Right(mockSearchResults));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(profileCurrentSearchProvider('query').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });

    test('changeEmailProfileProvider calls repo.changeEmailProfile and returns Right', () async {
      when(mockRepo.changeEmailProfile('newemail@test.com')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(changeEmailProfileProvider);
      final res = await fn('newemail@test.com');

      expect(res.isRight(), isTrue);
      verify(mockRepo.changeEmailProfile('newemail@test.com')).called(1);
    });

    test('verifyChangeEmailProfileProvider calls repo.verifyChangeEmailProfile and returns Right', () async {
      when(mockRepo.verifyChangeEmailProfile('newemail@test.com', '123456')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(verifyChangeEmailProfileProvider);
      final res = await fn('newemail@test.com', '123456');

      expect(res.isRight(), isTrue);
      verify(mockRepo.verifyChangeEmailProfile('newemail@test.com', '123456')).called(1);
    });

    test('changePasswordProfileProvider calls repo.changePasswordProfile and returns Right', () async {
      when(mockRepo.changePasswordProfile('oldPass', 'newPass', 'newPass')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(changePasswordProfileProvider);
      final res = await fn(oldPassword: 'oldPass', newPassword: 'newPass', confirmNewPassword: 'newPass');

      expect(res.isRight(), isTrue);
      verify(mockRepo.changePasswordProfile('oldPass', 'newPass', 'newPass')).called(1);
    });

    test('tweetRepliesProvider returns replies on success', () async {
      final mockReplies = [
        TweetReplyModel(
          id: '1',
          userId: 'user1',
          content: 'reply content',
          createdAt: '2024-01-01',
          lastActivityAt: '2024-01-01',
          likesCount: 0,
          retweetCount: 0,
          repliesCount: 0,
          quotesCount: 0,
          replyControl: 'everyone',
          parentId: 'parent1',
          tweetType: 'reply',
          user: UserReplyModel(
            id: 'user1',
            name: 'User',
            username: 'user1',
            profileMedia: '',
            protectedAccount: false,
            verified: false,
          ),
        ),
      ];
      when(mockRepo.getTweetReplies('tweet1')).thenAnswer((_) async => Right(mockReplies));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(tweetRepliesProvider('tweet1').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.length, 1));
    });
  });
}
