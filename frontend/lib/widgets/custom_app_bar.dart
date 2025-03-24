import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_constants.dart';
import '../main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool isTransparent;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.showLogo = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
    this.backgroundColor,
    this.isTransparent = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? kToolbarHeight + 56 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.getTheme().brightness == Brightness.dark;

    // Default background color
    final bgColor = backgroundColor ?? (isTransparent
      ? Colors.transparent
      : (isDark ? ThemeConstants.backgroundDarkest : ThemeConstants.primaryColor));

    // Title Widget - either simple text or logo with text
    Widget titleWidget;
    if (showLogo) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      );
    } else {
      titleWidget = Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    }

    // Default Actions (if none provided)
    final actionButtons = actions ?? [
      // Theme Toggle Button
      IconButton(
        icon: Icon(
          themeNotifier.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          color: Colors.white,
        ),
        onPressed: () => themeNotifier.toggleTheme(),
      ),
    ];

    // Back button or custom leading widget
    Widget? leadingWidget;
    if (showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    } else if (leading != null) {
      leadingWidget = leading;
    }

    return AppBar(
      title: titleWidget,
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      elevation: elevation,
      leading: leadingWidget,
      actions: actionButtons,
      bottom: bottom,
      shape: isTransparent ? null : const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }
}
