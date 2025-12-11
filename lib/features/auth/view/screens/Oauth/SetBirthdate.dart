import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/core/utils.dart';
import 'package:lite_x/core/view/widgets/Loader.dart';
import 'package:lite_x/features/auth/view/widgets/CustomTextField.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/auth/view_model/auth_state.dart';

class Setbirthdate extends ConsumerStatefulWidget {
  const Setbirthdate({super.key});

  @override
  ConsumerState<Setbirthdate> createState() => _SetbirthdateState();
}

class _SetbirthdateState extends ConsumerState<Setbirthdate> {
  final _dobController = TextEditingController();
  final _isFormValid = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    _dobController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _dobController.dispose();
    _isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _dobController.text.trim().isNotEmpty;
    _isFormValid.value = isValid;
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

  void _handleSignUp() {
    if (_dobController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    ref
        .read(authViewModelProvider.notifier)
        .Setbirthdate(birthDate: _dobController.text.trim());
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
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) async {
      if (next.type == AuthStateType.success) {
        context.goNamed(RouteConstants.UserNameScreen);
      } else if (next.type == AuthStateType.error) {
        _showErrorToast(next.message ?? 'An error occurred');
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Palette.background,
          appBar: AppBar(
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "What's your birth date?",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Palette.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "This won't be public.",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Palette.textWhite.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 32),
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
                _buildSignUpButton(isLoading),
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

  Widget _buildSignUpButton(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isFormValid,
        builder: (context, isValid, child) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, minHeight: 45),
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _handleSignUp : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),

                backgroundColor: Palette.textWhite,
                disabledBackgroundColor: Palette.textWhite.withOpacity(0.5),
                foregroundColor: Palette.background,
                disabledForegroundColor: Palette.border,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Palette.background,
                        ),
                      ),
                    )
                  : const Text(
                      'Sign up',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
