// frontend/lib/widgets/chat_event_card.dart
// No structural changes needed, already uses EventModel.
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/theme_constants.dart';
import 'package:intl/intl.dart';
import '../app_constants.dart'; // For potential image URL construction

class ChatEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onJoin; // Renamed from onJoin for clarity (it toggles join/leave)
  final bool isJoined;
  final bool showJoinButton;

  const ChatEventCard({
    Key? key,
    required this.event,
    required this.onTap,
    this.onJoin, // Callback when the button is pressed
    this.isJoined = false, // Current join status of the user
    this.showJoinButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateFormatter = DateFormat('EEEE, MMM d, y');
    final timeFormatter = DateFormat('h:mm a');
    final dateString = dateFormatter.format(event.dateTime);
    final timeString = timeFormatter.format(event.dateTime);

    // Construct full image URL if available
    final String? fullImageUrl = event.imageUrl != null
        ? (event.imageUrl!.startsWith('http') ? event.imageUrl : '${AppConstants.baseUrl}/${event.imageUrl}')
        : null;


    return GestureDetector(
      onTap: onTap, // Tap the whole card
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient( // Keep gradient background
            colors: [
              isDark ? ThemeConstants.backgroundDarker.withOpacity(0.8) : Colors.white,
              isDark ? ThemeConstants.backgroundDark.withOpacity(0.9) : Colors.grey.shade50,
            ],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
          boxShadow: ThemeConstants.softShadow(),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1),
        ),
        clipBehavior: Clip.antiAlias, // Clip content like images
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional Image Header
            if (fullImageUrl != null)
              Image.network(
                fullImageUrl,
                height: 120, // Adjust height as needed
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                ),
              ),

            // Event Header (Consistent styling)
            Container(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
              // Use a solid color if no image, maybe derived from community?
              color: fullImageUrl == null ? ThemeConstants.accentColor.withOpacity(isDark ? 0.2 : 0.1) : Colors.transparent,
              child: Row(
                children: [
                  Icon(Icons.event, color: ThemeConstants.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Separator if there's an image header
            if (fullImageUrl != null) const Divider(height: 1),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.access_time, '$dateString at $timeString', isDark),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on, event.location, isDark),
                  const SizedBox(height: 8),
                  if (event.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 24), // Indent description
                      child: Text(
                        event.description,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  _buildDetailRow(Icons.people, '${event.participants.length} / ${event.maxParticipants} participants', isDark, isBold: true),
                  const SizedBox(height: 16),

                  // Join/Leave Button
                  if (showJoinButton && onJoin != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: event.isFull && !isJoined ? null : onJoin, // Disable join if full and not already joined
                        icon: Icon(isJoined ? Icons.check_circle_outline : Icons.add_circle_outline, size: 18),
                        label: Text(isJoined ? 'Joined' : (event.isFull ? 'Event Full' : 'Join Event')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300) : ThemeConstants.accentColor,
                          foregroundColor: isJoined ? (isDark ? Colors.white70 : Colors.black54) : ThemeConstants.primaryColor,
                          disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          disabledForegroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for detail rows
  Widget _buildDetailRow(IconData icon, String text, bool isDark, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ThemeConstants.accentColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}