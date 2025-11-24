import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/settings/screens/YourAccount_Screen.dart';
import 'package:mockito/mockito.dart';

import 'navigator_observer_mocks.mocks.dart';

void main() {
  group('YourAccountScreen Widget Tests', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/your_account',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/your_account',
            name: 'your_account',
            builder: (context, state) => const YourAccountScreen(),
          ),
          GoRoute(
            path: '/account_information',
            name: RouteConstants.accountinformationscreen,
            builder: (context, state) => const Scaffold(body: Text('Account Information Screen')),
          ),
          GoRoute(
            path: '/change_password',
            name: RouteConstants.changePasswordScreen,
            builder: (context, state) => const Scaffold(body: Text('Change Password Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders account information list items', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Account information'), findsOneWidget);
      expect(find.text('Change your password'), findsOneWidget);
      expect(find.text('Download an archive of your data'), findsOneWidget);
      expect(find.text('Deactivate Account'), findsOneWidget);
    });

    testWidgets('navigates to Account Information screen on tap', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Account information'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Account Information Screen'), findsOneWidget);
    });

    testWidgets('navigates to Change Password screen on tap', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Change your password'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Change Password Screen'), findsOneWidget);
    });
  });
}
