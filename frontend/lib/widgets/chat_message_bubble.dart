import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../theme/theme_constants.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onLongPress;
  final Function(String)? onReactionSelected;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    this.onLongPress,
    this.onReactionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format timestamp as hh:mm AM/PM
    final formatter = DateFormat('h:mm a');
    final timeString = formatter.format(message.timestamp);

    // Set different colors for sent vs received messages
    final bubbleColor = message.isCurrentUser
      ? LinearGradient(
          colors: [
            Color(0xFF0d1b4a),
            Color(0xFF0d2b6a),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : LinearGradient(
          colors: [
            isDark ? Color(0xFF1a1a2e) : Color(0xFFe8eaf6),
            isDark ? Color(0xFF2a2a3e) : Color(0xFFc5cae9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final textColor = message.isCurrentUser
      ? Colors.white
      : (isDark ? Colors.white : Colors.black87);

    final timeColor = message.isCurrentUser
      ? Colors.white70
      : (isDark ? Colors.white60 : Colors.black54);

    return Align(
      alignment: message.isCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isCurrentUser ? 80 : 8,
          right: message.isCurrentUser ? 8 : 80,
          top: 4,
          bottom: 4,
        ),
        child: InkWell(
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: bubbleColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!message.isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: ThemeConstants.accentColor,
                      ),
                    ),
                  ),
                Text(
                  message.content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 10,
                            color: timeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (message.reactions != null && message.reactions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 4,
                      children: message.reactions!
                          .map((reaction) => _buildReaction(reaction))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReaction(String reaction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        reaction,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
