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

  group('Edit prof', () {
    // Initialize app once for all tests in the group
    setUpAll(() async {
      app.main();
    });

    testWidgets('Edit user profile', (WidgetTester tester) async {
      print('🚀 Starting test...');

      await waitForAppReady(tester);

      await login(tester, "yussefhassan600@gmail.com", "SaAaaD@@@2004");

      var profileAvatar = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
      await tester.tap(profileAvatar);
      await tester.pump(const Duration(seconds: 5));

      final ProfileButton = find.text('Profile');
      await tester.tap(ProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final EditProfileButton = find.byKey(
        const Key('EditProfileButton_profile_header'),
      );
      await tester.tap(EditProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // final nameProfileField = find.byKey(
      //   const Key('nameProfile_edit_profile_form'),
      // );

      final nameProfileField = find.byType(TextField).at(0);
      

      await tester.tap(nameProfileField);
      await tester.enterText(nameProfileField, 'Yussef Hassan');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final bioProfileField = find.byType(TextField).at(1);
      await tester.tap(bioProfileField);
      await tester.enterText(bioProfileField, 'Flutter Developer');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final saveButton = find.byKey(
        const Key('saveProfile_edit_profile_screen'),
      );

      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final myNameText = find.text('Yussef Hassan');
      expect(myNameText, findsOneWidget);
      final myBioText = find.text('Flutter Developer');
      expect(myBioText, findsOneWidget);
      print('✅ Test completed successfully.');
    });
  });
}
