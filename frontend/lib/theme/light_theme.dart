import 'package:flutter/material.dart';
import 'theme_constants.dart';

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: ThemeConstants.primaryColor,
    colorScheme: ColorScheme.light(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.accentColor,
      tertiary: ThemeConstants.highlightColor,
      background: Colors.grey.shade100,
      surface: Colors.white,
      error: ThemeConstants.errorColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.accentColor,
        foregroundColor: ThemeConstants.primaryColor,
        elevation: 2,
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
        foregroundColor: ThemeConstants.primaryColor,
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
        foregroundColor: ThemeConstants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
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
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      selectedColor: ThemeConstants.accentColor,
      disabledColor: Colors.grey.shade300,
      labelStyle: TextStyle(color: Colors.grey.shade800),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.smallPadding,
        vertical: ThemeConstants.smallPadding / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ThemeConstants.accentColor,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(
      color: Colors.grey.shade800,
      size: 24,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade900,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade800,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade800,
      ),
    ),
  );
}