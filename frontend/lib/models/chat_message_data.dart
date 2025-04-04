import 'package:flutter/foundation.dart'; // For required annotation if needed

class ChatMessageData {
  final int message_id; // Use underscore to match backend JSON keys
  final int? community_id;
  final int? event_id;
  final int user_id;
  final String username;
  final String content;
  final DateTime timestamp;

  ChatMessageData({
    required this.message_id,
    this.community_id,
    this.event_id,
    required this.user_id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    // More robust check for null core fields
    if (json['message_id'] == null || json['user_id'] == null || json['content'] == null || json['timestamp'] == null) {
      print("Error parsing ChatMessageData: Missing required fields in JSON: $json");
      throw FormatException("Missing required fields in ChatMessageData JSON", json);
    }

    DateTime parsedTimestamp;
    try {
      // Ensure it handles potential timezone info correctly from ISO 8601
      parsedTimestamp = DateTime.parse(json['timestamp'] as String).toLocal();
    } catch (e) {
      print("Error parsing timestamp '${json['timestamp']}': $e. Using current time as fallback.");
      parsedTimestamp = DateTime.now().toLocal(); // Fallback to local time
    }

    return ChatMessageData(
      message_id: json['message_id'] as int,
      community_id: json['community_id'] as int?,
      event_id: json['event_id'] as int?,
      user_id: json['user_id'] as int,
      // Backend provides username directly in the chat message fetch
      username: json['username'] as String? ?? 'Unknown User',
      content: json['content'] as String,
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'message_id': message_id,
    'community_id': community_id,
    'event_id': event_id,
    'user_id': user_id,
    'username': username,
    'content': content,
    'timestamp': timestamp.toUtc().toIso8601String(), // Send as UTC ISO string
  };
}