// lib/screens/community_detail_screen.dart
import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../widgets/custom_button.dart'; // Assuming you have this

class CommunityDetailScreen extends StatefulWidget {
  final Map<String, dynamic> community;
  final bool initialIsJoined;
  final Function(String communityId, bool currentlyJoined) onToggleJoin; // Callback

  const CommunityDetailScreen({
    Key? key,
    required this.community,
    required this.initialIsJoined,
    required this.onToggleJoin,
  }) : super(key: key);

  @override
  _CommunityDetailScreenState createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late bool _isJoined; // Local state for immediate UI feedback

  @override
  void initState() {
    super.initState();
    _isJoined = widget.initialIsJoined;
  }

  void _handleJoinToggle() {
    // Update local state immediately
    setState(() {
      _isJoined = !_isJoined;
    });
    // Call the actual logic passed from the parent screen
    widget.onToggleJoin(widget.community['id'].toString(), !_isJoined); // Pass the *previous* state
  }

  void _navigateToChat() {
    // Dummy action for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Community chat page navigation (Not Implemented)'),
        duration: Duration(seconds: 2),
      ),
    );
    // In the future:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(communityId: widget.community['id'])));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final communityColors = ThemeConstants.communityColors;
    final color = communityColors[widget.community['id'].hashCode % communityColors.length];

    // Safely extract data with defaults
    final String name = widget.community['name'] ?? 'Unnamed Community';
    final String description = widget.community['description'] ?? 'No description available.';
    final int memberCount = widget.community['member_count'] as int? ?? 0;
    final int onlineCount = widget.community['online_count'] as int? ?? 0;
    final String? location = widget.community['primary_location']?.toString();
    final String communityId = widget.community['id'].toString(); // Ensure ID is string

    return Scaffold(
      backgroundColor: Colors.transparent, // Needed for the overlay effect
      body: GestureDetector(
        // Allows tapping the background overlay to dismiss
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black.withOpacity(0.6), // The dark overlay
          child: Center(
            child: GestureDetector(
              // Prevents taps inside the card from dismissing
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding, vertical: 50), // Add vertical margin too
                constraints: const BoxConstraints(maxWidth: 500), // Limit max width on larger screens/tablets
                decoration: BoxDecoration(
                  color: isDark ? ThemeConstants.backgroundDarker : Colors.white,
                  borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius * 1.5), // Slightly larger radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias, // Clip content to rounded corners
                child: SingleChildScrollView( // Allow content to scroll if it overflows
                   padding: const EdgeInsets.all(ThemeConstants.largePadding),
                   child: Column(
                      mainAxisSize: MainAxisSize.min, // Take minimum space needed by content
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header (Optional: Add a similar gradient or image if needed)
                        // For simplicity, we'll just start with the name

                        // Community Name
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color, // Use community color for title
                              ),
                        ),
                        const SizedBox(height: ThemeConstants.smallPadding),

                        // Member/Online Counts & Location Row
                        Row(
                          children: [
                            _buildInfoChip(
                              context,
                              icon: Icons.people_outline,
                              text: '$memberCount Members',
                              isDark: isDark,
                            ),
                            const SizedBox(width: ThemeConstants.smallPadding),
                            _buildInfoChip(
                              context,
                              icon: Icons.online_prediction,
                              text: '$onlineCount Online',
                              iconColor: Colors.green, // Indicate online status
                              isDark: isDark,
                            ),
                          ],
                        ),
                        if (location != null && location.isNotEmpty) ...[
                           const SizedBox(height: ThemeConstants.smallPadding),
                          _buildInfoChip(
                            context,
                            icon: Icons.location_on_outlined,
                            text: location,
                            isDark: isDark,
                          ),
                        ],
                        const SizedBox(height: ThemeConstants.mediumPadding),
                        Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        const SizedBox(height: ThemeConstants.mediumPadding),

                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: ThemeConstants.smallPadding / 2),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: ThemeConstants.largePadding), // Space before buttons

                        // Action Buttons
                        Row(
                          children: [
                            // Join/Leave Button
                            Expanded(
                              child: CustomButton( // Or ElevatedButton
                                text: _isJoined ? 'Leave' : 'Join',
                                onPressed: _handleJoinToggle,
                                type: _isJoined ? ButtonType.secondary : ButtonType.primary, // Style based on state
                                icon: _isJoined ? Icons.logout : Icons.person_add_alt_1,
                              ),
                            ),
                            const SizedBox(width: ThemeConstants.mediumPadding),
                            // Go to Chat Button
                            Expanded(
                              child: CustomButton( // Or ElevatedButton
                                text: 'Go to Chat',
                                onPressed: _navigateToChat,
                                //type: ButtonType.tertiary, // Different style for chat button
                                icon: Icons.chat_bubble_outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for info chips (Members, Online, Location)
  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String text, Color? iconColor, required bool isDark}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20), // Make them pill-shaped
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}