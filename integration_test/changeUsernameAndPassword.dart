import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lite_x/main.dart' as app;
import 'package:flutter/material.dart';
import 'sign_in_function.dart';
// import 'log_out_function.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to wait for app initialization
  Future<void> waitForAppReady(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 2));
    });
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  group('change Tests 1', () {
    // Initialize app once for all tests in the group
    setUpAll(() async {
      app.main();
    });

    testWidgets('change username and password', (
      WidgetTester tester,
    ) async {
      print('🚀 Starting test...');

      await waitForAppReady(tester);

      await login(tester, "yussefhassan600@gmail.com", "SaAaaD@@@2004");

      var profileAvatar = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
      await tester.tap(profileAvatar);
      await tester.pump(const Duration(seconds: 5));

      final settingButton = find.text('Settings & Support');
      await tester.tap(settingButton);
      await tester.pumpAndSettle();

      final yourAccountButton = find.byKey(
        const Key('YourAccount_SettingsAndPrivacy_Screen'),
      );
      await tester.tap(yourAccountButton);
      await tester.pumpAndSettle();

      final accountInfoButton = find.byKey(
        const Key('AccountInformation_YourAccount_Screen'),
      );
      await tester.tap(accountInfoButton);
      await tester.pumpAndSettle();

      final usernameSettingButton = find.byKey(
        const Key('Username_AccountInformation_Screen'),
      );
      await tester.tap(usernameSettingButton);
      await tester.pumpAndSettle();

      final changeUsernameField = find.byKey(
        const Key('changeUsernameField_UserName_Screen'),
      );
      await tester.tap(changeUsernameField);
      await tester.enterText(changeUsernameField, "lolol88");
      await tester.pumpAndSettle();

      final doneButton = find.byKey(const Key('Done_Button_UserName_Screen'));
      await tester.tap(doneButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));


      final textFollowing = find.text('Following');
      expect(textFollowing, findsOneWidget);




      ///////////////////////////////////////////////////////////////
      var profileAvatar1 = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
      await tester.tap(profileAvatar1);
      await tester.pump(const Duration(seconds: 5));

      final settingButton1 = find.text('Settings & Support');
      await tester.tap(settingButton1);
      await tester.pumpAndSettle();

      final yourAccountButton1 = find.byKey(
        const Key('YourAccount_SettingsAndPrivacy_Screen'),
      );
      await tester.tap(yourAccountButton1);
      await tester.pumpAndSettle();

      final changePasswordButton1 = find.byKey(
        const Key('changePassword_YourAccount_Screen'),
      );
      await tester.tap(changePasswordButton1);
      await tester.pumpAndSettle();


      final currentPasswordField1 = find.byKey(
        const Key('curPassord_ChangePassword_Screen'),
      );
      await tester.tap(currentPasswordField1);
      await tester.enterText(currentPasswordField1, "SaAaaD@2004");
      await tester.pumpAndSettle();

      final newPasswordField1 = find.byKey(
        const Key('newPassord_ChangePassword_Screen'),
      );
      await tester.tap(newPasswordField1);
      await tester.enterText(newPasswordField1, "SaAaaD@2004");
      await tester.pumpAndSettle();

      final confirmPasswordField = find.byKey(
        const Key('confirmPassord_ChangePassword_Screen'),
      );
      await tester.tap(confirmPasswordField);
      await tester.enterText(confirmPasswordField, "SaAaaD@2004");
      await tester.pumpAndSettle();

      final updatePasswordButton = find.byKey(
          const Key('updatePassword_ChangePassword_Screen')
      );
      await tester.tap(updatePasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final createAccount = find.text('Create account');
      expect(createAccount, findsOneWidget);

    });
  });
}
