import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'custom_card.dart';

class ReplyCard extends StatelessWidget {
  final String content;
  final String? authorName;
  final String? authorAvatar;
  final String? timeAgo;
  final List<ReplyCard>? childReplies;
  final VoidCallback? onReply;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onDelete;
  final bool isOwner;
  final bool hasUpvoted;
  final bool hasDownvoted;
  final int? upvotes;
  final int? downvotes;
  final int indentLevel;
  final Color? authorHighlightColor;

  const ReplyCard({
    Key? key,
    required this.content,
    this.authorName,
    this.authorAvatar,
    this.timeAgo,
    this.childReplies,
    this.onReply,
    this.onUpvote,
    this.onDownvote,
    this.onDelete,
    this.isOwner = false,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
    this.upvotes,
    this.downvotes,
    this.indentLevel = 0,
    this.authorHighlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indentWidth = 8.0 + (indentLevel * 12.0);

    final bool hasChildren = childReplies != null && childReplies!.isNotEmpty;

    // Limit indent level to prevent replies from getting too narrow
    final effectiveIndent = indentLevel > 5 ? 5 : indentLevel;

    // Generate a color for the indent line based on indent level
    final colors = ThemeConstants.communityColors;
    final indentColor = effectiveIndent > 0
        ? colors[effectiveIndent % colors.length]
        : Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indent markers
            if (effectiveIndent > 0)
              Container(
                width: indentWidth,
                height: null, // Full height
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: indentColor.withOpacity(0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),

            // Reply content
            Expanded(
              child: CustomCard(
                backgroundColor: isDark
                  ? ThemeConstants.backgroundDark
                  : Colors.white,
                padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                elevation: 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author info
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: authorAvatar != null
                            ? NetworkImage(authorAvatar!)
                            : null,
                          backgroundColor: authorHighlightColor != null
                            ? authorHighlightColor!.withOpacity(0.2)
                            : ThemeConstants.primaryColor.withOpacity(0.2),
                          child: authorAvatar == null
                            ? const Icon(
                                Icons.person,
                                color: ThemeConstants.primaryColor,
                                size: 14,
                              )
                            : null,
                        ),

                        const SizedBox(width: 8),

                        // Author name
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                authorName ?? 'Anonymous',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: authorHighlightColor ?? (isDark
                                    ? Colors.white
                                    : Colors.black87),
                                  fontSize: 14,
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
                                    color: authorHighlightColor ?? ThemeConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'OP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Time
                        if (timeAgo != null)
                          Text(
                            timeAgo!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),

                        // Delete option
                        if (isOwner && onDelete != null)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 8),
                            onPressed: onDelete,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Content
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade200 : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Actions
                    Row(
                      children: [
                        // Upvote
                        _buildActionButton(
                          icon: hasUpvoted
                            ? Icons.arrow_upward
                            : Icons.arrow_upward_outlined,
                          label: upvotes?.toString() ?? '0',
                          onTap: onUpvote,
                          selected: hasUpvoted,
                          selectedColor: ThemeConstants.secondaryColor,
                        ),

                        // Downvote
                        _buildActionButton(
                          icon: hasDownvoted
                            ? Icons.arrow_downward
                            : Icons.arrow_downward_outlined,
                          label: downvotes?.toString() ?? '0',
                          onTap: onDownvote,
                          selected: hasDownvoted,
                          selectedColor: ThemeConstants.errorColor,
                        ),

                        // Reply
                        _buildActionButton(
                          icon: Icons.reply,
                          label: 'Reply',
                          onTap: onReply,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Child replies
        if (hasChildren)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: childReplies!.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReplyCard(
                    content: reply.content,
                    authorName: reply.authorName,
                    authorAvatar: reply.authorAvatar,
                    timeAgo: reply.timeAgo,
                    childReplies: reply.childReplies,
                    onReply: reply.onReply,
                    onUpvote: reply.onUpvote,
                    onDownvote: reply.onDownvote,
                    onDelete: reply.onDelete,
                    isOwner: reply.isOwner,
                    hasUpvoted: reply.hasUpvoted,
                    hasDownvoted: reply.hasDownvoted,
                    upvotes: reply.upvotes,
                    downvotes: reply.downvotes,
                    indentLevel: indentLevel + 1,
                    authorHighlightColor: reply.authorHighlightColor,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                ? (selectedColor ?? ThemeConstants.primaryColor)
                : Colors.grey.shade600,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
