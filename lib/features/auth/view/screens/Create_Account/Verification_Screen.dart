import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/dobProvider.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/providers/nameProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

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
  late String name;
  late String dateOfBirth;

  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
    name = ref.read(nameProvider);
    dateOfBirth = ref.read(dobProvider);
    _codeController.addListener(_validateForm);
  }

  void _validateForm() {
    _isFormValid.value = _codeController.text.trim().isNotEmpty;
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ref
        .read(authViewModelProvider.notifier)
        .verifySignupEmail(email: email, code: _codeController.text.trim());
  }

  void _resendCode() {
    ref
        .read(authViewModelProvider.notifier)
        .createAccount(name: name, email: email, dateOfBirth: dateOfBirth);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Verification code sent!',
          style: TextStyle(color: Palette.background),
        ),
        backgroundColor: Palette.iconsActive,
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
    ref.listen(authViewModelProvider, (previous, next) {
      final authViewModel = ref.read(authViewModelProvider.notifier);

      if (next.type == AuthStateType.verified) {
        context.goNamed(RouteConstants.passwordscreen);
        authViewModel.resetState();
      } else if (next.type == AuthStateType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.message ?? 'Invalid verification code',
              style: TextStyle(color: Palette.background),
            ),
            backgroundColor: Palette.textWhite,
          ),
        );
        authViewModel.resetState();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
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
                    _buildNextButton(isLoading),
                    const SizedBox(height: 15),
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

  Widget _buildNextButton(bool isLoading) {
    return Container(
      padding: EdgeInsets.all(10),

      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return SizedBox(
            width: 90,
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: const Size(0, 40),
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
