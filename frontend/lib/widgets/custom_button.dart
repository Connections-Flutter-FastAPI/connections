import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool disabled;

  const CustomButton({
    Key? key,
    this.backgroundColor,
    this.foregroundColor,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine padding based on size
    final EdgeInsets padding;
    switch (size) {
      case ButtonSize.small:
        padding = const EdgeInsets.symmetric(
          horizontal: ThemeConstants.smallPadding,
          vertical: 6,
        );
        break;
      case ButtonSize.large:
        padding = const EdgeInsets.symmetric(
          horizontal: ThemeConstants.largePadding,
          vertical: 14,
        );
        break;
      case ButtonSize.medium:
      default:
        padding = const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding,
          vertical: 10,
        );
        break;
    }

    // Determine font size based on size
    final double fontSize;
    switch (size) {
      case ButtonSize.small:
        fontSize = ThemeConstants.smallText;
        break;
      case ButtonSize.large:
        fontSize = ThemeConstants.subtitleText;
        break;
      case ButtonSize.medium:
      default:
        fontSize = ThemeConstants.bodyText;
        break;
    }

    // Determine button style based on type
    Widget button;
    switch (type) {
      case ButtonType.secondary:
        button = _buildSecondaryButton(isDark, padding, fontSize);
        break;
      case ButtonType.outline:
        button = _buildOutlineButton(isDark, padding, fontSize);
        break;
      case ButtonType.text:
        button = _buildTextButton(isDark, padding, fontSize);
        break;
      case ButtonType.primary:
      default:
        button = _buildPrimaryButton(isDark, padding, fontSize);
        break;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }

  Widget _buildPrimaryButton(bool isDark, EdgeInsets padding, double fontSize) {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.accentColor,
        foregroundColor: ThemeConstants.primaryColor,
        disabledForegroundColor: Colors.grey.shade400,
        disabledBackgroundColor: Colors.grey.shade300,
        elevation: disabled ? 0 : 2,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
      ),
      child: _buildButtonContent(fontSize, ThemeConstants.primaryColor),
    );
  }

  Widget _buildSecondaryButton(bool isDark, EdgeInsets padding, double fontSize) {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade200,
        foregroundColor: isDark ? Colors.white : ThemeConstants.primaryColor,
        disabledForegroundColor: Colors.grey.shade400,
        disabledBackgroundColor: Colors.grey.shade300,
        elevation: disabled ? 0 : 1,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
      ),
      child: _buildButtonContent(fontSize, isDark ? Colors.white : ThemeConstants.primaryColor),
    );
  }

  Widget _buildOutlineButton(bool isDark, EdgeInsets padding, double fontSize) {
    return OutlinedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConstants.accentColor,
        side: BorderSide(
          color: disabled ? Colors.grey.shade400 : ThemeConstants.accentColor,
          width: 2,
        ),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
      ),
      child: _buildButtonContent(fontSize, ThemeConstants.accentColor),
    );
  }

  Widget _buildTextButton(bool isDark, EdgeInsets padding, double fontSize) {
    return TextButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.accentColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
      ),
      child: _buildButtonContent(fontSize, ThemeConstants.accentColor),
    );
  }

  Widget _buildButtonContent(double fontSize, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
