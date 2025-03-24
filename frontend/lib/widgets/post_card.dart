import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'custom_card.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String content;
  final String? authorName;
  final String? authorAvatar;
  final String? timeAgo;
  final int? upvotes;
  final int? downvotes;
  final int? replyCount;
  final bool hasUpvoted;
  final bool hasDownvoted;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final bool isOwner;
  final String? communityName;
  final Color? communityColor;

  const PostCard({
    Key? key,
    required this.title,
    required this.content,
    this.authorName,
    this.authorAvatar,
    this.timeAgo,
    this.upvotes,
    this.downvotes,
    this.replyCount,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.onReply,
    this.onDelete,
    this.isOwner = false,
    this.communityName,
    this.communityColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      elevation: 3,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with author info
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            child: Row(
              children: [
                // Author Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundImage: authorAvatar != null
                    ? NetworkImage(authorAvatar!)
                    : null,
                  backgroundColor: ThemeConstants.primaryColor.withOpacity(0.2),
                  child: authorAvatar == null
                    ? const Icon(Icons.person, color: ThemeConstants.primaryColor)
                    : null,
                ),
                const SizedBox(width: ThemeConstants.smallPadding),

                // Author Name, Community, and Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author name in bold
                      Row(
                        children: [
                          Text(
                            authorName ?? 'Anonymous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (isOwner)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConstants.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'OP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Time ago and community
                      Row(
                        children: [
                          if (communityName != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: communityColor ?? ThemeConstants.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'r/$communityName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            timeAgo ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // More Options
                if (isOwner && onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            child: Text(
              content,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
          ),

          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.smallPadding,
              vertical: ThemeConstants.smallPadding,
            ),
            decoration: BoxDecoration(
              color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(ThemeConstants.cardBorderRadius),
                bottomRight: Radius.circular(ThemeConstants.cardBorderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Upvote
                _buildActionButton(
                  icon: hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: upvotes?.toString() ?? '0',
                  onTap: onUpvote,
                  selected: hasUpvoted,
                  selectedColor: ThemeConstants.secondaryColor,
                ),

                // Downvote
                _buildActionButton(
                  icon: hasDownvoted ? Icons.thumb_down : Icons.thumb_down_outlined,
                  label: downvotes?.toString() ?? '0',
                  onTap: onDownvote,
                  selected: hasDownvoted,
                  selectedColor: ThemeConstants.errorColor,
                ),

                // Reply
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: replyCount?.toString() ?? '0',
                  onTap: onReply,
                ),

                // Share
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool selected = false,
    Color? selectedColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                ? (selectedColor ?? ThemeConstants.primaryColor)
                : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                  ? (selectedColor ?? ThemeConstants.primaryColor)
                  : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
