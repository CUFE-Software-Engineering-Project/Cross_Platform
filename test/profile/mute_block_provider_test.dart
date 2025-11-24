import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mute_block_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProfileRepo>(),
])

void main() {
  group('Mute/Block providers (Mockito)', () {
    setUpAll(() {
      // Mockito needs dummy values for generic Either types used in generated mocks
      provideDummy<Either<Failure, void>>(const Left(Failure('dummy')));
      provideDummy<Either<Failure, List<UserModel>>>(const Left(Failure('dummy')));
      provideDummy<Either<Failure, ProfileModel>>(const Left(Failure('dummy')));
    });
    late MockProfileRepo mockRepo;

    setUp(() {
      mockRepo = MockProfileRepo();
    });

    test('blockUserProvider returns Right on success (mocked)', () async {
      when(mockRepo.blockUser(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(blockUserProvider);
      final res = await fn('user1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.blockUser('user1')).called(1);
    });

    test('blockUserProvider returns Left on failure (mocked)', () async {
      when(mockRepo.blockUser(any)).thenAnswer((_) async => const Left(Failure('block failed')));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(blockUserProvider);
      final res = await fn('user1');

      expect(res.isLeft(), isTrue);
      res.match((l) => expect(l.message, 'block failed'), (_) => null);
      verify(mockRepo.blockUser('user1')).called(1);
    });

    test('unBlockUserProvider returns Right on success (mocked)', () async {
      when(mockRepo.unBlockUser(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unBlockUserProvider);
      final res = await fn('user1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unBlockUser('user1')).called(1);
    });

    test('unBlockUserProvider returns Left on failure (mocked)', () async {
      when(mockRepo.unBlockUser(any)).thenAnswer((_) async => const Left(Failure('unblock failed')));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unBlockUserProvider);
      final res = await fn('user1');

      expect(res.isLeft(), isTrue);
      res.match((l) => expect(l.message, 'unblock failed'), (_) => null);
      verify(mockRepo.unBlockUser('user1')).called(1);
    });

    test('muteUserProvider returns Right on success (mocked)', () async {
      when(mockRepo.muteUser(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(muteUserProvider);
      final res = await fn('user1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.muteUser('user1')).called(1);
    });

    test('muteUserProvider returns Left on failure (mocked)', () async {
      when(mockRepo.muteUser(any)).thenAnswer((_) async => const Left(Failure('mute failed')));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(muteUserProvider);
      final res = await fn('user1');

      expect(res.isLeft(), isTrue);
      res.match((l) => expect(l.message, 'mute failed'), (_) => null);
      verify(mockRepo.muteUser('user1')).called(1);
    });

    test('unMuteUserProvider returns Right on success (mocked)', () async {
      when(mockRepo.unMuteUser(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unMuteUserProvider);
      final res = await fn('user1');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unMuteUser('user1')).called(1);
    });

    test('unMuteUserProvider returns Left on failure (mocked)', () async {
      when(mockRepo.unMuteUser(any)).thenAnswer((_) async => const Left(Failure('unmute failed')));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unMuteUserProvider);
      final res = await fn('user1');

      expect(res.isLeft(), isTrue);
      res.match((l) => expect(l.message, 'unmute failed'), (_) => null);
      verify(mockRepo.unMuteUser('user1')).called(1);
    });

    // Additional providers: follow/unfollow, like/unlike, save/unsave
    test('followControllerProvider calls repo.followUser', () async {
      when(mockRepo.followUser(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(followControllerProvider);
      final res = await fn('user2');

      expect(res.isRight(), isTrue);
      verify(mockRepo.followUser('user2')).called(1);
    });

    test('unFollowControllerProvider calls repo.unFollowUser', () async {
      when(mockRepo.unFollowUser(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(unFollowControllerProvider);
      final res = await fn('user2');

      expect(res.isRight(), isTrue);
      verify(mockRepo.unFollowUser('user2')).called(1);
    });

    test('likeTweetProvider and unlikeTweetProvider call repo methods', () async {
      when(mockRepo.likeTweet(any)).thenAnswer((_) async => const Right(null));
      when(mockRepo.unLikeTweet(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final likeFn = container.read(likeTweetProvider);
      final unlikeFn = container.read(unlikeTweetProvider);

      final likeRes = await likeFn('tweet1');
      final unlikeRes = await unlikeFn('tweet1');

      expect(likeRes.isRight(), isTrue);
      expect(unlikeRes.isRight(), isTrue);
      verify(mockRepo.likeTweet('tweet1')).called(1);
      verify(mockRepo.unLikeTweet('tweet1')).called(1);
    });

    test('saveTweetProvider and unSaveTweetProvider call repo methods', () async {
      when(mockRepo.saveTweet(any)).thenAnswer((_) async => const Right(null));
      when(mockRepo.unSaveTweet(any)).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final saveFn = container.read(saveTweetProvider);
      final unSaveFn = container.read(unSaveTweetProvider);

      final saveRes = await saveFn('tweet2');
      final unSaveRes = await unSaveFn('tweet2');

      expect(saveRes.isRight(), isTrue);
      expect(unSaveRes.isRight(), isTrue);
      verify(mockRepo.saveTweet('tweet2')).called(1);
      verify(mockRepo.unSaveTweet('tweet2')).called(1);
    });
  });
}
