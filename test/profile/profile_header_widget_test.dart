import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
    avatarUrl: 'https://example.com/avatar.jpg',
    bannerUrl: 'https://example.com/banner.jpg',
    isVerified: true,
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
    avatarId: 'avatar123',
  );

  group('Profile Header Tests', () {
    test('profile has avatar URL', () {
      expect(testProfile.avatarUrl, isNotEmpty);
      expect(testProfile.avatarUrl, contains('https://'));
    });

    test('profile has banner URL', () {
      expect(testProfile.bannerUrl, isNotEmpty);
      expect(testProfile.bannerUrl, contains('https://'));
    });

    testWidgets('shows verified badge for verified users', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Row(
                        children: [
                          Text(profile.displayName),
                          if (profile.isVerified)
                            Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('does not show verified badge for non-verified users', (tester) async {
      final unverifiedProfile = testProfile.copyWith(isVerified: false);
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(unverifiedProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Row(
                        children: [
                          Text(profile.displayName),
                          if (profile.isVerified)
                            Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('displays follower count correctly', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Column(
                        children: [
                          Text('${profile.followersCount} Followers'),
                          Text('${profile.followingCount} Following'),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100 Followers'), findsOneWidget);
      expect(find.text('50 Following'), findsOneWidget);
    });

    testWidgets('displays bio correctly', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Column(
                        children: [
                          Text(profile.displayName),
                          Text(profile.bio),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test bio'), findsOneWidget);
    });

    testWidgets('displays location when available', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Row(
                        children: [
                          Icon(Icons.location_on),
                          Text(profile.location),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays website when available', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Row(
                        children: [
                          Icon(Icons.link),
                          Text(profile.website),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('https://test.com'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('displays join date correctly', (tester) async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Row(
                        children: [
                          Icon(Icons.calendar_today),
                          Text('Joined ${profile.joinedDate}'),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Joined'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('shows protected account icon when applicable', (tester) async {
      final protectedProfile = testProfile.copyWith(protectedAccount: true);
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(protectedProfile));

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

                  return profileData.when(
                    data: (either) => either.fold(
                      (l) => Text('Error'),
                      (profile) => Row(
                        children: [
                          Text(profile.displayName),
                          if (profile.protectedAccount)
                            Icon(Icons.lock),
                        ],
                      ),
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
