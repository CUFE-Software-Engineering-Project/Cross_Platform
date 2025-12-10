import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> logOut(WidgetTester tester) async {
  var profileAvatar = find.byKey(const Key('ProfileAvatar_HomeAppBar'));
  expect(profileAvatar, findsOneWidget);
  
  // Tap on profile avatar to open drawer.
  await tester.tap(profileAvatar);
  await tester.pump(
    const Duration(seconds: 5),
  ); // time-based, not waiting for app to settle
  print('✅ After tapping profile avatar');

  final settingButton = find.text('Settings & Support');
  expect(settingButton, findsOneWidget);
  await tester.tap(settingButton);
  await tester.pumpAndSettle();

  final yourAccountButton = find.byKey(
    const Key('YourAccount_SettingsAndPrivacy_Screen'),
  );
  expect(yourAccountButton, findsOneWidget);
  await tester.tap(yourAccountButton);

  await tester.pumpAndSettle();

  final accountInfoButton = find.byKey(
    const Key('AccountInformation_YourAccount_Screen'),
  );
  expect(accountInfoButton, findsOneWidget);
  await tester.tap(accountInfoButton);

  await tester.pumpAndSettle();

  final logoutButton = find.byKey(
    const Key('Log_out_AccountInformation_Screen'),
  );
  expect(logoutButton, findsOneWidget);
  await tester.tap(logoutButton);

  await tester.pumpAndSettle();
}
