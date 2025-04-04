import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.contentPadding,
    this.filled = true,
    this.fillColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor: fillColor ??
            (isDark
                ? ThemeConstants.backgroundDarker
                : Colors.grey.shade100),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: ThemeConstants.mediumPadding,
              vertical: ThemeConstants.smallPadding,
            ),
        border: OutlineInputBorder(
          borderRadius: borderRadius ??
              BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ??
              BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ??
              BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius ??
              BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius ??
              BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        prefixIconConstraints: prefixIconConstraints,
        suffixIconConstraints: suffixIconConstraints,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade700,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.grey.shade500,
        ),
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
        helperStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
    );
  }
}
