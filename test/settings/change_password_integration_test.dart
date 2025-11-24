import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/settings/screens/ChangePassword_Screen.dart';

// Simple observer to assert navigation pushes occurred.
class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  @override
  void didPush(Route route, Route? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

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
  group('Integration: change password → logout → intro', () {
    final mockCoreUser = core_user.UserModel(
      id: 'mock_id',
      name: 'Mock User',
      email: 'mock@test.com',
      dob: '2000-01-01',
      username: 'testuser',
      isEmailVerified: true,
      isVerified: false,
    );

    testWidgets('successful change password logs out and navigates to intro',
        (tester) async {
      final testAuth = TestAuthViewModel();
      final navObserver = _TestNavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockCoreUser),
            changePasswordProfileProvider.overrideWithValue(({
              required String oldPassword,
              required String newPassword,
              required String confirmNewPassword,
            }) async {
              return const Right(null);
            }),
            authViewModelProvider.overrideWith(() => testAuth),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/change_password',
              observers: [navObserver],
              routes: [
                GoRoute(
                  path: '/change_password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: RouteConstants.introscreen,
                  name: RouteConstants.introscreen,
                  builder: (context, state) => const Scaffold(body: Text('Intro Screen')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill fields
      await tester.enterText(find.byType(TextFormField).at(0), 'oldPassword');
      await tester.enterText(find.byType(TextFormField).at(1), 'newPassword123');
      await tester.enterText(find.byType(TextFormField).at(2), 'newPassword123');

      // Submit
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      // Assert logout called and that navigation occurred (push happened)
      expect(testAuth.logoutCalls, 1);
      expect(navObserver.pushCount, greaterThan(0));
    });
  });
}
