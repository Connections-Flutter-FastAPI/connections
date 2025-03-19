// lib/theme/dark_theme.dart
import 'package:flutter/material.dart';
import 'theme_constants.dart';

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: ThemeConstants.primaryColor, // Keep primary color consistent
    scaffoldBackgroundColor: ThemeConstants.backgroundColorDark,
    fontFamily: ThemeConstants.fontFamily,
    cardColor: ThemeConstants.cardColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.mediumPadding,
            vertical: ThemeConstants.smallPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: ThemeConstants.primaryColor // Keep primary interaction color
      )
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: const BorderSide(color: ThemeConstants.secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        borderSide: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: ThemeConstants.textColorDark),
      errorStyle: const TextStyle(color: ThemeConstants.errorColor),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ThemeConstants.textColorDark),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ThemeConstants.textColorDark),
      displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.textColorDark),
      bodyLarge: TextStyle(fontSize: 16, color: ThemeConstants.textColorDark),
      bodyMedium: TextStyle(fontSize: 14, color: ThemeConstants.textColorDark),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ThemeConstants.textColorDark)
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: ThemeConstants.accentColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: ThemeConstants.backgroundColorDark
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: ThemeConstants.backgroundColorDark, // Set background color
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: Colors.white
    ),
    dialogTheme: DialogTheme(
      backgroundColor: ThemeConstants.backgroundColorDark, // Set background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius), // Rounded corners
      ),
      titleTextStyle: const TextStyle(color: ThemeConstants.textColorDark, fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: ThemeConstants.textColorDark, fontSize: 16),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: ThemeConstants.primaryColor,
    ),
      iconTheme: const IconThemeData(
      color: ThemeConstants.primaryColor,
    )
  );
}
