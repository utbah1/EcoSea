import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController? controller;

  // tambahan untuk validasi & UX
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const InputField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

        // border normal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff90E0EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff90E0EF)),
        ),

        // border saat fokus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff0077B6), width: 1.6),
        ),

        // border saat error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),

        // error text lebih rapi
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}