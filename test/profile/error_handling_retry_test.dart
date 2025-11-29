import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_extended_test.mocks.dart';

void main() {
  late MockProfileRepo mockRepo;

  setUp(() {
    mockRepo = MockProfileRepo();
  });

  final testProfile = ProfileModel(
    id: '123',
    username: 'testuser',
    displayName: 'Test User',
    email: 'test@example.com',
    bio: 'Test bio',
    birthDate: '1990-01-01',
    location: 'Test Location',
    website: 'https://test.com',
    avatarUrl: '',
    bannerUrl: '',
    isVerified: false,
    isFollowing: false,
    isFollower: false,
    isBlockedByMe: false,
    isMutedByMe: false,
    followersCount: 100,
    followingCount: 50,
    tweetsCount: 10,
    postCount: 10,
    joinedDate: '2020-01-01',
    protectedAccount: false,
    avatarId: '',
  );

  group('Error Handling & Retry Tests', () {
    test('getProfileData returns Left with timeout message on connection timeout', () async {
      when(mockRepo.getProfileData('testuser')).thenAnswer(
        (_) async => Left(Failure('connection timeout, please try agin...')),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final result = await container.read(profileDataProvider('testuser').future);

      result.fold(
        (failure) {
          expect(failure.message, contains('timeout'));
        },
        (profile) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.getProfileData('testuser')).called(1);
      container.dispose();
    });

    test('getProfileData handles generic failure gracefully', () async {
      when(mockRepo.getProfileData('testuser')).thenAnswer(
        (_) async => Left(Failure('Failed to load profile data, try agian later...')),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final result = await container.read(profileDataProvider('testuser').future);

      result.fold(
        (failure) {
          expect(failure.message, 'Failed to load profile data, try agian later...');
        },
        (profile) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.getProfileData('testuser')).called(1);
      container.dispose();
    });

    test('followUser returns Left on network failure', () async {
      when(mockRepo.followUser('testuser')).thenAnswer(
        (_) async => Left(Failure("couldn't follow user")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final follow = container.read(followControllerProvider);
      final result = await follow('testuser');

      result.fold(
        (failure) {
          expect(failure.message, "couldn't follow user");
        },
        (_) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.followUser('testuser')).called(1);
      container.dispose();
    });

    test('unFollowUser returns Left on network failure', () async {
      when(mockRepo.unFollowUser('testuser')).thenAnswer(
        (_) async => Left(Failure("couldn't unfollow user")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final unfollow = container.read(unFollowControllerProvider);
      final result = await unfollow('testuser');

      result.fold(
        (failure) {
          expect(failure.message, "couldn't unfollow user");
        },
        (_) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.unFollowUser('testuser')).called(1);
      container.dispose();
    });

    test('blockUser returns Left on failure', () async {
      when(mockRepo.blockUser('testuser')).thenAnswer(
        (_) async => Left(Failure("couldn't block user")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final block = container.read(blockUserProvider);
      final result = await block('testuser');

      result.fold(
        (failure) {
          expect(failure.message, "couldn't block user");
        },
        (_) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.blockUser('testuser')).called(1);
      container.dispose();
    });

    test('muteUser returns Left on failure', () async {
      when(mockRepo.muteUser('testuser')).thenAnswer(
        (_) async => Left(Failure("couldn't mute user")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final mute = container.read(muteUserProvider);
      final result = await mute('testuser');

      result.fold(
        (failure) {
          expect(failure.message, "couldn't mute user");
        },
        (_) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.muteUser('testuser')).called(1);
      container.dispose();
    });

    test('updateProfile returns Left on failure', () async {
      when(mockRepo.updateProfile(newModel: testProfile)).thenAnswer(
        (_) async => Left(Failure("Failed to update profile")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final editProfile = container.read(editProfileProvider);
      final result = await editProfile(testProfile);

      result.fold(
        (failure) {
          expect(failure.message, "Failed to update profile");
        },
        (_) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.updateProfile(newModel: testProfile)).called(1);
      container.dispose();
    });

    test('deleteTweet returns Left on failure', () async {
      when(mockRepo.deleteTweet('tweet123')).thenAnswer(
        (_) async => Left(Failure("Failed to delete tweet")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final deleteTweet = container.read(deleteTweetProvider);
      final result = await deleteTweet('tweet123');

      result.fold(
        (failure) {
          expect(failure.message, "Failed to delete tweet");
        },
        (_) => fail('Expected Left but got Right'),
      );

      verify(mockRepo.deleteTweet('tweet123')).called(1);
      container.dispose();
    });

    test('multiple failures are handled independently', () async {
      when(mockRepo.followUser('user1')).thenAnswer(
        (_) async => Left(Failure("Error 1")),
      );
      when(mockRepo.followUser('user2')).thenAnswer(
        (_) async => Left(Failure("Error 2")),
      );
      when(mockRepo.followUser('user3')).thenAnswer(
        (_) async => const Right(()),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final follow = container.read(followControllerProvider);

      final result1 = await follow('user1');
      final result2 = await follow('user2');
      final result3 = await follow('user3');

      expect(result1.isLeft(), true);
      expect(result2.isLeft(), true);
      expect(result3.isRight(), true);

      result1.fold((f) => expect(f.message, "Error 1"), (_) {});
      result2.fold((f) => expect(f.message, "Error 2"), (_) {});

      container.dispose();
    });

    test('consecutive retry after failure succeeds', () async {
      int callCount = 0;
      when(mockRepo.getProfileData('testuser')).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Left(Failure('Network error'));
        } else {
          return Right(testProfile);
        }
      });

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // First call fails
      final result1 = await container.read(profileDataProvider('testuser').future);
      expect(result1.isLeft(), true);

      // Refresh and try again
      container.refresh(profileDataProvider('testuser'));
      final result2 = await container.read(profileDataProvider('testuser').future);
      expect(result2.isRight(), true);

      verify(mockRepo.getProfileData('testuser')).called(2);
      container.dispose();
    });

    test('error message formats are consistent across providers', () async {
      when(mockRepo.followUser('user')).thenAnswer(
        (_) async => Left(Failure("couldn't follow user")),
      );
      when(mockRepo.blockUser('user')).thenAnswer(
        (_) async => Left(Failure("couldn't block user")),
      );
      when(mockRepo.muteUser('user')).thenAnswer(
        (_) async => Left(Failure("couldn't mute user")),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final follow = await container.read(followControllerProvider)('user');
      final block = await container.read(blockUserProvider)('user');
      final mute = await container.read(muteUserProvider)('user');

      follow.fold((f) => expect(f.message, contains("couldn't")), (_) {});
      block.fold((f) => expect(f.message, contains("couldn't")), (_) {});
      mute.fold((f) => expect(f.message, contains("couldn't")), (_) {});

      container.dispose();
    });
  });
}
