import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

enum ButtonType { primary, secondary, text, outline }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconLeading;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconLeading = true,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button properties based on type and size
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Size settings
    final double buttonHeight;
    final double fontSize;
    final double buttonPadding;
    final double buttonIconSize;

    switch (size) {
      case ButtonSize.small:
        buttonHeight = 36;
        fontSize = ThemeConstants.smallText;
        buttonPadding = ThemeConstants.smallPadding;
        buttonIconSize = 18;
        break;
      case ButtonSize.large:
        buttonHeight = 56;
        fontSize = ThemeConstants.titleText;
        buttonPadding = ThemeConstants.largePadding;
        buttonIconSize = 26;
        break;
      case ButtonSize.medium:
      default:
        buttonHeight = 48;
        fontSize = ThemeConstants.bodyText;
        buttonPadding = ThemeConstants.mediumPadding;
        buttonIconSize = 22;
        break;
    }

    // Type settings
    final Color bgColor;
    final Color txtColor;
    final Border? border;

    switch (type) {
      case ButtonType.secondary:
        bgColor = backgroundColor ?? (isDark
          ? ThemeConstants.backgroundDarker
          : Colors.grey.shade200);
        txtColor = textColor ?? ThemeConstants.primaryColor;
        border = null;
        break;
      case ButtonType.text:
        bgColor = Colors.transparent;
        txtColor = textColor ?? ThemeConstants.primaryColor;
        border = null;
        break;
      case ButtonType.outline:
        bgColor = Colors.transparent;
        txtColor = textColor ?? (isDark
          ? ThemeConstants.textPrimaryColor
          : ThemeConstants.primaryColor);
        border = Border.all(
          color: txtColor.withOpacity(0.5),
          width: 1.5,
        );
        break;
      case ButtonType.primary:
      default:
        bgColor = backgroundColor ?? ThemeConstants.primaryColor;
        txtColor = textColor ?? Colors.white;
        border = null;
        break;
    }

    // Create the content
    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && iconLeading) Icon(
          icon,
          size: iconSize ?? buttonIconSize,
          color: txtColor,
        ),
        if (icon != null && iconLeading) SizedBox(width: buttonPadding / 2),

        Text(
          text,
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),

        if (icon != null && !iconLeading) SizedBox(width: buttonPadding / 2),
        if (icon != null && !iconLeading) Icon(
          icon,
          size: iconSize ?? buttonIconSize,
          color: txtColor,
        ),
      ],
    );

    // Loading state
    if (isLoading) {
      content = Center(
        child: SizedBox(
          height: buttonIconSize,
          width: buttonIconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(txtColor),
          ),
        ),
      );
    }

    // Create the button with ink effect
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: borderRadius ?? BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius ?? BorderRadius.circular(ThemeConstants.buttonBorderRadius),
            border: border,
          ),
          height: buttonHeight,
          child: Container(
            padding: padding ?? EdgeInsets.symmetric(horizontal: buttonPadding),
            child: content,
          ),
        ),
      ),
    );
  }
}
