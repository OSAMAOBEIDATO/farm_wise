import 'package:farm_wise/comman/consta.dart';
import 'package:flutter/material.dart';

class ReusableTextField extends StatefulWidget {
  const ReusableTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isPasswordField = false,
  });

  final String hintText;
  final TextEditingController controller;
  final bool isPasswordField;
  final IconData prefixIcon;
  final TextInputType keyboardType;

  @override
  State<ReusableTextField> createState() => _ReusableTextFieldState();
}

class _ReusableTextFieldState extends State<ReusableTextField> {
  bool _isPasswordVisible = true; // Default to hidden (obscured) for password fields

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPasswordField ? _isPasswordVisible : false, // Only obscure text for password fields
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.prefixIcon,
          color: Colors.green[500],
        ),
        hintText: widget.hintText,
        hintStyle: KTextStyle,
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: widget.isPasswordField
            ? IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: _isPasswordVisible
              ? const Icon(Icons.visibility_off)
              : const Icon(Icons.visibility),
        )
            : null, // Show suffixIcon only for password fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}