import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile/follow_following_button.dart';
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

  group('Follow/Following Button Widget Tests', () {
    testWidgets('displays "Follow" when user is not following', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: testProfile),
            ),
          ),
        ),
      );

      expect(find.text('Follow'), findsOneWidget);
      expect(find.text('Following'), findsNothing);
    });

    testWidgets('displays "Follow Back" when user is follower but not following', (tester) async {
      final followerProfile = testProfile.copyWith(isFollower: true, isFollowing: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: followerProfile),
            ),
          ),
        ),
      );

      expect(find.text('Follow Back'), findsOneWidget);
    });

    testWidgets('displays "Following" when user is following', (tester) async {
      final followingProfile = testProfile.copyWith(isFollowing: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: followingProfile),
            ),
          ),
        ),
      );

      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('follow action updates state optimistically on success', (tester) async {
      when(mockRepo.followUser('testuser'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: testProfile),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Follow'), findsOneWidget);

      // Tap follow button
      await tester.tap(find.text('Follow'));
      await tester.pump();

      // Should update optimistically to "Following"
      expect(find.text('Following'), findsOneWidget);

      verify(mockRepo.followUser('testuser')).called(1);
    });

    testWidgets('follow action rolls back state on failure', (tester) async {
      when(mockRepo.followUser('testuser'))
          .thenAnswer((_) async => Left(Failure("Network error")));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: testProfile),
            ),
          ),
        ),
      );

      // Tap follow button
      await tester.tap(find.text('Follow'));
      await tester.pump();

      // Wait for async operation
      await tester.pump(const Duration(milliseconds: 100));

      // Should roll back to "Follow" after error
      expect(find.text('Follow'), findsOneWidget);

      verify(mockRepo.followUser('testuser')).called(1);
    });

    testWidgets('unfollow shows confirmation dialog', (tester) async {
      final followingProfile = testProfile.copyWith(isFollowing: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: followingProfile),
            ),
          ),
        ),
      );

      // Tap following button
      await tester.tap(find.text('Following'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Unfollow Test User'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Unfollow'), findsAtLeastNWidgets(1));
    });

    testWidgets('unfollow dialog cancel keeps following state', (tester) async {
      final followingProfile = testProfile.copyWith(isFollowing: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: followingProfile),
            ),
          ),
        ),
      );

      // Tap following button
      await tester.tap(find.text('Following'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should still be following
      expect(find.text('Following'), findsOneWidget);

      verifyNever(mockRepo.unFollowUser(any));
    });

    testWidgets('unfollow dialog confirm updates state', (tester) async {
      final followingProfile = testProfile.copyWith(isFollowing: true);
      when(mockRepo.unFollowUser('testuser'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: followingProfile),
            ),
          ),
        ),
      );

      // Tap following button
      await tester.tap(find.text('Following'));
      await tester.pumpAndSettle();

      // Tap unfollow in dialog
      final unfollowButton = find.text('Unfollow').last;
      await tester.tap(unfollowButton);
      await tester.pump();

      // Should update to "Follow"
      expect(find.text('Follow'), findsOneWidget);

      verify(mockRepo.unFollowUser('testuser')).called(1);
    });

    testWidgets('unfollow rolls back on failure', (tester) async {
      final followingProfile = testProfile.copyWith(isFollowing: true);
      when(mockRepo.unFollowUser('testuser'))
          .thenAnswer((_) async => Left(Failure("Network error")));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: followingProfile),
            ),
          ),
        ),
      );

      // Tap following button
      await tester.tap(find.text('Following'));
      await tester.pumpAndSettle();

      // Confirm unfollow
      final unfollowButton = find.text('Unfollow').last;
      await tester.tap(unfollowButton);
      await tester.pump();

      // Wait for async error
      await tester.pump(const Duration(milliseconds: 100));

      // Should roll back to "Following"
      expect(find.text('Following'), findsOneWidget);

      verify(mockRepo.unFollowUser('testuser')).called(1);
    });

    testWidgets('button styling changes based on following state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Follow_Following_Button(profileData: testProfile),
            ),
          ),
        ),
      );

      // Find button widget
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style!;

      // Check initial styling for "Follow" state (white background)
      expect(style.backgroundColor?.resolve({}), Colors.white);
      expect(style.foregroundColor?.resolve({}), Colors.white);
    });
  });
}
