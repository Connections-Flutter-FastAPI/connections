import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? borderColor;
  final Gradient? gradient;
  final BoxShape shape;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  const CustomCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.color,
    this.padding = const EdgeInsets.all(ThemeConstants.mediumPadding),
    this.margin = EdgeInsets.zero,
    this.elevation = 1,
    this.borderRadius,
    this.onTap,
    this.hasBorder = false,
    this.borderColor,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = color ??
        (isDark ? ThemeConstants.backgroundDarker : Colors.white);

    final BorderRadius effectiveBorderRadius = shape == BoxShape.rectangle
        ? (borderRadius ?? BorderRadius.circular(ThemeConstants.cardBorderRadius))
        : BorderRadius.zero;

    final Widget cardContent = Padding(
      padding: padding,
      child: child,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient != null ? null : cardColor,
        borderRadius: shape == BoxShape.rectangle ? effectiveBorderRadius : null,
        shape: shape,
        gradient: gradient,
        border: hasBorder
            ? Border.all(
                color: borderColor ??
                    (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                width: 1,
              )
            : null,
        boxShadow: boxShadow ??
            (elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: elevation * 2,
                      spreadRadius: elevation / 2,
                      offset: Offset(0, elevation),
                    ),
                  ]
                : null),
      ),
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: effectiveBorderRadius,
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
