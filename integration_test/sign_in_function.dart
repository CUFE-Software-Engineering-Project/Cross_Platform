import "package:flutter/material.dart";
import 'package:flutter_test/flutter_test.dart';

Future<void> login(WidgetTester tester, String email, String password) async {
  print('✓ App initialized');

  // Debug: Print what's on the initial screen
  print('\n📱 INITIAL SCREEN:');

  // Find and verify login button
  final loginButton = find.byKey(const Key('loginButton'));

  expect(loginButton, findsOneWidget);
  print('✓ Login button found');

  // Tap login button
  await tester.tap(loginButton);
  print('✓ Login button tapped');

  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Try to find the forget password text with case insensitivity
  var forgetPasswordText = find.text('Forgot password?');

  expect(forgetPasswordText, findsOneWidget);
  print('✅ Test passed: Found forget password text');

  final emailField = find.byKey(const Key('emailTextField_Login_Screen'));
  expect(emailField, findsOneWidget);

  await tester.tap(emailField);
  await tester.enterText(emailField, email);
  await tester.pumpAndSettle();

  //click next button
  final nextButton = find.byKey(const Key('NextButton_Login_Screen'));
  expect(nextButton, findsOneWidget);
  await tester.tap(nextButton);
  await tester.pumpAndSettle();

  //write password
  final passwordField = find.byKey(
    const Key('passwordTextField_LoginPasswordScreen'),
  );
  await tester.tap(passwordField);
  await tester.enterText(passwordField, password);
  await tester.pumpAndSettle();

  //click login button to enter the app
  final loginButton2 = find.byKey(const Key('LoginButton_LoginPasswordScreen'));
  expect(loginButton2, findsOneWidget);
  await tester.tap(loginButton2);
  await tester.pump(
    const Duration(seconds: 5),
  ); // time-based, not waiting for app to settle

  print("🔍 After login animation");
}
