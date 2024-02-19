import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String helperText;
  final String? errorText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autoFocus;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FormFieldValidator<String>? validator;
  final ValueChanged<bool>? onSuffixTap;
  // suffix icon
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.autoFocus = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.onSuffixTap,
    this.helperText = '',
    this.suffixIcon,
    this.prefixIcon,
    this.errorText = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Col.greyColor,
          fontWeight: FontWeight.normal,
        ),
        errorText: errorText,
        helperStyle: const TextStyle(
          color: Col.greyColor,
          fontStyle: FontStyle.italic,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofocus: autoFocus,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
    );
  }
}
