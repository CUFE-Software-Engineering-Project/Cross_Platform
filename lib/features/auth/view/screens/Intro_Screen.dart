// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/repositories/auth_remote_repository.dart';
import 'package:lite_x/features/auth/view/widgets/buildTermsText.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:google_sign_in/google_sign_in.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});
  // Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
  //   try {
  //     const String yourServerClientId =
  //         '806859586571-kv61qm314lnqg02m6v0ae0gctkq55cvm.apps.googleusercontent.com';
  //     final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  //     await googleSignIn.initialize(serverClientId: yourServerClientId);

  //     final GoogleSignInAccount? account = await googleSignIn.authenticate();

  //     if (account == null) {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Google Sign-In Canceled')),
  //         );
  //       }
  //       return;
  //     }

  //     const List<String> scopes = ['email'];

  //     final GoogleSignInServerAuthorization? serverAuth = await account
  //         .authorizationClient
  //         .authorizeServer(scopes);

  //     final String? serverAuthCode = serverAuth?.serverAuthCode;

  //     if (serverAuthCode == null) {
  //       throw Exception('Failed to get server auth code from Google.');
  //     }
  //     if (context.mounted) {
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) =>
  //             const Center(child: CircularProgressIndicator()),
  //       );
  //     }

  //     final repo = ref.read(authRemoteRepositoryProvider);
  //     final result = await repo.googleSignIn(serverAuthCode);
  //     if (context.mounted) {
  //       Navigator.of(context).pop();
  //     }

  //     if (context.mounted) {
  //       result.fold(
  //         (failure) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Error: ${failure.message}')),
  //           );
  //         },
  //         (loginResponse) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 'Login Successful! Welcome ${loginResponse.user.name}',
  //               ),
  //             ),
  //           );
  //           context.goNamed(RouteConstants.TestChatScreen);
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     if (context.mounted && Navigator.of(context).canPop()) {
  //       Navigator.of(context).pop();
  //     }

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Palette.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: SafeArea(child: _buildMobileLayout(size, context, ref)),
      ),
    );
  }

  Widget _buildMobileLayout(Size size, BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Center(child: buildXLogo(size: 50)),
            SizedBox(height: size.height * 0.15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                'See what\'s\nhappening in the\nworld right now.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.15),
            _buildAuthButtons(context, ref),
            const SizedBox(height: 25),
            buildTermsText(),
            const SizedBox(height: 5),
            _buildLoginSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AuthButton(
          icon: 'assets/images/google.png',
          label: 'Continue with Google',
          onPressed: () async {
            // await _handleGoogleSignIn(context, ref);
            // context.pushNamed(RouteConstants.TestChatScreen);
          },
        ),
        const SizedBox(height: 10),
        AuthButton(
          icon: 'assets/images/github.png',
          label: 'Continue with GitHub',
          onPressed: () {
            context.pushNamed(RouteConstants.ConversationsScreen);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey[800])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'or',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey[800])),
          ],
        ),
        const SizedBox(height: 12),
        AuthButton(
          label: 'Create account',
          onPressed: () {
            context.pushNamed(RouteConstants.createaccountscreen);
          },
        ),
      ],
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Wrap(
        children: [
          const Text(
            'Have an account already? ',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              context.pushNamed(RouteConstants.Loginscreen);
            },
            child: const Text(
              'Log in',
              style: TextStyle(
                color: Palette.info,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String? icon;
  final String label;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    );

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Image.asset(icon!, width: 24, height: 24),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
