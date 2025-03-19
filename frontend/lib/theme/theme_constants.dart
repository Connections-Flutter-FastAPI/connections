// lib/theme/theme_constants.dart
import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors (Prioritizing your friend's colors, but keeping your structure)
  static const Color primaryColor = Color(0xFF1E88E5); // Blue (from friend's code)
  static const Color secondaryColor = Color(0xFF42A5F5); // Light Blue (from friend's code)
  static const Color accentColor = Color(0xFFFFC107); // Example: Amber (keep your accent)
  static const Color backgroundColorLight = Color(0xFFF5F5F5); // Light Gray (from friend's code)
  static const Color backgroundColorDark = Color(0xFF121212); // Dark Gray (keep your dark mode color)
  static const Color textColorLight = Color(0xFF212121); // Dark Gray
  static const Color textColorDark = Color(0xFFFFFFFF); // White
  static const Color cardColorLight = Color(0xFFF5F5F5); // Light Gray
  static const Color cardColorDark = Color(0xFF1E1E1E);  // Darker Gray
  static const Color errorColor = Color(0xFFB00020); // Keep your error color
  static const Color successColor = Color(0xFF4CAF50); // Keep your success

  // Font Families
  static const String fontFamily = 'Roboto'; // Or any other font you prefer

  // Spacing (use multiples of 4 or 8 for consistency)
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double borderRadius = 12.0; // Slightly increased for a more modern look

  // Other constants as needed (e.g., button heights, icon sizes)
}
