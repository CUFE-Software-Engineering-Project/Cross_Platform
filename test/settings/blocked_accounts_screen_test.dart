import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/screens/BlockedAccounts_Screen.dart';
import 'package:lite_x/features/settings/view_model/providers.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'settings_mocks.mocks.dart';

void main() {
  group('BlockedAccountsScreen', () {
    late MockSettingsRepo mockSettingsRepo;
    final mockCoreUser = core_user.UserModel(
      id: 'mock_id',
      name: 'Mock User',
      email: 'mock@test.com',
      dob: '2000-01-01',
      username: 'testuser',
      isEmailVerified: true,
      isVerified: false,
    );

    setUp(() {
      mockSettingsRepo = MockSettingsRepo();
    });

    final user1 = UserModel(
      userName: 'user1',
      displayName: 'User One',
      bio: 'Bio of user one',
      image: 'http://example.com/user1.jpg',
      isVerified: true,
    );

    final user2 = UserModel(
      userName: 'user2',
      displayName: 'User Two',
      bio: 'Bio of user two',
      image: 'http://example.com/user2.jpg',
      isVerified: false,
    );

    Future<void> pumpTheWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepoProvider.overrideWithValue(mockSettingsRepo),
            currentUserProvider.overrideWithValue(mockCoreUser),
          ],
          child: const MaterialApp(home: BlockedAccountsScreen()),
        ),
      );
    }

    testWidgets('shows loading indicator, then error message when fetching fails', (tester) async {
      when(mockSettingsRepo.getBlockedAccounts(any)).thenAnswer((_) async => Left(Failure('Failed to fetch')));

      await pumpTheWidget(tester);

      // Initially, it should be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After the future completes
      await tester.pumpAndSettle();

      expect(find.text('Failed to fetch'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator, then list of blocked accounts', (tester) async {
      mockNetworkImagesFor(() async {
        when(mockSettingsRepo.getBlockedAccounts(any)).thenAnswer((_) async => Right([user1, user2]));

        await pumpTheWidget(tester);

        // Loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Data state
        await tester.pumpAndSettle();

        expect(find.text('User One'), findsOneWidget);
        expect(find.text('@user1'), findsOneWidget);
        expect(find.text('User Two'), findsOneWidget);
        expect(find.text('@user2'), findsOneWidget);
        expect(find.text('Blocked'), findsNWidgets(2));
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    testWidgets('shows loading indicator, then empty message', (tester) async {
      when(mockSettingsRepo.getBlockedAccounts(any)).thenAnswer((_) async => const Right([]));

      await pumpTheWidget(tester);

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Empty state
      await tester.pumpAndSettle();

      expect(find.text('No blocked accounts'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('unblocks a user when "Blocked" button is tapped', (tester) async {
      mockNetworkImagesFor(() async {
        // Setup for the initial fetch
        when(mockSettingsRepo.getBlockedAccounts('testuser')).thenAnswer((_) async => Right([user1]));

        await pumpTheWidget(tester);
        await tester.pumpAndSettle();

        // Ensure the user is there initially
        expect(find.text('User One'), findsOneWidget);
        expect(find.text('Blocked'), findsOneWidget);

        // Re-stub for the refresh call that will happen after unblocking
        when(mockSettingsRepo.getBlockedAccounts('testuser')).thenAnswer((_) async => const Right([]));
        when(mockSettingsRepo.unblockAccount('user1')).thenAnswer((_) async => const Right(null));

        // Tap the button to unblock
        await tester.tap(find.text('Blocked'));
        await tester.pumpAndSettle(); // Let the unblock and refresh futures complete

        // Verify the unblock method was called
        verify(mockSettingsRepo.unblockAccount('user1')).called(1);

        // Verify the list is now empty
        expect(find.text('No blocked accounts'), findsOneWidget);
        expect(find.text('User One'), findsNothing);
      });
    });
  });
}
