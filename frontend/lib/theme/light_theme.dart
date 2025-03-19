// lib/theme/light_theme.dart
import 'package:flutter/material.dart';
import 'theme_constants.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: ThemeConstants.primaryColor,
    scaffoldBackgroundColor: ThemeConstants.backgroundColorLight,
    fontFamily: ThemeConstants.fontFamily,
    cardColor: ThemeConstants.cardColorLight, // Use the card color
    appBarTheme: const AppBarTheme(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white, // Text color on App Bar
      elevation: 2, // Shadow
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
          foregroundColor: ThemeConstants.primaryColor, // Text Color for TextButton
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
      labelStyle: const TextStyle(color: ThemeConstants.textColorLight),
      errorStyle: const TextStyle(color: ThemeConstants.errorColor),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ThemeConstants.textColorLight),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ThemeConstants.textColorLight),
      displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.textColorLight),
      bodyLarge: TextStyle(fontSize: 16, color: ThemeConstants.textColorLight),
      bodyMedium: TextStyle(fontSize: 14, color: ThemeConstants.textColorLight),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ThemeConstants.textColorLight)

    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: ThemeConstants.accentColor,
        unselectedItemColor: ThemeConstants.secondaryColor,
        backgroundColor: ThemeConstants.backgroundColorLight
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ThemeConstants.secondaryColor,
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: Colors.white
    ),
      dialogTheme: DialogTheme(
        backgroundColor: ThemeConstants.backgroundColorLight, // Set background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius), // Rounded corners
        ),
        titleTextStyle: const TextStyle(color: ThemeConstants.textColorLight, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: ThemeConstants.textColorLight, fontSize: 16),
      ),
    listTileTheme: const ListTileThemeData(
      iconColor: ThemeConstants.primaryColor, // Color for icons
    ),
    iconTheme: const IconThemeData(
      color: ThemeConstants.primaryColor, // Default icon color
    ),
  );
}
