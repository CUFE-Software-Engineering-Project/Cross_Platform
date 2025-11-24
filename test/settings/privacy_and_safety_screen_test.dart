import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/settings/screens/PrivacyAndSafety_Screen.dart';
import 'package:mockito/mockito.dart';

import 'navigator_observer_mocks.mocks.dart';

void main() {
  group('PrivacyAndSafetyScreen Widget Tests', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/privacy_and_safety',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/privacy_and_safety',
            name: 'privacy_and_safety',
            builder: (context, state) => const PrivacyAndSafetyScreen(),
          ),
          GoRoute(
            path: '/mute_and_block',
            name: RouteConstants.muteandblockscreen,
            builder: (context, state) => const Scaffold(body: Text('Mute and Block Screen')),
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

    testWidgets('renders privacy and safety list items', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Audience and tagging'), findsOneWidget);
      expect(find.text('Your posts'), findsOneWidget);
      expect(find.text('Content you see'), findsOneWidget);
      expect(find.text('Mute and block'), findsOneWidget);
      expect(find.text('Direct messages'), findsOneWidget);
    });

    testWidgets('navigates to Mute and block screen on tap', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Mute and block'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Mute and Block Screen'), findsOneWidget);
    });
  });
}
