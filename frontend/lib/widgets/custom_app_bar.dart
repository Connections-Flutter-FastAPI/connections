import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final double height;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.height = kToolbarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      actions: actions,
      leading: leading,
      elevation: elevation,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? ThemeConstants.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      bottom: bottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));
}
