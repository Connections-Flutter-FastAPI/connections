// frontend/lib/widgets/reply_card.dart
import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../app_constants.dart'; // For potential image URL construction
// Removed CustomCard import if not used, simple Container/Padding is fine
// import 'custom_card.dart';

class ReplyCard extends StatelessWidget {
  final String content;
  final String? authorName;
  final String? authorAvatar; // Expecting relative path or full URL
  final String? timeAgo; // Keep as formatted string
  final VoidCallback? onReply;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onDelete;
  final bool isOwner;
  final bool hasUpvoted;
  final bool hasDownvoted;
  final int upvotes; // Now non-nullable, default to 0
  final int downvotes; // Now non-nullable, default to 0
  final int indentLevel;
  final Color? authorHighlightColor; // For OP highlighting

  const ReplyCard({
    Key? key,
    required this.content,
    this.authorName,
    this.authorAvatar,
    this.timeAgo,
    this.onReply,
    this.onUpvote,
    this.onDownvote,
    this.onDelete,
    this.isOwner = false,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
    this.upvotes = 0, // Default value
    this.downvotes = 0, // Default value
    required this.indentLevel,
    this.authorHighlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double indentPadding = indentLevel * 20.0; // Increase indent space slightly
    final Color cardBackgroundColor = isDark ? ThemeConstants.backgroundDark : Colors.white;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    // Construct full avatar URL if needed
    final String? fullAvatarUrl = authorAvatar != null
        ? (authorAvatar!.startsWith('http') ? authorAvatar : '${AppConstants.baseUrl}/$authorAvatar')
        : null;


    return Container(
      margin: EdgeInsets.only(left: indentPadding, bottom: indentLevel > 0 ? 4.0 : 8.0), // Apply indent margin
      padding: const EdgeInsets.all(12.0), // Consistent padding inside
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        border: indentLevel > 0 ? Border(left: BorderSide(color: borderColor, width: 2.0)) : null, // Indent line
        boxShadow: indentLevel == 0 ? ThemeConstants.softShadow() : null, // Shadow only for top-level
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 14, // Smaller avatar for replies
                backgroundColor: ThemeConstants.primaryColor.withOpacity(0.5),
                backgroundImage: fullAvatarUrl != null ? NetworkImage(fullAvatarUrl) : null,
                child: fullAvatarUrl == null
                    ? Text(
                  authorName != null && authorName!.isNotEmpty ? authorName![0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authorName ?? 'Anonymous',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: authorHighlightColor ?? (isDark ? Colors.white70 : Colors.black87)),
                ),
              ),
              if (timeAgo != null)
                Text(
                  timeAgo!,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey.shade600),
                ),
              if (isOwner && onDelete != null)
                SizedBox( // Constrain IconButton size
                  height: 24, width: 24,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: ThemeConstants.errorColor,
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete Reply',
                    onPressed: onDelete,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Padding(
            padding: const EdgeInsets.only(left: 36.0), // Indent content relative to avatar
            child: Text(
              content,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, height: 1.4, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),

          // Actions row
          Padding(
            padding: const EdgeInsets.only(left: 30.0), // Indent actions
            child: Row(
              children: [
                _buildActionButton(icon: Icons.arrow_upward, label: upvotes.toString(), onTap: onUpvote, selected: hasUpvoted, selectedColor: ThemeConstants.accentColor),
                const SizedBox(width: 12),
                _buildActionButton(icon: Icons.arrow_downward, label: downvotes.toString(), onTap: onDownvote, selected: hasDownvoted, selectedColor: ThemeConstants.errorColor),
                const SizedBox(width: 12),
                _buildActionButton(icon: Icons.reply, label: 'Reply', onTap: onReply),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Keep _buildActionButton helper
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool selected = false,
    Color? selectedColor,
  }) {
    final theme = Theme.of(context); // Access theme here
    final isDark = theme.brightness == Brightness.dark;
    final Color effectiveColor = selected
        ? (selectedColor ?? ThemeConstants.accentColor) // Use accent if selectedColor is null
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConstants.borderRadius / 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Prevent row from expanding unnecessarily
          children: [
            Icon(icon, size: 14, color: effectiveColor), // Slightly smaller icon
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, // Smaller font
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
