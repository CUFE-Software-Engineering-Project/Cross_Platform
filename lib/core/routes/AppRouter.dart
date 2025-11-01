import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/auth/view/screens/Intro_Screen.dart';


import 'package:lite_x/features/home/view/screens/home_screen.dart';
import 'package:lite_x/core/view/screen/Splash_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Create_Account/CreateAccount_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/Change_Password_Feedback.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/Choose_New_Password_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/Confirmation_code_Loc_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/ForgotPassword_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/LoginPasswordScreen.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/Login_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Create_Account/Password_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Create_Account/Upload_Profile_Photo_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Create_Account/UserName_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Create_Account/Verification_Screen.dart';
import 'package:lite_x/features/auth/view/screens/Log_In/VerificationForgot_Screen.dart';
// import 'package:lite_x/features/auth/view/screens/Verification_Screen.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/screens/birthdate_screen.dart';
import 'package:lite_x/features/profile/view/screens/edit_profile_screen.dart';
import 'package:lite_x/features/profile/view/screens/following_followers_screen.dart';
import 'package:lite_x/features/profile/view/screens/profile_screen.dart';
import 'package:lite_x/features/auth/view/screens/SettingsAndPrivacy_Screen.dart';
import 'package:lite_x/features/auth/view/screens/PrivacyAndSafety_Screen.dart';
import 'package:lite_x/features/auth/view/screens/MuteAndBlock_Screen.dart';
import 'package:lite_x/features/auth/view/screens/BlockedAccounts_Screen.dart';
import 'package:lite_x/features/auth/view/screens/MutedAccounts_Screen.dart';
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
          child: const IntroScreen(),
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
        name: RouteConstants.profileScreen,
        path: "/profilescreen/:username",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: ProfilePage(
            username: state.pathParameters['username'] as String,
          ),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),

      GoRoute(
        name: RouteConstants.homescreen,
        path: "/home",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomeScreen(),
        name: RouteConstants.settingsandprivacyscreen,
        path: "/settingsandprivacy",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsAndPrivacyScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.privacyandsafetyscreen,
        path: "/privacyandsafety",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PrivacyAndSafetyScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.editProfileScreen,
        path: "/editProfile",
        pageBuilder: (context, state) {
          final profileData = state.extra as ProfileModel;
          return CustomTransitionPage(
            child: EditProfileScreen(profileData: profileData),
            transitionsBuilder: _slideRightTransitionBuilder,
          );
        },
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
      GoRoute(
        name: RouteConstants.Loginscreen,
        path: "/LoginScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.LoginPasswordScreen,
        path: "/LoginPasswordScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginPasswordScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.ForgotpasswordScreen,
        path: "/ForgotpasswordScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ForgotpasswordScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.ConfirmationCodeLocScreen,
        path: "/ConfirmationCodeLocScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ConfirmationCodeLocScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.VerificationforgotScreen,
        path: "/VerificationforgotScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const VerificationforgotScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.ChooseNewPasswordScreen,
        path: "/ChooseNewPasswordScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ChooseNewPasswordScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.ChangePasswordFeedback,
        path: "/ChangePasswordFeedback",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ChangePasswordFeedback(),
        name: RouteConstants.muteandblockscreen,
        path: "/muteandblock",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const MuteAndBlockScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
      GoRoute(
        name: RouteConstants.FollowingFollowersScreen,
        path: "/followingfollowersscreen/:initialTab/:isMe",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: FollowingFollowersScreen(
            initialIndex: int.parse(
              state.pathParameters['initialTab'] as String,
            ),
            isMe: state.pathParameters['isMe'] as String,
            profileModel: state.extra as ProfileModel,
          ),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
    GoRoute(
        name: RouteConstants.blockedaccountsscreen,
        path: "/blockedaccounts",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const BlockedAccountsScreen(),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
     GoRoute(
        name: RouteConstants.BirthDateScreen,
        path: "/birthDateScreen",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: BirthdateScreen(profileModel: state.extra as ProfileModel),
          transitionsBuilder: _slideRightTransitionBuilder,
        ),
      ),
        GoRouter(
        name: RouteConstants.mutedaccountsscreen,
        path: "/mutedaccounts",
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const MutedAccountsScreen(),
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
