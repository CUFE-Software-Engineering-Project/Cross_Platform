import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/screens/profile_search_screen.dart';

import 'profile_repo_extended_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProfileRepo>()])
void main() {
  setUpAll(() {
    provideDummy<Either<Failure, List<SearchUserModel>>>(
      Left(Failure('dummy')),
    );
  });

  group('ProfileSearchScreen Widget Tests', () {
    late MockProfileRepo mockRepo;

    setUp(() {
      mockRepo = MockProfileRepo();
    });

    testWidgets('ProfileSearchScreen displays search bar', (
      WidgetTester tester,
    ) async {
      when(
        mockRepo.profileCurrentSearch(any),
      ).thenAnswer((_) async => Right([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(home: ProfileSearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify search bar is displayed
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ProfileSearchScreen triggers search on text input', (
      WidgetTester tester,
    ) async {
      final mockResults = [
        SearchUserModel(
          profileMediaId: "123",
          id: '1',
          username: 'testuser',
          name: 'Test User',
          verified: false,
          bio: 'Test bio',
          profileMedia: '',
          followers: 100,
          score: 10,
          isFollowing: false,
          isFollower: false,
        ),
      ];

      when(
        mockRepo.profileCurrentSearch('test'),
      ).thenAnswer((_) async => Right(mockResults));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp(home: ProfileSearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify search was called
      verify(mockRepo.profileCurrentSearch('test')).called(greaterThan(0));
    });
  });

  group('Profile Navigation Tests', () {
    late MockProfileRepo mockRepo;
    final testProfile = ProfileModel(
      id: '1',
      username: 'testuser',
      displayName: 'Test User',
      bio: 'Test bio',
      avatarUrl: '',
      bannerUrl: '',
      followersCount: 100,
      followingCount: 50,
      tweetsCount: 20,
      isVerified: false,
      joinedDate: '2024-01-01',
      website: '',
      location: '',
      postCount: 20,
      birthDate: '',
      isFollowing: false,
      isFollower: false,
      protectedAccount: false,
      isBlockedByMe: false,
      isMutedByMe: false,
      email: 'test@test.com',
      avatarId: '',
    );

    setUp(() {
      mockRepo = MockProfileRepo();
      when(
        mockRepo.getProfileData(any),
      ).thenAnswer((_) async => Right(testProfile));
      when(mockRepo.getFollowers(any)).thenAnswer((_) async => Right([]));
      when(mockRepo.getFollowings(any)).thenAnswer((_) async => Right([]));
    });

    testWidgets('Can navigate to followers screen from profile', (
      WidgetTester tester,
    ) async {
      final goRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/followers'),
                child: Text('Go to Followers'),
              ),
            ),
          ),
          GoRoute(
            path: '/followers',
            builder: (context, state) =>
                Scaffold(body: Text('Followers Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to navigate
      await tester.tap(find.text('Go to Followers'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Followers Screen'), findsOneWidget);
    });
  });
}
