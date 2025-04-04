import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomBottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  CustomBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });
}

class CustomBottomNav extends StatelessWidget {
  final List<CustomBottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final double elevation;
  final double iconSize;
  final double selectedFontSize;
  final double unselectedFontSize;

  const CustomBottomNav({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.elevation = 8,
    this.iconSize = 24,
    this.selectedFontSize = 12,
    this.unselectedFontSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? ThemeConstants.backgroundDarker : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: ThemeConstants.shortAnimation,
                            height: isSelected ? 40 : 32,
                            width: isSelected ? 40 : 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ThemeConstants.accentColor.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? ThemeConstants.accentColor
                                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                              size: isSelected ? iconSize : iconSize - 2,
                            ),
                          ),

                          // Badge
                          if (item.showBadge)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: ThemeConstants.errorColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    item.badgeCount > 99 ? '99+' : item.badgeCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? ThemeConstants.accentColor
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          fontSize: isSelected ? selectedFontSize : unselectedFontSize,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
