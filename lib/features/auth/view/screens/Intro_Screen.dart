import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildTermsText.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class IntoScreen extends StatelessWidget {
  const IntoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    final isMobile = size.width < 600;

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
              : _buildMobileLayout(size, isMobile, context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size, bool isMobile, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Center(child: buildXLogo(size: 50)),
            SizedBox(height: size.height * 0.25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
            _buildAuthButtons(isWeb: false, context: context),
            const SizedBox(height: 25),
            buildTermsText(),
            SizedBox(height: size.height * 0.05),
            _buildLoginSection(),
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
                Container(
                  width: 300,
                  height: 300,
                  child: buildXLogo(size: 300),
                ),
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
                _buildAuthButtons(isWeb: true, context: context),
                const SizedBox(height: 20),
                buildTermsText(),
                const SizedBox(height: 20),
                _buildLoginSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons({
    required bool isWeb,
    required BuildContext context,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.textWhite,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: Image.asset(
              'assets/images/google.png',
              width: 24,
              height: 24,
            ),
            label: const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (isWeb) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(
                Icons.apple,
                size: 20,
                color: Palette.background,
              ),
              label: const Text(
                'Continue with Apple',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey[800])),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'or',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey[800])),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.pushNamed(RouteConstants.createaccountscreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Create account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Have an account already? ',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {},
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
