import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class ConfirmationCodeLocScreen extends ConsumerStatefulWidget {
  const ConfirmationCodeLocScreen({super.key});

  @override
  ConsumerState<ConfirmationCodeLocScreen> createState() =>
      _ConfirmationCodeLocScreenState();
}

class _ConfirmationCodeLocScreenState
    extends ConsumerState<ConfirmationCodeLocScreen> {
  String _selectedMethod = 'email';

  void _handleNext() {
    print('Sending code via: $_selectedMethod');
    context.pushNamed(RouteConstants.VerificationforgotScreen);
  }

  void _handleCancel() {
    context.pop();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    final maskedUsername = username.length <= 2
        ? username[0] + '*' * (username.length - 1)
        : username.substring(0, 2) + '*' * (username.length - 2);
    final domainParts = domain.split('.');
    if (domainParts.length < 2) {
      final maskedDomain = domain[0] + '*' * (domain.length - 1);
      return '$maskedUsername@$maskedDomain';
    }
    final mainDomain = domainParts[0];
    final extension = domainParts.sublist(1).join('.');
    final maskedMainDomain = mainDomain[0] + '*' * (mainDomain.length - 1);
    final maskedExtension = '*' * extension.length;
    return '$maskedUsername@$maskedMainDomain.$maskedExtension';
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(emailProvider);
    final isWeb = kIsWeb;
    final maskedEmail = _maskEmail(email);

    return Scaffold(
      backgroundColor: isWeb
          ? Colors.black.withOpacity(0.4)
          : Palette.background,
      appBar: !isWeb
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close, color: Palette.textWhite),
                onPressed: () => context.goNamed(RouteConstants.introscreen),
              ),
              title: buildXLogo(size: 36),
              centerTitle: true,
              backgroundColor: Palette.background,
              elevation: 0,
            )
          : null,
      body: Center(
        child: Container(
          width: isWeb ? 600 : double.infinity,
          height: isWeb ? 650 : double.infinity,
          decoration: BoxDecoration(
            color: Palette.background,
            borderRadius: isWeb ? BorderRadius.circular(16) : null,
          ),
          child: Column(
            children: [
              if (isWeb)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Palette.textWhite),
                        onPressed: () =>
                            context.goNamed(RouteConstants.introscreen),
                      ),
                      Expanded(child: Center(child: buildXLogo(size: 40))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Where should we send a confirmation code?',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Palette.textWhite,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Before you can change your password, we need to make sure it\'s really you.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Start by choosing where to send a confirmation code.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildoption(
                            title: "Send an email to",
                            valueText: maskedEmail,
                            optionValue: "email",
                          ),
                        ],
                      ),
                      _buildSupportText(),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(isWeb),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildoption({
    required String title,
    required String valueText,
    required String optionValue,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = optionValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send an email to',
                    style: TextStyle(
                      fontSize: 18,
                      color: Palette.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    valueText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Palette.textWhite,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: optionValue,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
              activeColor: Colors.transparent,
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Palette.primary;
                }
                return Palette.textSecondary;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: _handleCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Palette.textWhite,
              side: const BorderSide(color: Palette.textWhite, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: isWeb ? 120 : 80,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                backgroundColor: Palette.textWhite,
                foregroundColor: Palette.background,
                minimumSize: const Size(0, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Palette.textSecondary),
        children: [
          const TextSpan(text: 'Contact '),
          TextSpan(
            text: 'X Support',
            style: const TextStyle(
              color: Palette.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const TextSpan(text: ' if you don\'t have access.'),
        ],
      ),
    );
  }
}
