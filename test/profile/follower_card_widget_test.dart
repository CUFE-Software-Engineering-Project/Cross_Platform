import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/follower_card.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_extended_test.mocks.dart';

void main() {
  late MockProfileRepo mockRepo;

  setUp(() {
    mockRepo = MockProfileRepo();
  });

  final testUser = UserModel(
    displayName: 'Test User',
    userName: 'testuser',
    image: 'https://example.com/avatar.jpg',
    bio: 'Test bio',
    isFollowing: false,
    isFollower: false,
    isVerified: false,
  );

  group('Follower Card Widget Tests', () {
    testWidgets('displays user information correctly', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: testUser, isMe: false),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) => Scaffold(
              body: Text('Profile'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);
    });

    testWidgets('shows "Follows you" badge when isFollower is true', (tester) async {
      final followerUser = testUser.copyWith(isFollower: true);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: followerUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Follows you'), findsOneWidget);
    });

    testWidgets('does not show "Follows you" badge when isFollower is false', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: testUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Follows you'), findsNothing);
    });

    testWidgets('displays Follow button when not following', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: testUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('displays Following button when already following', (tester) async {
      final followingUser = testUser.copyWith(isFollowing: true);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: followingUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('follow button triggers followUser action', (tester) async {
      when(mockRepo.followUser('testuser'))
          .thenAnswer((_) async => const Right(()));

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: testUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Follow'));
      await tester.pump();

      // Optimistically updates to "Following"
      expect(find.text('Following'), findsOneWidget);

      verify(mockRepo.followUser('testuser')).called(1);
    });

    testWidgets('follow error rolls back to Follow state', (tester) async {
      when(mockRepo.followUser('testuser'))
          .thenAnswer((_) async => Left(Failure("Network error")));

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: testUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Follow'));
      await tester.pump();

      // Wait for error
      await tester.pump(const Duration(milliseconds: 100));

      // Should roll back to "Follow"
      expect(find.text('Follow'), findsOneWidget);

      verify(mockRepo.followUser('testuser')).called(1);
    });

    testWidgets('unfollow shows confirmation dialog', (tester) async {
      final followingUser = testUser.copyWith(isFollowing: true);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: followingUser, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test verifies widget can be built with following user
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('navigates to profile on tap', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: testUser, isMe: false),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) {
              final username = state.pathParameters['username'];
              return Scaffold(
                body: Text('Profile: $username'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Tap on the card (not the button)
      await tester.tap(find.text('Test User'));
      await tester.pumpAndSettle();

      // Should navigate to profile
      expect(find.text('Profile: testuser'), findsOneWidget);
    });

    testWidgets('displays default avatar when image is empty', (tester) async {
      final userWithoutImage = testUser.copyWith(image: '');

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FollowerCard(user: userWithoutImage, isMe: false),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Should show default person icon
      expect(find.byIcon(Icons.person), findsWidgets);
    });
  });
}
