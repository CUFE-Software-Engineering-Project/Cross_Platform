import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class ForgotpasswordScreen extends ConsumerStatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends ConsumerState<ForgotpasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiercontroller = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);
  late String email;
  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
    _identifiercontroller.text = email;
    _identifiercontroller.addListener(_validateForm);
    _validateForm();
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
      context.pushNamed(RouteConstants.ConfirmationCodeLocScreen);
    }
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
    final isWeb = kIsWeb;
    return Scaffold(
      backgroundColor: isWeb
          ? Colors.black.withOpacity(0.4)
          : Palette.background,
      appBar: !isWeb
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close, color: Palette.textWhite),
                onPressed: () => context.pop(),
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
                        onPressed: () => context.pop(),
                      ),
                      Expanded(child: Center(child: buildXLogo(size: 40))),
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
                          'Find your X account',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter the email, phone number or username associated with your account to change your password.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _identifiercontroller,
                          labelText: 'Email address, phone number or username',
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
            width: isWeb ? 120 : 80,
            child: ElevatedButton(
              onPressed: isValid ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: const Size(0, 30),
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
    );
  }
}
