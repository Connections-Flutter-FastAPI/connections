import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomBottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;
  final bool showBadge;
  final int? badgeCount;

  CustomBottomNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    IconData? activeIcon,
    this.showBadge = false,
    this.badgeCount,
  }) : activeIcon = activeIcon ?? icon;
}

class CustomBottomNav extends StatelessWidget {
  final List<CustomBottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double iconSize;
  final double fontSize;
  final bool showLabels;
  final bool enableFloating;

  const CustomBottomNav({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height = 60,
    this.iconSize = 26,
    this.fontSize = 12,
    this.showLabels = true,
    this.enableFloating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ?? (isDark
      ? ThemeConstants.backgroundDarkest
      : Colors.white);

    final activeItemColor = activeColor ?? ThemeConstants.primaryColor;
    final inactiveItemColor = inactiveColor ?? (isDark
      ? Colors.grey.shade600
      : Colors.grey.shade700);

    // For floating effect
    final navBar = Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
        borderRadius: enableFloating
          ? BorderRadius.circular(30)
          : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background flash animation on active
                  if (isActive)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: ThemeConstants.shortAnimation,
                      builder: (context, value, child) {
                        return Container(
                          width: 56 * value,
                          height: 56 * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeItemColor.withOpacity(0.1),
                          ),
                        );
                      },
                    ),

                  // Icon & Label
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? activeItemColor : inactiveItemColor,
                        size: iconSize,
                      ),

                      // Label
                      if (showLabels)
                        const SizedBox(height: 4),
                      if (showLabels)
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? activeItemColor : inactiveItemColor,
                            fontSize: fontSize,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),

                  // Badge
                  if (item.showBadge)
                    Positioned(
                      top: showLabels ? 8 : (height - iconSize) / 2 - 8,
                      right: Directionality.of(context) == TextDirection.rtl ? null : 16,
                      left: Directionality.of(context) == TextDirection.rtl ? 16 : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: item.badgeCount != null ? 6 : 0,
                          vertical: item.badgeCount != null ? 2 : 0,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          color: ThemeConstants.errorColor,
                          shape: item.badgeCount != null ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: item.badgeCount != null ? BorderRadius.circular(9) : null,
                          border: Border.all(color: bgColor, width: 2),
                        ),
                        child: item.badgeCount != null
                            ? Center(
                                child: Text(
                                  item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );

    // Apply floating effect if enabled
    if (enableFloating) {
      return Padding(
        padding: const EdgeInsets.only(
          left: ThemeConstants.mediumPadding,
          right: ThemeConstants.mediumPadding,
          bottom: ThemeConstants.mediumPadding,
        ),
        child: navBar,
      );
    } else {
      return navBar;
    }
  }
}
