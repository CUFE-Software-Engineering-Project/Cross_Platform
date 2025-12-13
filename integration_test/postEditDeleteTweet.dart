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

  group('Postdelcr tweet', () {
    // Initialize app once for all tests in the group
    setUpAll(() async {
      app.main();
    });

    testWidgets('post delete create tweet', (WidgetTester tester) async {
      print('🚀 Starting test...');

      await waitForAppReady(tester);

      await login(tester, "yussefhassan600@gmail.com", "SaAaaD@@@2004");

      // Verify that we are logged in by checking for the presence of the PLUS button
      final plusButton = find.byType(Hero);
      expect(plusButton, findsOneWidget);
      await tester.tap(plusButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(plusButton);
      await tester.pump(const Duration(seconds: 2));

      final postTextField = find.byKey(
        const Key('postTextField_create_post_screen'),
      );
      await tester.enterText(postTextField, "no one is safe here");
      await tester.pumpAndSettle();

      final postButton = find.byKey(const Key('postButton_create_post_screen'));
      await tester.tap(postButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      var profileAvatar = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
      await tester.tap(profileAvatar);
      await tester.pump(const Duration(seconds: 5));

      final ProfileButton = find.text('Profile');
      await tester.tap(ProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final createdPost = find.byWidgetPredicate(
        (widget) =>
            (widget is Text &&
                widget.data != null &&
                widget.data!.contains("no one is safe here")) ||
            (widget is RichText &&
                widget.text.toPlainText().contains("no one is safe here")),
      );
      print('✅ Test passed: Post created and found on profile screen');

      await tester.tap(createdPost);
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.byTooltip('Show menu'));
      await tester.pumpAndSettle();

      final editButton = find.text('Edit');
      await tester.tap(editButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final editTweetField = find.byType(TextField).at(0);
      await tester.enterText(editTweetField, "engineer khaled is kind");
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final editedPost = find.text("engineer khaled is kind");
      expect(editedPost, findsOneWidget);
      print('✅ Test passed: Tweet edited successfully');

      await tester.tap(find.byTooltip('Show menu'));
      await tester.pumpAndSettle();

      final deleteButton = find.text('Delete');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final deleteButton1 = find.text('Delete');
      await tester.tap(deleteButton1);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // await tester.tap(find.byIcon(Icons.arrow_back));
      // await tester.pumpAndSettle();
    });
  });
}
