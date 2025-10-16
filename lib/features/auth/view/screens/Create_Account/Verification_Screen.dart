import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/signup_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _isFormValid = ValueNotifier(false);
  late String email;

  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
    _codeController.addListener(_validateForm);
  }

  void _validateForm() {
    _isFormValid.value = _codeController.text.trim().isNotEmpty;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      context.goNamed(RouteConstants.passwordscreen);
    }
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code sent!'),
        backgroundColor: Palette.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: isWeb
          ? Colors.black.withOpacity(0.4)
          : Palette.background,
      appBar: !isWeb
          ? AppBar(
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
                      Expanded(child: Center(child: buildXLogo(size: 40))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'We sent you a code',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter it below to verify $email.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _codeController,
                          labelText: 'Verification code',
                          keyboardType: TextInputType.number,
                          validator: verificationCodeValidator,
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _resendCode,
                          child: const Text(
                            'Didn\'t receive an email?',
                            style: TextStyle(
                              fontSize: 15,
                              color: Palette.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(isWeb),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 10),
      width: isWeb ? double.infinity : null,
      alignment: isWeb ? Alignment.center : Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return SizedBox(
            width: isWeb ? double.infinity : 90,
            child: ElevatedButton(
              onPressed: isValid ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: isWeb ? const Size(0, 60) : const Size(0, 40),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
