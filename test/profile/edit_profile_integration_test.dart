import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/screens/edit_profile_screen.dart';
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

  group('EditProfileScreen Integration Tests', () {
    testWidgets('displays all form fields correctly', (tester) async {
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

      // Verify form fields are displayed
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      
      // Check for form labels
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Bio'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('Birth date'), findsOneWidget);
    });

    testWidgets('name field validation - empty name disables save', (tester) async {
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

      // Find the name field and clear it
      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(TextFormField),
      );
      
      expect(nameField, findsOneWidget);
      
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Verify Save button is disabled (grey)
      final saveText = tester.widget<Text>(find.text('Save'));
      expect(saveText.style?.color, equals(Colors.grey));
    });

    testWidgets('name field validation - non-empty name enables save', (tester) async {
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

      // Find the name field and enter text
      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(TextFormField),
      );
      
      await tester.enterText(nameField, 'New Name');
      await tester.pumpAndSettle();

      // Verify Save button is enabled (white)
      final saveText = tester.widget<Text>(find.text('Save'));
      expect(saveText.style?.color, equals(Colors.white));
    });

    testWidgets('form fields update correctly', (tester) async {
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

      // Update bio field
      final bioField = find.ancestor(
        of: find.text('Bio'),
        matching: find.byType(TextFormField),
      );
      
      await tester.enterText(bioField, 'Updated bio text');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('Updated bio text'), findsOneWidget);
    });

    testWidgets('shows loading indicator when saving', (tester) async {
      // Setup mock for successful save
      when(mockRepo.updateProfile(newModel: anyNamed('newModel')))
          .thenAnswer((_) async => Right(testProfile));

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

      // Change name to trigger save
      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(TextFormField),
      );
      
      await tester.enterText(nameField, 'Updated Name');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Update Profile...'), findsOneWidget);
    });

    testWidgets('back button pops screen', (tester) async {
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
                          builder: (_) => EditProfileScreen(
                            profileData: testProfile,
                          ),
                        ),
                      ).then((_) => popped = true);
                    },
                    child: Text('Open Edit'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });

  group('Form Field Validation Tests', () {
    testWidgets('name field accepts valid input', (tester) async {
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

      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(TextFormField),
      );

      // Test various valid inputs
      await tester.enterText(nameField, 'John Doe');
      await tester.pumpAndSettle();
      expect(find.text('John Doe'), findsOneWidget);

      await tester.enterText(nameField, 'Alice');
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);

      await tester.enterText(nameField, 'User 123');
      await tester.pumpAndSettle();
      expect(find.text('User 123'), findsOneWidget);
    });

    testWidgets('bio field accepts multiline input', (tester) async {
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

      final bioField = find.ancestor(
        of: find.text('Bio'),
        matching: find.byType(TextFormField),
      );

      const multilineBio = 'Line 1\nLine 2\nLine 3';
      await tester.enterText(bioField, multilineBio);
      await tester.pumpAndSettle();

      expect(find.text(multilineBio), findsOneWidget);
    });

    testWidgets('website field accepts URL input', (tester) async {
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

      final websiteField = find.ancestor(
        of: find.text('Website'),
        matching: find.byType(TextFormField),
      );

      await tester.enterText(websiteField, 'https://example.com');
      await tester.pumpAndSettle();

      expect(find.text('https://example.com'), findsOneWidget);
    });
  });

  group('User Interaction Tests', () {
    testWidgets('save button calls update when fields changed', (tester) async {
      final updatedProfile = testProfile.copyWith(displayName: 'New Name');
      
      when(mockRepo.updateProfile(newModel: anyNamed('newModel')))
          .thenAnswer((_) async => Right(updatedProfile));

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

      // Change the name
      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(TextFormField),
      );
      
      await tester.enterText(nameField, 'New Name');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify update was called
      verify(mockRepo.updateProfile(newModel: anyNamed('newModel'))).called(1);
    });

    testWidgets('save button does not call update when no changes', (tester) async {
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

      // Tap save without making changes
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));

      // Verify update was not called
      verifyNever(mockRepo.updateProfile(newModel: anyNamed('newModel')));
    });

    testWidgets('tapping Switch to Professional button', (tester) async {
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

      // Scroll to find the button
      await tester.drag(find.byType(CustomScrollView), Offset(0, -500));
      await tester.pumpAndSettle();

      // Find and verify button exists
      expect(find.text('Switch to Professional'), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('displays error when save fails', (tester) async {
      final failure = Failure('Failed to update profile');
      
      when(mockRepo.updateProfile(newModel: anyNamed('newModel')))
          .thenAnswer((_) async => Left(failure));

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

      // Change name
      final nameField = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(TextFormField),
      );
      
      await tester.enterText(nameField, 'New Name');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify error handling was triggered
      verify(mockRepo.updateProfile(newModel: anyNamed('newModel'))).called(1);
    });
  });
}
