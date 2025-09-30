import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/signup_provider.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const _BuildWebLayout();
        } else {
          return const _BuildMobileLayout();
        }
      },
    );
  }
}

class _BuildMobileLayout extends StatelessWidget {
  const _BuildMobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.textWhite),
          onPressed: () => context.pop(),
        ),
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      backgroundColor: Palette.background,
      body: const _VerificationForm(isWeb: false),
    );
  }
}

class _BuildWebLayout extends StatelessWidget {
  const _BuildWebLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Center(
        child: Container(
          width: 600,
          height: 650,
          decoration: BoxDecoration(
            color: Palette.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Palette.textWhite),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(child: Center(child: buildXLogo(size: 32))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Expanded(child: _VerificationForm(isWeb: true)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationForm extends ConsumerStatefulWidget {
  final bool isWeb;
  const _VerificationForm({required this.isWeb});

  @override
  ConsumerState<_VerificationForm> createState() => _VerificationFormState();
}

class _VerificationFormState extends ConsumerState<_VerificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final FocusNode codefocus = FocusNode();

  bool iscodefocused = false;
  final _isFormValid = ValueNotifier<bool>(false);
  late String email;

  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
    _codeController.addListener(_validateForm);
    codefocus.addListener(() {
      setState(() {
        iscodefocused = codefocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _codeController.removeListener(_validateForm);
    codefocus.dispose();
    _codeController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    final codeValid = _codeController.text.trim().isNotEmpty;
    _isFormValid.value = codeValid;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      print('Verification code: ${_codeController.text}');
      print('Email: $email');
    }
  }

  void _resendCode() {
    print('Resending verification code to: $email');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code sent!'),
        backgroundColor: Palette.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We sent you a code',
                    style: TextStyle(
                      fontSize: 31,
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
                    focusNode: codefocus,
                    onFieldSubmitted: (_) {
                      if (_isFormValid.value) {
                        _handleNext();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _resendCode,
                    child: const Text(
                      'Didn\'t receive an email?',
                      style: TextStyle(fontSize: 15, color: Palette.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildNextButton(widget.isWeb),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 12),
      width: isWeb ? double.infinity : null,
      alignment: isWeb ? Alignment.center : Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return SizedBox(
            width: isWeb ? double.infinity : 85,
            child: ElevatedButton(
              onPressed: isValid ? _handleNext : null,
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
