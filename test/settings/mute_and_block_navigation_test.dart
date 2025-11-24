import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/settings/screens/MuteAndBlock_Screen.dart';

void main() {
  group('MuteAndBlockScreen navigation', () {
    final mockCoreUser = core_user.UserModel(
      id: 'mock_id',
      name: 'Mock User',
      email: 'mock@test.com',
      dob: '2000-01-01',
      username: 'testuser',
      isEmailVerified: true,
      isVerified: false,
    );

    testWidgets('navigates to Blocked and Muted accounts when list tiles tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockCoreUser),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/mute_and_block',
              routes: [
                GoRoute(
                  path: '/mute_and_block',
                  builder: (context, state) => const MuteAndBlockScreen(),
                ),
                GoRoute(
                  path: '/blocked',
                  name: RouteConstants.blockedaccountsscreen,
                  builder: (context, state) => const Scaffold(body: Text('Blocked Accounts Route')),
                ),
                GoRoute(
                  path: '/muted',
                  name: RouteConstants.mutedaccountsscreen,
                  builder: (context, state) => const Scaffold(body: Text('Muted Accounts Route')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Blocked accounts
      expect(find.text('Blocked accounts'), findsOneWidget);
      await tester.tap(find.text('Blocked accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Blocked Accounts Route'), findsOneWidget);

      // Rebuild the widget to go back to MuteAndBlockScreen and test Muted accounts
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(mockCoreUser),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/mute_and_block',
              routes: [
                GoRoute(
                  path: '/mute_and_block',
                  builder: (context, state) => const MuteAndBlockScreen(),
                ),
                GoRoute(
                  path: '/blocked',
                  name: RouteConstants.blockedaccountsscreen,
                  builder: (context, state) => const Scaffold(body: Text('Blocked Accounts Route')),
                ),
                GoRoute(
                  path: '/muted',
                  name: RouteConstants.mutedaccountsscreen,
                  builder: (context, state) => const Scaffold(body: Text('Muted Accounts Route')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Muted accounts
      expect(find.text('Muted accounts'), findsOneWidget);
      await tester.tap(find.text('Muted accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Muted Accounts Route'), findsOneWidget);
    });
  });
}
