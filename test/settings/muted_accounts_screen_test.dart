import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/screens/MutedAccounts_Screen.dart';
import 'package:lite_x/features/settings/view_model/providers.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'settings_mocks.mocks.dart';

void main() {
  group('MutedAccountsScreen', () {
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

    final mutedUser = UserModel(
      userName: 'muteduser',
      displayName: 'Muted User',
      bio: 'Bio of muted user',
      image: 'http://example.com/muted.jpg',
      isFollowing: false,
    );

    Future<void> pumpTheWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepoProvider.overrideWithValue(mockSettingsRepo),
            currentUserProvider.overrideWithValue(mockCoreUser),
          ],
          child: const MaterialApp(home: MutedAccountsScreen()),
        ),
      );
    }

    testWidgets('shows loading indicator, then error message when fetching fails', (tester) async {
      when(mockSettingsRepo.getMutedAccounts(any)).thenAnswer((_) async => Left(Failure('Failed to fetch')));

      await pumpTheWidget(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Failed to fetch'), findsOneWidget);
    });

    testWidgets('shows loading indicator, then list of muted accounts', (tester) async {
      mockNetworkImagesFor(() async {
        when(mockSettingsRepo.getMutedAccounts(any)).thenAnswer((_) async => Right([mutedUser]));

        await pumpTheWidget(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();

        expect(find.text('Muted User'), findsOneWidget);
        expect(find.text('@muteduser'), findsOneWidget);
        expect(find.byIcon(Icons.volume_off), findsOneWidget);
        expect(find.text('Follow'), findsOneWidget);
      });
    });

    testWidgets('shows loading indicator, then empty message', (tester) async {
      when(mockSettingsRepo.getMutedAccounts(any)).thenAnswer((_) async => const Right([]));

      await pumpTheWidget(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('No muted accounts'), findsOneWidget);
    });

    testWidgets('unmutes a user when icon is tapped', (tester) async {
      mockNetworkImagesFor(() async {
        // Initial fetch
        when(mockSettingsRepo.getMutedAccounts('testuser')).thenAnswer((_) async => Right([mutedUser]));

        await pumpTheWidget(tester);
        await tester.pumpAndSettle();
        expect(find.text('Muted User'), findsOneWidget);

        // Re-stub for refresh
        when(mockSettingsRepo.getMutedAccounts('testuser')).thenAnswer((_) async => const Right([]));
        when(mockSettingsRepo.unMuteAccount('muteduser')).thenAnswer((_) async => const Right(null));

        await tester.tap(find.byIcon(Icons.volume_off));
        await tester.pumpAndSettle();

        verify(mockSettingsRepo.unMuteAccount('muteduser')).called(1);
        expect(find.text('No muted accounts'), findsOneWidget);
      });
    });

    testWidgets('follows a user when "Follow" button is tapped', (tester) async {
      mockNetworkImagesFor(() async {
        final updatedUser = mutedUser.copyWith(isFollowing: true);

        // Initial fetch
        when(mockSettingsRepo.getMutedAccounts('testuser')).thenAnswer((_) async => Right([mutedUser]));
        
        await pumpTheWidget(tester);
        await tester.pumpAndSettle();
        expect(find.text('Follow'), findsOneWidget);

        // Re-stub for refresh
        when(mockSettingsRepo.getMutedAccounts('testuser')).thenAnswer((_) async => Right([updatedUser]));
        when(mockSettingsRepo.followUser('muteduser')).thenAnswer((_) async => const Right(null));

        await tester.tap(find.text('Follow'));
        await tester.pumpAndSettle();

        verify(mockSettingsRepo.followUser('muteduser')).called(1);
        expect(find.text('UnFollow'), findsOneWidget);
      });
    });
  });
}
