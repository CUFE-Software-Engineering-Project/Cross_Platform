import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/providers/signup_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

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
    if (_formKey.currentState!.validate()) {
      ref.read(emailProvider.notifier).update((_) => _emailController.text);
      context.pushNamed(RouteConstants.verificationscreen);
    }
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
    final isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: isWeb
          ? Colors.black.withOpacity(0.4)
          : Palette.background,
      appBar: !isWeb
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Palette.textWhite),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                            FocusScope.of(context).requestFocus(_emailFocus);
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
              _buildNextButton(isWeb),
              const SizedBox(height: 15),
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
            width: isWeb ? double.infinity : 90,
            child: ElevatedButton(
              onPressed: isValid ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
                minimumSize: isWeb ? const Size(0, 60) : const Size(0, 40),
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
