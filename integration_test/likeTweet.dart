import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lite_x/main.dart' as app;
import 'package:flutter/material.dart';
import 'sign_in_function.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to wait for app initialization
  Future<void> waitForAppReady(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  group('like tweet', () {
    // Initialize app once for all tests in the group
    setUpAll(() async {
      app.main();
    });

    testWidgets('like tweet', (WidgetTester tester) async {
      print('🚀 Starting test...');

      await waitForAppReady(tester);

      await login(tester, "yussefhassan600@gmail.com", "SaAaaD@@@2004");

      var profileAvatar = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
      await tester.tap(profileAvatar);
      await tester.pump(const Duration(seconds: 5));

      final ProfileButton = find.text('Profile');
      await tester.tap(ProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final likeButton = find.byKey(const Key("likeButton_shared"));
      await tester.tap(likeButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(
  find.byType(SvgPicture),
  findsOneWidget,
);

    });
  });
}
