// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const _buildWebLayout();
        } else {
          return const _buildMobileLayout();
        }
      },
    );
  }
}

class _buildMobileLayout extends StatelessWidget {
  const _buildMobileLayout();

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
      body: const _AccountForm(isWeb: false),
    );
  }
}

class _buildWebLayout extends StatelessWidget {
  const _buildWebLayout();

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
              const Expanded(child: _AccountForm(isWeb: true)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountForm extends StatefulWidget {
  final bool isWeb;
  const _AccountForm({required this.isWeb});

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  final FocusNode namefocus = FocusNode();
  final FocusNode emailfocus = FocusNode();

  bool isnamefocused = false;
  bool isemailfocused = false;

  final _isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _dobController.addListener(_validateForm);
    namefocus.addListener(() {
      setState(() {
        isnamefocused = namefocus.hasFocus;
      });
    });
    emailfocus.addListener(() {
      setState(() {
        isemailfocused = emailfocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _dobController.removeListener(_validateForm);
    namefocus.dispose();
    emailfocus.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final emailValid = _emailController.text.trim().isNotEmpty;
    final dobValid = _dobController.text.trim().isNotEmpty;
    _isFormValid.value = nameValid && emailValid && dobValid;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('DOB: ${_dobController.text}');
      context.pushNamed(RouteConstants.verificationscreen);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
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

    if (picked != null) {
      setState(() {
        var selectedDate = picked;
        _dobController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
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
                    focusNode: namefocus,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(emailfocus);
                    },
                  ),
                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                    focusNode: emailfocus,
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
