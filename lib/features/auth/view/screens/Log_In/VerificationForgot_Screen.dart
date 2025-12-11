import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';

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
  late String email;

  @override
  void initState() {
    super.initState();
    email = ref.read(emailProvider);
    _codeController.addListener(_validateForm);
  }

  void _validateForm() {
    _isFormValid.value = _codeController.text.trim().isNotEmpty;
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    ref
        .read(authViewModelProvider.notifier)
        .verifyResetCode(email: email, code: _codeController.text.trim());
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Palette.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Palette.greycolor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.15,
          vertical: MediaQuery.of(context).size.height * 0.4,
        ),
        duration: const Duration(seconds: 3),
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

      if (next.type == AuthStateType.awaitingPassword) {
        context.goNamed(RouteConstants.ChooseNewPasswordScreen);
        authViewModel.resetState();
      } else if (next.type == AuthStateType.error) {
        _showErrorToast(next.message ?? 'Invalid verification code');
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
                decoration: const BoxDecoration(color: Palette.background),
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
                                validator: verificationCodeValidator,
                                controller: _codeController,
                                labelText: 'Enter your code',
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (_) {
                                  if (_isFormValid.value && !isLoading) {
                                    _handleNext();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomButtons(isLoading),
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

  Widget _buildBottomButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.textWhite,
                side: const BorderSide(color: Palette.textWhite, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Back',
                softWrap: false,
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: _isFormValid,
            builder: (context, isValid, child) {
              return SizedBox(
                width: 100,
                height: 45,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ElevatedButton(
                    onPressed: (isValid && !isLoading) ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      backgroundColor: Palette.textWhite,
                      disabledBackgroundColor: Palette.textWhite.withOpacity(
                        0.6,
                      ),
                      foregroundColor: Palette.background,
                      disabledForegroundColor: Palette.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
