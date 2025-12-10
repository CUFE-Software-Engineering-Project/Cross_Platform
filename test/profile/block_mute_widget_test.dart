import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile/block_button.dart';
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

    isVerified: false,
    isFollowing: false,
    isFollower: false,
    isBlockedByMe: true,
    isMutedByMe: false,
    followersCount: 100,
    followingCount: 50,
    tweetsCount: 10,
    postCount: 10,
    joinedDate: '2020-01-01',
    protectedAccount: false,
    avatarId: '',
  );

  group('Block Button Widget Tests', () {
    testWidgets('displays "Blocked" when user is blocked', (tester) async {
      bool showDataCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BlockButton(
                profileData: testProfile,
                showDataFunc: () {
                  showDataCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Blocked'), findsOneWidget);
    });

    testWidgets('unblock shows confirmation dialog', (tester) async {
      bool showDataCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BlockButton(
                profileData: testProfile,
                showDataFunc: () {
                  showDataCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap blocked button
      await tester.tap(find.text('Blocked'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Unblock @testuser?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('UnBlock'), findsOneWidget);
    });

    testWidgets('unblock dialog cancel does not call unblock', (tester) async {
      bool showDataCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BlockButton(
                profileData: testProfile,
                showDataFunc: () {
                  showDataCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap blocked button
      await tester.tap(find.text('Blocked'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should not call unblock
      verifyNever(mockRepo.unBlockUser(any));
      expect(showDataCalled, isFalse);
    });

    testWidgets('unblock success refreshes profile data', (tester) async {
      bool showDataCalled = false;
      when(mockRepo.unBlockUser('testuser'))
          .thenAnswer((_) async => const Right(()));
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile.copyWith(isBlockedByMe: false)));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BlockButton(
                profileData: testProfile,
                showDataFunc: () {
                  showDataCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap blocked button
      await tester.tap(find.text('Blocked'));
      await tester.pumpAndSettle();

      // Confirm unblock
      await tester.tap(find.text('UnBlock'));
      await tester.pumpAndSettle();

      // Should call unblock and refresh
      verify(mockRepo.unBlockUser('testuser')).called(1);
      expect(showDataCalled, isTrue);
    });

    testWidgets('unblock failure shows error message', (tester) async {
      bool showDataCalled = false;
      when(mockRepo.unBlockUser('testuser'))
          .thenAnswer((_) async => Left(Failure("Failed to unblock user")));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BlockButton(
                profileData: testProfile,
                showDataFunc: () {
                  showDataCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap blocked button
      await tester.tap(find.text('Blocked'));
      await tester.pumpAndSettle();

      // Confirm unblock
      await tester.tap(find.text('UnBlock'));
      await tester.pumpAndSettle();

      // Should show error (check for error icon or message)
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(showDataCalled, isFalse);

      verify(mockRepo.unBlockUser('testuser')).called(1);
    });

    testWidgets('button has red styling for blocked state', (tester) async {
      bool showDataCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BlockButton(
                profileData: testProfile,
                showDataFunc: () {
                  showDataCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Find button and check styling
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style!;

      // Should have red foreground color
      expect(style.foregroundColor?.resolve({}), Colors.red);
    });
  });

  group('Mute/Unmute Provider Tests', () {
    testWidgets('mute user calls repo and returns Right', (tester) async {
      when(mockRepo.muteUser('testuser'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final mute = ref.read(muteUserProvider);
                      await mute('testuser');
                    },
                    child: Text('Mute'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mute'));
      await tester.pumpAndSettle();

      verify(mockRepo.muteUser('testuser')).called(1);
    });

    testWidgets('unmute user calls repo and returns Right', (tester) async {
      when(mockRepo.unMuteUser('testuser'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final unmute = ref.read(unMuteUserProvider);
                      await unmute('testuser');
                    },
                    child: Text('Unmute'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Unmute'));
      await tester.pumpAndSettle();

      verify(mockRepo.unMuteUser('testuser')).called(1);
    });

    testWidgets('mute returns Left on failure', (tester) async {
      when(mockRepo.muteUser('testuser'))
          .thenAnswer((_) async => Left(Failure("Failed to mute")));

      String? errorMessage;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final mute = ref.read(muteUserProvider);
                      final result = await mute('testuser');
                      result.fold(
                        (fail) => errorMessage = fail.message,
                        (r) => errorMessage = null,
                      );
                    },
                    child: Text('Mute'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mute'));
      await tester.pumpAndSettle();

      expect(errorMessage, 'Failed to mute');
      verify(mockRepo.muteUser('testuser')).called(1);
    });
  });

  group('Block User Provider Tests', () {
    testWidgets('block user calls repo and returns Right', (tester) async {
      when(mockRepo.blockUser('testuser'))
          .thenAnswer((_) async => const Right(()));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final block = ref.read(blockUserProvider);
                      await block('testuser');
                    },
                    child: Text('Block'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();

      verify(mockRepo.blockUser('testuser')).called(1);
    });

    testWidgets('block returns Left on failure', (tester) async {
      when(mockRepo.blockUser('testuser'))
          .thenAnswer((_) async => Left(Failure("Failed to block")));

      String? errorMessage;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      final block = ref.read(blockUserProvider);
                      final result = await block('testuser');
                      result.fold(
                        (fail) => errorMessage = fail.message,
                        (r) => errorMessage = null,
                      );
                    },
                    child: Text('Block'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();

      expect(errorMessage, 'Failed to block');
      verify(mockRepo.blockUser('testuser')).called(1);
    });
  });
}
