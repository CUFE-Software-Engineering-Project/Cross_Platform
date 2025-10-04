import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/view/screen/Splash_Screen.dart';
import 'package:lite_x/features/auth/view/screens/CreateAccount_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Intro_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Password_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Upload_Profile_Photo_Screen.dart';
import 'package:lite_x/features/auth/view/screens/UserName_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Verification_Screen.dart';

class Approuter {
  static final GoRouter router = GoRouter(
    initialLocation: "/splash",
    routes: [
      GoRoute(
        name: RouteConstants.splash,
        path: "/splash",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.introscreen,
        path: "/",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const IntoScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.createaccountscreen,
        path: "/createaccount",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CreateAccountScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.verificationscreen,
        path: "/verification",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const VerificationScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.passwordscreen,
        path: "/password",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PasswordScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.uploadProfilePhotoScreen,
        path: "/upload_profile_photo",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const UploadProfilePhotoScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.UserNameScreen,
        path: "/username",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const UsernameScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
    ],
    redirect: (context, state) {
      return null;
    },
    errorPageBuilder: (context, state) {
      return MaterialPage(child: Text("Error 404"));
    },
  );
  static Widget _slideRightTransitionBuilder(
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    const curve = Curves.ease;
    final tween = Tween(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve));
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }
}
