import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/screens/edit_profile_screen.dart';
import 'package:lite_x/features/profile/view/screens/following_followers_screen.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
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

  group('EditProfileScreen Widget Tests', () {
    testWidgets('EditProfileScreen displays profile form', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: EditProfileScreen(profileData: testProfile),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify screen structure
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('EditProfileScreen has save button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: EditProfileScreen(profileData: testProfile),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for save button or text - at least one should exist
      final hasSaveButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(TextButton),
      ).evaluate().isNotEmpty;
      final hasSaveText = find.text('Save').evaluate().isNotEmpty;
      expect(hasSaveButton || hasSaveText, isTrue);
    });
  });

  group('FollowingFollowersScreen Widget Tests', () {
    testWidgets('FollowingFollowersScreen displays tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: FollowingFollowersScreen(
              isMe: 'me',
              profileModel: testProfile,
              initialIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify screen exists
      expect(find.byType(FollowingFollowersScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('FollowingFollowersScreen displays user name in AppBar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: FollowingFollowersScreen(
              isMe: 'me',
              profileModel: testProfile,
              initialIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify display name appears in AppBar
      expect(find.text(testProfile.displayName), findsOneWidget);
    });

    testWidgets('FollowingFollowersScreen back button pops navigation', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FollowingFollowersScreen(
                            isMe: 'me',
                            profileModel: testProfile,
                            initialIndex: 0,
                          ),
                        ),
                      ).then((_) => popped = true);
                    },
                    child: Text('Navigate'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Navigate to FollowingFollowersScreen
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('FollowingFollowersScreen shows correct number of tabs for own profile', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: FollowingFollowersScreen(
              isMe: 'me', // User's own profile
              profileModel: testProfile,
              initialIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // For own profile, should have 6 tabs
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, equals(6));
    });

    testWidgets('FollowingFollowersScreen shows correct number of tabs for other profile', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: FollowingFollowersScreen(
              isMe: 'notme', // Someone else's profile
              profileModel: testProfile,
              initialIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // For other's profile, should have 4 tabs
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, equals(4));
    });

    testWidgets('FollowingFollowersScreen respects initial index', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: FollowingFollowersScreen(
              isMe: 'me',
              profileModel: testProfile,
              initialIndex: 1, // Start at second tab
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the initial tab index is set to 1
      final tabController = DefaultTabController.of(
        tester.element(find.byType(TabBarView)),
      );
      expect(tabController.index, equals(1));
    });
  });

  group('Profile Screen Integration Tests', () {
    testWidgets('EditProfileScreen form validation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: EditProfileScreen(profileData: testProfile),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify form exists
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('Profile screens can be dismissed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                profileData: testProfile,
                              ),
                            ),
                          );
                        },
                        child: Text('Open Edit'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FollowingFollowersScreen(
                                isMe: 'me',
                                profileModel: testProfile,
                              ),
                            ),
                          );
                        },
                        child: Text('Open Following'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Test EditProfileScreen navigation
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
      
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsNothing);

      // Test FollowingFollowersScreen navigation
      await tester.tap(find.text('Open Following'));
      await tester.pumpAndSettle();
      expect(find.byType(FollowingFollowersScreen), findsOneWidget);
      
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(FollowingFollowersScreen), findsNothing);
    });
  });
}
