import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

OutlineInputBorder border_sign(Color co, double w) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(5),
  borderSide: BorderSide(color: co, width: w),
);

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final bool isPassword;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    this.maxLength,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.isPassword = false,
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
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
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
        filled: true,
        fillColor: Palette.overlay,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Palette.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
