// ignore_for_file: unused_field

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildTermsTextP.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

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

  bool _isPassFocused = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateForm);
    _passFocus.addListener(() {
      setState(() {
        _isPassFocused = _passFocus.hasFocus;
      });
    });
  }

  void _validateForm() {
    final passwordValid =
        _passwordController.text.trim().isNotEmpty &&
        _passwordController.text.length >= 8;
    _isFormValid.value = passwordValid;
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      print('Password: ${_passwordController.text}');
      context.goNamed(RouteConstants.uploadProfilePhotoScreen);
    }
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
                          'You\'ll need a password',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Make sure it\'s 8 characters or more.',
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
              _buildSignUpButton(isWeb),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 10),
      width: isWeb ? double.infinity : null,
      alignment: isWeb ? Alignment.center : Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return SizedBox(
            width: isWeb ? double.infinity : 120,
            child: ElevatedButton(
              onPressed: isValid ? _handleSignUp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: isWeb ? const Size(0, 60) : const Size(0, 38),
              ),
              child: const Text(
                'Sign up',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
