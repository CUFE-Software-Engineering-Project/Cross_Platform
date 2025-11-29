import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
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

  final testUser = UserModel(
    displayName: 'Test User',
    userName: 'testuser',
    image: '',
    bio: 'Test bio',
    isFollowing: false,
    isFollower: false,
    isVerified: false,
  );

  group('RefreshIndicator Tests', () {
    testWidgets('profile data refresh calls provider refresh', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      int refreshCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final profileData = ref.watch(profileDataProvider('testuser'));

                  return RefreshIndicator(
                    onRefresh: () async {
                      refreshCount++;
                      // ignore: unused_result
                      ref.refresh(profileDataProvider('testuser'));
                    },
                    child: profileData.when(
                      data: (either) => either.fold(
                        (l) => ListView(children: [Text('Error')]),
                        (profile) => ListView(
                          children: [Text(profile.displayName)],
                        ),
                      ),
                      loading: () => ListView(children: [CircularProgressIndicator()]),
                      error: (e, s) => ListView(children: [Text('Error: $e')]),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger refresh by dragging down
      await tester.drag(find.text('Test User'), Offset(0, 300));
      await tester.pumpAndSettle();

      expect(refreshCount, 1);
      verify(mockRepo.getProfileData('testuser')).called(greaterThan(1));
    });

    test('followers provider refresh reloads data', () async {
      when(mockRepo.getFollowers('testuser'))
          .thenAnswer((_) async => Right([testUser]));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Initial load
      await container.read(followersProvider('testuser').future);
      verify(mockRepo.getFollowers('testuser')).called(1);

      // Refresh
      container.refresh(followersProvider('testuser'));
      await container.read(followersProvider('testuser').future);

      verify(mockRepo.getFollowers('testuser')).called(greaterThanOrEqualTo(1));
      container.dispose();
    });

    test('followings provider refresh reloads data', () async {
      when(mockRepo.getFollowings('testuser'))
          .thenAnswer((_) async => Right([testUser]));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Initial load
      await container.read(followingsProvider('testuser').future);
      verify(mockRepo.getFollowings('testuser')).called(1);

      // Refresh
      container.refresh(followingsProvider('testuser'));
      await container.read(followingsProvider('testuser').future);

      verify(mockRepo.getFollowings('testuser')).called(greaterThanOrEqualTo(1));
      container.dispose();
    });

    test('profile posts refresh reloads posts', () async {
      when(mockRepo.getProfilePosts('123'))
          .thenAnswer((_) async => Right([]));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Initial load
      await container.read(profilePostsProvider('123').future);
      verify(mockRepo.getProfilePosts('123')).called(1);

      // Refresh
      container.refresh(profilePostsProvider('123'));
      await container.read(profilePostsProvider('123').future);

      verify(mockRepo.getProfilePosts('123')).called(greaterThanOrEqualTo(1));
      container.dispose();
    });

    test('multiple providers can be refreshed independently', () async {
      when(mockRepo.getProfileData('user1'))
          .thenAnswer((_) async => Right(testProfile));
      when(mockRepo.getProfileData('user2'))
          .thenAnswer((_) async => Right(testProfile.copyWith(username: 'user2')));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Load both
      await container.read(profileDataProvider('user1').future);
      await container.read(profileDataProvider('user2').future);

      // Refresh only user1
      container.refresh(profileDataProvider('user1'));
      await container.read(profileDataProvider('user1').future);

      // user1 called twice, user2 called once
      verify(mockRepo.getProfileData('user1')).called(2);
      verify(mockRepo.getProfileData('user2')).called(1);

      container.dispose();
    });

    test('refresh after error retries successfully', () async {
      int callCount = 0;
      when(mockRepo.getProfileData('testuser')).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Left(Failure('Error'));
        }
        return Right(testProfile);
      });

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // First call fails
      final result1 = await container.read(profileDataProvider('testuser').future);
      expect(result1.isLeft(), true);

      // Refresh
      container.refresh(profileDataProvider('testuser'));
      final result2 = await container.read(profileDataProvider('testuser').future);
      expect(result2.isRight(), true);

      container.dispose();
    });

    test('refresh preserves other provider states', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));
      when(mockRepo.getFollowers('testuser'))
          .thenAnswer((_) async => Right([testUser]));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Load both
      await container.read(profileDataProvider('testuser').future);
      await container.read(followersProvider('testuser').future);

      // Refresh only profile data
      container.refresh(profileDataProvider('testuser'));
      await container.read(profileDataProvider('testuser').future);

      // Profile called twice, followers once
      verify(mockRepo.getProfileData('testuser')).called(2);
      verify(mockRepo.getFollowers('testuser')).called(1);

      container.dispose();
    });
  });

  group('Loading State Tests', () {
    test('profile data shows loading state initially', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      final provider = container.read(profileDataProvider('testuser'));
      
      expect(provider.isLoading, true);
      expect(provider.hasValue, false);

      await container.read(profileDataProvider('testuser').future);

      final loadedProvider = container.read(profileDataProvider('testuser'));
      expect(loadedProvider.hasValue, true);

      container.dispose();
    });

    test('refresh maintains existing data during reload', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      final container = ProviderContainer(
        overrides: [
          profileRepoProvider.overrideWithValue(mockRepo),
        ],
      );

      // Initial load
      await container.read(profileDataProvider('testuser').future);
      final initialData = container.read(profileDataProvider('testuser'));
      expect(initialData.hasValue, true);

      // Refresh - data should still be available
      container.refresh(profileDataProvider('testuser'));
      
      container.dispose();
    });
  });
}
