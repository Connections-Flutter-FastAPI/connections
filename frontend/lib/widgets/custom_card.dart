import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Function()? onTap;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardTheme.color,
          borderRadius: borderRadius ?? BorderRadius.circular(ThemeConstants.cardBorderRadius),
          border: border,
          boxShadow: boxShadow ?? [
            if (elevation != null && elevation! > 0)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: elevation! * 3,
                spreadRadius: elevation! * 0.2,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: child,
      ),
    );
  }
}
