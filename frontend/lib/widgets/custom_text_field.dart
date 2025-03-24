import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(
            left: ThemeConstants.smallPadding,
            bottom: ThemeConstants.smallPadding / 2
          ),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: ThemeConstants.bodyText,
              fontWeight: FontWeight.w600,
              color: isDark
                ? ThemeConstants.textSecondaryColor
                : Colors.grey.shade700,
            ),
          ),
        ),

        // Text Field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          style: TextStyle(
            color: isDark ? ThemeConstants.textPrimaryColor : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: ThemeConstants.mediumPadding,
              vertical: ThemeConstants.mediumPadding,
            ),
            fillColor: fillColor ?? (isDark
              ? ThemeConstants.backgroundDarker
              : Colors.grey.shade100),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              borderSide: const BorderSide(
                color: ThemeConstants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              borderSide: const BorderSide(
                color: ThemeConstants.errorColor,
                width: 2,
              ),
            ),
            hintStyle: TextStyle(
              color: isDark
                ? ThemeConstants.textTertiaryColor
                : Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }
}
