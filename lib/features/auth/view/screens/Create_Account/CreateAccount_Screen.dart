import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _dobController.addListener(_validateForm);
  }

  void _validateForm() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final emailValid = _emailController.text.trim().isNotEmpty;
    final dobValid = _dobController.text.trim().isNotEmpty;
    _isFormValid.value = nameValid && emailValid && dobValid;
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();

    ref
        .read(authViewModelProvider.notifier)
        .createAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
        );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Palette.textWhite),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final ThemeData datePickerTheme = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Palette.primary,
        onPrimary: Palette.textWhite,
        surface: Palette.background,
        onSurface: Palette.textWhite,
      ),
      dialogBackgroundColor: Palette.background,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: datePickerTheme, child: child!);
      },
    );

    if (picked != null && mounted) {
      _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _dobController.removeListener(_validateForm);
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
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
            .update((_) => _emailController.text.trim());
        authViewModel.resetState();
        if (mounted) {
          context.pushNamed(RouteConstants.verificationscreen);
        }
      } else if (next.type == AuthStateType.error) {
        _showErrorSnackBar(next.message ?? 'An error occurred');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            authViewModel.resetState();
          }
        });
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Palette.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Palette.textWhite),
              onPressed: isLoading ? null : () => context.pop(),
            ),
            title: buildXLogo(size: 36),
            centerTitle: true,
            backgroundColor: Palette.background,
            elevation: 0,
          ),
          body: AbsorbPointer(
            absorbing: isLoading,
            child: Center(
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
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create your account',
                                style: TextStyle(
                                  fontSize: 31,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.textWhite,
                                ),
                              ),
                              const SizedBox(height: 150),
                              CustomTextField(
                                controller: _nameController,
                                labelText: 'Name',
                                maxLength: 50,
                                validator: nameValidator,
                                focusNode: _nameFocus,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_emailFocus);
                                },
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: emailValidator,
                                focusNode: _emailFocus,
                              ),
                              const SizedBox(height: 25),
                              CustomTextField(
                                controller: _dobController,
                                labelText: 'Date of birth',
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: dobValidator,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildNextButton(isLoading),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Loader(),
          ),
      ],
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
            width: 90,
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _handleNext : null,
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
