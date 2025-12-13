import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/followers_List.dart';
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

  group('follow', () {
    // Initialize app once for all tests in the group
    setUpAll(() async {
      app.main();
    });

    testWidgets('follow User', (WidgetTester tester) async {
      print('🚀 Starting test...');

      await waitForAppReady(tester);

      await login(tester, "yussefhassan600@gmail.com", "SaAaaD@@@2004");

      var profileAvatar = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
      await tester.tap(profileAvatar);
      await tester.pump(const Duration(seconds: 5));

      final ProfileButton = find.text('Profile');
      await tester.tap(ProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final searchButton = find.byKey(
        const Key('SearchButton_profile_header'),
      );
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final searchField = find.byKey(
        const Key('profileSearch_profile_search_screen'),
      );
      await tester.enterText(searchField, 'c');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final abdaullaUser = find.text('Carter Terry');
      expect(abdaullaUser, findsOneWidget);
      await tester.tap(abdaullaUser);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final followUnfollowButton = find.byKey(
        const Key('followFollowing_follow_following_button'),
      );
      expect(followUnfollowButton, findsOneWidget);
      await tester.tap(followUnfollowButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final FollowerField = find.byKey(const Key('FollowerCount_profile_header'));
      await tester.tap(FollowerField);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 2));


// Find the FollowerList widget first
final followerList = find.byType(FollowerList);

// Find the Scrollable inside that list
final scrollableFollowerList = find.descendant(
  of: followerList,
  matching: find.byType(Scrollable),
);

// Now scroll until 'youssef' is visible
final myName = find.text('youssef');

await tester.scrollUntilVisible(
  myName,
  300, // scroll by 300 pixels per step
  scrollable: scrollableFollowerList,
);



      expect(myName, findsOneWidget);
      print('✅ Follow User test passed');

    });
  });
}
