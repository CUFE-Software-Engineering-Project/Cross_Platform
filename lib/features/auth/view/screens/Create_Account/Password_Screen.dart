import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildTermsTextP.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passFocus = FocusNode();
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final passwordValid =
        _passwordController.text.trim().isNotEmpty &&
        _passwordController.text.length >= 9;
    _isFormValid.value = passwordValid;
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;
    final email = ref.read(emailProvider);
    final password = _passwordController.text.trim();
    ref
        .read(authViewModelProvider.notifier)
        .finalizeSignup(email: email, password: password);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passFocus.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.type == AuthStateType.authenticated) {
        context.goNamed(RouteConstants.uploadProfilePhotoScreen);
      } else if (next.type == AuthStateType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.message ?? 'Signup failed',
              style: TextStyle(color: Palette.background),
            ),
            backgroundColor: Palette.textWhite,
          ),
        );
        ref.read(authViewModelProvider.notifier).resetState();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Palette.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: AbsorbPointer(
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
                                  'You\'ll need a password',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Palette.textWhite,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Make sure it\'s 9 characters or more.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.greycolor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _passwordController,
                                  focusNode: _passFocus,
                                  labelText: 'Password',
                                  isPassword: true,
                                  validator: passwordValidator,
                                  onFieldSubmitted: (_) {
                                    if (_isFormValid.value) {
                                      _handleSignUp();
                                    }
                                  },
                                ),
                                const SizedBox(height: 70),
                                buildTermsTextP(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildSignUpButton(isLoading),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: Loader()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, minHeight: 45),
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _handleSignUp : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Palette.background,
                        ),
                      ),
                    )
                  : const Text(
                      'Sign up',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
