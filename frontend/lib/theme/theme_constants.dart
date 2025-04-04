import 'package:flutter/material.dart';

class ThemeConstants {
  // Color Palette
  static const Color primaryColor = Color(0xFF1B1F3B); // Midnight Blue
  static const Color accentColor = Color(0xFF00FFFF); // Cyan
  static const Color highlightColor = Color(0xFFFFDD44); // Yellow
  static const Color backgroundDark = Color(0xFF121426);
  static const Color backgroundDarker = Color(0xFF0A0C18);
  static const Color backgroundDarkest = Color(0xFF050714);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);

  // Spacing constants
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 20.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Font sizes
  static const double headingText = 24.0;
  static const double subtitleText = 18.0;
  static const double bodyText = 16.0;
  static const double smallText = 14.0;
  static const double microText = 12.0;

  // Community colors for consistent assignment
  static const List<Color> communityColors = [
    Color(0xFF5865F2), // Discord blue
    Color(0xFFED4245), // Red
    Color(0xFF57F287), // Green
    Color(0xFFFEE75C), // Yellow
    Color(0xFFEB459E), // Pink
    Color(0xFF00FFFF), // Cyan
    Color(0xFFFF7F50), // Coral
    Color(0xFF9B59B6), // Purple
  ];

  // Custom effects
  static List<BoxShadow> glowEffect(Color color, {double radius = 8.0, double opacity = 0.4}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: radius,
        spreadRadius: radius / 4,
      ),
    ];
  }

  static List<BoxShadow> softShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

// lib/utils/colors.dart
//import 'package:flutter/material.dart';

const Color kDeepMidnightBlue = Color(0xFF1B1F3B);
const Color kCyan = Color(0xFF00FFFF);
const Color kHighlightYellow = Color(0xFFFFDD44);
const Color kLightText = Colors.white; // For contrast on dark background
const Color kSubtleGray = Colors.white38; // For less important elements
