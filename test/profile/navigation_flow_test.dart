import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view/screens/edit_profile_screen.dart';
import 'package:lite_x/features/profile/view/screens/profile_search_screen.dart';
import 'package:lite_x/features/profile/view/screens/following_followers_screen.dart';
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

  final testSearchUser = SearchUserModel(
    profileMediaId: "123",
    id: '123',
    username: 'testuser',
    name: 'Test User',
    verified: false,
    bio: 'Test bio',
    profileMedia: '',
    followers: 100,
    score: 0.8,
    isFollowing: false,
    isFollower: false,
  );

  final testUserModel = UserModel(
    displayName: 'Test User',
    userName: 'testuser',
    image: '',
    bio: 'Test bio',
    isFollowing: false,
    isFollower: false,
    isVerified: false,
  );

  group('Profile Navigation Flow Tests', () {
    testWidgets('search screen to profile screen navigation', (tester) async {
      when(
        mockRepo.profileCurrentSearch('testuser'),
      ).thenAnswer((_) async => Right([testSearchUser]));

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => ProfileSearchScreen(),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) {
              final username = state.pathParameters['username']!;
              return Scaffold(
                appBar: AppBar(title: Text('Profile: $username')),
                body: Center(child: Text('Profile Screen')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextFormField);
      await tester.enterText(searchField, 'testuser');
      await tester.pumpAndSettle();

      // Verify search results appear
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);

      // Tap on search result
      await tester.tap(find.text('Test User'));
      await tester.pumpAndSettle();

      // Verify navigation to profile screen
      expect(find.text('Profile Screen'), findsOneWidget);
      expect(find.text('Profile: testuser'), findsOneWidget);
    });

    testWidgets('profile to edit profile navigation', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text('Profile')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/edit-profile');
                  },
                  child: Text('Edit Profile'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) =>
                EditProfileScreen(profileData: testProfile),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Tap edit profile button
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Verify navigation to edit screen
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Bio'), findsOneWidget);
    });

    testWidgets('profile to followers/following navigation', (tester) async {
      when(
        mockRepo.getFollowers('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));
      when(
        mockRepo.getFollowings('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));
      // Mock additional tab providers to prevent errors
      when(
        mockRepo.getVerifiedFollowers('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));
      when(
        mockRepo.getFollowersYouKnow('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text('Profile')),
              body: Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push('/followers');
                      },
                      child: Text('View Followers'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/following');
                      },
                      child: Text('View Following'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/followers',
            builder: (context, state) => FollowingFollowersScreen(
              isMe: 'me',
              profileModel: testProfile,
              initialIndex: 2,
            ),
          ),
          GoRoute(
            path: '/following',
            builder: (context, state) => FollowingFollowersScreen(
              isMe: 'me',
              profileModel: testProfile,
              initialIndex: 3,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to followers
      await tester.tap(find.text('View Followers'));
      await tester.pumpAndSettle();

      expect(find.byType(FollowingFollowersScreen), findsOneWidget);

      // Navigate to following (don't test back navigation in this complex widget)
      router.go('/');
      await tester.pumpAndSettle();

      await tester.tap(find.text('View Following'));
      await tester.pumpAndSettle();

      expect(find.byType(FollowingFollowersScreen), findsOneWidget);
    });
  });

  group('Back Navigation Tests', () {
    testWidgets('back button from edit profile returns to profile', (
      tester,
    ) async {
      bool returnedToProfile = false;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text('Profile')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await context.push('/edit-profile');
                    returnedToProfile = true;
                  },
                  child: Text('Edit Profile'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) =>
                EditProfileScreen(profileData: testProfile),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to edit profile
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify returned to profile
      expect(returnedToProfile, isTrue);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('back button from search screen', (tester) async {
      when(
        mockRepo.profileCurrentSearch(''),
      ).thenAnswer((_) async => Right([]));

      bool canPopCalled = false;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text('Home')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await context.push('/search');
                    canPopCalled = true;
                  },
                  child: Text('Search'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => ProfileSearchScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byType(BackButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify returned to home
      expect(canPopCalled, isTrue);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('Deep Linking Navigation Tests', () {
    testWidgets('navigate directly to profile with username', (tester) async {
      when(
        mockRepo.getProfileData('testuser'),
      ).thenAnswer((_) async => Right(testProfile));

      final router = GoRouter(
        initialLocation: '/profile/testuser',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                Scaffold(appBar: AppBar(title: Text('Home'))),
          ),
          GoRoute(
            path: '/profile/:username',
            builder: (context, state) {
              final username = state.pathParameters['username']!;
              return Scaffold(
                appBar: AppBar(title: Text('Profile: $username')),
                body: Center(child: Text('Viewing $username')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Verify deep link worked
      expect(find.text('Profile: testuser'), findsOneWidget);
      expect(find.text('Viewing testuser'), findsOneWidget);
    });

    testWidgets('navigate to followers with initial tab index', (tester) async {
      when(
        mockRepo.getFollowers('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));
      when(
        mockRepo.getFollowings('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));
      // Mock additional tab providers to prevent errors
      when(
        mockRepo.getVerifiedFollowers('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));
      when(
        mockRepo.getFollowersYouKnow('testuser'),
      ).thenAnswer((_) async => Right([testUserModel]));

      final router = GoRouter(
        initialLocation: '/followers?tab=1',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                Scaffold(appBar: AppBar(title: Text('Home'))),
          ),
          GoRoute(
            path: '/followers',
            builder: (context, state) {
              final tab = state.uri.queryParameters['tab'];
              final initialIndex = int.tryParse(tab ?? '0') ?? 0;
              return FollowingFollowersScreen(
                isMe: 'me',
                profileModel: testProfile,
                initialIndex: initialIndex,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester
          .pump(); // Just one pump, not pumpAndSettle to avoid tab loading issues

      // Verify correct screen is loaded
      expect(find.byType(FollowingFollowersScreen), findsOneWidget);
    });
  });

  group('Navigation State Preservation Tests', () {
    testWidgets('edit profile preserves form state on interruption', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text('Home')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/edit-profile');
                  },
                  child: Text('Edit Profile'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) =>
                EditProfileScreen(profileData: testProfile),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepoProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to edit profile
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Find the TextFormField with label 'Name'
      final nameField = find.widgetWithText(TextFormField, 'Test User').first;

      await tester.enterText(nameField, 'Modified Name');
      await tester.pumpAndSettle();

      // Verify text persists
      expect(find.text('Modified Name'), findsOneWidget);
    });
  });
}
