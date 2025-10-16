import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildTermsText.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb || size.width > 800;

    return Scaffold(
      backgroundColor: Palette.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101010), Palette.background],
          ),
        ),
        child: SafeArea(
          child: isWeb
              ? _buildWebLayout(size, context)
              : _buildMobileLayout(size, context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size, BuildContext context) {
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
            _buildAuthButtons(context),
            const SizedBox(height: 25),
            buildTermsText(),
            const SizedBox(height: 5),
            _buildLoginSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(Size size, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(child: buildXLogo(size: 300)),
                const SizedBox(height: 10),
                const Text(
                  'Happening now',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Palette.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join today.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Palette.textWhite,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAuthButtons(context),
                const SizedBox(height: 20),
                buildTermsText(),
                const SizedBox(height: 20),
                _buildLoginSection(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        AuthButton(
          icon: 'assets/images/google.png',
          label: 'Continue with Google',
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        AuthButton(
          icon: 'assets/images/facebook.png',
          label: 'Continue with Facebook',
          onPressed: () {},
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
