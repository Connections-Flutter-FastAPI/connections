import 'package:flutter/material.dart';
import 'theme_constants.dart';

ThemeData darkTheme() {
  return ThemeData(
    // Base colors
    primaryColor: ThemeConstants.primaryColor,
    scaffoldBackgroundColor: ThemeConstants.backgroundDarkest,
    canvasColor: ThemeConstants.backgroundDarkest,

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.backgroundDarkest,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.2),
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: ThemeConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
      ),
      color: ThemeConstants.backgroundDark,
      shadowColor: Colors.black.withOpacity(0.3),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding * 1.5,
          vertical: ThemeConstants.mediumPadding,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.textPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding,
          vertical: ThemeConstants.smallPadding,
        ),
      ),
    ),

    // Bottom nav theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ThemeConstants.backgroundDarker,
      selectedItemColor: ThemeConstants.primaryColor,
      unselectedItemColor: ThemeConstants.textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),

    // Input decoration theme (for text fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeConstants.backgroundDarker,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.mediumPadding,
        vertical: ThemeConstants.mediumPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: const BorderSide(color: ThemeConstants.errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: ThemeConstants.textSecondaryColor),
      hintStyle: const TextStyle(color: ThemeConstants.textTertiaryColor),
    ),

    // Chip theme
    chipTheme: const ChipThemeData(
      backgroundColor: ThemeConstants.backgroundDark,
      disabledColor: Color(0xFF424549),
      selectedColor: ThemeConstants.primaryColor,
      secondarySelectedColor: ThemeConstants.primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: TextStyle(color: ThemeConstants.textPrimaryColor),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
    ),

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.secondaryColor,
      error: ThemeConstants.errorColor,
      background: ThemeConstants.backgroundDarkest,
      surface: ThemeConstants.backgroundDark,
    ),

    // Text themes
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: ThemeConstants.textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ThemeConstants.textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ThemeConstants.textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ThemeConstants.textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: ThemeConstants.textSecondaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: ThemeConstants.textSecondaryColor,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: ThemeConstants.textSecondaryColor,
      size: 24,
    ),

    // Floating action button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
      splashColor: ThemeConstants.primaryColor.withOpacity(0.4),
      elevation: 4,
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3F4147),
      thickness: 1,
      space: 1,
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade900,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      ),
    ),

    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: ThemeConstants.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade700;
      }),
    ),
  );
}
