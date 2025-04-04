import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class EventModel {
  final String id; // Assuming backend returns ID as string or can be converted
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final int maxParticipants;
  final List<String> participants; // Assuming backend sends participant IDs as strings
  final String creatorId; // Assuming backend sends creator ID as string
  final String communityId; // Assuming backend sends community ID as string
  final String? imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.maxParticipants,
    required this.participants,
    required this.creatorId,
    required this.communityId,
    this.imageUrl,
  });

  // Check if event is full
  bool get isFull => participants.length >= maxParticipants;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Basic validation
    if (json['id'] == null || json['title'] == null || json['location'] == null || json['event_timestamp'] == null || json['max_participants'] == null || json['creator_id'] == null || json['community_id'] == null) {
      print("Error parsing EventModel: Missing required fields in JSON: $json");
      throw FormatException("Missing required fields in EventModel JSON", json);
    }

    DateTime parsedDateTime;
    try {
      // Assuming backend sends timestamp in ISO 8601 format
      parsedDateTime = DateTime.parse(json['event_timestamp'] as String).toLocal();
    } catch (e) {
      print("Error parsing event_timestamp '${json['event_timestamp']}': $e. Using current time.");
      parsedDateTime = DateTime.now(); // Fallback
    }

    List<String> parsedParticipants = [];
    if (json['participants'] is List) {
      // Assuming participants are just user IDs (need adjustment if full user objects are sent)
      try {
        parsedParticipants = (json['participants'] as List<dynamic>)
            .map((p) => p.toString()) // Convert participant IDs to string robustly
            .toList();
      } catch (e) {
        print("Error parsing participants list: $e");
        // Keep parsedParticipants empty or handle differently
      }
    } else if (json['participant_count'] != null) {
      // Sometimes only count is sent, handle if needed (though our model expects IDs)
      print("Note: Received participant_count, but model expects participant IDs.");
    }


    return EventModel(
      id: json['id'].toString(), // Ensure ID is a string
      title: json['title'] as String,
      description: json['description'] as String? ?? '', // Handle null description
      location: json['location'] as String,
      dateTime: parsedDateTime,
      maxParticipants: json['max_participants'] as int,
      participants: parsedParticipants, // Use the parsed list
      creatorId: json['creator_id'].toString(), // Ensure ID is a string
      communityId: json['community_id'].toString(), // Ensure ID is a string
      imageUrl: json['image_url'] as String?, // Handle null image URL
    );
  }

  // Method to create mock data for development (Keep for testing if needed)
  static List<EventModel> getMockEvents() {
    return [
      EventModel(
        id: '1', // Use String IDs
        title: 'Tech Conference 2023',
        description: 'Annual tech conference with workshops, panels, and networking opportunities.',
        location: 'Convention Center',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxParticipants: 20,
        participants: ['102', '103', '104'], // String IDs
        creatorId: '100', // String ID
        communityId: '1', // String ID
        imageUrl: 'https://images.unsplash.com/photo-1523580494863-6f3031224c94',
      ),
      // ... other mock events ...
    ];
  }
}