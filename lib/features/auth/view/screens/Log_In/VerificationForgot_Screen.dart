// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class VerificationforgotScreen extends ConsumerStatefulWidget {
  const VerificationforgotScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerificationforgotScreenState();
}

class _VerificationforgotScreenState
    extends ConsumerState<VerificationforgotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      context.goNamed(RouteConstants.ChooseNewPasswordScreen);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: null,

      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Palette.background,
            borderRadius: null,
          ),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
                        const SizedBox(height: 11),
                        const Text(
                          'Check your email to get your confirmation code. if you need to request a new code, go back and reselect a confirmation.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Palette.textSecondary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the code';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _isFormValid.value =
                                _formKey.currentState?.validate() ?? false;
                          },
                          controller: _codeController,
                          labelText: 'Enter your code',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () {
              context.pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Palette.textWhite,
              side: const BorderSide(color: Palette.textWhite, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isFormValid,
            builder: (context, isValid, child) {
              return SizedBox(
                width: 80,
                child: ElevatedButton(
                  onPressed: isValid ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    backgroundColor: Palette.textWhite,
                    disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
                    foregroundColor: Palette.background,
                    disabledForegroundColor: Palette.border,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
