import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/auth/view_model/usecase/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';

//! Custom Text Form Field
class CustomTextFormField extends StatelessWidget with Validator {
  final String label;
  final String hintText;
  final Widget? prefIcon;
  final Widget? suffIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final bool? enabled;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefIcon,
    this.suffIcon,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: isMobile ? 14 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator:
              validator ??
              (String? value) {
                // infer common validators based on keyboardType or label
                final lowerLabel = label.toLowerCase();
                if (keyboardType == TextInputType.emailAddress ||
                    lowerLabel.contains('email')) {
                  return validateEmail(value);
                }
                if (lowerLabel.contains('password')) {
                  return validatePassword(value);
                }
                if (lowerLabel.contains('name')) {
                  return validateName(value);
                }
                if (lowerLabel.contains('Warehouse')) {
                  return validateWarehouse(value);
                }
                if (keyboardType == TextInputType.phone ||
                    lowerLabel.contains('phone')) {
                  return validatePhone(value);
                }
                return null;
              },
          enabled: enabled,
          onFieldSubmitted: onFieldSubmitted,
          style: GoogleFonts.openSans(fontSize: isMobile ? 16 : 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.openSans(
              color: AppColors.iconGrey,
              fontSize: isMobile ? 16 : 14,
            ),
            prefixIcon: prefIcon,
            suffixIcon: suffIcon,
            fillColor: AppColors.bgWiteShade,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderSideGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderSideGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderSideOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
