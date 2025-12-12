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
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    ref
        .read(authViewModelProvider.notifier)
        .checkEmail(email: _identifiercontroller.text.trim());
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
    _identifiercontroller.removeListener(_validateForm);
    _identifiercontroller.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      final authViewModel = ref.read(authViewModelProvider.notifier);

      if (next.type == AuthStateType.success) {
        ref
            .read(emailProvider.notifier)
            .update((_) => _identifiercontroller.text.trim());
        context.pushNamed(RouteConstants.ConfirmationCodeLocScreen);
        authViewModel.resetState();
      } else if (next.type == AuthStateType.error) {
        _showErrorToast(next.message ?? 'Account not found');
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
          onPressed: isLoading ? null : () => context.pop(),
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
                              const Text(
                                'Enter the email associated with your account to change your password.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Palette.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                controller: _identifiercontroller,
                                labelText: 'Email address',
                                keyboardType: TextInputType.emailAddress,
                                validator: emailValidator,
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
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 90, minHeight: 45),
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.6),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Next',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
