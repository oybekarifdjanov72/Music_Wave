import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.inputFormatters,
    this.validator,
    this.labelText,
  });
  final String? labelText;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    const textColor = AppColors.textPrimary;
    final borderColor = AppColors.instance.white.withValues(alpha: 0.2);
    final fillColor = AppColors.instance.shadeblack;

    return TextFormField(
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      keyboardType: widget.isPassword ? TextInputType.text : TextInputType.emailAddress,
      controller: widget.controller,
      obscureText: widget.isPassword && !isVisible,
      style: GoogleFonts.workSans(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: GoogleFonts.workSans(
          color: textColor.withValues(alpha: 0.7),
          fontSize: 16,
        ),
        hintText: widget.hintText,
        hintStyle: GoogleFonts.workSans(
          color: textColor.withValues(alpha: 0.4),
          fontSize: 16,
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: textColor.withValues(alpha: 0.7),
                size: 22,
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: textColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cyanAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
