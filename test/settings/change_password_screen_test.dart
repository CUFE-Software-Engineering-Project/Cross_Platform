import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/settings/screens/ChangePassword_Screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'change_password_screen_test.mocks.dart';

// Simple observer counting pushes to assert navigation without stubs.
class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  @override
  void didPush(Route route, Route? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

@GenerateNiceMocks([
  MockSpec<ProfileRepo>(),
])
class TestAuthViewModel extends AuthViewModel {
  int logoutCalls = 0;
  @override
  AuthState build() => AuthState.authenticated();
  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, String>>(const Left(Failure('dummy')));
    provideDummy<Either<Failure, void>>(const Left(Failure('dummy')));
  });

  group('ChangePasswordScreen', () {
    late MockProfileRepo mockProfileRepo;
    late TestAuthViewModel testAuthViewModel;
    late _TestNavigatorObserver testNavigatorObserver;

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
      mockProfileRepo = MockProfileRepo();
      testAuthViewModel = TestAuthViewModel();
      testNavigatorObserver = _TestNavigatorObserver();
    });

    Future<void> pumpTheWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepoProvider.overrideWithValue(mockProfileRepo),
            authViewModelProvider.overrideWith(() => testAuthViewModel),
            currentUserProvider.overrideWithValue(mockCoreUser),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/change_password',
              observers: [testNavigatorObserver],
              routes: [
                GoRoute(
                  path: '/change_password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: RouteConstants.introscreen,
                  name: RouteConstants.introscreen,
                  builder: (context, state) =>
                      const Scaffold(body: Text('Intro Screen')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('shows validation errors for empty fields', (tester) async {
      await pumpTheWidget(tester);
      await tester.tap(find.text('Update password'));
      await tester.pump();

      expect(find.text('Enter current password'), findsOneWidget);
      expect(find.text('Enter new password'), findsOneWidget);
      expect(find.text('Confirm your new password'), findsOneWidget);
    });

    testWidgets('shows validation error for mismatched passwords',
        (tester) async {
      await pumpTheWidget(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'oldPassword');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'newPassword123');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'newPassword456');
      await tester.tap(find.text('Update password'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets(
        'shows loading indicator and handles successful password change',
        (tester) async {
      when(mockProfileRepo.changePasswordProfile(
        any,
        any,
        any,
      )).thenAnswer((_) async => const Right(null));

      // logout is counted in TestAuthViewModel; no stubbing needed.

      await pumpTheWidget(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'oldPassword');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'newPassword123');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'newPassword123');

      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      verify(mockProfileRepo.changePasswordProfile(
        'oldPassword',
        'newPassword123',
        'newPassword123',
      )).called(1);

      expect(find.text('Password changed successfully'), findsOneWidget);

      expect(testAuthViewModel.logoutCalls, 1);

      expect(testNavigatorObserver.pushCount, greaterThan(0));
    });

    testWidgets('handles failed password change', (tester) async {
      when(mockProfileRepo.changePasswordProfile(
        any,
        any,
        any,
      )).thenAnswer((_) async => const Left(Failure('Wrong password')));

      await pumpTheWidget(tester);
      await tester.enterText(
          find.byType(TextFormField).at(0), 'wrongOldPassword');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'newPassword123');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'newPassword123');

      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      verify(mockProfileRepo.changePasswordProfile(
        'wrongOldPassword',
        'newPassword123',
        'newPassword123',
      )).called(1);

      expect(testAuthViewModel.logoutCalls, 0);
      expect(find.text('Intro Screen'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Wrong password'), findsOneWidget);
    });
  });
}
