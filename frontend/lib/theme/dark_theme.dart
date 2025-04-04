import 'package:flutter/material.dart';
import 'theme_constants.dart';

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: ThemeConstants.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.accentColor,
      tertiary: ThemeConstants.highlightColor,
      background: ThemeConstants.backgroundDark,
      surface: ThemeConstants.backgroundDarker,
      error: ThemeConstants.errorColor,
    ),
    scaffoldBackgroundColor: ThemeConstants.backgroundDarkest,
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: ThemeConstants.backgroundDarker,
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.accentColor,
        foregroundColor: ThemeConstants.primaryColor,
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding,
          vertical: ThemeConstants.smallPadding,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConstants.accentColor,
        side: const BorderSide(color: ThemeConstants.accentColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding,
          vertical: ThemeConstants.smallPadding,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeConstants.backgroundDarker,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: const BorderSide(color: ThemeConstants.accentColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(ThemeConstants.mediumPadding),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.accentColor,
      foregroundColor: ThemeConstants.primaryColor,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ThemeConstants.backgroundDarker,
      selectedColor: ThemeConstants.accentColor,
      disabledColor: Colors.grey.shade800,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: ThemeConstants.primaryColor),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.smallPadding,
        vertical: ThemeConstants.smallPadding / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ThemeConstants.backgroundDarker,
      selectedItemColor: ThemeConstants.accentColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white12,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  );
}