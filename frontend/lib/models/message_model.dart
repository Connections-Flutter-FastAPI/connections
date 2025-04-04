import 'package:flutter/material.dart';

class MessageModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final bool isCurrentUser;
  final List<String>? reactions;
  final String? imageUrl;

  MessageModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    required this.isCurrentUser,
    this.reactions,
    this.imageUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isCurrentUser: json['is_current_user'] as bool,
      reactions: json['reactions'] != null
          ? List<String>.from(json['reactions'] as List)
          : null,
      imageUrl: json['image_url'] as String?,
    );
  }

  // Method to create mock data for development
  static List<MessageModel> getMockMessages() {
    return [
      MessageModel(
        id: '1',
        userId: '100',
        username: 'John Smith',
        content: 'Hello everyone! Who\'s coming to the tech conference tomorrow?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isCurrentUser: false,
      ),
      MessageModel(
        id: '2',
        userId: '101',
        username: 'Sophie Miller',
        content: 'I\'ll be there! Really excited about the AI panel.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isCurrentUser: false,
      ),
      MessageModel(
        id: '3',
        userId: '102',
        username: 'Current User',
        content: 'Count me in! I\'ve registered for the workshop too.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isCurrentUser: true,
      ),
      MessageModel(
        id: '4',
        userId: '100',
        username: 'John Smith',
        content: 'Great! Let\'s meet at the entrance around 9:30?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isCurrentUser: false,
      ),
      MessageModel(
        id: '5',
        userId: '102',
        username: 'Current User',
        content: 'Sounds good to me. I\'ll be wearing a blue jacket.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isCurrentUser: true,
      ),
    ];
  }
}
