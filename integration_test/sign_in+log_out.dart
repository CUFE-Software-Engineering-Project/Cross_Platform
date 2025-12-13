import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lite_x/main.dart' as app;
import 'package:flutter/material.dart';
import 'sign_in_function.dart';
import 'log_out_function.dart';

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

  group('Sign In Tests', () {
    // Initialize app once for all tests in the group
    setUpAll(() async {
      app.main();
    });

    testWidgets('sign in test - navigate to login screen', (
      WidgetTester tester,
    ) async {
      print('🚀 Starting test...');

      await waitForAppReady(tester);

      await login(tester, "yussefhassan600@gmail.com", "SaAaaD@@@2004");

      // Verify that we are logged in by checking for the presence of the PLUS button
      final plusButton = find.byKey(const Key('plusButton_home_screen'));
      expect(plusButton, findsOneWidget);
      await tester.tap(plusButton);
      await tester.pumpAndSettle(const Duration(seconds: 7));
      print('✅ Test passed: Logged in and PLUS button found');

      final textFollowing = find.text('Following');
      expect(textFollowing, findsOneWidget);
      print('✅ Test passed: Home screen loaded with Following text');

      await logOut(tester);

      final createAccount = find.text('Create account');
      expect(createAccount, findsOneWidget);
      print('✅ Test passed: Intro screen loaded with Create Account text');
    });

    // testWidgets('sign in failed', (WidgetTester tester) async {
    //   print('🚀 Starting test...');

    //   await waitForAppReady(tester);

    //   // Debug: Print what's on the initial screen
    //   print('\n📱 INITIAL SCREEN:');

    //   // We're already on the intro screen from the previous test
    //   // Find and verify login button
    //   final loginButton = find.byKey(const Key('loginButton'));

    //   expect(loginButton, findsOneWidget);
    //   print('✓ Login button found');

    //   // Tap login button
    //   await tester.tap(loginButton);
    //   print('✓ Login button tapped');

    //   await tester.pumpAndSettle(const Duration(seconds: 1));

    //   // Try to find the forget password text
    //   var forgetPasswordText = find.text('Forgot password?');

    //   expect(forgetPasswordText, findsOneWidget);
    //   print('✅ Test passed: Found forget password text');

    //   final emailField = find.byKey(const Key('emailTextField_Login_Screen'));
    //   expect(emailField, findsOneWidget);

    //   await tester.tap(emailField);
    //   await tester.enterText(emailField, "lo00l@gmail.coco");
    //   await tester.pumpAndSettle();

    //   // Click next button
    //   final nextButton = find.byKey(const Key('NextButton_Login_Screen'));
    //   expect(nextButton, findsOneWidget);
    //   await tester.tap(nextButton);
    //   await tester.pumpAndSettle();

    //   // Checking text for error
    //   final errorText = find.text("Email not found. Please create an account.");
    //   expect(errorText, findsOneWidget);
    //   print('✅ Test passed: Sign in failed with invalid email');
    // });
  });
}
