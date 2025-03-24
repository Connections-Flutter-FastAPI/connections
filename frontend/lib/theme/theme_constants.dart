import 'package:flutter/material.dart';

class ThemeConstants {
  // Paddings
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border Radius
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 24.0;

  // Font Sizes
  static const double smallText = 12.0;
  static const double bodyText = 14.0;
  static const double titleText = 18.0;
  static const double headingText = 22.0;
  static const double largeHeadingText = 28.0;

  // Colors
  static const Color primaryColor = Color(0xFF5865F2); // Discord-like blue
  static const Color secondaryColor = Color(0xFF57F287); // Discord green
  static const Color tertiaryColor = Color(0xFFFEE75C); // Discord yellow
  static const Color errorColor = Color(0xFFED4245); // Discord red
  static const Color warningColor = Color(0xFFFAA61A); // Discord orange
  static const Color successColor = Color(0xFF57F287); // Discord green

  // Text Colors
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB9BBBE);
  static const Color textTertiaryColor = Color(0xFF72767D);

  // Background Colors
  static const Color backgroundDark = Color(0xFF36393F); // Discord dark
  static const Color backgroundDarker = Color(0xFF2F3136); // Discord sidebar
  static const Color backgroundDarkest = Color(0xFF202225); // Discord channels

  // Reddit-like colors
  static const Color redditOrange = Color(0xFFFF4500);
  static const Color redditBlue = Color(0xFF0079D3);

  // Twitter-like colors
  static const Color twitterBlue = Color(0xFF1DA1F2);
  static const Color twitterDarkBlue = Color(0xFF15202B);

  // Card Colors for Communities
  static const List<Color> communityColors = [
    Color(0xFFFF7597), // Pink
    Color(0xFF7289DA), // Discord Blurple
    Color(0xFFFF5700), // Reddit Orange
    Color(0xFF43B581), // Discord Green
    Color(0xFFFAA61A), // Discord Gold
    Color(0xFF1DA1F2), // Twitter Blue
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Elevation
  static const double cardElevation = 3.0;
  static const double modalElevation = 10.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}
