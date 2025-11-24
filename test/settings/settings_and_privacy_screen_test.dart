import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/settings/screens/SettingsAndPrivacy_Screen.dart';
import 'package:mockito/mockito.dart';

import 'navigator_observer_mocks.mocks.dart';

void main() {
  group('SettingsAndPrivacyScreen Widget Tests', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    // Helper function to pump the screen with necessary wrappers
    Future<void> pumpScreen(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SettingsAndPrivacyScreen(),
          ),
          GoRoute(
            name: RouteConstants.youraccountscreen,
            path: '/youraccount',
            builder: (context, state) => const Scaffold(body: Text('Your Account Screen')),
          ),
          GoRoute(
            name: RouteConstants.privacyandsafetyscreen,
            path: '/privacyandsafety',
            builder: (context, state) => const Scaffold(body: Text('Privacy and Safety Screen')),
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

    testWidgets('renders settings list items', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.text('Your account'), findsOneWidget);
      expect(find.text('Privacy and safety'), findsOneWidget);
    });

    testWidgets('navigates to Your Account screen on tap', (WidgetTester tester) async {
      await pumpScreen(tester);
      await tester.tap(find.text('Your account'));
      await tester.pumpAndSettle();

      // Verify that a push event happened
      verify(mockNavigatorObserver.didPush(any, any));
      // Check if we landed on the correct screen
      expect(find.text('Your Account Screen'), findsOneWidget);
    });

    testWidgets('navigates to Privacy and safety screen on tap', (WidgetTester tester) async {
      await pumpScreen(tester);
      await tester.tap(find.text('Privacy and safety'));
      await tester.pumpAndSettle();

      // Verify that a push event happened
      verify(mockNavigatorObserver.didPush(any, any));
      // Check if we landed on the correct screen
      expect(find.text('Privacy and Safety Screen'), findsOneWidget);
    });
  });
}
