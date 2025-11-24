import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/settings/screens/MuteAndBlock_Screen.dart';
import 'package:mockito/mockito.dart';

import 'navigator_observer_mocks.mocks.dart';

void main() {
  group('MuteAndBlockScreen Widget Tests', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/mute_and_block',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/mute_and_block',
            name: 'mute_and_block',
            builder: (context, state) => const MuteAndBlockScreen(),
          ),
          GoRoute(
            path: '/blocked_accounts',
            name: RouteConstants.blockedaccountsscreen,
            builder: (context, state) => const Scaffold(body: Text('Blocked Accounts Screen')),
          ),
          GoRoute(
            path: '/muted_accounts',
            name: RouteConstants.mutedaccountsscreen,
            builder: (context, state) => const Scaffold(body: Text('Muted Accounts Screen')),
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

    testWidgets('renders mute and block list items', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Blocked accounts'), findsOneWidget);
      expect(find.text('Muted accounts'), findsOneWidget);
      expect(find.text('Muted words'), findsOneWidget);
      expect(find.text('Muted notifications'), findsOneWidget);
    });

    testWidgets('navigates to Blocked accounts screen on tap', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Blocked accounts'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Blocked Accounts Screen'), findsOneWidget);
    });

    testWidgets('navigates to Muted accounts screen on tap', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Muted accounts'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Muted Accounts Screen'), findsOneWidget);
    });
  });
}
