import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'custom_card.dart';

class CommunityCard extends StatelessWidget {
  final String name;
  final String? description;
  final int? memberCount;
  final int? onlineCount;
  final Color backgroundColor;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool isJoined;
  final String? location;

  const CommunityCard({
    Key? key,
    required this.name,
    this.description,
    this.memberCount,
    this.onlineCount,
    this.backgroundColor = ThemeConstants.primaryColor,
    this.imageUrl,
    this.onTap,
    this.onJoin,
    this.isJoined = false,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
      ? ThemeConstants.backgroundDark
      : Colors.white;

    return CustomCard(
      elevation: 4,
      onTap: onTap,
      padding: EdgeInsets.zero,
      backgroundColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with background color and community circle
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(ThemeConstants.cardBorderRadius),
                topRight: Radius.circular(ThemeConstants.cardBorderRadius),
              ),
            ),
            child: Stack(
              children: [
                // Pattern overlay
                Opacity(
                  opacity: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(ThemeConstants.cardBorderRadius),
                        topRight: Radius.circular(ThemeConstants.cardBorderRadius),
                      ),
                      // Pattern
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://www.transparenttextures.com/patterns/subtle-white-feathers.png'
                        ),
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                  ),
                ),

                // Location tag if available
                if (location != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
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

          // Community Avatar
          Transform.translate(
            offset: const Offset(0, -24),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cardColor,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: backgroundColor,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null
                    ? Text(
                        name.substring(0, name.length > 0 ? 1 : 0).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : null,
                ),
              ),
            ),
          ),

          // Community Info - centered to account for the offset avatar
          Transform.translate(
            offset: const Offset(0, -12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  // Member counts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (memberCount != null) ...[
                        Icon(
                          Icons.people,
                          size: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount members',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],

                      if (memberCount != null && onlineCount != null)
                        const SizedBox(width: 12),

                      if (onlineCount != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$onlineCount online',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Description (if available)
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Join Button
          if (onJoin != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemeConstants.mediumPadding,
                0,
                ThemeConstants.mediumPadding,
                ThemeConstants.mediumPadding,
              ),
              child: ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined
                    ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                    : backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  isJoined ? 'Joined' : 'Join Community',
                  style: TextStyle(
                    color: isJoined
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
