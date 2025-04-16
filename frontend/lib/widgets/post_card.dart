// frontend/lib/widgets/post_card.dart
// No structural changes needed, but ensure props match fetched data keys.
// Added DateFormat import and usage.
import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../app_constants.dart'; // For constructing image URLs potentially
import 'package:intl/intl.dart'; // For date formatting

class PostCard extends StatelessWidget {
  final String title;
  final String content;
  final String? authorName;
  final String? authorAvatar; // Expecting full URL or relative path like "user_images/..."
  final String timeAgo; // Keep as formatted string for simplicity here
  final int upvotes;
  final int downvotes;
  final int replyCount;
  final bool hasUpvoted;
  final bool hasDownvoted;
  final bool isOwner;
  final String? communityName;
  final Color? communityColor;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final VoidCallback onTap;

  const PostCard({
    Key? key,
    required this.title,
    required this.content,
    this.authorName,
    this.authorAvatar,
    required this.timeAgo, // Keep this prop as it's formatted in the parent
    required this.upvotes,
    required this.downvotes,
    required this.replyCount,
    required this.hasUpvoted,
    required this.hasDownvoted,
    required this.isOwner,
    this.communityName,
    this.communityColor,
    required this.onUpvote,
    required this.onDownvote,
    required this.onReply,
    this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Construct full avatar URL if a relative path is given
    final String? fullAvatarUrl = authorAvatar != null
        ? (authorAvatar!.startsWith('http') ? authorAvatar : '${AppConstants.baseUrl}/$authorAvatar')
        : null;


    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: ThemeConstants.primaryColor.withOpacity(0.5), // Fallback bg
                    backgroundImage: fullAvatarUrl != null
                        ? NetworkImage(fullAvatarUrl) // Use constructed URL
                        : null,
                    child: fullAvatarUrl == null // Show initial only if no image URL
                        ? Text(
                      authorName != null && authorName!.isNotEmpty
                          ? authorName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName ?? 'Anonymous',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        ),
                        Text(
                          timeAgo, // Display pre-formatted time string
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (communityName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (communityColor ?? ThemeConstants.highlightColor).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (communityColor ?? ThemeConstants.highlightColor).withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        communityName!,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: communityColor ?? ThemeConstants.highlightColor),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              // Title
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              // Content
              Text(
                content,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              // Action Row
              Row(
                children: [
                  _buildActionButton(Icons.arrow_upward, upvotes.toString(), hasUpvoted, ThemeConstants.accentColor, onUpvote, isDark),
                  _buildActionButton(Icons.arrow_downward, downvotes.toString(), hasDownvoted, ThemeConstants.errorColor, onDownvote, isDark),
                  _buildActionButton(Icons.chat_bubble_outline, replyCount.toString(), false, null, onReply, isDark),
                  const Spacer(),
                  if (isOwner && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: ThemeConstants.errorColor,
                      onPressed: onDelete,
                      tooltip: 'Delete Post',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep _buildActionButton as is
  Widget _buildActionButton(IconData icon, String count, bool isActive, Color? activeColor, VoidCallback onPressed, bool isDark) {
    final color = isActive ? activeColor : (isDark ? Colors.white54 : Colors.grey.shade600);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(count, style: TextStyle(color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}