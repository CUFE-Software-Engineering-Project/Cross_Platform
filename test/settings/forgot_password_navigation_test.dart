import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/settings/screens/ChangePassword_Screen.dart';

// Simple observer counting pushes to assert navigation without stubs.
class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  @override
  void didPush(Route route, Route? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

void main() {
  group('ChangePasswordScreen navigation', () {
    final mockCoreUser = core_user.UserModel(
      id: 'mock_id',
      name: 'Mock User',
      email: 'mock@test.com',
      dob: '2000-01-01',
      username: 'testuser',
      isEmailVerified: true,
      isVerified: false,
    );

    testWidgets('navigates to Forgot password screen when button tapped', (tester) async {
      final testObserver = _TestNavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockCoreUser),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/change_password',
              observers: [testObserver],
              routes: [
                GoRoute(
                  path: '/change_password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: '/forgotpassword',
                  name: RouteConstants.ForgotpasswordScreen,
                  builder: (context, state) => const Scaffold(body: Text('Forgot Password Screen')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Forgot password?'), findsOneWidget);

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password Screen'), findsOneWidget);
      expect(testObserver.pushCount, greaterThan(0));
    });
  });
}
