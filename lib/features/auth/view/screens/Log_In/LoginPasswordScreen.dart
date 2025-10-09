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

class LoginPasswordScreen extends ConsumerStatefulWidget {
  const LoginPasswordScreen({super.key});

  @override
  ConsumerState<LoginPasswordScreen> createState() =>
      _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends ConsumerState<LoginPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passFocus = FocusNode();
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    final email = ref.read(emailProvider);
    _emailController.text = email;

    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final passwordValid =
        _passwordController.text.trim().isNotEmpty &&
        _passwordController.text.length >= 8;
    _isFormValid.value = passwordValid;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      // context.goNamed(RouteConstants.home);
    }
  }

  void _handleForgotPassword() {
    ref.read(emailProvider.notifier).update((_) => _emailController.text);
    context.pushNamed(RouteConstants.ForgotpasswordScreen);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validateForm);
    _passwordController.dispose();
    _emailController.dispose();
    _passFocus.dispose();
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
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter your password',
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w800,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _emailController,

                          readOnly: true,
                          enabled: false,
                        ),
                        const SizedBox(height: 38),
                        CustomTextField(
                          controller: _passwordController,
                          focusNode: _passFocus,
                          labelText: 'Password',
                          isPassword: true,
                          validator: passwordValidator,
                          onFieldSubmitted: (_) {
                            if (_isFormValid.value) {
                              _handleLogin();
                            }
                          },
                        ),
                      ],
                    ),
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

  Widget _buildBottomButtons(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: _handleForgotPassword,
            style: OutlinedButton.styleFrom(
              foregroundColor: Palette.textWhite,
              side: const BorderSide(color: Palette.textWhite, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Forgot password?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isFormValid,
            builder: (context, isValid, child) {
              return SizedBox(
                width: isWeb ? 120 : 80,
                child: ElevatedButton(
                  onPressed: isValid ? _handleLogin : null,
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
                    'Log in',
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
