import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';

OutlineInputBorder border_sign(Color co, double w) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(5),
  borderSide: BorderSide(color: co, width: w),
);

enum TextFieldValidationState { none, loading, valid, invalid }

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool? enabled;
  final bool isPassword;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? isPasswordCheck;
  final TextFieldValidationState validationState;
  final String? validationErrorText;
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.maxLength,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.enabled = true,
    this.onChanged,
    this.isPassword = false,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPasswordCheck,
    this.validationState = TextFieldValidationState.none,
    this.validationErrorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      validator: (value) {
        if (widget.validationState == TextFieldValidationState.invalid &&
            widget.validationErrorText != null) {
          return widget.validationErrorText;
        }
        return widget.validator?.call(value);
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      obscureText: widget.isPassword ? _obscureText : false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Palette.textWhite, fontSize: 18),
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelStyle: const TextStyle(
          color: Palette.primary,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(color: Palette.textSecondary, fontSize: 16),
        enabledBorder: border_sign(Palette.textSecondary, 1),
        focusedBorder: border_sign(Palette.primary, 2),
        errorBorder: border_sign(Palette.error, 1),
        focusedErrorBorder: border_sign(Palette.error, 2),
        disabledBorder: border_sign(Palette.textSecondary, 1),
        filled: true,
        fillColor: Palette.overlay,
        prefixText: widget.prefixText,
        prefixIcon: widget.prefixIcon,

        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildValidationSuffix(),
            if (widget.isPassword)
              IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Palette.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSuffix() {
    switch (widget.validationState) {
      case TextFieldValidationState.loading:
        return Container(
          margin: const EdgeInsets.only(right: 10),
          width: 20,
          height: 20,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Palette.primary,
          ),
        );
      case TextFieldValidationState.valid:
        return Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: const BoxDecoration(
            color: Palette.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.black, size: 20),
        );
      case TextFieldValidationState.invalid:
        return Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: const BoxDecoration(
            color: Palette.error,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error, color: Colors.black, size: 18),
        );
      case TextFieldValidationState.none:
        return const SizedBox.shrink();
    }
  }
}
