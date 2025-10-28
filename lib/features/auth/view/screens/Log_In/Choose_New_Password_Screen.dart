import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class ChooseNewPasswordScreen extends ConsumerStatefulWidget {
  const ChooseNewPasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseNewPasswordScreenState();
}

class _ChooseNewPasswordScreenState
    extends ConsumerState<ChooseNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newpasswordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);
  final _newPasswordValid = ValueNotifier<bool>(false);
  final _confirmPasswordValid = ValueNotifier<bool>(false);
  final _passwordsMatch = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final email = ref.read(emailProvider);
    _emailController.text = email;
    _newpasswordController.addListener(_validateForm);
    _confirmpasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final newPasswordValid =
        _newpasswordController.text.trim().isNotEmpty &&
        _newpasswordController.text.length >= 8;

    final confirmPasswordValid =
        _confirmpasswordController.text.trim().isNotEmpty &&
        _confirmpasswordController.text.length >= 8 &&
        _newpasswordController.text == _confirmpasswordController.text;

    _newPasswordValid.value = newPasswordValid;
    _confirmPasswordValid.value = confirmPasswordValid;
    _isFormValid.value = newPasswordValid && confirmPasswordValid;
    if (_newpasswordController.text.isEmpty ||
        _confirmpasswordController.text.isEmpty) {
      _passwordsMatch.value = false;
    } else {
      _passwordsMatch.value =
          (_newpasswordController.text == _confirmpasswordController.text);
    }
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      print('New Password: ${_newpasswordController.text}');
      print('Confirm Password: ${_confirmpasswordController.text}');
      context.goNamed(RouteConstants.ChangePasswordFeedback);
    }
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value != _newpasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void dispose() {
    _newpasswordController.removeListener(_validateForm);
    _confirmpasswordController.removeListener(_validateForm);
    _emailController.dispose();
    _confirmpasswordController.dispose();
    _newpasswordController.dispose();
    _isFormValid.dispose();
    _newPasswordValid.dispose();
    _confirmPasswordValid.dispose();
    _passwordsMatch.dispose();
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
                          'Choose a new password',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w800,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Palette.textSecondary,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'Make sure your new password is 8 characters or more. Try including numbers, letters, and punctuation marks for a ',
                              ),
                              TextSpan(
                                text: 'strong password.',
                                style: const TextStyle(
                                  color: Palette.primary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'You\'ll be logged out of all active X sessions after your password is changed.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Palette.textSecondary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 22),
                        CustomTextField(
                          controller: _emailController,
                          readOnly: true,
                          enabled: false,
                        ),
                        const SizedBox(height: 38),
                        ValueListenableBuilder<bool>(
                          valueListenable: _passwordsMatch,
                          builder: (context, isValid, child) {
                            return CustomTextField(
                              controller: _newpasswordController,
                              labelText: 'Enter a new password',
                              isPassword: true,
                              validator: passwordValidator,

                              isPasswordCheck:
                                  _newpasswordController.text.isEmpty
                                  ? null
                                  : _confirmpasswordController.text ==
                                        _newpasswordController.text,
                              onFieldSubmitted: (_) {
                                if (_isFormValid.value) {
                                  _handleChangePassword();
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        ValueListenableBuilder<bool>(
                          valueListenable: _passwordsMatch,
                          builder: (context, isValid, child) {
                            return CustomTextField(
                              controller: _confirmpasswordController,
                              labelText: 'Confirm your password',
                              isPassword: true,
                              validator: _confirmPasswordValidator,

                              isPasswordCheck:
                                  _confirmpasswordController.text.isEmpty
                                  ? null
                                  : _confirmpasswordController.text ==
                                        _newpasswordController.text,
                              onFieldSubmitted: (_) {
                                if (_isFormValid.value) {
                                  _handleChangePassword();
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(isWeb),
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
            width: isWeb ? 240 : 200,
            child: ElevatedButton(
              onPressed: isValid ? _handleChangePassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: isWeb ? const Size(0, 60) : const Size(0, 40),
              ),
              child: const Text(
                'Change password',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
