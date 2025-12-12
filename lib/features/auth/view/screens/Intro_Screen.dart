import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/buildTermsText.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Palette.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: const Color(0xFF5C5C5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    ref.listen(authViewModelProvider, (previous, next) {
      final authViewModel = ref.read(authViewModelProvider.notifier);

      if (next.type == AuthStateType.authenticated) {
        if (next.message == "new_google_user" ||
            next.message == "new_github_user") {
          context.goNamed(RouteConstants.setbirthdate);
          return;
        }
        if (next.message == "google_login_success" ||
            next.message == "github_login_success") {
          context.goNamed(RouteConstants.homescreen);
          return;
        }
      } else if (next.type == AuthStateType.error) {
        _showErrorToast(
          context,
          next.message ?? 'Login failed. Please try again.',
        );
        authViewModel.resetState();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Palette.background,
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(),
              child: SafeArea(child: _buildMobileLayout(size, context, ref)),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Loader(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size, BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(child: buildXLogo(size: 46)),
          // SizedBox(height: size.height * 0.15),
          const Spacer(flex: 1),
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
          const Spacer(flex: 1),
          _buildAuthButtons(context, ref),
          const SizedBox(height: 20),
          buildTermsText(),
          const SizedBox(height: 5),
          _buildLoginSection(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Column(
      children: [
        AuthButton(
          icon: 'assets/images/google.png',
          label: 'Continue with Google',
          onPressed: isLoading
              ? null
              : () {
                  ref.read(authViewModelProvider.notifier).loginWithGoogle();
                },
        ),
        const SizedBox(height: 10),
        AuthButton(
          icon: 'assets/images/github.png',
          label: 'Continue with GitHub',
          onPressed: isLoading
              ? null
              : () {
                  ref.read(authViewModelProvider.notifier).loginWithGithub();
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
          onPressed: isLoading
              ? null
              : () {
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
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          GestureDetector(
            onTap: () {
              context.pushNamed(RouteConstants.Loginscreen);
            },
            child: const Text(
              'Log in',
              style: TextStyle(
                color: Palette.info,
                fontSize: 16,
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
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isEnabled ? Colors.white : Colors.white.withOpacity(0.6),
      foregroundColor: isEnabled ? Colors.black : Colors.black.withOpacity(0.4),
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
