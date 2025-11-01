import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/providers/dobProvider.dart';
import 'package:lite_x/core/providers/emailProvider.dart';
import 'package:lite_x/core/providers/nameProvider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';
import 'dart:async';

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

  TextFieldValidationState _nameState = TextFieldValidationState.none;
  TextFieldValidationState _emailState = TextFieldValidationState.none;
  String? _emailErrorText;
  Timer? _emailDebounce;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateNameLocally);
    _emailController.addListener(_onEmailChanged);
    _dobController.addListener(_validateForm);
    _emailFocus.addListener(_onEmailFocusLost);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _dobController.text.trim().isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _validateNameLocally() {
    _validateForm();
    final name = _nameController.text.trim();
    final newState = name.isEmpty
        ? TextFieldValidationState.none
        : (nameValidator(name) == null
              ? TextFieldValidationState.valid
              : TextFieldValidationState.none);

    if (_nameState != newState) {
      setState(() => _nameState = newState);
    }
  }

  void _onEmailChanged() {
    _validateForm();

    if (_emailState != TextFieldValidationState.none) {
      setState(() {
        _emailState = TextFieldValidationState.none;
        _emailErrorText = null;
      });
    }

    _emailDebounce?.cancel();
    _emailDebounce = Timer(const Duration(milliseconds: 1000), () {
      if (emailValidator(_emailController.text.trim()) == null) {
        _performEmailCheck();
      }
    });
  }

  void _onEmailFocusLost() {
    if (!_emailFocus.hasFocus &&
        emailValidator(_emailController.text.trim()) == null) {
      _performEmailCheck();
    }
  }

  Future<void> _performEmailCheck() async {
    _emailDebounce?.cancel();
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _emailState = TextFieldValidationState.loading);

    final exists = await ref
        .read(authViewModelProvider.notifier)
        .validateEmail(email);

    if (!mounted) return;

    setState(() {
      if (exists == true) {
        _emailState = TextFieldValidationState.invalid;
        _emailErrorText = 'Email already exists';
      } else if (exists == false) {
        _emailState = TextFieldValidationState.valid;
        _emailErrorText = null;
      } else {
        _emailState = TextFieldValidationState.none;
      }
    });

    _formKey.currentState?.validate();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    ref
        .read(authViewModelProvider.notifier)
        .createAccount(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
        );
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

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Palette.primary,
              onPrimary: Palette.textWhite,
              surface: Palette.background,
              onSurface: Palette.textWhite,
            ),
            dialogBackgroundColor: Palette.background,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.type == AuthStateType.success) {
        ref
            .read(nameProvider.notifier)
            .update((_) => _nameController.text.trim());
        ref
            .read(emailProvider.notifier)
            .update((_) => _emailController.text.trim());
        ref
            .read(dobProvider.notifier)
            .update((_) => _dobController.text.trim());
        ref.read(authViewModelProvider.notifier).resetState();
        if (mounted) context.pushNamed(RouteConstants.verificationscreen);
      } else if (next.type == AuthStateType.error) {
        _showErrorToast(next.message ?? 'An error occurred');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) ref.read(authViewModelProvider.notifier).resetState();
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
                            validationState: _nameState,
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_emailFocus),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final formatError = emailValidator(value);
                              return formatError ?? _emailErrorText;
                            },
                            focusNode: _emailFocus,
                            validationState: _emailState,
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
      child: SizedBox(
        width: 90,
        child: ElevatedButton(
          onPressed: (_isFormValid && !isLoading) ? _handleNext : null,
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
      ),
    );
  }
}
