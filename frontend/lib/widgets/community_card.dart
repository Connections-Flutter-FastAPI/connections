import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CommunityCard extends StatelessWidget {
  final String name;
  final String? description;
  final int memberCount;
  final int onlineCount;
  final Color backgroundColor;
  final String? imageUrl;
  final String? location;
  final bool isJoined;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  const CommunityCard({
    Key? key,
    required this.name,
    this.description,
    required this.memberCount,
    required this.onlineCount,
    required this.backgroundColor,
    this.imageUrl,
    this.location,
    required this.isJoined,
    required this.onJoin,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeConstants.backgroundDarker : Colors.white,
          borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient background
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background design elements
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),

                  // Community initial in circle
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Location badge (if provided)
                  if (location != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              location!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Community details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description (if provided)
                    if (description != null && description!.isNotEmpty)
                      Expanded(
                        child: Text(
                          description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const Spacer(),

                    // Member counts
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 12,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$memberCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$onlineCount online',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Join/Leave button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onJoin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined
                              ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                              : ThemeConstants.accentColor,
                          foregroundColor: isJoined
                              ? (isDark ? Colors.white : Colors.black87)
                              : ThemeConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          elevation: 0,
                        ),
                        child: Text(isJoined ? 'Joined' : 'Join'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
