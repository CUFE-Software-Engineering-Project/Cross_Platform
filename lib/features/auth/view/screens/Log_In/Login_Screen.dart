import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiercontroller = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _identifiercontroller.addListener(_validateForm);
  }

  void _validateForm() {
    _isFormValid.value = _identifiercontroller.text.trim().isNotEmpty;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(emailProvider.notifier)
          .update((_) => _identifiercontroller.text);
      print('Login identifier: ${_identifiercontroller.text}');
      context.goNamed(RouteConstants.LoginPasswordScreen);
    }
  }

  void _handleForgotPassword() {
    print('Forgot password clicked');

    context.pushNamed(RouteConstants.ForgotpasswordScreen);
  }

  @override
  void dispose() {
    _identifiercontroller.removeListener(_validateForm);
    _identifiercontroller.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Palette.textWhite),
          onPressed: () => context.pop(),
        ),
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: Center(
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
                      horizontal: 25,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'To get started, first enter your phone, email address or @username',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _identifiercontroller,
                          labelText: 'Phone, email address, or username',
                          keyboardType: TextInputType.emailAddress,
                          validator: emailValidator,
                          onFieldSubmitted: (_) {
                            if (_isFormValid.value) {
                              _handleNext();
                            }
                          },
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
