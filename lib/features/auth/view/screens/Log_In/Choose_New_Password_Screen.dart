import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

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
  late String email;

  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
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
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    ref
        .read(authViewModelProvider.notifier)
        .resetPassword(
          email: email,
          password: _newpasswordController.text.trim(),
        );
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
    ref.listen(authViewModelProvider, (previous, next) {
      final authViewModel = ref.read(authViewModelProvider.notifier);

      if (next.type == AuthStateType.success) {
        context.goNamed(RouteConstants.ChangePasswordFeedback);
        authViewModel.resetState();
      } else if (next.type == AuthStateType.error) {
        _showToast(next.message ?? 'Failed to change password');
        authViewModel.resetState();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

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
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Palette.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Make sure your new password is 8 characters or more. Try including numbers, letters, and punctuation marks for a ',
                                    ),
                                    TextSpan(
                                      text: 'strong password.',
                                      style: TextStyle(
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
                                builder: (context, isMatch, child) {
                                  TextFieldValidationState validationState =
                                      TextFieldValidationState.none;

                                  if (_newpasswordController.text.isNotEmpty &&
                                      _confirmpasswordController
                                          .text
                                          .isNotEmpty) {
                                    validationState = isMatch
                                        ? TextFieldValidationState.valid
                                        : TextFieldValidationState.invalid;
                                  }

                                  return CustomTextField(
                                    controller: _newpasswordController,
                                    labelText: 'Enter a new password',
                                    isPassword: true,
                                    validator: passwordValidator,
                                    validationState: validationState,
                                    onFieldSubmitted: (_) {
                                      if (_isFormValid.value && !isLoading) {
                                        _handleChangePassword();
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 32),
                              ValueListenableBuilder<bool>(
                                valueListenable: _passwordsMatch,
                                builder: (context, isMatch, child) {
                                  TextFieldValidationState validationState =
                                      TextFieldValidationState.none;

                                  if (_newpasswordController.text.isNotEmpty &&
                                      _confirmpasswordController
                                          .text
                                          .isNotEmpty) {
                                    validationState = isMatch
                                        ? TextFieldValidationState.valid
                                        : TextFieldValidationState.invalid;
                                  }

                                  return CustomTextField(
                                    controller: _confirmpasswordController,
                                    labelText: 'Confirm your password',
                                    isPassword: true,
                                    validator: _confirmPasswordValidator,
                                    validationState: validationState,
                                    onFieldSubmitted: (_) {
                                      if (_isFormValid.value && !isLoading) {
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
                    _buildNextButton(isLoading),
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
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _handleChangePassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: const Size(0, 40),
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
