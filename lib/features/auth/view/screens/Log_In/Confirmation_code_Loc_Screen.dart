import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class ConfirmationCodeLocScreen extends ConsumerStatefulWidget {
  const ConfirmationCodeLocScreen({super.key});

  @override
  ConsumerState<ConfirmationCodeLocScreen> createState() =>
      _ConfirmationCodeLocScreenState();
}

class _ConfirmationCodeLocScreenState
    extends ConsumerState<ConfirmationCodeLocScreen> {
  String _selectedMethod = 'email';
  late String email;

  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
  }

  void _handleNext() {
    ref.read(authViewModelProvider.notifier).forgetPassword(email: email);
  }

  void _handleCancel() {
    context.pop();
  }

  void _showToast(String message) {
    if (!mounted) return;
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
    ref.listen(authViewModelProvider, (previous, next) {
      final authViewModel = ref.read(authViewModelProvider.notifier);

      if (next.type == AuthStateType.success) {
        context.pushNamed(RouteConstants.VerificationforgotScreen);
        authViewModel.resetState();
      } else if (next.type == AuthStateType.error) {
        _showToast(next.message ?? 'Failed to send verification code');
        authViewModel.resetState();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    final maskedEmail = _maskEmail(email);

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Palette.textWhite),
          onPressed: isLoading
              ? null
              : () => context.goNamed(RouteConstants.introscreen),
        ),
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: Palette.background),
                child: Column(
                  children: [
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
                    _buildBottomButtons(isLoading),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(color: Colors.black, child: const Loader()),
          ],
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

  Widget _buildBottomButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 45, minWidth: 80),
            child: OutlinedButton(
              onPressed: isLoading ? null : _handleCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textWhite,
                side: const BorderSide(color: Palette.textWhite, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Cancel',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            height: 45,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  backgroundColor: Palette.textWhite,
                  disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
                  foregroundColor: Palette.background,
                  disabledForegroundColor: Palette.border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Next',
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 15, color: Palette.textSecondary),
        children: [
          TextSpan(text: 'Contact '),
          TextSpan(
            text: 'X Support',
            style: TextStyle(
              color: Palette.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(text: ' if you don\'t have access.'),
        ],
      ),
    );
  }
}
